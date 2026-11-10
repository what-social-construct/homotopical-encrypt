module

public import Sheaf.Cellular
public import Axioms.CochainCommitment.Payload

@[expose] public section

/-!
# Exact one-cochain commitments for a concrete cellular sheaf

The primary committed mathematical object is the decoded exact `C¹` cochain.
A `C⁰` opening is determined only modulo `ker δ₀`; no opening/message
uniqueness is claimed. Snapshot binding is an explicit authenticated relation,
not a consequence of exactness or wire-shape well-formedness.
-/

set_option autoImplicit false

namespace HomotopicalEncryption
namespace Sheaf
namespace CellularSheaf

variable
  {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- Number of scalar coordinates in the concrete degree-one cochain space. -/
def edgeCoordinateCount (F : CellularSheaf X) : ℕ :=
  Fintype.card (TotalCoord Edge F.edgeDim)

/--
An immutable public name for the sheaf-relevant value of the existing
`SheafState` bus. Indexing by `F` ties the mathematical snapshot to the full
cellular sheaf; runtime refinement must realize the root and canonical encoding.
-/
structure SheafStateSnapshot (F : CellularSheaf X) where
  schemaVersion : ℕ
  root : Fin 32 → UInt8
  topologyHash : Fin 16 → UInt8
  CanonicallyEncoded : Prop
  RootBindsCellularSheaf : Prop

namespace SheafStateSnapshot

/-- Explicit well-formedness obligations for a content-addressed snapshot. -/
def WellFormed {F : CellularSheaf X} (s : SheafStateSnapshot F) : Prop :=
  s.CanonicallyEncoded ∧ s.RootBindsCellularSheaf

end SheafStateSnapshot

/-- Wire interpretation and outer-envelope binding for one concrete sheaf. -/
structure CochainPayloadInterpretation (F : CellularSheaf X) where
  snapshot : SheafStateSnapshot F
  decode : Axioms.CochainCommitmentData → F.C1
  /-- Authenticated outer-envelope relation between the payload and snapshot.
      This is supplied by the proof/runtime layer; the 16-byte topology tag
      alone does not establish it. -/
  PayloadBindsSnapshot : Axioms.CochainCommitmentData → Prop

namespace CochainPayloadInterpretation

variable {F : CellularSheaf X}

/-- Explicit snapshot, topology-tag, and coordinate-shape binding predicate. -/
def BoundToSnapshot
    (I : CochainPayloadInterpretation F)
    (c : Axioms.CochainCommitmentData) : Prop :=
  I.snapshot.WellFormed ∧
    c.n_edge_values = F.edgeCoordinateCount ∧
    c.topology_hash = I.snapshot.topologyHash ∧
    I.PayloadBindsSnapshot c

end CochainPayloadInterpretation

/-- Equality of openings modulo the information retained by `δ₀`. -/
def OpeningEquivalent (F : CellularSheaf X) (a a' : F.C0) : Prop :=
  F.delta0 a = F.delta0 a'

/-- Opening equivalence is equality modulo `ker δ₀`. -/
theorem openingEquivalent_iff_sub_mem_ker
    (F : CellularSheaf X) (a a' : F.C0) :
    F.OpeningEquivalent a a' ↔ a - a' ∈ LinearMap.ker F.delta0 := by
  simp [OpeningEquivalent, LinearMap.mem_ker, sub_eq_zero]

/-- Accepted exact `C¹` payload, without a uniqueness claim for its opening. -/
structure AcceptedCommittedOneCochain
    {F : CellularSheaf X}
    (I : CochainPayloadInterpretation F)
    (c : Axioms.CochainCommitmentData) : Prop where
  wireWellFormed : c.WellFormed
  boundToSnapshot : I.BoundToSnapshot c
  representsExact : ∃ a : F.C0, I.decode c = F.delta0 a

namespace AcceptedCommittedOneCochain

variable
  {F : CellularSheaf X}
  {I : CochainPayloadInterpretation F}
  {c : Axioms.CochainCommitmentData}

theorem edgeValues_length_eq_edgeCoordinateCount
    (h : AcceptedCommittedOneCochain I c) :
    c.edge_values.length = F.edgeCoordinateCount := by
  rw [← h.wireWellFormed.2.1]
  exact h.boundToSnapshot.2.1

theorem decoded_isExactOneCochain
    (h : AcceptedCommittedOneCochain I c) :
    F.IsExactOneCochain (I.decode c) := by
  obtain ⟨a, ha⟩ := h.representsExact
  exact ⟨a, ha.symm⟩

theorem decoded_isOneCocycle
    (h : AcceptedCommittedOneCochain I c) :
    F.IsOneCocycle (I.decode c) :=
  F.isOneCocycle_of_isExactOneCochain h.decoded_isExactOneCochain

theorem openings_equivalent_of_same_payload
    {a a' : F.C0}
    (ha : I.decode c = F.delta0 a)
    (ha' : I.decode c = F.delta0 a') :
    F.OpeningEquivalent a a' := by
  exact ha.symm.trans ha'

end AcceptedCommittedOneCochain

end CellularSheaf
end Sheaf
end HomotopicalEncryption
