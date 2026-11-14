module

public import Protocol.Transfer.Anchored
public import Protocol.Storage.Retrieval.NativeAnchored

@[expose] public section

/-!
# Native recovery through the actual checked owned transfer

This adapter selects canonical native bytes in the existing raw transfer
configuration. It introduces no second manifest or packet profile. The
separate original-observation certificate identifies the context and decoded
full HCP ciphertext; exact-payload verification alone does not supply it.

The checked packet names the same two-slot manifest used by its computed
history anchor. With downloaded-byte availability and the canonical held
transport token, recovery returns the original harmonic coefficients or
exhibits an accepted content-hash collision. The byte/sample equation and
native certificate remain explicit profile facts. They do not identify
coefficients with resource amounts or establish identity privacy, protected
delivery, concrete proof-system security or consensus finality.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.Owned

open Sheaf CellularSheaf HCPCoupledFamily
open Storage Ephemeral Evidence.TransferTranscript

variable {rows cols : ℕ} {B C : Matrix (Fin rows) (Fin cols) ℤ}
  {Owner Asset Receipt : Type}
  {payload : CochainPayloadInterpretation (sheaf C)}
  {PublicClass Lifecycle : Type}
  {classify : SheafStateSnapshot (sheaf C) → PublicClass}
  {Binds : TCB.HCPStackBinding Lifecycle PublicClass (C1 (Fin rows) (Fin cols))}

namespace Config

/-- Construct native validation for this existing transfer's raw seal from
its actual context and canonical sample bytes. Malformed raw configurations
remain representable without such a certificate. -/
theorem nativeBinding (config : Config (sheaf C) Owner Asset Receipt)
    (O : TCB.BoundHCPObservation (integralStructure C)
      payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ)
    (contextEq : config.context = ofHCPObservation O identify parameters)
    (sampleEq : config.ciphertext = CoupledCiphertext.sampleBytes C z a u)
    (sameSample : O.encrypted = HCPCoupledEncoding.sample C z a u) :
    NativeManifest.BindsOriginal config.manifest O identify parameters := by
  refine ⟨contextEq, ?_⟩
  change CoupledCiphertext.BindsObservation config.hashes.ciphertext O config.ciphertext
    (config.hashes.ciphertext config.ciphertext)
  rw [sampleEq]
  exact CoupledCiphertext.sampleBytes_binds_original config.hashes.ciphertext O z a u sameSample

end Config

namespace CheckedTransfer

/-- The complete checked intent includes the root of the actual two-slot seal. -/
theorem native_manifest_root
    {config : Config (sheaf C) Owner Asset Receipt}
    {transfer : ResourceTransfer Owner} {bytes : List UInt8}
    (checked : CheckedTransfer config transfer bytes) :
    checked.proof.packet.intent.manifestRoot = config.manifest.root :=
  congrArg Intent.manifestRoot checked.proof.intent_eq

/-- The actual owned packet, candidate and history entry retain the native
original artifact and full ciphertext. Recovery uses their same manifest;
the only substitution alternative is a concrete accepted byte-hash collision. -/
theorem native_history_recovery [DecidableEq Asset]
    {config : Config (sheaf C) Owner Asset Receipt}
    {transfer : ResourceTransfer Owner} {bytes : List UInt8}
    {Envelope : Type}
    {Authorized : TransportToken.Scope → Prop}
    {DeliversBytes : TransportToken.Scope → List UInt8 → Envelope → Prop}
    {source : Context (sheaf B)} {recipient : TCB.Hash32}
    {sourceEpoch targetEpoch : ℕ}
    (checked : CheckedTransfer config transfer bytes)
    (runtime : TCB.RuntimeBoundary) (runtimeWellFormed : runtime.WellFormed)
    (O : TCB.BoundHCPObservation (integralStructure C)
      payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ)
    (sampleEq : config.ciphertext = CoupledCiphertext.sampleBytes C z a u)
    (bound : NativeManifest.BindsOriginal config.manifest O identify parameters)
    (downloaded : List (CiphertextManifest.Slot × List UInt8))
    (delivery : NativeDelivery.Receipt (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := config.context) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch)
      (material := NativeDelivery.tokenFor (B := B) (C := C)
        recipient sourceEpoch targetEpoch source config.context))
    (present : CoupledCiphertext.sampleBytes C z a u ∈ downloaded.map Prod.snd) :
    checked.proof.packet.intent.manifestRoot = config.manifest.root ∧
      config.context = ofHCPObservation O identify parameters ∧
      checked.candidate.action.cochain = O.artifact.cochain ∧
      (config.history checked.proof.packet).manifestIncluded checked.candidate config.context
        config.manifest.manifest.items config.manifest.root checked.candidate.proposal.blockDigest ∧
      O.encrypted.message = HCPCoupledEncoding.message C z ∧
      Ledger.AcceptedUpdate config.policy config.before checked.candidate checked.candidate.after ∧
      (Storage.Retrieval.Native.recoverByDigest config.hashes.ciphertext config.manifest.publicView
          config.ciphertextDigest downloaded delivery delivery.scope
          (TransportToken.encode (NativeDelivery.tokenFor (B := B) (C := C)
            recipient sourceEpoch targetEpoch source config.context)) = some z ∨
        ∃ substituted, substituted ≠ config.ciphertext ∧
          config.hashes.ciphertext substituted = config.ciphertextDigest ∧
          Storage.Retrieval.ContentAddress.readByDigest config.hashes.ciphertext config.manifest.publicView
            config.ciphertextDigest downloaded = some substituted) := by
  have anchor := checked.anchor runtime runtimeWellFormed
  have contextEq : config.context = ofHCPObservation O identify parameters := bound.context_eq
  have exactMatch : config.context.cochain = O.artifact.cochain := by
    rw [contextEq]
    rfl
  refine ⟨checked.native_manifest_root, bound.context_eq,
    anchor.cochain_matches.trans exactMatch, anchor.manifestIncluded,
    Storage.Retrieval.NativeAnchored.message_eq_of_bound_sample
      config.hashes.ciphertext config.hashes.manifest config.persisted
      O identify parameters z a u config.manifest sampleEq bound,
    anchor.toAcceptedUpdate, ?_⟩
  have named := CiphertextManifest.ciphertext_named config.manifest
  change config.hashes.ciphertext config.ciphertext ∈
    config.manifest.publicView.directory.map Prod.snd at named
  rw [sampleEq] at named
  have recovery := Storage.Retrieval.Native.recoverByDigest_correct_or_collision (B := B) (C := C)
    config.hashes.ciphertext config.manifest.publicView downloaded delivery z a u named present
  simpa only [Config.ciphertextDigest, Config.operational, Operational.Config.ciphertextDigest,
    sampleEq] using recovery

end CheckedTransfer
end HomotopicalEncryption.Protocol.Transfer.Owned
