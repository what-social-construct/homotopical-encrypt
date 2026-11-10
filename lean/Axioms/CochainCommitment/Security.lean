module

public import Axioms.CochainCommitment.Payload
public import Axioms.CochainCommitment.Blinded
public import Axioms.Foundation

@[expose] public section

/-
  Cochain commitment security interfaces.

  Paper correspondence:
  - Paper 2: binding, hiding, homomorphic, topology-binding and
    partial-opening assumptions, and their relation to protocol evidence.
  - Paper 1 uses only the elementary opening quotient and observation
    distinction; it claims no commitment security theorem from these records.

  This file contains binding/hiding/homomorphism assumptions and bridge
  theorems. The wire-facing payload lives in
  `Axioms.CochainCommitment.Payload`.
-/

namespace HomotopicalEncryption
namespace Axioms

/--
  Cochain commitment axioms capturing the security properties
  that Paper 2 keeps as explicit construction/security assumptions.

  A value of `CochainCommitmentAxioms` records explicit assumptions for an
  authenticated wrapper around the exact `C¹` payload. The bare coboundary
  supplies none of the cryptographic properties below: its degree-zero
  openings are defined only modulo `ker δ₀`.
-/
structure CochainCommitmentAxioms where
  /-- Authenticated binding of the serialized exact `C¹` value. This does not
      assert uniqueness of a degree-zero opening. -/
  ExactPayloadBinding : Prop

  /-- Distributional hiding of the witness component claimed by the wrapper.
      Exactness or kernel ambiguity alone does not prove this property. -/
  WrapperHiding : Prop

  /-- HOMOMORPHIC ADDITION: linearity of δ.
      δ(m₁∥r₁) + δ(m₂∥r₂) = δ((m₁+m₂)∥(r₁+r₂)) mod q.
      This is used in Chain.lean for cochain_root accumulation
      and in balance_preserved for transaction aggregation. -/
  HomomorphicAddition : Prop

  /-- HOMOMORPHIC SCALAR MULT: k · δ(m∥r) = δ(k·m∥k·r) mod q.
      Follows from linearity of δ. -/
  HomomorphicScalarMult : Prop

  /-- Authenticated binding to the declared topology/instance context. Paper 2
      strengthens this to a canonical `SheafStateSnapshot` root. -/
  ContextBinding : Prop

  /-- PARTIAL OPENING: revealing a subset of vertex values allows
      verification of edges incident to revealed vertices.
      This is the VectorCommitment property from Python. -/
  PartialOpeningSoundness : Prop

abbrev CochainCommitmentWellFormed (C : CochainCommitmentAxioms) : Prop :=
  C.ExactPayloadBinding
  ∧ C.WrapperHiding
  ∧ C.HomomorphicAddition
  ∧ C.HomomorphicScalarMult
  ∧ C.ContextBinding
  ∧ C.PartialOpeningSoundness

/--
  Cryptographic assumptions for the typed blinded-commitment construction.

  `BlindedCommittedCochain` carries the mathematical construction
    decode(base) + s·Hτ = δ₀(a) + s·Hτ.
  This record separately states the cryptographic properties of that
  construction; those distributional claims do not follow from exactness
  alone.
-/
structure BlindedCommitmentAxioms where
  /-- Hodge orthogonality: im(δ) and harmonic element H are in
      orthogonal subspaces (Hodge decomposition). -/
  HodgeOrthogonality : Prop
  /-- Nothing-up-my-sleeve: H is deterministically derived from the declared
      public context. -/
  DeterministicBasis : Prop
  /-- Authenticated binding of the resulting blinded `C¹` value. -/
  AuthenticatedValueBinding : Prop
  /-- Separately assumed distributional hiding of the blinded construction. -/
  DistributionalHiding : Prop

abbrev BlindedCommitmentWellFormed (B : BlindedCommitmentAxioms) : Prop :=
  B.HodgeOrthogonality
  ∧ B.DeterministicBasis
  ∧ B.AuthenticatedValueBinding
  ∧ B.DistributionalHiding

/--
  Vector commitment axioms.

  Python: VectorCommitment commits to a vector of values, each at
  a different vertex. Partial opening works naturally via the
  coboundary structure: reveal vertex i's value → verifier checks
  all edges incident to vertex i are consistent.
-/
structure VectorCommitmentAxioms where
  /-- Completeness: honest opener with correct values always verifies. -/
  Completeness : Prop
  /-- Soundness: for each revealed edge, the asserted local coboundary
      equation holds. This is local equation soundness, not uniqueness of the
      whole degree-zero opening. -/
  Soundness : Prop
  /-- Position binding: each vertex is authenticated at its canonical position
      in the declared context. -/
  PositionBinding : Prop

abbrev VectorCommitmentWellFormed (V : VectorCommitmentAxioms) : Prop :=
  V.Completeness
  ∧ V.Soundness
  ∧ V.PositionBinding

/--
  Cohomological MAC axioms.

  Python: CohomologicalMAC authenticates messages via Hodge projection.
    Key = secret sheaf Laplacian Δ (defines ker(Δ) = harmonic subspace)
    Tag(key, m) = P_H · c(m ∥ nonce) where P_H projects onto ker(Δ)
    Verify(key, m, tag) = check Δ·tag ≈ 0 ∧ V_H^T·tag = V_H^T·c
-/
structure CohomologicalMACAxioms where
  /-- Correctness: honest tag with correct key always verifies. -/
  Correctness : Prop
  /-- Unforgeability: producing a valid tag without the key (= without Δ)
      is as hard as the Discrete Hodge Decomposition problem. -/
  Unforgeability : Prop
  /-- Key fingerprint binding: tags are bound to a specific Laplacian. -/
  KeyBinding : Prop
  /-- Determinism: same (key, message, nonce) → same tag. -/
  Determinism : Prop

abbrev CohomologicalMACWellFormed (M : CohomologicalMACAxioms) : Prop :=
  M.Correctness
  ∧ M.Unforgeability
  ∧ M.KeyBinding
  ∧ M.Determinism

/--
  Foundation supplies the cochain/Hodge geometry consumed by a commitment
  interface.

  CochainComplex + LaplacianFromCoboundary give the cochain/Hodge structure
  used by the commitment-binding interface.
-/
theorem foundation_supplies_commitment_geometry (F : Foundation) :
    FoundationWellFormed F →
    F.CochainComplex ∧ F.LaplacianFromCoboundary := by
  intro h
  exact ⟨h.1, h.2.2.1⟩

/--
  Well-formedness exposes the separately stated homomorphic-addition field.
  Ledger balance preservation requires an additional ledger equation and does
  not follow from linearity alone.
-/
theorem homomorphic_addition_of_wellFormed
    (C : CochainCommitmentAxioms)
    (hC : CochainCommitmentWellFormed C) :
    C.HomomorphicAddition := by
  exact hC.2.2.1

/--
  Canonical `CochainCommitmentAxioms` interface derived from `Foundation`
  together with the commitment-specific hypotheses that `Foundation` does not
  carry.

  The homomorphic fields are tied to the declared coboundary-linearity
  premise.  Topology binding is an explicit input: it is not a consequence of
  the cochain-complex equation, and it must never be filled with `True` merely
  to construct the interface record.
-/
def CochainCommitmentFromFoundation
    (F : Foundation) (_hF : FoundationWellFormed F)
    (hBinding : Prop) (hHiding : Prop) (hTopologyBinding : Prop)
    (hPartial : Prop) :
    CochainCommitmentAxioms where
  ExactPayloadBinding := hBinding
  WrapperHiding := hHiding
  HomomorphicAddition := F.CoboundaryLinearity
  HomomorphicScalarMult := F.CoboundaryLinearity
  ContextBinding := hTopologyBinding
  PartialOpeningSoundness := hPartial

/--
  The canonical commitment from Foundation is well-formed when the
  binding, hiding, and partial-opening witnesses are supplied.
-/
theorem canonical_commitment_wellformed
    (F : Foundation) (hF : FoundationWellFormed F)
    (hBinding hHiding hTopologyBinding hPartial : Prop)
    (hb : hBinding) (hh : hHiding) (ht : hTopologyBinding) (hp : hPartial) :
    CochainCommitmentWellFormed
      (CochainCommitmentFromFoundation
        F hF hBinding hHiding hTopologyBinding hPartial) := by
  refine ⟨hb, hh, hF.2.1, hF.2.1, ht, hp⟩

end Axioms
end HomotopicalEncryption
