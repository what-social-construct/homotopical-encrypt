module

public import Protocol.Transfer.Operational
public import Protocol.Transfer.PublicView
public import Mathlib.Probability.ProbabilityMassFunction.Basic

@[expose] public section

/-!
# A one-shot sampled integrity experiment for the actual transfer checker

An adversary receives a selected public transfer view and explicit auxiliary
input, then uses one shared random tape to produce an attempted transfer and
packet bytes. The attempt is checked against the fixed operational configuration,
including its actual trusted interpretation. The sampled bad event is checker
acceptance together with invalidity of the computed candidate.

The operational event decomposition bounds this event by authorization and
payload-verification failures. The probability inequality uses one PMF for all
three events and requires no independence. It is a conditional error-composition
theorem: no primitive error estimate, efficient adversary, security parameter,
signing oracle, corruption policy, negligible bound or anonymity claim is added.

The general experiment permits any selected observation and auxiliary input;
it does not assert that independently supplied values form a coherent release.
`ofCheckedRelease` supplies the exact view of an existing checked transfer.
Further released data must enter the auxiliary input or a richer declared view.
The arbitrary PMF has countable support; no uniform distribution on an infinite
classifier fiber is postulated. State origin, runtime agreement and finality
remain outside this fixed-configuration one-shot experiment.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Security

open Sheaf CellularSheaf
open scoped ENNReal

variable {Vertex Edge Face Owner Asset Receipt Aux Coins : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- A single attempted update, computed from precisely the selected observation. -/
abbrev Adversary (Owner Aux Coins : Type) :=
  Owned.PublicTransferView Owner → Aux → Coins → Operational.Attempt Owner

/-- Fixed setup and explicit shared randomness for a one-shot integrity experiment. -/
structure Experiment (F : CellularSheaf X) (Owner Asset Receipt Aux Coins : Type) where
  config : Operational.Config F Owner Asset Receipt
  view : Owned.PublicTransferView Owner
  auxiliary : Aux
  coins : PMF Coins
  adversary : Adversary Owner Aux Coins

variable {F : CellularSheaf X}

namespace Experiment

variable (experiment : Experiment F Owner Asset Receipt Aux Coins)

/-- The adversary uses this experiment's declared view, auxiliary input and tape. -/
def attempt (coin : Coins) : Operational.Attempt Owner :=
  experiment.adversary experiment.view experiment.auxiliary coin

/-- Acceptance of an invalid candidate by the actual operational checker. -/
def acceptedInvalidEvent [DecidableEq Asset] : Set Coins :=
  {coin | Operational.AcceptedInvalid experiment.config (experiment.attempt coin)}

/-- The same attempted packet violates its intended authorization predicate. -/
def authorizationFailureEvent : Set Coins :=
  {coin | Operational.AuthorizationFailure experiment.config (experiment.attempt coin)}

/-- The same attempted packet violates exact acceptance under the trusted interpretation. -/
def payloadFailureEvent : Set Coins :=
  {coin | Operational.PayloadFailure experiment.config (experiment.attempt coin)}

/-- PMF mass of accepted-invalid outcomes, without a measurable-space assumption. -/
def acceptedInvalidProbability [DecidableEq Asset] : ℝ≥0∞ :=
  experiment.coins.toOuterMeasure experiment.acceptedInvalidEvent

/-- PMF mass of authorization failures on the same shared random tape. -/
def authorizationFailureProbability : ℝ≥0∞ :=
  experiment.coins.toOuterMeasure experiment.authorizationFailureEvent

/-- PMF mass of payload failures on the same shared random tape. -/
def payloadFailureProbability : ℝ≥0∞ :=
  experiment.coins.toOuterMeasure experiment.payloadFailureEvent

/-- The actual checker, rather than a generic assumed success relation, supplies the reduction. -/
theorem acceptedInvalidEvent_subset_failures [DecidableEq Asset] :
    experiment.acceptedInvalidEvent ⊆
      experiment.authorizationFailureEvent ∪ experiment.payloadFailureEvent := by
  intro coin acceptedInvalid
  exact Operational.acceptedInvalid_implies_failure experiment.config
    (experiment.attempt coin) acceptedInvalid

/-- One-shot accepted-invalid error is bounded by primitive failure masses, without independence. -/
theorem acceptedInvalidProbability_le [DecidableEq Asset] :
    experiment.acceptedInvalidProbability ≤
      experiment.authorizationFailureProbability + experiment.payloadFailureProbability := by
  exact (MeasureTheory.measure_mono experiment.acceptedInvalidEvent_subset_failures).trans
    (MeasureTheory.measure_union_le
      experiment.authorizationFailureEvent experiment.payloadFailureEvent)

/-- Supplied primitive error budgets compose for this same experiment and adversary. -/
theorem acceptedInvalidProbability_le_of_bounds [DecidableEq Asset]
    {authorizationError payloadError : ℝ≥0∞}
    (authorizationBound : experiment.authorizationFailureProbability ≤ authorizationError)
    (payloadBound : experiment.payloadFailureProbability ≤ payloadError) :
    experiment.acceptedInvalidProbability ≤ authorizationError + payloadError :=
  experiment.acceptedInvalidProbability_le.trans (add_le_add authorizationBound payloadBound)

/-- Support-local ideal soundness suffices; no claim is made about unsampled tapes. -/
theorem acceptedInvalidProbability_eq_zero_of_no_failures [DecidableEq Asset]
    (authorizationGood : ∀ coin ∈ experiment.coins.support,
      ¬ Operational.AuthorizationFailure experiment.config (experiment.attempt coin))
    (payloadGood : ∀ coin ∈ experiment.coins.support,
      ¬ Operational.PayloadFailure experiment.config (experiment.attempt coin)) :
    experiment.acceptedInvalidProbability = 0 := by
  rw [acceptedInvalidProbability, PMF.toOuterMeasure_apply_eq_zero_iff]
  apply Set.disjoint_left.mpr
  intro coin supported acceptedInvalid
  rcases experiment.acceptedInvalidEvent_subset_failures acceptedInvalid with
    authorizationFailure | payloadFailure
  · exact authorizationGood coin supported authorizationFailure
  · exact payloadGood coin supported payloadFailure

/-- Forgetting an exact profile's universal soundness contracts preserves its
original algorithms and forces ideal zero error. This is a specialization of
those exact hypotheses, not a zero-error claim for deployed primitives. -/
theorem acceptedInvalidProbability_eq_zero_of_exact_config [DecidableEq Asset]
    (exactConfig : Owned.Config F Owner Asset Receipt)
    (config_eq : experiment.config = exactConfig.operational) :
    experiment.acceptedInvalidProbability = 0 := by
  apply experiment.acceptedInvalidProbability_eq_zero_of_no_failures
  · intro coin _supported failure
    rw [config_eq] at failure
    obtain ⟨packet, _decoded, _metadata, _intent, verified, unauthorized⟩ := failure
    exact unauthorized (exactConfig.authorization.sound
      (experiment.attempt coin).transfer.signer
      (exactConfig.operational.intentFor (experiment.attempt coin).transfer)
      packet.ownerSignature verified)
  · intro coin _supported failure
    rw [config_eq] at failure
    obtain ⟨packet, _decoded, _metadata, _intent, verified, unaccepted⟩ := failure
    exact unaccepted (exactConfig.payload.sound exactConfig.context
      (exactConfig.operational.intentFor (experiment.attempt coin).transfer)
      packet.proofBytes rfl rfl verified)

end Experiment

/-- Instantiate the observation with the exact bytes, parsed packet, proposal and
input-manifest projection of an existing checked release. The attacked fixed
configuration is explicit and need not be the setup of that earlier release. -/
def ofCheckedRelease
    (config : Operational.Config F Owner Asset Receipt)
    {source : Owned.Config F Owner Asset Receipt}
    {transfer : Owned.ResourceTransfer Owner} {bytes : List UInt8}
    (release : Owned.CheckedTransfer source transfer bytes)
    (auxiliary : Aux) (coins : PMF Coins) (adversary : Adversary Owner Aux Coins) :
    Experiment F Owner Asset Receipt Aux Coins where
  config := config
  view := release.publicView
  auxiliary := auxiliary
  coins := coins
  adversary := adversary

/-- The named instantiation supplies this exact checked release, with no view replacement. -/
theorem ofCheckedRelease_view
    (config : Operational.Config F Owner Asset Receipt)
    {source : Owned.Config F Owner Asset Receipt}
    {transfer : Owned.ResourceTransfer Owner} {bytes : List UInt8}
    (release : Owned.CheckedTransfer source transfer bytes)
    (auxiliary : Aux) (coins : PMF Coins) (adversary : Adversary Owner Aux Coins) :
    (ofCheckedRelease config release auxiliary coins adversary).view = release.publicView := rfl

/-- In the instantiated experiment the adversary receives the original released values. -/
theorem ofCheckedRelease_attempt
    (config : Operational.Config F Owner Asset Receipt)
    {source : Owned.Config F Owner Asset Receipt}
    {transfer : Owned.ResourceTransfer Owner} {bytes : List UInt8}
    (release : Owned.CheckedTransfer source transfer bytes)
    (auxiliary : Aux) (coins : PMF Coins) (adversary : Adversary Owner Aux Coins)
    (coin : Coins) :
    (ofCheckedRelease config release auxiliary coins adversary).attempt coin =
      adversary release.publicView auxiliary coin := rfl

end HomotopicalEncryption.Protocol.Transfer.Security
