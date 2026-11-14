module

public import Protocol.Transfer.PublicView
public import Mathlib.Probability.ProbabilityMassFunction.Basic

@[expose] public section

/-!
# A challenge game for checked transfer releases

Both branches are accepted transfers under one fixed operational configuration.
The challenger releases the actual `PublicTransferView` of the selected branch;
the adversary returns its guess of the branch bit. An arbitrary PMF specifies the
bit sampler for the success event. The distinguishing advantage below is the
absolute gap between the two deterministic output bits.

The fixed configuration also fixes the sheaf, original storage context and
payload, selected ciphertext bytes and their released digest. This is a
transaction-release leakage audit, not an HCP message or encryption challenge
with two independently chosen hidden geometries.

The public input resource ID already gives a perfect distinguisher when the
branches use different IDs. Thus equality of that released ID is necessary for
any nontrivial confidentiality claim about this view. This file supplies no
confidentiality theorem, primitive hardness assumption, or hiding assertion.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Confidentiality

open Sheaf CellularSheaf
open scoped ENNReal

variable {Vertex Edge Face Owner Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Two actual checked transfers under one fixed setup and original context. -/
structure Challenge (config : Operational.Config F Owner Asset Receipt) where
  leftTransfer : Owned.ResourceTransfer Owner
  leftBytes : List UInt8
  leftChecked : Operational.CheckedTransfer config leftTransfer leftBytes
  rightTransfer : Owned.ResourceTransfer Owner
  rightBytes : List UInt8
  rightChecked : Operational.CheckedTransfer config rightTransfer rightBytes

namespace Challenge

variable {config : Operational.Config F Owner Asset Receipt}
  (challenge : Challenge config)

/-- The checked release of the false branch, including packet and manifest. -/
def leftView : Owned.PublicTransferView Owner :=
  Owned.PublicTransferView.ofOperational challenge.leftChecked

/-- The checked release of the true branch, including packet and manifest. -/
def rightView : Owned.PublicTransferView Owner :=
  Owned.PublicTransferView.ofOperational challenge.rightChecked

/-- The false branch releases its checked transfer, not a separate chosen ID. -/
theorem leftView_transfer : challenge.leftView.transfer = challenge.leftTransfer := by
  change challenge.leftChecked.proof.packet.intent.transfer = challenge.leftTransfer
  rw [challenge.leftChecked.proof.intent_eq]
  rfl

/-- The true branch releases its checked transfer, not a separate chosen ID. -/
theorem rightView_transfer : challenge.rightView.transfer = challenge.rightTransfer := by
  change challenge.rightChecked.proof.packet.intent.transfer = challenge.rightTransfer
  rw [challenge.rightChecked.proof.intent_eq]
  rfl

/-- Both branches name the ciphertext fixed by this operational configuration. -/
theorem leftView_ciphertextDigest :
    challenge.leftView.ciphertextDigest = some config.ciphertextDigest :=
  Owned.PublicTransferView.ofOperational_ciphertextDigest challenge.leftChecked

theorem rightView_ciphertextDigest :
    challenge.rightView.ciphertextDigest = some config.ciphertextDigest :=
  Owned.PublicTransferView.ofOperational_ciphertextDigest challenge.rightChecked

/-- This fixed-configuration game does not vary its encrypted-object name. -/
theorem ciphertextDigest_eq :
    challenge.leftView.ciphertextDigest = challenge.rightView.ciphertextDigest :=
  challenge.leftView_ciphertextDigest.trans challenge.rightView_ciphertextDigest.symm

/-- The challenger's actual public observation for the selected bit. -/
def observe (bit : Bool) : Owned.PublicTransferView Owner :=
  if bit then challenge.rightView else challenge.leftView

/-- A one-shot observer sees the full released view and guesses the branch bit. -/
abbrev Adversary (Owner : Type) := Owned.PublicTransferView Owner → Bool

/-- The observer wins exactly when its guess matches the selected bit. -/
def Wins (adversary : Adversary Owner) (bit : Bool) : Prop :=
  adversary (challenge.observe bit) = bit

/-- Winning bit outcomes for a fixed observer. -/
def successEvent (adversary : Adversary Owner) : Set Bool :=
  {bit | challenge.Wins adversary bit}

/-- One-shot success probability for an explicit bit sampler. -/
def successProbability (bits : PMF Bool) (adversary : Adversary Owner) : ℝ≥0∞ :=
  bits.toOuterMeasure (challenge.successEvent adversary)

/-- Probability of output `true` on a deterministic branch, embedded in `ℝ`. -/
def trueOutput (adversary : Adversary Owner) (bit : Bool) : ℝ :=
  if adversary (challenge.observe bit) then 1 else 0

/-- Deterministic distinguishing advantage between the two released branches. -/
def advantage (adversary : Adversary Owner) : ℝ :=
  |challenge.trueOutput adversary true - challenge.trueOutput adversary false|

/-- Test whether the released input resource ID differs from the left branch's ID. -/
def inputIdAdversary : Adversary Owner :=
  fun view => !Owned.PublicTransferView.inputTest challenge.leftView.transfer.input view

/-- Distinct released input IDs let the same public test win on both branches. -/
theorem inputIdAdversary_wins
    (different : challenge.leftView.transfer.input ≠ challenge.rightView.transfer.input)
    (bit : Bool) : challenge.Wins challenge.inputIdAdversary bit := by
  obtain ⟨onLeft, onRight⟩ :=
    Owned.PublicTransferView.inputTest_distinguishes
      challenge.leftView challenge.rightView different
  cases bit <;> simp [Wins, observe, inputIdAdversary, onLeft, onRight]

/-- The released-ID test wins with probability one for every bit sampler. -/
theorem inputIdAdversary_successProbability_eq_one (bits : PMF Bool)
    (different : challenge.leftView.transfer.input ≠ challenge.rightView.transfer.input) :
    challenge.successProbability bits challenge.inputIdAdversary = 1 := by
  rw [successProbability, PMF.toOuterMeasure_apply_eq_one_iff]
  intro bit _
  exact challenge.inputIdAdversary_wins different bit

/-- Its deterministic distinguishing advantage is exactly one. -/
theorem inputIdAdversary_advantage_eq_one
    (different : challenge.leftView.transfer.input ≠ challenge.rightView.transfer.input) :
    challenge.advantage challenge.inputIdAdversary = 1 := by
  obtain ⟨onLeft, onRight⟩ :=
    Owned.PublicTransferView.inputTest_distinguishes
      challenge.leftView challenge.rightView different
  simp [advantage, trueOutput, observe, inputIdAdversary, onLeft, onRight]

/-- Different checked transfer inputs yield a perfect released-view distinguisher. -/
theorem inputIdAdversary_advantage_eq_one_of_transfer_input_ne
    (different : challenge.leftTransfer.input ≠ challenge.rightTransfer.input) :
    challenge.advantage challenge.inputIdAdversary = 1 := by
  apply challenge.inputIdAdversary_advantage_eq_one
  simpa only [challenge.leftView_transfer, challenge.rightView_transfer] using different

/-- Any uniform bound strictly below perfect advantage requires equal public input IDs. -/
theorem input_eq_of_all_advantage_lt_one
    (bounded : ∀ adversary : Adversary Owner, challenge.advantage adversary < 1) :
    challenge.leftView.transfer.input = challenge.rightView.transfer.input := by
  by_contra different
  have perfect := challenge.inputIdAdversary_advantage_eq_one different
  have strict := bounded challenge.inputIdAdversary
  rw [perfect] at strict
  exact (lt_irrefl (1 : ℝ)) strict

end Challenge

end HomotopicalEncryption.Protocol.Transfer.Confidentiality
