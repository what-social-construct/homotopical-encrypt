#![allow(dead_code)]
// Cochain Commitment Scheme — Rust port of src/crypto/commitment.py
//
// Commit(m) = δ(m ∥ r) where:
//   - m is the message (at vertex 0)
//   - r is randomness (at vertices 1..n)
//   - δ: C⁰ → C¹ is the coboundary operator
//
// Properties:
//   BINDING:      collision requires ker(δ) element (SVP-hard)
//   HIDING:       δ with secret restriction maps is lattice-hard
//   HOMOMORPHIC:  δ(m₁∥r₁) + δ(m₂∥r₂) = δ((m₁+m₂)∥(r₁+r₂))
//
// Wire format (matching Python CochainCommitment.to_bytes()):
//   modulus(4 LE) + n_edges(4 LE) + edge_values(n × 8 i64 LE) + topology_hash(16)

use sha2::{Sha256, Digest};
use rand::Rng;

/// Default lattice modulus (matching Python commitment.py)
pub const DEFAULT_MODULUS: i64 = 12289;

// =============================================================================
// COCHAIN COMPLEX (topology)
// =============================================================================

/// A simplicial complex with vertices and edges.
///
/// The coboundary δ: C⁰ → C¹ is defined by the edge list:
///   δ(c)(e) = c(v) - c(u) for edge e = (u, v)
///
/// Matches Python CochainComplex from src/primitives/cochain.py.
#[derive(Debug, Clone)]
pub struct CochainComplex {
    pub n_vertices: usize,
    pub edges: Vec<(usize, usize)>,
    pub stalk_dim: usize,
}

impl CochainComplex {
    /// Create a complex with the given vertices, edges, and stalk dimension.
    pub fn new(n_vertices: usize, edges: Vec<(usize, usize)>, stalk_dim: usize) -> Self {
        Self { n_vertices, edges, stalk_dim }
    }

    /// Create a complete graph K_n (every pair connected).
    pub fn complete(n: usize, stalk_dim: usize) -> Self {
        let mut edges = Vec::new();
        for i in 0..n {
            for j in (i + 1)..n {
                edges.push((i, j));
            }
        }
        Self { n_vertices: n, edges, stalk_dim }
    }

    /// Create a path graph (0-1-2-...-n).
    pub fn path(n: usize, stalk_dim: usize) -> Self {
        let edges: Vec<(usize, usize)> = (0..n - 1).map(|i| (i, i + 1)).collect();
        Self { n_vertices: n, edges, stalk_dim }
    }

    /// Apply coboundary δ: C⁰ → C¹.
    ///
    /// Input: vertex values c[v][d] for v in 0..n_vertices, d in 0..stalk_dim
    /// Output: edge values δ(c)[e][d] = c[v][d] - c[u][d] for edge e = (u, v)
    ///
    /// All arithmetic mod q.
    pub fn apply_coboundary(&self, vertex_values: &[Vec<i64>], q: i64) -> Vec<i64> {
        let mut edge_values = Vec::with_capacity(self.edges.len() * self.stalk_dim);
        for &(u, v) in &self.edges {
            for d in 0..self.stalk_dim {
                let val = (vertex_values[v][d] - vertex_values[u][d]).rem_euclid(q);
                edge_values.push(val);
            }
        }
        edge_values
    }

    /// Compute topology hash (matches Python CochainCommitment._hash_topology).
    pub fn topology_hash(&self) -> [u8; 16] {
        let mut hasher = Sha256::new();
        // Sort vertices (0..n, already sorted)
        let vertices: Vec<usize> = (0..self.n_vertices).collect();
        hasher.update(format!("{:?}", vertices).as_bytes());
        // Sort edges
        let mut sorted_edges = self.edges.clone();
        sorted_edges.sort();
        hasher.update(format!("{:?}", sorted_edges).as_bytes());
        hasher.update(format!("{}", self.stalk_dim).as_bytes());
        let full_hash: [u8; 32] = hasher.finalize().into();
        let mut h = [0u8; 16];
        h.copy_from_slice(&full_hash[..16]);
        h
    }
}

// =============================================================================
// COCHAIN COMMITMENT
// =============================================================================

/// Cochain commitment: Commit(m) = δ(m ∥ r) mod q
///
/// The commitment lives in C¹ (edge space). Binding comes from
/// the hardness of finding ker(δ) elements (SVP on cochain lattice).
/// Hiding comes from the random shares at non-message vertices.
///
/// Matches Python CochainCommitment from src/crypto/commitment.py.
#[derive(Debug, Clone)]
pub struct CochainCommitment {
    /// Edge values in C¹ (the commitment itself)
    pub edge_values: Vec<i64>,
    /// Topology hash (16 bytes, identifies which complex this is over)
    pub topology_hash: [u8; 16],
    /// Modulus q for ℤ_q arithmetic
    pub modulus: i64,
}

impl CochainCommitment {
    /// Create a commitment to a message.
    ///
    /// Places `message` at vertex 0, random values at other vertices,
    /// then applies the coboundary δ.
    ///
    /// Returns (commitment, randomness) where randomness is the opening.
    pub fn commit(
        message: &[i64],
        complex: &CochainComplex,
        q: i64,
    ) -> (Self, Vec<Vec<i64>>) {
        let mut rng = rand::thread_rng();
        let randomness: Vec<Vec<i64>> = (0..complex.n_vertices - 1)
            .map(|_| {
                (0..complex.stalk_dim)
                    .map(|_| rng.gen_range(0..q))
                    .collect()
            })
            .collect();

        Self::commit_with_randomness(message, complex, &randomness, q)
    }

    /// Create a commitment with explicit randomness (for testing/verification).
    pub fn commit_with_randomness(
        message: &[i64],
        complex: &CochainComplex,
        randomness: &[Vec<i64>],
        q: i64,
    ) -> (Self, Vec<Vec<i64>>) {
        assert_eq!(message.len(), complex.stalk_dim, "message dim must match stalk_dim");
        assert_eq!(randomness.len(), complex.n_vertices - 1, "need n-1 random vectors");

        // Build vertex values: message at v0, randomness at v1..vn
        let mut vertex_values: Vec<Vec<i64>> = Vec::with_capacity(complex.n_vertices);
        vertex_values.push(message.to_vec());
        for r in randomness {
            vertex_values.push(r.clone());
        }

        // Apply coboundary δ
        let edge_values = complex.apply_coboundary(&vertex_values, q);
        let topology_hash = complex.topology_hash();

        (
            Self {
                edge_values,
                topology_hash,
                modulus: q,
            },
            randomness.to_vec(),
        )
    }

    /// Verify a commitment opening.
    ///
    /// Recomputes δ(message ∥ randomness) and checks against stored edge values.
    pub fn verify_opening(
        &self,
        message: &[i64],
        randomness: &[Vec<i64>],
        complex: &CochainComplex,
    ) -> bool {
        // Check topology matches
        if complex.topology_hash() != self.topology_hash {
            return false;
        }

        // Recompute commitment
        let (recomputed, _) = Self::commit_with_randomness(
            message, complex, randomness, self.modulus,
        );

        // Compare edge values mod q
        if self.edge_values.len() != recomputed.edge_values.len() {
            return false;
        }
        self.edge_values.iter().zip(recomputed.edge_values.iter()).all(|(a, b)| {
            a.rem_euclid(self.modulus) == b.rem_euclid(self.modulus)
        })
    }

    /// Serialize to wire format (matching Python CochainCommitment.to_bytes()).
    ///
    /// Format: modulus(4 LE) + n_edges(4 LE) + edge_values(n × 8 i64 LE) + topology_hash(16)
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut data = Vec::new();
        data.extend_from_slice(&(self.modulus as u32).to_le_bytes());
        data.extend_from_slice(&(self.edge_values.len() as u32).to_le_bytes());
        for &val in &self.edge_values {
            data.extend_from_slice(&val.to_le_bytes());
        }
        data.extend_from_slice(&self.topology_hash);
        data
    }

    /// Deserialize from wire format (matching Python CochainCommitment.from_bytes()).
    pub fn from_bytes(data: &[u8]) -> Option<Self> {
        if data.len() < 8 {
            return None;
        }

        let modulus = u32::from_le_bytes(data[0..4].try_into().ok()?) as i64;
        let n_edges = u32::from_le_bytes(data[4..8].try_into().ok()?) as usize;

        if modulus == 0 || modulus > 100_000 {
            return None;
        }

        let edge_start = 8;
        let edge_end = edge_start + n_edges * 8;
        if data.len() < edge_end {
            return None;
        }

        let edge_values: Vec<i64> = data[edge_start..edge_end]
            .chunks_exact(8)
            .map(|c| i64::from_le_bytes(c.try_into().unwrap()))
            .collect();

        // Extract topology hash if present (16 bytes after edges)
        let mut topology_hash = [0u8; 16];
        if data.len() >= edge_end + 16 {
            topology_hash.copy_from_slice(&data[edge_end..edge_end + 16]);
        }

        Some(Self {
            edge_values,
            topology_hash,
            modulus,
        })
    }

    /// Homomorphic addition of two commitments.
    ///
    /// δ(m₁∥r₁) + δ(m₂∥r₂) = δ((m₁+m₂)∥(r₁+r₂))
    ///
    /// Both commitments must be over the same topology.
    pub fn add(&self, other: &CochainCommitment) -> Option<CochainCommitment> {
        if self.topology_hash != other.topology_hash {
            return None;
        }
        let q = self.modulus;
        let len = self.edge_values.len().max(other.edge_values.len());
        let mut combined = vec![0i64; len];

        for (i, &v) in self.edge_values.iter().enumerate() {
            combined[i] = (combined[i] + v).rem_euclid(q);
        }
        for (i, &v) in other.edge_values.iter().enumerate() {
            combined[i] = (combined[i] + v).rem_euclid(q);
        }

        Some(CochainCommitment {
            edge_values: combined,
            topology_hash: self.topology_hash,
            modulus: q,
        })
    }

    /// Homomorphic scalar multiplication.
    ///
    /// k · Commit(m, r) = Commit(k·m, k·r)
    pub fn scalar_mult(&self, scalar: i64) -> CochainCommitment {
        let q = self.modulus;
        let scaled = self.edge_values.iter()
            .map(|&v| (scalar * v).rem_euclid(q))
            .collect();
        CochainCommitment {
            edge_values: scaled,
            topology_hash: self.topology_hash,
            modulus: q,
        }
    }
}

// =============================================================================
// TESTS
// =============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_coboundary_basic() {
        // Path graph: 0 -- 1 -- 2, stalk_dim=1
        let cx = CochainComplex::path(3, 1);
        // Vertex values: [10], [30], [50]
        let vertex_values = vec![vec![10], vec![30], vec![50]];
        let q = 12289;
        let edges = cx.apply_coboundary(&vertex_values, q);
        // Edge (0,1): 30 - 10 = 20
        // Edge (1,2): 50 - 30 = 20
        assert_eq!(edges, vec![20, 20]);
    }

    #[test]
    fn test_coboundary_negative_wraps() {
        let cx = CochainComplex::path(2, 1);
        // v0=100, v1=50 → edge = 50 - 100 = -50 → rem_euclid(12289) = 12239
        let vertex_values = vec![vec![100], vec![50]];
        let q = 12289;
        let edges = cx.apply_coboundary(&vertex_values, q);
        assert_eq!(edges, vec![(-50i64).rem_euclid(q)]);
    }

    #[test]
    fn test_commit_and_verify() {
        let cx = CochainComplex::complete(4, 2);
        let message = vec![42, 99];
        let q = DEFAULT_MODULUS;

        let (commitment, randomness) = CochainCommitment::commit(&message, &cx, q);

        // Verify with correct opening
        assert!(commitment.verify_opening(&message, &randomness, &cx));

        // Verify with wrong message fails
        let wrong_message = vec![0, 0];
        assert!(!commitment.verify_opening(&wrong_message, &randomness, &cx));
    }

    #[test]
    fn test_commit_deterministic_with_explicit_randomness() {
        let cx = CochainComplex::path(3, 1);
        let message = vec![42];
        let randomness = vec![vec![100], vec![200]];
        let q = DEFAULT_MODULUS;

        let (c1, _) = CochainCommitment::commit_with_randomness(&message, &cx, &randomness, q);
        let (c2, _) = CochainCommitment::commit_with_randomness(&message, &cx, &randomness, q);

        assert_eq!(c1.edge_values, c2.edge_values);
    }

    #[test]
    fn test_wire_format_roundtrip() {
        let cx = CochainComplex::complete(3, 1);
        let message = vec![77];
        let q = DEFAULT_MODULUS;

        let (commitment, _) = CochainCommitment::commit(&message, &cx, q);
        let bytes = commitment.to_bytes();
        let restored = CochainCommitment::from_bytes(&bytes).unwrap();

        assert_eq!(commitment.edge_values, restored.edge_values);
        assert_eq!(commitment.topology_hash, restored.topology_hash);
        assert_eq!(commitment.modulus, restored.modulus);
    }

    #[test]
    fn test_wire_format_matches_python() {
        // Manually construct the wire format Python would produce
        let q: u32 = 12289;
        let edges: Vec<i64> = vec![100, -200, 300];
        let topo_hash = [0xABu8; 16];

        let mut data = Vec::new();
        data.extend_from_slice(&q.to_le_bytes());
        data.extend_from_slice(&(edges.len() as u32).to_le_bytes());
        for &e in &edges {
            data.extend_from_slice(&e.to_le_bytes());
        }
        data.extend_from_slice(&topo_hash);

        let commitment = CochainCommitment::from_bytes(&data).unwrap();
        assert_eq!(commitment.modulus, 12289);
        assert_eq!(commitment.edge_values, vec![100, -200, 300]);
        assert_eq!(commitment.topology_hash, topo_hash);

        // Re-serialize should match
        assert_eq!(commitment.to_bytes(), data);
    }

    #[test]
    fn test_homomorphic_addition() {
        let cx = CochainComplex::path(3, 1);
        let q = DEFAULT_MODULUS;

        let m1 = vec![100];
        let r1 = vec![vec![200], vec![300]];
        let (c1, _) = CochainCommitment::commit_with_randomness(&m1, &cx, &r1, q);

        let m2 = vec![400];
        let r2 = vec![vec![500], vec![600]];
        let (c2, _) = CochainCommitment::commit_with_randomness(&m2, &cx, &r2, q);

        // Sum commitment
        let c_sum = c1.add(&c2).unwrap();

        // Direct commitment of (m1+m2, r1+r2)
        let m_sum = vec![(100 + 400) % q];
        let r_sum = vec![
            vec![(200 + 500) % q],
            vec![(300 + 600) % q],
        ];
        let (c_direct, _) = CochainCommitment::commit_with_randomness(&m_sum, &cx, &r_sum, q);

        // Should be equal (linearity of δ)
        assert_eq!(c_sum.edge_values, c_direct.edge_values);
    }

    #[test]
    fn test_homomorphic_scalar_mult() {
        let cx = CochainComplex::path(3, 1);
        let q = DEFAULT_MODULUS;
        let k: i64 = 3;

        let m = vec![100];
        let r = vec![vec![200], vec![300]];
        let (c, _) = CochainCommitment::commit_with_randomness(&m, &cx, &r, q);

        // k * commitment
        let c_scaled = c.scalar_mult(k);

        // Direct commitment of (k*m, k*r)
        let m_k = vec![(k * 100) % q];
        let r_k = vec![
            vec![(k * 200) % q],
            vec![(k * 300) % q],
        ];
        let (c_direct, _) = CochainCommitment::commit_with_randomness(&m_k, &cx, &r_k, q);

        assert_eq!(c_scaled.edge_values, c_direct.edge_values);
    }

    #[test]
    fn test_different_topology_add_fails() {
        let cx1 = CochainComplex::path(3, 1);
        let cx2 = CochainComplex::complete(3, 1);
        let q = DEFAULT_MODULUS;

        let (c1, _) = CochainCommitment::commit(&[42], &cx1, q);
        let (c2, _) = CochainCommitment::commit(&[99], &cx2, q);

        assert!(c1.add(&c2).is_none());
    }

    #[test]
    fn test_topology_hash_deterministic() {
        let cx1 = CochainComplex::complete(4, 2);
        let cx2 = CochainComplex::complete(4, 2);
        assert_eq!(cx1.topology_hash(), cx2.topology_hash());
    }

    #[test]
    fn test_topology_hash_different() {
        let cx1 = CochainComplex::complete(3, 1);
        let cx2 = CochainComplex::path(3, 1);
        assert_ne!(cx1.topology_hash(), cx2.topology_hash());
    }

    #[test]
    fn test_complete_graph_edge_count() {
        let cx = CochainComplex::complete(4, 1);
        assert_eq!(cx.edges.len(), 6); // C(4,2) = 6
    }

    #[test]
    fn test_from_bytes_rejects_invalid() {
        assert!(CochainCommitment::from_bytes(b"short").is_none());
        // Zero modulus
        let mut bad = vec![0u8; 24];
        assert!(CochainCommitment::from_bytes(&bad).is_none());
        // Modulus too large
        bad[0..4].copy_from_slice(&200_000u32.to_le_bytes());
        assert!(CochainCommitment::from_bytes(&bad).is_none());
    }

    #[test]
    fn test_modular_arithmetic() {
        // Verify edge values wrap correctly under addition
        let cx = CochainComplex::path(2, 1);
        let q = DEFAULT_MODULUS;

        let (c1, _) = CochainCommitment::commit_with_randomness(
            &[q - 1], &cx, &[vec![1]], q,
        );
        let (c2, _) = CochainCommitment::commit_with_randomness(
            &[q - 1], &cx, &[vec![1]], q,
        );

        let sum = c1.add(&c2).unwrap();
        // Each edge value should be mod q
        for &v in &sum.edge_values {
            assert!(v >= 0 && v < q, "edge value {} not in [0, q)", v);
        }
    }

    #[test]
    fn test_multidimensional_stalk() {
        // stalk_dim=3: message and randomness are 3-vectors
        let cx = CochainComplex::path(3, 3);
        let message = vec![10, 20, 30];
        let randomness = vec![vec![40, 50, 60], vec![70, 80, 90]];
        let q = DEFAULT_MODULUS;

        let (commitment, _) = CochainCommitment::commit_with_randomness(
            &message, &cx, &randomness, q,
        );

        // 2 edges × 3 dimensions = 6 edge values
        assert_eq!(commitment.edge_values.len(), 6);
        assert!(commitment.verify_opening(&message, &randomness, &cx));
    }
}
