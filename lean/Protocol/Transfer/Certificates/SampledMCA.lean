module

public import Protocol.Transfer.Operational
public import Protocol.Storage.CanonicalCalibration
public import Protocol.Storage.CanonicalThreeLevel
public import Mathlib.Probability.ProbabilityMassFunction.Constructions

@[expose] public section

/-!
# A sampled scalar check for the canonical cochain profile

The verifier retains the original transfer configuration, intended action and
count radius before drawing one uniform field challenge. The full cochain is
already part of the canonical intent, which fixes both columns under the
selected layout. A response supplies the original packet and a scalar RS
polynomial for the issued challenge. The existing packet checks still run.

At a modular cochain distance at least the normalized radius, an accepted
response implies an MCA-bad challenge for the retained line. The probability
bound permits arbitrary responses after the draw. It concerns one verifier
draw; randomness, session persistence and transport are runtime obligations.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Certificates.SampledMCA

open ProximityCoding
open ProximityCoding.BlockCode
open Storage.CanonicalSystematic (Index parameters length_pos degreeBound_pos)
open Storage.CanonicalThreeLevel
open HomotopicalEncryption.Proximity.CanonicalRS (RSField)
open scoped ENNReal

variable {Owner Asset Receipt : Type}

/-- The verifier fixes these inputs at the start of a single attempt. The
configuration may use the existing projection bundle verifier. -/
structure Pending (Owner Asset Receipt : Type) where
  config : Operational.Config Storage.CanonicalSystematic.sheaf Owner Asset Receipt
  transfer : Operational.ResourceTransfer Owner
  radius : ℕ
  prechecks : Operational.Prechecks config transfer

def Pending.line (pending : Pending Owner Asset Receipt) : AffineLine Index RSField :=
  extractedLine (pending.config.intentFor pending.transfer).base.cochain

theorem Pending.pair_eq_calibration (pending : Pending Owner Asset Receipt) :
    pairWord pending.line = Storage.CanonicalCalibration.calibration.extract pending.config.context := by
  funext i j
  fin_cases j <;> rfl

/-- Exact packet intent matching retains the pair without a new digest or an
assumption that a digest uniquely identifies arbitrary payloads. -/
theorem Pending.checked_line (pending : Pending Owner Asset Receipt) {bytes : List UInt8}
    (checked : Operational.CheckedTransfer pending.config pending.transfer bytes) :
    extractedLine checked.proof.packet.intent.base.cochain = pending.line := by
  rw [checked.proof.intent_eq]
  rfl

def uniformChallenge : PMF RSField :=
  PMF.ofFintype (fun _ => (Fintype.card RSField : ℝ≥0∞)⁻¹) (by
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    exact ENNReal.mul_inv_cancel (by simp [Axioms.canonicalCochainModulus]) (ENNReal.natCast_ne_top _))

theorem uniformChallenge_mass (challenges : Finset RSField) :
    (uniformChallenge.toOuterMeasure (challenges : Set RSField)).toReal =
      challengeFraction challenges := by
  rw [PMF.toOuterMeasure_apply_finset]
  simp [uniformChallenge, Finset.sum_const, nsmul_eq_mul, challengeFraction,
    ENNReal.toReal_mul, ENNReal.toReal_inv, div_eq_mul_inv]

/-- Each value of the experiment comes with this same retained attempt. -/
structure Round (_pending : Pending Owner Asset Receipt) where
  challenge : RSField

def Pending.draw (pending : Pending Owner Asset Receipt) : PMF (Round pending) :=
  uniformChallenge.map Round.mk

structure Response where
  packet : List UInt8
  challenge : RSField
  polynomial : Polynomial RSField

/-- The scalar check evaluates the proposed codeword at the actual evaluation
points and compares it to the issued fold. Strict inequality keeps a
distance at the declared radius out of the acceptance region. -/
def Round.check {pending : Pending Owner Asset Receipt}
    (round : Round pending) (response : Response) : Bool :=
  decide (response.challenge = round.challenge) &&
    decide (response.polynomial.natDegree < parameters.degreeBound) &&
    decide (hammingDistance
      (fun i => response.polynomial.eval (parameters.domain.point i))
      (pending.line.point round.challenge) < pending.radius) &&
    Operational.check pending.config pending.transfer response.packet

def Round.checkedTransfer {pending : Pending Owner Asset Receipt}
    {round : Round pending} {response : Response} (accepted : round.check response = true) :
    Operational.CheckedTransfer pending.config pending.transfer response.packet :=
  Operational.CheckedTransfer.ofCheck (Bool.and_eq_true_iff.mp accepted).2

theorem Round.check_rejects_challenge_mismatch {pending : Pending Owner Asset Receipt}
    (round : Round pending) (response : Response) (mismatch : response.challenge ≠ round.challenge) :
    round.check response = false := by
  simp [Round.check, mismatch]

theorem Round.checked_word {pending : Pending Owner Asset Receipt}
    {round : Round pending} {response : Response} (accepted : round.check response = true) :
    pending.line.point round.challenge =
      receivedWord (round.checkedTransfer accepted).proof.packet.intent.base.cochain
        round.challenge := by
  rw [← extractedLine_point, pending.checked_line (round.checkedTransfer accepted)]

/-- Against a far original modular cochain, a successful strict-radius scalar
check witnesses failure of MCA for the exact retained pair. -/
theorem Round.accepted_mem_bad {pending : Pending Owner Asset Receipt}
    {round : Round pending} {response : Response} (accepted : round.check response = true)
    (far : relativeRadius (ι := Index) pending.radius ≤
      Storage.CanonicalCalibration.sourceModel.distanceToValid pending.config.context) :
    round.challenge ∈ parameters.toBlockCode.badChallengeSetAt
      (relativeRadius (ι := Index) pending.radius) pending.line := by
  simp only [Round.check, Bool.and_eq_true_iff, decide_eq_true_eq] at accepted
  obtain ⟨⟨⟨_, degree⟩, edits⟩, _⟩ := accepted
  let word : Word Index RSField := fun i => response.polynomial.eval (parameters.domain.point i)
  have codeword : parameters.toBlockCode.Codeword word := ⟨response.polynomial, degree, fun _ => rfl⟩
  have hn : (0 : ℝ) < Fintype.card Index := by exact_mod_cast length_pos
  have below : parameters.toBlockCode.relativeDistanceToCode (pending.line.point round.challenge) <
      relativeRadius (ι := Index) pending.radius := by
    refine (parameters.toBlockCode.relativeDistanceToCode_le_of_codeword codeword).trans_lt ?_
    apply (div_lt_div_iff_of_pos_right hn).mpr
    exact_mod_cast edits
  have pairFar : relativeRadius (ι := Index) pending.radius ≤
      (parameters.toBlockCode.interleaved (Fin 2)).relativeDistanceToCode (pairWord pending.line) := by
    rw [pending.pair_eq_calibration]
    exact Storage.CanonicalCalibration.sourceFar_implies_rsFar _ _ far
  by_contra good
  exact (not_lt_of_ge (parameters.toBlockCode.scalarDistance_ge_of_pairDistance_ge_of_good
    (parameters.code_nonempty degreeBound_pos) length_pos _ _ _ good pairFar)) below

/-- The event quantifies over every answering packet and polynomial after the
draw, so the bound also controls any adaptive response in this attempt. -/
theorem Pending.far_acceptance_le {pending : Pending Owner Asset Receipt}
    (far : relativeRadius (ι := Index) pending.radius ≤
      Storage.CanonicalCalibration.sourceModel.distanceToValid pending.config.context) :
    (pending.draw.toOuterMeasure {round | ∃ response, round.check response = true}).toReal ≤
      challengeFraction (parameters.toBlockCode.badChallengeSetAt
        (relativeRadius (ι := Index) pending.radius) pending.line) := by
  rw [Pending.draw, PMF.toOuterMeasure_map_apply, ← uniformChallenge_mass]
  apply ENNReal.toReal_mono
  · rw [PMF.toOuterMeasure_apply]
    exact uniformChallenge.tsum_coe_indicator_ne_top _
  · apply uniformChallenge.toOuterMeasure.mono
    rintro γ ⟨response, accepted⟩
    exact Round.accepted_mem_bad (round := Round.mk γ) accepted far

theorem Pending.far_acceptance_le_of_mca {pending : Pending Owner Asset Receipt} {ε : ℝ}
    (far : relativeRadius (ι := Index) pending.radius ≤
      Storage.CanonicalCalibration.sourceModel.distanceToValid pending.config.context)
    (mca : parameters.toBlockCode.PairMCAErrorBoundAt (relativeRadius (ι := Index) pending.radius) ε) :
    (pending.draw.toOuterMeasure {round | ∃ response, round.check response = true}).toReal ≤ ε :=
  (pending.far_acceptance_le far).trans (mca pending.line)

/-- The canonical diagonal payload is a sharp example when the original packet
passes its independent checks. Only the cancellation challenge can pass, and
at that challenge the zero polynomial witnesses acceptance. -/
theorem Pending.capacity_acceptance_eq {pending : Pending Owner Asset Receipt}
    (payload : pending.config.context.cochain = Storage.CanonicalThreeLevel.capacityPayload)
    (positive : 0 < pending.radius)
    (within : relativeRadius (ι := Index) pending.radius ≤ (3 : ℝ) / 4)
    {packet : List UInt8}
    (packetAccepted : Operational.check pending.config pending.transfer packet = true) :
    (pending.draw.toOuterMeasure {round | ∃ response, round.check response = true}).toReal =
      (1 : ℝ) / 12289 := by
  have lineEq : pending.line = extractedLine capacityPayload := congrArg extractedLine payload
  have fold : pending.line.point (-1) = fun _ => 0 := by
    funext i
    rw [lineEq, AffineLine.point_apply, capacityLine_base, capacityLine_direction]
    simp
  have far : relativeRadius (ι := Index) pending.radius ≤
      Storage.CanonicalCalibration.sourceModel.distanceToValid pending.config.context := by
    change relativeRadius (ι := Index) pending.radius ≤ cochainDistance pending.config.context.cochain
    rwa [payload, capacityPayload_cochainDistance]
  have nonnegative : 0 ≤ relativeRadius (ι := Index) pending.radius := by
    unfold relativeRadius
    positivity
  have events : Round.mk ⁻¹' {round : Round pending | ∃ response, round.check response = true} =
      (parameters.toBlockCode.badChallengeSetAt
        (relativeRadius (ι := Index) pending.radius) pending.line : Set RSField) := by
    ext γ
    constructor
    · rintro ⟨response, accepted⟩
      exact Round.accepted_mem_bad (round := Round.mk γ) accepted far
    · intro bad
      have cancelling : γ = -1 := by
        change γ ∈ additiveCode.asBlockCode.badChallengeSetAt _ pending.line at bad
        rw [lineEq, capacityPayload_badChallenges _ nonnegative] at bad
        exact Finset.mem_singleton.mp bad
      subst γ
      refine ⟨⟨packet, -1, 0⟩, ?_⟩
      simp [Round.check, fold, degreeBound_pos, positive, packetAccepted]
  rw [Pending.draw, PMF.toOuterMeasure_map_apply, events, uniformChallenge_mass, lineEq]
  exact capacityPayload_badChallengeFraction _ nonnegative

end HomotopicalEncryption.Protocol.Transfer.Certificates.SampledMCA
