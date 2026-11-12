module

public import Protocol.Storage.Retrieval.ContentAddress
public import Protocol.Ephemeral.NativeDelivery

@[expose] public section

/-!
# Hash-addressed recovery with the native rational transport token

The existing digest lookup feeds the exact bytes to the existing scoped
native token operation. The held material is a derived rational matrix;
retained-base recovery also uses the explicit private source presentation.
Source and target contexts, authorization and protected delivery remain those
of the one scoped receipt. No new recovery carrier or selected network request
is introduced.

With the canonical issuer-derived token bytes supplied, canonical target
sample bytes recover the original coefficient vector, or accepted ciphertext
substitution produces an actual byte-hash collision. The token-substitution
collision theorem is separate; no combined two-adversarial-input theorem is
asserted here. Manifest authentication, availability and protected delivery
retain their original contracts. The ciphertext digest is separate from the
exact artifact digest.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.Retrieval.Native

open Sheaf CellularSheaf HCPCoupledFamily
open Ephemeral
open TCB.PrimitiveChecks

variable {rows cols : ℕ} {Envelope Slot : Type*}
  {Authorized : TransportToken.Scope → Prop}
  {DeliversBytes : TransportToken.Scope → Bytes → Envelope → Prop}
  {B C : Matrix (Fin rows) (Fin cols) ℤ}
  {recipient : TCB.Hash32} {sourceEpoch targetEpoch : ℕ}
  {source : Context (sheaf B)} {target : Context (sheaf C)}

section Operation

variable {material : TransportToken.Token rows cols}

/-- Locate and hash-check full ciphertext bytes before the held native token's
own canonical/scope/hash checks and exact retained-base recovery. -/
def recoverByDigest (hash : Bytes → TCB.Hash32) (view : PublicManifestView Slot)
    (digest : TCB.Hash32) (downloaded : List (Slot × Bytes))
    (delivery : NativeDelivery.Receipt (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := target) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch) (material := material))
    (request : TransportToken.Scope) (tokenBytes : Bytes) : Option (Fin cols → ℤ) :=
  (ContentAddress.readByDigest hash view digest downloaded).bind
    (NativeDelivery.recoverFor (rows := rows) (cols := cols) (B := B) (C := C)
      delivery hash request tokenBytes digest)

/-- An unlisted digest never reaches the token or private source-key operation. -/
theorem recoverByDigest_none_of_unlisted (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (digest : TCB.Hash32) (downloaded : List (Slot × Bytes))
    (delivery : NativeDelivery.Receipt (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := target) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch) (material := material))
    (request : TransportToken.Scope) (tokenBytes : Bytes)
    (unlisted : digest ∉ view.directory.map Prod.snd) :
    recoverByDigest hash view digest downloaded delivery request tokenBytes = none := by
  simp [recoverByDigest,
    ContentAddress.readByDigest_none_of_unlisted hash view digest downloaded unlisted]

/-- Any scope mismatch rejects even after the ciphertext passes the directory
and content-hash check. This is label checking, not caller authentication. -/
theorem recoverByDigest_none_of_scope_ne (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (digest : TCB.Hash32) (downloaded : List (Slot × Bytes))
    (delivery : NativeDelivery.Receipt (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := target) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch) (material := material))
    (request : TransportToken.Scope) (wrong : request ≠ delivery.scope) (tokenBytes : Bytes) :
    recoverByDigest hash view digest downloaded delivery request tokenBytes = none := by
  cases read : ContentAddress.readByDigest hash view digest downloaded with
  | none => simp [recoverByDigest, read]
  | some bytes =>
    simp [recoverByDigest, read, NativeDelivery.recoverFor, ScopedDelivery.useFor, wrong]

end Operation

/-- Canonical native token and target ciphertext bytes give original integer
coefficients or an accepted hash collision. The full-cochain decoder and
transport/recovery calculations are actual implementations in this profile. -/
theorem recoverByDigest_correct_or_collision
    (hash : Bytes → TCB.Hash32) (view : PublicManifestView Slot)
    (downloaded : List (Slot × Bytes))
    (delivery : NativeDelivery.Receipt (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := target) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch)
      (material := NativeDelivery.tokenFor (B := B) (C := C) recipient sourceEpoch targetEpoch source target))
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ)
    (named : hash (CoupledCiphertext.sampleBytes C z a u) ∈ view.directory.map Prod.snd)
    (present : CoupledCiphertext.sampleBytes C z a u ∈ downloaded.map Prod.snd) :
    recoverByDigest hash view (hash (CoupledCiphertext.sampleBytes C z a u)) downloaded delivery
        delivery.scope
        (TransportToken.encode (NativeDelivery.tokenFor (B := B) (C := C) recipient sourceEpoch targetEpoch source target)) =
      some z ∨
      ∃ candidate, candidate ≠ CoupledCiphertext.sampleBytes C z a u ∧
        hash candidate = hash (CoupledCiphertext.sampleBytes C z a u) ∧
        ContentAddress.readByDigest hash view (hash (CoupledCiphertext.sampleBytes C z a u))
          downloaded = some candidate := by
  obtain ⟨candidate, accepted⟩ :=
    ContentAddress.readByDigest_complete hash view downloaded named present
  rcases ContentAddress.readByDigest_original_or_collision hash view downloaded accepted with
    same | collision
  · subst candidate
    refine Or.inl ?_
    rw [recoverByDigest, accepted, Option.bind_some]
    exact NativeDelivery.recoverFor_sample (rows := rows) (cols := cols) (B := B) (C := C)
      delivery hash z a u
  · exact Or.inr ⟨candidate, collision.1, collision.2, accepted⟩

section OriginalObservations

variable
  {payloadS : CochainPayloadInterpretation (sheaf B)}
  {payloadT : CochainPayloadInterpretation (sheaf C)}
  {PublicClassS LifecycleS PublicClassT LifecycleT : Type}
  {classifyS : SheafStateSnapshot (sheaf B) → PublicClassS}
  {classifyT : SheafStateSnapshot (sheaf C) → PublicClassT}
  {BindsS : TCB.HCPStackBinding LifecycleS PublicClassS (C1 (Fin rows) (Fin cols))}
  {BindsT : TCB.HCPStackBinding LifecycleT PublicClassT (C1 (Fin rows) (Fin cols))}

/-- Original bound observations determine both contexts and retain the source
message and target full-ciphertext binding. The hash-addressed result uses the
same native samples and private source presentation, without a new HCP carrier. -/
theorem recoverByDigest_bound_observation_or_collision
    (hash : Bytes → TCB.Hash32) (view : PublicManifestView Slot)
    (downloaded : List (Slot × Bytes))
    (sourceObservation : TCB.BoundHCPObservation (integralStructure B)
      payloadS PublicClassS LifecycleS classifyS BindsS)
    (targetObservation : TCB.BoundHCPObservation (integralStructure C)
      payloadT PublicClassT LifecycleT classifyT BindsT)
    (identifyS : LifecycleS → TCB.Hash32) (parametersS : TCB.Hash32)
    (identifyT : LifecycleT → TCB.Hash32) (parametersT : TCB.Hash32)
    (delivery : NativeDelivery.Receipt (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := ofHCPObservation sourceObservation identifyS parametersS)
      (target := ofHCPObservation targetObservation identifyT parametersT)
      (recipient := recipient) (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch)
      (material := NativeDelivery.tokenFor (B := B) (C := C) recipient sourceEpoch targetEpoch
        (ofHCPObservation sourceObservation identifyS parametersS)
        (ofHCPObservation targetObservation identifyT parametersT)))
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ)
    (source_eq : sourceObservation.encrypted = HCPCoupledEncoding.sample B z a u)
    (target_eq : targetObservation.encrypted = HCPCoupledEncoding.sample C z a u)
    (named : hash (CoupledCiphertext.sampleBytes C z a u) ∈ view.directory.map Prod.snd)
    (present : CoupledCiphertext.sampleBytes C z a u ∈ downloaded.map Prod.snd) :
    sourceObservation.encrypted.message = HCPCoupledEncoding.message B z ∧
      CoupledCiphertext.BindsObservation hash targetObservation (CoupledCiphertext.sampleBytes C z a u)
        (hash (CoupledCiphertext.sampleBytes C z a u)) ∧
      (recoverByDigest hash view (hash (CoupledCiphertext.sampleBytes C z a u)) downloaded delivery
          delivery.scope
          (TransportToken.encode (NativeDelivery.tokenFor (B := B) (C := C) recipient sourceEpoch targetEpoch
            (ofHCPObservation sourceObservation identifyS parametersS)
            (ofHCPObservation targetObservation identifyT parametersT))) = some z ∨
        ∃ candidate, candidate ≠ CoupledCiphertext.sampleBytes C z a u ∧
          hash candidate = hash (CoupledCiphertext.sampleBytes C z a u) ∧
          ContentAddress.readByDigest hash view (hash (CoupledCiphertext.sampleBytes C z a u))
            downloaded = some candidate) := by
  refine ⟨?_, CoupledCiphertext.sampleBytes_binds_original hash targetObservation z a u target_eq, ?_⟩
  · rw [source_eq]
    rfl
  · exact recoverByDigest_correct_or_collision hash view downloaded delivery z a u named present

end OriginalObservations

end HomotopicalEncryption.Protocol.Storage.Retrieval.Native
