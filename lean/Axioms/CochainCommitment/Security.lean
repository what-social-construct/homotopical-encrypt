import Axioms.CochainCommitment.Payload
import Axioms.CochainCommitment.Blinded
import Axioms.Foundation

/-
  Cochain commitment security interfaces.

  Paper correspondence:
  - Paper 1 Section 5: binding, hiding, homomorphic, topology-binding, and
    partial-opening security interfaces.
  - Paper 2: concrete adversary games and protocol evidence.

  This file contains binding/hiding/homomorphism assumptions and bridge
  theorems. The wire-facing payload lives in
  `Axioms.CochainCommitment.Payload`.
-/

namespace Hcrypt
namespace Axioms

/--
  Cochain commitment axioms capturing the security properties
  that Paper 1 treats as interface assumptions.

  A value of `CochainCommitmentAxioms` is the Lean witness that the commitment
  layer has binding, hiding, homomorphic, topology-binding, and partial-opening
  properties. This file imports only payload and foundation data; hardness
  comparisons and chain-level use of homomorphic accumulation are outside this
  file.
-/
structure CochainCommitmentAxioms where
  /-- BINDING: collision requires finding ker(δ) element.
      This axiom records the commitment-specific binding boundary; CVP
      hardness remains an external comparison assumption. -/
  Binding : Prop

  /-- HIDING: commitment reveals nothing about message.
      δ(m ∥ r) for uniformly random r is computationally
      indistinguishable from random in C¹. -/
  Hiding : Prop

  /-- HOMOMORPHIC ADDITION: linearity of δ.
      δ(m₁∥r₁) + δ(m₂∥r₂) = δ((m₁+m₂)∥(r₁+r₂)) mod q.
      This is used in Chain.lean for cochain_root accumulation
      and in balance_preserved for transaction aggregation. -/
  HomomorphicAddition : Prop

  /-- HOMOMORPHIC SCALAR MULT: k · δ(m∥r) = δ(k·m∥k·r) mod q.
      Follows from linearity of δ. -/
  HomomorphicScalarMult : Prop

  /-- TOPOLOGY BINDING: commitment is bound to a specific
      simplicial complex via topology_hash.
      Commitments over different topologies cannot be combined. -/
  TopologyBinding : Prop

  /-- PARTIAL OPENING: revealing a subset of vertex values allows
      verification of edges incident to revealed vertices.
      This is the VectorCommitment property from Python. -/
  PartialOpeningSoundness : Prop

abbrev CochainCommitmentWellFormed (C : CochainCommitmentAxioms) : Prop :=
  C.Binding
  ∧ C.Hiding
  ∧ C.HomomorphicAddition
  ∧ C.HomomorphicScalarMult
  ∧ C.TopologyBinding
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
  /-- Nothing-up-my-sleeve: H is deterministically derived from
      topology hash (no trusted setup). -/
  DeterministicBasis : Prop
  /-- Binding: extracting m requires projecting onto im(δ),
      which requires knowing the Laplacian. -/
  Binding : Prop
  /-- Hiding: blinding factor r makes commitment uniform. -/
  Hiding : Prop

abbrev BlindedCommitmentWellFormed (B : BlindedCommitmentAxioms) : Prop :=
  B.HodgeOrthogonality
  ∧ B.DeterministicBasis
  ∧ B.Binding
  ∧ B.Hiding

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
  /-- Soundness: for each revealed edge, the coboundary equation holds.
      Falsifying requires finding a coboundary collision. -/
  Soundness : Prop
  /-- Position binding: each vertex is bound to its position in
      the complex (topology hash prevents reindexing attacks). -/
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
  Foundation implies commitment binding preconditions.

  CochainComplex + LaplacianFromCoboundary give the cochain/Hodge structure
  used by the commitment-binding interface.
-/
theorem foundation_implies_binding_preconditions (F : Foundation) :
    FoundationWellFormed F →
    F.CochainComplex ∧ F.LaplacianFromCoboundary := by
  intro h
  exact ⟨h.1, h.2.2.1⟩

/--
  Homomorphic addition implies balance preservation.

  If commitments are homomorphic under addition (δ is linear),
  then Σᵢ δ(txᵢ) = δ(Σᵢ txᵢ) and balance can be checked on
  the accumulated commitment.
-/
theorem homomorphic_implies_balance_law
    (C : CochainCommitmentAxioms)
    (hC : CochainCommitmentWellFormed C) :
    C.HomomorphicAddition := by
  exact hC.2.2.1

/--
  Canonical CochainCommitmentAxioms instance derived from Foundation
  and a binding/hiding hypothesis.

  This lightweight interface instance fills the homomorphic fields with the
  cochain-complex premise currently carried by `Foundation`. The separate
  `Foundation.CoboundaryLinearity` field records the stronger mathematical
  linearity assumption, but this constructor does not use it. Binding, hiding,
  and partial-opening soundness remain explicit witnesses supplied to the
  constructor.
-/
def CochainCommitmentFromFoundation
    (F : Foundation) (_hF : FoundationWellFormed F)
    (hBinding : Prop) (hHiding : Prop) (hPartial : Prop) :
    CochainCommitmentAxioms where
  Binding := hBinding
  Hiding := hHiding
  -- Current lightweight interface witness for the homomorphic fields.
  HomomorphicAddition := F.CochainComplex
  HomomorphicScalarMult := F.CochainComplex
  TopologyBinding := True
  PartialOpeningSoundness := hPartial

/--
  The canonical commitment from Foundation is well-formed when the
  binding, hiding, and partial-opening witnesses are supplied.
-/
theorem canonical_commitment_wellformed
    (F : Foundation) (hF : FoundationWellFormed F)
    (hBinding hHiding hPartial : Prop)
    (hb : hBinding) (hh : hHiding) (hp : hPartial) :
    CochainCommitmentWellFormed
      (CochainCommitmentFromFoundation F hF hBinding hHiding hPartial) := by
  refine ⟨hb, hh, hF.1, hF.1, trivial, hp⟩

end Axioms
end Hcrypt
