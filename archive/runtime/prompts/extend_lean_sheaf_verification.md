# Prompt: Extend Lean Formalization to Sheaf Storage / Geometric / Functorial Construction

## Context

We have a formally verified Lean 4 + Mathlib file (`framework_consolidation.lean`) proving the cryptographic hardness hierarchy for homotopical-encrypt:

**Already proven:**
1. `Hodge_Decomposition_Theorem` — any cochain decomposes into harmonic + exact + coexact, mutually orthogonal
2. `Hodge_Hardness_Reduction` — breaking Hodge ⟹ solving CVP (lattice problem is a projection)
3. `Hodge_Ambiguity` — same ciphertext under different Laplacians means different things (spectral gap is private key material)
4. `Hodge_Strictly_Harder` — CVP oracle insufficient to solve Hodge problem
5. `Spectrum_Not_Homotopy_Invariant` — spectral fingerprint is NOT a homotopy invariant (two homotopy-equivalent Laplacians can have different spectra)
6. `GrothendieckFibration` — Cartesian morphism lifting, `FibrationCopy`, `copy_equivalent_thm`

**NOT yet formalized** but implemented in the codebase and relied on for security:

The sheaf-theoretic storage layer, geometric constructions, and functorial properties that the chain actually uses. These are the **preconditions** the existing hardness proof assumes but doesn't verify.

## What to Formalize

Extend `framework_consolidation.lean` with the following sections. Each corresponds to code that exists in the repository.

### 1. Cellular Sheaf Structure (`src/geometry/sheaf.py`)

Define a `CellularSheaf` over a finite simplicial complex (nerve):
- Stalks: `F(σ) : Type` for each cell σ (finite-dimensional ℝ-vector spaces)
- Restriction maps: `ρ_{σ,τ} : F(σ) → F(τ)` for each face relation σ ⊇ τ (linear maps)

**Prove functoriality:**
```
∀ σ τ υ, σ ⊇ τ ⊇ υ → ρ_{σ,υ} = ρ_{τ,υ} ∘ ρ_{σ,τ}   -- composition
∀ σ, ρ_{σ,σ} = id                                         -- identity
```

This matches `sheaf.py`'s `set_restriction` / `get_restriction` and the naturality checks in `rust/oracle/src/stalk_bridge.rs::verify_naturality_for_edge`.

### 2. Coboundary and Sheaf Laplacian (`src/geometry/sheaf_laplacian.py`)

Define the sheaf coboundary operator δ₀: C⁰(F) → C¹(F) by:
```
(δ₀ c)(e) = ρ_{e,v}(c(v)) - ρ_{e,u}(c(u))   for edge e = (u,v)
```

where ρ are the restriction maps from the sheaf.

**Prove:**
- `Sheaf_Laplacian_Is_Self_Adjoint`: Δ₀ = δ₀* ∘ δ₀ is symmetric (self-adjoint)
- `Sheaf_Laplacian_Is_PSD`: Δ₀ is positive semi-definite (⟨Δv, v⟩ ≥ 0 for all v)
- `Sheaf_Laplacian_Kernel_Characterization`: v ∈ ker(Δ₀) iff ρ_{e,v}(c(v)) = ρ_{e,u}(c(u)) for all edges — i.e., kernel elements are exactly the **global sections** that agree on overlaps

This is the sheaf-theoretic generalization of the graph Laplacian. The existing `Hodge_Decomposition_Theorem` uses abstract matrices; this section grounds it in the actual sheaf structure the code constructs.

### 3. Gluing Axiom / H¹ Obstruction (`rust/oracle/src/stalk_bridge.rs`)

The Oracle checks `H¹ = 0` as a gluing condition:

**Prove:**
- `Gluing_Iff_H1_Zero`: A family of local sections {s_v ∈ F(v)} glues to a global section iff H¹(nerve, F) = 0
- `Gluing_Obstruction_Is_Cocycle`: The disagreements ρ_{e,v}(s_v) - ρ_{e,u}(s_u) form a 1-cocycle, and it's a coboundary iff gluing succeeds

This matches `stalk_bridge.rs::check_gluing_obstruction()` which returns `Ok(true)` when H¹ vanishes.

### 4. Cochain Commitment Binding from ker(δ) (`src/crypto/commitment.py`)

The commitment scheme uses `Commit(m) = δ(m ∥ r)`:

**Prove:**
- `Cochain_Commitment_Binding`: Finding m₁ ≠ m₂ with δ(m₁∥r₁) = δ(m₂∥r₂) requires finding a nonzero element of ker(δ), which is SVP-hard when the coboundary lattice has appropriate dimension
- `Cochain_Commitment_Homomorphic`: δ(m₁∥r₁) + δ(m₂∥r₂) = δ((m₁+m₂)∥(r₁+r₂)) — linearity of δ gives additive homomorphism

This grounds the `Block.compute_cochain_root()` accumulation in `rust/node/src/types.rs`.

### 5. Parallel Transport Preserves Norms (`src/geometry/fiber_bundle.py`)

The fiber bundle uses orthogonal connection matrices:

**Prove:**
- `Orthogonal_Transport_Preserves_Norm`: If all transition matrices are orthogonal (R ∈ O(n)), then ‖T_{path}(v)‖ = ‖v‖
- `Transport_Inverse_Roundtrip`: T_{path}(T_{path⁻¹}(v)) = v for any path and its reverse
- `Holonomy_Is_Orthogonal`: The holonomy around any loop is an orthogonal matrix

This matches `fiber_bundle.py::parallel_transport` and `holonomy`, and the property that transport preserves the inner product structure needed for Hodge decomposition.

### 6. Storage Correctness (`rust/node/src/storage/sheaf_store.rs`)

The sheaf store separates data by `StalkContext` (Public, Private, Zk):

**Prove (as a specification):**
- `Context_Isolation`: Stalks stored under different contexts are independent — `get_stalk(Zk, v)` never leaks data from `get_stalk(Private, v)`
- `Section_Consistency`: `set_section` followed by `get_section` returns a family satisfying the naturality condition checked by `verify_all_naturality`

This is more of a specification than a deep theorem, but it formally states the data isolation property the chain relies on.

## Critical Clarification: Four Kinds of "Orthogonality"

During the audit that produced the existing Lean proofs, we identified four distinct orthogonality properties that the system relies on. The prompt consumer **must not conflate them** — they form a dependency chain (B) → (C) → (A), with (D) independent:

### A. Hodge Orthogonality (proven in `Hodge_Decomposition_Theorem`)
The decomposition `b = h + e₁ + e₂` has `⟨h, e₁⟩ = ⟨h, e₂⟩ = ⟨e₁, e₂⟩ = 0`. This is a **consequence** of the Laplacian being self-adjoint. The retired Python prototype checked this numerically via `validate_hodge_orthogonality()` in `docs/archive/python/src/invariants/harmonic.py`; it is not a current refinement.

### B. Stalk Fiber Inner Product (foundational — makes δ* well-defined)
Each stalk F(v) = ℝ^d carries the standard Euclidean inner product. The **total cochain space** C⁰ = ⊕_v F(v) inherits its inner product as a direct sum of stalk inner products. This is what makes the adjoint δ₀* well-defined, which in turn makes Δ = δ₀*δ₀ self-adjoint and PSD. Without this, "harmonic projection" has no meaning. In the code: `Stalk.data` is a numpy array with standard dot product; `sheaf_laplacian.py` builds the Laplacian Δ = δᵀδ where δ is a real matrix and the transpose IS the adjoint with respect to the standard inner product on ⊕_v ℝ^d. The Lean formalization should define the cochain inner product as `⟨c₁, c₂⟩ = Σ_v ⟨c₁(v), c₂(v)⟩_ℝ^d` and prove `⟨δ₀ c, η⟩_C¹ = ⟨c, δ₀* η⟩_C⁰`.

### C. Orthogonal Restriction Maps (needed for Section 5; preserves B)
The fiber bundle transition matrices are in O(n) — orthogonal group. This is an **input assumption**: `fiber_bundle.py::FiberBundle.random()` generates orthogonal matrices via QR decomposition. Crucially, this means restriction maps **preserve the stalk inner product** from (B): `⟨R_e v, R_e w⟩ = ⟨v, w⟩`. Without this, parallel transport distorts norms, and the Hodge decomposition's orthogonality (A) would not hold for the *sheaf* Laplacian (only for abstract matrices). The Lean formalization should make this an explicit hypothesis (`∀ e, R_e ∈ O(n)`), not derive it.

### D. √2 Spectral Gap Bounds (operational, NOT part of hardness claim)
The consensus layer checks `1/√2 ≤ spectral_gap ≤ 2√2`. These bounds are **operational parameters** for the validator, not part of the hardness reduction. `hardness_proof.lean` does not mention √2. The `test_math_audit.py` docstrings explicitly note: "K_n has gap = n > 2√2 for n≥3 because it's a bare graph Laplacian, not a consensus-layer normalized Laplacian. √2 bounds are tested in test_hardening.py. The hardness claim does NOT depend on √2."

The key security insight (proven as `Hodge_Ambiguity`): the **exact spectral gap value** is private key material. The Rust node was storing the raw f64 on-chain; we fixed it to store only a boolean `spectral_gap_valid: bool` — the Oracle verifies the gap is in bounds, then discards the value before it hits the block header. This prevents narrowing the anonymity set.

**For the new proofs:** Section 2 (sheaf Laplacian) depends on (B) — the stalk inner product is what makes δᵀ the adjoint. Section 5 (parallel transport) depends on (C) — orthogonal restriction maps preserve the stalk inner product. Section 2's self-adjointness + Section 5's norm preservation together give (A) — Hodge orthogonality for the sheaf Laplacian. Section 6 (storage) is independent. None depend on (D).

## Technical Notes

- **Lean 4 + Mathlib**: Use `leanprover/lean4:v4.24.0` with the same Mathlib version as the existing files
- **Style**: Follow the existing proof style in `framework_consolidation.lean` (use `simp`, `aesop`, `grind`, `exact?` etc.)
- **Keep `set_option maxHeartbeats 0`** — some proofs need it
- The existing file uses `Matrix n n R` for Laplacians; for the sheaf Laplacian, you'll need to work with block matrices or direct sums of stalks
- `CellularSheaf` can be defined as a functor from the face category of the simplicial complex to `FdVect ℝ`, but a concrete definition using `Fin n → ℝ^d` stalks is fine too
- The coboundary δ₀ should be defined as an actual matrix (matching the `sheaf_laplacian.py` implementation) so it connects to the existing `Hodge_Decomposition_Theorem`

## Expected Output

A single `.lean` file that:
1. Imports the existing `framework_consolidation.lean` definitions (or re-states compatible ones)
2. Defines `CellularSheaf`, `SheafCoboundary`, `SheafLaplacian`
3. Proves functoriality, self-adjointness, PSD, kernel characterization
4. Proves the gluing/H¹ correspondence
5. Proves cochain commitment binding (as reduction to SVP on ker(δ))
6. Proves parallel transport norm preservation
7. States the storage isolation specification

All proofs should be machine-checked (no `sorry`). Use `exact?` or `decide` where needed, but resolve all goals.
