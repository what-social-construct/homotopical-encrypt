module

public import Mathlib.LinearAlgebra.Span.Basic
public import Sheaf.HCPAxisFamily
public import Protocol.Storage.Retrieval.HodgeQuery

@[expose] public section

/-!
# A joint-view obstruction for one-hot linear Hodge queries

The public predicate below asks whether one query column lies outside the span
of all other columns. A private linear projection proves that the selected
column is essential when it has nonzero projection and every other column has
zero projection. If all nonselected columns are redundant, this public
predicate uniquely identifies the selected index from the whole query.

The result concerns exact algebra and an explicit redundancy hypothesis. It
does not construct a numerical rank algorithm, finite wire decoder, noise
sampler or efficient probabilistic distinguisher. In particular it does not
assert that every HCP query profile satisfies the hypothesis. It explains why
single-observation HCP ambiguity does not by itself prove privacy for a joint
one-hot query. The finite example reuses an actual cellular HCP axis family.
Its columns are produced by the existing harmonic-lattice encryptor with
actual exact/coexact `HodgeNoise`; the final comparison retains the existing
known-lattice CVP theorem for those same samples. The extra joint-view and
redundancy hypotheses do not refute fixed single-observation HCP/CVP results.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.Retrieval.LinearQueryObstruction

variable {R I V W : Type*} [Semiring R]
  [AddCommMonoid V] [Module R V]
  [AddCommMonoid W] [Module R W]

/-- A column is essential precisely when the other public columns do not span it.
This predicate contains no private projection or hidden geometric parameter. -/
def EssentialColumn (R : Type*) [Semiring R]
    {I V : Type*} [AddCommMonoid V] [Module R V]
    (query : I → V) (index : I) : Prop :=
  query index ∉ Submodule.span R (query '' {other | other ≠ index})

/-- A private linear map separating the selected column proves public span
essentiality. Idempotence is not needed, so a Hodge projector is a special case. -/
theorem selected_essential (query : I → V) (projection : V →ₗ[R] W)
    (selected : I) (nonzero : projection (query selected) ≠ 0)
    (others_zero : ∀ other, other ≠ selected → projection (query other) = 0) :
    EssentialColumn R query selected := by
  have killed : Submodule.span R (query '' {other | other ≠ selected}) ≤
      LinearMap.ker projection := by
    apply Submodule.span_le.mpr
    rintro _ ⟨other, different, rfl⟩
    exact LinearMap.mem_ker.mpr (others_zero other different)
  intro membership
  exact nonzero (LinearMap.mem_ker.mp (killed membership))

/-- Under the stated redundancy condition the selected index is the unique
essential column, described entirely by the public joint query. -/
theorem essential_iff_selected (query : I → V) (projection : V →ₗ[R] W)
    (selected : I) (nonzero : projection (query selected) ≠ 0)
    (others_zero : ∀ other, other ≠ selected → projection (query other) = 0)
    (redundant : ∀ other, other ≠ selected →
      query other ∈ Submodule.span R (query '' {index | index ≠ other}))
    (index : I) : EssentialColumn R query index ↔ index = selected := by
  classical
  constructor
  · intro essential
    by_contra different
    exact essential (redundant index different)
  · intro same
    subst index
    exact selected_essential query projection selected nonzero others_zero

/-- Queries for different selected indices cannot have the same complete public
column view under these hypotheses, even without disclosing the private map. -/
theorem query_ne_of_selected_ne (left right : I → V) (projection : V →ₗ[R] W)
    (leftSelected rightSelected : I)
    (nonzero : projection (left leftSelected) ≠ 0)
    (others_zero : ∀ other, other ≠ leftSelected → projection (left other) = 0)
    (rightRedundant : ∀ other, other ≠ rightSelected →
      right other ∈ Submodule.span R (right '' {index | index ≠ other}))
    (different : leftSelected ≠ rightSelected) : left ≠ right := by
  intro same
  have essential := selected_essential left projection leftSelected nonzero others_zero
  rw [same] at essential
  exact essential (rightRedundant leftSelected different)

/-- The public essential-column predicate separates two candidate selections.
This is a logical joint-view obstruction, with no complexity claim. -/
theorem public_predicate_separates (left right : I → V) (projection : V →ₗ[R] W)
    (leftSelected rightSelected : I)
    (nonzero : projection (left leftSelected) ≠ 0)
    (others_zero : ∀ other, other ≠ leftSelected → projection (left other) = 0)
    (rightRedundant : ∀ other, other ≠ rightSelected →
      right other ∈ Submodule.span R (right '' {index | index ≠ other}))
    (different : leftSelected ≠ rightSelected) :
    EssentialColumn R left leftSelected ∧ ¬ EssentialColumn R right leftSelected := by
  exact ⟨selected_essential left projection leftSelected nonzero others_zero,
    fun essential => essential (rightRedundant leftSelected different)⟩

section Hodge

open Sheaf CellularSheaf

variable {Vertex Edge Face : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- The actual native harmonic projector is an instance of the algebraic
obstruction; independent HCP observations do not erase their joint span. -/
theorem harmonic_essential_iff_selected (query : I → F.C1) (selected : I)
    (nonzero : F.harmonicOneProjection (query selected) ≠ 0)
    (others_zero : ∀ other, other ≠ selected → F.harmonicOneProjection (query other) = 0)
    (redundant : ∀ other, other ≠ selected →
      query other ∈ Submodule.span ℝ (query '' {index | index ≠ other}))
    (index : I) : EssentialColumn ℝ query index ↔ index = selected :=
  essential_iff_selected query F.harmonicOneProjection selected nonzero others_zero redundant index

/-- One-hot messages passed through the actual harmonic-lattice encryptor have
the separating projections for every chosen family of structured Hodge noises.
The joint-column redundancy condition is additional, not a consequence of HCP. -/
theorem encrypted_essential_iff_selected
    {Rank : Type} [Fintype Rank] {integral : IntegralStructure F}
    (H : HarmonicLatticePresentation integral Rank)
    (coefficients : I → Rank → ℤ) (noise : I → HodgeNoise F) (selected : I)
    (nonzero : (H.point (coefficients selected)).1 ≠ 0)
    (others_zero : ∀ other, other ≠ selected → coefficients other = 0)
    (redundant : ∀ other, other ≠ selected →
      (H.encrypt (coefficients other) (noise other)).observed ∈ Submodule.span ℝ
        ((fun j => (H.encrypt (coefficients j) (noise j)).observed) ''
          {index | index ≠ other}))
    (index : I) :
    EssentialColumn ℝ (fun j => (H.encrypt (coefficients j) (noise j)).observed) index ↔
      index = selected := by
  apply harmonic_essential_iff_selected (F := F) _ selected _ _ redundant index
  · rw [H.encrypt_projection_eq_point]
    exact nonzero
  · intro other different
    rw [H.encrypt_projection_eq_point, others_zero other different]
    exact HodgeQuery.point_zero H

end Hodge

namespace AxisExample

open Sheaf CellularSheaf Sheaf.HCPAxisFamily

/-- Rank-one integral coefficients select exactly the first database position. -/
def coefficients (index : Fin 3) : Fin 1 → ℤ :=
  if index = 0 then fun _ => 1 else 0

/-- Vary the existing coexact opening by the nonzero scalars one, two and three.
These remain actual HodgeNoise values; no random-sampler claim is attached. -/
def queryNoise (index : Fin 3) : HodgeNoise (sheaf 0) where
  exactOpening := 0
  coexactOpening := (index.val + 1 : ℝ) • (opening 0).coexactOpening

/-- The existing cellular differential turns these openings into distinct
coexact vectors in the same native Hodge complement. -/
theorem queryNoise_value (index : Fin 3) :
    (queryNoise index).value = (index.val + 1 : ℝ) • unitCochain 0 := by
  change (sheaf 0).delta0 0 +
    (sheaf 0).delta1.adjoint ((index.val + 1 : ℝ) • (opening 0).coexactOpening) = _
  rw [map_zero, zero_add, map_smul]
  change (index.val + 1 : ℝ) • (opening 0).coexactComponent = _
  rw [opening_coexactComponent]

/-- Actual encrypted columns use the existing integral harmonic lattice and
varying exact/coexact Hodge openings, not an unrelated abstract mask. -/
def querySample (index : Fin 3) : HodgeEncryptedCochain (integralStructure 0) :=
  HodgeQuery.sample (harmonicLatticePresentation 0) (fun _ => 1) 0 index queryNoise

/-- The selected encrypted sample is exactly the original cellular HCP sample. -/
theorem selected_sample_eq_original : querySample 0 = sample 0 := by
  have noise_zero : queryNoise 0 = opening 0 := by simp [queryNoise, opening]
  rw [querySample, HodgeQuery.sample, noise_zero, sample_eq_encrypt_one]
  rfl

/-- The complete public joint query consists of these actual observed cochains. -/
def query : Fin 3 → C1 :=
  HodgeQuery.query (harmonicLatticePresentation 0) (fun _ => 1) 0 queryNoise

/-- The selected column has a harmonic message; the other two have distinct
nonzero coexact noises and zero harmonic message. -/
theorem query_eq (index : Fin 3) :
    query index = (if index = 0 then unitCochain 1 else 0) +
      (index.val + 1 : ℝ) • unitCochain 0 := by
  change ((harmonicLatticePresentation 0).point (coefficients index)).1 +
    (queryNoise index).value = _
  rw [harmonicLatticePresentation_point, queryNoise_value]
  by_cases h : index = 0 <;> simp [coefficients, h]

/-- The selected column has the nonzero harmonic direction of the existing sheaf. -/
theorem selected_projection :
    (sheaf 0).harmonicOneProjection (query 0) = unitCochain 1 := by
  rw [query, HodgeQuery.query_projection]
  norm_num [harmonicLatticePresentation_point]

/-- All other columns are annihilated by that same actual harmonic projector. -/
theorem others_projection (index : Fin 3) (different : index ≠ 0) :
    (sheaf 0).harmonicOneProjection (query index) = 0 := by
  rw [query, HodgeQuery.query_projection]
  simp [different]

/-- Distinct nonselected coexact columns meet the explicit redundancy premise. -/
theorem others_redundant (index : Fin 3) (different : index ≠ 0) :
    query index ∈ Submodule.span ℝ (query '' {other | other ≠ index}) := by
  fin_cases index
  · exact (different rfl).elim
  · change query 1 ∈ Submodule.span ℝ (query '' {other | other ≠ (1 : Fin 3)})
    have equation : (2 / 3 : ℝ) • query 2 = query 1 := by
      norm_num [query_eq, smul_smul]
    rw [← equation]
    apply Submodule.smul_mem
    exact Submodule.subset_span ⟨2, by decide, rfl⟩
  · change query 2 ∈ Submodule.span ℝ (query '' {other | other ≠ (2 : Fin 3)})
    have equation : (3 / 2 : ℝ) • query 1 = query 2 := by
      norm_num [query_eq, smul_smul]
    rw [← equation]
    apply Submodule.smul_mem
    exact Submodule.subset_span ⟨1, by decide, rfl⟩

/-- This genuine cellular fixture exposes its selected column in the public
joint query. It is a counterexample profile, not a private-retrieval scheme. -/
theorem selected_is_publicly_identified (index : Fin 3) :
    EssentialColumn ℝ query index ↔ index = 0 := by
  apply harmonic_essential_iff_selected (F := sheaf 0)
    query 0 _ others_projection others_redundant index
  rw [selected_projection]
  exact unitCochain_ne_zero 1

/-- The same encrypted query column still has exactly the existing known-lattice
CVP target. The joint-view obstruction does not replace this comparison. -/
theorem cvp_solution_iff_message (index : Fin 3) (v : CVP.AmbientVector Index) :
    CVP.Solution ((harmonicLatticePresentation 0).cvpInstance (querySample index)) v ↔
      v = ((harmonicLatticePresentation 0).point (coefficients index)).1 :=
  (harmonicLatticePresentation 0).solution_cvpInstance_iff_eq_point
    (coefficients index) (queryNoise index) v

end AxisExample

end HomotopicalEncryption.Protocol.Storage.Retrieval.LinearQueryObstruction
