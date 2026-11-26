module

public import Proximity.Core.PolynomialAgreement
public import Mathlib.Algebra.Polynomial.OfFn

@[expose] public section

/-!
# The fixed-degree boundary of polynomial agreement certificates

Normalize the coefficient of the response at degree `D` to one. The
remaining response coefficients and the multiplier coefficients solve an
explicit system of linear equations on the evaluation domain.
-/

set_option autoImplicit false

namespace ProximityCoding.ReedSolomon.Parameters.PairAgreementCertificate

variable {F ι : Type*} [Field F] [Fintype ι]
variable {P : Parameters F ι} {w : VectorWord ι F (Fin 2)}

/-- Multiplying the response and both multipliers by a nonzero scalar
preserves the certificate at the same degrees. -/
noncomputable def scale (cert : P.PairAgreementCertificate w) {a : F} (nonzero : a ≠ 0) :
    P.PairAgreementCertificate w where
  multipliers := fun j => Polynomial.C a * cert.multipliers j
  degreeBudget := cert.degreeBudget
  response := Polynomial.C a * cert.response
  multiplier_degree_le j := by
    simpa only [Polynomial.natDegree_C_mul nonzero] using cert.multiplier_degree_le j
  degree_separates := by
    simpa only [Polynomial.natDegree_C_mul nonzero] using cert.degree_separates
  response_eval i := by
    simp only [Polynomial.eval_mul, Polynomial.eval_C, cert.response_eval i]
    ring

theorem scale_natDegree (cert : P.PairAgreementCertificate w) {a : F} (nonzero : a ≠ 0) :
    (cert.scale nonzero).response.natDegree = cert.response.natDegree :=
  Polynomial.natDegree_C_mul nonzero

/-- A nonzero response can be made monic by scaling the whole certificate. -/
noncomputable def normalize (cert : P.PairAgreementCertificate w) (nonzero : cert.response ≠ 0) :
    P.PairAgreementCertificate w :=
  cert.scale (inv_ne_zero (Polynomial.leadingCoeff_ne_zero.mpr nonzero))

theorem normalize_monic (cert : P.PairAgreementCertificate w) (nonzero : cert.response ≠ 0) :
    (cert.normalize nonzero).response.Monic :=
  Polynomial.monic_C_mul_of_mul_leadingCoeff_eq_one
    (inv_mul_cancel₀ (Polynomial.leadingCoeff_ne_zero.mpr nonzero))

/-- Coefficients of the multipliers and the response below its monic term. -/
abbrev Coefficients (F : Type*) (t D : ℕ) :=
  (Fin 2 → Fin (t + 1) → F) × (Fin D → F)

/-- Each row subtracts the lower response terms from the weighted received
symbols. Its right-hand side is the monic term at that site. -/
def coefficientSystem (P : Parameters F ι) (w : VectorWord ι F (Fin 2)) (t D : ℕ) :
    Coefficients F t D →ₗ[F] (ι → F) where
  toFun x i :=
    (∑ s : Fin (t + 1), x.1 0 s * P.domain.point i ^ s.val) * w i 0 +
      (∑ s : Fin (t + 1), x.1 1 s * P.domain.point i ^ s.val) * w i 1 -
        ∑ s : Fin D, x.2 s * P.domain.point i ^ s.val
  map_add' x y := by
    ext i
    simp only [Prod.fst_add, Prod.snd_add, Pi.add_apply, add_mul, Finset.sum_add_distrib]
    ring
  map_smul' a x := by
    ext i
    change (∑ s : Fin (t + 1), (a * x.1 0 s) * P.domain.point i ^ s.val) * w i 0 +
        (∑ s : Fin (t + 1), (a * x.1 1 s) * P.domain.point i ^ s.val) * w i 1 -
          (∑ s : Fin D, (a * x.2 s) * P.domain.point i ^ s.val) = _
    simp only [RingHom.id_apply, Pi.smul_apply, smul_eq_mul, mul_assoc, ← Finset.mul_sum]
    ring

theorem coefficientSystem_apply (P : Parameters F ι) (w : VectorWord ι F (Fin 2))
    (t D : ℕ) (x : Coefficients F t D) (i : ι) :
    coefficientSystem P w t D x i =
      (∑ s : Fin (t + 1), x.1 0 s * P.domain.point i ^ s.val) * w i 0 +
        (∑ s : Fin (t + 1), x.1 1 s * P.domain.point i ^ s.val) * w i 1 -
          ∑ s : Fin D, x.2 s * P.domain.point i ^ s.val := rfl

theorem coefficientSystem_eval [DecidableEq F] (P : Parameters F ι)
    (w : VectorWord ι F (Fin 2)) (t D : ℕ) (x : Coefficients F t D) (i : ι) :
    coefficientSystem P w t D x i =
      (Polynomial.ofFn (t + 1) (x.1 0)).eval (P.domain.point i) * w i 0 +
      (Polynomial.ofFn (t + 1) (x.1 1)).eval (P.domain.point i) * w i 1 -
        (Polynomial.ofFn D x.2).eval (P.domain.point i) := by
  simp only [coefficientSystem_apply, Polynomial.ofFn_eq_sum_monomial, Polynomial.eval_finsetSum,
    Polynomial.eval_monomial]

/-- A normalized system with a solution has precisely that solution plus
the kernel as its set of solutions. -/
theorem coefficientSystem_fiber (t D : ℕ) {x y : Coefficients F t D} {b : ι → F}
    (solution : coefficientSystem P w t D x = b) :
    coefficientSystem P w t D y = b ↔
      y - x ∈ LinearMap.ker (coefficientSystem P w t D) := by
  rw [LinearMap.mem_ker, map_sub, solution, sub_eq_zero]

/-- The coefficient system decides existence for the original certificate
class at the exact budget `t` and response degree `D`. -/
theorem exists_certificate_iff_coefficientSystem [DecidableEq F] (t D : ℕ) (positive : 0 < D)
    (separates : P.degreeBound + t ≤ D) :
    (∃ cert : P.PairAgreementCertificate w,
        cert.degreeBudget = t ∧ cert.response.natDegree = D) ↔
      ∃ x : Coefficients F t D,
        coefficientSystem P w t D x = fun i => P.domain.point i ^ D := by
  constructor
  · rintro ⟨cert, budget, degree⟩
    have nonzero : cert.response ≠ 0 := by
      intro zero
      simp only [zero, Polynomial.natDegree_zero] at degree
      omega
    let normal := cert.normalize nonzero
    have monic : normal.response.Monic := cert.normalize_monic nonzero
    have normalDegree : normal.response.natDegree = D :=
      (cert.scale_natDegree (inv_ne_zero (Polynomial.leadingCoeff_ne_zero.mpr nonzero))).trans degree
    have tailDegree : (normal.response - Polynomial.X ^ D).natDegree < D := by
      by_cases zero : normal.response - Polynomial.X ^ D = 0
      · simpa only [zero, Polynomial.natDegree_zero] using positive
      apply (Polynomial.natDegree_lt_iff_degree_lt zero).mpr
      have responseDegree : normal.response.degree = (D : WithBot ℕ) :=
        (Polynomial.degree_eq_natDegree monic.ne_zero).trans (congrArg (fun q : ℕ => (q : WithBot ℕ)) normalDegree)
      have equalDegrees := responseDegree.trans (Polynomial.degree_X_pow (R := F) D).symm
      rw [← responseDegree]
      exact Polynomial.degree_sub_lt_left equalDegrees monic.ne_zero
        (monic.trans (Polynomial.monic_X_pow D).symm)
    let x : Coefficients F t D :=
      (fun j => Polynomial.toFn (t + 1) (normal.multipliers j),
        Polynomial.toFn D (normal.response - Polynomial.X ^ D))
    refine ⟨x, ?_⟩
    funext i
    have multiplier (j : Fin 2) : (normal.multipliers j).natDegree < t + 1 := by
      have bound := normal.multiplier_degree_le j
      change (normal.multipliers j).natDegree ≤ cert.degreeBudget at bound
      omega
    rw [coefficientSystem_eval]
    dsimp only [x]
    rw [Polynomial.ofFn_comp_toFn_eq_id_of_natDegree_lt (multiplier 0),
      Polynomial.ofFn_comp_toFn_eq_id_of_natDegree_lt (multiplier 1),
      Polynomial.ofFn_comp_toFn_eq_id_of_natDegree_lt tailDegree, ← normal.response_eval i,
      Polynomial.eval_sub, Polynomial.eval_pow, Polynomial.eval_X]
    ring
  · rintro ⟨x, solves⟩
    let response : Polynomial F := Polynomial.X ^ D + Polynomial.ofFn D x.2
    have responseDegree : response.natDegree = D := by
      dsimp only [response]
      have tailDegree := Polynomial.ofFn_natDegree_lt positive x.2
      rw [Polynomial.natDegree_add_eq_left_of_natDegree_lt,
        Polynomial.natDegree_X_pow]
      simpa only [Polynomial.natDegree_X_pow] using tailDegree
    let cert : P.PairAgreementCertificate w :=
      { multipliers := fun j => Polynomial.ofFn (t + 1) (x.1 j)
        degreeBudget := t
        response := response
        multiplier_degree_le := fun j => Nat.le_of_lt_succ
          (Polynomial.ofFn_natDegree_lt (Nat.zero_lt_succ t) (x.1 j))
        degree_separates := responseDegree.symm ▸ separates
        response_eval := fun i => by
          have row := congrFun solves i
          rw [coefficientSystem_eval] at row
          rw [show response = Polynomial.X ^ D + Polynomial.ofFn D x.2 from rfl,
            Polynomial.eval_add, Polynomial.eval_pow, Polynomial.eval_X, ← row]
          ring }
    exact ⟨cert, rfl, responseDegree⟩

/-- At each response degree the largest admissible budget subsumes the
smaller budgets. Multiplying the witness by a power of `X` also makes
feasible degrees upward closed. -/
theorem exists_at_larger_degree [DecidableEq F] {D E : ℕ}
    (positive : 0 < D) (degree_le : D ≤ E)
    (found : ∃ cert : P.PairAgreementCertificate w, cert.response.natDegree = D) :
    ∃ cert : P.PairAgreementCertificate w,
      cert.degreeBudget = E - P.degreeBound ∧ cert.response.natDegree = E := by
  obtain ⟨cert, degree⟩ := found
  have nonzero : cert.response ≠ 0 := by
    intro zero
    simp only [zero, Polynomial.natDegree_zero] at degree
    omega
  let offset := E - D
  have raisedDegree : (cert.response * Polynomial.X ^ offset).natDegree = E := by
    rw [Polynomial.natDegree_mul_X_pow _ nonzero, degree]
    exact Nat.add_sub_of_le degree_le
  have separates := cert.degree_separates
  have budgetBound : cert.degreeBudget + offset ≤ E - P.degreeBound := by
    dsimp only [offset]
    omega
  let raised : P.PairAgreementCertificate w :=
    { multipliers := fun j => cert.multipliers j * Polynomial.X ^ offset
      degreeBudget := E - P.degreeBound
      response := cert.response * Polynomial.X ^ offset
      multiplier_degree_le := fun j => by
        have degreeMul := Polynomial.natDegree_mul_le
          (p := cert.multipliers j) (q := Polynomial.X ^ offset)
        rw [Polynomial.natDegree_X_pow] at degreeMul
        exact degreeMul.trans
          ((Nat.add_le_add_right (cert.multiplier_degree_le j) offset).trans budgetBound)
      degree_separates := by
        rw [raisedDegree]
        omega
      response_eval := fun i => by
        simp only [Polynomial.eval_mul, Polynomial.eval_pow, Polynomial.eval_X, cert.response_eval i]
        ring }
  exact ⟨raised, rfl, raisedDegree⟩

end ProximityCoding.ReedSolomon.Parameters.PairAgreementCertificate
