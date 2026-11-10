module

public import Protocol.Evidence.TransferTranscript

@[expose] public section

/-!
# Soundness-free operational transfer packet checks

These interfaces specify the actual signature and payload-proof algorithms
without assuming that either algorithm is sound. The payload algorithm remains
indexed by its selected trusted interpretation and proof metadata; equality of
public names does not identify arbitrary decoders.

Successful checking supplies parsing, canonical-byte and exact public-input
equalities together with the two actual Boolean verification results. It does
not supply owner authorization, payload acceptance or candidate validity. Those
semantic facts require local good-event premises or separate primitive security
contracts. The classical checker is a mathematical specification, not a verified
runtime parser or an efficient cryptographic implementation.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Evidence.TransferCheck

open TransferTranscript
open Sheaf CellularSheaf

/-- The intended authorization relation and its selected checking algorithm.
No implication from verification to authorization is built into this record. -/
structure Authorization (Owner : Type) where
  Authorized : Owner → Intent Owner → Prop
  verify : Owner → Intent Owner → List UInt8 → Bool

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- The selected payload-proof algorithm under its trusted interpretation.
An index identifies the intended semantics without assuming proof soundness. -/
structure PayloadVerifier {F : CellularSheaf X}
    (_interpretation : CochainPayloadInterpretation F) (Owner : Type)
    (_metadata : ProofMetadata) where
  verify : Intent Owner → List UInt8 → Bool

/-- A canonical packet codec; primitive semantic soundness is separate. -/
structure PacketCodec (Owner : Type) where
  encode : ProofPacket Owner → List UInt8
  decode : List UInt8 → Option (ProofPacket Owner)
  decode_encode : ∀ packet, decode (encode packet) = some packet

namespace PacketCodec

theorem encode_injective {Owner : Type} (codec : PacketCodec Owner) :
    Function.Injective codec.encode := by
  intro left right h
  have decoded := congrArg codec.decode h
  simpa only [codec.decode_encode, Option.some.injEq] using decoded

end PacketCodec

variable {Owner : Type} {F : CellularSheaf X}
  {interpretation : CochainPayloadInterpretation F}

/-- Check actual canonical bytes, exact public inputs and both algorithm results. -/
def check (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8) : Bool := by
  classical
  exact match codec.decode bytes with
    | none => false
    | some packet =>
        ((((decide (packet.metadata = expectedMetadata) &&
          decide (packet.intent = expectedIntent)) &&
          decide (bytes = codec.encode packet)) &&
          authorization.verify packet.intent.transfer.signer packet.intent
            packet.ownerSignature) &&
          payload.verify packet.intent packet.proofBytes)

/-- Exact structural and Boolean evidence, without primitive semantic soundness. -/
structure CheckedPacket (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8) where
  packet : ProofPacket Owner
  decoded : codec.decode bytes = some packet
  canonical : bytes = codec.encode packet
  metadata_eq : packet.metadata = expectedMetadata
  intent_eq : packet.intent = expectedIntent
  signatureVerified : authorization.verify packet.intent.transfer.signer packet.intent
    packet.ownerSignature = true
  proofVerified : payload.verify packet.intent packet.proofBytes = true

theorem check_sound (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8)
    (accepted : check codec expectedMetadata expectedIntent authorization payload bytes = true) :
    Nonempty (CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) := by
  classical
  cases decoded : codec.decode bytes with
  | none => simp [check, decoded] at accepted
  | some packet =>
    simp only [check, decoded, Bool.and_eq_true_iff, decide_eq_true_eq] at accepted
    obtain ⟨⟨⟨⟨metadata, intent⟩, canonical⟩, signature⟩, proof⟩ := accepted
    exact ⟨⟨packet, decoded, canonical, metadata, intent, signature, proof⟩⟩

namespace CheckedPacket

variable {codec : PacketCodec Owner} {expectedMetadata : ProofMetadata}
  {expectedIntent : Intent Owner} {authorization : Authorization Owner}
  {payload : PayloadVerifier interpretation Owner expectedMetadata} {bytes : List UInt8}

def ofCheck
    (accepted : check codec expectedMetadata expectedIntent authorization payload bytes = true) :
    CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes :=
  Classical.choice (check_sound codec expectedMetadata expectedIntent authorization payload bytes accepted)

theorem check_true
    (checked : CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) :
    check codec expectedMetadata expectedIntent authorization payload bytes = true := by
  classical
  simp only [check, checked.decoded, Bool.and_eq_true_iff, decide_eq_true_eq]
  exact ⟨⟨⟨⟨checked.metadata_eq, checked.intent_eq⟩, checked.canonical⟩,
    checked.signatureVerified⟩, checked.proofVerified⟩

/-- The deterministic parser fixes the typed packet for these exact bytes. -/
theorem packet_eq
    (first second : CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) :
    first.packet = second.packet :=
  Option.some.inj (first.decoded.symm.trans second.decoded)

/-- The actual signature check is for the exact expected owner and intent. -/
theorem signatureVerified_expected
    (checked : CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) :
    authorization.verify expectedIntent.transfer.signer expectedIntent
      checked.packet.ownerSignature = true := by
  simpa only [checked.intent_eq] using checked.signatureVerified

/-- The actual proof check is for the exact expected public input. -/
theorem proofVerified_expected
    (checked : CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) :
    payload.verify expectedIntent checked.packet.proofBytes = true := by
  simpa only [checked.intent_eq] using checked.proofVerified

end CheckedPacket

theorem check_true_iff (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8) :
    check codec expectedMetadata expectedIntent authorization payload bytes = true ↔
      Nonempty (CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) :=
  ⟨check_sound codec expectedMetadata expectedIntent authorization payload bytes,
    fun ⟨checked⟩ => checked.check_true⟩

theorem reject_malformed (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8)
    (malformed : codec.decode bytes = none) :
    check codec expectedMetadata expectedIntent authorization payload bytes = false := by
  simp only [check, malformed]

end HomotopicalEncryption.Protocol.Evidence.TransferCheck
