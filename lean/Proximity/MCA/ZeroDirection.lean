module

public import Proximity.MCA.Definitions
public import Proximity.Core.Distance

@[expose] public section

/-!
# Zero-direction pairs have no bad challenges

The challenged scalar word is the original base word at every challenge.
Any scalar agreement witness extends to a pair witness by adjoining the zero
codeword. Thus same-set MCA has no bad challenge at any count or real radius.
The pair distance is exactly the scalar distance, with whole-symbol Hamming
counts and the existing attained-minimum distance definitions.
-/

set_option autoImplicit false

noncomputable section

namespace ProximityCoding

namespace AffineLine

variable {ι F : Type*} [Semiring F]

theorem point_eq_base_of_direction_eq_zero
    (L : AffineLine ι F) (hdir : L.direction = 0) (γ : F) :
    L.point γ = L.base := by
  funext i
  simp only [point, hdir, Pi.zero_apply, mul_zero, add_zero]

end AffineLine

namespace BlockCode

variable {ι F : Type*} [Semiring F]

/-- A scalar witness extends on the very same agreement set by appending the
zero codeword. No linearity or RS hypothesis is required. -/
theorem pairCloseOnSet_of_direction_eq_zero
    (C : BlockCode ι F) (hzero : C.Codeword (0 : Word ι F))
    (L : AffineLine ι F) (hdir : L.direction = 0) (γ : F)
    (S : Finset ι) (hclose : C.CloseOnSet (L.point γ) S) :
    C.PairCloseOnSet L S := by
  rcases hclose with ⟨c, hc, hagree⟩
  refine ⟨pairWord (⟨c, 0⟩ : AffineLine ι F), ?_, ?_⟩
  · intro j
    fin_cases j
    · simpa [pairWord] using hc
    · simpa [pairWord, Pi.zero_def] using hzero
  · intro i hi
    funext j
    fin_cases j
    · have hi' := hagree i hi
      rw [L.point_eq_base_of_direction_eq_zero hdir γ] at hi'
      simpa [pairWord] using hi'
    · simp [pairWord, hdir]

/-- Zero-direction lines cannot witness a same-set MCA failure. -/
theorem not_badOnSet_of_direction_eq_zero
    (C : BlockCode ι F) (hzero : C.Codeword (0 : Word ι F))
    (L : AffineLine ι F) (hdir : L.direction = 0) (γ : F) (S : Finset ι) :
    ¬ C.BadOnSet L γ S := by
  rintro ⟨hclose, hnot⟩
  exact hnot (C.pairCloseOnSet_of_direction_eq_zero hzero L hdir γ S hclose)

section FiniteChallenges

variable [Fintype ι] [Fintype F]

theorem not_mem_badChallengeSet_of_direction_eq_zero
    (C : BlockCode ι F) (hzero : C.Codeword (0 : Word ι F))
    (L : AffineLine ι F) (hdir : L.direction = 0) (r : ℕ) (γ : F) :
    γ ∉ C.badChallengeSet r L := by
  intro hbad
  obtain ⟨S, _, hS⟩ := (C.mem_badChallengeSet r L γ).mp hbad
  exact C.not_badOnSet_of_direction_eq_zero hzero L hdir γ S hS

/-- Every public challenge, including an already fixed mix, is good for every
real radius on a zero-direction line. -/
theorem not_mem_badChallengeSetAt_of_direction_eq_zero
    (C : BlockCode ι F) (hzero : C.Codeword (0 : Word ι F))
    (L : AffineLine ι F) (hdir : L.direction = 0) (δ : ℝ) (γ : F) :
    γ ∉ C.badChallengeSetAt δ L := by
  intro hbad
  obtain ⟨S, _, hS⟩ := (C.mem_badChallengeSetAt δ L γ).mp hbad
  exact C.not_badOnSet_of_direction_eq_zero hzero L hdir γ S hS

theorem badChallengeSet_eq_empty_of_direction_eq_zero
    (C : BlockCode ι F) (hzero : C.Codeword (0 : Word ι F))
    (L : AffineLine ι F) (hdir : L.direction = 0) (r : ℕ) :
    C.badChallengeSet r L = ∅ := by
  classical
  apply Finset.eq_empty_iff_forall_notMem.mpr
  exact C.not_mem_badChallengeSet_of_direction_eq_zero hzero L hdir r

theorem badChallengeSetAt_eq_empty_of_direction_eq_zero
    (C : BlockCode ι F) (hzero : C.Codeword (0 : Word ι F))
    (L : AffineLine ι F) (hdir : L.direction = 0) (δ : ℝ) :
    C.badChallengeSetAt δ L = ∅ := by
  classical
  apply Finset.eq_empty_iff_forall_notMem.mpr
  exact C.not_mem_badChallengeSetAt_of_direction_eq_zero hzero L hdir δ

end FiniteChallenges

section Distance

variable [Fintype ι] [DecidableEq F]

omit [Semiring F] in
private theorem hammingDistance_component_zero_le
    (p : PlaneWord ι F) (L : AffineLine ι F) :
    hammingDistance (fun i => p i 0) L.base ≤ hammingDistance p (pairWord L) := by
  classical
  apply Finset.card_le_card
  intro i hi
  have hneq : p i 0 ≠ L.base i := (Finset.mem_filter.mp hi).2
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ i, ?_⟩
  intro heq
  exact hneq (by simpa only [pairWord_zero] using congrFun heq 0)

/-- Adjoining a zero coordinate preserves the whole-symbol Hamming count. -/
theorem hammingDistance_pairWord_of_directions_eq_zero
    (L M : AffineLine ι F) (hL : L.direction = 0) (hM : M.direction = 0) :
    hammingDistance (pairWord L) (pairWord M) =
      hammingDistance L.base M.base := by
  classical
  unfold hammingDistance
  congr 1
  ext i
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro hneq heq
    apply hneq
    funext j
    fin_cases j
    · simpa [pairWord] using heq
    · simp [pairWord, hL, hM]
  · intro hneq heq
    exact hneq (by simpa only [pairWord_zero] using congrFun heq 0)

/-- The nearest scalar codeword extends with a zero second component, while
projection of any pair codeword bounds the converse distance. -/
theorem hammingDistanceToCode_pairWord_of_direction_eq_zero
    (C : BlockCode ι F) (hzero : C.Codeword (0 : Word ι F))
    (L : AffineLine ι F) (hdir : L.direction = 0) :
    (C.interleaved (Fin 2)).hammingDistanceToCode (pairWord L) =
      C.hammingDistanceToCode L.base := by
  have hpairZero : (C.interleaved (Fin 2)).Codeword (0 : PlaneWord ι F) := by
    intro _j
    exact hzero
  apply le_antisymm
  · obtain ⟨c, hc, hdist⟩ := C.exists_nearest_codeword ⟨0, hzero⟩ L.base
    let M : AffineLine ι F := ⟨c, 0⟩
    have hM : (C.interleaved (Fin 2)).Codeword (pairWord M) := by
      intro j
      fin_cases j
      · simpa [pairWord, M] using hc
      · simpa [pairWord, M, Pi.zero_def] using hzero
    calc
      (C.interleaved (Fin 2)).hammingDistanceToCode (pairWord L) ≤
          hammingDistance (pairWord M) (pairWord L) :=
        (C.interleaved (Fin 2)).hammingDistanceToCode_le_of_codeword hM
      _ = hammingDistance c L.base :=
        hammingDistance_pairWord_of_directions_eq_zero M L rfl hdir
      _ = C.hammingDistanceToCode L.base := hdist.symm
  · obtain ⟨p, hp, hdist⟩ := (C.interleaved (Fin 2)).exists_nearest_codeword
      ⟨0, hpairZero⟩ (pairWord L)
    calc
      C.hammingDistanceToCode L.base ≤ hammingDistance (fun i => p i 0) L.base :=
        C.hammingDistanceToCode_le_of_codeword (hp 0)
      _ ≤ hammingDistance p (pairWord L) := hammingDistance_component_zero_le p L
      _ = (C.interleaved (Fin 2)).hammingDistanceToCode (pairWord L) := hdist.symm

theorem relativeDistanceToCode_pairWord_of_direction_eq_zero
    (C : BlockCode ι F) (hzero : C.Codeword (0 : Word ι F))
    (L : AffineLine ι F) (hdir : L.direction = 0) :
    (C.interleaved (Fin 2)).relativeDistanceToCode (pairWord L) =
      C.relativeDistanceToCode L.base := by
  unfold relativeDistanceToCode
  rw [C.hammingDistanceToCode_pairWord_of_direction_eq_zero hzero L hdir]

/-- Every challenge has the same scalar distance, exactly equal to the actual
pair distance, without a sampled-goodness hypothesis or radius restriction. -/
theorem pairDistance_eq_scalarDistance_at_every_challenge_of_direction_eq_zero
    (C : BlockCode ι F) (hzero : C.Codeword (0 : Word ι F))
    (L : AffineLine ι F) (hdir : L.direction = 0) (γ : F) :
    (C.interleaved (Fin 2)).relativeDistanceToCode (pairWord L) =
      C.relativeDistanceToCode (L.point γ) := by
  rw [L.point_eq_base_of_direction_eq_zero hdir γ]
  exact C.relativeDistanceToCode_pairWord_of_direction_eq_zero hzero L hdir

end Distance

end BlockCode
end ProximityCoding
