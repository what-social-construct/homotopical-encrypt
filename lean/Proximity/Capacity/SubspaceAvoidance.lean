module

public import Mathlib.Algebra.Module.Submodule.Union

@[expose] public section

/-! # Proper-subspace avoidance over a finite field -/

set_option autoImplicit false

namespace ProximityCoding

/-- Fewer proper subspaces than field elements leave a vector outside every subspace. -/
theorem exists_outside_subspaces {F V β : Type*} [Field F] [Fintype F]
    [AddCommGroup V] [Module F V] [Fintype β]
    (U : β → Submodule F V) (proper : ∀ i, U i ≠ ⊤)
    (few : Fintype.card β < Fintype.card F) :
    ∃ x : V, ∀ i, x ∉ U i := by
  have cardBound : (Finset.univ : Finset β).card < ENat.card F := by
    simpa using few
  have unionProper :=
    Submodule.iUnion_ssubset_of_forall_ne_top_of_card_lt Finset.univ U proper cardBound
  simpa [Set.ssubset_univ_iff, Set.iUnion_eq_univ_iff] using unionProper

end ProximityCoding
