module

public import Protocol.Storage.CellDirectory.Codec
public import Protocol.Storage.CellDirectory.Patch
public import Protocol.Storage.EncryptedCell
public import Protocol.Storage.PublicView

@[expose] public section

/-!
# Checked directory fragments for one storage context

A caller supplies the trusted context and directory root for its snapshot.
Canonical directory bytes bind the complete context key and ordered cell
entries under SHA-256. After checking that directory once, the caller can
verify and merge smaller views, then read whole ciphertexts by cell ID.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CellDirectory

open Codec (Entries)
open TCB.PrimitiveChecks (Bytes)

/-- A directory checked against the caller's context and directory root. -/
structure Verified (context : ContextKey) (root : TCB.Hash32) where
  entries : Entries
  uniqueCells : (entries.map Prod.fst).Nodup
  committed : Sha256.digest (Codec.encode context entries) = root

def verifyEntries (context : ContextKey) (root : TCB.Hash32)
    (claimed : ContextKey) (entries : Entries) : Option (Verified context root) :=
  if claimed = context then
    if unique : (entries.map Prod.fst).Nodup then
      let computed := Sha256.digestBytes (Codec.encode context entries)
      if bound : Sha256.key computed = List.ofFn root then
        some ⟨entries, unique, List.ofFn_injective bound⟩
      else none
    else none
  else none

theorem verifyEntries_eq_some_iff (context : ContextKey) (root : TCB.Hash32)
    (claimed : ContextKey) (entries : Entries) (checked : Verified context root) :
    verifyEntries context root claimed entries = some checked ↔
      claimed = context ∧ entries = checked.entries := by
  constructor
  · intro accepted
    unfold verifyEntries at accepted
    split at accepted
    next sameContext =>
      split at accepted
      next unique =>
        dsimp only at accepted
        split at accepted
        next bound =>
          exact ⟨sameContext, congrArg Verified.entries (Option.some.inj accepted)⟩
        next => exact (Option.some_ne_none checked accepted.symm).elim
      next => exact (Option.some_ne_none checked accepted.symm).elim
    next => exact (Option.some_ne_none checked accepted.symm).elim
  · rintro ⟨sameContext, sameEntries⟩
    subst claimed
    subst entries
    have digestEq : Sha256.key (Sha256.digestBytes (Codec.encode context checked.entries)) =
        List.ofFn root := congrArg (fun hash : TCB.Hash32 => List.ofFn hash) checked.committed
    simp only [verifyEntries, if_true, dite_eq_left checked.uniqueCells, dite_eq_left digestEq]

/-- Parse the exact directory bytes and check their context, unique cell IDs and root. -/
def verify (context : ContextKey) (root : TCB.Hash32) (bytes : Bytes) :
    Option (Verified context root) :=
  (Codec.decode bytes).bind fun (claimed, entries) => verifyEntries context root claimed entries

theorem verify_eq_some_iff (context : ContextKey) (root : TCB.Hash32) (bytes : Bytes)
    (checked : Verified context root) :
    verify context root bytes = some checked ↔ bytes = Codec.encode context checked.entries := by
  constructor
  · intro accepted
    unfold verify at accepted
    cases parsed : Codec.decode bytes with
    | none => simp [parsed] at accepted
    | some value =>
      obtain ⟨claimed, entries⟩ := value
      simp only [parsed, Option.bind_some] at accepted
      obtain ⟨rfl, rfl⟩ := (verifyEntries_eq_some_iff _ _ _ _ _).mp accepted
      exact (Codec.decode_eq_some_iff _ _ _).mp parsed
  · rintro rfl
    simp [verify, verifyEntries_eq_some_iff]

/-- Check the directory projection of an existing public manifest at the
caller-supplied name. The context and slots use the directory codec. -/
def verifyView (context : ContextKey) (root : TCB.Hash32) (view : PublicManifestView ℕ) :
    Option (Verified context root) :=
  if view.root = root then verifyEntries context root view.base.key view.directory else none

theorem verifyView_eq_some_iff (context : ContextKey) (root : TCB.Hash32)
    (view : PublicManifestView ℕ) (checked : Verified context root) :
    verifyView context root view = some checked ↔
      view.root = root ∧ view.base.key = context ∧ view.directory = checked.entries := by
  by_cases bound : view.root = root <;> simp [verifyView, bound, verifyEntries_eq_some_iff]

namespace Verified

variable {context : ContextKey} {root : TCB.Hash32}

def preimage (directory : Verified context root) : Bytes := Codec.encode context directory.entries

/-- Independently verified directories at one name agree, or give distinct
canonical preimages with equal SHA-256. -/
theorem entries_eq_or_collision (left right : Verified context root) :
    left.entries = right.entries ∨
      (left.preimage ≠ right.preimage ∧ Sha256.digest left.preimage = Sha256.digest right.preimage) := by
  by_cases same : left.entries = right.entries
  · exact Or.inl same
  · refine Or.inr ⟨?_, left.committed.trans right.committed.symm⟩
    intro encoded
    have pair : (context, left.entries) = (context, right.entries) := Codec.encode_injective encoded
    exact same (congrArg Prod.snd pair)

def checkPatch (directory : Verified context root) (entries : Entries) :
    Option (Patch directory.entries) := Patch.check directory.entries entries

/-- Overlap consistency for fragments of independently verified views at the
same trusted name, with the explicit collision alternative. -/
theorem overlap_agrees_or_collision (left right : Verified context root)
    (leftPatch : Patch left.entries) (rightPatch : Patch right.entries)
    {cell : ℕ} {leftDigest rightDigest : TCB.Hash32}
    (leftFound : leftPatch.resolve cell = some leftDigest)
    (rightFound : rightPatch.resolve cell = some rightDigest) :
    leftDigest = rightDigest ∨
      (left.preimage ≠ right.preimage ∧ Sha256.digest left.preimage = Sha256.digest right.preimage) := by
  rcases left.entries_eq_or_collision right with same | collision
  · have named := leftPatch.resolve_sound leftFound
    rw [same] at named
    exact Or.inl (Option.some.inj (named.symm.trans (rightPatch.resolve_sound rightFound)))
  · exact Or.inr collision

/-- A fetch resolves one checked cell ID and verifies the entire named ciphertext. -/
def read (directory : Verified context root) (patch : Patch directory.entries)
    (store : EncryptedCell.Store) (cell : ℕ) : Option Bytes :=
  (patch.resolve cell).bind (EncryptedCell.read store)

theorem read_eq_some_iff (directory : Verified context root) (patch : Patch directory.entries)
    (store : EncryptedCell.Store) (cell : ℕ) (bytes : Bytes) :
    directory.read patch store cell = some bytes ↔
      ∃ digest, patch.resolve cell = some digest ∧ EncryptedCell.read store digest = some bytes := by
  simp only [read, Option.bind_eq_some_iff]

/-- The authoritative directory's original content survives a checked read,
unless the content bytes themselves exhibit a SHA-256 collision. -/
theorem read_original_or_collision (directory : Verified context root) (patch : Patch directory.entries)
    (store : EncryptedCell.Store) (cell : ℕ) {original returned : Bytes}
    (named : directory.entries.lookup cell = some (Sha256.digest original))
    (accepted : directory.read patch store cell = some returned) :
    returned = original ∨ (returned ≠ original ∧ Sha256.digest returned = Sha256.digest original) := by
  obtain ⟨digest, resolved, fetched⟩ := (directory.read_eq_some_iff _ _ _ _).mp accepted
  have bound : digest = Sha256.digest original :=
    Option.some.inj ((patch.resolve_sound resolved).symm.trans named)
  rw [bound] at fetched
  exact EncryptedCell.read_original_or_collision store fetched

end Verified

end HomotopicalEncryption.Protocol.Storage.CellDirectory
