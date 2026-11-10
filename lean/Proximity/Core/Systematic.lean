module

public import Proximity.MCA.Pair
public import Mathlib.Algebra.Field.ZMod

@[expose] public section

/-!
# Systematic interpolation and integer syndrome compatibility

An actual Reed--Solomon information set supplies the generator coefficients.
Their canonical integer lifts define a real systematic code independently of
the finite-field Hamming metric. A no-wrap condition on the integer syndrome
then reflects finite-field validity into real linear validity. No source
distance inequality or exact-lift hypothesis is assumed here.
-/

set_option autoImplicit false

noncomputable section

namespace ProximityCoding.ReedSolomon.Parameters

open scoped BigOperators

section Field

variable {F ι : Type*} [Field F] [Fintype F] [DecidableEq F]
  [Fintype ι] [DecidableEq ι]

/-- The actual interpolation basis for an information coordinate. -/
def informationCoefficient (P : Parameters F ι) (S : Finset ι)
    (i : ι) (a : {a // a ∈ S}) : F :=
  P.interpolateWord S (fun j => if j = a.val then 1 else 0) i

/-- Systematic encoding by the actual RS interpolation basis. -/
def systematicEncode (P : Parameters F ι) (S : Finset ι)
    (data : {a // a ∈ S} → F) : Word ι F :=
  fun i => ∑ a, data a * P.informationCoefficient S i a

/-- The complete systematic check, including its zero information rows. -/
def systematicCheck (P : Parameters F ι) (S : Finset ι)
    (w : Word ι F) : Word ι F :=
  fun i => w i - P.systematicEncode S (fun a => w a.val) i

theorem informationCoefficient_on (P : Parameters F ι) (S : Finset ι)
    (a b : {a // a ∈ S}) :
    P.informationCoefficient S b.val a = if b = a then 1 else 0 := by
  unfold informationCoefficient
  rw [P.interpolateWord_eq_on S _ b.property]
  by_cases h : b = a
  · subst b
    simp
  · have hv : b.val ≠ a.val := fun hv => h (Subtype.ext hv)
    simp only [if_neg h, if_neg hv]

theorem systematicEncode_on (P : Parameters F ι) (S : Finset ι)
    (data : {a // a ∈ S} → F) (b : {a // a ∈ S}) :
    P.systematicEncode S data b.val = data b := by
  simp [systematicEncode, P.informationCoefficient_on]

theorem systematicEncode_codeword (P : Parameters F ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (data : {a // a ∈ S} → F) :
    P.Codeword (P.systematicEncode S data) := by
  have hP := P.fAdditive_of_degreeBound_pos hDegree
  have hsum : ∀ T : Finset {a // a ∈ S},
      P.Codeword (fun i => ∑ a ∈ T, data a * P.informationCoefficient S i a) := by
    intro T
    induction T using Finset.induction_on with
    | empty => simpa using hP.zero_mem
    | @insert a T ha ih =>
      have haCode : P.Codeword (fun i => data a * P.informationCoefficient S i a) := by
        exact hP.smul_mem (data a) (P.interpolateWord_codeword hDegree hS _)
      simpa only [Finset.sum_insert ha] using hP.add_mem haCode ih
  change P.Codeword (fun i => ∑ a, data a * P.informationCoefficient S i a)
  exact hsum Finset.univ

theorem codeword_iff_systematicEncode (P : Parameters F ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (w : Word ι F) :
    P.Codeword w ↔ w = P.systematicEncode S (fun a => w a.val) := by
  constructor
  · intro hw
    apply P.determinedBy_degreeBound hw
      (P.systematicEncode_codeword S hDegree hS _) S hS
    intro i hi
    exact (P.systematicEncode_on S (fun a => w a.val) ⟨i, hi⟩).symm
  · intro hw
    rw [hw]
    exact P.systematicEncode_codeword S hDegree hS _

theorem codeword_iff_systematicCheck_eq_zero (P : Parameters F ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (w : Word ι F) :
    P.Codeword w ↔ P.systematicCheck S w = 0 := by
  rw [P.codeword_iff_systematicEncode S hDegree hS]
  simp only [systematicCheck, funext_iff, Pi.zero_apply, sub_eq_zero]

theorem vectorCodeword_iff_systematicCheck_eq_zero
    (P : Parameters F ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    {σ : Type*} (w : Word ι (σ → F)) :
    P.VectorCodeword σ w ↔ ∀ j, P.systematicCheck S (fun i => w i j) = 0 := by
  change (∀ j, P.Codeword (fun i => w i j)) ↔ _
  exact forall_congr' fun j =>
    P.codeword_iff_systematicCheck_eq_zero S hDegree hS (fun i => w i j)

end Field

section Integer

variable {q : ℕ} [Fact q.Prime] {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Canonical integer lifts of the actual finite-field interpolation coefficients. -/
def integerCoefficient (P : Parameters (ZMod q) ι) (S : Finset ι)
    (i : ι) (a : {a // a ∈ S}) : ℤ :=
  (P.informationCoefficient S i a).val

def integerEncode (P : Parameters (ZMod q) ι) (S : Finset ι)
    (data : {a // a ∈ S} → ℤ) : ι → ℤ :=
  fun i => ∑ a, data a * P.integerCoefficient S i a

def integerCheck (P : Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → ℤ) : ι → ℤ :=
  fun i => z i - P.integerEncode S (fun a => z a.val) i

theorem intCast_integerCoefficient (P : Parameters (ZMod q) ι) (S : Finset ι)
    (i : ι) (a : {a // a ∈ S}) :
    (P.integerCoefficient S i a : ZMod q) = P.informationCoefficient S i a := by
  simp [integerCoefficient]

theorem integerCoefficient_on (P : Parameters (ZMod q) ι) (S : Finset ι)
    (a b : {a // a ∈ S}) :
    P.integerCoefficient S b.val a = if b = a then 1 else 0 := by
  unfold integerCoefficient
  rw [P.informationCoefficient_on]
  split <;>
    simp [ZMod.val_one_eq_one_mod,
      Nat.mod_eq_of_lt (Fact.out : q.Prime).one_lt]

theorem intCast_integerCheck (P : Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → ℤ) (i : ι) :
    (P.integerCheck S z i : ZMod q) =
      P.systematicCheck S (fun a => (z a : ZMod q)) i := by
  simp [integerCheck, integerEncode, systematicCheck, systematicEncode,
    P.intCast_integerCoefficient]

/-- An integer syndrome lies strictly within one modulus of zero in every row. -/
def NoWrap (P : Parameters (ZMod q) ι) (S : Finset ι) (z : ι → ℤ) : Prop :=
  ∀ i, |P.integerCheck S z i| < (q : ℤ)

theorem integerCheck_eq_zero_of_codeword_of_noWrap
    (P : Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : ι → ℤ) (hw : P.Codeword (fun i => (z i : ZMod q)))
    (hwrap : P.NoWrap S z) : P.integerCheck S z = 0 := by
  have hcheck := (P.codeword_iff_systematicCheck_eq_zero S hDegree hS _).mp hw
  funext i
  have hzero : (P.integerCheck S z i : ZMod q) = 0 := by
    rw [P.intCast_integerCheck, hcheck]
    rfl
  have hdiv : (q : ℤ) ∣ P.integerCheck S z i :=
    (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp hzero
  obtain ⟨k, hk⟩ := hdiv
  have hq : (0 : ℤ) < q := by exact_mod_cast (Fact.out : q.Prime).pos
  have hkbound : (q : ℤ) * |k| < q := by
    simpa only [hk, abs_mul, abs_of_pos hq] using hwrap i
  have hkl : |k| < 1 := by
    by_contra h
    have hm := mul_le_mul_of_nonneg_left (le_of_not_gt h) hq.le
    linarith
  have hkzero : k = 0 := by
    obtain ⟨hlo, hhi⟩ := abs_lt.mp hkl
    omega
  simpa [hkzero] using hk

/-- The real code uses the same integer-lifted interpolation coefficients. -/
def realEncode (P : Parameters (ZMod q) ι) (S : Finset ι)
    (data : {a // a ∈ S} → ℝ) : ι → ℝ :=
  fun i => ∑ a, data a * (P.integerCoefficient S i a : ℝ)

/-- Real linear syndrome, independent of finite-field distance semantics. -/
def realCheck (P : Parameters (ZMod q) ι) (S : Finset ι)
    (x : ι → ℝ) : ι → ℝ :=
  fun i => x i - P.realEncode S (fun a => x a.val) i

theorem realEncode_on (P : Parameters (ZMod q) ι) (S : Finset ι)
    (data : {a // a ∈ S} → ℝ) (b : {a // a ∈ S}) :
    P.realEncode S data b.val = data b := by
  simp [realEncode, P.integerCoefficient_on]

theorem intCast_integerCheck_real (P : Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → ℤ) (i : ι) :
    (P.integerCheck S z i : ℝ) = P.realCheck S (fun a => (z a : ℝ)) i := by
  simp [integerCheck, integerEncode, realCheck, realEncode]

/-- The systematic real check describes the range of the constructed generator. -/
theorem realCheck_eq_zero_iff (P : Parameters (ZMod q) ι) (S : Finset ι)
    (x : ι → ℝ) :
    P.realCheck S x = 0 ↔ ∃ data, P.realEncode S data = x := by
  constructor
  · intro hx
    refine ⟨fun a => x a.val, ?_⟩
    funext i
    have hi := congrFun hx i
    change x i - P.realEncode S (fun a => x a.val) i = 0 at hi
    exact (sub_eq_zero.mp hi).symm
  · rintro ⟨data, rfl⟩
    have hdata : (fun a : {a // a ∈ S} => P.realEncode S data a.val) = data := by
      funext a
      exact P.realEncode_on S data a
    funext i
    change P.realEncode S data i - P.realEncode S _ i = 0
    rw [hdata, sub_self]

theorem realCheck_eq_zero_of_codeword_of_noWrap
    (P : Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : ι → ℤ) (hw : P.Codeword (fun i => (z i : ZMod q)))
    (hwrap : P.NoWrap S z) : P.realCheck S (fun i => (z i : ℝ)) = 0 := by
  have hz := P.integerCheck_eq_zero_of_codeword_of_noWrap S hDegree hS z hw hwrap
  funext i
  rw [← P.intCast_integerCheck_real, hz]
  simp

/-- Actual vector-code validity reflects componentwise through the integer checks. -/
theorem realCheck_components_eq_zero_of_vectorCodeword_of_noWrap
    (P : Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    {σ : Type*} (z : ι → σ → ℤ)
    (hw : P.VectorCodeword σ (fun i j => (z i j : ZMod q)))
    (hwrap : ∀ j, P.NoWrap S (fun i => z i j)) :
    ∀ j, P.realCheck S (fun i => (z i j : ℝ)) = 0 := by
  intro j
  exact P.realCheck_eq_zero_of_codeword_of_noWrap S hDegree hS
    (fun i => z i j) (hw j) (hwrap j)

theorem integerCheck_single_outside (P : Parameters (ZMod q) ι) (S : Finset ι)
    (o : ι) (ho : o ∉ S) :
    P.integerCheck S (fun i => if i = o then 1 else 0) =
      (fun i => if i = o then 1 else 0) := by
  have hin : ∀ a : {a // a ∈ S}, a.val ≠ o := by
    intro a h
    exact ho (h ▸ a.property)
  funext i
  simp [integerCheck, integerEncode, hin]

/-- A unit received error outside the information set has a genuine nonzero
real syndrome and satisfies the explicit no-wrap restriction. -/
theorem single_outside_noWrap_nonzero (P : Parameters (ZMod q) ι) (S : Finset ι)
    (o : ι) (ho : o ∉ S) :
    P.NoWrap S (fun i => if i = o then 1 else 0) ∧
      P.realCheck S (fun i => if i = o then 1 else 0) ≠ 0 := by
  constructor
  · intro i
    rw [P.integerCheck_single_outside S o ho]
    by_cases h : i = o
    · simp only [h, ite_true, abs_one]
      exact_mod_cast (Fact.out : q.Prime).one_lt
    · simp only [h, ite_false, abs_zero]
      exact_mod_cast (Fact.out : q.Prime).pos
  · intro hz
    have hrow := congrFun hz o
    have hint := P.integerCheck_single_outside S o ho
    have hreal := P.intCast_integerCheck_real S (fun i => if i = o then 1 else 0) o
    rw [hint] at hreal
    have hone : P.realCheck S (fun i => if i = o then 1 else 0) o = 1 := by
      simpa using hreal.symm
    rw [hone] at hrow
    norm_num at hrow

end Integer

end ProximityCoding.ReedSolomon.Parameters
