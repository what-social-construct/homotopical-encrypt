module

public import Protocol.Transfer.PathSignature.NativeOperatorGuessing
public import Protocol.Transfer.PathSignature.NativeSignSampler.Recovery

@[expose] public section

/-!
# Reuse of a fresh-sign key

Two canonical ciphertexts with the same sign key expose the coordinatewise
agreement of their messages. The openings may differ. One known message then
recovers the sign key and the other message. For the ciphertext-only view, the
agreement also characterizes the compatible message pairs.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignSampler.Reuse

open NativeOperatorGuessing (recoverMask recoverMask_ciphertextBytes unmasked_ciphertextBytes)

variable {rows cols : ℕ}

private theorem mask_comm (first second : Fin cols → Bool) :
    mask first second = mask second first := by
  funext col
  change (first col == second col) = (second col == first col)
  cases first col <;> cases second col <;> rfl

private theorem mask_cancel_right (first second : Fin cols → Bool) :
    mask (mask first second) second = first :=
  mask_involutive second first

theorem mask_reused (key first second : Fin cols → Bool) :
    mask (mask key first) (mask key second) = mask first second := by
  funext col
  change ((key col == first col) == (key col == second col)) = (first col == second col)
  cases key col <;> cases first col <;> cases second col <;> rfl

/-- Read coordinatewise message agreement from two ciphertexts. Its bitwise
complement is the coordinatewise XOR of the messages when the sign key agrees. -/
def recoverAgreement (A : Matrix (Fin rows) (Fin cols) ℤ) (first second : List UInt8) :
    Option (Fin cols → Bool) := do
  let firstMasked ← recoverMask A first
  let secondMasked ← recoverMask A second
  some (mask firstMasked secondMasked)

theorem recoverAgreement_ciphertextBytes (A : Matrix (Fin rows) (Fin cols) ℤ)
    (d a₁ a₂ : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key first second : Fin cols → Bool) :
    recoverAgreement A (ciphertextBytes A d a₁ key first) (ciphertextBytes A d a₂ key second) =
      some (mask first second) := by
  simp [recoverAgreement, recoverMask_ciphertextBytes A d _ orthogonal positive, mask_reused]

/-- Unmask the sign key using a known message and its ciphertext. -/
def recoverKnownKey (A : Matrix (Fin rows) (Fin cols) ℤ) (bytes : List UInt8)
    (known : Fin cols → Bool) : Option (Fin cols → Bool) :=
  (recoverMask A bytes).map fun masked => mask masked known

theorem recoverKnownKey_ciphertextBytes (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key known : Fin cols → Bool) :
    recoverKnownKey A (ciphertextBytes A d a key known) known = some key := by
  simp [recoverKnownKey, recoverMask_ciphertextBytes A d a orthogonal positive,
    mask_involutive known key]

/-- A known message for the first ciphertext supplies the sign key for the second. -/
def recoverReusedMessage (A : Matrix (Fin rows) (Fin cols) ℤ) (first second : List UInt8)
    (known : Fin cols → Bool) : Option (Fin cols → Bool) := do
  let key ← recoverKnownKey A first known
  let secondMasked ← recoverMask A second
  some (mask secondMasked key)

theorem recoverReusedMessage_ciphertextBytes (A : Matrix (Fin rows) (Fin cols) ℤ)
    (d a₁ a₂ : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key known second : Fin cols → Bool) :
    recoverReusedMessage A (ciphertextBytes A d a₁ key known)
        (ciphertextBytes A d a₂ key second) known = some second := by
  have unmask : mask (mask key second) key = second := by
    rw [mask_comm key second, mask_cancel_right]
  simp [recoverReusedMessage, recoverKnownKey_ciphertextBytes A d a₁ orthogonal positive,
    recoverMask_ciphertextBytes A d a₂ orthogonal positive, unmask]

private theorem recoverMask_normalBytes (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (masked : Fin cols → Bool) :
    recoverMask A (normalBytes A d a masked) = some masked := by
  let message : Fin cols → Bool := fun _ => true
  rw [← unmasked_ciphertextBytes A d a orthogonal masked message,
    recoverMask_ciphertextBytes A d a orthogonal positive, mask_cancel_right]

private theorem ciphertextBytes_eq_normalBytes_iff_mask
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key message masked : Fin cols → Bool) :
    ciphertextBytes A d a key message = normalBytes A d a masked ↔ mask key message = masked := by
  constructor
  · intro same
    have decoded := congrArg (recoverMask A) same
    rw [recoverMask_ciphertextBytes A d a orthogonal positive,
      recoverMask_normalBytes A d a orthogonal positive] at decoded
    exact Option.some.inj decoded
  · intro same
    rw [ciphertextBytes_normal A d a orthogonal, same]

/-- Every canonical sign key supplies exactly the output given by unmasking
with that key. Encrypting that output with the supplied key gives the same bytes. -/
theorem recoverBitsWithKeyBytes_alternativeSignKey
    (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (key message alternative : Fin cols → Bool) :
    let decoded := mask (mask key message) alternative
    ciphertextBytes A d a alternative decoded = ciphertextBytes A d a key message ∧
      recoverBitsWithKeyBytes rows cols
        (Storage.CoupledCodec.encode (Storage.CoupledCodec.ofMatrix (presentation A alternative)))
        (ciphertextBytes A d a key message) = some decoded := by
  dsimp only
  have same : ciphertextBytes A d a alternative (mask (mask key message) alternative) =
      ciphertextBytes A d a key message := by
    rw [ciphertextBytes_normal A d a orthogonal, ciphertextBytes_normal A d a orthogonal,
      mask_comm alternative, mask_cancel_right]
  refine ⟨same, ?_⟩
  rw [← same, recoverBitsWithKeyBytes_ciphertextBytes A d a positive]

/-- Exactly the pairs with the observed agreement have a common sign key
that generates the two ciphertexts at their respective openings. -/
theorem compatible_message_pair_iff (A : Matrix (Fin rows) (Fin cols) ℤ) (d a₁ a₂ : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (firstMask secondMask first second : Fin cols → Bool) :
    (∃ key, ciphertextBytes A d a₁ key first = normalBytes A d a₁ firstMask ∧
        ciphertextBytes A d a₂ key second = normalBytes A d a₂ secondMask) ↔
      mask first second = mask firstMask secondMask := by
  simp only [ciphertextBytes_eq_normalBytes_iff_mask A d _ orthogonal positive]
  constructor
  · rintro ⟨key, hFirst, hSecond⟩
    rw [← hFirst, ← hSecond, mask_reused]
  · intro agreement
    let key := mask firstMask first
    have firstAgrees : mask key first = firstMask := mask_cancel_right firstMask first
    refine ⟨key, firstAgrees, ?_⟩
    apply (mask_involutive firstMask).injective
    change mask (mask key second) firstMask = mask secondMask firstMask
    calc
      mask (mask key second) firstMask = mask firstMask (mask key second) := mask_comm _ _
      _ = mask first second := by rw [← firstAgrees, mask_reused]
      _ = mask firstMask secondMask := agreement
      _ = mask secondMask firstMask := mask_comm _ _

/-- The two-ciphertext fiber has one distinct message pair for every choice of
the first message, including when the message space has zero coordinates. -/
theorem compatible_message_pairs_card (A : Matrix (Fin rows) (Fin cols) ℤ) (d a₁ a₂ : ℤ)
    (orthogonal : A.transpose * A = d • (1 : Matrix (Fin cols) (Fin cols) ℤ))
    (positive : 0 < d) (firstMask secondMask : Fin cols → Bool) :
    {pair : (Fin cols → Bool) × (Fin cols → Bool) |
      ∃ key, ciphertextBytes A d a₁ key pair.1 = normalBytes A d a₁ firstMask ∧
        ciphertextBytes A d a₂ key pair.2 = normalBytes A d a₂ secondMask}.ncard = 2 ^ cols := by
  let relative := mask firstMask secondMask
  let partner : (Fin cols → Bool) → (Fin cols → Bool) × (Fin cols → Bool) :=
    fun first => (first, mask relative first)
  have fiber : {pair : (Fin cols → Bool) × (Fin cols → Bool) |
      ∃ key, ciphertextBytes A d a₁ key pair.1 = normalBytes A d a₁ firstMask ∧
        ciphertextBytes A d a₂ key pair.2 = normalBytes A d a₂ secondMask} = Set.range partner := by
    ext ⟨first, second⟩
    change (∃ key, ciphertextBytes A d a₁ key first = normalBytes A d a₁ firstMask ∧
        ciphertextBytes A d a₂ key second = normalBytes A d a₂ secondMask) ↔
      ∃ input, (input, mask relative input) = (first, second)
    rw [compatible_message_pair_iff A d a₁ a₂ orthogonal positive]
    change mask first second = relative ↔ _
    constructor
    · intro agreement
      refine ⟨first, congrArg (Prod.mk first) ?_⟩
      rw [← agreement, mask_comm first second, mask_cancel_right]
    · rintro ⟨input, same⟩
      have hFirst : input = first := congrArg Prod.fst same
      have hSecond : mask relative input = second := congrArg Prod.snd same
      rw [← hFirst, ← hSecond, mask_comm input, mask_cancel_right]
  rw [fiber, Set.ncard_range_of_injective (fun _ _ same => congrArg Prod.fst same),
    Nat.card_eq_fintype_card]
  simp

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSignSampler.Reuse
