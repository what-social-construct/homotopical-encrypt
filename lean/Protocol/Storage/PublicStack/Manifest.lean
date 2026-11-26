module

public import Protocol.Storage.CellDirectory.Checkpoint

@[expose] public section

/-!
# Canonical public stack manifests

A manifest names the cell directory and three public byte objects in fixed
roles. The context retains its original protocol names, while each object
address is a digest of the selected bytes. A reader verifies the manifest
against an independently authenticated root.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack

open TCB.PrimitiveChecks (Bytes)
open Protocol.Ephemeral.ScopeCodec (encodeFixed encodeKey parseFixed parseKey)

/-- Public byte addresses needed to restore one snapshot's published stack. -/
structure Manifest where
  context : ContextKey
  directoryRoot : TCB.Hash32
  snapshotAddress : TCB.Hash32
  cochainAddress : TCB.Hash32
  evidenceAddress : TCB.Hash32

namespace Manifest

def domain : Bytes := "HODGE_PUBLIC_STACK_V1".toUTF8.data.toList

def pin (manifest : Manifest) : CellDirectory.CheckpointPin :=
  ⟨manifest.context, manifest.directoryRoot⟩

def artifactAddresses (manifest : Manifest) : List TCB.Hash32 :=
  [manifest.snapshotAddress, manifest.cochainAddress, manifest.evidenceAddress]

def encodeBody (manifest : Manifest) (rest : Bytes) : Bytes :=
  encodeKey manifest.context
    (encodeFixed manifest.directoryRoot
      (encodeFixed manifest.snapshotAddress
        (encodeFixed manifest.cochainAddress (encodeFixed manifest.evidenceAddress rest))))

def parseBody (bytes : Bytes) : Option (Manifest × Bytes) := do
  let (context, rest) ← parseKey bytes
  let (directoryRoot, rest) ← parseFixed 32 rest
  let (snapshotAddress, rest) ← parseFixed 32 rest
  let (cochainAddress, rest) ← parseFixed 32 rest
  let (evidenceAddress, rest) ← parseFixed 32 rest
  some (⟨context, directoryRoot, snapshotAddress, cochainAddress, evidenceAddress⟩, rest)

@[simp] theorem parseBody_encodeBody (manifest : Manifest) (rest : Bytes) :
    parseBody (encodeBody manifest rest) = some (manifest, rest) := by
  simp [parseBody, encodeBody]

def encode (manifest : Manifest) : Bytes := domain ++ encodeBody manifest []

def decode (bytes : Bytes) : Option Manifest :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (manifest, rest) =>
    if rest = [] ∧ bytes = manifest.encode then some manifest else none

@[simp] theorem decode_encode (manifest : Manifest) : decode manifest.encode = some manifest := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (manifest : Manifest) :
    decode bytes = some manifest ↔ bytes = manifest.encode := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        exact canonical.2.trans (congrArg encode (Option.some.inj decoded))
      next => contradiction
  · rintro rfl
    exact decode_encode manifest

theorem encode_injective : Function.Injective encode := by
  intro left right same
  have decoded := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using decoded

end Manifest

/-- A public stack manifest checked at an independently authenticated root. -/
structure Verified (root : TCB.Hash32) where
  manifest : Manifest
  committed : Sha256.digest manifest.encode = root

/-- Verify canonical manifest bytes against the root before following any link. -/
def verify (root : TCB.Hash32) (bytes : Bytes) : Option (Verified root) :=
  (Manifest.decode bytes).bind fun manifest =>
    let computed := Sha256.digestBytes manifest.encode
    if bound : Sha256.key computed = List.ofFn root then
      some ⟨manifest, List.ofFn_injective bound⟩
    else none

theorem verify_eq_some_iff (root : TCB.Hash32) (bytes : Bytes) (checked : Verified root) :
    verify root bytes = some checked ↔ bytes = checked.manifest.encode := by
  constructor
  · intro accepted
    unfold verify at accepted
    cases parsed : Manifest.decode bytes with
    | none => simp [parsed] at accepted
    | some manifest =>
      simp only [parsed, Option.bind_some] at accepted
      split at accepted
      next bound =>
        exact ((Manifest.decode_eq_some_iff _ _).mp parsed).trans
          (congrArg Manifest.encode (congrArg Verified.manifest (Option.some.inj accepted)))
      next => exact (Option.some_ne_none checked accepted.symm).elim
  · rintro rfl
    have bound : Sha256.key (Sha256.digestBytes checked.manifest.encode) = List.ofFn root :=
      congrArg (fun hash : TCB.Hash32 => List.ofFn hash) checked.committed
    simp only [verify, Manifest.decode_encode, Option.bind_some, dite_eq_left bound]

namespace Verified

/-- Two accepted manifests at the same root agree or give distinct canonical
manifest bytes with equal SHA-256. -/
theorem manifest_eq_or_collision {root : TCB.Hash32} (left right : Verified root) :
    left.manifest = right.manifest ∨
      (left.manifest.encode ≠ right.manifest.encode ∧
        Sha256.digest left.manifest.encode = Sha256.digest right.manifest.encode) := by
  by_cases same : left.manifest = right.manifest
  · exact Or.inl same
  · exact Or.inr ⟨fun equal => same (Manifest.encode_injective equal),
      left.committed.trans right.committed.symm⟩

end Verified

end HomotopicalEncryption.Protocol.Storage.PublicStack
