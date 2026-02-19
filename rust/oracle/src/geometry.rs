// Geometry Module - Parallel Transport & Hodge Projection
//
// Translation of Python geometry primitives to Rust.
// These implement the core homotopical encryption operations:
// - Parallel transport (fiber bundle connection)
// - Harmonic projection (Hodge decomposition)

use anyhow::Result;
use nalgebra::{DMatrix, DVector, SVD};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Connection on fiber bundle: edge → transport matrix
pub type Connection = HashMap<(u64, u64), DMatrix<f64>>;

/// Fiber bundle with parallel transport capability
#[derive(Debug, Clone)]
pub struct FiberBundle {
    /// Nerve structure: dimension → simplices
    pub nerve: HashMap<i32, Vec<Vec<u64>>>,
    
    /// Fiber dimension (e.g., 512 = DEFAULT_STALK_DIM from credential.py)
    pub fiber_dim: usize,
    
    /// Connection matrices along edges
    pub connection: Connection,
}

impl FiberBundle {
    pub fn new(nerve: HashMap<i32, Vec<Vec<u64>>>, fiber_dim: usize) -> Self {
        Self {
            nerve,
            fiber_dim,
            connection: HashMap::new(),
        }
    }
    
    /// Set connection (transport matrix) along an edge
    pub fn set_connection(&mut self, v0: u64, v1: u64, matrix: DMatrix<f64>) {
        // Store in canonical order (smaller first)
        let edge = if v0 < v1 { (v0, v1) } else { (v1, v0) };
        self.connection.insert(edge, matrix);
    }
    
    /// Get connection along an edge (identity if not set)
    pub fn get_connection(&self, v0: u64, v1: u64) -> DMatrix<f64> {
        let edge = if v0 < v1 { (v0, v1) } else { (v1, v0) };
        self.connection
            .get(&edge)
            .cloned()
            .unwrap_or_else(|| DMatrix::identity(self.fiber_dim, self.fiber_dim))
    }
    
    /// Parallel transport vector along path
    /// 
    /// Translates from Python: FiberBundle.parallel_transport()
    pub fn parallel_transport(&self, vector: &DVector<f64>, path: &[u64]) -> DVector<f64> {
        let mut current = vector.clone();
        
        for i in 0..path.len().saturating_sub(1) {
            let transport = self.get_connection(path[i], path[i + 1]);
            current = &transport * &current;
        }
        
        current
    }
    
    /// Inverse transport (undo parallel transport)
    /// For orthogonal connections, inverse = transpose
    pub fn inverse_transport(&self, vector: &DVector<f64>, path: &[u64]) -> DVector<f64> {
        let mut current = vector.clone();
        
        // Walk path in reverse
        for i in (1..path.len()).rev() {
            let transport = self.get_connection(path[i], path[i - 1]);
            // Inverse of orthogonal matrix = transpose
            current = transport.transpose() * &current;
        }
        
        current
    }
    
    /// Compute holonomy around a closed loop
    pub fn holonomy(&self, loop_path: &[u64]) -> Result<DMatrix<f64>> {
        if loop_path.first() != loop_path.last() {
            anyhow::bail!("Loop must be closed");
        }
        
        let mut result = DMatrix::identity(self.fiber_dim, self.fiber_dim);
        
        for i in 0..loop_path.len().saturating_sub(1) {
            let transport = self.get_connection(loop_path[i], loop_path[i + 1]);
            result = &transport * &result;
        }
        
        Ok(result)
    }
}

/// Hodge decomposition and harmonic projection
pub struct HodgeProjector {
    /// Laplacian matrix Δ = δ*δ + δδ*
    laplacian: DMatrix<f64>,
    
    /// Harmonic subspace basis (ker Δ)
    harmonic_basis: Vec<DVector<f64>>,
    
    /// Tolerance for zero eigenvalues
    tol: f64,
}

impl HodgeProjector {
    /// Create projector from Laplacian matrix
    pub fn new(laplacian: DMatrix<f64>, tol: f64) -> Result<Self> {
        let n = laplacian.nrows();
        
        // Eigendecomposition to find harmonic subspace
        let svd = SVD::new(laplacian.clone(), true, true);
        let singular_values = &svd.singular_values;
        let v = svd.v_t.as_ref()
            .ok_or_else(|| anyhow::anyhow!("SVD failed"))?
            .transpose();
        
        // Harmonic basis = eigenvectors with eigenvalue ≈ 0
        let mut harmonic_basis = Vec::new();
        for i in 0..n {
            if singular_values[i].abs() < tol {
                harmonic_basis.push(v.column(i).clone_owned());
            }
        }
        
        Ok(Self {
            laplacian,
            harmonic_basis,
            tol,
        })
    }
    
    /// Project vector onto harmonic subspace ker(Δ)
    /// 
    /// This is the COMMITMENT operation:
    /// Full credential → harmonic projection (compact commitment)
    pub fn project_to_harmonic(&self, vector: &DVector<f64>) -> DVector<f64> {
        let mut projection = DVector::zeros(vector.len());
        
        // Project onto each basis vector
        for basis in &self.harmonic_basis {
            let coeff = vector.dot(basis);
            projection += coeff * basis;
        }
        
        projection
    }
    
    /// Quantize projection to fixed-size bytes
    /// 
    /// Deterministic: same projection → same bytes always
    pub fn quantize_to_bytes(&self, projection: &DVector<f64>, num_bytes: usize) -> Vec<u8> {
        let mut bytes = Vec::with_capacity(num_bytes);
        
        // Take first `num_bytes` components, quantize to bytes
        for i in 0..num_bytes.min(projection.len()) {
            // Scale to [0, 255]
            let val = projection[i];
            let normalized = ((val + 1.0) / 2.0 * 255.0).clamp(0.0, 255.0) as u8;
            bytes.push(normalized);
        }
        
        // Pad with zeros if needed
        while bytes.len() < num_bytes {
            bytes.push(0);
        }
        
        bytes
    }
    
    /// Get dimension of harmonic subspace (= β₀)
    pub fn harmonic_dim(&self) -> usize {
        self.harmonic_basis.len()
    }
    
    /// Get spectral gap (smallest nonzero eigenvalue)
    pub fn spectral_gap(&self) -> f64 {
        let svd = SVD::new(self.laplacian.clone(), false, false);
        let singular_values = &svd.singular_values;
        
        // Find smallest value > tolerance
        singular_values
            .iter()
            .filter(|&&v| v > self.tol)
            .min_by(|a, b| a.partial_cmp(b).unwrap())
            .copied()
            .unwrap_or(0.0)
    }
}

/// Stalk: local data at a vertex (translates Python Stalk)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Stalk {
    /// Stalk dimension
    pub dimension: usize,
    
    /// Data vector
    pub data: Vec<f64>,
    
    /// Vertex ID in nerve
    pub vertex_id: Option<u64>,
}

impl Stalk {
    pub fn new(dimension: usize, data: Vec<f64>) -> Result<Self> {
        if data.len() != dimension {
            anyhow::bail!("Data length {} != dimension {}", data.len(), dimension);
        }
        Ok(Self {
            dimension,
            data,
            vertex_id: None,
        })
    }
    
    pub fn with_vertex(mut self, vertex_id: u64) -> Self {
        self.vertex_id = Some(vertex_id);
        self
    }
    
    pub fn to_dvector(&self) -> DVector<f64> {
        DVector::from_vec(self.data.clone())
    }
    
    pub fn from_dvector(dv: DVector<f64>) -> Self {
        Self {
            dimension: dv.len(),
            data: dv.data.as_vec().clone(),
            vertex_id: None,
        }
    }
}

/// Transport a Stalk along a path (uses FiberBundle)
pub fn transport_stalk(
    bundle: &FiberBundle,
    stalk: &Stalk,
    path: &[u64],
) -> Stalk {
    let transported = bundle.parallel_transport(&stalk.to_dvector(), path);
    Stalk::from_dvector(transported)
        .with_vertex(*path.last().unwrap_or(&0))
}

/// Compute geometric commitment (harmonic projection)
/// 
/// This replaces SHA256 hashing with our Hodge-based commitment:
/// credential → transport → project to ker(Δ) → quantize
pub fn compute_geometric_commitment(
    bundle: &FiberBundle,
    stalk: &Stalk,
    projector: &HodgeProjector,
    path: &[u64],
    commitment_bytes: usize,
) -> Vec<u8> {
    // 1. Transport stalk along path
    let transported = bundle.parallel_transport(&stalk.to_dvector(), path);
    
    // 2. Project to harmonic subspace
    let harmonic = projector.project_to_harmonic(&transported);
    
    // 3. Quantize to bytes
    projector.quantize_to_bytes(&harmonic, commitment_bytes)
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_parallel_transport() {
        let mut bundle = FiberBundle::new(HashMap::new(), 3);
        
        // Set identity connection (flat bundle)
        bundle.set_connection(0, 1, DMatrix::identity(3, 3));
        bundle.set_connection(1, 2, DMatrix::identity(3, 3));
        
        let vector = DVector::from_vec(vec![1.0, 2.0, 3.0]);
        let path = vec![0, 1, 2];
        
        let transported = bundle.parallel_transport(&vector, &path);
        
        // Identity connection should preserve vector
        assert!((transported - vector).norm() < 1e-10);
    }
    
    #[test]
    fn test_hodge_projection() {
        // Simple 3x3 Laplacian with 1D harmonic subspace
        let laplacian = DMatrix::from_vec(3, 3, vec![
            2.0, -1.0, -1.0,
            -1.0, 2.0, -1.0,
            -1.0, -1.0, 2.0,
        ]);
        
        let projector = HodgeProjector::new(laplacian, 1e-6).unwrap();
        
        // Harmonic subspace = constant vectors (β₀ = 1)
        assert_eq!(projector.harmonic_dim(), 1);
    }
    
    #[test]
    fn test_geometric_commitment() {
        let mut bundle = FiberBundle::new(HashMap::new(), 4);
        bundle.set_connection(0, 1, DMatrix::identity(4, 4));

        let laplacian = DMatrix::from_fn(4, 4, |i, j| {
            if i == j { 2.0 } else if (i as i32 - j as i32).abs() == 1 { -1.0 } else { 0.0 }
        });

        let projector = HodgeProjector::new(laplacian, 1e-6).unwrap();

        let stalk = Stalk::new(4, vec![1.0, 2.0, 3.0, 4.0]).unwrap();
        let path = vec![0, 1];

        let commitment = compute_geometric_commitment(
            &bundle, &stalk, &projector, &path, 32
        );

        assert_eq!(commitment.len(), 32);

        // Determinism: same input → same output
        let commitment2 = compute_geometric_commitment(
            &bundle, &stalk, &projector, &path, 32
        );
        assert_eq!(commitment, commitment2);
    }

    // ── Holonomy (curvature of fiber bundle) ────────────────────

    #[test]
    fn test_holonomy_flat_bundle() {
        // Flat bundle (identity connections) → holonomy = identity
        let mut bundle = FiberBundle::new(HashMap::new(), 3);
        bundle.set_connection(0, 1, DMatrix::identity(3, 3));
        bundle.set_connection(1, 2, DMatrix::identity(3, 3));
        bundle.set_connection(2, 0, DMatrix::identity(3, 3));

        let loop_path = vec![0, 1, 2, 0];
        let holonomy = bundle.holonomy(&loop_path).unwrap();

        // Identity → no curvature
        let identity = DMatrix::identity(3, 3);
        assert!((holonomy - identity).norm() < 1e-10);
    }

    #[test]
    fn test_holonomy_curved_bundle() {
        // Triangle with non-identity connection → nontrivial holonomy (curvature)
        let mut bundle = FiberBundle::new(HashMap::new(), 2);

        // Rotation by 90° on edge 0→1, identity elsewhere
        let rot = DMatrix::from_vec(2, 2, vec![0.0, 1.0, -1.0, 0.0]);
        bundle.set_connection(0, 1, rot);                           // curvature here
        bundle.set_connection(1, 2, DMatrix::identity(2, 2));       // flat
        bundle.set_connection(0, 2, DMatrix::identity(2, 2));       // flat

        // Loop 0 → 1 → 2 → 0: picks up rotation from edge (0,1)
        let loop_path = vec![0, 1, 2, 0];
        let holonomy = bundle.holonomy(&loop_path).unwrap();

        let identity = DMatrix::identity(2, 2);
        assert!((holonomy - identity).norm() > 0.1, "Curved bundle must have nontrivial holonomy");
    }

    // ── Inverse transport ───────────────────────────────────────

    #[test]
    fn test_inverse_transport_roundtrip() {
        let mut bundle = FiberBundle::new(HashMap::new(), 3);
        bundle.set_connection(0, 1, DMatrix::identity(3, 3));
        bundle.set_connection(1, 2, DMatrix::identity(3, 3));

        let v = DVector::from_vec(vec![1.0, 2.0, 3.0]);
        let path = vec![0, 1, 2];

        let forward = bundle.parallel_transport(&v, &path);
        let backward = bundle.inverse_transport(&forward, &path);

        // Roundtrip: forward then inverse = original
        assert!((backward - &v).norm() < 1e-10);
    }

    // ── Spectral properties ─────────────────────────────────────

    #[test]
    fn test_spectral_gap() {
        // 3×3 graph Laplacian: triangle has eigenvalues 0, 3, 3
        let laplacian = DMatrix::from_vec(3, 3, vec![
            2.0, -1.0, -1.0,
            -1.0, 2.0, -1.0,
            -1.0, -1.0, 2.0,
        ]);

        let projector = HodgeProjector::new(laplacian, 1e-6).unwrap();

        // Spectral gap = first nonzero eigenvalue = 3.0
        assert!((projector.spectral_gap() - 3.0).abs() < 1e-6);
    }

    #[test]
    fn test_harmonic_projection_preserves_harmonic() {
        let laplacian = DMatrix::from_vec(3, 3, vec![
            2.0, -1.0, -1.0,
            -1.0, 2.0, -1.0,
            -1.0, -1.0, 2.0,
        ]);

        let projector = HodgeProjector::new(laplacian, 1e-6).unwrap();

        // Constant vector is in ker(Δ) — harmonic
        let harmonic = DVector::from_vec(vec![1.0, 1.0, 1.0]);
        let projected = projector.project_to_harmonic(&harmonic);

        // Should preserve direction (project onto normalized constant vector)
        // All components should be equal
        let ratio = projected[0];
        assert!((projected[1] - ratio).abs() < 1e-10);
        assert!((projected[2] - ratio).abs() < 1e-10);
    }

    #[test]
    fn test_quantize_deterministic() {
        let laplacian = DMatrix::from_fn(4, 4, |i, j| {
            if i == j { 2.0 } else if (i as i32 - j as i32).abs() == 1 { -1.0 } else { 0.0 }
        });

        let projector = HodgeProjector::new(laplacian, 1e-6).unwrap();

        let v = DVector::from_vec(vec![1.0, 2.0, 3.0, 4.0]);
        let proj = projector.project_to_harmonic(&v);

        let bytes1 = projector.quantize_to_bytes(&proj, 32);
        let bytes2 = projector.quantize_to_bytes(&proj, 32);
        assert_eq!(bytes1.len(), 32);
        assert_eq!(bytes1, bytes2); // deterministic
    }

    #[test]
    fn test_commitment_changes_with_input() {
        // Use triangle Laplacian (valid graph Laplacian: rows sum to 0 → has ker(Δ))
        // Previous test used tridiagonal [2,-1,0;-1,2,-1;0,-1,2] which is NOT
        // a graph Laplacian (rows don't sum to 0 → no harmonic subspace → all
        // projections are zero → all commitments identical regardless of input).
        //
        // Python computes the real Laplacian from the sheaf (SheafLaplacian.get_laplacian_0).
        // The Oracle receives it pre-computed. This test validates the commitment is
        // binding when the Laplacian actually has a harmonic subspace.
        let mut bundle = FiberBundle::new(HashMap::new(), 3);
        bundle.set_connection(0, 1, DMatrix::identity(3, 3));

        // Triangle Laplacian: eigenvalues 0, 3, 3 → 1D harmonic subspace (constant vectors)
        let laplacian = DMatrix::from_vec(3, 3, vec![
            2.0, -1.0, -1.0,
            -1.0, 2.0, -1.0,
            -1.0, -1.0, 2.0,
        ]);

        let projector = HodgeProjector::new(laplacian, 1e-6).unwrap();
        assert_eq!(projector.harmonic_dim(), 1);
        let path = vec![0, 1];

        // Stalks with different sums → different harmonic projections (different constant component)
        let s1 = Stalk::new(3, vec![0.1, 0.1, 0.1]).unwrap();   // sum=0.3
        let s2 = Stalk::new(3, vec![0.5, 0.5, 0.5]).unwrap();   // sum=1.5

        let c1 = compute_geometric_commitment(&bundle, &s1, &projector, &path, 32);
        let c2 = compute_geometric_commitment(&bundle, &s2, &projector, &path, 32);

        // Different harmonic projections → different quantized bytes → binding
        assert_ne!(c1, c2);
    }
}
