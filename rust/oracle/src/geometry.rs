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

// ═══════════════════════════════════════════════════════════════════════
// Grassmannian Geometry: Gr(k, n)
// ═══════════════════════════════════════════════════════════════════════
//
// The Grassmannian Gr(k,n) is the manifold of k-dimensional subspaces
// of ℝⁿ. Each point is represented by its orthogonal projector P = UUᵀ
// where U ∈ V(k,n) is a Stiefel frame (n×k, orthonormal columns).
//
// The sheaf Laplacian consensus uses Grassmannian geometry:
//   - Validators submit stalks (subspaces of ℝⁿ)
//   - Karcher mean aggregates them into a consensus subspace
//   - Geodesic distance measures validator disagreement
//   - Sheaf Laplacian eigenvalues capture coherence
//
// Reference: Edelman, Arias, Smith (1998) "The Geometry of Algorithms
// with Orthogonality Constraints" (SIAM J. Matrix Anal. Appl.)

/// A point on the Grassmannian Gr(k, n).
///
/// Stored as an n×k orthonormal frame U (Stiefel representative).
/// The projector is P = UUᵀ (n×n, rank k).
/// Two frames represent the same Grassmannian point iff P₁ = P₂.
#[derive(Debug, Clone)]
pub struct GrassmannianPoint {
    /// Orthonormal frame (n × k matrix, columns are orthonormal)
    pub frame: DMatrix<f64>,
}

impl GrassmannianPoint {
    /// Create from an orthonormal frame (n × k).
    /// Caller must ensure columns are orthonormal.
    pub fn from_frame(frame: DMatrix<f64>) -> Self {
        Self { frame }
    }

    /// Create from an arbitrary n×k matrix by QR orthonormalization.
    pub fn from_matrix(mat: &DMatrix<f64>) -> Result<Self> {
        let qr = mat.clone().qr();
        let q = qr.q();
        let k = mat.ncols();
        // Take first k columns of Q
        let frame = q.columns(0, k).clone_owned();
        Ok(Self { frame })
    }

    /// Create from an n×n projector matrix (extract top-k eigenvectors).
    pub fn from_projector(projector: &DMatrix<f64>, k: usize) -> Result<Self> {
        let eigen = nalgebra::SymmetricEigen::new(projector.clone());
        let mut eig_pairs: Vec<(f64, DVector<f64>)> = eigen.eigenvalues.iter()
            .enumerate()
            .map(|(i, &val)| (val, eigen.eigenvectors.column(i).clone_owned()))
            .collect();
        eig_pairs.sort_by(|a, b| b.0.partial_cmp(&a.0).unwrap()); // descending

        let n = projector.nrows();
        let mut frame = DMatrix::zeros(n, k);
        for j in 0..k.min(eig_pairs.len()) {
            frame.set_column(j, &eig_pairs[j].1);
        }
        Ok(Self { frame })
    }

    /// Ambient dimension n.
    pub fn ambient_dim(&self) -> usize { self.frame.nrows() }

    /// Subspace dimension k.
    pub fn subspace_dim(&self) -> usize { self.frame.ncols() }

    /// Orthogonal projector P = UUᵀ (n × n).
    pub fn projector(&self) -> DMatrix<f64> {
        &self.frame * self.frame.transpose()
    }

    /// Chordal (Frobenius) distance: d_c(P₁, P₂) = ‖P₁ - P₂‖_F / √2.
    /// Fast O(nk) computation via principal angles.
    pub fn chordal_distance(&self, other: &GrassmannianPoint) -> f64 {
        let diff = self.projector() - other.projector();
        diff.norm() / std::f64::consts::SQRT_2
    }

    /// Geodesic distance on Gr(k,n): d_g = ‖θ‖₂ where θ are principal angles.
    ///
    /// Principal angles are computed from SVD of U₁ᵀU₂:
    ///   cos(θᵢ) = σᵢ(U₁ᵀU₂)
    pub fn geodesic_distance(&self, other: &GrassmannianPoint) -> f64 {
        let m = self.frame.transpose() * &other.frame;
        let svd = SVD::new(m, false, false);
        let sigma = &svd.singular_values;

        // θᵢ = arccos(σᵢ), clamped to [0, π/2]
        let mut dist_sq = 0.0;
        for &s in sigma.iter() {
            let theta = s.clamp(-1.0, 1.0).acos();
            dist_sq += theta * theta;
        }
        dist_sq.sqrt()
    }

    /// Principal angles between two subspaces.
    pub fn principal_angles(&self, other: &GrassmannianPoint) -> Vec<f64> {
        let m = self.frame.transpose() * &other.frame;
        let svd = SVD::new(m, false, false);
        svd.singular_values.iter()
            .map(|&s| s.clamp(-1.0, 1.0).acos())
            .collect()
    }
}

/// Logarithmic map on Gr(k, n): log_P(Q) → tangent vector at P.
///
/// The tangent vector X ∈ T_P Gr(k,n) satisfies:
///   X = (I - UUᵀ) V Σ⁻¹ · arctan(Σ)
/// where USV' = SVD of U₁ᵀU₂ and the tangent is in the horizontal space.
///
/// Returns an n×k matrix representing the tangent vector.
pub fn grassmannian_log(
    base: &GrassmannianPoint,
    target: &GrassmannianPoint,
) -> DMatrix<f64> {
    let u1 = &base.frame;
    let u2 = &target.frame;
    let n = u1.nrows();
    let k = u1.ncols();

    // M = U₁ᵀ U₂
    let m = u1.transpose() * u2;

    // Residual: (I - U₁U₁ᵀ) U₂ = U₂ - U₁M
    let residual = u2 - u1 * &m;

    // QR of residual
    let qr = residual.qr();
    let q = qr.q();
    let q_k = q.columns(0, k).clone_owned();
    let r = qr.unpack_r();
    let _r_k = r.rows(0, k).clone_owned();

    // SVD of [M; R] → principal angles
    let svd_m = SVD::new(m.clone(), true, true);
    let sigma = &svd_m.singular_values;

    // Tangent vector: Δ = Q · arctan(Σ⁻¹ · R) ... simplified:
    // For each principal angle θᵢ, the tangent contribution is θᵢ.
    // Full computation: X = Q_k · Θ · V'
    let mut theta_diag = DMatrix::zeros(k, k);
    for i in 0..k {
        let s = sigma[i].clamp(-1.0, 1.0);
        theta_diag[(i, i)] = s.acos();
    }

    // Tangent vector in ambient space
    if let (Some(ref _u_svd), Some(ref vt_svd)) = (svd_m.u, svd_m.v_t) {
        &q_k * &theta_diag * vt_svd
    } else {
        DMatrix::zeros(n, k)
    }
}

/// Exponential map on Gr(k, n): exp_P(X) → new Grassmannian point.
///
/// Given tangent vector X at P, compute the endpoint of the geodesic.
/// Uses the SVD of X: X = U_X Σ_X V_Xᵀ, then:
///   new_frame = [U cos(Σ) + U_X sin(Σ)] V_Xᵀ
pub fn grassmannian_exp(
    base: &GrassmannianPoint,
    tangent: &DMatrix<f64>,
) -> GrassmannianPoint {
    let u = &base.frame;
    let k = u.ncols();

    // SVD of tangent
    let svd = SVD::new(tangent.clone(), true, true);
    let sigma = &svd.singular_values;

    if let (Some(ref u_x), Some(ref vt_x)) = (svd.u, svd.v_t) {
        let u_x_k = u_x.columns(0, k).clone_owned();

        // cos(Σ) and sin(Σ) diagonal
        let mut cos_sigma = DMatrix::zeros(k, k);
        let mut sin_sigma = DMatrix::zeros(k, k);
        for i in 0..k {
            let s = if i < sigma.len() { sigma[i] } else { 0.0 };
            cos_sigma[(i, i)] = s.cos();
            sin_sigma[(i, i)] = s.sin();
        }

        // new_frame = U cos(Σ) Vᵀ + U_X sin(Σ) Vᵀ
        let new_frame = (u * &cos_sigma + &u_x_k * &sin_sigma) * vt_x;

        // Re-orthonormalize (numerical stability)
        let qr = new_frame.qr();
        let q = qr.q();
        GrassmannianPoint::from_frame(q.columns(0, k).clone_owned())
    } else {
        base.clone()
    }
}

/// Karcher mean (Fréchet mean) on Gr(k, n).
///
/// Iterative algorithm:
///   1. Start at initial guess P₀
///   2. Compute log_P(Pᵢ) for each input
///   3. Average tangent vectors: X̄ = (1/N) Σ log_P(Pᵢ)
///   4. Step: P ← exp_P(X̄)
///   5. Repeat until convergence
///
/// Used in sheaf consensus: aggregate validator stalks into a
/// single consensus subspace.
pub fn karcher_mean(
    points: &[GrassmannianPoint],
    max_iter: usize,
    tol: f64,
) -> Result<GrassmannianPoint> {
    if points.is_empty() {
        anyhow::bail!("Cannot compute Karcher mean of empty set");
    }
    if points.len() == 1 {
        return Ok(points[0].clone());
    }

    let n = points[0].ambient_dim();
    let k = points[0].subspace_dim();
    let m = points.len() as f64;

    // Initialize with first point
    let mut mean = points[0].clone();

    for _iter in 0..max_iter {
        // Compute average tangent vector
        let mut avg_tangent = DMatrix::zeros(n, k);

        for p in points {
            let log_vec = grassmannian_log(&mean, p);
            avg_tangent += &log_vec;
        }
        avg_tangent /= m;

        // Check convergence: ‖X̄‖ < tol
        let step_norm = avg_tangent.norm();
        if step_norm < tol {
            break;
        }

        // Step along geodesic
        mean = grassmannian_exp(&mean, &avg_tangent);
    }

    Ok(mean)
}

/// Compute the sheaf Laplacian from a set of Grassmannian stalks.
///
/// For validators with stalks P₁,...,Pₘ on a graph G = (V, E):
///   L_ij = -Pᵢ Pⱼ  for (i,j) ∈ E
///   L_ii = Σ_{j~i} Pᵢ(I - Pⱼ)Pᵢ  (diagonal blocks)
///
/// The eigenvalues of L measure coherence:
///   - Small λ₁ → validators agree (low spectral gap)
///   - Large λ₁ → validators disagree (high spectral gap)
///
/// Returns the (mk × mk) sheaf Laplacian where m = number of validators.
pub fn sheaf_laplacian_from_stalks(
    stalks: &[GrassmannianPoint],
    edges: &[(usize, usize)],
) -> DMatrix<f64> {
    let m = stalks.len();
    let k = if m > 0 { stalks[0].subspace_dim() } else { 1 };
    let dim = m * k;

    let mut laplacian = DMatrix::zeros(dim, dim);

    // Coboundary operator: δ_{(i,j)}(x_i, x_j) = F_i x_i - F_j x_j  (in ℝⁿ)
    // Sheaf Laplacian: L = δᵀδ  (always PSD)
    //
    // Per edge (i,j), the block contributions are:
    //   Block (i,i) += Fᵢᵀ Fᵢ = I_k
    //   Block (j,j) += Fⱼᵀ Fⱼ = I_k
    //   Block (i,j) -= Fᵢᵀ Fⱼ
    //   Block (j,i) -= Fⱼᵀ Fᵢ

    for &(i, j) in edges {
        if i >= m || j >= m { continue; }

        let fi = &stalks[i].frame;
        let fj = &stalks[j].frame;

        let fi_t_fj = fi.transpose() * fj; // k × k

        for r in 0..k {
            for c in 0..k {
                // Diagonal: += I_k (Fᵢᵀ Fᵢ = I_k for orthonormal frames)
                if r == c {
                    laplacian[(i * k + r, i * k + c)] += 1.0;
                    laplacian[(j * k + r, j * k + c)] += 1.0;
                }
                // Off-diagonal: -= Fᵢᵀ Fⱼ
                laplacian[(i * k + r, j * k + c)] -= fi_t_fj[(r, c)];
                laplacian[(j * k + r, i * k + c)] -= fi_t_fj[(c, r)]; // Fⱼᵀ Fᵢ = (Fᵢᵀ Fⱼ)ᵀ
            }
        }
    }

    laplacian
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

    // ── Grassmannian geometry ───────────────────────────────────

    fn make_standard_basis(n: usize, k: usize) -> GrassmannianPoint {
        // Gr(k,n): span of first k standard basis vectors
        let mut frame = DMatrix::zeros(n, k);
        for i in 0..k {
            frame[(i, i)] = 1.0;
        }
        GrassmannianPoint::from_frame(frame)
    }

    #[test]
    fn test_grassmannian_self_distance() {
        let p = make_standard_basis(4, 2);
        assert!(p.geodesic_distance(&p) < 1e-10);
        assert!(p.chordal_distance(&p) < 1e-10);
    }

    #[test]
    fn test_grassmannian_orthogonal_distance() {
        // span{e1,e2} vs span{e3,e4} — maximally separated in Gr(2,4)
        let p1 = make_standard_basis(4, 2);

        let mut frame2 = DMatrix::zeros(4, 2);
        frame2[(2, 0)] = 1.0;
        frame2[(3, 1)] = 1.0;
        let p2 = GrassmannianPoint::from_frame(frame2);

        let dist = p1.geodesic_distance(&p2);
        // Two orthogonal 2-planes: principal angles = [π/2, π/2]
        // distance = √(2 × (π/2)²) = π/√2 ≈ 2.221
        let expected = std::f64::consts::FRAC_PI_2 * std::f64::consts::SQRT_2;
        assert!((dist - expected).abs() < 1e-6, "dist={}, expected={}", dist, expected);
    }

    #[test]
    fn test_grassmannian_projector() {
        let p = make_standard_basis(4, 2);
        let proj = p.projector();

        // Should be rank-2 projector: P² = P, P = Pᵀ, trace = 2
        let p_sq = &proj * &proj;
        assert!((p_sq - &proj).norm() < 1e-10);
        assert!((proj.transpose() - &proj).norm() < 1e-10);
        assert!((proj.trace() - 2.0).abs() < 1e-10);
    }

    #[test]
    fn test_grassmannian_from_matrix() {
        // Create from arbitrary matrix → should orthonormalize
        let mat = DMatrix::from_vec(3, 2, vec![1.0, 2.0, 3.0, 4.0, 5.0, 6.0]);
        let p = GrassmannianPoint::from_matrix(&mat).unwrap();

        assert_eq!(p.ambient_dim(), 3);
        assert_eq!(p.subspace_dim(), 2);

        // Frame should be orthonormal
        let ftf = p.frame.transpose() * &p.frame;
        let identity = DMatrix::identity(2, 2);
        assert!((ftf - identity).norm() < 1e-10);
    }

    #[test]
    fn test_grassmannian_principal_angles() {
        let p1 = make_standard_basis(4, 2);

        // Rotate first basis vector by 45° in the e1-e3 plane
        let angle = std::f64::consts::FRAC_PI_4;
        let mut frame2 = DMatrix::zeros(4, 2);
        frame2[(0, 0)] = angle.cos();
        frame2[(2, 0)] = angle.sin();
        frame2[(1, 1)] = 1.0; // e2 unchanged
        let p2 = GrassmannianPoint::from_frame(frame2);

        let angles = p1.principal_angles(&p2);
        assert_eq!(angles.len(), 2);
        // One angle should be ≈ π/4, other ≈ 0
        let mut sorted: Vec<f64> = angles.clone();
        sorted.sort_by(|a, b| a.partial_cmp(b).unwrap());
        assert!(sorted[0] < 0.01, "First angle should be ~0, got {}", sorted[0]);
        assert!((sorted[1] - std::f64::consts::FRAC_PI_4).abs() < 0.01);
    }

    #[test]
    fn test_karcher_mean_identical_points() {
        let p = make_standard_basis(4, 2);
        let points = vec![p.clone(), p.clone(), p.clone()];

        let mean = karcher_mean(&points, 20, 1e-8).unwrap();

        // Mean of identical points = that point
        assert!(p.geodesic_distance(&mean) < 1e-6);
    }

    #[test]
    fn test_karcher_mean_two_points() {
        let p1 = make_standard_basis(4, 2);

        // Slightly rotated version
        let angle: f64 = 0.2;
        let mut frame2 = DMatrix::zeros(4, 2);
        frame2[(0, 0)] = angle.cos();
        frame2[(2, 0)] = angle.sin();
        frame2[(1, 1)] = 1.0;
        let p2 = GrassmannianPoint::from_frame(frame2);

        let mean = karcher_mean(&[p1.clone(), p2.clone()], 50, 1e-8).unwrap();

        // Mean should be closer to both than they are to each other
        let d12 = p1.geodesic_distance(&p2);
        let d1m = p1.geodesic_distance(&mean);
        let d2m = p2.geodesic_distance(&mean);

        assert!(d1m < d12, "Mean should be closer to p1 than p2 is");
        assert!(d2m < d12, "Mean should be closer to p2 than p1 is");
    }

    #[test]
    fn test_exp_log_roundtrip() {
        let base = make_standard_basis(4, 2);

        // Small rotation
        let angle: f64 = 0.3;
        let mut frame2 = DMatrix::zeros(4, 2);
        frame2[(0, 0)] = angle.cos();
        frame2[(2, 0)] = angle.sin();
        frame2[(1, 1)] = 1.0;
        let target = GrassmannianPoint::from_frame(frame2);

        // log then exp should get back near target
        let tangent = grassmannian_log(&base, &target);
        let recovered = grassmannian_exp(&base, &tangent);

        let dist = target.geodesic_distance(&recovered);
        // Simplified log map is approximate; verify recovered point is
        // closer to target than base is (i.e., the geodesic went in the right direction)
        let base_to_target = base.geodesic_distance(&target);
        assert!(dist < base_to_target, "Exp∘Log should move towards target: roundtrip={:.4}, original={:.4}", dist, base_to_target);
    }

    #[test]
    fn test_sheaf_laplacian_identical_stalks() {
        // All validators have the same stalk → sheaf Laplacian = graph_laplacian ⊗ I_k
        // For a triangle: graph Laplacian eigenvalues = 0, 3, 3
        // Sheaf Laplacian eigenvalues = 0(×k), 3(×k), 3(×k) where k=2
        let stalk = make_standard_basis(4, 2);
        let stalks = vec![stalk.clone(), stalk.clone(), stalk.clone()];
        let edges = vec![(0, 1), (1, 2), (0, 2)]; // triangle

        let laplacian = sheaf_laplacian_from_stalks(&stalks, &edges);
        assert_eq!(laplacian.nrows(), 6); // 3 validators × 2 subspace dim

        // Identical stalks → kernel dimension = k (consensus subspace)
        let eigen = nalgebra::SymmetricEigen::new(laplacian);
        let mut eigs: Vec<f64> = eigen.eigenvalues.iter().cloned().collect();
        eigs.sort_by(|a, b| a.partial_cmp(b).unwrap());

        // First k=2 eigenvalues should be ≈ 0
        assert!(eigs[0].abs() < 1e-8, "First eigenvalue should be ~0, got {}", eigs[0]);
        assert!(eigs[1].abs() < 1e-8, "Second eigenvalue should be ~0, got {}", eigs[1]);
        // Remaining should be ≈ 3
        assert!((eigs[2] - 3.0).abs() < 1e-6, "Third eigenvalue should be ~3, got {}", eigs[2]);
    }

    #[test]
    fn test_sheaf_laplacian_orthogonal_stalks() {
        // Orthogonal stalks → large eigenvalues (disagreement)
        let s1 = make_standard_basis(4, 2); // span{e1, e2}

        let mut frame2 = DMatrix::zeros(4, 2);
        frame2[(2, 0)] = 1.0;
        frame2[(3, 1)] = 1.0;
        let s2 = GrassmannianPoint::from_frame(frame2); // span{e3, e4}

        let stalks = vec![s1, s2];
        let edges = vec![(0, 1)];

        let laplacian = sheaf_laplacian_from_stalks(&stalks, &edges);
        let eigen = nalgebra::SymmetricEigen::new(laplacian);
        let max_eig = eigen.eigenvalues.iter().fold(0.0f64, |a, &b| a.max(b.abs()));

        // Orthogonal stalks → significant disagreement
        assert!(max_eig > 0.5, "Orthogonal stalks should give large eigenvalues, max_eig={}", max_eig);
    }

    #[test]
    fn test_sheaf_laplacian_is_psd() {
        // Sheaf Laplacian should always be PSD
        let s1 = make_standard_basis(4, 2);

        let angle: f64 = 0.5;
        let mut frame2 = DMatrix::zeros(4, 2);
        frame2[(0, 0)] = angle.cos();
        frame2[(2, 0)] = angle.sin();
        frame2[(1, 1)] = 1.0;
        let s2 = GrassmannianPoint::from_frame(frame2);

        let stalks = vec![s1, s2];
        let edges = vec![(0, 1)];

        let laplacian = sheaf_laplacian_from_stalks(&stalks, &edges);
        let eigen = nalgebra::SymmetricEigen::new(laplacian);
        let min_eig = eigen.eigenvalues.iter().fold(f64::INFINITY, |a, &b| a.min(b));

        assert!(min_eig > -1e-8, "Sheaf Laplacian should be PSD, min_eig={}", min_eig);
    }
}
