module

public import Protocol.Evidence.TransferCheck

@[expose] public section

/-!
# A full-intent signing message from the existing packet codec

The signing subject is the existing metadata and pre-proof `Intent`. Its
packet skeleton has empty signature and proof bytes, so signing introduces no
self-reference. Prefixing the existing roundtrip codec's output with the owner
domain gives an injective encoding of that full subject. The codec is still a
supplied implementation contract; this module constructs no new concrete wire
serializer or cryptographic signature algorithm.

Full-intent reflection preserves the original transfer signer, context/payload,
source evidence, proposal draft and input-manifest root without a second schema.
The owner domain is disjoint from the existing worker spectral-signature prefix.
This is equality of exact message bytes, not a hash-injectivity assumption or a
proof of authorization, key ownership, unforgeability or transcript privacy.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Signing

open Evidence.TransferTranscript

/-- The owner-intent signing domain, represented by its exact ASCII bytes. -/
def domain : List UInt8 :=
  [72, 79, 77, 79, 84, 79, 80, 73, 67, 65, 76, 95, 69, 78, 67, 82, 89, 80, 84, 95,
    79, 87, 78, 69, 82, 95, 73, 78, 84, 69, 78, 84, 95, 86, 49]

/-- The existing runtime worker-signature domain, kept distinct from owner intents. -/
def spectralDomain : List UInt8 :=
  [72, 79, 77, 79, 84, 79, 80, 73, 67, 65, 76, 95, 69, 78, 67, 82, 89, 80, 84, 95,
    83, 80, 69, 67, 84, 82, 65, 76, 95, 80, 82, 79, 79, 70, 95, 86, 49]

/-- The existing public packet with no signature/proof output in its own preimage. -/
def skeleton {Owner : Type} (metadata : ProofMetadata) (intent : Intent Owner) :
    ProofPacket Owner where
  metadata := metadata
  intent := intent
  ownerSignature := []
  proofBytes := []

/-- Canonical signing bytes relative to the existing supplied packet codec. -/
def message {Owner : Type} (codec : Evidence.TransferCheck.PacketCodec Owner)
    (metadata : ProofMetadata) (intent : Intent Owner) : List UInt8 :=
  domain ++ codec.encode (skeleton metadata intent)

/-- An exact owner-domain prefix, with any remaining message bytes. -/
def InDomain (bytes : List UInt8) : Prop :=
  ∃ suffix : List UInt8, bytes = domain ++ suffix

variable {Owner : Type}

@[simp]
theorem skeleton_metadata (metadata : ProofMetadata) (intent : Intent Owner) :
    (skeleton metadata intent).metadata = metadata := rfl

@[simp]
theorem skeleton_intent (metadata : ProofMetadata) (intent : Intent Owner) :
    (skeleton metadata intent).intent = intent := rfl

@[simp]
theorem skeleton_ownerSignature (metadata : ProofMetadata) (intent : Intent Owner) :
    (skeleton metadata intent).ownerSignature = [] := rfl

@[simp]
theorem skeleton_proofBytes (metadata : ProofMetadata) (intent : Intent Owner) :
    (skeleton metadata intent).proofBytes = [] := rfl

/-- Equal signing bytes identify both the exact metadata and original full intent. -/
theorem message_eq_iff (codec : Evidence.TransferCheck.PacketCodec Owner)
    (leftMetadata rightMetadata : ProofMetadata) (leftIntent rightIntent : Intent Owner) :
    message codec leftMetadata leftIntent = message codec rightMetadata rightIntent ↔
      leftMetadata = rightMetadata ∧ leftIntent = rightIntent := by
  constructor
  · intro same
    have encoded : codec.encode (skeleton leftMetadata leftIntent) =
        codec.encode (skeleton rightMetadata rightIntent) :=
      List.append_cancel_left same
    have packet := codec.encode_injective encoded
    exact ⟨congrArg ProofPacket.metadata packet, congrArg ProofPacket.intent packet⟩
  · rintro ⟨rfl, rfl⟩
    rfl

theorem message_metadata_eq (codec : Evidence.TransferCheck.PacketCodec Owner)
    {leftMetadata rightMetadata : ProofMetadata} {leftIntent rightIntent : Intent Owner}
    (same : message codec leftMetadata leftIntent = message codec rightMetadata rightIntent) :
    leftMetadata = rightMetadata :=
  ((message_eq_iff codec _ _ _ _).1 same).1

theorem message_intent_eq (codec : Evidence.TransferCheck.PacketCodec Owner)
    {leftMetadata rightMetadata : ProofMetadata} {leftIntent rightIntent : Intent Owner}
    (same : message codec leftMetadata leftIntent = message codec rightMetadata rightIntent) :
    leftIntent = rightIntent :=
  ((message_eq_iff codec _ _ _ _).1 same).2

/-- The complete signing subject is reflected, without requiring injective owner keys. -/
theorem message_injective (codec : Evidence.TransferCheck.PacketCodec Owner) :
    Function.Injective (fun subject : ProofMetadata × Intent Owner =>
      message codec subject.1 subject.2) := by
  intro left right same
  exact Prod.ext (message_metadata_eq codec same) (message_intent_eq codec same)

theorem message_ne_of_metadata_ne (codec : Evidence.TransferCheck.PacketCodec Owner)
    {leftMetadata rightMetadata : ProofMetadata} {leftIntent rightIntent : Intent Owner}
    (different : leftMetadata ≠ rightMetadata) :
    message codec leftMetadata leftIntent ≠ message codec rightMetadata rightIntent :=
  fun same => different (message_metadata_eq codec same)

theorem message_ne_of_intent_ne (codec : Evidence.TransferCheck.PacketCodec Owner)
    {leftMetadata rightMetadata : ProofMetadata} {leftIntent rightIntent : Intent Owner}
    (different : leftIntent ≠ rightIntent) :
    message codec leftMetadata leftIntent ≠ message codec rightMetadata rightIntent :=
  fun same => different (message_intent_eq codec same)

/-- Every constructed signing message has the actual owner-domain prefix. -/
theorem message_inDomain (codec : Evidence.TransferCheck.PacketCodec Owner)
    (metadata : ProofMetadata) (intent : Intent Owner) :
    InDomain (message codec metadata intent) :=
  ⟨codec.encode (skeleton metadata intent), rfl⟩

/-- The first byte after `HOMOTOPICAL_ENCRYPT_` differs for owner and worker spectral messages. -/
theorem domain_append_ne_spectralDomain_append (ownerSuffix spectralSuffix : List UInt8) :
    domain ++ ownerSuffix ≠ spectralDomain ++ spectralSuffix := by
  intro same
  have atBoundary := congrArg (fun bytes : List UInt8 => bytes[20]?) same
  have ownerByte : (domain ++ ownerSuffix)[20]? = some (79 : UInt8) := by
    rw [List.getElem?_append_left (by decide : 20 < domain.length)]
    rfl
  have spectralByte : (spectralDomain ++ spectralSuffix)[20]? = some (83 : UInt8) := by
    rw [List.getElem?_append_left (by decide : 20 < spectralDomain.length)]
    rfl
  rw [ownerByte, spectralByte] at atBoundary
  exact (by decide : (79 : UInt8) ≠ 83) (Option.some.inj atBoundary)

/-- Every existing spectral-domain message is outside the owner-intent domain. -/
theorem not_inDomain_spectralMessage (suffix : List UInt8) :
    ¬ InDomain (spectralDomain ++ suffix) := by
  rintro ⟨ownerSuffix, same⟩
  exact domain_append_ne_spectralDomain_append ownerSuffix suffix same.symm

/-- Owner signing bytes differ from every existing spectral-domain message. -/
theorem message_ne_spectralMessage (codec : Evidence.TransferCheck.PacketCodec Owner)
    (metadata : ProofMetadata) (intent : Intent Owner) (suffix : List UInt8) :
    message codec metadata intent ≠ spectralDomain ++ suffix :=
  domain_append_ne_spectralDomain_append (codec.encode (skeleton metadata intent)) suffix

end HomotopicalEncryption.Protocol.Transfer.Signing
