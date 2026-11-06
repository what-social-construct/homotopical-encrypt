module

public import Proximity.Core.DeepHole
public import Proximity.MCA.ZeroDirection

@[expose] public section

/-!
# The factor two between native metrics is sharp for the actual RS code

A degree-`k` deep hole in the first column and the zero codeword in the
second has whole-pair distance `(n-k)/n`, while its native scalar-coordinate
distance is half that value. The near-direction factor two is therefore
necessary even in the actual Reed--Solomon family.
-/

set_option autoImplicit false

noncomputable section

namespace ProximityPrize

open BlockCode

section GenericMinimum

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

/-- Scalar-coordinate edits minimize independently in the two code columns. -/
private theorem flat_minimum_eq_column_sum (C : BlockCode ι α)
    (hC : ∃ c, C.Codeword c) (w : Word ι (Fin 2 → α)) :
    C.flattenedPairCode.hammingDistanceToCode (flattenPair w) =
      C.hammingDistanceToCode (fun i => w i 0) +
        C.hammingDistanceToCode (fun i => w i 1) := by
  classical
  apply le_antisymm
  · let c : Fin 2 → Word ι α := fun j =>
      (C.exists_nearest_codeword hC (fun i => w i j)).choose
    have hc (j : Fin 2) : C.Codeword (c j) :=
      (C.exists_nearest_codeword hC (fun i => w i j)).choose_spec.1
    have hd (j : Fin 2) : C.hammingDistanceToCode (fun i => w i j) =
        hammingDistance (c j) (fun i => w i j) :=
      (C.exists_nearest_codeword hC (fun i => w i j)).choose_spec.2
    have hcode : C.flattenedPairCode.Codeword (flattenPair (fun i j => c j i)) := hc
    have hbound := C.flattenedPairCode.hammingDistanceToCode_le_of_codeword hcode
      (w := flattenPair w)
    rw [flat_hamming_eq_column_sum] at hbound
    change C.flattenedPairCode.hammingDistanceToCode (flattenPair w) ≤
      hammingDistance (c 0) (fun i => w i 0) +
        hammingDistance (c 1) (fun i => w i 1) at hbound
    rw [← hd 0, ← hd 1] at hbound
    exact hbound
  · obtain ⟨c, hc, hd⟩ := C.flattenedPairCode.exists_nearest_codeword
      (flattenedPairCode_nonempty C hC) (flattenPair w)
    have hzero := C.hammingDistanceToCode_le_of_codeword (hc 0) (w := fun i => w i 0)
    have hone := C.hammingDistanceToCode_le_of_codeword (hc 1) (w := fun i => w i 1)
    have hsum := flat_hamming_eq_column_sum (unflattenPair c) w
    simp only [flattenPair_unflattenPair] at hsum
    change hammingDistance c (flattenPair w) =
      hammingDistance (fun i => c (i, 0)) (fun i => w i 0) +
        hammingDistance (fun i => c (i, 1)) (fun i => w i 1) at hsum
    rw [hd, hsum]
    exact Nat.add_le_add hzero hone

end GenericMinimum

namespace ReedSolomon.Parameters

variable {F ι : Type*} [Field F] [Fintype F] [DecidableEq F]
  [Fintype ι] [DecidableEq ι]

def zeroDirectionPowerLine (P : Parameters F ι) : AffineLine ι F where
  base := P.powerReceivedWord
  direction := 0

theorem zeroDirectionPowerLine_pairDistance_eq_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    (P.vectorBlockCode (Fin 2)).relativeDistanceToCode
        (pairWord P.zeroDirectionPowerLine) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  calc
    _ = P.toBlockCode.relativeDistanceToCode P.powerReceivedWord :=
      P.toBlockCode.relativeDistanceToCode_pairWord_of_direction_eq_zero
        (P.fAdditive_of_degreeBound_pos hDegree).zero_mem P.zeroDirectionPowerLine rfl
    _ = _ := P.powerReceivedWord_relativeDistanceToCode_eq_capacity hDegree hk

theorem zeroDirectionPowerLine_flatDistance_eq_half_capacity
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) :
    P.toBlockCode.flattenedPairCode.relativeDistanceToCode
        (flattenPair (pairWord P.zeroDirectionPowerLine)) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) / 2 := by
  have hzero : P.toBlockCode.Codeword (0 : Word ι F) :=
    (P.fAdditive_of_degreeBound_pos hDegree).zero_mem
  have hzero_min : P.toBlockCode.hammingDistanceToCode (0 : Word ι F) = 0 :=
    (P.toBlockCode.hammingDistanceToCode_eq_zero_iff (P.code_nonempty hDegree) 0).mpr hzero
  have hc₀ : (fun i => pairWord P.zeroDirectionPowerLine i 0) = P.powerReceivedWord := rfl
  have hc₁ : (fun i => pairWord P.zeroDirectionPowerLine i 1) = (0 : Word ι F) := rfl
  have hn : (0 : ℝ) < Fintype.card ι := by exact_mod_cast hDegree.trans_le hk
  unfold relativeDistanceToCode relativeRadius
  rw [flat_minimum_eq_column_sum P.toBlockCode (P.code_nonempty hDegree), hc₀, hc₁,
    P.powerReceivedWord_hammingDistanceToCode_eq_capacity hDegree hk, hzero_min]
  simp only [Nat.add_zero, Fintype.card_prod, Fintype.card_fin,
    Nat.cast_mul, Nat.cast_ofNat]
  field_simp [hn.ne']

/-- The real RS instance itself refutes a unit near-direction comparison. -/
theorem zeroDirectionPowerLine_not_pairDistance_le_flatDistance
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hproper : P.degreeBound < Fintype.card ι) :
    ¬ ((P.vectorBlockCode (Fin 2)).relativeDistanceToCode
        (pairWord P.zeroDirectionPowerLine) ≤
      P.toBlockCode.flattenedPairCode.relativeDistanceToCode
        (flattenPair (pairWord P.zeroDirectionPowerLine))) := by
  have hcap : (0 : ℝ) < relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
    apply div_pos
    · exact_mod_cast Nat.sub_pos_of_lt hproper
    · exact_mod_cast hDegree.trans hproper
  rw [P.zeroDirectionPowerLine_pairDistance_eq_capacity hDegree hproper.le,
    P.zeroDirectionPowerLine_flatDistance_eq_half_capacity hDegree hproper.le]
  linarith

theorem no_unit_pair_distance_bound_by_flat_distance
    (P : Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hproper : P.degreeBound < Fintype.card ι) :
    ¬ (∀ w : Word ι (Fin 2 → F),
      (P.vectorBlockCode (Fin 2)).relativeDistanceToCode w ≤
        P.toBlockCode.flattenedPairCode.relativeDistanceToCode (flattenPair w)) := by
  intro h
  exact P.zeroDirectionPowerLine_not_pairDistance_le_flatDistance hDegree hproper
    (h (pairWord P.zeroDirectionPowerLine))

end ReedSolomon.Parameters
end ProximityPrize
