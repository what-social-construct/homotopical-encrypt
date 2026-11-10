// Core types for Homotopical-Encrypt chain
//
// Commitment model (from commitment.py):
//   Commit(m) = δ(m || r) where δ is coboundary C⁰ → C¹
//   Homomorphic: δ(m₁||r₁) + δ(m₂||r₂) = δ((m₁+m₂)||(r₁+r₂))
//   Binding: collision requires finding ker(δ) elements (SVP-hard)
//
// Cochain tree root (from ARCHITECTURE.md):
//   Block.cochain_root = SHA256("HCRYPT_COCHAIN_ROOT" + Σᵢ edge_values(txᵢ) mod q)
//   NOT a standard Merkle tree — uses linearity of δ for homomorphic accumulation
//
// Block hash:  SHA256("HCRYPT_BLOCK_V1" + header fields)
// Tx hash:     SHA256("HCRYPT_HTX_V2" + cochain_data + key_image)
//
// Wire format for cochain commitment (matching Python CochainCommitment.to_bytes()):
//   modulus(4 LE) + n_edges(4 LE) + edge_values(n × 8 as i64 LE) + topology_hash(16)
//
// √2 bounds: 1/√2 ≤ spectral_gap ≤ 2√2 (Tsirelson / Bell)

use serde::{Deserialize, Serialize};
use sha2::{Sha256, Digest};
use std::fmt;
use thiserror::Error;

// √2 bounds (Tsirelson / Bell)
pub const SQRT2: f64 = 1.41421356237;
pub const POV_LOWER: f64 = 1.0 / SQRT2;   // ~0.707
pub const POV_UPPER: f64 = 2.0 * SQRT2;   // ~2.828

/// Boundary margin for UNDETERMINED zone (matches Python topos.py)
pub const BOUNDARY_MARGIN: f64 = 0.15;

// ─── Heyting Algebra ────────────────────────────────────────────────────
//
// Three-valued truth for topos consensus (Lambert 2021).
// The subobject classifier Ω of Sh(N(V)) is a Heyting algebra:
//   ⊤ = VALID, ⊥ = INVALID, ½ = UNDETERMINED
//
// Key difference from Boolean: ¬UNDETERMINED = UNDETERMINED (not VALID).
// Double negation does NOT collapse the middle.

/// Three-valued Heyting truth value for topos consensus.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum HeytingValue {
    Valid = 1,
    Undetermined = 0,
    Invalid = -1,
}

impl HeytingValue {
    /// ∧ (meet = min)
    pub fn meet(self, other: Self) -> Self {
        match (self, other) {
            (Self::Invalid, _) | (_, Self::Invalid) => Self::Invalid,
            (Self::Undetermined, _) | (_, Self::Undetermined) => Self::Undetermined,
            _ => Self::Valid,
        }
    }

    /// ∨ (join = max)
    pub fn join(self, other: Self) -> Self {
        match (self, other) {
            (Self::Valid, _) | (_, Self::Valid) => Self::Valid,
            (Self::Undetermined, _) | (_, Self::Undetermined) => Self::Undetermined,
            _ => Self::Invalid,
        }
    }

    /// → (Heyting implication)
    ///
    /// a → b = max{c : a ∧ c ≤ b}
    ///
    /// Truth table:
    ///   V → V = V,  V → U = U,  V → I = I
    ///   U → V = V,  U → U = V,  U → I = U  ← NOT Boolean!
    ///   I → V = V,  I → U = V,  I → I = V
    pub fn implies(self, other: Self) -> Self {
        if (self as i8) <= (other as i8) {
            return Self::Valid;
        }
        if self == Self::Valid {
            return other;
        }
        // Undetermined → Invalid = Undetermined (not Invalid)
        Self::Undetermined
    }

    /// ¬a = a → ⊥
    ///
    /// ¬VALID = INVALID
    /// ¬INVALID = VALID
    /// ¬UNDETERMINED = UNDETERMINED  ← the key non-Boolean feature
    pub fn negate(self) -> Self {
        self.implies(Self::Invalid)
    }

    /// ¬¬a ≥ a (Heyting: double negation is inflation, not identity)
    pub fn double_negate(self) -> Self {
        self.negate().negate()
    }

    /// Is this a definite (non-UNDETERMINED) judgment?
    pub fn is_decided(self) -> bool {
        self != Self::Undetermined
    }
}

impl fmt::Display for HeytingValue {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Self::Valid => write!(f, "VALID"),
            Self::Undetermined => write!(f, "UNDETERMINED"),
            Self::Invalid => write!(f, "INVALID"),
        }
    }
}

/// Block hash (SHA-256, domain-separated)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct BlockHash(pub [u8; 32]);

impl fmt::Display for BlockHash {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", hex::encode(self.0))
    }
}

/// Spectral fingerprint (from Oracle off-chain computation)
///
/// Maps to Oracle's HashStalk and Python's SpectralFingerprint.
///
/// POST-AUDIT (Hodge_Ambiguity): The raw spectral_gap value is NOT stored
/// on-chain. Only a boolean "gap is valid" flag is included. Storing the
/// exact gap value would narrow the anonymity set — the Lean proof
/// (Hodge_Ambiguity) shows that same ciphertext under different Laplacians
/// means different things, and the eigenvalue spectrum (including gap) is
/// the PRIVATE key. See also: Spectrum_Not_Homotopy_Invariant.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpectralFingerprint {
    /// Whether Oracle verified gap ∈ [1/√2, 2√2] (boolean only — value discarded)
    pub spectral_gap_valid: bool,
    /// Betti numbers (β₀, β₁, β₂) — matches Oracle HashStalk
    pub betti_numbers: (i32, i32, i32),
    /// Geometric commitment hash (Hodge projection → quantize → hash)
    pub hash: [u8; 32],
}

impl SpectralFingerprint {
    /// Check if gap was verified valid by Oracle
    pub fn verify_bounds(&self) -> bool {
        self.spectral_gap_valid
    }
}

/// Lattice modulus matching Python commitment.py (CochainCommitment default q)
pub const COCHAIN_MODULUS: i64 = 12289;

/// Maximum number of cochain edges accepted in one consensus commitment.
pub const MAX_COCHAIN_EDGES: usize = 8_192;

#[derive(Debug, Error, PartialEq, Eq)]
pub enum CochainCommitmentError {
    #[error("cochain commitment is too short: {actual} bytes")]
    TooShort { actual: usize },
    #[error("unsupported cochain modulus {0}")]
    InvalidModulus(u32),
    #[error("cochain commitment has zero edges")]
    EmptyEdges,
    #[error("cochain commitment has {actual} edges, maximum is {max}")]
    TooManyEdges { actual: usize, max: usize },
    #[error("cochain commitment length overflow")]
    LengthOverflow,
    #[error("non-canonical cochain commitment length: expected {expected}, got {actual}")]
    NonCanonicalLength { expected: usize, actual: usize },
    #[error("inconsistent cochain edge count: expected {expected}, got {actual}")]
    InconsistentEdgeCount { expected: usize, actual: usize },
}

/// Block header
///
/// From ARCHITECTURE.md:
///   prev_hash: SHA256(block N-1)
///   cochain_root: root of cochain tree (NOT standard Merkle)
///   spectral_gap: λ₁ of block Laplacian
///   topology_hash: hash of included party topology
///   producer_fingerprint: spectral fingerprint of producer
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BlockHeader {
    pub version: u32,
    pub height: u64,
    pub parent_hash: BlockHash,
    /// Cochain tree root — homomorphic accumulation of δ(txᵢ) mod q
    ///
    /// NOT a standard Merkle tree. Uses linearity of coboundary:
    /// Σᵢ δ(txᵢ) = δ(Σᵢ txᵢ) — the coboundary of the sum.
    /// Binding: forging requires finding ker(δ) elements (SVP-hard).
    /// Partial opening: reveal subset of vertices, check δ consistency.
    pub cochain_root: [u8; 32],
    pub timestamp: u64,
    /// Spectral proof (contains gap, fingerprint, Oracle trace)
    pub spectral_proof: SpectralProof,
    /// Block producer's spectral fingerprint (32 bytes)
    pub producer_fingerprint: [u8; 32],
    /// Topology hash of producer's nerve complex
    pub topology_hash: [u8; 32],
}

impl BlockHeader {
    /// Domain-separated SHA-256 hash matching Python block.py BlockHeader.hash()
    ///
    /// Python: SHA256("HCRYPT_BLOCK_V1" + version + height + prev_hash +
    ///         cochain_root + timestamp + spectral_gap +
    ///         spectral_commitment + producer_fingerprint)
    pub fn hash(&self) -> BlockHash {
        let mut hasher = Sha256::new();
        hasher.update(b"HCRYPT_BLOCK_V1");
        hasher.update(&self.version.to_le_bytes());
        hasher.update(&self.height.to_le_bytes());
        hasher.update(&self.parent_hash.0);
        hasher.update(&self.cochain_root);
        hasher.update(&self.timestamp.to_le_bytes());
        hasher.update(&[self.spectral_proof.fingerprint.spectral_gap_valid as u8]);
        hasher.update(&self.spectral_proof.fingerprint.hash); // spectral_commitment
        hasher.update(&self.producer_fingerprint);
        BlockHash(hasher.finalize().into())
    }
}

/// Spectral proof (from Oracle)
///
/// Oracle computes: credential → Hodge projection → quantize → hash
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpectralProof {
    pub fingerprint: SpectralFingerprint,
    pub computation_trace: Vec<ComputationStep>,
    pub worker_signatures: Vec<WorkerSignature>,
}

/// Computation step in Oracle trace
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ComputationStep {
    pub operation: String,
    pub input_hash: [u8; 32],
    pub output_hash: [u8; 32],
}

/// Worker signature
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorkerSignature {
    pub worker_pubkey: [u8; 32],
    pub signature: Vec<u8>,
}

/// Transaction (homotopy-based)
///
/// Mirrors Python chain/homotopy_transaction.py HomotopyTransaction
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Transaction {
    /// Serialized transaction data
    pub data: Vec<u8>,
    /// Key image for double-spend prevention
    pub key_image: Option<[u8; 32]>,
    /// Sender's spectral fingerprint (first input)
    pub sender_fingerprint: Option<[u8; 32]>,
    /// Transaction fee (public, always visible for chain economics)
    pub fee_amount: u64,
}

impl Transaction {
    /// Domain-separated SHA-256 tx hash matching Python HomotopyTransaction.tx_hash()
    ///
    /// Python: SHA256("HCRYPT_HTX_V2" + version + key_images + fingerprints + ...)
    pub fn tx_hash(&self) -> [u8; 32] {
        let mut hasher = Sha256::new();
        hasher.update(b"HCRYPT_HTX_V2");
        hasher.update(&self.data);
        if let Some(ki) = &self.key_image {
            hasher.update(ki);
        }
        hasher.finalize().into()
    }
}

/// Block
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Block {
    pub header: BlockHeader,
    pub transactions: Vec<Transaction>,
}

impl Block {
    /// Compute block hash (domain-separated SHA-256 over header)
    pub fn hash(&self) -> BlockHash {
        self.header.hash()
    }

    /// Compute cochain tree root via homomorphic accumulation.
    ///
    /// From cochain.py: δ(c)(e) = c(v) - c(u) — coboundary computes edge
    /// disagreements. From commitment.py: Commit(m) = δ(m || r).
    ///
    /// The cochain tree root accumulates all transaction commitments using
    /// the linearity of δ: Σᵢ δ(txᵢ) = δ(Σᵢ txᵢ).
    ///
    /// Wire format per tx.data (CochainCommitment.to_bytes()):
    ///   modulus(4 LE) + n_edges(4 LE) + edge_values(n × 8 i64 LE) + topology_hash(16)
    ///
    /// Root = SHA256("HCRYPT_COCHAIN_ROOT" + accumulated_edges mod q)
    ///
    /// **SHA256 is only the final compression step.** The input is coboundary
    /// edge values from δ(m‖r) mod q, not raw transaction data. Binding
    /// security comes from the lattice structure: forging a second preimage
    /// requires finding a ker(δ) element (SVP-hard on the cochain lattice,
    /// post-quantum). SHA256 collision resistance is a secondary guarantee.
    pub fn try_compute_cochain_root(&self) -> Result<[u8; 32], CochainCommitmentError> {
        if self.transactions.is_empty() {
            return Ok([0u8; 32]);
        }

        let mut accumulated: Vec<i64> = Vec::new();
        let mut q: i64 = COCHAIN_MODULUS;
        let mut expected_edges: Option<usize> = None;

        for tx in &self.transactions {
            let (modulus, edges) = try_parse_cochain_commitment(&tx.data)?;
            q = modulus as i64;

            match expected_edges {
                Some(n) if n != edges.len() => {
                    return Err(CochainCommitmentError::InconsistentEdgeCount {
                        expected: n,
                        actual: edges.len(),
                    });
                }
                None => expected_edges = Some(edges.len()),
                _ => {}
            }

            if accumulated.is_empty() {
                accumulated = edges.into_iter().map(|edge| edge.rem_euclid(q)).collect();
            } else {
                // Homomorphic addition: δ(m₁||r₁) + δ(m₂||r₂) = δ((m₁+m₂)||(r₁+r₂))
                for (acc, edge) in accumulated.iter_mut().zip(edges) {
                    *acc = (*acc + edge).rem_euclid(q);
                }
            }
        }

        // Domain-separated hash of accumulated edge values
        let mut hasher = Sha256::new();
        hasher.update(b"HCRYPT_COCHAIN_ROOT");
        for val in &accumulated {
            hasher.update(&val.to_le_bytes());
        }
        Ok(hasher.finalize().into())
    }

    /// Compute the cochain root for already-validated transaction data.
    ///
    /// Consensus code should prefer `try_compute_cochain_root` and surface the
    /// validation error. This helper intentionally panics on malformed data
    /// rather than falling back to hashing raw bytes.
    pub fn compute_cochain_root(&self) -> [u8; 32] {
        self.try_compute_cochain_root()
            .expect("block contains canonical cochain commitments")
    }
}

/// Parse cochain commitment from wire format.
///
/// Wire format (matching Python CochainCommitment.to_bytes()):
///   modulus(4 LE) + n_edges(4 LE) + edge_values(n × 8 as i64 LE) + topology_hash(16)
///
/// Returns `(modulus, edge_values)` or an error if data doesn't match the
/// canonical consensus format.
pub fn try_parse_cochain_commitment(
    data: &[u8],
) -> Result<(u32, Vec<i64>), CochainCommitmentError> {
    if data.len() < 24 {
        return Err(CochainCommitmentError::TooShort { actual: data.len() });
    }

    let modulus = u32::from_le_bytes(
        data[0..4]
            .try_into()
            .map_err(|_| CochainCommitmentError::TooShort { actual: data.len() })?,
    );
    let n_edges = u32::from_le_bytes(
        data[4..8]
            .try_into()
            .map_err(|_| CochainCommitmentError::TooShort { actual: data.len() })?,
    ) as usize;

    if modulus as i64 != COCHAIN_MODULUS {
        return Err(CochainCommitmentError::InvalidModulus(modulus));
    }
    if n_edges == 0 {
        return Err(CochainCommitmentError::EmptyEdges);
    }
    if n_edges > MAX_COCHAIN_EDGES {
        return Err(CochainCommitmentError::TooManyEdges {
            actual: n_edges,
            max: MAX_COCHAIN_EDGES,
        });
    }

    let edge_bytes = n_edges
        .checked_mul(8)
        .ok_or(CochainCommitmentError::LengthOverflow)?;
    let expected_len = 8usize
        .checked_add(edge_bytes)
        .and_then(|n| n.checked_add(16))
        .ok_or(CochainCommitmentError::LengthOverflow)?;

    if data.len() != expected_len {
        return Err(CochainCommitmentError::NonCanonicalLength {
            expected: expected_len,
            actual: data.len(),
        });
    }

    let edge_start = 8;
    let edge_end = edge_start + edge_bytes;
    let edges: Vec<i64> = data[edge_start..edge_end]
        .chunks_exact(8)
        .map(|c| i64::from_le_bytes(c.try_into().unwrap()))
        .collect();

    Ok((modulus, edges))
}

/// Backward-compatible parser wrapper for call sites that only need yes/no.
pub fn parse_cochain_commitment(data: &[u8]) -> Option<(u32, Vec<i64>)> {
    try_parse_cochain_commitment(data).ok()
}

/// Helper: create a default BlockHeader for tests
#[cfg(test)]
pub fn test_header(height: u64, _gap: f64) -> BlockHeader {
    BlockHeader {
        version: 1,
        height,
        parent_hash: BlockHash([0; 32]),
        cochain_root: [0; 32],
        timestamp: 0,
        spectral_proof: SpectralProof {
            fingerprint: SpectralFingerprint {
                spectral_gap_valid: true,
                betti_numbers: (1, 0, 0),
                hash: [0; 32],
            },
            computation_trace: vec![],
            worker_signatures: vec![],
        },
        producer_fingerprint: [0; 32],
        topology_hash: [0; 32],
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_spectral_bounds() {
        let fp = SpectralFingerprint {
            spectral_gap_valid: true,
            betti_numbers: (1, 0, 0),
            hash: [0; 32],
        };
        assert!(fp.verify_bounds());

        assert!(!SpectralFingerprint { spectral_gap_valid: false, betti_numbers: (1, 0, 0), hash: [0; 32] }.verify_bounds());
        assert!(SpectralFingerprint { spectral_gap_valid: true, betti_numbers: (1, 0, 0), hash: [0; 32] }.verify_bounds());
    }

    #[test]
    fn test_cochain_root_empty() {
        let block = Block {
            header: test_header(0, 1.0),
            transactions: vec![],
        };
        assert_eq!(block.compute_cochain_root(), [0u8; 32]);
    }

    #[test]
    fn test_cochain_root_deterministic() {
        let block = Block {
            header: test_header(0, 1.0),
            transactions: vec![
                Transaction { data: b"tx1".to_vec(), key_image: None, sender_fingerprint: None, fee_amount: 0 },
                Transaction { data: b"tx2".to_vec(), key_image: None, sender_fingerprint: None, fee_amount: 0 },
            ],
        };
        let root1 = block.compute_cochain_root();
        let root2 = block.compute_cochain_root();
        assert_eq!(root1, root2);
        assert_ne!(root1, [0u8; 32]);
    }

    #[test]
    fn test_cochain_root_homomorphic() {
        // Build two transactions as proper cochain commitments
        // Wire format: modulus(4) + n_edges(4) + edge_values(n*8)
        let q: u32 = 12289;
        let n: u32 = 2; // 2 edges

        // tx1: edges = [100, 200]
        let mut tx1_data = Vec::new();
        tx1_data.extend_from_slice(&q.to_le_bytes());
        tx1_data.extend_from_slice(&n.to_le_bytes());
        tx1_data.extend_from_slice(&100i64.to_le_bytes());
        tx1_data.extend_from_slice(&200i64.to_le_bytes());

        // tx2: edges = [300, 400]
        let mut tx2_data = Vec::new();
        tx2_data.extend_from_slice(&q.to_le_bytes());
        tx2_data.extend_from_slice(&n.to_le_bytes());
        tx2_data.extend_from_slice(&300i64.to_le_bytes());
        tx2_data.extend_from_slice(&400i64.to_le_bytes());

        let block = Block {
            header: test_header(0, 1.0),
            transactions: vec![
                Transaction { data: tx1_data, key_image: None, sender_fingerprint: None, fee_amount: 0 },
                Transaction { data: tx2_data, key_image: None, sender_fingerprint: None, fee_amount: 0 },
            ],
        };

        // Manually compute expected: (100+300) mod q, (200+400) mod q = [400, 600]
        let mut expected_hasher = Sha256::new();
        expected_hasher.update(b"HCRYPT_COCHAIN_ROOT");
        expected_hasher.update(&400i64.to_le_bytes());
        expected_hasher.update(&600i64.to_le_bytes());
        let expected: [u8; 32] = expected_hasher.finalize().into();

        assert_eq!(block.compute_cochain_root(), expected);
    }

    #[test]
    fn test_parse_cochain_commitment() {
        let q: u32 = 12289;
        let n: u32 = 3;
        let mut data = Vec::new();
        data.extend_from_slice(&q.to_le_bytes());
        data.extend_from_slice(&n.to_le_bytes());
        data.extend_from_slice(&42i64.to_le_bytes());
        data.extend_from_slice(&(-7i64).to_le_bytes());
        data.extend_from_slice(&999i64.to_le_bytes());
        // 16-byte topology hash
        data.extend_from_slice(&[0xAB; 16]);

        let (modulus, edges) = parse_cochain_commitment(&data).unwrap();
        assert_eq!(modulus, 12289);
        assert_eq!(edges, vec![42, -7, 999]);

        // Too short → None
        assert!(parse_cochain_commitment(b"short").is_none());
    }

    #[test]
    fn test_block_hash_deterministic() {
        let block = Block {
            header: BlockHeader {
                version: 1,
                height: 42,
                parent_hash: BlockHash([1; 32]),
                cochain_root: [2; 32],
                timestamp: 1234567890,
                spectral_proof: SpectralProof {
                    fingerprint: SpectralFingerprint {
                        spectral_gap_valid: true,
                        betti_numbers: (1, 0, 0),
                        hash: [3; 32],
                    },
                    computation_trace: vec![],
                    worker_signatures: vec![],
                },
                producer_fingerprint: [4; 32],
                topology_hash: [5; 32],
            },
            transactions: vec![],
        };
        assert_eq!(block.hash(), block.hash());
    }

    #[test]
    fn test_domain_separated_hash() {
        // Verify the hash includes the domain separator
        let block = Block {
            header: test_header(0, 1.0),
            transactions: vec![],
        };
        let h = block.hash();
        // Should not be all zeros (domain separator ensures this)
        assert_ne!(h.0, [0u8; 32]);
    }

    #[test]
    fn test_tx_hash_domain_separated() {
        let tx = Transaction { data: b"test".to_vec(), key_image: None, sender_fingerprint: None, fee_amount: 0 };
        let h = tx.tx_hash();
        // Domain separator "HCRYPT_HTX_V2" ensures non-trivial hash
        assert_ne!(h, [0u8; 32]);
        // Deterministic
        assert_eq!(h, tx.tx_hash());
    }

    // ── Wire format edge cases ──────────────────────────────────

    #[test]
    fn test_parse_cochain_with_topology_hash() {
        // Full wire format: modulus(4) + n_edges(4) + edges(n*8) + topology_hash(16)
        let q: u32 = 12289;
        let n: u32 = 2;
        let mut data = Vec::new();
        data.extend_from_slice(&q.to_le_bytes());
        data.extend_from_slice(&n.to_le_bytes());
        data.extend_from_slice(&100i64.to_le_bytes());
        data.extend_from_slice(&200i64.to_le_bytes());
        data.extend_from_slice(&[0xAB; 16]); // topology hash

        let (modulus, edges) = parse_cochain_commitment(&data).unwrap();
        assert_eq!(modulus, 12289);
        assert_eq!(edges, vec![100, 200]);
        // Topology hash is trailing — parse ignores it (not part of edge values)
    }

    #[test]
    fn test_parse_cochain_zero_modulus_rejected() {
        let mut data = Vec::new();
        data.extend_from_slice(&0u32.to_le_bytes()); // modulus = 0 → invalid
        data.extend_from_slice(&1u32.to_le_bytes());
        data.extend_from_slice(&42i64.to_le_bytes());
        assert!(parse_cochain_commitment(&data).is_none());
    }

    #[test]
    fn test_parse_cochain_overflow_modulus_rejected() {
        let mut data = Vec::new();
        data.extend_from_slice(&200_000u32.to_le_bytes()); // > 100_000 → rejected
        data.extend_from_slice(&1u32.to_le_bytes());
        data.extend_from_slice(&42i64.to_le_bytes());
        assert!(parse_cochain_commitment(&data).is_none());
    }

    #[test]
    fn test_parse_cochain_truncated_edges() {
        // Claims 3 edges but only provides bytes for 2
        let q: u32 = 12289;
        let mut data = Vec::new();
        data.extend_from_slice(&q.to_le_bytes());
        data.extend_from_slice(&3u32.to_le_bytes()); // n_edges = 3
        data.extend_from_slice(&100i64.to_le_bytes());
        data.extend_from_slice(&200i64.to_le_bytes());
        // Missing third edge → should fail
        assert!(parse_cochain_commitment(&data).is_none());
    }

    #[test]
    fn test_parse_cochain_zero_edges() {
        let q: u32 = 12289;
        let mut data = Vec::new();
        data.extend_from_slice(&q.to_le_bytes());
        data.extend_from_slice(&0u32.to_le_bytes()); // 0 edges
        let (modulus, edges) = parse_cochain_commitment(&data).unwrap();
        assert_eq!(modulus, 12289);
        assert!(edges.is_empty());
    }

    #[test]
    fn test_parse_cochain_negative_edges() {
        // Edge values can be negative (coboundary δ(c)(e) = c(v) - c(u))
        let q: u32 = 12289;
        let n: u32 = 2;
        let mut data = Vec::new();
        data.extend_from_slice(&q.to_le_bytes());
        data.extend_from_slice(&n.to_le_bytes());
        data.extend_from_slice(&(-500i64).to_le_bytes());
        data.extend_from_slice(&(-1i64).to_le_bytes());

        let (_, edges) = parse_cochain_commitment(&data).unwrap();
        assert_eq!(edges, vec![-500, -1]);
    }

    // ── Cochain root with proper CochainCommitment wire data ────

    #[test]
    fn test_cochain_root_with_wire_format_txs() {
        // Simulate Python: CochainCommitment.to_bytes() → Rust parse + accumulate
        let q: u32 = 12289;

        // tx1: edges = [1000, -500, 300] (coboundary values)
        let tx1 = build_cochain_tx(q, &[1000, -500, 300]);
        // tx2: edges = [200, 800, -100]
        let tx2 = build_cochain_tx(q, &[200, 800, -100]);

        let block = Block {
            header: test_header(1, 1.5),
            transactions: vec![tx1, tx2],
        };

        // Expected: (1000+200) mod q, (-500+800) mod q, (300-100) mod q = [1200, 300, 200]
        let mut expected_hasher = Sha256::new();
        expected_hasher.update(b"HCRYPT_COCHAIN_ROOT");
        expected_hasher.update(&1200i64.to_le_bytes());
        expected_hasher.update(&300i64.to_le_bytes());
        expected_hasher.update(&200i64.to_le_bytes());
        let expected: [u8; 32] = expected_hasher.finalize().into();

        assert_eq!(block.compute_cochain_root(), expected);
    }

    #[test]
    fn test_cochain_root_modular_wraparound() {
        // Edge values that exceed q should wrap around
        let q: u32 = 12289;
        let tx1 = build_cochain_tx(q, &[12000]);
        let tx2 = build_cochain_tx(q, &[1000]);

        let block = Block {
            header: test_header(0, 1.0),
            transactions: vec![tx1, tx2],
        };

        // (12000 + 1000) mod 12289 = 13000 mod 12289 = 711
        let mut expected_hasher = Sha256::new();
        expected_hasher.update(b"HCRYPT_COCHAIN_ROOT");
        expected_hasher.update(&711i64.to_le_bytes());
        let expected: [u8; 32] = expected_hasher.finalize().into();

        assert_eq!(block.compute_cochain_root(), expected);
    }

    #[test]
    fn test_cochain_root_negative_wraparound() {
        // Negative values should use rem_euclid (always positive result)
        let q: u32 = 12289;
        let tx1 = build_cochain_tx(q, &[-1]);
        // rem_euclid(-1, 12289) = 12288
        let tx2 = build_cochain_tx(q, &[-1]);
        // rem_euclid(12288 + (-1), 12289) = rem_euclid(12287, 12289) = 12287

        let block = Block {
            header: test_header(0, 1.0),
            transactions: vec![tx1, tx2],
        };

        let mut expected_hasher = Sha256::new();
        expected_hasher.update(b"HCRYPT_COCHAIN_ROOT");
        expected_hasher.update(&12287i64.to_le_bytes()); // (-1 + -1) mod 12289 = 12287
        let expected: [u8; 32] = expected_hasher.finalize().into();

        assert_eq!(block.compute_cochain_root(), expected);
    }

    #[test]
    fn test_cochain_root_unequal_edge_count() {
        // tx1 has 2 edges, tx2 has 3 → accumulation extends
        let q: u32 = 12289;
        let tx1 = build_cochain_tx(q, &[100, 200]);
        let tx2 = build_cochain_tx(q, &[300, 400, 500]);

        let block = Block {
            header: test_header(0, 1.0),
            transactions: vec![tx1, tx2],
        };

        // Expected: [400, 600, 500] (third edge only from tx2)
        let mut expected_hasher = Sha256::new();
        expected_hasher.update(b"HCRYPT_COCHAIN_ROOT");
        expected_hasher.update(&400i64.to_le_bytes());
        expected_hasher.update(&600i64.to_le_bytes());
        expected_hasher.update(&500i64.to_le_bytes());
        let expected: [u8; 32] = expected_hasher.finalize().into();

        assert_eq!(block.compute_cochain_root(), expected);
    }

    #[test]
    fn test_block_hash_changes_with_fields() {
        let h1 = test_header(1, 1.5).hash();
        let h2 = test_header(2, 1.5).hash(); // different height
        assert_ne!(h1, h2);
    }

    #[test]
    fn test_tx_hash_with_key_image() {
        let tx1 = Transaction { data: b"same".to_vec(), key_image: None, sender_fingerprint: None, fee_amount: 0 };
        let tx2 = Transaction { data: b"same".to_vec(), key_image: Some([1; 32]), sender_fingerprint: None, fee_amount: 0 };
        let tx3 = Transaction { data: b"same".to_vec(), key_image: Some([2; 32]), sender_fingerprint: None, fee_amount: 0 };
        // Different key images → different hashes
        assert_ne!(tx1.tx_hash(), tx2.tx_hash());
        assert_ne!(tx2.tx_hash(), tx3.tx_hash());
    }

    #[test]
    fn test_pov_bounds_constants() {
        // Verify the √2 constants are correct
        assert!((SQRT2 - std::f64::consts::SQRT_2).abs() < 1e-8);
        assert!((POV_LOWER - 1.0 / std::f64::consts::SQRT_2).abs() < 1e-8);
        assert!((POV_UPPER - 2.0 * std::f64::consts::SQRT_2).abs() < 1e-8);
    }

    /// Helper: build a Transaction with CochainCommitment wire format
    fn build_cochain_tx(q: u32, edges: &[i64]) -> Transaction {
        let mut data = Vec::new();
        data.extend_from_slice(&q.to_le_bytes());
        data.extend_from_slice(&(edges.len() as u32).to_le_bytes());
        for &e in edges {
            data.extend_from_slice(&e.to_le_bytes());
        }
        Transaction {
            data,
            key_image: None,
            sender_fingerprint: None,
            fee_amount: 0,
        }
    }
}
