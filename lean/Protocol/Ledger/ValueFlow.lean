module

public import Mathlib.Data.Finsupp.Order

@[expose] public section

/-!
Finite resource markings and exact conservative updates.

The resource and asset types remain abstract. Fees can be represented among
produced resources; explicit minting and burning policies belong in later
protocol refinements.
-/

namespace HomotopicalEncryption
namespace Protocol
namespace Ledger

/-- A finite inventory of resources with nonnegative integral multiplicities. -/
abbrev Marking (Resource : Type) := Resource →₀ ℕ

/-- Additive asset valuation of a finite resource marking. -/
structure ValueModel (Resource Asset : Type) where
  value : Marking Resource →+ (Asset → ℕ)

/-- The resource inventory consumed and produced by one action. -/
structure ResourceFlow (Resource : Type) where
  consumed : Marking Resource
  produced : Marking Resource

namespace ResourceFlow

variable {Resource Asset : Type}

/-- Remove consumed resources and add produced resources. -/
noncomputable def apply (flow : ResourceFlow Resource) (marking : Marking Resource) :
    Marking Resource :=
  (marking - flow.consumed) + flow.produced

/-- Every requested resource is available before applying the flow. -/
def Enabled (flow : ResourceFlow Resource) (marking : Marking Resource) : Prop :=
  flow.consumed ≤ marking

/-- The consumed and produced inventories have equal value in every asset. -/
def Conserves (flow : ResourceFlow Resource) (V : ValueModel Resource Asset) : Prop :=
  V.value flow.consumed = V.value flow.produced

/-- Enabled consumption has no loss from truncated subtraction. -/
theorem remainder_add_consumed
    (flow : ResourceFlow Resource)
    (marking : Marking Resource)
    (hEnabled : flow.Enabled marking) :
    marking - flow.consumed + flow.consumed = marking :=
  tsub_add_cancel_of_le hEnabled

/-- Applying an enabled conservative flow preserves the actual marking value. -/
theorem value_apply
    (flow : ResourceFlow Resource)
    (V : ValueModel Resource Asset)
    (marking : Marking Resource)
    (hEnabled : flow.Enabled marking)
    (hConserves : flow.Conserves V) :
    V.value (flow.apply marking) = V.value marking := by
  change V.value ((marking - flow.consumed) + flow.produced) = V.value marking
  rw [map_add, ← hConserves, ← map_add, flow.remainder_add_consumed marking hEnabled]

end ResourceFlow

end Ledger
end Protocol
end HomotopicalEncryption
