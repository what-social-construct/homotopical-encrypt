module

public import Protocol.Transfer.Signing

@[expose] public section

/-!
# Concrete credential/message public-input bytes

The format is the ASCII domain `HCRYPT_PATH_SIGNATURE_V1`, followed by `[1,b]`
for each credential byte `b`, a single `[0]` delimiter and the complete message
bytes. Tag bytes inside a credential are data and require no special case.
After the delimiter all remaining bytes belong to the message.

The decoder parses the tagged credential and then checks exact re-encoding,
including the domain. It accepts exactly this canonical format. The codec is
executable with linear encoded length; it imposes no supplied injectivity
or hash assumption. It selects a byte representation for a public credential,
not a credential-generation, opening or cryptographic proof construction.
-/

set_option autoImplicit false

namespace Hcrypt.Protocol.Transfer.PathSignature.Codec

/-- Exact ASCII bytes of the native path-signature public-input domain. -/
def domain : List UInt8 :=
  [72, 67, 82, 89, 80, 84, 95, 80, 65, 84, 72, 95,
    83, 73, 71, 78, 65, 84, 85, 82, 69, 95, 86, 49]

/-- Tag every public-credential byte, then delimit the complete raw message. -/
def frame : List UInt8 → List UInt8 → List UInt8
  | [], message => 0 :: message
  | byte :: key, message => 1 :: byte :: frame key message

/-- Parse tagged credential bytes, stopping at the unique delimiter position. -/
def parseFrame : List UInt8 → Option (List UInt8 × List UInt8)
  | [] => none
  | tag :: rest =>
    if tag = 0 then some ([], rest)
    else
      match rest with
      | [] => none
      | byte :: tail =>
        if tag = 1 then
          (parseFrame tail).map (fun subject => (byte :: subject.1, subject.2))
        else none

/-- Concrete public-input encoding of credential bytes and full message bytes. -/
def encode (key message : List UInt8) : List UInt8 :=
  domain ++ frame key message

/-- Canonical parser; exact re-encoding also validates the domain prefix. -/
def decode (bytes : List UInt8) : Option (List UInt8 × List UInt8) :=
  match parseFrame (bytes.drop domain.length) with
  | none => none
  | some subject =>
    if bytes = encode subject.1 subject.2 then some subject else none

/-- The recursive parser recovers both byte strings without ambiguity. -/
theorem parseFrame_frame (key message : List UInt8) :
    parseFrame (frame key message) = some (key, message) := by
  induction key with
  | nil => cases message <;> rfl
  | cons byte key ih => simp [frame, parseFrame, ih]

/-- Every canonical encoding roundtrips through the actual decoder. -/
@[simp]
theorem decode_encode (key message : List UInt8) :
    decode (encode key message) = some (key, message) := by
  simp [decode, encode, parseFrame_frame]

/-- The actual parser accepts exactly the canonical bytes of its result. -/
theorem decode_eq_some_iff (bytes key message : List UInt8) :
    decode bytes = some (key, message) ↔ bytes = encode key message := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseFrame (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some subject =>
      simp only [parsed] at decoded
      split at decoded
      next same =>
        have subject_eq : subject = (key, message) := Option.some.inj decoded
        subst subject
        exact same
      next => contradiction
  · rintro rfl
    exact decode_encode key message

/-- No two distinct credential/message pairs have the same public-input bytes. -/
theorem encode_injective :
    Function.Injective (fun subject : List UInt8 × List UInt8 => encode subject.1 subject.2) := by
  intro left right same
  have decoded := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using decoded

/-- Tagged credential framing uses two bytes per credential byte plus one delimiter. -/
theorem frame_length (key message : List UInt8) :
    (frame key message).length = 2 * key.length + 1 + message.length := by
  induction key with
  | nil => simp [frame, Nat.add_comm]
  | cons byte key ih =>
    simp only [frame, List.length_cons, ih]
    omega

/-- The complete format has fixed domain overhead and linear length. -/
theorem encode_length (key message : List UInt8) :
    (encode key message).length = 24 + 2 * key.length + 1 + message.length := by
  simp only [encode, List.length_append, frame_length]
  have domain_length : domain.length = 24 := rfl
  rw [domain_length]
  omega

/-- A tag other than zero or one before the delimiter is malformed. -/
theorem decode_rejects_invalid_tag (tag : UInt8) (rest : List UInt8)
    (not_zero : tag ≠ 0) (not_one : tag ≠ 1) :
    decode (domain ++ tag :: rest) = none := by
  cases rest <;> simp [decode, parseFrame, not_zero, not_one]

/-- A final credential tag without its byte or delimiter is malformed. -/
theorem decode_rejects_truncated_key : decode (domain ++ [1]) = none := by
  simp [decode, parseFrame]

/-- A different public-input domain is rejected independently of its body. -/
theorem decode_rejects_wrong_domain (bytes : List UInt8)
    (wrong : bytes.take domain.length ≠ domain) : decode bytes = none := by
  cases decoded : decode bytes with
  | none => rfl
  | some subject =>
    have canonical := (decode_eq_some_iff bytes subject.1 subject.2).mp decoded
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

end Hcrypt.Protocol.Transfer.PathSignature.Codec
