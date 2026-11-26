module

public import Protocol.Transfer.PathSignature.NativeCommittedRelease

@[expose] public section

/-!
# Operational checking of assembled V2 evidence

The original configuration verifies the bytes assembled from the V2 instance
and the two generated evidence strings. The codec round trip supplies its
parser result. Resource and snapshot checks and the two Boolean verifier
results suffice for operational acceptance of that exact release.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease.Inputs

open Sheaf CellularSheaf
open Evidence.TransferTranscript

variable {Vertex Edge Face Owner Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- The assembled bytes parse to the original intent and the generated
evidence, with checked fields for the supplied operational configuration. -/
def checkedOfAssembly (inputs : Inputs Owner)
    {config : Operational.Config F Owner Asset Receipt}
    (prechecks : Operational.Prechecks config inputs.transfer)
    (aligned : MatchesConfig inputs config) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer) =
      some publicInput)
    (ownerSignature proofBytes : List UInt8)
    (signatureVerified : config.authorization.verify inputs.transfer.signer
      (config.intentFor inputs.transfer) ownerSignature = true)
    (proofVerified : config.payload.verify (config.intentFor inputs.transfer) proofBytes = true) :
    Operational.CheckedTransfer config inputs.transfer
      (inputs.assemble publicInput ownerSignature proofBytes).packetBytes := by
  let packet : ProofPacket Owner :=
    ⟨config.metadata, config.intentFor inputs.transfer, ownerSignature, proofBytes⟩
  have encoded : (inputs.assemble publicInput ownerSignature proofBytes).packetBytes =
      config.codec.encode packet :=
    congrArg Owned.PublicTransferView.packetBytes
      (inputs.assemble_eq_config prechecks aligned credentialFor publicInput parsed
        ownerSignature proofBytes)
  exact ⟨prechecks, ⟨packet, by rw [encoded, config.codec.decode_encode], encoded,
    rfl, rfl, signatureVerified, proofVerified⟩⟩

/-- The real Boolean checker accepts the exact canonical bytes of this
assembly when both configured verifiers accept the generated evidence. -/
theorem check_assemble (inputs : Inputs Owner)
    {config : Operational.Config F Owner Asset Receipt}
    (prechecks : Operational.Prechecks config inputs.transfer)
    (aligned : MatchesConfig inputs config) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer) =
      some publicInput)
    (ownerSignature proofBytes : List UInt8)
    (signatureVerified : config.authorization.verify inputs.transfer.signer
      (config.intentFor inputs.transfer) ownerSignature = true)
    (proofVerified : config.payload.verify (config.intentFor inputs.transfer) proofBytes = true) :
    Operational.check config inputs.transfer
      (inputs.assemble publicInput ownerSignature proofBytes).packetBytes = true :=
  (inputs.checkedOfAssembly prechecks aligned credentialFor publicInput parsed
    ownerSignature proofBytes signatureVerified proofVerified).check_true

/-- The assembled public release is exactly the view of the checked packet. -/
theorem assemble_eq_checkedOfAssembly (inputs : Inputs Owner)
    {config : Operational.Config F Owner Asset Receipt}
    (prechecks : Operational.Prechecks config inputs.transfer)
    (aligned : MatchesConfig inputs config) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor config credentialFor inputs.transfer.signer) =
      some publicInput)
    (ownerSignature proofBytes : List UInt8)
    (signatureVerified : config.authorization.verify inputs.transfer.signer
      (config.intentFor inputs.transfer) ownerSignature = true)
    (proofVerified : config.payload.verify (config.intentFor inputs.transfer) proofBytes = true) :
    inputs.assemble publicInput ownerSignature proofBytes =
      Owned.PublicTransferView.ofOperational
        (inputs.checkedOfAssembly prechecks aligned credentialFor publicInput parsed
          ownerSignature proofBytes signatureVerified proofVerified) :=
  inputs.assemble_eq_checked
    (inputs.checkedOfAssembly prechecks aligned credentialFor publicInput parsed
      ownerSignature proofBytes signatureVerified proofVerified)
    aligned credentialFor publicInput parsed

variable {Seed VerifierKey PublicCRS Trapdoor Randomness Validator Signature : Type}
  [DecidableEq Validator]
  {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Signature}
  {hash : List UInt8 → TCB.Hash32}

/-- The configured owner checker consumes the verifier result on the exact
assembled signing input when the approved program and reference are selected. -/
theorem approved_ownerSignature_verified (inputs : Inputs Owner)
    {base : Operational.Config F Owner Asset Receipt}
    (prechecks : Operational.Prechecks base inputs.transfer)
    (aligned : MatchesConfig inputs base) (credentialFor : Owner → TCB.Hash32)
    (publicInput : NativeCommitted.Instance)
    (parsed : NativeCommitted.decodeInstance
      (NativeCommittedContext.contextKeyFor base credentialFor inputs.transfer.signer) =
      some publicInput)
    (approval : Certificates.Profile.Approval committee authentication hash)
    (program : NativeCommitted.Program)
    (parseKey : List UInt8 → Option VerifierKey) (parseCRS : List UInt8 → Option PublicCRS)
    (family : NativeCommitted.Program →
      CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (reference : VerifierKey × PublicCRS)
    (exactCode : approval.descriptor.program = NativeCommitted.encodeProgram program)
    (applicable : approval.appliesConfig base (NativeCommitted.encodeProgram program) none none = true)
    (selected : Certificates.Profile.select NativeCommitted.decodeProgram parseKey parseCRS
      approval.descriptor = some (program, reference.1, reference.2))
    (ownerSignature : List UInt8)
    (verified : (family program).verify reference (inputs.signingInputAt publicInput)
      ownerSignature = true) :
    (NativeCommittedContext.configure approval base program parseKey parseCRS family
      credentialFor).authorization.verify inputs.transfer.signer (base.intentFor inputs.transfer)
      ownerSignature = true := by
  let key := NativeCommittedContext.contextKeyFor base credentialFor inputs.transfer.signer
  let message := Signing.message base.codec base.metadata (base.intentFor inputs.transfer)
  change (NativeCommittedContext.signatureVerifier approval base program parseKey parseCRS family).verify
    key message ownerSignature = true
  change (decide (approval.descriptor.program = NativeCommitted.encodeProgram program) &&
    approval.verifyConfig base (NativeCommitted.encodeProgram program) none none
      NativeCommitted.decodeProgram parseKey parseCRS
      (fun chosen k crs input proof => (family chosen).verify (k, crs) input proof)
      (Codec.encode key message) ownerSignature) = true
  simp only [exactCode, decide_true, Bool.true_and]
  rw [approval.verifyConfig_of_selected base (NativeCommitted.encodeProgram program) none none
    NativeCommitted.decodeProgram parseKey parseCRS
    (fun chosen k crs input proof => (family chosen).verify (k, crs) input proof)
    applicable program reference.1 reference.2 selected]
  rw [inputs.signingInputAt_eq_config prechecks aligned credentialFor publicInput parsed] at verified
  exact verified

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease.Inputs
