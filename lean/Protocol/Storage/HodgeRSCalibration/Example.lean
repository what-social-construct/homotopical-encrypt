module

public import Protocol.Storage.HodgeRSCalibration

@[expose] public section

/-!
# An exact native Hodge and Reed–Solomon calibration over `𝔽₁₇`

The affine evaluation sites are `0` through `7`, with information at `0` and
`1`. The first coexact opening is `(1, -2, 1, 0, 0, 0)`. Its information-edge
contribution cancels over the integers. The second cochain and both harmonic
messages and exact openings are zero.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.HodgeRSCalibration.Example

open ProximityCoding
open scoped BigOperators

local instance : Fact (Nat.Prime 17) := ⟨by decide⟩

abbrev Site := Fin 2 ⊕ Fin 6

/-- The natural evaluation site before its reduction into `ZMod 17`. -/
def label : Site → ℕ := Sum.elim Fin.val (fun r => r.val + 2)

theorem label_lt (i : Site) : label i < 17 := by
  rcases i with c | r
  · exact c.isLt.trans (by decide)
  · change r.val + 2 < 17
    omega

def parameters : ReedSolomon.Parameters (ZMod 17) Site where
  degreeBound := 2
  domain := {
    point := fun i => (label i : ZMod 17)
    injective_point := by
      intro i k h
      have same := congrArg ZMod.val h
      rw [ZMod.val_natCast_of_lt (label_lt i), ZMod.val_natCast_of_lt (label_lt k)] at same
      rcases i with c | r <;> rcases k with d | s
      · exact congrArg Sum.inl (Fin.ext same)
      · change c.val = s.val + 2 at same
        omega
      · change r.val + 2 = d.val at same
        omega
      · exact congrArg Sum.inr (Fin.ext (by change r.val + 2 = s.val + 2 at same; omega)) }

def informationSites : Finset Site := {.inl 0, .inl 1}

theorem left_mem (c : Fin 2) : Sum.inl c ∈ informationSites := by
  fin_cases c <;> decide

theorem right_notMem (r : Fin 6) : Sum.inr r ∉ informationSites := by
  simp [informationSites]

def layout : Layout informationSites (Fin 6) (Fin 2) where
  information := {
    toFun := fun c => ⟨.inl c, left_mem c⟩
    invFun := fun i => Sum.elim id (fun _ => 0) i.val
    left_inv := fun _ => rfl
    right_inv := by
      rintro ⟨c | r, hi⟩
      · rfl
      · exact (right_notMem r hi).elim }
  parity := {
    toFun := fun r => ⟨.inr r, right_notMem r⟩
    invFun := fun i => Sum.elim (fun _ => 0) id i.val
    left_inv := fun _ => rfl
    right_inv := by
      rintro ⟨c | r, hi⟩
      · exact (hi (left_mem c)).elim
      · rfl }

private theorem siteEquiv_eq : layout.siteEquiv = Equiv.refl Site := by
  ext i
  cases i <;> rfl

private theorem degree_pos : 0 < parameters.degreeBound := by decide

private theorem informationSites_card : informationSites.card = parameters.degreeBound := by decide

private def affineBasis (c : Fin 2) (i : Site) : ZMod 17 :=
  if c = 0 then 1 - parameters.domain.point i else parameters.domain.point i

private theorem affineBasis_codeword (c : Fin 2) : parameters.Codeword (affineBasis c) := by
  by_cases hc : c = 0
  · refine ⟨1 - Polynomial.X, ?_, fun i => by simp [affineBasis, hc]⟩
    calc
      (1 - Polynomial.X : Polynomial (ZMod 17)).natDegree ≤
          max (1 : Polynomial (ZMod 17)).natDegree (Polynomial.X : Polynomial (ZMod 17)).natDegree :=
        Polynomial.natDegree_sub_le _ _
      _ < parameters.degreeBound := by simp [parameters]
  · exact ⟨Polynomial.X, by simp [parameters], fun i => by simp [affineBasis, hc]⟩

private theorem coefficient_eq (c : Fin 2) (i : Site) :
    parameters.informationCoefficient informationSites i (layout.information c) = affineBasis c i := by
  apply congrFun (parameters.determinedBy_degreeBound
    (parameters.interpolateWord_codeword degree_pos informationSites_card _)
    (affineBasis_codeword c) informationSites informationSites_card ?_)
  intro k hk
  rw [parameters.interpolateWord_eq_on informationSites _ hk]
  rcases Finset.mem_insert.mp hk with rfl | hk
  · fin_cases c <;> decide
  · obtain rfl := Finset.mem_singleton.mp hk
    fin_cases c <;> decide

/-- The native matrix is the canonical integer lift of the affine basis. -/
theorem matrix_eq (r : Fin 6) (c : Fin 2) :
    matrix parameters layout r c = if c = 0 then 16 - (r.val : ℤ) else (r.val : ℤ) + 2 := by
  change ((parameters.informationCoefficient informationSites (.inr r) (layout.information c)).val : ℤ) = _
  rw [coefficient_eq]
  fin_cases r <;> fin_cases c <;> decide

def opening (j : Fin 2) : Fin 6 → ℤ :=
  if j = 0 then ![1, -2, 1, 0, 0, 0] else 0

private def rawNoise (i : Site) (j : Fin 2) : ℤ :=
  Sum.elim (fun _ => 0) (opening j) i

private theorem noise_eq : noise parameters layout opening = rawNoise := by
  funext i j
  rcases i with c | r
  · simp only [noise, rawPair, siteEquiv_eq, Equiv.refl_symm, Equiv.refl_apply,
      Sheaf.HCPCoupledEncoding.integerObserved, Pi.zero_apply, matrix_eq]
    fin_cases c <;> fin_cases j <;> decide
  · simp [noise, rawPair, siteEquiv_eq, Sheaf.HCPCoupledEncoding.integerObserved, rawNoise]

private theorem receivedPair_eq : receivedPair parameters layout 0 opening =
    (fun i j => (rawNoise i j : ZMod 17)) := by
  funext i j
  change (noise parameters layout opening i j : ZMod 17) = _
  rw [noise_eq]

private theorem harmonicPair_zero : harmonicPair parameters layout 0 = 0 := by
  funext i j
  cases i <;>
    simp [harmonicPair, receivedPair, rawPair, siteEquiv_eq, Sheaf.HCPCoupledEncoding.integerObserved]

private theorem distance_from_harmonic : BlockCode.hammingDistance (harmonicPair parameters layout 0)
    (receivedPair parameters layout 0 opening) = 3 := by
  rw [harmonicPair_zero, receivedPair_eq]
  decide

private theorem sparse : SparseNoise parameters layout 0 opening 2 where
  visible := by
    rw [harmonicPair_zero, receivedPair_eq, noise_eq]
    decide
  small := by rw [distance_from_harmonic]; decide
  bounded := by
    intro i
    rcases i with c | r
    · norm_num [siteEnergy, noise_eq, rawNoise]
    · fin_cases r <;> norm_num [siteEnergy, noise_eq, rawNoise, opening, Fin.sum_univ_two]

/-- Whole-site distance to the actual interleaved affine Reed–Solomon code. -/
theorem pairDistance_eq : (parameters.vectorBlockCode (Fin 2)).relativeDistanceToCode
    (receivedPair parameters layout 0 opening) = 3 / 8 := by
  rw [BlockCode.relativeDistanceToCode,
    (nearest parameters layout degree_pos informationSites_card sparse).1, distance_from_harmonic]
  norm_num

/-- Sum of both squared residuals in the native coupled sheaf. -/
theorem residualSq_eq : residualSq parameters layout 0 opening = 6 := by
  rw [residualSq_eq_sum_siteEnergy, Fintype.sum_sum_type]
  norm_num [siteEnergy, noise_eq, rawNoise, opening, Fin.sum_univ_succ]

end HomotopicalEncryption.Protocol.Storage.HodgeRSCalibration.Example
