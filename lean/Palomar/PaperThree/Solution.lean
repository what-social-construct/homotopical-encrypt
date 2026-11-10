module

public import ProximityCoding

@[expose] public section
set_option autoImplicit false

/-!
# Canonical proofs for the Paper 3 coding statements

The imported development supplies the actual fields, domains, codes and
proofs. Only the two explicit equivalence-law statements need local wrappers.
Challenge is not imported by this module.
-/

namespace HomotopicalEncryption.Palomar.PaperThree
open ProximityCoding
theorem planePairEquiv_inverse_laws {ι F : Type*} :
    (∀ p : PlaneWord ι F, (planePairEquiv ι F).symm (planePairEquiv ι F p) = p) ∧
    (∀ w : PairWord ι F, planePairEquiv ι F ((planePairEquiv ι F).symm w) = w) := by
  exact ⟨(planePairEquiv ι F).left_inv, (planePairEquiv ι F).right_inv⟩
theorem planeLineEquiv_inverse_laws {ι F : Type*} :
    (∀ p : PlaneWord ι F, (planeLineEquiv ι F).symm (planeLineEquiv ι F p) = p) ∧
    (∀ L : AffineLine ι F, planeLineEquiv ι F ((planeLineEquiv ι F).symm L) = L) := by
  exact ⟨(planeLineEquiv ι F).left_inv, (planeLineEquiv ι F).right_inv⟩
end HomotopicalEncryption.Palomar.PaperThree
