module

public import Proximity.Core.InterleavedMetric
public import Proximity.Application.DistanceCalibration
public import Mathlib.Algebra.Polynomial.Roots

@[expose] public section

/-!
# Actual Reed--Solomon deep holes in the native metrics

The received word `a X^k` with nonzero `a` has distance exactly `n-k` from
degree-`<k` Reed--Solomon codewords. Repeating the same received word in both
columns attains the capacity radius in both the flattened-coordinate and
native whole-pair metrics. These witnesses use the actual evaluation domain.
-/

set_option autoImplicit false

noncomputable section

namespace ProximityCoding.ReedSolomon.Parameters

open BlockCode CapacityList

variable {F ι : Type*} [Field F] [Fintype F] [DecidableEq F]
  [Fintype ι] [DecidableEq ι]

def scaledPowerWord (P : Parameters F ι) (a : F) : Word ι F :=
  fun i => a * P.domain.point i ^ P.degreeBound

def powerReceivedWord (P : Parameters F ι) : Word ι F :=
  fun i => P.domain.point i ^ P.degreeBound

def diagonalPowerPair (P : Parameters F ι) : Word ι (Fin 2 → F) :=
  fun i _ => P.powerReceivedWord i

theorem scaledPowerWord_one (P : Parameters F ι) :
    P.scaledPowerWord 1 = P.powerReceivedWord := by
  funext i
  change (1 : F) * P.domain.point i ^ P.degreeBound = P.domain.point i ^ P.degreeBound
  exact one_mul _

theorem scaledPowerWord_agreement_card_le (P : Parameters F ι)
    (a : F) (ha : a ≠ 0) (c : Word ι F) (hc : P.Codeword c) :
    (agreementSet c (P.scaledPowerWord a)).card ≤ P.degreeBound := by
  classical
  obtain ⟨p, hp, heval⟩ := hc
  let A := agreementSet c (P.scaledPowerWord a)
  change A.card ≤ P.degreeBound
  by_contra h
  have hcard : P.degreeBound < A.card := Nat.lt_of_not_ge h
  have hinj : Function.Injective
      (fun i : {i // i ∈ A} => P.domain.point i.val) :=
    P.domain.injective_point.comp Subtype.val_injective
  have hagree : ∀ i : {i // i ∈ A},
      Polynomial.eval (P.domain.point i.val) p =
        Polynomial.eval (P.domain.point i.val)
          (Polynomial.C a * Polynomial.X ^ P.degreeBound) := by
    intro i
    have hi : c i.val = P.scaledPowerWord a i.val :=
      (Finset.mem_filter.mp i.property).2
    rw [← heval i.val]
    simpa only [scaledPowerWord, Polynomial.eval_mul,
      Polynomial.eval_C, Polynomial.eval_pow, Polynomial.eval_X] using hi
  have hdegrees : max p.natDegree
      (Polynomial.C a * Polynomial.X ^ P.degreeBound).natDegree <
        Fintype.card {i // i ∈ A} := by
    rw [Polynomial.natDegree_C_mul_X_pow _ _ ha, Fintype.card_coe]
    exact max_lt (hp.trans hcard) hcard
  have heq := Polynomial.eq_of_natDegree_lt_card_of_eval_eq p
    (Polynomial.C a * Polynomial.X ^ P.degreeBound) hinj hagree hdegrees
  have hnat := congrArg Polynomial.natDegree heq
  rw [Polynomial.natDegree_C_mul_X_pow _ _ ha] at hnat
  omega

theorem scaledPowerWord_hamming_ge_capacity (P : Parameters F ι)
    (a : F) (ha : a ≠ 0) (c : Word ι F) (hc : P.Codeword c) :
    Fintype.card ι - P.degreeBound ≤ hammingDistance c (P.scaledPowerWord a) := by
  have hcard := P.scaledPowerWord_agreement_card_le a ha c hc
  have hpartition := agreement_card_add_hammingDistance c (P.scaledPowerWord a)
  omega

theorem powerReceivedWord_hamming_ge_capacity (P : Parameters F ι)
    (c : Word ι F) (hc : P.Codeword c) :
    Fintype.card ι - P.degreeBound ≤ hammingDistance c P.powerReceivedWord := by
  rw [← P.scaledPowerWord_one]
  exact P.scaledPowerWord_hamming_ge_capacity 1 one_ne_zero c hc

theorem scaledPowerWord_hammingDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (a : F) (ha : a ≠ 0) :
    P.toBlockCode.hammingDistanceToCode (P.scaledPowerWord a) =
      Fintype.card ι - P.degreeBound := by
  apply le_antisymm
  · exact (P.toBlockCode.close_iff_hammingDistanceToCode_le
      (P.code_nonempty hDegree) _ _).mp
        (P.close_capacity hDegree hk (P.scaledPowerWord a))
  · obtain ⟨c, hc, hnearest⟩ := P.toBlockCode.exists_nearest_codeword
      (P.code_nonempty hDegree) (P.scaledPowerWord a)
    rw [hnearest]
    exact P.scaledPowerWord_hamming_ge_capacity a ha c hc

theorem scaledPowerWord_relativeDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (a : F) (ha : a ≠ 0) :
    P.toBlockCode.relativeDistanceToCode (P.scaledPowerWord a) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  unfold relativeDistanceToCode relativeRadius
  rw [P.scaledPowerWord_hammingDistanceToCode_eq_capacity hDegree hk a ha]

theorem powerReceivedWord_hammingDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    P.toBlockCode.hammingDistanceToCode P.powerReceivedWord =
      Fintype.card ι - P.degreeBound := by
  rw [← P.scaledPowerWord_one]
  exact P.scaledPowerWord_hammingDistanceToCode_eq_capacity hDegree hk 1 one_ne_zero

theorem powerReceivedWord_relativeDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    P.toBlockCode.relativeDistanceToCode P.powerReceivedWord =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  rw [← P.scaledPowerWord_one]
  exact P.scaledPowerWord_relativeDistanceToCode_eq_capacity hDegree hk 1 one_ne_zero

private theorem column_hamming_le_pair
    (u v : Word ι (Fin 2 → F)) (j : Fin 2) :
    hammingDistance (fun i => u i j) (fun i => v i j) ≤ hammingDistance u v := by
  classical
  apply Finset.card_le_card
  intro i hi
  have hne := (Finset.mem_filter.mp hi).2
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _, ?_⟩
  intro heq
  exact hne (congrFun heq j)

theorem diagonalPowerPair_hammingDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    (P.vectorBlockCode (Fin 2)).hammingDistanceToCode P.diagonalPowerPair =
      Fintype.card ι - P.degreeBound := by
  have hC := interleavedPair_nonempty P.toBlockCode (P.code_nonempty hDegree)
  apply le_antisymm
  · exact ((P.vectorBlockCode (Fin 2)).close_iff_hammingDistanceToCode_le hC _ _).mp
      (P.vector_close_capacity hDegree hk (Fin 2) P.diagonalPowerPair)
  · obtain ⟨c, hc, hnearest⟩ := (P.vectorBlockCode (Fin 2)).exists_nearest_codeword
      hC P.diagonalPowerPair
    have hscalar := P.powerReceivedWord_hamming_ge_capacity (fun i => c i 0) (hc 0)
    have hcol := column_hamming_le_pair c P.diagonalPowerPair 0
    change hammingDistance (fun i => c i 0) P.powerReceivedWord ≤ _ at hcol
    rw [hnearest]
    exact hscalar.trans hcol

theorem diagonalPowerPair_relativeDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    (P.vectorBlockCode (Fin 2)).relativeDistanceToCode P.diagonalPowerPair =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  unfold relativeDistanceToCode relativeRadius
  rw [P.diagonalPowerPair_hammingDistanceToCode_eq_capacity hDegree hk]

theorem flat_diagonalPowerPair_hammingDistanceToCode_eq_twice_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    (flattenedPairCode P.toBlockCode).hammingDistanceToCode
        (flattenPair P.diagonalPowerPair) =
      2 * (Fintype.card ι - P.degreeBound) := by
  apply le_antisymm
  · obtain ⟨c, hc, hnearest⟩ := P.toBlockCode.exists_nearest_codeword
      (P.code_nonempty hDegree) P.powerReceivedWord
    have hdist : hammingDistance c P.powerReceivedWord =
        Fintype.card ι - P.degreeBound := by
      rw [← hnearest, P.powerReceivedWord_hammingDistanceToCode_eq_capacity hDegree hk]
    have hcode : (flattenedPairCode P.toBlockCode).Codeword
        (flattenPair (fun i _ => c i)) := fun _ => hc
    calc
      _ ≤ hammingDistance (flattenPair (fun i _ => c i))
          (flattenPair P.diagonalPowerPair) :=
        (flattenedPairCode P.toBlockCode).hammingDistanceToCode_le_of_codeword hcode
      _ = 2 * (Fintype.card ι - P.degreeBound) := by
        rw [flat_hamming_eq_column_sum]
        change hammingDistance c P.powerReceivedWord +
          hammingDistance c P.powerReceivedWord = _
        rw [hdist]
        omega
  · obtain ⟨c, hc, hnearest⟩ := (flattenedPairCode P.toBlockCode).exists_nearest_codeword
      (flattenedPairCode_nonempty P.toBlockCode (P.code_nonempty hDegree))
        (flattenPair P.diagonalPowerPair)
    have hzero := P.powerReceivedWord_hamming_ge_capacity (fun i => c (i, 0)) (hc 0)
    have hone := P.powerReceivedWord_hamming_ge_capacity (fun i => c (i, 1)) (hc 1)
    have hsum := flat_hamming_eq_column_sum (unflattenPair c) P.diagonalPowerPair
    simp only [flattenPair_unflattenPair] at hsum
    change hammingDistance c (flattenPair P.diagonalPowerPair) =
      hammingDistance (fun i => c (i, 0)) P.powerReceivedWord +
        hammingDistance (fun i => c (i, 1)) P.powerReceivedWord at hsum
    rw [hnearest, hsum]
    omega

theorem flat_diagonalPowerPair_relativeDistanceToCode_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    (flattenedPairCode P.toBlockCode).relativeDistanceToCode
        (flattenPair P.diagonalPowerPair) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  have hn : (0 : ℝ) < Fintype.card ι := by
    exact_mod_cast hDegree.trans_le hk
  unfold relativeDistanceToCode relativeRadius
  rw [P.flat_diagonalPowerPair_hammingDistanceToCode_eq_twice_capacity hDegree hk]
  simp only [Fintype.card_prod, Fintype.card_fin, Nat.cast_mul, Nat.cast_ofNat]
  field_simp [hn.ne']

/-- Every noncancelling challenge retains the full scalar capacity distance. -/
theorem diagonalPowerPair_fold_distance_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (γ : F) (hγ : γ ≠ -1) :
    P.toBlockCode.relativeDistanceToCode
        (fun i => P.powerReceivedWord i + γ * P.powerReceivedWord i) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  have hcoef : 1 + γ ≠ 0 := by
    intro h
    exact hγ (add_eq_zero_iff_eq_neg.mp (by simpa only [add_comm] using h))
  have hw : (fun i => P.powerReceivedWord i + γ * P.powerReceivedWord i) =
      P.scaledPowerWord (1 + γ) := by
    funext i
    simp only [powerReceivedWord, scaledPowerWord]
    ring
  rw [hw]
  exact P.scaledPowerWord_relativeDistanceToCode_eq_capacity hDegree hk _ hcoef

end ProximityCoding.ReedSolomon.Parameters
