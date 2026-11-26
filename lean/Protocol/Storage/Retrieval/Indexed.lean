module

public import TCB.PrimitiveChecks

@[expose] public section

/-!
# Digest-indexed encrypted-object reads

The index returns an entire byte object for the requested digest. The caller
checks the digest of those bytes before using them. This check takes the
requested digest as input and the lookup receives that same digest.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.Retrieval.Indexed

open TCB.PrimitiveChecks (Bytes)

/-- Fetch and check the complete bytes for one content address. -/
def read (hash : Bytes → TCB.Hash32) (lookup : TCB.Hash32 → Option Bytes)
    (digest : TCB.Hash32) : Option Bytes :=
  (lookup digest).filter fun bytes => decide (hash bytes = digest)

/-- Success requires both the actual lookup response and its matching digest. -/
theorem read_eq_some_iff (hash : Bytes → TCB.Hash32) (lookup : TCB.Hash32 → Option Bytes)
    (digest : TCB.Hash32) (bytes : Bytes) :
    read hash lookup digest = some bytes ↔ lookup digest = some bytes ∧ hash bytes = digest := by
  simp only [read, Option.filter_eq_some_iff, decide_eq_true_eq]

/-- An accepted substitution for a named original exhibits a hash collision. -/
theorem read_original_or_collision (hash : Bytes → TCB.Hash32)
    (lookup : TCB.Hash32 → Option Bytes) {original returned : Bytes}
    (accepted : read hash lookup (hash original) = some returned) :
    returned = original ∨ (returned ≠ original ∧ hash returned = hash original) := by
  have checked := ((read_eq_some_iff hash lookup (hash original) returned).mp accepted).2
  by_cases same : returned = original
  · exact Or.inl same
  · exact Or.inr ⟨same, checked⟩

end HomotopicalEncryption.Protocol.Storage.Retrieval.Indexed
