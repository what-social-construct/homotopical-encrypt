// VRF Slot Assignment — Fork Prevention for PoV Consensus
//
// Port of Python src/consensus/vrf_slots.py
//
// Each epoch has exactly ONE valid block producer, determined by:
//     VRF(prev_block_hash, epoch) → (output, proof)
//
// The VRF uses the producer's secret fibration (eigenvectors) as key.
// This binds slot eligibility to the geometric identity — you can't
// grind for slots without a new fibration (which changes your fingerprint).
//
// CONSTRUCTION (hash-based VRF for sheaf setting):
//   VRF key = SHA256(eigenvectors || "VRF_KEY_V1")
//   VRF_eval(key, prev_hash, epoch):
//     output = HMAC-SHA256(key, prev_hash || epoch)
//     proof  = SHA256(key || output || epoch || "VRF_PROOF_V1")
//
// Reference: Gilad et al. (2017) "Algorand", Micali (2001) "VRF"

use anyhow::{Result, bail};
use hmac::{Hmac, Mac};
use sha2::{Sha256, Digest};
use std::collections::HashMap;

type HmacSha256 = Hmac<Sha256>;

// ─── Constants (match Python vrf_slots.py) ──────────────────────────

const VRF_KEY_DOMAIN: &[u8] = b"VRF_KEY_V1";
const VRF_COMMITMENT_DOMAIN: &[u8] = b"VRF_COMMITMENT_V1";
const VRF_PROOF_DOMAIN: &[u8] = b"VRF_PROOF_V1";

// ─── VRF Key ────────────────────────────────────────────────────────

/// VRF key derived from secret fibration eigenvectors.
///
/// key_bytes = SHA256(eigenvectors || "VRF_KEY_V1")
/// Deterministic from fibration, changes on rotation,
/// NOT linkable to spectral fingerprint (one-way hash).
#[derive(Debug, Clone)]
pub struct VRFKey {
    pub key_bytes: [u8; 32],
    pub identity_hash: [u8; 32],
    pub key_commitment: [u8; 32],
}

impl VRFKey {
    /// Create VRF key from raw eigenvector bytes and identity hash.
    pub fn from_eigenvector_bytes(eigenvector_bytes: &[u8], identity_hash: [u8; 32]) -> Self {
        let mut hasher = Sha256::new();
        hasher.update(eigenvector_bytes);
        hasher.update(VRF_KEY_DOMAIN);
        let key_bytes: [u8; 32] = hasher.finalize().into();

        let mut hasher2 = Sha256::new();
        hasher2.update(&key_bytes);
        hasher2.update(VRF_COMMITMENT_DOMAIN);
        let key_commitment: [u8; 32] = hasher2.finalize().into();

        VRFKey { key_bytes, identity_hash, key_commitment }
    }

    /// Create from Oracle commitment fingerprint (bootstraps from the fingerprint
    /// bytes as a proxy for eigenvectors — in production, would use actual eigenvectors
    /// from the credential).
    pub fn from_fingerprint(fingerprint: [u8; 32]) -> Self {
        Self::from_eigenvector_bytes(&fingerprint, fingerprint)
    }
}

// ─── VRF Output ─────────────────────────────────────────────────────

/// VRF evaluation result: (output, proof) pair.
#[derive(Debug, Clone)]
pub struct VRFOutput {
    pub output: [u8; 32],
    pub proof: [u8; 32],
    pub epoch: u64,
    pub key_commitment: [u8; 32],
    pub identity_hash: [u8; 32],
}

impl VRFOutput {
    /// Normalized VRF score ∈ [0, 1).
    pub fn score(&self) -> f64 {
        let bytes: [u8; 8] = self.output[..8].try_into().unwrap();
        u64::from_le_bytes(bytes) as f64 / (u64::MAX as f64 + 1.0)
    }

    /// Serialize for block header (136 bytes, matches Python).
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut out = Vec::with_capacity(136);
        out.extend_from_slice(&self.output);
        out.extend_from_slice(&self.proof);
        out.extend_from_slice(&self.epoch.to_le_bytes());
        out.extend_from_slice(&self.key_commitment);
        out.extend_from_slice(&self.identity_hash);
        out
    }

    /// Deserialize from block header.
    pub fn from_bytes(data: &[u8]) -> Result<Self> {
        if data.len() < 136 {
            bail!("VRF data too short: {} < 136", data.len());
        }
        let mut output = [0u8; 32];
        output.copy_from_slice(&data[0..32]);
        let mut proof = [0u8; 32];
        proof.copy_from_slice(&data[32..64]);
        let epoch = u64::from_le_bytes(data[64..72].try_into()?);
        let mut key_commitment = [0u8; 32];
        key_commitment.copy_from_slice(&data[72..104]);
        let mut identity_hash = [0u8; 32];
        identity_hash.copy_from_slice(&data[104..136]);

        Ok(VRFOutput { output, proof, epoch, key_commitment, identity_hash })
    }
}

// ─── VRF Evaluation ─────────────────────────────────────────────────

/// Evaluate VRF for a given epoch.
///
/// output = HMAC-SHA256(vrf_key, prev_block_hash || epoch)
/// proof  = SHA256(vrf_key || output || epoch || "VRF_PROOF_V1")
pub fn vrf_evaluate(key: &VRFKey, prev_block_hash: &[u8; 32], epoch: u64) -> VRFOutput {
    // VRF input = prev_block_hash || epoch
    let mut input = Vec::with_capacity(40);
    input.extend_from_slice(prev_block_hash);
    input.extend_from_slice(&epoch.to_le_bytes());

    // output = HMAC-SHA256(key, input)
    let mut mac = HmacSha256::new_from_slice(&key.key_bytes)
        .expect("HMAC key length is always valid");
    mac.update(&input);
    let output: [u8; 32] = mac.finalize().into_bytes().into();

    // proof = SHA256(key || output || epoch || "VRF_PROOF_V1")
    let mut hasher = Sha256::new();
    hasher.update(&key.key_bytes);
    hasher.update(&output);
    hasher.update(&epoch.to_le_bytes());
    hasher.update(VRF_PROOF_DOMAIN);
    let proof: [u8; 32] = hasher.finalize().into();

    VRFOutput {
        output,
        proof,
        epoch,
        key_commitment: key.key_commitment,
        identity_hash: key.identity_hash,
    }
}

/// Check if VRF output makes this validator eligible for the slot.
pub fn vrf_check_eligibility(
    vrf_output: &VRFOutput,
    centrality: f64,
    n_validators: usize,
) -> (bool, f64) {
    let threshold = (centrality * n_validators.max(1) as f64).min(1.0);
    let score = vrf_output.score();
    (score < threshold, threshold)
}

// ─── Slot Assignment ────────────────────────────────────────────────

/// Slot assignment for an epoch.
#[derive(Debug, Clone)]
pub struct SlotAssignment {
    pub epoch: u64,
    pub prev_block_hash: [u8; 32],
    pub selected_identity: [u8; 32],
    pub vrf_output: VRFOutput,
    pub centrality: f64,
    pub eligible_count: usize,
}

/// Assign slot for an epoch: evaluate VRF for all validators,
/// select the eligible validator with lowest score.
///
/// Deterministic: same inputs → same assignment on every node.
pub fn assign_slot(
    epoch: u64,
    prev_block_hash: &[u8; 32],
    vrf_keys: &HashMap<[u8; 32], VRFKey>,
    centralities: &HashMap<[u8; 32], f64>,
) -> Option<SlotAssignment> {
    if vrf_keys.is_empty() {
        return None;
    }

    let n_validators = vrf_keys.len();
    let mut best_score = f64::INFINITY;
    let mut best_output: Option<VRFOutput> = None;
    let mut best_identity: Option<[u8; 32]> = None;
    let mut eligible_count = 0usize;

    for (identity, key) in vrf_keys.iter() {
        let centrality = centralities.get(identity).copied().unwrap_or(0.0);
        if centrality <= 0.0 {
            continue;
        }

        let vrf_out = vrf_evaluate(key, prev_block_hash, epoch);
        let (eligible, _threshold) = vrf_check_eligibility(&vrf_out, centrality, n_validators);

        if eligible {
            eligible_count += 1;
            let score = vrf_out.score();
            if score < best_score {
                best_score = score;
                best_output = Some(vrf_out);
                best_identity = Some(*identity);
            }
        }
    }

    // Fallback: if no one eligible, pick lowest score (liveness)
    if best_identity.is_none() {
        for (identity, key) in vrf_keys.iter() {
            let vrf_out = vrf_evaluate(key, prev_block_hash, epoch);
            let score = vrf_out.score();
            if score < best_score {
                best_score = score;
                best_output = Some(vrf_out);
                best_identity = Some(*identity);
            }
        }
        eligible_count = 1;
    }

    let identity = best_identity?;
    let vrf_out = best_output?;

    Some(SlotAssignment {
        epoch,
        prev_block_hash: *prev_block_hash,
        selected_identity: identity,
        vrf_output: vrf_out,
        centrality: centralities.get(&identity).copied().unwrap_or(0.0),
        eligible_count,
    })
}

// ─── Slot Verification ──────────────────────────────────────────────

/// Verify that a block's VRF slot assignment is structurally valid.
pub fn verify_slot_assignment(
    block_height: u64,
    block_producer_identity: &[u8; 32],
    vrf_data: &[u8],
    registered_identities: &[&[u8; 32]],
) -> Result<()> {
    let vrf_output = VRFOutput::from_bytes(vrf_data)?;

    if vrf_output.epoch != block_height {
        bail!("VRF epoch {} != block height {}", vrf_output.epoch, block_height);
    }

    if &vrf_output.identity_hash != block_producer_identity {
        bail!("VRF identity mismatch");
    }

    if !registered_identities.contains(&block_producer_identity) {
        bail!("Producer not in registered validator set");
    }

    if vrf_output.output == [0u8; 32] {
        bail!("VRF output is all zeros");
    }

    if vrf_output.proof == [0u8; 32] {
        bail!("VRF proof is all zeros");
    }

    Ok(())
}

// ─── Equivocation Detection ─────────────────────────────────────────

/// Evidence that a validator produced two blocks at the same height.
#[derive(Debug, Clone)]
pub struct EquivocationEvidence {
    pub identity_hash: [u8; 32],
    pub epoch: u64,
    pub block_hash_1: [u8; 32],
    pub block_hash_2: [u8; 32],
    pub vrf_data_1: Vec<u8>,
    pub vrf_data_2: Vec<u8>,
}

/// Tracks blocks per (identity, epoch) to detect equivocation.
pub struct EquivocationTracker {
    seen: HashMap<([u8; 32], u64), ([u8; 32], Vec<u8>)>,
    evidence: Vec<EquivocationEvidence>,
}

impl EquivocationTracker {
    pub fn new() -> Self {
        EquivocationTracker {
            seen: HashMap::new(),
            evidence: Vec::new(),
        }
    }

    /// Record a block. Returns Some(evidence) if equivocation detected.
    pub fn record_block(
        &mut self,
        identity_hash: [u8; 32],
        epoch: u64,
        block_hash: [u8; 32],
        vrf_data: Vec<u8>,
    ) -> Option<EquivocationEvidence> {
        let key = (identity_hash, epoch);

        if let Some((prev_hash, prev_vrf)) = self.seen.get(&key) {
            if *prev_hash != block_hash {
                let evidence = EquivocationEvidence {
                    identity_hash,
                    epoch,
                    block_hash_1: *prev_hash,
                    block_hash_2: block_hash,
                    vrf_data_1: prev_vrf.clone(),
                    vrf_data_2: vrf_data,
                };
                self.evidence.push(evidence.clone());
                return Some(evidence);
            }
            return None; // Same block (duplicate gossip)
        }

        self.seen.insert(key, (block_hash, vrf_data));
        None
    }

    pub fn has_equivocated(&self, identity_hash: &[u8; 32]) -> bool {
        self.evidence.iter().any(|e| &e.identity_hash == identity_hash)
    }
}

// ─── Tests ──────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    fn test_key(id: u8) -> VRFKey {
        let eigvec_bytes = [id; 32];
        let identity = {
            let mut h = Sha256::new();
            h.update(&[id]);
            let r: [u8; 32] = h.finalize().into();
            r
        };
        VRFKey::from_eigenvector_bytes(&eigvec_bytes, identity)
    }

    #[test]
    fn test_vrf_deterministic() {
        let key = test_key(1);
        let prev = [0u8; 32];
        let out1 = vrf_evaluate(&key, &prev, 42);
        let out2 = vrf_evaluate(&key, &prev, 42);
        assert_eq!(out1.output, out2.output);
        assert_eq!(out1.proof, out2.proof);
        assert_eq!(out1.score(), out2.score());
    }

    #[test]
    fn test_vrf_different_epochs() {
        let key = test_key(1);
        let prev = [0u8; 32];
        let out1 = vrf_evaluate(&key, &prev, 0);
        let out2 = vrf_evaluate(&key, &prev, 1);
        assert_ne!(out1.output, out2.output);
    }

    #[test]
    fn test_vrf_score_range() {
        let key = test_key(1);
        let prev = [0u8; 32];
        for epoch in 0..100 {
            let out = vrf_evaluate(&key, &prev, epoch);
            let s = out.score();
            assert!(s >= 0.0 && s < 1.0, "Score {} out of range at epoch {}", s, epoch);
        }
    }

    #[test]
    fn test_vrf_serialization_roundtrip() {
        let key = test_key(1);
        let prev = [0u8; 32];
        let out = vrf_evaluate(&key, &prev, 7);
        let bytes = out.to_bytes();
        assert_eq!(bytes.len(), 136);
        let restored = VRFOutput::from_bytes(&bytes).unwrap();
        assert_eq!(restored.output, out.output);
        assert_eq!(restored.proof, out.proof);
        assert_eq!(restored.epoch, out.epoch);
    }

    #[test]
    fn test_slot_assignment() {
        let mut vrf_keys = HashMap::new();
        let mut centralities = HashMap::new();

        for i in 0u8..5 {
            let key = test_key(i);
            let id = key.identity_hash;
            centralities.insert(id, [0.1, 0.2, 0.4, 0.2, 0.1][i as usize]);
            vrf_keys.insert(id, key);
        }

        let prev = [0u8; 32];
        let slot = assign_slot(0, &prev, &vrf_keys, &centralities);
        assert!(slot.is_some());
        let s = slot.unwrap();
        assert!(centralities.contains_key(&s.selected_identity));
        assert!(s.eligible_count > 0);
    }

    #[test]
    fn test_slot_deterministic() {
        let mut vrf_keys = HashMap::new();
        let mut centralities = HashMap::new();

        for i in 0u8..3 {
            let key = test_key(i);
            let id = key.identity_hash;
            centralities.insert(id, 1.0 / 3.0);
            vrf_keys.insert(id, key);
        }

        let prev = [0u8; 32];
        let s1 = assign_slot(5, &prev, &vrf_keys, &centralities).unwrap();
        let s2 = assign_slot(5, &prev, &vrf_keys, &centralities).unwrap();
        assert_eq!(s1.selected_identity, s2.selected_identity);
    }

    #[test]
    fn test_equivocation_detection() {
        let mut tracker = EquivocationTracker::new();
        let id = [1u8; 32];

        // First block — no equivocation
        let ev1 = tracker.record_block(id, 0, [0xAA; 32], vec![0; 136]);
        assert!(ev1.is_none());

        // Second different block at same epoch — equivocation!
        let ev2 = tracker.record_block(id, 0, [0xBB; 32], vec![1; 136]);
        assert!(ev2.is_some());
        assert!(tracker.has_equivocated(&id));
    }

    #[test]
    fn test_equivocation_same_block_ok() {
        let mut tracker = EquivocationTracker::new();
        let id = [1u8; 32];
        let hash = [0xAA; 32];

        tracker.record_block(id, 0, hash, vec![0; 136]);
        let ev = tracker.record_block(id, 0, hash, vec![0; 136]);
        assert!(ev.is_none()); // Same block = not equivocation
    }

    #[test]
    fn test_verify_slot_assignment() {
        let key = test_key(1);
        let prev = [0u8; 32];
        let out = vrf_evaluate(&key, &prev, 0);
        let bytes = out.to_bytes();
        let id = key.identity_hash;

        let result = verify_slot_assignment(0, &id, &bytes, &[&id]);
        assert!(result.is_ok());

        // Wrong height
        let result2 = verify_slot_assignment(1, &id, &bytes, &[&id]);
        assert!(result2.is_err());

        // Unregistered identity
        let fake_id = [0xFF; 32];
        let result3 = verify_slot_assignment(0, &fake_id, &bytes, &[&id]);
        assert!(result3.is_err());
    }
}
