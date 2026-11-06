module

public import Sheaf.Commitment
public import Axioms.SheafCoherence

@[expose] public section

/-!
# Cellular cochain semantics for the legacy coherence interface

The adapter identifies the existing cochain carriers and intertwines their
actual coboundaries. Decoder commutation and snapshot binding then transport
exactness, cocyclehood and accepted-payload semantics. Acceptance equivalence
is a theorem, not an adapter field. No norm or metric preservation is claimed.

The direct realization uses the actual cellular maps. Its square-zero gate
is their equation, proved from `delta1_comp_delta0`. Other legacy ambient
shape, Hodge and nerve gates remain explicit supplied records and hypotheses.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt
namespace Sheaf
namespace CellularSheaf

section Equivalences

variable
  {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- Carrier equivalences intertwining the actual degree-zero and degree-one
coboundaries. The legacy complex has plain types, so no additional linear
structure or metric is silently assigned to it. -/
structure CochainComplexEquivalence
    (F : CellularSheaf X) (K : Axioms.SheafCochainComplex) where
  e0 : F.C0 ≃ K.C0
  e1 : F.C1 ≃ K.C1
  e2 : F.C2 ≃ K.C2
  zero_comm : e2 0 = K.zeroC2
  delta0_comm : ∀ a : F.C0, e1 (F.delta0 a) = K.coboundary0 (e0 a)
  delta1_comm : ∀ b : F.C1, e2 (F.delta1 b) = K.coboundary1 (e1 b)

namespace CochainComplexEquivalence

variable {F : CellularSheaf X} {K : Axioms.SheafCochainComplex}

/-- The legacy operators satisfy their actual square-zero equation under
an operator-compatible carrier equivalence. This does not invent a proof of
an independently chosen legacy gate proposition. -/
theorem coboundary_square_zero (E : CochainComplexEquivalence F K) :
    ∀ a : K.C0, K.coboundary1 (K.coboundary0 a) = K.zeroC2 := by
  intro a
  obtain ⟨b, rfl⟩ := E.e0.surjective a
  rw [← E.delta0_comm, ← E.delta1_comm]
  have hzero : F.delta1 (F.delta0 b) = 0 := by
    have h := LinearMap.congr_fun F.delta1_comp_delta0 b
    simpa using h
  rw [hzero, E.zero_comm]

end CochainComplexEquivalence

/-- Decoder and snapshot compatibility on the same original payload type.
The binding equivalence is about the actual snapshot predicate, including
its shape, tag and outer-envelope obligations, rather than acceptance itself. -/
structure CochainSemantics
    {F : CellularSheaf X}
    (I : CochainPayloadInterpretation F) (S : Axioms.SheafCoherence)
    extends CochainComplexEquivalence F S.Complex where
  decode_comm : ∀ c : Axioms.CochainCommitmentData,
    e1 (I.decode c) = S.CommittedCochains.decode c
  bound_iff : ∀ c : Axioms.CochainCommitmentData,
    I.BoundToSnapshot c ↔ S.CommittedCochains.BoundToSheaf c

namespace CochainSemantics

variable
  {F : CellularSheaf X}
  {I : CochainPayloadInterpretation F}
  {S : Axioms.SheafCoherence}

/-- Exactness is transported through the degree-zero witness equivalence
and the actual degree-zero coboundary equation. -/
theorem representsExact_iff (E : CochainSemantics I S)
    (c : Axioms.CochainCommitmentData) :
    (∃ a : F.C0, I.decode c = F.delta0 a) ↔
      Axioms.RepresentsExactOneCochain S c := by
  constructor
  · rintro ⟨a, ha⟩
    exact ⟨E.e0 a,
      (E.decode_comm c).symm.trans
        ((congrArg E.e1 ha).trans (E.delta0_comm a))⟩
  · rintro ⟨a, ha⟩
    refine ⟨E.e0.symm a, E.e1.injective ?_⟩
    rw [E.decode_comm, E.delta0_comm, Equiv.apply_symm_apply]
    exact ha

/-- Cocyclehood is transported through the actual degree-one coboundary
and the degree-two zero, without any ambient geometry assumption. -/
theorem cocycle_iff (E : CochainSemantics I S)
    (c : Axioms.CochainCommitmentData) :
    F.IsOneCocycle (I.decode c) ↔ Axioms.IsOneCocycle S c := by
  change F.delta1 (I.decode c) = 0 ↔
    S.Complex.coboundary1 (S.CommittedCochains.decode c) = S.Complex.zeroC2
  constructor
  · intro h
    rw [← E.decode_comm, ← E.delta1_comm, h, E.zero_comm]
  · intro h
    apply E.e2.injective
    rw [E.delta1_comm, E.decode_comm, E.zero_comm]
    exact h

/-- Legacy semantic validity is exactly concrete acceptance together with
the separately supplied legacy ambient-coherence contract. -/
theorem accepted_and_ambient_iff (E : CochainSemantics I S)
    (c : Axioms.CochainCommitmentData) :
    AcceptedCommittedOneCochain I c ∧ Axioms.SheafCoherenceWellFormed S ↔
      Axioms.CommittedCochainWellFormed S c := by
  constructor
  · rintro ⟨h, hS⟩
    exact ⟨h.wireWellFormed, hS, (E.bound_iff c).1 h.boundToSnapshot,
      (E.representsExact_iff c).1 h.representsExact⟩
  · intro h
    exact ⟨⟨h.1, (E.bound_iff c).2 h.2.2.1,
      (E.representsExact_iff c).2 h.2.2.2⟩, h.2.1⟩

/-- Under explicit ambient coherence, accepted-payload semantics agree. -/
theorem accepted_iff (E : CochainSemantics I S)
    (hS : Axioms.SheafCoherenceWellFormed S)
    (c : Axioms.CochainCommitmentData) :
    AcceptedCommittedOneCochain I c ↔
      Axioms.CommittedCochainWellFormed S c := by
  constructor
  · intro h
    exact (E.accepted_and_ambient_iff c).1 ⟨h, hS⟩
  · intro h
    exact ((E.accepted_and_ambient_iff c).2 h).1

end CochainSemantics

end Equivalences

section DirectRealization

/- The legacy interface fixes its carriers in `Type`, so its direct
realization uses small finite cell types. The generic adapter above permits
universe-polymorphic concrete carriers whenever suitable equivalences exist. -/
variable
  {Vertex Edge Face : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- The legacy cochain-complex carrier built directly from the same cellular
cochains and actual coboundary maps. Its gate denotes their actual equation. -/
def toSheafCochainComplex (F : CellularSheaf X) : Axioms.SheafCochainComplex where
  C0 := F.C0
  C1 := F.C1
  C2 := F.C2
  zeroC2 := 0
  coboundary0 := F.delta0
  coboundary1 := F.delta1
  CoboundarySquaresZero := ∀ a : F.C0, F.delta1 (F.delta0 a) = 0
  coboundarySquaresZero_spec h := h

/-- The direct realization's square-zero gate is proved from cellular
restriction composition and the cell boundary equation. -/
theorem toSheafCochainComplex_square_zero (F : CellularSheaf X) :
    F.toSheafCochainComplex.CoboundarySquaresZero := by
  intro a
  have h := LinearMap.congr_fun F.delta1_comp_delta0 a
  simpa using h

namespace CochainPayloadInterpretation

variable {F : CellularSheaf X}

/-- Preserve the original decoder and full snapshot binding in the legacy
commitment interface. -/
def toCommittedCochainInterpretation (I : CochainPayloadInterpretation F) :
    Axioms.CommittedCochainInterpretation F.toSheafCochainComplex where
  decode := I.decode
  BoundToSheaf := I.BoundToSnapshot

/-- Build the legacy coherence bundle with the actual complex and payload
interpretation. All other ambient records remain explicit arguments. -/
def toSheafCoherence
    (I : CochainPayloadInterpretation F)
    (shape : Axioms.RestrictionShapeCompatibility)
    (edge : Axioms.EdgeNaturality)
    (triangle : Axioms.TriangleFaceCommutativity)
    (hodge : Axioms.HodgeCoherence)
    (nerve : Axioms.FiniteSimplicialNerve) : Axioms.SheafCoherence where
  ShapeCompat := shape
  EdgeNat := edge
  TriangleNat := triangle
  Complex := F.toSheafCochainComplex
  CommittedCochains := I.toCommittedCochainInterpretation
  Hodge := hodge
  Nerve := nerve

variable
  (I : CochainPayloadInterpretation F)
  (shape : Axioms.RestrictionShapeCompatibility)
  (edge : Axioms.EdgeNaturality)
  (triangle : Axioms.TriangleFaceCommutativity)
  (hodge : Axioms.HodgeCoherence)
  (nerve : Axioms.FiniteSimplicialNerve)

/-- The direct realization has identity carrier equivalences and definitionally
the same decoder/snapshot relation; no acceptance theorem is assumed. -/
def identitySemantics :
    CochainSemantics I (I.toSheafCoherence shape edge triangle hodge nerve) where
  e0 := Equiv.refl _
  e1 := Equiv.refl _
  e2 := Equiv.refl _
  zero_comm := rfl
  delta0_comm _ := rfl
  delta1_comm _ := rfl
  decode_comm _ := rfl
  bound_iff _ := Iff.rfl

/-- The concrete square-zero obligation is discharged, while all remaining
legacy shape, Hodge and nerve gates stay visible. -/
theorem toSheafCoherence_wellFormed_iff :
    Axioms.SheafCoherenceWellFormed
      (I.toSheafCoherence shape edge triangle hodge nerve) ↔
      shape.IncidenceShapes ∧ edge.EdgeSquareCommutes ∧
        triangle.TriangleFacesCommute ∧
        hodge.LaplacianFromCoboundary ∧ hodge.Orthogonality ∧
        nerve.Finite ∧ nerve.Simplicial ∧ nerve.Connected := by
  change (shape.IncidenceShapes ∧ edge.EdgeSquareCommutes ∧
      triangle.TriangleFacesCommute ∧
      F.toSheafCochainComplex.CoboundarySquaresZero ∧
      hodge.LaplacianFromCoboundary ∧ hodge.Orthogonality ∧
      nerve.Finite ∧ nerve.Simplicial ∧ nerve.Connected) ↔ _
  constructor
  · rintro ⟨hs, he, ht, _, hh, ho, hf, hsi, hc⟩
    exact ⟨hs, he, ht, hh, ho, hf, hsi, hc⟩
  · rintro ⟨hs, he, ht, hh, ho, hf, hsi, hc⟩
    exact ⟨hs, he, ht, F.toSheafCochainComplex_square_zero,
      hh, ho, hf, hsi, hc⟩

end CochainPayloadInterpretation
end DirectRealization

end CellularSheaf
end Sheaf
end Hcrypt

end
