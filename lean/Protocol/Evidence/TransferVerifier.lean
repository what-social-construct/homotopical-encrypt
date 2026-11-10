module

public import Protocol.Evidence.TransferCheck

@[expose] public section

/-!
# Operational packet checking for the bounded owned-resource transfer

The checker parses actual bytes, requires the exact metadata and public intent,
rejects noncanonical encodings, and invokes the selected signature and payload
proof verifiers. A checked packet contains those checks, not candidate validity
or payload acceptance. The latter facts follow only through explicit indexed
primitive soundness contracts.

The exact-payload verifier is indexed by the actual trusted payload
interpretation. Its soundness contract includes context/interpretation binding
and arithmetization obligations; it does not range over arbitrary decoders
sharing public names. It is not constructed from a matching digest or
statement name. The codec and primitive implementations are supplied; classical
equality makes this a noncomputable Boolean specification, not a verified Rust
parser, efficient proof system or cryptographic security theorem.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Evidence.TransferVerifier

open TransferTranscript
open Sheaf CellularSheaf

/-- Verification of the exact pre-proof intent by its stated owner. -/
structure Authorization (Owner : Type) where
  Authorized : Owner → Intent Owner → Prop
  verify : Owner → Intent Owner → List UInt8 → Bool
  sound : ∀ owner intent signature,
    verify owner intent signature = true → Authorized owner intent

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- A selected exact-payload proof verifier under its actual context binding.
The supplied soundness law is about that original interpretation and artifact;
it is not inferred from equality of public names. -/
structure PayloadVerifier {F : CellularSheaf X}
    (interpretation : CochainPayloadInterpretation F) (Owner : Type)
    (_metadata : ProofMetadata) where
  proofSystem : Axioms.ZKP
  proofSystem_wellFormed : Axioms.ZKPWellFormed proofSystem
  verify : Intent Owner → List UInt8 → Bool
  sound : ∀ (context : Storage.Context F) (intent : Intent Owner) (proofBytes : List UInt8),
    context.interpretation = interpretation →
      intent.base = context.publicView → verify intent proofBytes = true →
      context.Accepted

/-- A concrete encoding/decoding pair remains an implementation parameter. -/
structure PacketCodec (Owner : Type) where
  encode : ProofPacket Owner → List UInt8
  decode : List UInt8 → Option (ProofPacket Owner)
  decode_encode : ∀ packet, decode (encode packet) = some packet

/-- Forget the universal signature-soundness contract, retaining the same algorithm. -/
def Authorization.operational {Owner : Type} (authorization : Authorization Owner) :
    TransferCheck.Authorization Owner where
  Authorized := authorization.Authorized
  verify := authorization.verify

/-- Forget universal payload soundness, retaining its actual interpretation index. -/
def PayloadVerifier.operational {F : CellularSheaf X}
    {interpretation : CochainPayloadInterpretation F} {Owner : Type}
    {metadata : ProofMetadata} (payload : PayloadVerifier interpretation Owner metadata) :
    TransferCheck.PayloadVerifier interpretation Owner metadata where
  verify := payload.verify

/-- Retain this exact canonical encoding and deterministic parser. -/
def PacketCodec.operational {Owner : Type} (codec : PacketCodec Owner) :
    TransferCheck.PacketCodec Owner where
  encode := codec.encode
  decode := codec.decode
  decode_encode := codec.decode_encode

namespace PacketCodec

/-- The roundtrip law prevents two different typed packets sharing canonical bytes. -/
theorem encode_injective {Owner : Type} (codec : PacketCodec Owner) :
    Function.Injective codec.encode :=
  codec.operational.encode_injective

end PacketCodec

variable {Owner : Type} {F : CellularSheaf X}
  {interpretation : CochainPayloadInterpretation F}

/-- Check canonical bytes and every selected public coordinate before primitive verification. -/
def check (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8) : Bool :=
  TransferCheck.check codec.operational expectedMetadata expectedIntent authorization.operational
    payload.operational bytes

/-- Exact contracts and their soundness-free projections execute the same checks. -/
theorem check_eq_operational (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8) :
    check codec expectedMetadata expectedIntent authorization payload bytes =
      TransferCheck.check codec.operational expectedMetadata expectedIntent
        authorization.operational payload.operational bytes := rfl

/-- Actual packet/check evidence, before deriving authorization or exactness. -/
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

/-- Successful Boolean checking supplies the actual parsed packet and its exact checks. -/
theorem check_sound (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8)
    (accepted : check codec expectedMetadata expectedIntent authorization payload bytes = true) :
    Nonempty (CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) := by
  obtain ⟨checked⟩ := TransferCheck.check_sound codec.operational expectedMetadata expectedIntent
    authorization.operational payload.operational bytes accepted
  exact ⟨⟨checked.packet, checked.decoded, checked.canonical, checked.metadata_eq,
    checked.intent_eq, checked.signatureVerified, checked.proofVerified⟩⟩

namespace CheckedPacket

variable {codec : PacketCodec Owner} {expectedMetadata : ProofMetadata}
  {expectedIntent : Intent Owner} {authorization : Authorization Owner}
  {payload : PayloadVerifier interpretation Owner expectedMetadata} {bytes : List UInt8}

/-- Drop the semantic contracts without changing any actual checked coordinate. -/
def operational
    (checked : CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) :
    TransferCheck.CheckedPacket codec.operational expectedMetadata expectedIntent
      authorization.operational payload.operational bytes where
  packet := checked.packet
  decoded := checked.decoded
  canonical := checked.canonical
  metadata_eq := checked.metadata_eq
  intent_eq := checked.intent_eq
  signatureVerified := checked.signatureVerified
  proofVerified := checked.proofVerified

/-- Structural checking can be reused when the separate exact contracts are supplied. -/
def ofOperational
    (checked : TransferCheck.CheckedPacket codec.operational expectedMetadata expectedIntent
      authorization.operational payload.operational bytes) :
    CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes where
  packet := checked.packet
  decoded := checked.decoded
  canonical := checked.canonical
  metadata_eq := checked.metadata_eq
  intent_eq := checked.intent_eq
  signatureVerified := checked.signatureVerified
  proofVerified := checked.proofVerified

/-- Extract the checked value; this is a classical specification, not a parsing algorithm. -/
def ofCheck
    (accepted : check codec expectedMetadata expectedIntent authorization payload bytes = true) :
    CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes :=
  Classical.choice (check_sound codec expectedMetadata expectedIntent authorization payload bytes accepted)

/-- Retained check evidence also establishes success of the Boolean specification. -/
theorem check_true
    (checked : CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) :
    check codec expectedMetadata expectedIntent authorization payload bytes = true :=
  checked.operational.check_true

/-- The indexed signature soundness contract authorizes this exact expected intent. -/
theorem authorized
    (checked : CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) :
    authorization.Authorized expectedIntent.transfer.signer expectedIntent := by
  have result := authorization.sound checked.packet.intent.transfer.signer
    checked.packet.intent checked.packet.ownerSignature checked.signatureVerified
  simpa only [checked.intent_eq] using result

/-- The indexed proof soundness contract accepts the same original payload context. -/
theorem accepted
    (checked : CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes)
    (context : Storage.Context F)
    (interpretation_eq : context.interpretation = interpretation)
    (base_eq : expectedIntent.base = context.publicView) :
    context.Accepted := by
  exact payload.sound context checked.packet.intent checked.packet.proofBytes
    interpretation_eq ((congrArg Intent.base checked.intent_eq).trans base_eq)
    checked.proofVerified

end CheckedPacket

theorem check_true_iff (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8) :
    check codec expectedMetadata expectedIntent authorization payload bytes = true ↔
      Nonempty (CheckedPacket codec expectedMetadata expectedIntent authorization payload bytes) :=
  ⟨check_sound codec expectedMetadata expectedIntent authorization payload bytes,
    fun ⟨checked⟩ => checked.check_true⟩

/-- Malformed bytes cannot reach the primitive verification stages. -/
theorem reject_malformed (codec : PacketCodec Owner) (expectedMetadata : ProofMetadata)
    (expectedIntent : Intent Owner) (authorization : Authorization Owner)
    (payload : PayloadVerifier interpretation Owner expectedMetadata) (bytes : List UInt8)
    (malformed : codec.decode bytes = none) :
    check codec expectedMetadata expectedIntent authorization payload bytes = false :=
  TransferCheck.reject_malformed codec.operational expectedMetadata expectedIntent
    authorization.operational payload.operational bytes malformed

end HomotopicalEncryption.Protocol.Evidence.TransferVerifier
