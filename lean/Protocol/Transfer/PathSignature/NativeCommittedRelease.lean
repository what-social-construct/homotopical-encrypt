module

public import Protocol.Transfer.PublicAssembly
public import Protocol.Transfer.PathSignature.NativeCommittedContext

@[expose] public section

/-!
# Reassemble the original checked release from the V2 public instance

The public inputs retain the original transfer, exact artifact and assembly
setup. The V2 snapshot name fills the earlier state's snapshot coordinate and
the base header's snapshot coordinate. The V2 ciphertext name fills the
original manifest slot. The transfer is signed on the full original message.

For a checked transfer the snapshot precheck and actual parsed context key
identify these same names. A pointwise reconstruction result retains the
actual signature, payload proof, proposal and manifest. The two functions
that computed the artifact names need not be shared, since assembly uses
their already released values.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease

open Sheaf CellularSheaf
open Evidence.TransferTranscript

variable {Owner : Type}

/-- The original public assembly fields other than the challenge's two V2 names
and evidence bytes. -/
structure Inputs (Owner : Type) where
  setup : Owned.PublicAssemblySetup Owner
  base : Storage.PublicPayloadView
  transfer : Operational.ResourceTransfer Owner

namespace Inputs

/-- Fill the snapshot coordinate used by the original state-hash preimage. -/
def setupAt (inputs : Inputs Owner) (publicInput : NativeCommitted.Instance) :
    Owned.PublicAssemblySetup Owner :=
  { inputs.setup with
    before := { inputs.setup.before with snapshotRoot := publicInput.targetSnapshot } }

/-- Fill the released snapshot coordinate on the existing artifact header. -/
def baseAt (inputs : Inputs Owner) (publicInput : NativeCommitted.Instance) :
    Storage.PublicPayloadView :=
  { inputs.base with key := { inputs.base.key with snapshotRoot := publicInput.targetSnapshot } }

def intentAt (inputs : Inputs Owner) (publicInput : NativeCommitted.Instance) : Intent Owner :=
  (inputs.setupAt publicInput).intent inputs.transfer (inputs.baseAt publicInput)
    publicInput.ciphertextDigest

/-- The V2 key and the existing canonical full-intent signing message. -/
def signingInputAt (inputs : Inputs Owner) (publicInput : NativeCommitted.Instance) :
    List UInt8 :=
  Codec.encode (NativeCommitted.encodeInstance publicInput)
    (Signing.message inputs.setup.codec inputs.setup.metadata (inputs.intentAt publicInput))

/-- The original public packet, proposal and manifest assembly. -/
def assemble (inputs : Inputs Owner) (publicInput : NativeCommitted.Instance)
    (ownerSignature proofBytes : List UInt8) : Owned.PublicTransferView Owner :=
  (inputs.setupAt publicInput).view inputs.transfer (inputs.baseAt publicInput)
    publicInput.ciphertextDigest ownerSignature proofBytes

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Exact alignment of the reused public data. The snapshot coordinates and
the two functions that already computed artifact names come from the actual
configuration rather than the supplied public inputs. -/
structure MatchesConfig (inputs : Inputs Owner) (config : Operational.Config F Owner Asset Receipt) :
    Prop where
  setup : Owned.PublicAssemblySetup.ofOperational config =
    { inputs.setup with
      before := { inputs.setup.before with snapshotRoot := config.before.snapshotRoot }
      hashes := { inputs.setup.hashes with
        ciphertext := config.hashes.ciphertext, cochain := config.hashes.cochain } }
  base : config.context.publicView =
    { inputs.base with key := { inputs.base.key with snapshotRoot := config.context.key.snapshotRoot } }

/-- The structural snapshot check and parsed V2 key identify the names used
by both the public assembly and the original configuration. -/
theorem matches_at (inputs : Inputs Owner)
    {config : Operational.Config F Owner Asset Receipt}
    (prechecks : Operational.Prechecks config inputs.transfer)
    (aligned : MatchesConfig inputs config) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer) =
      some publicInput) :
    Owned.PublicAssemblySetup.ofOperational config =
      { inputs.setupAt publicInput with hashes := { inputs.setup.hashes with
        ciphertext := config.hashes.ciphertext, cochain := config.hashes.cochain } } ∧
    config.context.publicView = inputs.baseAt publicInput ∧
    config.ciphertextDigest = publicInput.ciphertextDigest := by
  have names := Option.some.inj
    ((NativeCommittedContext.contextKeyFor_decodes config credentialFor inputs.transfer.signer).symm.trans
      parsed)
  have snapshot : config.context.key.snapshotRoot = publicInput.targetSnapshot :=
    congrArg (fun fields : NativeCommitted.Instance => fields.targetSnapshot) names
  have beforeSnapshot : config.before.snapshotRoot = publicInput.targetSnapshot :=
    prechecks.snapshotMatches.symm.trans snapshot
  exact ⟨by simpa only [setupAt, beforeSnapshot] using aligned.setup,
    by simpa only [baseAt, snapshot] using aligned.base,
    congrArg (fun fields : NativeCommitted.Instance => fields.ciphertextDigest) names⟩

/-- Before evidence verification, assembly already constructs the original
configuration's public packet, proposal and manifest. -/
theorem assemble_eq_config (inputs : Inputs Owner)
    {config : Operational.Config F Owner Asset Receipt}
    (prechecks : Operational.Prechecks config inputs.transfer)
    (aligned : MatchesConfig inputs config) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer) =
      some publicInput) (ownerSignature proofBytes : List UInt8) :
    inputs.assemble publicInput ownerSignature proofBytes =
      (Owned.PublicAssemblySetup.ofOperational config).view inputs.transfer
        config.context.publicView config.ciphertextDigest ownerSignature proofBytes := by
  obtain ⟨setup, base, digest⟩ := inputs.matches_at prechecks aligned credentialFor publicInput parsed
  rw [setup, base, digest]
  rfl

/-- Reconstruct every released byte and name of the actual checked packet
from the parsed V2 instance and the original public fields. -/
theorem assemble_eq_checked (inputs : Inputs Owner)
    {config : Operational.Config F Owner Asset Receipt} {bytes : List UInt8}
    (checked : Operational.CheckedTransfer config inputs.transfer bytes)
    (aligned : MatchesConfig inputs config) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer) =
      some publicInput) :
    inputs.assemble publicInput checked.proof.packet.ownerSignature checked.proof.packet.proofBytes =
      Owned.PublicTransferView.ofOperational checked := by
  rw [Owned.PublicTransferView.ofOperational_eq_assembled checked]
  exact inputs.assemble_eq_config checked.prechecks aligned credentialFor publicInput parsed _ _

/-- The assembled intent is the original configuration's expected intent. -/
theorem intentAt_eq_config (inputs : Inputs Owner)
    {config : Operational.Config F Owner Asset Receipt}
    (prechecks : Operational.Prechecks config inputs.transfer)
    (aligned : MatchesConfig inputs config) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer) =
      some publicInput) :
    inputs.intentAt publicInput = config.intentFor inputs.transfer := by
  obtain ⟨setup, base, digest⟩ := inputs.matches_at prechecks aligned credentialFor publicInput parsed
  rw [← Owned.PublicAssemblySetup.ofOperational_intent, setup, base, digest]
  rfl

/-- The reconstructed signing input already matches the context-derived key
and full expected signing subject before evidence verification. -/
theorem signingInputAt_eq_config (inputs : Inputs Owner)
    {config : Operational.Config F Owner Asset Receipt}
    (prechecks : Operational.Prechecks config inputs.transfer)
    (aligned : MatchesConfig inputs config) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer) =
      some publicInput) :
    inputs.signingInputAt publicInput =
      Codec.encode (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer)
        (Signing.message config.codec config.metadata (config.intentFor inputs.transfer)) := by
  have setup := (inputs.matches_at prechecks aligned credentialFor publicInput parsed).1
  have key := (NativeCommitted.decodeInstance_eq_some_iff _ _).mp parsed
  have codec : config.codec = inputs.setup.codec :=
    congrArg Owned.PublicAssemblySetup.codec setup
  have metadata : config.metadata = inputs.setup.metadata :=
    congrArg Owned.PublicAssemblySetup.metadata setup
  rw [signingInputAt, key, ← codec, ← metadata,
    inputs.intentAt_eq_config prechecks aligned credentialFor publicInput parsed]

/-- The reconstructed bytes sent to the V2 proof primitive match the original
context-derived key and full signing subject used by the owner checker. -/
theorem signingInputAt_eq_checked (inputs : Inputs Owner)
    {config : Operational.Config F Owner Asset Receipt} {bytes : List UInt8}
    (checked : Operational.CheckedTransfer config inputs.transfer bytes)
    (aligned : MatchesConfig inputs config) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer) =
      some publicInput) :
    inputs.signingInputAt publicInput =
      Codec.encode (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer)
        (Signing.message config.codec config.metadata (config.intentFor inputs.transfer)) :=
  inputs.signingInputAt_eq_config checked.prechecks aligned credentialFor publicInput parsed

end Inputs
end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease
