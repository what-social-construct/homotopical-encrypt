module

public import Protocol.Storage.NativeManifest
public import Protocol.Storage.Retrieval.Native
public import Protocol.Storage.Anchor

@[expose] public section

/-!
# Native ciphertext recovery from the same sealed and anchored manifest

The public view and ciphertext directory membership below are derived from
an actual two-slot seal of the original target context. They are not supplied
as independent names. The existing transition anchor authenticates that exact
context, ordered manifest and root under its candidate/history contract.

Canonical ciphertext binding also identifies the target's original harmonic
message by projection; equality of private opening representatives is not
required. Recovery uses the existing held native token and private base key.
Downloaded-byte availability and canonical issuer-derived token bytes remain
explicit. History authentication, protected delivery and hash security are
not inferred from root computation or sealing.

This is a same-context ciphertext/history association. It does not identify
the harmonic coefficients with ledger amounts, credentials or action semantics,
change the earlier owned-transfer packet, or establish identity privacy or PIR.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.Retrieval.NativeAnchored

open Sheaf CellularSheaf HCPCoupledFamily
open Ephemeral

abbrev Bytes := List UInt8

variable {rows cols : ℕ} {B C : Matrix (Fin rows) (Fin cols) ℤ}
  {Envelope Receipt : Type*}
  {Authorized : TransportToken.Scope → Prop}
  {DeliversBytes : TransportToken.Scope → Bytes → Envelope → Prop}
  {payloadT : CochainPayloadInterpretation (sheaf C)}
  {PublicClassT LifecycleT : Type*}
  {classifyT : SheafStateSnapshot (sheaf C) → PublicClassT}
  {BindsT : TCB.HCPStackBinding LifecycleT PublicClassT (C1 (Fin rows) (Fin cols))}

variable (hash : Bytes → TCB.Hash32)
  (manifestHash : NativeManifest.PublicPreimage → TCB.Hash32)
  (persisted : Context (sheaf C) →
    List (ManifestItem NativeManifest.Slot NativeManifest.Payload) →
    TCB.Hash32 → Receipt → Prop)
  (targetObservation : TCB.BoundHCPObservation (integralStructure C)
    payloadT PublicClassT LifecycleT classifyT BindsT)
  (identifyT : LifecycleT → TCB.Hash32) (parametersT : TCB.Hash32)
  (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ)

/-- Binding canonical sample bytes to the actual observation determines its
harmonic message. No equality of private opening representatives is assumed. -/
theorem message_eq_of_sealed_sample
    (M : SealedManifest (NativeManifest.scheme hash manifestHash persisted
      targetObservation identifyT parametersT (CoupledCiphertext.sampleBytes C z a u))
      (ofHCPObservation targetObservation identifyT parametersT)) :
    targetObservation.encrypted.message = HCPCoupledEncoding.message C z := by
  apply Subtype.ext
  have observed := Option.some.inj
    ((CoupledCiphertext.decodeReal_sampleBytes C z a u).symm.trans
      (NativeManifest.ciphertext_bound M).1)
  have projected := congrArg (sheaf C).harmonicOneProjection observed
  change (sheaf C).harmonicOneProjection (HCPCoupledEncoding.sample C z a u).observed =
    (sheaf C).harmonicOneProjection targetObservation.encrypted.observed at projected
  rw [(HCPCoupledEncoding.sample C z a u).harmonicOneProjection_observed,
    targetObservation.encrypted.harmonicOneProjection_observed] at projected
  exact projected.symm

variable {source : Context (sheaf B)} {recipient : TCB.Hash32}
  {sourceEpoch targetEpoch : ℕ}

/-- Lookup naming is derived from this actual target-bound seal. The caller
still supplies downloaded-byte availability and the canonical issued token. -/
theorem recoverByDigest_sealed_or_collision
    (M : SealedManifest (NativeManifest.scheme hash manifestHash persisted
      targetObservation identifyT parametersT (CoupledCiphertext.sampleBytes C z a u))
      (ofHCPObservation targetObservation identifyT parametersT))
    (downloaded : List (NativeManifest.Slot × Bytes))
    (delivery : NativeDelivery.Receipt (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := ofHCPObservation targetObservation identifyT parametersT)
      (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch)
      (material := NativeDelivery.tokenFor (B := B) (C := C)
        recipient sourceEpoch targetEpoch source (ofHCPObservation targetObservation identifyT parametersT)))
    (present : (CoupledCiphertext.sampleBytes C z a u) ∈ downloaded.map Prod.snd) :
    Native.recoverByDigest hash M.publicView (hash (CoupledCiphertext.sampleBytes C z a u))
        downloaded delivery
        delivery.scope
        (TransportToken.encode (NativeDelivery.tokenFor (B := B) (C := C)
          recipient sourceEpoch targetEpoch source (ofHCPObservation targetObservation identifyT parametersT))) = some z ∨
      ∃ candidate, candidate ≠ CoupledCiphertext.sampleBytes C z a u ∧
        hash candidate = hash (CoupledCiphertext.sampleBytes C z a u) ∧
        ContentAddress.readByDigest hash M.publicView (hash (CoupledCiphertext.sampleBytes C z a u)) downloaded =
          some candidate :=
  Native.recoverByDigest_correct_or_collision (B := B) (C := C)
    hash M.publicView downloaded delivery z a u (NativeManifest.ciphertext_named M) present

section History

variable {Resource Nullifier Asset : Type} [DecidableEq Nullifier]
  {runtime : TCB.RuntimeBoundary}
  {policy : Ledger.Policy Resource Nullifier Asset (CochainPayloadInterpretation (sheaf C))}
  {bindings : Evidence.RootBindings Resource Nullifier (CochainPayloadInterpretation (sheaf C))}
  {candidate : Ledger.Candidate Resource Nullifier (CochainPayloadInterpretation (sheaf C))}
  {topologyBinds : SheafStateSnapshot (sheaf C) → TCB.Hash32 → Prop}
  {history : HistoryBindings (sheaf C) Resource Nullifier
    NativeManifest.Slot NativeManifest.Payload}
  {evidence : Evidence.Transition runtime policy bindings candidate}

/-- The exact original artifact, native ciphertext and recovery are associated
with one evidence-bearing history entry through the existing anchor. This
does not interpret the recovered coefficient vector as the ledger action. -/
theorem recoverByDigest_anchored_or_collision
    (M : SealedManifest (NativeManifest.scheme hash manifestHash persisted
      targetObservation identifyT parametersT (CoupledCiphertext.sampleBytes C z a u))
      (ofHCPObservation targetObservation identifyT parametersT))
    (anchor : TransitionAnchor topologyBinds history evidence
      (ofHCPObservation targetObservation identifyT parametersT) M)
    (downloaded : List (NativeManifest.Slot × Bytes))
    (delivery : NativeDelivery.Receipt (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := ofHCPObservation targetObservation identifyT parametersT)
      (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch)
      (material := NativeDelivery.tokenFor (B := B) (C := C)
        recipient sourceEpoch targetEpoch source (ofHCPObservation targetObservation identifyT parametersT)))
    (present : (CoupledCiphertext.sampleBytes C z a u) ∈ downloaded.map Prod.snd) :
    M.publicView.base = (ofHCPObservation targetObservation identifyT parametersT).publicView ∧
      candidate.action.cochain = targetObservation.artifact.cochain ∧
      candidate.proposal.snapshotRoot =
        (ofHCPObservation targetObservation identifyT parametersT).key.snapshotRoot ∧
      history.manifestIncluded candidate (ofHCPObservation targetObservation identifyT parametersT)
        M.manifest.items M.root candidate.proposal.blockDigest ∧
      hash (CoupledCiphertext.sampleBytes C z a u) ∈ M.publicView.directory.map Prod.snd ∧
      targetObservation.encrypted.message = HCPCoupledEncoding.message C z ∧
      Ledger.AcceptedUpdate policy candidate.before candidate candidate.after ∧
      (Native.recoverByDigest hash M.publicView (hash (CoupledCiphertext.sampleBytes C z a u))
          downloaded delivery
          delivery.scope
          (TransportToken.encode (NativeDelivery.tokenFor (B := B) (C := C)
            recipient sourceEpoch targetEpoch source (ofHCPObservation targetObservation identifyT parametersT))) = some z ∨
        ∃ substituted, substituted ≠ CoupledCiphertext.sampleBytes C z a u ∧
          hash substituted = hash (CoupledCiphertext.sampleBytes C z a u) ∧
          ContentAddress.readByDigest hash M.publicView (hash (CoupledCiphertext.sampleBytes C z a u)) downloaded =
            some substituted) :=
  ⟨SealedManifest.publicView_base M, anchor.cochain_matches, anchor.snapshot_root_matches,
    anchor.manifestIncluded, NativeManifest.ciphertext_named M,
    message_eq_of_sealed_sample hash manifestHash persisted
      targetObservation identifyT parametersT z a u M,
    anchor.toAcceptedUpdate,
    recoverByDigest_sealed_or_collision hash manifestHash persisted
      targetObservation identifyT parametersT z a u M downloaded delivery present⟩

end History
end HomotopicalEncryption.Protocol.Storage.Retrieval.NativeAnchored
