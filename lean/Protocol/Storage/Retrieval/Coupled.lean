module

public import Protocol.Storage.Retrieval.Recovery
public import Protocol.Storage.CoupledCiphertext
public import HCP.CoupledCVP

@[expose] public section

/-!
# Hash-addressed recovery of the original coupled Hodge ciphertext

The concrete coupled ciphertext codec discharges the full-cochain decoder
premise of the existing hash-addressed recovery theorem. Source and target
remain their original bound HCP observations; both storage contexts are
derived from those observations. Recovery retains the actual presented
rotation and its recipient/epoch/context-bound delivery receipt.

The requested digest names the canonical bytes of the full target Hodge
observation, independently of its exact-component artifact digest. Hashing
selects and checks the stored object; the delivered private transport supplies
recovery. No hash-derived secret, new recovery algorithm or delivery producer
is introduced here. Manifest authentication, availability and authorized
delivery retain the hypotheses of the existing theorem.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.Retrieval.Coupled

open Sheaf CellularSheaf
open HomotopicalEncryption.HCP
open TCB.PrimitiveChecks

variable {rows cols : ℕ}
  {B C : Matrix (Fin rows) (Fin cols) ℤ}
  {payloadS : CochainPayloadInterpretation (HCPCoupledFamily.sheaf B)}
  {payloadT : CochainPayloadInterpretation (HCPCoupledFamily.sheaf C)}
  {PublicClassS LifecycleS PublicClassT LifecycleT Recipient Envelope Slot : Type}
  {classifyS : SheafStateSnapshot (HCPCoupledFamily.sheaf B) → PublicClassS}
  {classifyT : SheafStateSnapshot (HCPCoupledFamily.sheaf C) → PublicClassT}
  {BindsS : TCB.HCPStackBinding LifecycleS PublicClassS
    (HCPCoupledFamily.C1 (Fin rows) (Fin cols))}
  {BindsT : TCB.HCPStackBinding LifecycleT PublicClassT
    (HCPCoupledFamily.C1 (Fin rows) (Fin cols))}
  {rotation : Ephemeral.PresentedRotation
    (CoupledCVP.harmonicLatticePresentation B) (CoupledCVP.harmonicLatticePresentation C)}
  {contract : Ephemeral.DeliveryContract
    (CoupledCVP.harmonicLatticePresentation B) (CoupledCVP.harmonicLatticePresentation C)
    Recipient Envelope}
  {recipient : Recipient} {sourceEpoch targetEpoch : ℕ}

/-- Canonical native ciphertext bytes recover the original source coefficients
or expose an actual accepted hash collision. The full-cochain decoding equation
is proved by the codec, rather than supplied as an independent profile premise.
The receipt still binds the actual private rotation to the exact original
source/target contexts, recipient and epochs. -/
theorem recoverByDigest_original_or_collision
    (hash : Bytes → TCB.Hash32) (view : PublicManifestView Slot)
    (downloaded : List (Slot × Bytes))
    (source : TCB.BoundHCPObservation (HCPCoupledFamily.integralStructure B)
      payloadS PublicClassS LifecycleS classifyS BindsS)
    (target : TCB.BoundHCPObservation (HCPCoupledFamily.integralStructure C)
      payloadT PublicClassT LifecycleT classifyT BindsT)
    (identifyS : LifecycleS → TCB.Hash32) (parametersS : TCB.Hash32)
    (identifyT : LifecycleT → TCB.Hash32) (parametersT : TCB.Hash32)
    (delivery : Ephemeral.RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      (ofHCPObservation source identifyS parametersS)
      (ofHCPObservation target identifyT parametersT))
    (transported : Ephemeral.BoundSampleRotation rotation source target)
    (z : Fin cols → ℤ)
    (message_eq : source.encrypted.message = (CoupledCVP.harmonicLatticePresentation B).point z)
    (a : ℤ) (u : Fin rows → ℤ)
    (target_eq : target.encrypted = HCPCoupledEncoding.sample C z a u)
    (named : hash (CoupledCiphertext.sampleBytes C z a u) ∈ view.directory.map Prod.snd)
    (present : CoupledCiphertext.sampleBytes C z a u ∈ downloaded.map Prod.snd) :
    Recovery.recoverByDigest hash (CoupledCiphertext.decodeReal rows cols) view
        (hash (CoupledCiphertext.sampleBytes C z a u)) downloaded delivery delivery.scope = some z ∨
      ∃ candidate, candidate ≠ CoupledCiphertext.sampleBytes C z a u ∧
        hash candidate = hash (CoupledCiphertext.sampleBytes C z a u) ∧
        ContentAddress.readByDigest hash view (hash (CoupledCiphertext.sampleBytes C z a u))
          downloaded = some candidate := by
  exact Recovery.recoverByDigest_bound_observation_or_collision
    hash (CoupledCiphertext.decodeReal rows cols) view downloaded delivery source target
    transported z message_eq named present
    (CoupledCiphertext.sampleBytes_binds_original hash target z a u target_eq).1

end HomotopicalEncryption.Protocol.Storage.Retrieval.Coupled
