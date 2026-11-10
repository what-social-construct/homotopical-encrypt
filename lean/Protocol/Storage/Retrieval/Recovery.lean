module

public import Protocol.Storage.Retrieval.ContentAddress
public import Protocol.Ephemeral.Delivery
public import Protocol.Ephemeral.HCP

@[expose] public section

/-!
# Hash-addressed full ciphertexts and original private HCP recovery

The reader first checks the requested ciphertext digest in an already
downloaded bucket, then parses the full target cochain and uses existing
recipient/epoch/context-bound recovery material. The parser is a selected
finite-profile contract, not the exact-component payload decoder. No hash of
the exact payload is reinterpreted as a digest of the full Hodge observation.

Availability of the original bytes and their full-cochain decoding equation
give original-message recovery or an actual colliding byte candidate. The
native corollary retains the original BoundHCPObservation endpoints through
BoundSampleRotation. Manifest authentication, private material delivery,
finite parsing, content secrecy and the transport/runtime implementation keep
their existing contracts. This local computation sends no selected request.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.Retrieval.Recovery

open Sheaf CellularSheaf
open TCB.PrimitiveChecks

variable {Vertex Edge Face Rank Recipient Envelope Slot : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face] [Fintype Rank]
  {X : OrientedTwoComplex Vertex Edge Face} {F G : CellularSheaf X}
  {I : IntegralStructure F} {J : IntegralStructure G}
  {H : HarmonicLatticePresentation I Rank} {K : HarmonicLatticePresentation J Rank}
  {contract : Ephemeral.DeliveryContract H K Recipient Envelope}
  {rotation : Ephemeral.PresentedRotation H K}
  {recipient : Recipient} {sourceEpoch targetEpoch : ℕ}
  {sourceContext : Context F} {targetContext : Context G}

/-- Hash-check opaque bytes, parse the full ciphertext and then use the existing
private recovery receipt. Every target-specific step is client-local. -/
def recoverByDigest (hash : Bytes → TCB.Hash32) (decode : Bytes → Option G.C1)
    (view : PublicManifestView Slot) (digest : TCB.Hash32) (downloaded : List (Slot × Bytes))
    (delivery : Ephemeral.RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      sourceContext targetContext)
    (request : Ephemeral.DeliveryScope Recipient) : Option (Rank → ℤ) :=
  (ContentAddress.decodeByDigest hash decode view digest downloaded).bind (delivery.recoverFor request)

/-- An unlisted ciphertext never reaches the finite parser or private recovery. -/
theorem recoverByDigest_none_of_unlisted (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option G.C1) (view : PublicManifestView Slot) (digest : TCB.Hash32)
    (downloaded : List (Slot × Bytes))
    (delivery : Ephemeral.RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      sourceContext targetContext)
    (request : Ephemeral.DeliveryScope Recipient)
    (unlisted : digest ∉ view.directory.map Prod.snd) :
    recoverByDigest hash decode view digest downloaded delivery request = none := by
  simp [recoverByDigest, ContentAddress.decodeByDigest,
    ContentAddress.readByDigest_none_of_unlisted hash view digest downloaded unlisted]

/-- Changing any existing recovery scope coordinate rejects locally, even if
the downloaded object passes its hash and parser checks. -/
theorem recoverByDigest_none_of_scope_ne (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option G.C1) (view : PublicManifestView Slot) (digest : TCB.Hash32)
    (downloaded : List (Slot × Bytes))
    (delivery : Ephemeral.RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      sourceContext targetContext)
    (request : Ephemeral.DeliveryScope Recipient) (wrong : request ≠ delivery.scope) :
    recoverByDigest hash decode view digest downloaded delivery request = none := by
  cases parsed : ContentAddress.decodeByDigest hash decode view digest downloaded with
  | none => simp [recoverByDigest, parsed]
  | some b =>
    simpa only [recoverByDigest, parsed, Option.bind_some] using
      delivery.recoverFor_eq_none_of_scope_ne request wrong b

/-- Once the named original bytes are accepted, their actual full-cochain
decoder equation and existing recovery theorem determine the local result. -/
theorem recoverByDigest_of_original (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option G.C1) (view : PublicManifestView Slot)
    (downloaded : List (Slot × Bytes))
    (delivery : Ephemeral.RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      sourceContext targetContext)
    {original : Bytes} {b : G.C1} {z : Rank → ℤ}
    (accepted : ContentAddress.readByDigest hash view (hash original) downloaded = some original)
    (decodes : decode original = some b)
    (recovers : delivery.recoverFor delivery.scope b = some z) :
    recoverByDigest hash decode view (hash original) downloaded delivery delivery.scope = some z := by
  simpa only [recoverByDigest, ContentAddress.decodeByDigest, accepted, Option.bind_some,
    decodes] using recovers

/-- The available named ciphertext recovers its original coefficients or a
substituted accepted byte candidate exhibits an actual target-hash collision. -/
theorem recoverByDigest_correct_or_collision (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option G.C1) (view : PublicManifestView Slot)
    (downloaded : List (Slot × Bytes))
    (delivery : Ephemeral.RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      sourceContext targetContext)
    {original : Bytes} {b : G.C1} {z : Rank → ℤ}
    (named : hash original ∈ view.directory.map Prod.snd)
    (present : original ∈ downloaded.map Prod.snd)
    (decodes : decode original = some b)
    (recovers : delivery.recoverFor delivery.scope b = some z) :
    recoverByDigest hash decode view (hash original) downloaded delivery delivery.scope = some z ∨
      ∃ candidate, candidate ≠ original ∧ hash candidate = hash original ∧
        ContentAddress.readByDigest hash view (hash original) downloaded = some candidate := by
  obtain ⟨candidate, accepted⟩ := ContentAddress.readByDigest_complete hash view downloaded named present
  rcases ContentAddress.readByDigest_original_or_collision hash view downloaded accepted with
    same | collision
  · subst candidate
    exact Or.inl (recoverByDigest_of_original hash decode view downloaded delivery accepted decodes recovers)
  · exact Or.inr ⟨candidate, collision.1, collision.2, accepted⟩

/-- Native specialization: the retrieved bytes encode this actual rotated
structured-noise encryption, with unchanged integer coefficient message. -/
theorem recoverByDigest_rotated_or_collision (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option G.C1) (view : PublicManifestView Slot)
    (downloaded : List (Slot × Bytes))
    (delivery : Ephemeral.RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      sourceContext targetContext)
    {original : Bytes} (z : Rank → ℤ) (noise : HodgeNoise F)
    (named : hash original ∈ view.directory.map Prod.snd)
    (present : original ∈ downloaded.map Prod.snd)
    (decodes : decode original = some (rotation.rotateObserved (H.encrypt z noise).observed)) :
    recoverByDigest hash decode view (hash original) downloaded delivery delivery.scope = some z ∨
      ∃ candidate, candidate ≠ original ∧ hash candidate = hash original ∧
        ContentAddress.readByDigest hash view (hash original) downloaded = some candidate :=
  recoverByDigest_correct_or_collision hash decode view downloaded delivery named present decodes
    (delivery.recoverFor_rotated_encrypt z noise)

section OriginalObservations

variable {payloadS : CochainPayloadInterpretation F} {payloadT : CochainPayloadInterpretation G}
  {PublicClassS LifecycleS PublicClassT LifecycleT : Type}
  {classifyS : SheafStateSnapshot F → PublicClassS}
  {classifyT : SheafStateSnapshot G → PublicClassT}
  {BindsS : TCB.HCPStackBinding LifecycleS PublicClassS F.C1}
  {BindsT : TCB.HCPStackBinding LifecycleT PublicClassT G.C1}

/-- The exact original bound source/target samples supply recovery of this
retrieved full target observation. Its exact-component leaf remains distinct. -/
theorem recoverByDigest_bound_observation_or_collision (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option G.C1) (view : PublicManifestView Slot)
    (downloaded : List (Slot × Bytes))
    (delivery : Ephemeral.RecoveryDelivery contract rotation recipient sourceEpoch targetEpoch
      sourceContext targetContext)
    (source : TCB.BoundHCPObservation I payloadS PublicClassS LifecycleS classifyS BindsS)
    (target : TCB.BoundHCPObservation J payloadT PublicClassT LifecycleT classifyT BindsT)
    (transported : Ephemeral.BoundSampleRotation rotation source target)
    {original : Bytes} (z : Rank → ℤ) (message_eq : source.encrypted.message = H.point z)
    (named : hash original ∈ view.directory.map Prod.snd)
    (present : original ∈ downloaded.map Prod.snd)
    (decodes : decode original = some target.cochainObject) :
    recoverByDigest hash decode view (hash original) downloaded delivery delivery.scope = some z ∨
      ∃ candidate, candidate ≠ original ∧ hash candidate = hash original ∧
        ContentAddress.readByDigest hash view (hash original) downloaded = some candidate := by
  apply recoverByDigest_correct_or_collision hash decode view downloaded delivery named present decodes
  simpa [Ephemeral.RecoveryDelivery.recoverFor] using transported.recover_with_base z message_eq

end OriginalObservations

end HomotopicalEncryption.Protocol.Storage.Retrieval.Recovery
