module

public import Mathlib.LinearAlgebra.ExteriorPower.Basis
public import Mathlib.LinearAlgebra.Quotient.Basic

public section

/-!
# Exterior-square incidence for syndrome pencils
-/

set_option autoImplicit false

namespace ProximityCoding.BlockCode.Syndrome

variable {F V : Type*} [Field F] [AddCommGroup V] [Module F V]

private theorem exteriorPair_eq_zero_iff (v : Fin 2 → V) :
    exteriorPower.ιMulti F 2 v = 0 ↔ ¬ LinearIndependent F v := by
  refine ⟨?_, (exteriorPower.ιMulti F 2).map_linearDependent v⟩
  intro zero independent
  let e : Fin 2 ↪o Fin 2 := (OrderIso.refl (Fin 2)).toOrderEmbedding
  let s := Set.powersetCard.ofFinEmbEquiv e
  have nonzero := (exteriorPower.ιMulti_family_linearIndependent_field (n := 2) independent).ne_zero s
  apply nonzero
  simpa [exteriorPower.ιMulti_family, s, e, Function.comp_def] using zero

/-- A syndrome pencil meets a support subspace nontrivially precisely when its
two generators have zero exterior product in the quotient by that subspace. -/
theorem projectedWedge_eq_zero_iff (M : (F × F) →ₗ[F] V) (injective : Function.Injective M)
    (U : Submodule F V) :
    exteriorPower.ιMulti F 2 ![U.mkQ (M (1, 0)), U.mkQ (M (0, 1))] = 0 ↔
      ¬ Disjoint M.range U := by
  let N := U.mkQ.comp M
  change exteriorPower.ιMulti F 2 ![N (1, 0), N (0, 1)] = 0 ↔ ¬ Disjoint M.range U
  have combine (a b : F) : N (a, b) = a • N (1, 0) + b • N (0, 1) := by
    rw [← N.map_smul, ← N.map_smul, ← N.map_add]
    congr 1
    ext <;> simp
  have independent_iff : LinearIndependent F ![N (1, 0), N (0, 1)] ↔ Function.Injective N := by
    rw [LinearIndependent.pair_iffₛ]
    constructor
    · rintro independent ⟨a, b⟩ ⟨a', b'⟩ equal
      rw [combine a b, combine a' b'] at equal
      have coefficients := independent a b a' b' equal
      exact Prod.ext coefficients.1 coefficients.2
    · intro hinj a b a' b' equal
      have coordinates := hinj ((combine a b).trans (equal.trans (combine a' b').symm))
      exact ⟨congrArg Prod.fst coordinates, congrArg Prod.snd coordinates⟩
  have injective_iff : Function.Injective N ↔ Disjoint M.range U := by
    have disjoint_iff_injOn : Disjoint M.range U ↔ Set.InjOn U.mkQ M.range := by
      simpa only [Submodule.ker_mkQ] using
        (LinearMap.disjoint_ker_iff_injOn (f := U.mkQ) (p := M.range))
    rw [disjoint_iff_injOn]
    constructor
    · rintro hinj _ ⟨a, rfl⟩ _ ⟨b, rfl⟩ equal
      exact congrArg M (hinj equal)
    · intro hinj a b equal
      exact injective (hinj ⟨a, rfl⟩ ⟨b, rfl⟩ equal)
  rw [exteriorPair_eq_zero_iff, independent_iff, injective_iff]

end ProximityCoding.BlockCode.Syndrome
