// Validator Set — Harmonic projection weight for PoV selection
//
// Mirrors Python src/consensus/validator_selection.py
//
// THREE-LAYER SELECTION:
//   1. Vault bond gate (binary): bonded >= MINIMUM_VAULT_BOND
//   2. Plücker eligibility gate (binary): d_Gr(stalk, μ) < MAX_DIVERGENCE
//   3. Harmonic projection weight (continuous): ‖π_H(stalk)‖ / ‖stalk‖
//
// Heavy math (Grassmann distance, Karcher mean, Hodge projection)
// is computed by Python Oracle workers. Rust receives the results
// and uses them for:
//   - VRF threshold: score < centrality(validator) → eligible
//   - Block reward distribution: proportional to harmonic weight
//   - Slashing: deactivate validator, zero their weight
//
// Reference: Swan et al. (2025) "Higher Categorical Cryptoeconomics"

use std::collections::HashMap;
use anyhow::{Result, bail};
use tracing::{debug, info, warn};

/// Minimum vault bond for validator eligibility (in smallest units)
pub const MINIMUM_VAULT_BOND: u64 = 1_000_000;

/// Maximum Grassmann divergence from consensus (radians, ~45°)
pub const MAX_DIVERGENCE: f64 = std::f64::consts::FRAC_PI_4;

/// Minimum centrality for validators without stalk data
pub const MIN_CENTRALITY: f64 = 0.01;

/// A validator in the network.
///
/// Identified by spectral fingerprint, not staked capital.
/// Selection probability comes from harmonic projection weight.
#[derive(Debug, Clone)]
pub struct Validator {
    /// Spectral fingerprint (32-byte identity)
    pub fingerprint: [u8; 32],
    /// Position in topology (vertex in Čech nerve)
    pub vertex_id: u64,
    /// Vault bond (for slashing, not selection weight)
    pub bond: u64,
    /// Currently active
    pub is_active: bool,
    /// Last block produced (epoch)
    pub last_block: u64,
    /// Harmonic projection weight ∈ (0, 1] — computed by Oracle
    ///
    /// weight = ‖π_H(stalk)‖ / ‖stalk‖
    /// Updated when Oracle provides new stalk computation.
    pub harmonic_weight: f64,
    /// Plücker centrality ∈ (0, 1] — fallback if harmonic unavailable
    ///
    /// centrality = 1 / (1 + d_Gr(stalk, consensus))
    pub plucker_centrality: f64,
    /// Ed25519 public key (for block signature verification)
    pub pubkey: [u8; 32],
}

impl Validator {
    /// Get the effective selection weight (harmonic preferred, then Plücker)
    pub fn selection_weight(&self) -> f64 {
        if self.harmonic_weight > MIN_CENTRALITY {
            self.harmonic_weight
        } else if self.plucker_centrality > MIN_CENTRALITY {
            self.plucker_centrality
        } else {
            MIN_CENTRALITY
        }
    }
}

/// Manages the validator set for PoV consensus.
///
/// Stores validators and their Oracle-computed centralities.
/// Provides VRF threshold computation and weighted selection.
pub struct ValidatorSet {
    /// fingerprint → Validator
    validators: HashMap<[u8; 32], Validator>,
    /// Cached normalized weights (sum to 1.0)
    cached_weights: Option<HashMap<[u8; 32], f64>>,
}

impl ValidatorSet {
    pub fn new() -> Self {
        Self {
            validators: HashMap::new(),
            cached_weights: None,
        }
    }

    /// Register a new validator.
    ///
    /// Initially has minimum weight until Oracle provides stalk computation.
    pub fn register(
        &mut self,
        fingerprint: [u8; 32],
        pubkey: [u8; 32],
        vertex_id: u64,
        bond: u64,
    ) -> Result<()> {
        if self.validators.contains_key(&fingerprint) {
            bail!("Validator already registered");
        }

        self.validators.insert(fingerprint, Validator {
            fingerprint,
            vertex_id,
            bond,
            is_active: true,
            last_block: 0,
            harmonic_weight: 0.0,
            plucker_centrality: 0.0,
            pubkey,
        });

        self.cached_weights = None;
        info!("Registered validator: {}", hex::encode(&fingerprint[..8]));
        Ok(())
    }

    /// Update a validator's harmonic weight (from Oracle computation).
    ///
    /// Called when Oracle provides: stalk → Hodge projection → weight
    pub fn update_harmonic_weight(&mut self, fingerprint: &[u8; 32], weight: f64) -> Result<()> {
        let v = self.validators.get_mut(fingerprint)
            .ok_or_else(|| anyhow::anyhow!("Unknown validator"))?;

        if weight < 0.0 || weight > 1.0 {
            bail!("Harmonic weight must be in [0, 1], got {}", weight);
        }

        v.harmonic_weight = weight;
        self.cached_weights = None;
        debug!("Updated harmonic weight: {} → {:.4}",
               hex::encode(&fingerprint[..8]), weight);
        Ok(())
    }

    /// Update a validator's Plücker centrality (from Oracle computation).
    ///
    /// Called when Oracle provides: stalk → Grassmann distance → centrality
    pub fn update_plucker_centrality(&mut self, fingerprint: &[u8; 32], centrality: f64) -> Result<()> {
        let v = self.validators.get_mut(fingerprint)
            .ok_or_else(|| anyhow::anyhow!("Unknown validator"))?;

        if centrality < 0.0 || centrality > 1.0 {
            bail!("Plücker centrality must be in [0, 1], got {}", centrality);
        }

        v.plucker_centrality = centrality;
        self.cached_weights = None;
        Ok(())
    }

    /// Deactivate a validator (slashing, voluntary exit).
    pub fn deactivate(&mut self, fingerprint: &[u8; 32]) -> Result<()> {
        let v = self.validators.get_mut(fingerprint)
            .ok_or_else(|| anyhow::anyhow!("Unknown validator"))?;
        v.is_active = false;
        self.cached_weights = None;
        warn!("Deactivated validator: {}", hex::encode(&fingerprint[..8]));
        Ok(())
    }

    /// Get all active validators.
    pub fn active_validators(&self) -> Vec<&Validator> {
        self.validators.values()
            .filter(|v| v.is_active)
            .collect()
    }

    /// Number of active validators.
    pub fn active_count(&self) -> usize {
        self.validators.values().filter(|v| v.is_active).count()
    }

    /// Get a validator by fingerprint.
    pub fn get(&self, fingerprint: &[u8; 32]) -> Option<&Validator> {
        self.validators.get(fingerprint)
    }

    /// Get all trusted worker pubkeys (for PoV signature verification).
    pub fn trusted_pubkeys(&self) -> Vec<[u8; 32]> {
        self.validators.values()
            .filter(|v| v.is_active)
            .map(|v| v.pubkey)
            .collect()
    }

    // =========================================================================
    // WEIGHT COMPUTATION
    // =========================================================================

    /// Compute normalized selection weights for all active validators.
    ///
    /// Priority:
    ///   1. Harmonic projection weight (if Oracle provided)
    ///   2. Plücker centrality (if Oracle provided)
    ///   3. Minimum weight (if no Oracle data yet)
    ///
    /// Returns fingerprint → normalized weight (sum = 1.0).
    pub fn compute_weights(&mut self) -> &HashMap<[u8; 32], f64> {
        if self.cached_weights.is_some() {
            return self.cached_weights.as_ref().unwrap();
        }

        let mut weights = HashMap::new();
        let mut total = 0.0;

        for v in self.validators.values() {
            if !v.is_active {
                continue;
            }

            let w = v.selection_weight();
            weights.insert(v.fingerprint, w);
            total += w;
        }

        // Normalize
        if total > 0.0 {
            for w in weights.values_mut() {
                *w /= total;
            }
        }

        self.cached_weights = Some(weights);
        self.cached_weights.as_ref().unwrap()
    }

    // =========================================================================
    // VRF THRESHOLD
    // =========================================================================

    /// Get VRF threshold for a specific validator.
    ///
    /// threshold = normalized_weight(validator)
    ///
    /// A validator is eligible to produce if:
    ///   VRF_score(prev_hash, epoch) < threshold
    ///
    /// Higher weight → higher threshold → more likely to produce.
    /// Single validator with weight 1.0 always produces.
    pub fn vrf_threshold(&mut self, fingerprint: &[u8; 32]) -> f64 {
        let weights = self.compute_weights();
        weights.get(fingerprint).copied().unwrap_or(0.0)
    }

    // =========================================================================
    // ELIGIBILITY GATES
    // =========================================================================

    /// Check vault bond eligibility.
    pub fn is_bond_eligible(&self, fingerprint: &[u8; 32]) -> bool {
        self.validators.get(fingerprint)
            .map(|v| v.is_active && v.bond >= MINIMUM_VAULT_BOND)
            .unwrap_or(false)
    }

    /// Check Plücker divergence eligibility.
    ///
    /// Returns true if validator has centrality above minimum
    /// (Oracle already verified d_Gr < MAX_DIVERGENCE when computing centrality).
    pub fn is_plucker_eligible(&self, fingerprint: &[u8; 32]) -> bool {
        self.validators.get(fingerprint)
            .map(|v| v.is_active && v.selection_weight() > MIN_CENTRALITY)
            .unwrap_or(false)
    }

    /// Full eligibility check (both gates).
    pub fn is_eligible(&self, fingerprint: &[u8; 32]) -> bool {
        self.is_bond_eligible(fingerprint) && self.is_plucker_eligible(fingerprint)
    }

    // =========================================================================
    // SELECTION
    // =========================================================================

    /// Select a validator for the next block using VRF-weighted selection.
    ///
    /// Uses the VRF output as a random value in [0, 1) and selects
    /// by cumulative weight (higher harmonic weight → more likely).
    pub fn select_producer(
        &mut self,
        vrf_random: f64,
    ) -> Option<[u8; 32]> {
        let weights = self.compute_weights().clone();
        if weights.is_empty() {
            return None;
        }

        // Sort by fingerprint for determinism
        let mut sorted: Vec<_> = weights.into_iter().collect();
        sorted.sort_by(|a, b| a.0.cmp(&b.0));

        let mut cumulative = 0.0;
        for (fp, w) in &sorted {
            cumulative += w;
            if vrf_random < cumulative {
                // Update last_block
                if let Some(v) = self.validators.get_mut(fp) {
                    v.last_block += 1;
                }
                return Some(*fp);
            }
        }

        // Fallback to last (rounding)
        sorted.last().map(|(fp, _)| *fp)
    }

    /// Record that a validator produced a block at this epoch.
    pub fn record_production(&mut self, fingerprint: &[u8; 32], epoch: u64) {
        if let Some(v) = self.validators.get_mut(fingerprint) {
            v.last_block = epoch;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use ed25519_dalek::{SigningKey, VerifyingKey};

    fn make_keypair(seed: u8) -> ([u8; 32], [u8; 32]) {
        let sk = SigningKey::from_bytes(&[seed; 32]);
        let pk = VerifyingKey::from(&sk).to_bytes();
        let mut fp = [0u8; 32];
        fp[0] = seed;
        (fp, pk)
    }

    #[test]
    fn test_register_and_count() {
        let mut vs = ValidatorSet::new();
        let (fp0, pk0) = make_keypair(0);
        let (fp1, pk1) = make_keypair(1);

        vs.register(fp0, pk0, 0, MINIMUM_VAULT_BOND).unwrap();
        vs.register(fp1, pk1, 1, MINIMUM_VAULT_BOND).unwrap();

        assert_eq!(vs.active_count(), 2);
    }

    #[test]
    fn test_duplicate_registration_fails() {
        let mut vs = ValidatorSet::new();
        let (fp, pk) = make_keypair(0);

        vs.register(fp, pk, 0, MINIMUM_VAULT_BOND).unwrap();
        assert!(vs.register(fp, pk, 0, MINIMUM_VAULT_BOND).is_err());
    }

    #[test]
    fn test_deactivate() {
        let mut vs = ValidatorSet::new();
        let (fp, pk) = make_keypair(0);

        vs.register(fp, pk, 0, MINIMUM_VAULT_BOND).unwrap();
        assert_eq!(vs.active_count(), 1);

        vs.deactivate(&fp).unwrap();
        assert_eq!(vs.active_count(), 0);
    }

    #[test]
    fn test_uniform_weights_no_oracle() {
        let mut vs = ValidatorSet::new();
        for i in 0u8..4 {
            let (fp, pk) = make_keypair(i);
            vs.register(fp, pk, i as u64, MINIMUM_VAULT_BOND).unwrap();
        }

        let weights = vs.compute_weights();
        // All should be equal (uniform — no Oracle data)
        assert_eq!(weights.len(), 4);
        for &w in weights.values() {
            assert!((w - 0.25).abs() < 1e-10);
        }
    }

    #[test]
    fn test_harmonic_weight_update() {
        let mut vs = ValidatorSet::new();
        let (fp0, pk0) = make_keypair(0);
        let (fp1, pk1) = make_keypair(1);

        vs.register(fp0, pk0, 0, MINIMUM_VAULT_BOND).unwrap();
        vs.register(fp1, pk1, 1, MINIMUM_VAULT_BOND).unwrap();

        // V0 gets high harmonic weight, V1 stays at minimum
        vs.update_harmonic_weight(&fp0, 0.9).unwrap();

        let weights = vs.compute_weights();
        let w0 = weights[&fp0];
        let w1 = weights[&fp1];

        // V0 should dominate
        assert!(w0 > w1);
        assert!((w0 + w1 - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_plucker_centrality_update() {
        let mut vs = ValidatorSet::new();
        let (fp0, pk0) = make_keypair(0);
        let (fp1, pk1) = make_keypair(1);

        vs.register(fp0, pk0, 0, MINIMUM_VAULT_BOND).unwrap();
        vs.register(fp1, pk1, 1, MINIMUM_VAULT_BOND).unwrap();

        vs.update_plucker_centrality(&fp0, 0.8).unwrap();
        vs.update_plucker_centrality(&fp1, 0.2).unwrap();

        let weights = vs.compute_weights();
        assert!(weights[&fp0] > weights[&fp1]);
    }

    #[test]
    fn test_harmonic_overrides_plucker() {
        let mut vs = ValidatorSet::new();
        let (fp, pk) = make_keypair(0);

        vs.register(fp, pk, 0, MINIMUM_VAULT_BOND).unwrap();
        vs.update_plucker_centrality(&fp, 0.3).unwrap();
        vs.update_harmonic_weight(&fp, 0.9).unwrap();

        let v = vs.get(&fp).unwrap();
        // Harmonic preferred over Plücker
        assert_eq!(v.selection_weight(), 0.9);
    }

    #[test]
    fn test_vrf_threshold() {
        let mut vs = ValidatorSet::new();
        let (fp0, pk0) = make_keypair(0);
        let (fp1, pk1) = make_keypair(1);

        vs.register(fp0, pk0, 0, MINIMUM_VAULT_BOND).unwrap();
        vs.register(fp1, pk1, 1, MINIMUM_VAULT_BOND).unwrap();

        vs.update_harmonic_weight(&fp0, 0.75).unwrap();
        vs.update_harmonic_weight(&fp1, 0.25).unwrap();

        let t0 = vs.vrf_threshold(&fp0);
        let t1 = vs.vrf_threshold(&fp1);

        // Higher weight → higher threshold → more slots
        assert!(t0 > t1);
        assert!((t0 + t1 - 1.0).abs() < 1e-10);
    }

    #[test]
    fn test_bond_eligibility() {
        let mut vs = ValidatorSet::new();
        let (fp_rich, pk_rich) = make_keypair(0);
        let (fp_poor, pk_poor) = make_keypair(1);

        vs.register(fp_rich, pk_rich, 0, MINIMUM_VAULT_BOND).unwrap();
        vs.register(fp_poor, pk_poor, 1, MINIMUM_VAULT_BOND - 1).unwrap();

        assert!(vs.is_bond_eligible(&fp_rich));
        assert!(!vs.is_bond_eligible(&fp_poor));
    }

    #[test]
    fn test_select_producer_weighted() {
        let mut vs = ValidatorSet::new();
        let (fp0, pk0) = make_keypair(0);
        let (fp1, pk1) = make_keypair(1);

        vs.register(fp0, pk0, 0, MINIMUM_VAULT_BOND).unwrap();
        vs.register(fp1, pk1, 1, MINIMUM_VAULT_BOND).unwrap();

        vs.update_harmonic_weight(&fp0, 0.9).unwrap();
        vs.update_harmonic_weight(&fp1, 0.1).unwrap();

        // Simulate 100 selections
        let mut count0 = 0;
        let mut count1 = 0;
        for i in 0..100 {
            let random = (i as f64) / 100.0;
            let selected = vs.select_producer(random).unwrap();
            if selected == fp0 { count0 += 1; }
            else { count1 += 1; }
        }

        // V0 should get ~90% of slots
        assert!(count0 > 80, "V0 got {} slots (expected ~90)", count0);
        assert!(count1 > 0, "V1 got {} slots (expected ~10)", count1);
    }

    #[test]
    fn test_trusted_pubkeys() {
        let mut vs = ValidatorSet::new();
        let (fp0, pk0) = make_keypair(0);
        let (fp1, pk1) = make_keypair(1);
        let (fp2, pk2) = make_keypair(2);

        vs.register(fp0, pk0, 0, MINIMUM_VAULT_BOND).unwrap();
        vs.register(fp1, pk1, 1, MINIMUM_VAULT_BOND).unwrap();
        vs.register(fp2, pk2, 2, MINIMUM_VAULT_BOND).unwrap();

        vs.deactivate(&fp1).unwrap();

        let pubkeys = vs.trusted_pubkeys();
        assert_eq!(pubkeys.len(), 2);
        assert!(pubkeys.contains(&pk0));
        assert!(!pubkeys.contains(&pk1)); // deactivated
        assert!(pubkeys.contains(&pk2));
    }

    #[test]
    fn test_invalid_weight_rejected() {
        let mut vs = ValidatorSet::new();
        let (fp, pk) = make_keypair(0);
        vs.register(fp, pk, 0, MINIMUM_VAULT_BOND).unwrap();

        assert!(vs.update_harmonic_weight(&fp, 1.5).is_err());
        assert!(vs.update_harmonic_weight(&fp, -0.1).is_err());
        assert!(vs.update_plucker_centrality(&fp, 2.0).is_err());
    }

    #[test]
    fn test_single_validator_always_produces() {
        let mut vs = ValidatorSet::new();
        let (fp, pk) = make_keypair(0);
        vs.register(fp, pk, 0, MINIMUM_VAULT_BOND).unwrap();

        // With one validator, threshold should be 1.0
        let threshold = vs.vrf_threshold(&fp);
        assert!((threshold - 1.0).abs() < 1e-10);

        // Any VRF score < 1.0 should select this validator
        let selected = vs.select_producer(0.999).unwrap();
        assert_eq!(selected, fp);
    }

    #[test]
    fn test_deactivated_not_selected() {
        let mut vs = ValidatorSet::new();
        let (fp0, pk0) = make_keypair(0);
        let (fp1, pk1) = make_keypair(1);

        vs.register(fp0, pk0, 0, MINIMUM_VAULT_BOND).unwrap();
        vs.register(fp1, pk1, 1, MINIMUM_VAULT_BOND).unwrap();

        vs.deactivate(&fp0).unwrap();

        // Only fp1 should be selected
        let selected = vs.select_producer(0.5).unwrap();
        assert_eq!(selected, fp1);
    }
}
