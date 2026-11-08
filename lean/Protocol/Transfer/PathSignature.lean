module

public import Protocol.Ephemeral.Rotation
public import Protocol.Transfer.Authorization
public import Protocol.Transfer.PathSignature.Codec

@[expose] public section

/-!
# Native path witnesses at the existing owner-verifier boundary

A partial decoder selects a supported finite-byte witness profile. Its output
reuses a private base, credential opening and the original ephemeral path;
validity requires the actual opening relation and a proof of admissibility.
No total encoding of arbitrary continuous paths or real maps is assumed.
The chosen path realization constructs the original rotation and its recovery
law, without introducing another fibration, owner registry or rotation carrier.

The existing proof verifier executes through `asSignatureVerifier`, on the
selected credential and full signing message, using `ownerSignature` bytes.
Public-input reflection is an explicit encoder law. Backend-statement
reflection is separately required to infer existence of a valid finite witness.
That existence does not depend on the message and is not knowledge security:
a backend may ignore its public input. Actual transcript binding, extraction,
unforgeability, setup, decoding algorithms and authenticated credential setup
remain separate obligations. The original cochain payload proof is unchanged.
-/

set_option autoImplicit false

namespace Hcrypt.Protocol.Transfer.PathSignature

open Sheaf CellularSheaf
open Evidence.TransferTranscript
open TCB.PrimitiveChecks

variable {Key Rep Opening Owner : Type} [Axioms.HasPathSpace Rep]
  {classifier : Axioms.FibrationClassifier Rep}

/-- Finite private bytes decode to the designated credential opening and an
admissible original path. The decoder may support only a restricted profile. -/
def WitnessRelation (opens : Key → Rep → Opening → Prop)
    (decode : Bytes → Option (Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base))
    (key : Key) (witness : Bytes) : Prop :=
  ∃ decoded, decode witness = some decoded ∧
    opens key decoded.1 decoded.2.1 ∧ decoded.2.2.WellFormed

/-- Deterministic decoding identifies the exact private base, opening and path
whose admissibility is required, rather than an unrelated existential witness. -/
theorem witnessRelation_iff_of_decode (opens : Key → Rep → Opening → Prop)
    (decode : Bytes → Option (Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base))
    {key : Key} {witness : Bytes}
    {decoded : Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base}
    (decodes : decode witness = some decoded) :
    WitnessRelation opens decode key witness ↔
      opens key decoded.1 decoded.2.1 ∧ decoded.2.2.WellFormed := by
  constructor
  · rintro ⟨other, otherDecodes, opened, admissible⟩
    have same : other = decoded := Option.some.inj (otherDecodes.symm.trans decodes)
    subst other
    exact ⟨opened, admissible⟩
  · rintro ⟨opened, admissible⟩
    exact ⟨decoded, decodes, opened, admissible⟩

/-- The finite relation retains a credential opening for the actual public key.
No individual-owner binding is inferred from a public homotopy-class label. -/
theorem witnessRelation_credential (opens : Key → Rep → Opening → Prop)
    (decode : Bytes → Option (Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base))
    {key : Key} {witness : Bytes} (valid : WitnessRelation opens decode key witness) :
    ∃ base opening, opens key base opening := by
  obtain ⟨decoded, _decodes, opened, _admissible⟩ := valid
  exact ⟨decoded.1, decoded.2.1, opened⟩

/-- Under the existing classifier law, this very decoded path preserves class. -/
theorem witnessRelation_class (opens : Key → Rep → Opening → Prop)
    (decode : Bytes → Option (Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base))
    (respects : Axioms.PathRespectsHomotopyClass classifier)
    {key : Key} {witness : Bytes} (valid : WitnessRelation opens decode key witness) :
    ∃ decoded, decode witness = some decoded ∧
      opens key decoded.1 decoded.2.1 ∧
      classifier.π decoded.2.2.representative = classifier.π decoded.1 := by
  obtain ⟨decoded, decodes, opened, _admissible⟩ := valid
  exact ⟨decoded, decodes, opened, decoded.2.2.samePublicFingerprint respects⟩

section Geometry

variable {Vertex Edge Face Rank : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face] [Fintype Rank]
  {X : OrientedTwoComplex Vertex Edge Face}
  {family : Rep → CellularSheaf X}
  {integrals : ∀ r, IntegralStructure (family r)}
  {presentations : ∀ r, HarmonicLatticePresentation (integrals r) Rank}

/-- Construct the existing rotation using the actual path decoded from finite
witness bytes. Both credential opening and admissibility remain required. -/
def rotationOfWitness (opens : Key → Rep → Opening → Prop)
    (decode : Bytes → Option (Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base))
    (realize : ∀ {x y : Rep}, Axioms.HasPathSpace.Path x y →
      Ephemeral.PresentedRotation (presentations x) (presentations y))
    {key : Key} {witness : Bytes}
    {decoded : Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base}
    (decodes : decode witness = some decoded)
    (valid : WitnessRelation opens decode key witness) :
    Ephemeral.EphemeralRotation family integrals presentations decoded.2.2 :=
  Ephemeral.EphemeralRotation.ofPath realize
    ((witnessRelation_iff_of_decode opens decode decodes).mp valid).2

/-- The finite witness selects the same path transport as its retained rotation. -/
theorem rotationOfWitness_transport (opens : Key → Rep → Opening → Prop)
    (decode : Bytes → Option (Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base))
    (realize : ∀ {x y : Rep}, Axioms.HasPathSpace.Path x y →
      Ephemeral.PresentedRotation (presentations x) (presentations y))
    {key : Key} {witness : Bytes}
    {decoded : Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base}
    (decodes : decode witness = some decoded)
    (valid : WitnessRelation opens decode key witness) (b : (family decoded.1).C1) :
    (rotationOfWitness opens decode realize decodes valid).rotation.rotateObserved b =
      (Ephemeral.PresentedRotation.pathFiberSystem realize).transport decoded.2.2.path b := rfl

/-- Original coefficients are recovered using the same decoded path and actual
inverse rotation. This is mathematical recovery, not an efficient signer. -/
theorem rotationOfWitness_recovery (opens : Key → Rep → Opening → Prop)
    (decode : Bytes → Option (Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base))
    (realize : ∀ {x y : Rep}, Axioms.HasPathSpace.Path x y →
      Ephemeral.PresentedRotation (presentations x) (presentations y))
    {key : Key} {witness : Bytes}
    {decoded : Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base}
    (decodes : decode witness = some decoded)
    (valid : WitnessRelation opens decode key witness)
    (z : Rank → ℤ) (noise : HodgeNoise (family decoded.1)) :
    (rotationOfWitness opens decode realize decodes valid).rotation.recoverWithBase
      ((Ephemeral.PresentedRotation.pathFiberSystem realize).transport decoded.2.2.path
        ((presentations decoded.1).encrypt z noise).observed) = some z :=
  (realize decoded.2.2.path).recoverWithBase_rotated_encrypt z noise

end Geometry

/-- An injective selected public-input encoding reflects the credential key,
complete metadata and original full intent. This is not transcript security. -/
theorem input_subject_eq (inputFor : Key → Bytes → Bytes)
    (reflects : Function.Injective (fun subject : Key × Bytes => inputFor subject.1 subject.2))
    (codec : Evidence.TransferCheck.PacketCodec Owner)
    {leftKey rightKey : Key} {leftMetadata rightMetadata : ProofMetadata}
    {leftIntent rightIntent : Intent Owner}
    (same : inputFor leftKey (Signing.message codec leftMetadata leftIntent) =
      inputFor rightKey (Signing.message codec rightMetadata rightIntent)) :
    leftKey = rightKey ∧ leftMetadata = rightMetadata ∧ leftIntent = rightIntent := by
  have subjects : (leftKey, Signing.message codec leftMetadata leftIntent) =
      (rightKey, Signing.message codec rightMetadata rightIntent) := reflects same
  exact ⟨congrArg Prod.fst subjects,
    (Signing.message_eq_iff codec _ _ _ _).mp (congrArg Prod.snd subjects)⟩

/-- The concrete canonical byte codec discharges the outer input-injectivity
premise for byte-valued public credentials and the original signing subject. -/
theorem canonical_input_subject_eq (codec : Evidence.TransferCheck.PacketCodec Owner)
    {leftKey rightKey : Bytes} {leftMetadata rightMetadata : ProofMetadata}
    {leftIntent rightIntent : Intent Owner}
    (same : Codec.encode leftKey (Signing.message codec leftMetadata leftIntent) =
      Codec.encode rightKey (Signing.message codec rightMetadata rightIntent)) :
    leftKey = rightKey ∧ leftMetadata = rightMetadata ∧ leftIntent = rightIntent :=
  input_subject_eq Codec.encode Codec.encode_injective codec same

/-- Native proof bytes occupy the original owner-signature field and execute
the supplied proof backend on the selected key and exact full-intent message. -/
theorem checker_verify (backend : ProofVerifier) (inputFor : Key → Bytes → Bytes)
    (codec : Evidence.TransferCheck.PacketCodec Owner) (metadata : ProofMetadata)
    (keyFor : Owner → Key) (authorized : Owner → Intent Owner → Prop)
    (owner : Owner) (intent : Intent Owner) (signature : Bytes) :
    (Authorization.checker codec metadata (backend.asSignatureVerifier inputFor)
      keyFor authorized).verify owner intent signature =
      backend.verify (inputFor (keyFor owner) (Signing.message codec metadata intent)) signature := rfl

/-- Backend truth must separately reflect the chosen finite witness relation.
This derives existence or actual false acceptance, not knowledge or forgery bounds. -/
theorem verified_witness_or_falseAccept (backend : ProofVerifier)
    (inputFor : Key → Bytes → Bytes) (opens : Key → Rep → Opening → Prop)
    (decode : Bytes → Option (Σ base : Rep, Opening × Axioms.EphemeralFiberSpec classifier base))
    (key : Key) (message signature : Bytes)
    (reflects : backend.Holds (inputFor key message) → ∃ witness, WitnessRelation opens decode key witness)
    (verified : (backend.asSignatureVerifier inputFor).verify key message signature = true) :
    (∃ witness, WitnessRelation opens decode key witness) ∨
      backend.FalseAccept (inputFor key message) signature := by
  rcases backend.verified_cases (inputFor key message) signature verified with holds | falseAccept
  · exact Or.inl (reflects holds)
  · exact Or.inr falseAccept

section Operational

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- The actual parsed release verifies its original owner-signature bytes for
the existing expected full intent. The separate payload proof is untouched. -/
theorem checked_signature_verified (base : Operational.Config F Owner Asset Receipt)
    (backend : ProofVerifier) (inputFor : Key → Bytes → Bytes) (keyFor : Owner → Key)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (Authorization.configure base (backend.asSignatureVerifier inputFor) keyFor) transfer bytes) :
    backend.verify
      (inputFor (keyFor transfer.signer) (Signing.message base.codec base.metadata (base.intentFor transfer)))
      checked.proof.packet.ownerSignature = true := by
  have verified := checked.proof.signatureVerified
  change backend.verify
    (inputFor (keyFor checked.proof.packet.intent.transfer.signer)
      (Signing.message base.codec base.metadata checked.proof.packet.intent))
    checked.proof.packet.ownerSignature = true at verified
  rw [checked.proof.intent_eq] at verified
  exact verified

end Operational

end Hcrypt.Protocol.Transfer.PathSignature
