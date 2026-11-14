module

public import Protocol.Transfer.Signing
public import Protocol.Ephemeral.ScopeCodec
public import Protocol.Storage.TransportCodec

@[expose] public section

/-!
# Canonical public certificate subjects

This concrete outer format reuses the existing tagged byte, fixed identifier
and reduced-rational codecs. The original metadata and complete pre-proof
intent use the supplied packet codec's empty-output signing skeleton. No
certificate proof, opening, private geometry or other witness is serialized.

Claim, selected public profile bytes, optional rational calibration and full
ciphertext digest are retained as separate public coordinates. The raw format
accepts invalid calibration values: semantic validity and identification of
the actual projection profile are separate binding predicates. The subject
contains no enclosing gate/evidence/block root, avoiding self-reference when
its bytes are committed later. Encoding alone supplies neither such binding
nor authorization, certificate truth, knowledge or cryptographic hash security.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Certificates.Codec

open Evidence.TransferTranscript
open Storage.CoupledCodec
open Ephemeral.ScopeCodec (encodeFixed parseFixed parseFixed_encodeFixed encodeFixed_append)
open Storage.TransportCodec (encodeRat parseRat parseRat_encodeRat encodeRat_append)

/-- The eight supported public certificate claims; their tags are fixed below. -/
inductive Claim where
  | nativeCiphertext
  | stageCertificate
  | sourceMetric
  | pluckerMetric
  | publicShadowRespect
  | semanticAlignment
  | projectionNaturality
  | finalFarRegion
  deriving DecidableEq

namespace Claim

def tag : Claim → ℕ
  | .nativeCiphertext => 0
  | .stageCertificate => 1
  | .sourceMetric => 2
  | .pluckerMetric => 3
  | .publicShadowRespect => 4
  | .semanticAlignment => 5
  | .projectionNaturality => 6
  | .finalFarRegion => 7

def ofTag : ℕ → Option Claim
  | 0 => some .nativeCiphertext
  | 1 => some .stageCertificate
  | 2 => some .sourceMetric
  | 3 => some .pluckerMetric
  | 4 => some .publicShadowRespect
  | 5 => some .semanticAlignment
  | 6 => some .projectionNaturality
  | 7 => some .finalFarRegion
  | _ => none

@[simp] theorem ofTag_tag (claim : Claim) : ofTag claim.tag = some claim := by
  cases claim <;> rfl

def encode (claim : Claim) (rest : Bytes) : Bytes := encodeNat claim.tag rest

def parse (bytes : Bytes) : Option (Claim × Bytes) := do
  let (tag, rest) ← parseNat bytes
  let claim ← ofTag tag
  some (claim, rest)

@[simp] theorem parse_encode (claim : Claim) (rest : Bytes) :
    parse (encode claim rest) = some (claim, rest) := by
  simp [parse, encode]

theorem encode_append (claim : Claim) (rest suffix : Bytes) :
    encode claim rest ++ suffix = encode claim (rest ++ suffix) :=
  encodeNat_append _ _ _

end Claim

/-- Raw finite calibration coordinates. Inequalities are checked separately. -/
structure Calibration where
  sourceNear : ℚ
  sourceFar : ℚ
  targetNear : ℚ
  targetFar : ℚ
  deriving DecidableEq

namespace Calibration

def encode (calibration : Calibration) (rest : Bytes) : Bytes :=
  encodeRat calibration.sourceNear
    (encodeRat calibration.sourceFar
      (encodeRat calibration.targetNear (encodeRat calibration.targetFar rest)))

def parse (bytes : Bytes) : Option (Calibration × Bytes) := do
  let (sourceNear, rest) ← parseRat bytes
  let (sourceFar, rest) ← parseRat rest
  let (targetNear, rest) ← parseRat rest
  let (targetFar, rest) ← parseRat rest
  some (⟨sourceNear, sourceFar, targetNear, targetFar⟩, rest)

@[simp] theorem parse_encode (calibration : Calibration) (rest : Bytes) :
    parse (encode calibration rest) = some (calibration, rest) := by
  cases calibration
  simp [parse, encode]

theorem encode_append (calibration : Calibration) (rest suffix : Bytes) :
    encode calibration rest ++ suffix = encode calibration (rest ++ suffix) := by
  simp [encode, encodeRat_append]

end Calibration

def encodeCalibration : Option Calibration → Bytes → Bytes
  | none, rest => 0 :: rest
  | some calibration, rest => 1 :: Calibration.encode calibration rest

def parseCalibration : Bytes → Option (Option Calibration × Bytes)
  | [] => none
  | tag :: rest =>
    if tag = 0 then some (none, rest)
    else if tag = 1 then
      (Calibration.parse rest).map (fun value => (some value.1, value.2))
    else none

@[simp] theorem parseCalibration_encodeCalibration (calibration : Option Calibration)
    (rest : Bytes) :
    parseCalibration (encodeCalibration calibration rest) = some (calibration, rest) := by
  cases calibration <;> simp [parseCalibration, encodeCalibration]

theorem encodeCalibration_append (calibration : Option Calibration) (rest suffix : Bytes) :
    encodeCalibration calibration rest ++ suffix =
      encodeCalibration calibration (rest ++ suffix) := by
  cases calibration <;> simp [encodeCalibration, Calibration.encode_append]

/-- Exactly the public subject. Profile bytes require an actual-object semantic
binding; their presence is not a decoder or registry correctness assumption. -/
structure Subject (Owner : Type) where
  metadata : ProofMetadata
  intent : Intent Owner
  ciphertextDigest : TCB.Hash32
  profile : Bytes
  calibration : Option Calibration
  claim : Claim

/-- ASCII `HODGE_CERTIFICATE_SUBJECT_V1`. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 67, 69, 82, 84, 73, 70, 73, 67, 65, 84, 69, 95,
    83, 85, 66, 74, 69, 67, 84, 95, 86, 49]

variable {Owner : Type}

def encodeBody (codec : Evidence.TransferCheck.PacketCodec Owner)
    (subject : Subject Owner) (rest : Bytes) : Bytes :=
  Claim.encode subject.claim
    (encodeFixed subject.ciphertextDigest
      (frame subject.profile
        (encodeCalibration subject.calibration
          (frame (codec.encode (Signing.skeleton subject.metadata subject.intent)) rest))))

def parseBody (codec : Evidence.TransferCheck.PacketCodec Owner)
    (bytes : Bytes) : Option (Subject Owner × Bytes) := do
  let (claim, rest) ← Claim.parse bytes
  let (ciphertextDigest, rest) ← parseFixed 32 rest
  let (profile, rest) ← parseFrame rest
  let (calibration, rest) ← parseCalibration rest
  let (skeletonBytes, rest) ← parseFrame rest
  let packet ← codec.decode skeletonBytes
  if packet.ownerSignature = [] ∧ packet.proofBytes = [] then
    some (⟨packet.metadata, packet.intent, ciphertextDigest, profile, calibration, claim⟩, rest)
  else none

@[simp] theorem parseBody_encodeBody (codec : Evidence.TransferCheck.PacketCodec Owner)
    (subject : Subject Owner) (rest : Bytes) :
    parseBody codec (encodeBody codec subject rest) = some (subject, rest) := by
  cases subject
  simp [parseBody, encodeBody, parseFrame_frame, codec.decode_encode, Signing.skeleton]

def encode (codec : Evidence.TransferCheck.PacketCodec Owner) (subject : Subject Owner) : Bytes :=
  domain ++ encodeBody codec subject []

/-- Canonical parser including exact domain, empty suffix and re-encoding. -/
def decode (codec : Evidence.TransferCheck.PacketCodec Owner) (bytes : Bytes) :
    Option (Subject Owner) :=
  match parseBody codec (bytes.drop domain.length) with
  | none => none
  | some (subject, rest) =>
    if rest = [] ∧ bytes = encode codec subject then some subject else none

@[simp] theorem decode_encode (codec : Evidence.TransferCheck.PacketCodec Owner)
    (subject : Subject Owner) : decode codec (encode codec subject) = some subject := by
  simp [decode, encode]

theorem decode_eq_some_iff (codec : Evidence.TransferCheck.PacketCodec Owner)
    (bytes : Bytes) (subject : Subject Owner) :
    decode codec bytes = some subject ↔ bytes = encode codec subject := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody codec (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next same =>
        have subjectEq : other = subject := Option.some.inj decoded
        subst other
        exact same.2
      next => contradiction
  · rintro rfl
    exact decode_encode codec subject

theorem encode_injective (codec : Evidence.TransferCheck.PacketCodec Owner) :
    Function.Injective (encode codec) := by
  intro left right same
  have decoded := congrArg (decode codec) same
  simpa only [decode_encode, Option.some.injEq] using decoded

/-- Exact bytes reflect all public coordinates, including full metadata and
the original intent. No identifier is substituted for its selected meaning. -/
theorem encode_eq_iff (codec : Evidence.TransferCheck.PacketCodec Owner)
    (left right : Subject Owner) :
    encode codec left = encode codec right ↔ left = right :=
  ⟨fun same => encode_injective codec same, congrArg (encode codec)⟩

theorem metadata_eq_of_encode_eq (codec : Evidence.TransferCheck.PacketCodec Owner)
    {left right : Subject Owner} (same : encode codec left = encode codec right) :
    left.metadata = right.metadata := congrArg Subject.metadata (encode_injective codec same)

theorem intent_eq_of_encode_eq (codec : Evidence.TransferCheck.PacketCodec Owner)
    {left right : Subject Owner} (same : encode codec left = encode codec right) :
    left.intent = right.intent := congrArg Subject.intent (encode_injective codec same)

theorem ciphertextDigest_eq_of_encode_eq (codec : Evidence.TransferCheck.PacketCodec Owner)
    {left right : Subject Owner} (same : encode codec left = encode codec right) :
    left.ciphertextDigest = right.ciphertextDigest :=
  congrArg Subject.ciphertextDigest (encode_injective codec same)

theorem profile_eq_of_encode_eq (codec : Evidence.TransferCheck.PacketCodec Owner)
    {left right : Subject Owner} (same : encode codec left = encode codec right) :
    left.profile = right.profile := congrArg Subject.profile (encode_injective codec same)

theorem calibration_eq_of_encode_eq (codec : Evidence.TransferCheck.PacketCodec Owner)
    {left right : Subject Owner} (same : encode codec left = encode codec right) :
    left.calibration = right.calibration := congrArg Subject.calibration (encode_injective codec same)

theorem claim_eq_of_encode_eq (codec : Evidence.TransferCheck.PacketCodec Owner)
    {left right : Subject Owner} (same : encode codec left = encode codec right) :
    left.claim = right.claim := congrArg Subject.claim (encode_injective codec same)

theorem encodeBody_append (codec : Evidence.TransferCheck.PacketCodec Owner)
    (subject : Subject Owner) (rest suffix : Bytes) :
    encodeBody codec subject rest ++ suffix = encodeBody codec subject (rest ++ suffix) := by
  simp [encodeBody, Claim.encode_append, encodeFixed_append, frame_append,
    encodeCalibration_append]

theorem parseBody_encode_append (codec : Evidence.TransferCheck.PacketCodec Owner)
    (subject : Subject Owner) (suffix : Bytes) :
    parseBody codec ((encode codec subject ++ suffix).drop domain.length) =
      some (subject, suffix) := by
  rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
  simp

theorem decode_rejects_trailing (codec : Evidence.TransferCheck.PacketCodec Owner)
    (subject : Subject Owner) (suffix : Bytes) (nonempty : suffix ≠ []) :
    decode codec (encode codec subject ++ suffix) = none := by
  simp [decode, parseBody_encode_append, nonempty]

theorem decode_rejects_wrong_domain (codec : Evidence.TransferCheck.PacketCodec Owner)
    (bytes : Bytes) (wrong : bytes.take domain.length ≠ domain) : decode codec bytes = none := by
  cases parsed : decode codec bytes with
  | none => rfl
  | some subject =>
    have canonical := (decode_eq_some_iff codec bytes subject).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

/-- Canonical parsing and the actual byte digest check, independently of
certificate truth or a proof-verification result. -/
def check (codec : Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (expectedDigest : TCB.Hash32) (bytes : Bytes) :
    Option (Subject Owner) := do
  let subject ← decode codec bytes
  if hash bytes = expectedDigest then some subject else none

theorem check_eq_some_iff (codec : Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (expectedDigest : TCB.Hash32)
    (bytes : Bytes) (subject : Subject Owner) :
    check codec hash expectedDigest bytes = some subject ↔
      bytes = encode codec subject ∧ hash bytes = expectedDigest := by
  cases parsed : decode codec bytes with
  | none => simp [check, parsed, ← decode_eq_some_iff]
  | some other =>
    have canonical := (decode_eq_some_iff codec bytes other).mp parsed
    have subjectEq : bytes = encode codec subject ↔ other = subject := by
      constructor
      · intro same
        exact encode_injective codec (canonical.symm.trans same)
      · rintro rfl
        exact canonical
    by_cases sameHash : hash bytes = expectedDigest <;>
      simp [check, parsed, sameHash, subjectEq]

@[simp] theorem check_encode (codec : Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (subject : Subject Owner) :
    check codec hash (hash (encode codec subject)) (encode codec subject) = some subject :=
  (check_eq_some_iff codec hash _ _ subject).mpr ⟨rfl, rfl⟩

/-- Accepted replacement changes no public subject coordinate unless it
exhibits distinct canonical bytes with the same actual digest. -/
theorem check_original_or_collision (codec : Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (original returned : Subject Owner) (bytes : Bytes)
    (accepted : check codec hash (hash (encode codec original)) bytes = some returned) :
    returned = original ∨
      (bytes ≠ encode codec original ∧ hash bytes = hash (encode codec original)) := by
  classical
  obtain ⟨canonical, checked⟩ := (check_eq_some_iff codec hash _ bytes returned).mp accepted
  by_cases same : returned = original
  · exact Or.inl same
  · refine Or.inr ⟨?_, checked⟩
    intro sameBytes
    exact same (encode_injective codec (canonical.symm.trans sameBytes))

end HomotopicalEncryption.Protocol.Transfer.Certificates.Codec
