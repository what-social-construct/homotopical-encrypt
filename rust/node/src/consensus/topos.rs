// Topos Consensus — Heyting-Valued Block Verification
//
// Three-valued verification: VALID / INVALID / UNDETERMINED.
//
// Extends PoVVerifier with Heyting logic. Instead of hard accept/reject,
// blocks near the spectral gap boundary get UNDETERMINED and can be held
// in mempool for re-evaluation.
//
// Boolean PoV: gap ∈ bounds → accept, else → reject
// Topos PoV:   gap clearly in bounds → VALID
//              gap clearly out of bounds → INVALID
//              gap near boundary (±margin) → UNDETERMINED
//              insufficient worker sigs → UNDETERMINED
//              trace broken → INVALID
//
// Matches Python src/consensus/topos.py HeytingValue / ToposConsensus.
//
// Reference: Lambert (2021) "A Topos View of Blockchain Consensus Protocols"

use crate::types::*;
use tracing::{debug, warn};

/// Evidence supporting a topos judgment.
///
/// Matches Python ConsensusEvidence — collects the spectral, topological,
/// and structural data that determines the HeytingValue.
#[derive(Debug, Clone)]
pub struct ToposEvidence {
    /// Betti numbers from Oracle (β₀, β₁, β₂)
    pub betti_numbers: (i32, i32, i32),
    /// Whether the Oracle reported the gap as valid
    pub gap_oracle_valid: bool,
    /// Distance from nearest boundary (positive = inside bounds, negative = outside)
    pub gap_margin: f64,
    /// Whether gap is in the boundary zone (±BOUNDARY_MARGIN)
    pub in_boundary: bool,
    /// Number of worker signatures
    pub n_worker_sigs: usize,
    /// Number of trusted worker sigs
    pub n_trusted_sigs: usize,
    /// Computation trace valid
    pub trace_valid: bool,
    /// Cochain root matches
    pub cochain_root_valid: bool,
    /// Human-readable forcing condition
    pub forcing_condition: String,
    /// Confidence [0.0, 1.0]
    pub confidence: f64,
}

/// Complete topos judgment: HeytingValue + evidence + resolution hints.
///
/// Matches Python ToposJudgment.
#[derive(Debug, Clone)]
pub struct ToposJudgment {
    pub value: HeytingValue,
    pub evidence: ToposEvidence,
    /// What would resolve UNDETERMINED → VALID
    pub resolve_valid_if: String,
    /// What would resolve UNDETERMINED → INVALID
    pub resolve_invalid_if: String,
}

impl std::fmt::Display for ToposJudgment {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(
            f,
            "ToposJudgment({}, β₀={}, margin={:.4}, conf={:.3})",
            self.value,
            self.evidence.betti_numbers.0,
            self.evidence.gap_margin,
            self.evidence.confidence,
        )
    }
}

/// Topos Verifier — three-valued block verification.
///
/// Wraps the same checks as PoVVerifier but returns HeytingValue
/// instead of Result<()>. The boundary margin creates an UNDETERMINED
/// zone where blocks are neither accepted nor rejected.
///
/// Block handling by value:
///   VALID       → propagate immediately, add to chain
///   INVALID     → reject, penalize proposer
///   UNDETERMINED → hold in mempool, re-evaluate next epoch
pub struct ToposVerifier {
    trusted_workers: Vec<[u8; 32]>,
    boundary_margin: f64,
    min_worker_fraction: f64,
}

impl ToposVerifier {
    pub fn new(trusted_workers: Vec<[u8; 32]>) -> Self {
        Self {
            trusted_workers,
            boundary_margin: BOUNDARY_MARGIN,
            min_worker_fraction: 2.0 / 3.0,
        }
    }

    pub fn with_margin(mut self, margin: f64) -> Self {
        self.boundary_margin = margin;
        self
    }

    /// Verify a block with three-valued Heyting logic.
    ///
    /// Returns ToposJudgment instead of Result<()>.
    pub fn verify_block_topos(&self, block: &Block) -> ToposJudgment {
        let proof = &block.header.spectral_proof;
        let betti = proof.fingerprint.betti_numbers;

        // ─── Gate 0: Version check ─────────────────────────────────
        if block.header.version != 1 {
            return self.invalid(
                betti,
                format!("Unknown block version: {}", block.header.version),
            );
        }

        // ─── Gate 1: Computation trace ─────────────────────────────
        let trace_valid = self.verify_computation_trace(proof);
        if !trace_valid {
            return self.invalid(betti, "Computation trace broken".into());
        }

        // ─── Gate 2: Cochain root ──────────────────────────────────
        let computed_root = block.compute_cochain_root();
        let cochain_root_valid = computed_root == block.header.cochain_root;
        if !cochain_root_valid {
            return self.invalid(betti, "Cochain root mismatch".into());
        }

        // ─── Gate 3: Worker consensus ──────────────────────────────
        let n_sigs = proof.worker_signatures.len();
        let n_trusted = proof.worker_signatures.iter()
            .filter(|s| self.trusted_workers.contains(&s.worker_pubkey))
            .count();

        if n_sigs < 3 {
            return self.undetermined(
                betti, true, trace_valid, cochain_root_valid,
                n_sigs, n_trusted,
                "Too few worker signatures".into(),
                "≥3 workers sign the proof".into(),
                "Block expires without sufficient signatures".into(),
            );
        }

        let trusted_fraction = if n_sigs > 0 {
            n_trusted as f64 / n_sigs as f64
        } else {
            0.0
        };

        if trusted_fraction < self.min_worker_fraction {
            return self.undetermined(
                betti, proof.fingerprint.spectral_gap_valid, trace_valid,
                cochain_root_valid, n_sigs, n_trusted,
                format!(
                    "Insufficient trusted worker fraction: {}/{}={:.0}% < {:.0}%",
                    n_trusted, n_sigs, trusted_fraction * 100.0,
                    self.min_worker_fraction * 100.0,
                ),
                "More trusted workers confirm".into(),
                "Trusted fraction stays below threshold".into(),
            );
        }

        // ─── Gate 4: Spectral gap (THREE-VALUED) ──────────────────
        //
        // The Oracle reports gap_valid as boolean. But we also check
        // Betti numbers for boundary analysis:
        //   β₀ > 1 → partitioned (INVALID)
        //   β₁ > 1 → persistent cycles (soft UNDETERMINED)
        //
        // If Oracle says gap is valid, we trust it (VALID).
        // If Oracle says invalid, we check if it might be borderline.

        // Hard INVALID: partitioned topology
        if betti.0 > 1 {
            return self.invalid(
                betti,
                format!("β₀={} > 1 (partitioned network)", betti.0),
            );
        }

        // Oracle gap check
        if !proof.fingerprint.spectral_gap_valid {
            // Oracle said gap is bad — but is it borderline?
            // Without the raw gap value (POST-AUDIT: discarded for privacy),
            // we can't determine boundary proximity. Conservative: INVALID.
            //
            // FUTURE: Oracle could send a "boundary" flag alongside the boolean.
            return self.invalid(
                betti,
                "Oracle reported spectral gap out of √2 bounds".into(),
            );
        }

        // Persistent disagreement cycles (soft flag)
        if betti.1 > 1 {
            return self.undetermined(
                betti, true, trace_valid, cochain_root_valid,
                n_sigs, n_trusted,
                format!("β₁={} persistent disagreement cycles", betti.1),
                "Disagreement cycles resolve (β₁ decreases)".into(),
                "Cycles persist across multiple epochs".into(),
            );
        }

        // ─── ALL GATES PASSED: VALID ──────────────────────────────

        debug!("✅ Topos VALID at height {}", block.header.height);

        ToposJudgment {
            value: HeytingValue::Valid,
            evidence: ToposEvidence {
                betti_numbers: betti,
                gap_oracle_valid: true,
                gap_margin: 1.0, // Oracle confirmed — full margin
                in_boundary: false,
                n_worker_sigs: n_sigs,
                n_trusted_sigs: n_trusted,
                trace_valid: true,
                cochain_root_valid: true,
                forcing_condition: "All gates clear".into(),
                confidence: 1.0,
            },
            resolve_valid_if: String::new(),
            resolve_invalid_if: String::new(),
        }
    }

    /// Verify a block chain link with topos logic.
    pub fn verify_chain_topos(&self, block: &Block, parent: &Block) -> ToposJudgment {
        // First verify the block itself
        let judgment = self.verify_block_topos(block);
        if judgment.value == HeytingValue::Invalid {
            return judgment;
        }

        // Check parent hash
        if block.header.parent_hash != parent.hash() {
            return self.invalid(
                block.header.spectral_proof.fingerprint.betti_numbers,
                "Parent hash mismatch".into(),
            );
        }

        // Check height
        if block.header.height != parent.header.height + 1 {
            return self.invalid(
                block.header.spectral_proof.fingerprint.betti_numbers,
                format!(
                    "Height mismatch: expected {}, got {}",
                    parent.header.height + 1, block.header.height,
                ),
            );
        }

        judgment
    }

    /// Combine two judgments across epochs (meet = cautious).
    pub fn meet_judgments(&self, j1: &ToposJudgment, j2: &ToposJudgment) -> HeytingValue {
        j1.value.meet(j2.value)
    }

    /// Combine two judgments across epochs (join = optimistic).
    pub fn join_judgments(&self, j1: &ToposJudgment, j2: &ToposJudgment) -> HeytingValue {
        j1.value.join(j2.value)
    }

    // ─── Internal helpers ───────────────────────────────────────

    fn invalid(&self, betti: (i32, i32, i32), reason: String) -> ToposJudgment {
        warn!("❌ Topos INVALID: {}", reason);
        ToposJudgment {
            value: HeytingValue::Invalid,
            evidence: ToposEvidence {
                betti_numbers: betti,
                gap_oracle_valid: false,
                gap_margin: -1.0,
                in_boundary: false,
                n_worker_sigs: 0,
                n_trusted_sigs: 0,
                trace_valid: false,
                cochain_root_valid: false,
                forcing_condition: reason,
                confidence: 1.0,
            },
            resolve_valid_if: String::new(),
            resolve_invalid_if: String::new(),
        }
    }

    fn undetermined(
        &self,
        betti: (i32, i32, i32),
        gap_valid: bool,
        trace_valid: bool,
        cochain_valid: bool,
        n_sigs: usize,
        n_trusted: usize,
        reason: String,
        resolve_valid: String,
        resolve_invalid: String,
    ) -> ToposJudgment {
        debug!("⚠ Topos UNDETERMINED: {}", reason);
        ToposJudgment {
            value: HeytingValue::Undetermined,
            evidence: ToposEvidence {
                betti_numbers: betti,
                gap_oracle_valid: gap_valid,
                gap_margin: 0.0,
                in_boundary: true,
                n_worker_sigs: n_sigs,
                n_trusted_sigs: n_trusted,
                trace_valid,
                cochain_root_valid: cochain_valid,
                forcing_condition: reason,
                confidence: 0.5,
            },
            resolve_valid_if: resolve_valid,
            resolve_invalid_if: resolve_invalid,
        }
    }

    fn verify_computation_trace(&self, proof: &SpectralProof) -> bool {
        if proof.computation_trace.is_empty() {
            return false;
        }

        for i in 1..proof.computation_trace.len() {
            if proof.computation_trace[i].input_hash
                != proof.computation_trace[i - 1].output_hash
            {
                return false;
            }
        }

        if let Some(last) = proof.computation_trace.last() {
            if last.output_hash != proof.fingerprint.hash {
                return false;
            }
        }

        true
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::consensus::pov::{PoVProducer, OracleCommitment};
    use ed25519_dalek::{SigningKey, VerifyingKey};

    fn test_oracle(gap: f64) -> OracleCommitment {
        OracleCommitment {
            fingerprint: [42u8; 32],
            spectral_gap: gap,
            betti_numbers: (1, 0, 0),
            topology_hash: [7u8; 32],
            producer_fingerprint: [99u8; 32],
        }
    }

    fn test_keypairs() -> (Vec<[u8; 32]>, Vec<SigningKey>) {
        let signing_keys: Vec<SigningKey> = (0u8..4)
            .map(|i| SigningKey::from_bytes(&[i; 32]))
            .collect();
        let pubkeys: Vec<[u8; 32]> = signing_keys.iter()
            .map(|sk| VerifyingKey::from(sk).to_bytes())
            .collect();
        (pubkeys, signing_keys)
    }

    fn make_genesis(gap: f64) -> (Block, Vec<[u8; 32]>) {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = PoVProducer::from_signing_key(
            signing_keys[0].clone(), pubkeys.clone()
        ).with_peer_keys(signing_keys[1..].to_vec());
        let commitment = test_oracle(gap);
        let genesis = producer.produce_genesis(&commitment).unwrap();
        (genesis, pubkeys)
    }

    // ─── Heyting algebra unit tests ─────────────────────────────

    #[test]
    fn test_heyting_negation() {
        use HeytingValue::*;
        assert_eq!(Valid.negate(), Invalid);
        assert_eq!(Invalid.negate(), Valid);
        assert_eq!(Undetermined.negate(), Undetermined); // NOT Boolean!
    }

    #[test]
    fn test_heyting_double_negation() {
        use HeytingValue::*;
        // ¬Valid = Invalid, ¬Invalid = Valid → ¬¬Valid = ¬Invalid = Valid ✓
        assert_eq!(Valid.double_negate(), Valid);
        // ¬Invalid = Valid, ¬Valid = Invalid → ¬¬Invalid = Invalid ✓
        assert_eq!(Invalid.double_negate(), Invalid);
        // ¬Undetermined = Undetermined → ¬¬Undetermined = Undetermined ✓
        // This is the KEY non-Boolean property: double negation doesn't collapse
        assert_eq!(Undetermined.double_negate(), Undetermined);
    }

    #[test]
    fn test_heyting_meet() {
        use HeytingValue::*;
        assert_eq!(Valid.meet(Valid), Valid);
        assert_eq!(Valid.meet(Undetermined), Undetermined);
        assert_eq!(Valid.meet(Invalid), Invalid);
        assert_eq!(Undetermined.meet(Undetermined), Undetermined);
        assert_eq!(Undetermined.meet(Invalid), Invalid);
    }

    #[test]
    fn test_heyting_join() {
        use HeytingValue::*;
        assert_eq!(Invalid.join(Invalid), Invalid);
        assert_eq!(Invalid.join(Undetermined), Undetermined);
        assert_eq!(Invalid.join(Valid), Valid);
        assert_eq!(Undetermined.join(Undetermined), Undetermined);
        assert_eq!(Undetermined.join(Valid), Valid);
    }

    #[test]
    fn test_heyting_implies() {
        use HeytingValue::*;
        // U → I = U (NOT I — this is the key non-Boolean feature)
        assert_eq!(Undetermined.implies(Invalid), Undetermined);
        // V → U = U
        assert_eq!(Valid.implies(Undetermined), Undetermined);
        // I → V = V
        assert_eq!(Invalid.implies(Valid), Valid);
        // I → I = V
        assert_eq!(Invalid.implies(Invalid), Valid);
    }

    #[test]
    fn test_heyting_is_decided() {
        assert!(HeytingValue::Valid.is_decided());
        assert!(HeytingValue::Invalid.is_decided());
        assert!(!HeytingValue::Undetermined.is_decided());
    }

    // ─── Topos verifier tests ───────────────────────────────────

    #[test]
    fn test_topos_valid_block() {
        let (genesis, workers) = make_genesis(1.5);
        let verifier = ToposVerifier::new(workers);

        let j = verifier.verify_block_topos(&genesis);
        assert_eq!(j.value, HeytingValue::Valid);
        assert!(j.evidence.confidence > 0.9);
    }

    #[test]
    fn test_topos_invalid_version() {
        let (mut genesis, workers) = make_genesis(1.5);
        genesis.header.version = 99;
        let verifier = ToposVerifier::new(workers);

        let j = verifier.verify_block_topos(&genesis);
        assert_eq!(j.value, HeytingValue::Invalid);
        assert!(j.evidence.forcing_condition.contains("version"));
    }

    #[test]
    fn test_topos_invalid_cochain_root() {
        let (mut genesis, workers) = make_genesis(1.5);
        genesis.header.cochain_root = [0xFF; 32];
        let verifier = ToposVerifier::new(workers);

        let j = verifier.verify_block_topos(&genesis);
        assert_eq!(j.value, HeytingValue::Invalid);
        assert!(j.evidence.forcing_condition.contains("Cochain root"));
    }

    #[test]
    fn test_topos_invalid_gap() {
        let (mut genesis, workers) = make_genesis(1.5);
        // Simulate Oracle saying gap is bad
        genesis.header.spectral_proof.fingerprint.spectral_gap_valid = false;
        let verifier = ToposVerifier::new(workers);

        let j = verifier.verify_block_topos(&genesis);
        assert_eq!(j.value, HeytingValue::Invalid);
        assert!(j.evidence.forcing_condition.contains("spectral gap"));
    }

    #[test]
    fn test_topos_undetermined_few_sigs() {
        let (mut genesis, workers) = make_genesis(1.5);
        // Remove worker signatures to trigger UNDETERMINED
        genesis.header.spectral_proof.worker_signatures = vec![
            WorkerSignature { worker_pubkey: [0; 32], signature: vec![0; 64] },
        ];
        let verifier = ToposVerifier::new(workers);

        let j = verifier.verify_block_topos(&genesis);
        assert_eq!(j.value, HeytingValue::Undetermined);
        assert!(j.resolve_valid_if.contains("workers"));
    }

    #[test]
    fn test_topos_undetermined_persistent_cycles() {
        let (mut genesis, workers) = make_genesis(1.5);
        // β₁ > 1 → persistent disagreement cycles
        genesis.header.spectral_proof.fingerprint.betti_numbers = (1, 3, 0);
        let verifier = ToposVerifier::new(workers);

        let j = verifier.verify_block_topos(&genesis);
        assert_eq!(j.value, HeytingValue::Undetermined);
        assert!(j.evidence.forcing_condition.contains("cycles"));
    }

    #[test]
    fn test_topos_invalid_partitioned() {
        let (mut genesis, workers) = make_genesis(1.5);
        // β₀ > 1 → partitioned network
        genesis.header.spectral_proof.fingerprint.betti_numbers = (3, 0, 0);
        let verifier = ToposVerifier::new(workers);

        let j = verifier.verify_block_topos(&genesis);
        assert_eq!(j.value, HeytingValue::Invalid);
        assert!(j.evidence.forcing_condition.contains("partitioned"));
    }

    #[test]
    fn test_topos_chain_valid() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = PoVProducer::from_signing_key(
            signing_keys[0].clone(), pubkeys.clone()
        ).with_peer_keys(signing_keys[1..].to_vec());
        let verifier = ToposVerifier::new(pubkeys);

        let c1 = test_oracle(1.5);
        let genesis = producer.produce_genesis(&c1).unwrap();

        let c2 = test_oracle(2.0);
        let block1 = producer.produce_block(&genesis, vec![], &c2).unwrap();

        let j = verifier.verify_chain_topos(&block1, &genesis);
        assert_eq!(j.value, HeytingValue::Valid);
    }

    #[test]
    fn test_topos_chain_wrong_parent() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = PoVProducer::from_signing_key(
            signing_keys[0].clone(), pubkeys.clone()
        ).with_peer_keys(signing_keys[1..].to_vec());
        let verifier = ToposVerifier::new(pubkeys);

        let c1 = test_oracle(1.5);
        let genesis = producer.produce_genesis(&c1).unwrap();

        let c2 = test_oracle(2.0);
        let block1 = producer.produce_block(&genesis, vec![], &c2).unwrap();

        // Verify against self (wrong parent)
        let j = verifier.verify_chain_topos(&block1, &block1);
        assert_eq!(j.value, HeytingValue::Invalid);
    }

    #[test]
    fn test_topos_meet_judgments() {
        let (genesis, workers) = make_genesis(1.5);
        let verifier = ToposVerifier::new(workers);

        let j_valid = verifier.verify_block_topos(&genesis);
        assert_eq!(j_valid.value, HeytingValue::Valid);

        // Meet of VALID ∧ VALID = VALID
        assert_eq!(verifier.meet_judgments(&j_valid, &j_valid), HeytingValue::Valid);
    }

    #[test]
    fn test_topos_display() {
        let (genesis, workers) = make_genesis(1.5);
        let verifier = ToposVerifier::new(workers);

        let j = verifier.verify_block_topos(&genesis);
        let display = format!("{}", j);
        assert!(display.contains("VALID"));
        assert!(display.contains("β₀=1"));
    }
}
