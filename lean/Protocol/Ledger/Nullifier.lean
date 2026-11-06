module

public import Mathlib.Data.Finset.Basic
public import Mathlib.Data.Finset.Dedup

@[expose] public section

/-!
Finite nullifier consumption from an action's body list.

Freshness is checked against the prior spent set. Any requirement that the
body list itself has no duplicates is an additional action-validity condition.
-/

namespace Hcrypt
namespace Protocol
namespace Ledger
namespace Nullifiers

variable {N : Type} [DecidableEq N]

/-- Every nullifier used by the action is fresh relative to the prior state. -/
def Fresh (spent : Finset N) (uses : List N) : Prop :=
  ∀ n ∈ uses, n ∉ spent

/-- Record exactly the nullifiers from the action body alongside prior spends. -/
def consume (spent : Finset N) (uses : List N) : Finset N :=
  spent ∪ uses.toFinset

/-- Consuming an action preserves every previously spent nullifier. -/
theorem spent_subset_consume (spent : Finset N) (uses : List N) :
    spent ⊆ consume spent uses :=
  Finset.subset_union_left

/-- Every nullifier in the action body is marked spent after consumption. -/
theorem mem_consume_of_mem
    (spent : Finset N)
    {uses : List N}
    {n : N}
    (hn : n ∈ uses) :
    n ∈ consume spent uses :=
  Finset.mem_union.mpr (Or.inr (List.mem_toFinset.mpr hn))

/-- A nonempty action body cannot be fresh after its nullifiers are consumed. -/
theorem not_fresh_consume
    (spent : Finset N)
    (uses : List N)
    (hUses : uses ≠ []) :
    ¬ Fresh (consume spent uses) uses := by
  cases uses with
  | nil => exact (hUses rfl).elim
  | cons n rest =>
      intro hFresh
      have hn : n ∈ n :: rest := by simp
      exact hFresh n hn (mem_consume_of_mem spent hn)

end Nullifiers
end Ledger
end Protocol
end Hcrypt
