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
use anyhow::{Result, bail};
use tracing::{debug, info, warn};

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
    /// This node's worker pubkey
    worker_pubkey: [u8; 32],
    /// Trusted Oracle workers (for signatures)
    trusted_workers: Vec<[u8; 32]>,
}

impl PoVProducer {
    pub fn new(worker_pubkey: [u8; 32], trusted_workers: Vec<[u8; 32]>) -> Self {
        Self { worker_pubkey, trusted_workers }
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
        let fingerprint = SpectralFingerprint {
            spectral_gap: oracle_commitment.spectral_gap,
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
            spectral_gap: oracle_commitment.spectral_gap,
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

    /// Sign proof with worker keys
    fn sign_proof(&self, _fingerprint: &SpectralFingerprint) -> Vec<WorkerSignature> {
        // Our own signature
        let mut sigs = vec![WorkerSignature {
            worker_pubkey: self.worker_pubkey,
            signature: vec![0u8; 64], // TODO: real Ed25519
        }];

        // Other trusted workers
        for &worker in &self.trusted_workers {
            if worker != self.worker_pubkey {
                sigs.push(WorkerSignature {
                    worker_pubkey: worker,
                    signature: vec![0u8; 64],
                });
            }
        }

        sigs
    }
}

/// PoV Verifier — validates blocks
pub struct PoVVerifier {
    trusted_workers: Vec<[u8; 32]>,
}

impl PoVVerifier {
    pub fn new(trusted_workers: Vec<[u8; 32]>) -> Self {
        Self { trusted_workers }
    }

    /// Verify a block's spectral proof
    pub fn verify_block(&self, block: &Block) -> Result<()> {
        let proof = &block.header.spectral_proof;

        debug!("Verifying block at height {}", block.header.height);

        // 1. Version check
        if block.header.version != 1 {
            bail!("Unknown block version: {}", block.header.version);
        }

        // 2. Verify √2 bounds
        if !proof.fingerprint.verify_bounds() {
            bail!(
                "Spectral gap {:.4} outside √2 bounds [{:.4}, {:.4}]",
                proof.fingerprint.spectral_gap, POV_LOWER, POV_UPPER
            );
        }

        // 3. Verify computation trace hash chain
        if !self.verify_computation_trace(proof) {
            bail!("Invalid computation trace");
        }

        // 4. Verify worker consensus (2/3 required)
        if !self.verify_worker_consensus(proof) {
            bail!("Insufficient worker consensus");
        }

        // 5. Verify Merkle root
        let computed_root = block.compute_cochain_root();
        if computed_root != block.header.cochain_root {
            bail!("Merkle root mismatch");
        }

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

    fn verify_worker_consensus(&self, proof: &SpectralProof) -> bool {
        if proof.worker_signatures.len() < 3 {
            return false;
        }

        let threshold = (proof.worker_signatures.len() * 2) / 3;
        let valid_count = proof.worker_signatures.iter()
            .filter(|sig| self.trusted_workers.contains(&sig.worker_pubkey))
            .count();

        valid_count >= threshold
    }
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

    fn test_workers() -> (Vec<[u8; 32]>, [u8; 32]) {
        let workers: Vec<[u8; 32]> = (0..4).map(|i| [i as u8; 32]).collect();
        let my_key = workers[0];
        (workers, my_key)
    }

    #[test]
    fn test_produce_genesis() {
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers.clone());

        let commitment = test_oracle_commitment(1.5);
        let genesis = producer.produce_genesis(&commitment).unwrap();

        assert_eq!(genesis.header.height, 0);
        assert_eq!(genesis.header.parent_hash, BlockHash([0; 32]));
        assert_eq!(genesis.header.producer_fingerprint, [99u8; 32]);
        assert_eq!(genesis.header.topology_hash, [7u8; 32]);
        assert_eq!(genesis.header.spectral_proof.fingerprint.spectral_gap, 1.5);
    }

    #[test]
    fn test_produce_and_verify() {
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers.clone());
        let verifier = PoVVerifier::new(workers);

        // Genesis
        let commitment = test_oracle_commitment(1.5);
        let genesis = producer.produce_genesis(&commitment).unwrap();

        // Verify genesis
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
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers);

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
            spectral_gap: 1.5,
            betti_numbers: (1, 0, 0),
            hash: [0; 32],
        };
        assert!(fp.verify_bounds());

        let fp_invalid = SpectralFingerprint {
            spectral_gap: 5.0,
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
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers);
        assert!(producer.produce_genesis(&commitment).is_ok());
    }

    #[test]
    fn test_boundary_exact_upper() {
        // Exactly at 2√2 ≈ 2.82842712... → should be accepted
        let commitment = test_oracle_commitment(POV_UPPER);
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers);
        assert!(producer.produce_genesis(&commitment).is_ok());
    }

    #[test]
    fn test_boundary_just_below_lower() {
        // Just below 1/√2 → rejected
        let commitment = test_oracle_commitment(POV_LOWER - 1e-10);
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers);
        assert!(producer.produce_genesis(&commitment).is_err());
    }

    #[test]
    fn test_boundary_just_above_upper() {
        // Just above 2√2 → rejected
        let commitment = test_oracle_commitment(POV_UPPER + 1e-10);
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers);
        assert!(producer.produce_genesis(&commitment).is_err());
    }

    // ── Block validation pipeline ───────────────────────────────

    #[test]
    fn test_verify_rejects_tampered_cochain_root() {
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers.clone());
        let verifier = PoVVerifier::new(workers);

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
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers.clone());
        let verifier = PoVVerifier::new(workers);

        let commitment = test_oracle_commitment(1.5);
        let mut block = producer.produce_genesis(&commitment).unwrap();

        block.header.version = 99;

        let result = verifier.verify_block(&block);
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("version"));
    }

    #[test]
    fn test_verify_block_with_transactions() {
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers.clone());
        let verifier = PoVVerifier::new(workers);

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
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers.clone());
        let verifier = PoVVerifier::new(workers);

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
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers.clone());
        let verifier = PoVVerifier::new(workers);

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
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers.clone());
        let verifier = PoVVerifier::new(workers);

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
        let (workers, my_key) = test_workers();
        let producer = PoVProducer::new(my_key, workers);

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
        Transaction { data, key_image: None }
    }
}
