// Native Sheaf Onion Encryption
//
// Ports Python fiber_bundle.py onion routing to pure Rust.
// Eliminates the Python HTTP bridge dependency for privacy.
//
// MATH:
//   encrypt: ciphertext = Q @ plaintext     (Q ∈ SO(n), parallel transport)
//   decrypt: plaintext  = Q^T @ ciphertext   (Q^T = Q^{-1} for orthogonal)
//
//   Path hints are encrypted per-layer with BLAKE3-keyed XOR.
//   Each relay peels one layer by:
//     1. Decrypt path hint (recover random walk)
//     2. Reconstruct Q from path
//     3. Apply Q^T to decrypt
//
// LEAN GROUNDING:
//   Tsirelson.lean: Grassmannian_Laplacian_injective (Q determines W uniquely)
//   Hardness.lean:  GrothendieckFibration (parallel transport = cartesian lifts)
//   Laplacian.lean: laplacian_apply (Δ_W b = P_{W⊥} b)
//
// CATEGORICAL VIEW (Swan et al. Table 1 #11):
//   Each relay's Q is a LENS focusing on its fiber subspace.
//   Composition Q₁∘Q₂∘Q₃ is the onion = composed optic.
//   GET: Q @ msg  (view through fiber)
//   PUT: Q^T @ cipher (update back to base)

use anyhow::{anyhow, Result};
use nalgebra::{DMatrix, DVector};
use rand::Rng;
use serde::{Deserialize, Serialize};

/// A parallel transport matrix Q ∈ SO(n).
/// Constructed from a random walk on the nerve graph.
#[derive(Debug, Clone)]
pub struct TransportMatrix {
    /// The orthogonal matrix Q (n × n)
    pub q: DMatrix<f64>,
}

impl TransportMatrix {
    /// Identity transport (no rotation)
    pub fn identity(dim: usize) -> Self {
        Self {
            q: DMatrix::identity(dim, dim),
        }
    }

    /// Construct from a random walk path through connection matrices.
    /// Each edge (i,j) has an orthogonal connection R_{ij}.
    /// The transport along path [v₀, v₁, ..., vₖ] is:
    ///   Q = R_{v₀,v₁} · R_{v₁,v₂} · ... · R_{vₖ₋₁,vₖ}
    pub fn from_path(connections: &ConnectionSet, path: &[usize]) -> Self {
        let dim = connections.dim;
        let mut q = DMatrix::identity(dim, dim);

        for window in path.windows(2) {
            let (u, v) = (window[0], window[1]);
            if let Some(r) = connections.get_connection(u, v) {
                q = r * &q;
            }
        }

        Self { q }
    }

    /// Generate a random orthogonal transport (for testing / ephemeral fibers)
    pub fn random(dim: usize) -> Self {
        // QR decomposition of random matrix → Q ∈ O(n)
        // Then fix det to +1 for SO(n)
        let mut rng = rand::thread_rng();
        let m: DMatrix<f64> =
            DMatrix::from_fn(dim, dim, |_, _| rng.gen::<f64>() - 0.5);
        let qr = m.qr();
        let mut q = qr.q();

        // Ensure det = +1 (proper rotation)
        if q.determinant() < 0.0 {
            q.column_mut(0).scale_mut(-1.0);
        }

        Self { q }
    }

    /// Encrypt: ciphertext = Q @ plaintext
    pub fn encrypt(&self, plaintext: &DVector<f64>) -> DVector<f64> {
        &self.q * plaintext
    }

    /// Decrypt: plaintext = Q^T @ ciphertext (orthogonal inverse)
    pub fn decrypt(&self, ciphertext: &DVector<f64>) -> DVector<f64> {
        self.q.transpose() * ciphertext
    }

    /// Dimension
    pub fn dim(&self) -> usize {
        self.q.nrows()
    }

    /// Verify orthogonality: Q^T Q ≈ I
    pub fn verify_orthogonal(&self, tol: f64) -> bool {
        let qtq = self.q.transpose() * &self.q;
        let identity = DMatrix::identity(self.dim(), self.dim());
        let err = (&qtq - &identity).norm();
        err < tol
    }
}

// ─── Connection Set ────────────────────────────────────────────────

/// Set of orthogonal connection matrices on nerve edges.
/// This is the fiber bundle's connection — the parallel transport structure.
pub struct ConnectionSet {
    pub dim: usize,
    /// Connection matrices indexed by (min(u,v), max(u,v))
    connections: std::collections::HashMap<(usize, usize), DMatrix<f64>>,
}

impl ConnectionSet {
    /// Create empty connection set
    pub fn new(dim: usize) -> Self {
        Self {
            dim,
            connections: std::collections::HashMap::new(),
        }
    }

    /// Create random connections for a set of edges (testing)
    pub fn random(dim: usize, edges: &[(usize, usize)]) -> Self {
        let mut cs = Self::new(dim);
        for &(u, v) in edges {
            let t = TransportMatrix::random(dim);
            cs.set_connection(u, v, t.q);
        }
        cs
    }

    /// Set connection matrix for edge (u, v)
    pub fn set_connection(&mut self, u: usize, v: usize, r: DMatrix<f64>) {
        let key = (u.min(v), u.max(v));
        self.connections.insert(key, r);
    }

    /// Get connection matrix for edge (u, v)
    pub fn get_connection(&self, u: usize, v: usize) -> Option<DMatrix<f64>> {
        let key = (u.min(v), u.max(v));
        self.connections.get(&key).cloned()
    }
}

// ─── Onion Packet ──────────────────────────────────────────────────

/// A native onion packet (replaces Python bridge version)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NativeOnionPacket {
    /// Encrypted layers (each is a serialized DVector<f64>)
    pub layers: Vec<Vec<u8>>,
    /// Encrypted path hints per layer (BLAKE3-keyed)
    pub encrypted_hints: Vec<Vec<u8>>,
    /// Current layer index (relays increment this)
    pub current_layer: usize,
    /// Fiber dimension
    pub fiber_dim: usize,
}

impl NativeOnionPacket {
    /// Serialize to bytes
    pub fn to_bytes(&self) -> Result<Vec<u8>> {
        bincode::serialize(self).map_err(|e| anyhow!("Serialize: {}", e))
    }

    /// Deserialize from bytes
    pub fn from_bytes(data: &[u8]) -> Result<Self> {
        bincode::deserialize(data).map_err(|e| anyhow!("Deserialize: {}", e))
    }

    /// Number of layers remaining
    pub fn layers_remaining(&self) -> usize {
        self.layers.len().saturating_sub(self.current_layer)
    }

    /// Is this the final layer?
    pub fn is_final(&self) -> bool {
        self.current_layer + 1 >= self.layers.len()
    }
}

// ─── Path Hint Encryption ──────────────────────────────────────────

/// Encrypt a path hint (list of vertex indices) with a relay key.
/// Uses BLAKE3 in keyed mode as a stream cipher.
fn encrypt_path_hint(path: &[usize], relay_key: &[u8; 32]) -> Vec<u8> {
    // Serialize path as u32 LE
    let mut plaintext = Vec::with_capacity(path.len() * 4);
    for &v in path {
        plaintext.extend_from_slice(&(v as u32).to_le_bytes());
    }

    // BLAKE3 keyed hash as keystream
    let mut hasher = blake3::Hasher::new_keyed(relay_key);
    hasher.update(b"hcrypt-onion-hint-v1");
    hasher.update(&(plaintext.len() as u32).to_le_bytes());
    let mut keystream = vec![0u8; plaintext.len()];
    hasher.finalize_xof().fill(&mut keystream);

    // XOR
    plaintext
        .iter()
        .zip(keystream.iter())
        .map(|(a, b)| a ^ b)
        .collect()
}

/// Decrypt a path hint with a relay key.
fn decrypt_path_hint(encrypted: &[u8], relay_key: &[u8; 32]) -> Vec<usize> {
    // Reconstruct keystream
    let mut hasher = blake3::Hasher::new_keyed(relay_key);
    hasher.update(b"hcrypt-onion-hint-v1");
    hasher.update(&(encrypted.len() as u32).to_le_bytes());
    let mut keystream = vec![0u8; encrypted.len()];
    hasher.finalize_xof().fill(&mut keystream);

    // XOR to get plaintext
    let plaintext: Vec<u8> = encrypted
        .iter()
        .zip(keystream.iter())
        .map(|(a, b)| a ^ b)
        .collect();

    // Deserialize u32 LE
    plaintext
        .chunks(4)
        .filter_map(|chunk| {
            if chunk.len() == 4 {
                Some(u32::from_le_bytes([chunk[0], chunk[1], chunk[2], chunk[3]]) as usize)
            } else {
                None
            }
        })
        .collect()
}

// ─── Onion Construction ────────────────────────────────────────────

/// Generate a random walk on the nerve graph starting from a random vertex.
fn random_walk(n_vertices: usize, edges: &[(usize, usize)], walk_len: usize) -> Vec<usize> {
    let mut rng = rand::thread_rng();

    // Build adjacency list
    let mut adj: std::collections::HashMap<usize, Vec<usize>> = std::collections::HashMap::new();
    for &(u, v) in edges {
        adj.entry(u).or_default().push(v);
        adj.entry(v).or_default().push(u);
    }

    let start = rng.gen_range(0..n_vertices);
    let mut path = vec![start];
    let mut current = start;

    for _ in 0..walk_len {
        if let Some(neighbors) = adj.get(&current) {
            if !neighbors.is_empty() {
                let next = neighbors[rng.gen_range(0..neighbors.len())];
                path.push(next);
                current = next;
                continue;
            }
        }
        break;
    }

    path
}

/// Serialize a DVector<f64> to bytes
fn dvector_to_bytes(v: &DVector<f64>) -> Vec<u8> {
    let mut bytes = Vec::with_capacity(v.len() * 8);
    for i in 0..v.len() {
        bytes.extend_from_slice(&v[i].to_le_bytes());
    }
    bytes
}

/// Deserialize bytes to DVector<f64>
fn dvector_from_bytes(data: &[u8], dim: usize) -> Result<DVector<f64>> {
    if data.len() != dim * 8 {
        return Err(anyhow!(
            "Expected {} bytes for dim={}, got {}",
            dim * 8,
            dim,
            data.len()
        ));
    }
    let mut values = Vec::with_capacity(dim);
    for chunk in data.chunks(8) {
        values.push(f64::from_le_bytes(chunk.try_into()?));
    }
    Ok(DVector::from_vec(values))
}

/// Create an onion packet wrapping message through relay chain.
///
/// Each relay has:
///   - A ConnectionSet (fiber bundle connection)
///   - A 32-byte key (shared via prior DH or similar)
///   - A nerve graph (vertices + edges for random walks)
///
/// Wraps message in layers: msg → wrap(relay_n) → ... → wrap(relay_1)
pub fn create_native_onion(
    relay_connections: &[&ConnectionSet],
    relay_keys: &[[u8; 32]],
    relay_edges: &[&[(usize, usize)]],
    relay_n_vertices: &[usize],
    message: &DVector<f64>,
) -> Result<NativeOnionPacket> {
    let n_relays = relay_connections.len();
    if n_relays != relay_keys.len()
        || n_relays != relay_edges.len()
        || n_relays != relay_n_vertices.len()
    {
        return Err(anyhow!("Relay parameter count mismatch"));
    }

    let dim = message.len();
    let mut current = message.clone();
    let mut layers = Vec::new();
    let mut encrypted_hints = Vec::new();

    // Wrap from last relay to first (onion structure)
    for i in (0..n_relays).rev() {
        let cs = relay_connections[i];
        if cs.dim != dim {
            return Err(anyhow!("Relay {} dim {} != message dim {}", i, cs.dim, dim));
        }

        // Generate random walk for this layer
        let path = random_walk(relay_n_vertices[i], relay_edges[i], 5);

        // Build transport matrix from path
        let transport = TransportMatrix::from_path(cs, &path);

        // ENCRYPT: ciphertext = Q @ plaintext
        let encrypted = transport.encrypt(&current);

        layers.insert(0, dvector_to_bytes(&encrypted));

        // Encrypt path hint with relay's key
        let hint = encrypt_path_hint(&path, &relay_keys[i]);
        encrypted_hints.insert(0, hint);

        current = encrypted;
    }

    Ok(NativeOnionPacket {
        layers,
        encrypted_hints,
        current_layer: 0,
        fiber_dim: dim,
    })
}

/// Peel one layer of onion encryption (relay processing).
///
/// Returns (decrypted_data, is_final)
pub fn peel_native_onion(
    packet: &mut NativeOnionPacket,
    connections: &ConnectionSet,
    relay_key: &[u8; 32],
) -> Result<(DVector<f64>, bool)> {
    if packet.current_layer >= packet.layers.len() {
        return Err(anyhow!("No more layers to peel"));
    }

    let dim = packet.fiber_dim;

    // Get this layer's encrypted data
    let layer_data = dvector_from_bytes(&packet.layers[packet.current_layer], dim)?;

    // Decrypt path hint
    let path = decrypt_path_hint(&packet.encrypted_hints[packet.current_layer], relay_key);

    // Reconstruct transport matrix from path
    let transport = TransportMatrix::from_path(connections, &path);

    // DECRYPT: plaintext = Q^T @ ciphertext
    let decrypted = transport.decrypt(&layer_data);

    packet.current_layer += 1;
    let is_final = packet.current_layer >= packet.layers.len();

    Ok((decrypted, is_final))
}

// ─── Tests ─────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_transport_encrypt_decrypt_roundtrip() {
        let dim = 8;
        let t = TransportMatrix::random(dim);
        assert!(t.verify_orthogonal(1e-10));

        let msg = DVector::from_fn(dim, |i, _| (i + 1) as f64);
        let cipher = t.encrypt(&msg);
        let recovered = t.decrypt(&cipher);

        let err = (&recovered - &msg).norm();
        assert!(err < 1e-10, "Roundtrip error: {}", err);
    }

    #[test]
    fn test_transport_preserves_norm() {
        let dim = 16;
        let t = TransportMatrix::random(dim);
        let msg = DVector::from_fn(dim, |i, _| (i as f64).sin());

        let cipher = t.encrypt(&msg);
        let norm_diff = (msg.norm() - cipher.norm()).abs();
        assert!(norm_diff < 1e-10, "Norm not preserved: diff={}", norm_diff);
    }

    #[test]
    fn test_path_hint_encrypt_decrypt() {
        let path = vec![0, 3, 1, 4, 2];
        let key = [42u8; 32];

        let encrypted = encrypt_path_hint(&path, &key);
        let recovered = decrypt_path_hint(&encrypted, &key);

        assert_eq!(path, recovered);
    }

    #[test]
    fn test_path_hint_wrong_key_fails() {
        let path = vec![0, 1, 2, 3];
        let key1 = [42u8; 32];
        let key2 = [99u8; 32];

        let encrypted = encrypt_path_hint(&path, &key1);
        let recovered = decrypt_path_hint(&encrypted, &key2);

        assert_ne!(path, recovered, "Wrong key should give wrong path");
    }

    #[test]
    fn test_transport_from_path() {
        let dim = 4;
        let edges = vec![(0, 1), (1, 2), (2, 3)];
        let cs = ConnectionSet::random(dim, &edges);

        let path = vec![0, 1, 2, 3];
        let t = TransportMatrix::from_path(&cs, &path);
        assert!(t.verify_orthogonal(1e-8));
    }

    #[test]
    fn test_full_onion_roundtrip() {
        let dim = 8;
        let n_relays = 3;

        // Set up relay infrastructure
        let edges_data = vec![
            vec![(0, 1), (1, 2), (2, 0)],
            vec![(0, 1), (1, 2), (2, 3)],
            vec![(0, 1), (1, 2)],
        ];
        let connections: Vec<ConnectionSet> = edges_data
            .iter()
            .map(|e| ConnectionSet::random(dim, e))
            .collect();
        let keys: Vec<[u8; 32]> = (0..n_relays)
            .map(|i| {
                let mut k = [0u8; 32];
                k[0] = i as u8;
                k
            })
            .collect();
        let n_vertices = vec![3, 4, 3];

        let conn_refs: Vec<&ConnectionSet> = connections.iter().collect();
        let edge_refs: Vec<&[(usize, usize)]> = edges_data.iter().map(|e| e.as_slice()).collect();

        // Create message
        let msg = DVector::from_fn(dim, |i, _| (i + 1) as f64 * 0.1);

        // Wrap in onion
        let mut packet =
            create_native_onion(&conn_refs, &keys, &edge_refs, &n_vertices, &msg).unwrap();

        assert_eq!(packet.layers.len(), n_relays);
        assert_eq!(packet.current_layer, 0);

        // Peel all layers
        let mut last_decrypted = None;
        for i in 0..n_relays {
            let (decrypted, is_final) =
                peel_native_onion(&mut packet, &connections[i], &keys[i]).unwrap();
            if is_final {
                last_decrypted = Some(decrypted);
            }
            assert_eq!(is_final, i == n_relays - 1);
        }

        // Final decrypted should match original message
        let recovered = last_decrypted.expect("Should have final output");
        let err = (&recovered - &msg).norm();
        assert!(
            err < 1e-6,
            "Onion roundtrip error: {} (expected < 1e-6)",
            err
        );
    }

    #[test]
    fn test_onion_composition_is_optic() {
        // Verify that composing transports = applying them in sequence
        // This is the categorical optic: lens composition
        let dim = 6;
        let t1 = TransportMatrix::random(dim);
        let t2 = TransportMatrix::random(dim);
        let t3 = TransportMatrix::random(dim);

        let msg = DVector::from_fn(dim, |i, _| (i as f64 + 1.0).sqrt());

        // Compose: wrap in order 3,2,1 (onion)
        let c1 = t3.encrypt(&msg);
        let c2 = t2.encrypt(&c1);
        let c3 = t1.encrypt(&c2);

        // Peel in order 1,2,3
        let p1 = t1.decrypt(&c3);
        let p2 = t2.decrypt(&p1);
        let p3 = t3.decrypt(&p2);

        let err = (&p3 - &msg).norm();
        assert!(err < 1e-10, "Optic composition error: {}", err);

        // Verify composition = matrix product
        let composed = &t1.q * &t2.q * &t3.q;
        let direct = composed * &msg;
        let direct_err = (&direct - &c3).norm();
        assert!(
            direct_err < 1e-10,
            "Composition should equal matrix product"
        );
    }
}
