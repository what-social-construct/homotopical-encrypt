module

public import Protocol.Storage.PublicView
public import TCB.PrimitiveChecks

@[expose] public section

/-!
# Local authentication of retrieved encrypted-object bytes

The existing public manifest supplies the fixed directory and root. Its
selected opaque-blob digest names the complete ciphertext bytes, separately
from the exact-component `ContextKey.cochainDigest`. No new manifest, hash or
context-key carrier is introduced. The caller must authenticate this manifest
against the intended snapshot; mere possession of a `PublicManifestView` is
not a proof that its root or directory is authentic.

Lookup below runs on a list already downloaded by the client. The server need
not receive the selected slot. Hash checking precedes the supplied decoder.
Successful checking gives equality with the named original bytes or an actual
collision for the selected hash function. No global hash injectivity, access
authorization, availability or selector-privacy theorem is assumed here.
-/

set_option autoImplicit false

namespace Hcrypt.Protocol.Storage.Retrieval.ContentAddress

open TCB.PrimitiveChecks

section Slots

variable {Slot : Type*} [BEq Slot]

/-- Select opaque encrypted bytes locally and check their directory digest.
Both lookups operate on client-held values, not on a public selected request. -/
def readLocal (hash : Bytes → TCB.Hash32) (view : PublicManifestView Slot)
    (slot : Slot) (downloaded : List (Slot × Bytes)) : Option Bytes :=
  match view.directory.lookup slot, downloaded.lookup slot with
  | some expected, some bytes => if hash bytes = expected then some bytes else none
  | _, _ => none

/-- The actual successful check retains both directory lookup and returned bytes. -/
theorem readLocal_eq_some_iff (hash : Bytes → TCB.Hash32) (view : PublicManifestView Slot)
    (slot : Slot) (downloaded : List (Slot × Bytes)) (bytes : Bytes) :
    readLocal hash view slot downloaded = some bytes ↔
      ∃ digest, view.directory.lookup slot = some digest ∧
        downloaded.lookup slot = some bytes ∧ hash bytes = digest := by
  cases directory : view.directory.lookup slot with
  | none => simp [readLocal, directory]
  | some digest =>
    cases rows : downloaded.lookup slot with
    | none => simp [readLocal, directory, rows]
    | some returned =>
      by_cases checked : hash returned = digest
      · simp [readLocal, directory, rows, checked]
        aesop
      · simp [readLocal, directory, rows, checked]
        intro bound same
        exact checked ((congrArg hash same).trans bound.symm)

/-- Lawful slot equality identifies both actual directory and downloaded entries. -/
theorem readLocal_members [LawfulBEq Slot] (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (slot : Slot) (downloaded : List (Slot × Bytes))
    {bytes : Bytes} (accepted : readLocal hash view slot downloaded = some bytes) :
    ∃ digest, (slot, digest) ∈ view.directory ∧ (slot, bytes) ∈ downloaded ∧
      hash bytes = digest := by
  obtain ⟨digest, directory, rows, checked⟩ :=
    (readLocal_eq_some_iff hash view slot downloaded bytes).mp accepted
  obtain ⟨before, after, named, _⟩ := List.lookup_eq_some_iff.mp directory
  obtain ⟨left, right, returned, _⟩ := List.lookup_eq_some_iff.mp rows
  refine ⟨digest, ?_, ?_, checked⟩
  · rw [named]
    simp
  · rw [returned]
    simp

/-- A missing directory entry cannot be accepted, regardless of downloaded data. -/
theorem readLocal_none_of_directory_missing (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (slot : Slot) (downloaded : List (Slot × Bytes))
    (missing : view.directory.lookup slot = none) :
    readLocal hash view slot downloaded = none := by
  simp [readLocal, missing]

/-- A missing downloaded entry cannot be accepted. -/
theorem readLocal_none_of_bytes_missing (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (slot : Slot) (downloaded : List (Slot × Bytes))
    (missing : downloaded.lookup slot = none) :
    readLocal hash view slot downloaded = none := by
  cases view.directory.lookup slot <;> simp [readLocal, missing]

/-- A selected candidate with the wrong digest is rejected before decoding. -/
theorem readLocal_none_of_wrong_digest (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (slot : Slot) (downloaded : List (Slot × Bytes))
    {digest : TCB.Hash32} {bytes : Bytes}
    (directory : view.directory.lookup slot = some digest)
    (rows : downloaded.lookup slot = some bytes) (wrong : hash bytes ≠ digest) :
    readLocal hash view slot downloaded = none := by
  simp [readLocal, directory, rows, wrong]

/-- Honest already-downloaded bytes for the selected directory entry are accepted. -/
theorem readLocal_eq_some_of_matching (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (slot : Slot) (downloaded : List (Slot × Bytes))
    {digest : TCB.Hash32} {bytes : Bytes}
    (directory : view.directory.lookup slot = some digest)
    (rows : downloaded.lookup slot = some bytes) (bound : hash bytes = digest) :
    readLocal hash view slot downloaded = some bytes :=
  (readLocal_eq_some_iff hash view slot downloaded bytes).mpr ⟨digest, directory, rows, bound⟩

/-- Accepted substitution of the named original bytes exposes an actual collision.
Only binding of this original entry is needed; no universal hash law is used. -/
theorem readLocal_original_or_collision (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (slot : Slot) (downloaded : List (Slot × Bytes))
    {original returned : Bytes}
    (directory : view.directory.lookup slot = some (hash original))
    (accepted : readLocal hash view slot downloaded = some returned) :
    returned = original ∨ (returned ≠ original ∧ hash returned = hash original) := by
  obtain ⟨digest, named, _rows, checked⟩ :=
    (readLocal_eq_some_iff hash view slot downloaded returned).mp accepted
  have sameDigest : digest = hash original := Option.some.inj (named.symm.trans directory)
  by_cases same : returned = original
  · exact Or.inl same
  · exact Or.inr ⟨same, checked.trans sameDigest⟩

/-- A target-specific absence of collisions recovers the exact named original. -/
theorem readLocal_eq_original_of_no_collision (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (slot : Slot) (downloaded : List (Slot × Bytes))
    {original returned : Bytes}
    (directory : view.directory.lookup slot = some (hash original))
    (accepted : readLocal hash view slot downloaded = some returned)
    (noCollision : ∀ candidate, hash candidate = hash original → candidate = original) :
    returned = original := by
  rcases readLocal_original_or_collision hash view slot downloaded directory accepted with
    same | collision
  · exact same
  · exact noCollision returned collision.2

/-- Invoke a selected finite ciphertext parser only after successful digest checking. -/
def decodeLocal {Decoded : Type*} (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option Decoded) (view : PublicManifestView Slot)
    (slot : Slot) (downloaded : List (Slot × Bytes)) : Option Decoded :=
  (readLocal hash view slot downloaded).bind decode

/-- Successful decoding identifies the actual authenticated byte candidate. -/
theorem decodeLocal_eq_some_iff {Decoded : Type*} (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option Decoded) (view : PublicManifestView Slot)
    (slot : Slot) (downloaded : List (Slot × Bytes)) (value : Decoded) :
    decodeLocal hash decode view slot downloaded = some value ↔
      ∃ bytes, readLocal hash view slot downloaded = some bytes ∧ decode bytes = some value := by
  cases read : readLocal hash view slot downloaded with
  | none => simp [decodeLocal, read]
  | some bytes => simp [decodeLocal, read]

/-- Rejected or absent bytes never reach the selected parser. -/
theorem decodeLocal_none_of_read_none {Decoded : Type*} (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option Decoded) (view : PublicManifestView Slot)
    (slot : Slot) (downloaded : List (Slot × Bytes))
    (rejected : readLocal hash view slot downloaded = none) :
    decodeLocal hash decode view slot downloaded = none := by
  simp [decodeLocal, rejected]

/-- Any different decoded result after accepted hashing supplies a colliding
byte candidate; finite parsing alone cannot bypass the content check. -/
theorem decodeLocal_original_or_collision {Decoded : Type*} (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option Decoded) (view : PublicManifestView Slot)
    (slot : Slot) (downloaded : List (Slot × Bytes))
    {original : Bytes} {expected returned : Decoded}
    (directory : view.directory.lookup slot = some (hash original))
    (decodes : decode original = some expected)
    (accepted : decodeLocal hash decode view slot downloaded = some returned) :
    returned = expected ∨
      ∃ candidate, candidate ≠ original ∧ hash candidate = hash original ∧
        readLocal hash view slot downloaded = some candidate ∧ decode candidate = some returned := by
  obtain ⟨bytes, read, parsed⟩ :=
    (decodeLocal_eq_some_iff hash decode view slot downloaded returned).mp accepted
  rcases readLocal_original_or_collision hash view slot downloaded directory read with same | collision
  · subst bytes
    exact Or.inl (Option.some.inj (parsed.symm.trans decodes))
  · exact Or.inr ⟨bytes, collision.1, collision.2, read, parsed⟩

end Slots

section Digests

variable {Slot : Type*}

/-- Resolve a named ciphertext digest entirely within the downloaded bucket.
Directory membership restricts selection to listed names; the candidate's actual
bytes are hashed before return. Duplicate slot labels do not affect this check. -/
def readByDigest (hash : Bytes → TCB.Hash32) (view : PublicManifestView Slot)
    (digest : TCB.Hash32) (downloaded : List (Slot × Bytes)) : Option Bytes :=
  if digest ∈ view.directory.map Prod.snd then
    (downloaded.map Prod.snd).find? (fun bytes => decide (hash bytes = digest))
  else none

/-- Success retains public-directory membership, actual downloaded bytes and
their checked hash; no server-side selected lookup is part of this function. -/
theorem readByDigest_sound (hash : Bytes → TCB.Hash32) (view : PublicManifestView Slot)
    (digest : TCB.Hash32) (downloaded : List (Slot × Bytes)) {bytes : Bytes}
    (accepted : readByDigest hash view digest downloaded = some bytes) :
    digest ∈ view.directory.map Prod.snd ∧ bytes ∈ downloaded.map Prod.snd ∧
      hash bytes = digest := by
  unfold readByDigest at accepted
  split at accepted
  next named =>
    have checked : decide (hash bytes = digest) = true :=
      List.find?_some (p := fun candidate => decide (hash candidate = digest)) accepted
    exact ⟨named, List.mem_of_find?_eq_some accepted,
      of_decide_eq_true checked⟩
  next => contradiction

/-- An unlisted ciphertext digest is rejected, even if matching bytes were sent. -/
theorem readByDigest_none_of_unlisted (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (digest : TCB.Hash32) (downloaded : List (Slot × Bytes))
    (unlisted : digest ∉ view.directory.map Prod.snd) :
    readByDigest hash view digest downloaded = none := by
  simp [readByDigest, unlisted]

/-- If every received candidate has another hash, the requested object is absent. -/
theorem readByDigest_none_of_no_match (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (digest : TCB.Hash32) (downloaded : List (Slot × Bytes))
    (missing : ∀ candidate ∈ downloaded.map Prod.snd, hash candidate ≠ digest) :
    readByDigest hash view digest downloaded = none := by
  cases read : readByDigest hash view digest downloaded with
  | none => rfl
  | some bytes =>
    obtain ⟨_named, present, checked⟩ := readByDigest_sound hash view digest downloaded read
    exact False.elim (missing bytes present checked)

/-- A named original actually present in the downloaded bucket yields a
checked result, even if another colliding candidate occurs earlier. -/
theorem readByDigest_complete (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (downloaded : List (Slot × Bytes))
    {original : Bytes}
    (named : hash original ∈ view.directory.map Prod.snd)
    (present : original ∈ downloaded.map Prod.snd) :
    ∃ returned, readByDigest hash view (hash original) downloaded = some returned := by
  unfold readByDigest
  rw [ite_eq_left named]
  cases found : (downloaded.map Prod.snd).find?
      (fun bytes => decide (hash bytes = hash original)) with
  | some returned => exact ⟨returned, rfl⟩
  | none =>
    have absent := List.find?_eq_none.mp found
    exact False.elim (absent original present (by simp))

/-- A substitution for the requested content hash yields an actual collision. -/
theorem readByDigest_original_or_collision (hash : Bytes → TCB.Hash32)
    (view : PublicManifestView Slot) (downloaded : List (Slot × Bytes))
    {original returned : Bytes}
    (accepted : readByDigest hash view (hash original) downloaded = some returned) :
    returned = original ∨ (returned ≠ original ∧ hash returned = hash original) := by
  have checked := (readByDigest_sound hash view (hash original) downloaded accepted).2.2
  by_cases same : returned = original
  · exact Or.inl same
  · exact Or.inr ⟨same, checked⟩

/-- Parse only ciphertext bytes already accepted for the requested content hash. -/
def decodeByDigest {Decoded : Type*} (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option Decoded) (view : PublicManifestView Slot)
    (digest : TCB.Hash32) (downloaded : List (Slot × Bytes)) : Option Decoded :=
  (readByDigest hash view digest downloaded).bind decode

/-- The digest-selected parser result retains its actual authenticated input. -/
theorem decodeByDigest_eq_some_iff {Decoded : Type*} (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option Decoded) (view : PublicManifestView Slot)
    (digest : TCB.Hash32) (downloaded : List (Slot × Bytes)) (value : Decoded) :
    decodeByDigest hash decode view digest downloaded = some value ↔
      ∃ bytes, readByDigest hash view digest downloaded = some bytes ∧ decode bytes = some value := by
  cases read : readByDigest hash view digest downloaded with
  | none => simp [decodeByDigest, read]
  | some bytes => simp [decodeByDigest, read]

/-- A different parsed value for the named original ciphertext supplies a
colliding downloaded byte candidate, independently of duplicate slot labels. -/
theorem decodeByDigest_original_or_collision {Decoded : Type*} (hash : Bytes → TCB.Hash32)
    (decode : Bytes → Option Decoded) (view : PublicManifestView Slot)
    (downloaded : List (Slot × Bytes)) {original : Bytes} {expected returned : Decoded}
    (decodes : decode original = some expected)
    (accepted : decodeByDigest hash decode view (hash original) downloaded = some returned) :
    returned = expected ∨
      ∃ candidate, candidate ≠ original ∧ hash candidate = hash original ∧
        readByDigest hash view (hash original) downloaded = some candidate ∧
        decode candidate = some returned := by
  obtain ⟨bytes, read, parsed⟩ :=
    (decodeByDigest_eq_some_iff hash decode view (hash original) downloaded returned).mp accepted
  rcases readByDigest_original_or_collision hash view downloaded read with same | collision
  · subst bytes
    exact Or.inl (Option.some.inj (parsed.symm.trans decodes))
  · exact Or.inr ⟨bytes, collision.1, collision.2, read, parsed⟩

end Digests

end Hcrypt.Protocol.Storage.Retrieval.ContentAddress
