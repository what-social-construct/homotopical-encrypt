module

public import Protocol.Storage.CiphertextManifest
public import Protocol.Storage.CoupledCiphertext

@[expose] public section

/-!
# Original-observation certificates for the canonical ciphertext manifest

The raw two-slot scheme and seal are exactly `CiphertextManifest`'s canonical
objects. They admit arbitrary bytes, so storage/signing can represent invalid
inputs without assuming their semantic validity. This file adds only a
proposition certifying the selected bytes against the existing original HCP
observation and its derived context. It introduces no second checkpoint
profile, manifest carrier or replacement HCP observation.

The coupled sample constructor discharges this certificate with the actual
full-cochain codec. Public names still contain no private message, opening,
presentation or transport token. Semantic binding does not establish hiding,
hash security, availability, authenticated history or protected delivery.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.NativeManifest

open Sheaf CellularSheaf HCPCoupledFamily

export CiphertextManifest
  (Bytes Slot Payload PublicPreimage exactItem ciphertextItem directory preimage
    scheme sealed items_eq publicView_base publicView_directory publicView_root
    publicView_hash ciphertext_named exact_named sealed_publicView persisted_of_receipt)

variable {rows cols : ℕ} {B : Matrix (Fin rows) (Fin cols) ℤ}
  {payload : CochainPayloadInterpretation (sheaf B)}
  {PublicClass Lifecycle : Type*}
  {classify : SheafStateSnapshot (sheaf B) → PublicClass}
  {Binds : TCB.HCPStackBinding Lifecycle PublicClass (C1 (Fin rows) (Fin cols))}
  {Receipt : Type*}
  {hash : Bytes → TCB.Hash32} {manifestHash : PublicPreimage → TCB.Hash32}
  {persisted : Context (sheaf B) → List (ManifestItem Slot Payload) →
    TCB.Hash32 → Receipt → Prop}
  {bytes : Bytes} {C : Context (sheaf B)}

/-- A validated refinement of the same raw seal, retaining the actual original
observation and its full-ciphertext decoder equation. -/
structure BindsOriginal
    (M : SealedManifest (scheme hash manifestHash persisted bytes) C)
    (O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) : Prop where
  context_eq : C = ofHCPObservation O identify parameters
  ciphertext_bound : CoupledCiphertext.BindsObservation hash O bytes (hash bytes)

variable
  {M : SealedManifest (scheme hash manifestHash persisted bytes) C}
  {O : TCB.BoundHCPObservation (integralStructure B)
    payload PublicClass Lifecycle classify Binds}
  {identify : Lifecycle → TCB.Hash32} {parameters : TCB.Hash32}

/-- Context identity is supplied by the validated certificate, not raw sealing. -/
theorem context_eq (bound : BindsOriginal M O identify parameters) :
    C = ofHCPObservation O identify parameters := bound.context_eq

theorem ciphertext_bound (bound : BindsOriginal M O identify parameters) :
    CoupledCiphertext.BindsObservation hash O bytes (hash bytes) := bound.ciphertext_bound

/-- A different context cannot be certified for this original observation,
although it still has its own raw seal. -/
theorem not_of_context_ne (wrong : C ≠ ofHCPObservation O identify parameters) :
    ¬ BindsOriginal M O identify parameters := by
  intro bound
  exact wrong bound.context_eq

/-- Certify any raw seal of canonical native sample bytes from the existing
actual observation and context equality. -/
theorem bindsSample (hash : Bytes → TCB.Hash32) (manifestHash : PublicPreimage → TCB.Hash32)
    (persisted : Context (sheaf B) → List (ManifestItem Slot Payload) →
      TCB.Hash32 → Receipt → Prop)
    (O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ)
    (M : SealedManifest (scheme hash manifestHash persisted
      (CoupledCiphertext.sampleBytes B z a u)) C)
    (contextEq : C = ofHCPObservation O identify parameters)
    (sameSample : O.encrypted = HCPCoupledEncoding.sample B z a u) :
    BindsOriginal M O identify parameters :=
  ⟨contextEq, CoupledCiphertext.sampleBytes_binds_original hash O z a u sameSample⟩

/-- Raw canonical sample bytes are sealable before their validation is supplied. -/
def sealedSample (hash : Bytes → TCB.Hash32) (manifestHash : PublicPreimage → TCB.Hash32)
    (persisted : Context (sheaf B) → List (ManifestItem Slot Payload) →
      TCB.Hash32 → Receipt → Prop)
    (O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    SealedManifest (scheme hash manifestHash persisted (CoupledCiphertext.sampleBytes B z a u))
      (ofHCPObservation O identify parameters) :=
  sealed hash manifestHash persisted (ofHCPObservation O identify parameters)
    (CoupledCiphertext.sampleBytes B z a u)

/-- The canonical sample codec proves the original-observation certificate for
the same raw seal; no parallel manifest profile is introduced. -/
theorem sealedSample_binds (hash : Bytes → TCB.Hash32)
    (manifestHash : PublicPreimage → TCB.Hash32)
    (persisted : Context (sheaf B) → List (ManifestItem Slot Payload) →
      TCB.Hash32 → Receipt → Prop)
    (O : TCB.BoundHCPObservation (integralStructure B)
      payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ)
    (sameSample : O.encrypted = HCPCoupledEncoding.sample B z a u) :
    BindsOriginal (sealedSample hash manifestHash persisted O identify parameters z a u)
      O identify parameters :=
  bindsSample hash manifestHash persisted O identify parameters z a u
    (sealedSample hash manifestHash persisted O identify parameters z a u) rfl sameSample

end HomotopicalEncryption.Protocol.Storage.NativeManifest
