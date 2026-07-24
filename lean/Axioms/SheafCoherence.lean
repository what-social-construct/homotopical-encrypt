import Mathlib
import Axioms.Foundation
import Axioms.CochainCommitment.Payload

/-
  Sheaf Coherence Axioms

  Paper correspondence:
  - Paper 1 Section 4: exact structural invariants and sheaf-coherence
    preconditions.
  - Paper 1 Section 6: consumed by the proximity cochain/global-section bridge.

  Dedicated interface for runtime sheaf-coherence checks.

  Separation of concerns:
    - Grassmannian.lean: metric/manifold geometry (distance, Karcher mean)
    - SheafCoherence.lean: sheaf restriction coherence and gluing laws

  Runtime mapping (current):
    Python:
      - retired docs/archive/python/src/invariants/cohomology.py
          * validate_nerve_structure
          * check_cochain_complex_structure (δ₁ ∘ δ₀ = 0)
      - retired docs/archive/python/src/invariants/unified.py
          * UnifiedInvariantValidator._check_cochain_complex
          * UnifiedInvariantValidator._check_laplacian_construction
          * UnifiedInvariantValidator._check_hodge_orthogonality

    Rust:
      - planned dedicated coherence validator module
        (current rust/oracle/src/geometry.rs covers geometric operators)
-/

namespace Hcrypt
namespace Axioms

/-- Restriction maps are shape-compatible on incidences v ≤ e ≤ t. -/
structure RestrictionShapeCompatibility where
  /-- For every incidence pair, cod/domain dimensions match. -/
  IncidenceShapes : Prop

/-- Naturality on edges: edge restriction agrees with vertex transport. -/
structure EdgeNaturality where
  /-- For each edge (v,w), the two restriction paths are coherent. -/
  EdgeSquareCommutes : Prop

/-- Triangle/2-simplex commutativity for face restrictions. -/
structure TriangleFaceCommutativity where
  /-- On each triangle, all face-composition paths agree. -/
  TriangleFacesCommute : Prop

/--
Typed degree-zero through degree-two sheaf cochain complex.

`CoboundarySquaresZero` remains an assumption-oriented gate so runtime-facing
contracts can require it explicitly.  Unlike the former proposition-only
placeholder, `coboundarySquaresZero_spec` ties that gate to the actual
coboundary maps.
-/
structure SheafCochainComplex where
  C0 : Type
  C1 : Type
  C2 : Type
  zeroC2 : C2
  coboundary0 : C0 → C1
  coboundary1 : C1 → C2
  /-- δ₁ ∘ δ₀ = 0. -/
  CoboundarySquaresZero : Prop
  /-- The abstract gate denotes the actual equation on the carried maps. -/
  coboundarySquaresZero_spec :
    CoboundarySquaresZero →
      ∀ x : C0, coboundary1 (coboundary0 x) = zeroC2

/--
Interpret serialized cochain commitments in a particular sheaf cochain
complex.  `BoundToSheaf` is the mathematical topology-binding predicate; the
runtime owns the concrete hash/serialization check that establishes it.
-/
structure CommittedCochainInterpretation (K : SheafCochainComplex) where
  decode : CochainCommitmentData → K.C1
  BoundToSheaf : CochainCommitmentData → Prop

/-- Hodge-level coherence needed for stable decomposition. -/
structure HodgeCoherence where
  /-- Δ is built from coboundaries: Δ = δ*δ + δδ*. -/
  LaplacianFromCoboundary : Prop
  /-- Harmonic / exact / coexact subspaces are pairwise orthogonal. -/
  Orthogonality : Prop

/-- Finite/simplicial/connected constraints for runtime tractability + gluing. -/
structure FiniteSimplicialNerve where
  /-- Nerve is finite. -/
  Finite : Prop
  /-- Nerve is simplicial (all faces present). -/
  Simplicial : Prop
  /-- Nerve is connected (β₀ = 1 for consensus-connected regime). -/
  Connected : Prop

/--
  Full sheaf coherence contract exported to runtime validators.

  This is intentionally assumption-oriented and mirrors the same style as
  Foundation.lean: Lean specifies *what must hold*; runtime checks *whether
  it currently holds* for a concrete state.
-/
structure SheafCoherence where
  ShapeCompat : RestrictionShapeCompatibility
  EdgeNat : EdgeNaturality
  TriangleNat : TriangleFaceCommutativity
  Complex : SheafCochainComplex
  CommittedCochains : CommittedCochainInterpretation Complex
  Hodge : HodgeCoherence
  Nerve : FiniteSimplicialNerve

abbrev SheafCoherenceWellFormed (S : SheafCoherence) : Prop :=
  S.ShapeCompat.IncidenceShapes
  ∧ S.EdgeNat.EdgeSquareCommutes
  ∧ S.TriangleNat.TriangleFacesCommute
  ∧ S.Complex.CoboundarySquaresZero
  ∧ S.Hodge.LaplacianFromCoboundary
  ∧ S.Hodge.Orthogonality
  ∧ S.Nerve.Finite
  ∧ S.Nerve.Simplicial
  ∧ S.Nerve.Connected

/-- A payload decodes as an exact degree-one cochain in the supplied sheaf. -/
def RepresentsExactOneCochain
    (S : SheafCoherence)
    (c : CochainCommitmentData) : Prop :=
  ∃ x : S.Complex.C0,
    S.CommittedCochains.decode c = S.Complex.coboundary0 x

/-- The decoded payload is a degree-one cocycle. -/
def IsOneCocycle
    (S : SheafCoherence)
    (c : CochainCommitmentData) : Prop :=
  S.Complex.coboundary1 (S.CommittedCochains.decode c) = S.Complex.zeroC2

/--
Full mathematical well-formedness for a committed cochain in a sheaf context.

This strengthens the wire-facing `CochainCommitmentData.WellFormed` predicate
with ambient sheaf coherence, topology binding, and the witness that the
payload really is an exact one-cochain.
-/
def CommittedCochainWellFormed
    (S : SheafCoherence)
    (c : CochainCommitmentData) : Prop :=
  c.WellFormed
    ∧ SheafCoherenceWellFormed S
    ∧ S.CommittedCochains.BoundToSheaf c
    ∧ RepresentsExactOneCochain S c

namespace CochainCommitmentData

/-- Dot-notation view of the full sheaf-semantic commitment contract. -/
abbrev CoherentWith
    (c : CochainCommitmentData)
    (S : SheafCoherence) : Prop :=
  CommittedCochainWellFormed S c

end CochainCommitmentData

/-- Foundation and sheaf coherence are jointly admissible assumptions. -/
abbrev FoundationWithSheafCoherence
    (F : Foundation) (S : SheafCoherence) : Prop :=
  FoundationWellFormed F ∧ SheafCoherenceWellFormed S

/--
  Coherence implies the core structural preconditions used in transaction-stage
  validation: adjacent coboundaries compose to zero, and the Laplacian is built
  from coboundaries.
-/
theorem coherence_implies_structural_preconditions (S : SheafCoherence) :
    SheafCoherenceWellFormed S →
    S.Complex.CoboundarySquaresZero ∧ S.Hodge.LaplacianFromCoboundary := by
  intro h
  rcases h with ⟨_, _, _, hδ2, hLap, _, _, _, _⟩
  exact ⟨hδ2, hLap⟩

/-- Semantic cochain validity inherits the underlying wire-format validity. -/
theorem cochain_wellFormed_of_committedCochainWellFormed
    {S : SheafCoherence} {c : CochainCommitmentData}
    (h : CommittedCochainWellFormed S c) :
    c.WellFormed :=
  h.1

/-- Semantic cochain validity carries the ambient sheaf-coherence contract. -/
theorem sheaf_wellFormed_of_committedCochainWellFormed
    {S : SheafCoherence} {c : CochainCommitmentData}
    (h : CommittedCochainWellFormed S c) :
    SheafCoherenceWellFormed S :=
  h.2.1

/-- Semantically valid committed cochains are bound to their sheaf context. -/
theorem boundToSheaf_of_committedCochainWellFormed
    {S : SheafCoherence} {c : CochainCommitmentData}
    (h : CommittedCochainWellFormed S c) :
    S.CommittedCochains.BoundToSheaf c :=
  h.2.2.1

/-- Semantically valid committed cochains carry their exactness witness. -/
theorem exactOneCochain_of_committedCochainWellFormed
    {S : SheafCoherence} {c : CochainCommitmentData}
    (h : CommittedCochainWellFormed S c) :
    RepresentsExactOneCochain S c :=
  h.2.2.2

/-- Exact committed one-cochains are cocycles by the sheaf complex law. -/
theorem oneCocycle_of_committedCochainWellFormed
    {S : SheafCoherence} {c : CochainCommitmentData}
    (h : CommittedCochainWellFormed S c) :
    IsOneCocycle S c := by
  obtain ⟨x, hx⟩ := exactOneCochain_of_committedCochainWellFormed h
  unfold IsOneCocycle
  rw [hx]
  exact S.Complex.coboundarySquaresZero_spec
    (coherence_implies_structural_preconditions S
      (sheaf_wellFormed_of_committedCochainWellFormed h)).1 x

end Axioms
end Hcrypt
