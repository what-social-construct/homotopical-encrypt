module

public import Protocol.Storage.Retrieval.Indexed
public import Protocol.Storage.Sha256
public import Mathlib.Data.List.OfFn
public import Std.Data.HashMap.Lemmas

@[expose] public section

/-!
# A digest-indexed reference store for encrypted cells

Each value is the entire byte payload of one encrypted cell. Insertion and
lookup use the 32 bytes of SHA-256 as the key. A read checks the returned
payload against the expected digest. The caller supplies that digest.
Identity resolution, durable persistence, and selector privacy are separate.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.EncryptedCell

open TCB.PrimitiveChecks (Bytes)

abbrev Store := Std.HashMap (List UInt8) Bytes

/-- Store the entire encrypted value under its SHA-256 address. Reject
distinct bytes at an occupied address so an insertion cannot replace them. -/
def insert (store : Store) (bytes : Bytes) : Option (TCB.Hash32 × Store) :=
  let computed := Sha256.digestBytes bytes
  let address := Sha256.toHash32 computed
  let key := Sha256.key computed
  match store[key]? with
  | none => some (address, store.insert key bytes)
  | some existing => if existing = bytes then some (address, store) else none

/-- One direct index operation at the requested digest. -/
def lookup (store : Store) (address : TCB.Hash32) : Option Bytes :=
  store[List.ofFn address]?

/-- Verify the complete returned object, evaluating its SHA-256 digest once. -/
def read (store : Store) (address : TCB.Hash32) : Option Bytes :=
  (lookup store address).filter fun bytes =>
    decide (Sha256.key (Sha256.digestBytes bytes) = List.ofFn address)

theorem read_eq_indexed (store : Store) (address : TCB.Hash32) :
    read store address = Retrieval.Indexed.read Sha256.digest (lookup store) address := by
  apply Option.ext
  intro bytes
  rw [Retrieval.Indexed.read_eq_some_iff]
  simp only [read, Option.filter_eq_some_iff, decide_eq_true_eq, Sha256.key,
    Sha256.digest, List.ofFn_inj]

/-- Successful insertion retains the original bytes and names them by SHA-256. -/
theorem insert_lookup (store : Store) (bytes : Bytes) {address : TCB.Hash32} {next : Store}
    (stored : insert store bytes = some (address, next)) :
    address = Sha256.digest bytes ∧ lookup next address = some bytes := by
  unfold insert at stored
  dsimp only at stored
  cases current : store[Sha256.key (Sha256.digestBytes bytes)]? with
  | none =>
    simp only [current, Option.some.injEq, Prod.mk.injEq] at stored
    obtain ⟨rfl, rfl⟩ := stored
    exact ⟨rfl, Std.HashMap.getElem?_insert_self⟩
  | some existing =>
    simp only [current] at stored
    split at stored
    · rename_i same
      have pair := Option.some.inj stored
      obtain ⟨rfl, rfl⟩ := Prod.mk.inj pair
      exact ⟨rfl, current.trans (congrArg some same)⟩
    · contradiction

theorem read_insert (store : Store) (bytes : Bytes) {address : TCB.Hash32} {next : Store}
    (stored : insert store bytes = some (address, next)) : read next address = some bytes := by
  obtain ⟨named, found⟩ := insert_lookup store bytes stored
  rw [read_eq_indexed]
  exact (Retrieval.Indexed.read_eq_some_iff _ _ _ _).mpr ⟨found, named.symm⟩

theorem read_original_or_collision (store : Store) {original returned : Bytes}
    (accepted : read store (Sha256.digest original) = some returned) :
    returned = original ∨
      (returned ≠ original ∧ Sha256.digest returned = Sha256.digest original) := by
  rw [read_eq_indexed] at accepted
  exact Retrieval.Indexed.read_original_or_collision Sha256.digest (lookup store) accepted

end HomotopicalEncryption.Protocol.Storage.EncryptedCell
