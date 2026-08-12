import Proximity.Concrete.PluckerCochain

/-
  Concrete Plucker-to-committed-cochain bridge.

  Paper correspondence:
  - Paper 1 Section 6: concrete Plucker-to-cochain/local-syndrome bridge.
  - Paper 1 Section 5: consumes the cochain commitment payload shape.

  This file owns the first concrete payload boundary after the projective
  Plucker shadow. It does not choose a plane shadow or an RS field. The output
  carrier is the existing `Axioms.CochainCommitmentData` payload used by the
  storage/runtime layer.

  The actual byte/coordinate encoder from a public Plucker shadow is still a
  construction input: Lean records the required shape, quotient behavior, and
  local-syndrome compatibility without pretending that a canonical runtime
  serialization follows from the projective quotient alone.
-/

namespace Hcrypt
namespace Proximity
namespace PluckerCochain
namespace Concrete

open GrassmannianPlucker

noncomputable section

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}

/--
A concrete encoder from public Plucker shadows into the existing committed
cochain payload.

The encoder is total on public shadows, but its payload guarantees are required
only on valid frame witnesses. This matches the proof pipeline: valid Plucker
frames are what enter the cochain/local-syndrome gate.
-/
structure PayloadEncoder
    (P : FramedSystem n r)
    (S : Axioms.SheafCoherence) where
  encode : P.Shadow → CochainBridge.CommittedCochain
  expectedEdgeCount : ℕ
  expectedEdgeCount_pos : 0 < expectedEdgeCount
  committedCochainWellFormed_of_validFrame :
    ∀ W : FrameWitness n r,
      ValidFrame P W →
        Axioms.CommittedCochainWellFormed S (encode (P.publicShadow W))
  edgeCount_of_validFrame :
    ∀ W : FrameWitness n r,
      ValidFrame P W →
        (encode (P.publicShadow W)).n_edge_values = expectedEdgeCount

namespace PayloadEncoder

variable {P : FramedSystem n r} {S : Axioms.SheafCoherence}

/-- Valid Plucker frames encode to wire-well-formed cochain payloads. -/
theorem wellFormed_of_validFrame
    (E : PayloadEncoder P S)
    (W : FrameWitness n r)
    (hW : ValidFrame P W) :
    (E.encode (P.publicShadow W)).WellFormed :=
  Axioms.cochain_wellFormed_of_committedCochainWellFormed
    (E.committedCochainWellFormed_of_validFrame W hW)

/-- Valid Plucker frames encode to the canonical payload modulus. -/
theorem supportedModulus_of_validFrame
    (E : PayloadEncoder P S)
    (W : FrameWitness n r)
    (hW : ValidFrame P W) :
    Axioms.CochainCommitmentData.SupportedModulus
      (E.encode (P.publicShadow W)) :=
  (E.wellFormed_of_validFrame W hW).1

/-- Valid Plucker frames encode to the expected edge count. -/
theorem edgeCount_eq_expected
    (E : PayloadEncoder P S)
    (W : FrameWitness n r)
    (hW : ValidFrame P W) :
    (E.encode (P.publicShadow W)).n_edge_values = E.expectedEdgeCount :=
  E.edgeCount_of_validFrame W hW

/-- The encoded edge vector has the expected length for valid Plucker frames. -/
theorem edgeValues_length_eq_expected
    (E : PayloadEncoder P S)
    (W : FrameWitness n r)
    (hW : ValidFrame P W) :
    (E.encode (P.publicShadow W)).edge_values.length = E.expectedEdgeCount := by
  have hWF := E.wellFormed_of_validFrame W hW
  rw [← hWF.2.1]
  exact E.edgeCount_of_validFrame W hW

/--
Encoding is automatically quotient-respecting at the payload level because the
encoder consumes the public Plucker shadow, not the private frame witness.
-/
theorem encode_eq_of_publicShadow_eq
    (E : PayloadEncoder P S)
    {W V : FrameWitness n r}
    (hWV : P.publicShadow W = P.publicShadow V) :
    E.encode (P.publicShadow W) = E.encode (P.publicShadow V) := by
  simp [hWV]

/-- Valid Plucker frames encode to semantically accepted committed cocycles. -/
theorem globalSectionCandidate_of_validFrame
    (E : PayloadEncoder P S)
    (W : FrameWitness n r)
    (hW : ValidFrame P W) :
    CochainBridge.CommittedCochain.GlobalSectionCandidate S
      (E.encode (P.publicShadow W)) :=
  E.committedCochainWellFormed_of_validFrame W hW

end PayloadEncoder

/--
Concrete commitment-sum local syndrome input.

This is a lightweight local-test interpretation already present in the chain
layer: the syndrome is the sum of committed edge values. The statement that
global candidates have zero sum remains an explicit construction input.
-/
structure CommitmentSumSyndromeInputs
    (S : Axioms.SheafCoherence) : Prop where
  zero_sum_of_globalCandidate :
    ∀ c : CochainBridge.CommittedCochain,
      CochainBridge.CommittedCochain.GlobalSectionCandidate S c →
        c.commitment_sum = 0

/-- Binary residual for the commitment-sum syndrome. -/
def commitmentSumResidual
    (c : CochainBridge.CommittedCochain) : ℝ :=
  if c.commitment_sum = 0 then 0 else 1

/-- The commitment-sum residual vanishes exactly on zero-sum payloads. -/
theorem commitmentSumResidual_eq_zero_of_sum_zero
    {c : CochainBridge.CommittedCochain}
    (hc : c.commitment_sum = 0) :
    commitmentSumResidual c = 0 := by
  simp [commitmentSumResidual, hc]

/--
Concrete local syndrome target using the existing commitment-sum residual.

This target is intentionally modest: it is a chain-facing summary syndrome, not
the final cochain-to-plane or RS distance theorem. In particular, zero
commitment sum does not imply the already-separate sheaf/commitment acceptance
predicate; the projection chain consumes an accepted commitment before applying
this summary test.
-/
def commitmentSumLocalSyndromeTarget
    (S : Axioms.SheafCoherence)
    (h : CommitmentSumSyndromeInputs S) :
    LocalSyndromeTarget S where
  Syndrome := ℤ
  syndrome := fun c => c.commitment_sum
  ZeroSyndrome := fun s => s = 0
  distanceToCode := commitmentSumResidual
  zeroSyndrome_of_globalCandidate := by
    intro c hc
    exact h.zero_sum_of_globalCandidate c hc

namespace CommitmentSumSyndromeInputs

/-- Global candidates are codewords for the commitment-sum local target. -/
theorem codeword_of_globalCandidate
    {S : Axioms.SheafCoherence}
    (h : CommitmentSumSyndromeInputs S)
    {c : CochainBridge.CommittedCochain}
    (hc : CochainBridge.CommittedCochain.GlobalSectionCandidate S c) :
    (commitmentSumLocalSyndromeTarget S h).Codeword c :=
  LocalSyndromeTarget.codeword_of_globalCandidate
    (commitmentSumLocalSyndromeTarget S h) hc

/-- Global candidates have zero commitment-sum residual. -/
theorem residual_eq_zero_of_globalCandidate
    {S : Axioms.SheafCoherence}
    (h : CommitmentSumSyndromeInputs S)
    {c : CochainBridge.CommittedCochain}
    (hc : CochainBridge.CommittedCochain.GlobalSectionCandidate S c) :
    commitmentSumResidual c = 0 :=
  commitmentSumResidual_eq_zero_of_sum_zero
    (h.zero_sum_of_globalCandidate c hc)

end CommitmentSumSyndromeInputs

/--
Construction inputs for the actual Plucker-to-cochain projection.

`distanceControlled` is the first quantitative fidelity obligation in the
pipeline: after the public Plucker quotient and payload encoding, the selected
local cochain distance must stay within the Plucker disagreement budget.
-/
structure ProjectionInputs
    (P : FramedSystem n r)
    (S : Axioms.SheafCoherence)
    (L : LocalSyndromeTarget S)
    (pluckerDisagreement : FrameWitness n r → ℝ) where
  encoder : PayloadEncoder P S
  distanceControlled :
    ∀ W : FrameWitness n r,
      L.distanceToCode (encoder.encode (P.publicShadow W)) ≤
        pluckerDisagreement W

namespace ProjectionInputs

variable
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : LocalSyndromeTarget S}
    {pluckerDisagreement : FrameWitness n r → ℝ}

/-- Build the generic Plucker-to-cochain projection from concrete payload inputs. -/
def toProjection
    (I : ProjectionInputs P S L pluckerDisagreement) :
    Projection P S L pluckerDisagreement where
  encode := I.encoder.encode
  preservesValidFrame := by
    intro W hW
    exact I.encoder.globalSectionCandidate_of_validFrame W hW
  distanceControlled := I.distanceControlled

/-- Concrete inputs expose the standard stage-local invariant checklist. -/
def toInvariantChecklist
    (I : ProjectionInputs P S L pluckerDisagreement) :
    InvariantChecklist I.toProjection :=
  InvariantChecklist.of_projection I.toProjection

/-- Valid frames map to cochain local-test codewords under the concrete bridge. -/
theorem validFrame_maps_to_codeword
    (I : ProjectionInputs P S L pluckerDisagreement)
    (W : FrameWitness n r)
    (hW : ValidFrame P W) :
    L.Codeword (I.encoder.encode (P.publicShadow W)) := by
  have hCandidate :
      CochainBridge.CommittedCochain.GlobalSectionCandidate S
        (I.encoder.encode (P.publicShadow W)) :=
    I.encoder.globalSectionCandidate_of_validFrame W hW
  exact L.codeword_of_globalCandidate hCandidate

/-- The concrete bridge satisfies the Plucker-to-cochain distance bound. -/
theorem projected_distance_le_pluckerDisagreement
    (I : ProjectionInputs P S L pluckerDisagreement)
    (W : FrameWitness n r) :
    L.distanceToCode (I.encoder.encode (P.publicShadow W)) ≤
      pluckerDisagreement W :=
  I.distanceControlled W

end ProjectionInputs

end

end Concrete
end PluckerCochain
end Proximity
end Hcrypt
