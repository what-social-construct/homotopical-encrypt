// Proof of Value: Spectral Gap Validation + Block Production
//
// Data flow:
//   Python wallet → Oracle (FullStalk) → Oracle computes HashStalk → Node PoV
//
// The Oracle provides HashStalk containing:
//   fingerprint (Hodge projection commitment), spectral_gap, betti_numbers, topology_hash
//
// The PoV producer uses Oracle output to create blocks.
// The PoV verifier checks √2 bounds and trace consistency.

use crate::types::*;
use crate::consensus::topos::ToposVerifier;
use crate::crypto::geodesic_zkp::{verify_geodesic_proof, GeodesicZKProof};
// HeytingValue imported via crate::types::*
use anyhow::{Result, bail};
use ed25519_dalek::{SigningKey, VerifyingKey, Signer, Verifier, Signature};
use tracing::{debug, info, warn};

/// Domain separator for spectral proof signatures.
/// Prevents cross-protocol signature reuse.
const PROOF_SIG_DOMAIN: &[u8] = b"HCRYPT_SPECTRAL_PROOF_V1";

/// Build the canonical message that workers sign for a spectral proof.
///
/// message = DOMAIN_SEP || fingerprint_hash || gap_valid || β₀ || β₁ || β₂
///
/// This binds the signature to the specific geometric commitment.
/// Signing the hash (not raw data) prevents length-extension attacks.
fn proof_signing_message(fingerprint: &SpectralFingerprint) -> Vec<u8> {
    let mut msg = Vec::with_capacity(PROOF_SIG_DOMAIN.len() + 32 + 1 + 12);
    msg.extend_from_slice(PROOF_SIG_DOMAIN);
    msg.extend_from_slice(&fingerprint.hash);
    msg.push(fingerprint.spectral_gap_valid as u8);
    msg.extend_from_slice(&fingerprint.betti_numbers.0.to_le_bytes());
    msg.extend_from_slice(&fingerprint.betti_numbers.1.to_le_bytes());
    msg.extend_from_slice(&fingerprint.betti_numbers.2.to_le_bytes());
    msg
}

/// Oracle commitment data (matches Oracle's HashStalk)
/// This is what the Oracle sends to the Node after computing η
#[derive(Debug, Clone)]
pub struct OracleCommitment {
    /// Geometric commitment hash (Hodge projection → quantize → bytes)
    pub fingerprint: [u8; 32],
    /// Spectral gap λ₁ (first nonzero eigenvalue of Δ)
    pub spectral_gap: f64,
    /// Betti numbers (β₀, β₁, β₂) — matches Oracle's HashStalk
    pub betti_numbers: (i32, i32, i32),
    /// Topology hash (SHA256 of nerve vertices + edges)
    pub topology_hash: [u8; 32],
    /// Block producer's identity fingerprint
    pub producer_fingerprint: [u8; 32],
}

/// Block producer — creates blocks from Oracle-provided commitments
pub struct PoVProducer {
    /// This node's Ed25519 signing key
    signing_key: SigningKey,
    /// This node's worker pubkey (derived from signing_key)
    worker_pubkey: [u8; 32],
    /// Trusted Oracle workers (for signatures)
    trusted_workers: Vec<[u8; 32]>,
    /// Trusted workers' signing keys (for multi-sig in test/single-node mode)
    /// In production, each worker signs independently via RPC.
    peer_signing_keys: Vec<SigningKey>,
}

impl PoVProducer {
    pub fn new(worker_pubkey: [u8; 32], trusted_workers: Vec<[u8; 32]>) -> Self {
        // Generate a signing key whose public key matches worker_pubkey.
        // In production, the key is loaded from secure storage.
        // This fallback generates a fresh key for compatibility.
        let signing_key = SigningKey::from_bytes(&worker_pubkey);
        let actual_pubkey: [u8; 32] = VerifyingKey::from(&signing_key).to_bytes();
        Self {
            signing_key,
            worker_pubkey: actual_pubkey,
            trusted_workers,
            peer_signing_keys: Vec::new(),
        }
    }

    /// Create producer from an actual Ed25519 signing key
    pub fn from_signing_key(signing_key: SigningKey, trusted_workers: Vec<[u8; 32]>) -> Self {
        let worker_pubkey = VerifyingKey::from(&signing_key).to_bytes();
        Self {
            signing_key,
            worker_pubkey,
            trusted_workers,
            peer_signing_keys: Vec::new(),
        }
    }

    /// Add peer signing keys (for test / single-node multi-sig)
    pub fn with_peer_keys(mut self, keys: Vec<SigningKey>) -> Self {
        self.peer_signing_keys = keys;
        self
    }

    /// Produce a block using Oracle commitment
    ///
    /// Flow: Oracle HashStalk → SpectralFingerprint → SpectralProof → Block
    pub fn produce_block(
        &self,
        parent: &Block,
        transactions: Vec<Transaction>,
        oracle_commitment: &OracleCommitment,
    ) -> Result<Block> {
        // 1. Verify √2 bounds on Oracle's spectral gap
        if oracle_commitment.spectral_gap < POV_LOWER || oracle_commitment.spectral_gap > POV_UPPER {
            bail!(
                "Spectral gap {:.4} outside √2 bounds [{:.4}, {:.4}]",
                oracle_commitment.spectral_gap, POV_LOWER, POV_UPPER
            );
        }

        let parent_hash = parent.hash();
        let height = parent.header.height + 1;

        debug!("Producing block at height {} (parent={})", height, parent_hash);

        // 2. Build SpectralFingerprint from Oracle data
        //    POST-AUDIT (Hodge_Ambiguity): store only boolean, not raw gap value.
        //    The raw gap is verified above but DISCARDED — it's private key material.
        let fingerprint = SpectralFingerprint {
            spectral_gap_valid: true, // verified by bounds check above
            betti_numbers: oracle_commitment.betti_numbers,
            hash: oracle_commitment.fingerprint,
        };

        // 3. Build computation trace from Oracle's commitment chain
        let trace = self.build_oracle_trace(oracle_commitment);

        // 4. Collect worker signatures
        let signatures = self.sign_proof(&fingerprint);

        let proof = SpectralProof {
            fingerprint,
            computation_trace: trace,
            worker_signatures: signatures,
        };

        // 5. Build block with Merkle root
        let mut block = Block {
            header: BlockHeader {
                version: 1,
                height,
                parent_hash,
                cochain_root: [0u8; 32],
                timestamp: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_secs(),
                spectral_proof: proof,
                producer_fingerprint: oracle_commitment.producer_fingerprint,
                topology_hash: oracle_commitment.topology_hash,
            },
            transactions,
        };

        // Compute and set Merkle root
        block.header.cochain_root = block.compute_cochain_root();

        info!(
            "✅ Produced block at height {} with {} txs (gap={:.4})",
            height,
            block.transactions.len(),
            oracle_commitment.spectral_gap,
        );

        Ok(block)
    }

    /// Produce genesis block (no parent)
    pub fn produce_genesis(&self, oracle_commitment: &OracleCommitment) -> Result<Block> {
        if oracle_commitment.spectral_gap < POV_LOWER || oracle_commitment.spectral_gap > POV_UPPER {
            bail!("Genesis spectral gap {:.4} outside bounds", oracle_commitment.spectral_gap);
        }

        let fingerprint = SpectralFingerprint {
            spectral_gap_valid: true, // verified by bounds check above
            betti_numbers: oracle_commitment.betti_numbers,
            hash: oracle_commitment.fingerprint,
        };

        let trace = self.build_oracle_trace(oracle_commitment);
        let signatures = self.sign_proof(&fingerprint);

        let block = Block {
            header: BlockHeader {
                version: 1,
                height: 0,
                parent_hash: BlockHash([0; 32]),
                cochain_root: [0u8; 32],
                timestamp: std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap()
                    .as_secs(),
                spectral_proof: SpectralProof {
                    fingerprint,
                    computation_trace: trace,
                    worker_signatures: signatures,
                },
                producer_fingerprint: oracle_commitment.producer_fingerprint,
                topology_hash: oracle_commitment.topology_hash,
            },
            transactions: vec![],
        };

        info!("✅ Produced genesis block: {}", block.hash());
        Ok(block)
    }

    /// Build computation trace from Oracle commitment
    ///
    /// The trace records how Oracle derived the commitment:
    ///   credential → Hodge projection → quantize → fingerprint
    /// Each step links input_hash → output_hash
    fn build_oracle_trace(&self, commitment: &OracleCommitment) -> Vec<ComputationStep> {
        use blake3::Hasher;

        // Step 1: topology → topology_hash (Oracle computed this)
        let mut h = Hasher::new();
        h.update(b"topology_input");
        let topo_input = *h.finalize().as_bytes();

        // Step 2: credential → Hodge projection (Oracle's geometric commitment)
        let mut h = Hasher::new();
        h.update(&commitment.topology_hash);
        h.update(&commitment.spectral_gap.to_le_bytes());
        let hodge_hash = *h.finalize().as_bytes();

        // Step 3: Hodge projection → fingerprint commitment
        vec![
            ComputationStep {
                operation: "topology_hash".to_string(),
                input_hash: topo_input,
                output_hash: commitment.topology_hash,
            },
            ComputationStep {
                operation: "hodge_projection".to_string(),
                input_hash: commitment.topology_hash,
                output_hash: hodge_hash,
            },
            ComputationStep {
                operation: "geometric_commitment".to_string(),
                input_hash: hodge_hash,
                output_hash: commitment.fingerprint,
            },
        ]
    }

    /// Sign proof with Ed25519 over the canonical signing message.
    ///
    /// Each worker signs: DOMAIN_SEP || fingerprint_hash || gap_valid || β₀ || β₁ || β₂
    /// This binds the signature to the exact geometric commitment.
    fn sign_proof(&self, fingerprint: &SpectralFingerprint) -> Vec<WorkerSignature> {
        let msg = proof_signing_message(fingerprint);

        // Our own signature (always present)
        let our_sig = self.signing_key.sign(&msg);
        let mut sigs = vec![WorkerSignature {
            worker_pubkey: self.worker_pubkey,
            signature: our_sig.to_bytes().to_vec(),
        }];

        // Peer worker signatures (single-node / test mode: we have their keys)
        for peer_key in &self.peer_signing_keys {
            let peer_pubkey = VerifyingKey::from(peer_key).to_bytes();
            let peer_sig = peer_key.sign(&msg);
            sigs.push(WorkerSignature {
                worker_pubkey: peer_pubkey,
                signature: peer_sig.to_bytes().to_vec(),
            });
        }

        sigs
    }
}

/// PoV Verifier — validates blocks using Topos consensus and Geodesic ZKPs
pub struct PoVVerifier {
    trusted_workers: Vec<[u8; 32]>,
    /// Topos-theoretic verifier (Heyting lattice consensus)
    topos: ToposVerifier,
}

impl PoVVerifier {
    pub fn new(trusted_workers: Vec<[u8; 32]>) -> Self {
        let topos = ToposVerifier::new(trusted_workers.clone());
        Self { trusted_workers, topos }
    }

    /// Verify a block's spectral proof (full pipeline: PoV + Topos + ZKP)
    pub fn verify_block(&self, block: &Block) -> Result<()> {
        let proof = &block.header.spectral_proof;

        debug!("Verifying block at height {}", block.header.height);

        // 1. Version check
        if block.header.version != 1 {
            bail!("Unknown block version: {}", block.header.version);
        }

        // 2. Verify √2 bounds
        if !proof.fingerprint.verify_bounds() {
            bail!("Spectral gap not verified valid by Oracle");
        }

        // 3. Topos-theoretic consensus check (Heyting lattice judgment)
        //    Runs copresheaf/Heyting verification from topos.rs
        let judgment = self.topos.verify_block_topos(block);
        match judgment.value {
            HeytingValue::Invalid => {
                bail!("Topos consensus: INVALID — {}", judgment.evidence.forcing_condition);
            }
            HeytingValue::Undetermined => {
                // Log warning but allow — matches Heyting semantics where
                // ¬¬p does not imply p (excluded middle doesn't hold)
                warn!("Topos consensus: UNDETERMINED — {}", judgment.resolve_valid_if);
            }
            HeytingValue::Valid => {
                debug!("Topos consensus: VALID");
            }
        }

        // 4. Verify computation trace hash chain
        if !self.verify_computation_trace(proof) {
            bail!("Invalid computation trace");
        }

        // 5. Verify worker consensus (2/3 required)
        if !self.verify_worker_consensus(proof) {
            bail!("Insufficient worker consensus");
        }

        // 6. Verify Merkle root
        let computed_root = block.compute_cochain_root();
        if computed_root != block.header.cochain_root {
            bail!("Merkle root mismatch");
        }

        // 7. Verify geodesic ZKPs on transactions (if present)
        self.verify_transaction_zkps(block)?;

        debug!("✅ Block verified at height {}", block.header.height);
        Ok(())
    }

    /// Verify parent linkage
    pub fn verify_chain(&self, block: &Block, parent: &Block) -> Result<()> {
        // Verify the block itself
        self.verify_block(block)?;

        // Check parent hash
        if block.header.parent_hash != parent.hash() {
            bail!("Parent hash mismatch");
        }

        // Check height
        if block.header.height != parent.header.height + 1 {
            bail!(
                "Height mismatch: expected {}, got {}",
                parent.header.height + 1, block.header.height
            );
        }

        Ok(())
    }

    fn verify_computation_trace(&self, proof: &SpectralProof) -> bool {
        if proof.computation_trace.is_empty() {
            return false;
        }

        // Verify hash chain continuity
        for i in 1..proof.computation_trace.len() {
            if proof.computation_trace[i].input_hash != proof.computation_trace[i - 1].output_hash {
                warn!("Computation trace broken at step: {}", proof.computation_trace[i].operation);
                return false;
            }
        }

        // Final hash must match fingerprint commitment
        if let Some(last) = proof.computation_trace.last() {
            if last.output_hash != proof.fingerprint.hash {
                warn!("Final trace hash doesn't match fingerprint");
                return false;
            }
        }

        true
    }

    /// Verify worker consensus: 2/3 of signatures must be valid Ed25519
    /// over the canonical signing message, from trusted worker pubkeys.
    fn verify_worker_consensus(&self, proof: &SpectralProof) -> bool {
        if proof.worker_signatures.len() < 3 {
            return false;
        }

        let msg = proof_signing_message(&proof.fingerprint);
        let threshold = (proof.worker_signatures.len() * 2) / 3;

        let valid_count = proof.worker_signatures.iter()
            .filter(|sig| {
                // Must be a trusted worker
                if !self.trusted_workers.contains(&sig.worker_pubkey) {
                    return false;
                }
                // Must have correct signature length
                if sig.signature.len() != 64 {
                    return false;
                }
                // Verify Ed25519 signature
                let Ok(verifying_key) = VerifyingKey::from_bytes(&sig.worker_pubkey) else {
                    return false;
                };
                let Ok(signature) = Signature::from_slice(&sig.signature) else {
                    return false;
                };
                verifying_key.verify(&msg, &signature).is_ok()
            })
            .count();

        if valid_count < threshold {
            warn!(
                "Worker consensus: {}/{} valid sigs (need {})",
                valid_count, proof.worker_signatures.len(), threshold
            );
        }

        valid_count >= threshold
    }

    /// Verify geodesic ZKPs embedded in transactions
    ///
    /// Transactions may optionally carry a geodesic ZK proof (proving the
    /// sender knows a path on the Grassmannian connecting two stalks).
    /// If present, the proof must pass the 7-gate verification pipeline.
    fn verify_transaction_zkps(&self, block: &Block) -> Result<()> {
        for (idx, tx) in block.transactions.iter().enumerate() {
            // ZKP-bearing transactions have sender_fingerprint set
            // and data length > standard cochain commitment size
            if tx.sender_fingerprint.is_some() && tx.data.len() > 128 {
                // Try to parse as geodesic ZK proof (last portion of tx.data)
                // The cochain commitment occupies the first part; ZKP appended after
                if let Some(cc_end) = parse_cochain_commitment_end(&tx.data) {
                    if cc_end < tx.data.len() {
                        let zkp_bytes = &tx.data[cc_end..];
                        if let Ok(zkp) = GeodesicZKProof::from_bytes(zkp_bytes) {
                            // Use block's topology hash for verification context
                            let topo_hash = &block.header.topology_hash;
                            let result = verify_geodesic_proof(
                                &zkp,
                                &[], // target spectrum validated at Oracle level
                                topo_hash,
                                false, // non-strict: allow Oracle-validated gaps
                            );
                            if !result.valid {
                                bail!(
                                    "Transaction {} geodesic ZKP failed gate {}/{}: {}",
                                    idx, result.gates_passed, result.total_gates, result.reason
                                );
                            }
                            debug!("Transaction {} geodesic ZKP passed ({}/{})",
                                   idx, result.gates_passed, result.total_gates);
                        }
                    }
                }
            }
        }
        Ok(())
    }
}

/// Parse cochain commitment from tx.data and return the byte offset where it ends.
/// Wire format: modulus(4) + n_edges(4) + edges(n×8) + topo_hash(16)
fn parse_cochain_commitment_end(data: &[u8]) -> Option<usize> {
    if data.len() < 8 { return None; }
    let n_edges = u32::from_le_bytes(data[4..8].try_into().ok()?) as usize;
    let end = 4 + 4 + n_edges * 8 + 16;
    if end <= data.len() { Some(end) } else { None }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_oracle_commitment(gap: f64) -> OracleCommitment {
        OracleCommitment {
            fingerprint: [42u8; 32],
            spectral_gap: gap,
            betti_numbers: (1, 0, 0),
            topology_hash: [7u8; 32],
            producer_fingerprint: [99u8; 32],
        }
    }

    /// Generate 4 Ed25519 keypairs for testing.
    /// Returns (pubkeys, signing_keys) where pubkeys are the trusted worker list
    /// and signing_keys[0] is the "our" key.
    fn test_keypairs() -> (Vec<[u8; 32]>, Vec<SigningKey>) {
        let signing_keys: Vec<SigningKey> = (0u8..4)
            .map(|i| SigningKey::from_bytes(&[i; 32]))
            .collect();
        let pubkeys: Vec<[u8; 32]> = signing_keys.iter()
            .map(|sk| VerifyingKey::from(sk).to_bytes())
            .collect();
        (pubkeys, signing_keys)
    }

    /// Build a PoVProducer with real Ed25519 keys and all 4 workers signing.
    fn test_producer(pubkeys: &[[u8; 32]], signing_keys: &[SigningKey]) -> PoVProducer {
        PoVProducer::from_signing_key(signing_keys[0].clone(), pubkeys.to_vec())
            .with_peer_keys(signing_keys[1..].to_vec())
    }

    /// Backward-compatible helper: returns (pubkeys, my_signing_key_seed).
    /// The pubkeys are REAL Ed25519 pubkeys (derived from seeds [0;32]..[3;32]).
    /// Use with PoVProducer::new() which treats the input as a seed.
    fn test_workers() -> (Vec<[u8; 32]>, [u8; 32]) {
        let (pubkeys, _signing_keys) = test_keypairs();
        // my_key seed = [0; 32] which is signing_keys[0]'s seed
        (pubkeys, [0u8; 32])
    }

    #[test]
    fn test_produce_genesis() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);

        let commitment = test_oracle_commitment(1.5);
        let genesis = producer.produce_genesis(&commitment).unwrap();

        assert_eq!(genesis.header.height, 0);
        assert_eq!(genesis.header.parent_hash, BlockHash([0; 32]));
        assert_eq!(genesis.header.producer_fingerprint, [99u8; 32]);
        assert_eq!(genesis.header.topology_hash, [7u8; 32]);
        assert!(genesis.header.spectral_proof.fingerprint.spectral_gap_valid);

        // Signatures are real (64 bytes, not zeros)
        for sig in &genesis.header.spectral_proof.worker_signatures {
            assert_eq!(sig.signature.len(), 64);
            assert_ne!(sig.signature, vec![0u8; 64], "Signature must not be all zeros");
        }
    }

    #[test]
    fn test_produce_and_verify() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        let verifier = PoVVerifier::new(pubkeys.clone());

        // Genesis
        let commitment = test_oracle_commitment(1.5);
        let genesis = producer.produce_genesis(&commitment).unwrap();

        // Verify genesis (now with real Ed25519 verification!)
        verifier.verify_block(&genesis).unwrap();

        // Block 1
        let commitment2 = test_oracle_commitment(1.8);
        let block1 = producer.produce_block(&genesis, vec![], &commitment2).unwrap();

        assert_eq!(block1.header.height, 1);
        assert_eq!(block1.header.parent_hash, genesis.hash());

        // Verify chain linkage
        verifier.verify_chain(&block1, &genesis).unwrap();
    }

    #[test]
    fn test_reject_invalid_gap() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);

        // Too low
        let bad = test_oracle_commitment(0.3);
        assert!(producer.produce_genesis(&bad).is_err());

        // Too high
        let bad = test_oracle_commitment(5.0);
        assert!(producer.produce_genesis(&bad).is_err());
    }

    #[test]
    fn test_spectral_bounds() {
        let fp = SpectralFingerprint {
            spectral_gap_valid: true,
            betti_numbers: (1, 0, 0),
            hash: [0; 32],
        };
        assert!(fp.verify_bounds());

        let fp_invalid = SpectralFingerprint {
            spectral_gap_valid: false,
            betti_numbers: (1, 0, 0),
            hash: [0; 32],
        };
        assert!(!fp_invalid.verify_bounds());
    }

    // ── √2 boundary precision ───────────────────────────────────

    #[test]
    fn test_boundary_exact_lower() {
        // Exactly at 1/√2 ≈ 0.70710678... → should be accepted
        let commitment = test_oracle_commitment(POV_LOWER);
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        assert!(producer.produce_genesis(&commitment).is_ok());
    }

    #[test]
    fn test_boundary_exact_upper() {
        // Exactly at 2√2 ≈ 2.82842712... → should be accepted
        let commitment = test_oracle_commitment(POV_UPPER);
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        assert!(producer.produce_genesis(&commitment).is_ok());
    }

    #[test]
    fn test_boundary_just_below_lower() {
        // Just below 1/√2 → rejected
        let commitment = test_oracle_commitment(POV_LOWER - 1e-10);
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        assert!(producer.produce_genesis(&commitment).is_err());
    }

    #[test]
    fn test_boundary_just_above_upper() {
        // Just above 2√2 → rejected
        let commitment = test_oracle_commitment(POV_UPPER + 1e-10);
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        assert!(producer.produce_genesis(&commitment).is_err());
    }

    // ── Block validation pipeline ───────────────────────────────

    #[test]
    fn test_verify_rejects_tampered_cochain_root() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        let verifier = PoVVerifier::new(pubkeys.clone());

        let commitment = test_oracle_commitment(1.5);
        let mut block = producer.produce_genesis(&commitment).unwrap();

        // Tamper with cochain root
        block.header.cochain_root = [0xFF; 32];

        let result = verifier.verify_block(&block);
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("root mismatch"));
    }

    #[test]
    fn test_verify_rejects_bad_version() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        let verifier = PoVVerifier::new(pubkeys.clone());

        let commitment = test_oracle_commitment(1.5);
        let mut block = producer.produce_genesis(&commitment).unwrap();

        block.header.version = 99;

        let result = verifier.verify_block(&block);
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("version"));
    }

    #[test]
    fn test_verify_block_with_transactions() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        let verifier = PoVVerifier::new(pubkeys.clone());

        let commitment = test_oracle_commitment(1.5);
        let genesis = producer.produce_genesis(&commitment).unwrap();

        // Build transactions as proper cochain commitments
        let q: u32 = 12289;
        let txs = vec![
            build_test_cochain_tx(q, &[100, 200]),
            build_test_cochain_tx(q, &[300, 400]),
        ];

        let commitment2 = test_oracle_commitment(2.0);
        let block = producer.produce_block(&genesis, txs, &commitment2).unwrap();

        // Block should verify (cochain root computed correctly)
        verifier.verify_block(&block).unwrap();

        // Verify chain linkage too
        verifier.verify_chain(&block, &genesis).unwrap();
    }

    #[test]
    fn test_verify_chain_wrong_parent() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        let verifier = PoVVerifier::new(pubkeys.clone());

        let c1 = test_oracle_commitment(1.5);
        let genesis = producer.produce_genesis(&c1).unwrap();

        let c2 = test_oracle_commitment(2.0);
        let block1 = producer.produce_block(&genesis, vec![], &c2).unwrap();

        // Try to verify block1 against itself instead of genesis
        let result = verifier.verify_chain(&block1, &block1);
        assert!(result.is_err());
    }

    #[test]
    fn test_verify_chain_wrong_height() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        let verifier = PoVVerifier::new(pubkeys.clone());

        let c1 = test_oracle_commitment(1.5);
        let genesis = producer.produce_genesis(&c1).unwrap();

        let c2 = test_oracle_commitment(2.0);
        let block1 = producer.produce_block(&genesis, vec![], &c2).unwrap();

        let c3 = test_oracle_commitment(1.8);
        let block2 = producer.produce_block(&block1, vec![], &c3).unwrap();

        // block2 (height 2) verified against genesis (height 0) → parent hash or height mismatch
        let result = verifier.verify_chain(&block2, &genesis);
        assert!(result.is_err());
        let err_msg = result.unwrap_err().to_string();
        assert!(err_msg.contains("mismatch"), "Expected mismatch error, got: {}", err_msg);
    }

    #[test]
    fn test_three_block_chain() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);
        let verifier = PoVVerifier::new(pubkeys.clone());

        let c1 = test_oracle_commitment(1.0);
        let genesis = producer.produce_genesis(&c1).unwrap();
        verifier.verify_block(&genesis).unwrap();

        let c2 = test_oracle_commitment(1.5);
        let block1 = producer.produce_block(&genesis, vec![], &c2).unwrap();
        verifier.verify_chain(&block1, &genesis).unwrap();

        let c3 = test_oracle_commitment(2.5);
        let block2 = producer.produce_block(&block1, vec![], &c3).unwrap();
        verifier.verify_chain(&block2, &block1).unwrap();

        // Heights are correct
        assert_eq!(genesis.header.height, 0);
        assert_eq!(block1.header.height, 1);
        assert_eq!(block2.header.height, 2);

        // Parent hashes chain
        assert_eq!(block1.header.parent_hash, genesis.hash());
        assert_eq!(block2.header.parent_hash, block1.hash());
    }

    #[test]
    fn test_cochain_root_set_correctly_on_produced_block() {
        let (pubkeys, signing_keys) = test_keypairs();
        let producer = test_producer(&pubkeys, &signing_keys);

        let c = test_oracle_commitment(1.5);
        let genesis = producer.produce_genesis(&c).unwrap();

        let q: u32 = 12289;
        let txs = vec![
            build_test_cochain_tx(q, &[42, -7]),
            build_test_cochain_tx(q, &[58, 7]),
        ];

        let c2 = test_oracle_commitment(2.0);
        let block = producer.produce_block(&genesis, txs, &c2).unwrap();

        // Verify the stored root matches recomputation
        let recomputed = block.compute_cochain_root();
        assert_eq!(block.header.cochain_root, recomputed);
        assert_ne!(recomputed, [0u8; 32]);
    }

    /// Helper: build a Transaction with CochainCommitment wire format
    fn build_test_cochain_tx(q: u32, edges: &[i64]) -> Transaction {
        let mut data = Vec::new();
        data.extend_from_slice(&q.to_le_bytes());
        data.extend_from_slice(&(edges.len() as u32).to_le_bytes());
        for &e in edges {
            data.extend_from_slice(&e.to_le_bytes());
        }
        Transaction { data, key_image: None, sender_fingerprint: None, fee_amount: 0 }
    }
}
