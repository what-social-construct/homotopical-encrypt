module

public import Protocol.Storage.CoupledCodec
public import Protocol.Storage.Context
public import Sheaf.HCPCoupledFamily

@[expose] public section

/-!
# Canonical coupled presentations bound to the original snapshot

The codec determines the matrix, scalar stalks, standard integral structure
and Euclidean metric of the coupled family. This optional profile identifies
its canonical byte hash with the existing snapshot root. A successful parser
and root check recovers the named packet or exhibits an actual hash collision.
No global injectivity or hiding property is assumed for the hash function.

The equation below is an additional concrete profile condition. It does not
construct the generic snapshot's remaining authentication obligations.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CoupledBinding

open Sheaf CellularSheaf
open CoupledCodec

/-- Parse a canonical presentation and check its exact named content root. -/
def check (hash : Bytes → TCB.Hash32) (root : TCB.Hash32)
    (bytes : Bytes) : Option Packet := do
  let p ← decode bytes
  if hash bytes = root then some p else none

theorem check_eq_some_iff (hash : Bytes → TCB.Hash32) (root : TCB.Hash32)
    (bytes : Bytes) (p : Packet) :
    check hash root bytes = some p ↔ bytes = encode p ∧ hash bytes = root := by
  cases parsed : decode bytes with
  | none => simp [check, parsed, ← decode_eq_some_iff]
  | some q =>
    have canonical := (decode_eq_some_iff bytes q).mp parsed
    have hp : bytes = encode p ↔ q = p := by
      constructor
      · intro same
        exact encode_injective (canonical.symm.trans same)
      · rintro rfl
        exact canonical
    by_cases hroot : hash bytes = root <;>
      simp [check, parsed, hroot, hp]

/-- Original canonical bytes always pass their own content-root check. -/
theorem check_encode (hash : Bytes → TCB.Hash32) (p : Packet) :
    check hash (hash (encode p)) (encode p) = some p :=
  (check_eq_some_iff hash _ _ p).mpr ⟨rfl, rfl⟩

/-- Accepted substitution for a named presentation is exact or a byte collision. -/
theorem check_original_or_collision (hash : Bytes → TCB.Hash32)
    (original returned : Packet) (bytes : Bytes)
    (accepted : check hash (hash (encode original)) bytes = some returned) :
    returned = original ∨
      (bytes ≠ encode original ∧ hash bytes = hash (encode original)) := by
  obtain ⟨canonical, checked⟩ := (check_eq_some_iff hash _ bytes returned).mp accepted
  by_cases same : returned = original
  · exact Or.inl same
  · refine Or.inr ⟨?_, checked⟩
    intro hbytes
    exact same (encode_injective (canonical.symm.trans hbytes))

/-- The canonical integer presentation uses the original sheaf-indexed snapshot. -/
def BindsSnapshot (hash : Bytes → TCB.Hash32) {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ)
    (snapshot : SheafStateSnapshot (HCPCoupledFamily.sheaf B)) : Prop :=
  hash (encode (ofMatrix B)) = snapshot.root

/-- The same profile condition is visible in the existing derived context key. -/
theorem context_root_eq (hash : Bytes → TCB.Hash32) {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ)
    (C : Context (HCPCoupledFamily.sheaf B))
    (bound : BindsSnapshot hash B C.interpretation.snapshot) :
    hash (encode (ofMatrix B)) = C.key.snapshotRoot := bound

/-- A check under the original snapshot retains the actual matrix packet or collision. -/
theorem snapshot_original_or_collision (hash : Bytes → TCB.Hash32) {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ)
    (snapshot : SheafStateSnapshot (HCPCoupledFamily.sheaf B))
    (bound : BindsSnapshot hash B snapshot) (bytes : Bytes) (returned : Packet)
    (accepted : check hash snapshot.root bytes = some returned) :
    returned = ofMatrix B ∨
      (bytes ≠ encode (ofMatrix B) ∧ hash bytes = hash (encode (ofMatrix B))) := by
  rw [← bound] at accepted
  exact check_original_or_collision hash _ returned bytes accepted

end HomotopicalEncryption.Protocol.Storage.CoupledBinding
