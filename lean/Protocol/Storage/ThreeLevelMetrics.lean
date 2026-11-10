module

public import Protocol.Storage.CoordinateCodec
public import Proximity.Core.InterleavedMetric
public import Sheaf.SystematicCode.Modular

@[expose] public section

/-!
# Native cochain, integer-plane and finite-field RS distances

The cochain code is defined by actual integral cellular coboundaries modulo
`q`. Its scalar-coordinate edit distance counts `2n` positions. The integer
plane counts `n` whole pairs. RS distance is measured after field reduction.
The codeword correspondence and explicit matching representative lift prove
the comparisons; none of these distances is defined to equal another one.

These are modular wire/cochain metrics. They do not replace the separately
defined Euclidean decodedDistance or identify modular validity with Accepted.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.ThreeLevel

open ProximityPrize
open HomotopicalEncryption.Sheaf.SystematicCode

variable {q : ℕ} [Fact q.Prime] {ι : Type} [Fintype ι] [DecidableEq ι]

/-- One scalar column is valid when its actual integral cellular lift is exact modulo q. -/
def integerScalarCode (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) :
    BlockCode ι ℤ where
  Codeword z := ModularExact P S (fun i j => if j = 0 then z i else 0)

def reducePair (z : Word ι (Fin 2 → ℤ)) : Word ι (Fin 2 → ZMod q) :=
  fun i j => (z i j : ZMod q)

theorem integerScalarCode_codeword_iff
    (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound) (z : Word ι ℤ) :
    (integerScalarCode P S).Codeword z ↔ P.Codeword (fun i => (z i : ZMod q)) := by
  change ModularExact P S _ ↔ _
  rw [modularExact_iff_vectorCodeword P S hDegree hS]
  constructor
  · intro h
    simpa [ReedSolomon.Parameters.toBlockCode] using h 0
  · intro h j
    fin_cases j
    · simpa [ReedSolomon.Parameters.toBlockCode] using h
    · simpa [ReedSolomon.Parameters.toBlockCode] using
        (P.fAdditive_of_degreeBound_pos hDegree).zero_mem

/-- Both scalar-column validity tests are exactly the actual modular cochain predicate. -/
theorem integerPairCode_codeword_iff_modularExact
    (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : Word ι (Fin 2 → ℤ)) :
    ((integerScalarCode P S).interleaved (Fin 2)).Codeword z ↔ ModularExact P S z := by
  rw [modularExact_iff_vectorCodeword P S hDegree hS]
  change (∀ j, (integerScalarCode P S).Codeword (fun i => z i j)) ↔ _
  exact forall_congr' fun _ => integerScalarCode_codeword_iff P S hDegree hS _

theorem integerPairCode_codeword_iff_reduced
    (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : Word ι (Fin 2 → ℤ)) :
    ((integerScalarCode P S).interleaved (Fin 2)).Codeword z ↔
      (P.vectorBlockCode (Fin 2)).Codeword (reducePair z) := by
  rw [integerPairCode_codeword_iff_modularExact P S hDegree hS]
  exact modularExact_iff_vectorCodeword P S hDegree hS z

/-- Reduction may erase pair mismatches but cannot create them. -/
theorem reduced_hamming_le (z w : Word ι (Fin 2 → ℤ)) :
    BlockCode.hammingDistance (reducePair (q := q) z) (reducePair w) ≤
      BlockCode.hammingDistance z w := by
  apply Finset.card_le_card
  intro i hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  intro heq
  exact hi (congrArg (fun p : Fin 2 → ℤ => fun j => (p j : ZMod q)) heq)

/-- Choose codeword representatives to preserve every already matching whole pair. -/
def liftMatching (received : Word ι (Fin 2 → ℤ)) (w : Word ι (Fin 2 → ZMod q)) :
    Word ι (Fin 2 → ℤ) :=
  fun i j => if w i = reducePair received i then received i j else (w i j).val

@[simp] theorem reduce_liftMatching
    (received : Word ι (Fin 2 → ℤ)) (w : Word ι (Fin 2 → ZMod q)) :
    reducePair (liftMatching received w) = w := by
  funext i j
  by_cases h : w i = reducePair received i
  · simpa only [reducePair, liftMatching, if_pos h] using (congrFun h j).symm
  · simp [reducePair, liftMatching, h]

theorem liftMatching_pair_eq_iff
    (received : Word ι (Fin 2 → ℤ)) (w : Word ι (Fin 2 → ZMod q)) (i : ι) :
    liftMatching received w i = received i ↔ w i = reducePair received i := by
  constructor
  · intro h
    have hr := congrArg (fun p : Fin 2 → ℤ => fun j => (p j : ZMod q)) h
    change reducePair (liftMatching received w) i = reducePair received i at hr
    simpa only [reduce_liftMatching] using hr
  · intro h
    funext j
    simp only [liftMatching, if_pos h]

theorem liftMatching_hamming
    (received : Word ι (Fin 2 → ℤ)) (w : Word ι (Fin 2 → ZMod q)) :
    BlockCode.hammingDistance (liftMatching received w) received =
      BlockCode.hammingDistance w (reducePair received) := by
  unfold BlockCode.hammingDistance
  congr 1
  ext i
  simp only [Finset.mem_filter, Finset.mem_univ, true_and,
    ne_eq, liftMatching_pair_eq_iff]

theorem integerScalarCode_nonempty
    (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound) :
    ∃ z, (integerScalarCode P S).Codeword z := by
  refine ⟨0, (integerScalarCode_codeword_iff P S hDegree hS _).mpr ?_⟩
  simpa using (P.fAdditive_of_degreeBound_pos hDegree).zero_mem

/-- Native integer-plane distance equals RS distance by explicit representative lifting. -/
theorem planeDistance_eq_rsDistance
    (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : Word ι (Fin 2 → ℤ)) :
    ((integerScalarCode P S).interleaved (Fin 2)).relativeDistanceToCode z =
      (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (reducePair z) := by
  have hscalar := integerScalarCode_nonempty P S hDegree hS
  have hint : ∃ w, ((integerScalarCode P S).interleaved (Fin 2)).Codeword w := by
    obtain ⟨w, hw⟩ := hscalar
    exact ⟨fun i _ => w i, fun _ => hw⟩
  have hfield : ∃ w, (P.vectorBlockCode (Fin 2)).Codeword w := by
    refine ⟨0, ?_⟩
    intro _j
    change P.Codeword (fun _ => 0)
    exact (P.fAdditive_of_degreeBound_pos hDegree).zero_mem
  apply le_antisymm
  · obtain ⟨w, hw, hd⟩ := (P.vectorBlockCode (Fin 2)).exists_nearest_codeword_relative hfield
      (reducePair z)
    have hlift := (integerPairCode_codeword_iff_reduced P S hDegree hS _).mpr
      (show (P.vectorBlockCode (Fin 2)).Codeword (reducePair (liftMatching z w)) by
        simpa only [reduce_liftMatching] using hw)
    calc
      _ ≤ BlockCode.relativeHammingDistance (liftMatching z w) z :=
        ((integerScalarCode P S).interleaved (Fin 2)).relativeDistanceToCode_le_of_codeword hlift
      _ = _ := by simpa only [BlockCode.relativeHammingDistance, liftMatching_hamming] using hd.symm
  · obtain ⟨w, hw, hd⟩ := ((integerScalarCode P S).interleaved (Fin 2)).exists_nearest_codeword_relative hint z
    calc
      _ ≤ BlockCode.relativeHammingDistance (reducePair w) (reducePair z) :=
        (P.vectorBlockCode (Fin 2)).relativeDistanceToCode_le_of_codeword
          ((integerPairCode_codeword_iff_reduced P S hDegree hS _).mp hw)
      _ ≤ BlockCode.relativeHammingDistance w z := by
        apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg _)
        exact_mod_cast reduced_hamming_le (q := q) w z
      _ = _ := hd.symm

/-- All three native levels, with their normalization and comparison directions. -/
theorem three_native_distance_comparison
    (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (hn : 0 < Fintype.card ι) (z : Word ι (Fin 2 → ℤ)) :
    (integerScalarCode P S).flattenedPairCode.relativeDistanceToCode (BlockCode.flattenPair z) ≤
        ((integerScalarCode P S).interleaved (Fin 2)).relativeDistanceToCode z ∧
    ((integerScalarCode P S).interleaved (Fin 2)).relativeDistanceToCode z =
        (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (reducePair z) ∧
    (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (reducePair z) ≤
        2 * (integerScalarCode P S).flattenedPairCode.relativeDistanceToCode
          (BlockCode.flattenPair z) := by
  have h := BlockCode.flattenedPairCode_distance_comparison (integerScalarCode P S)
    (integerScalarCode_nonempty P S hDegree hS) hn z
  have heq := planeDistance_eq_rsDistance P S hDegree hS z
  exact ⟨h.1, heq, heq ▸ h.2⟩

/-- Saturated modular validity admits representative lifts that preserve every
already matching scalar coordinate. This is a metric theorem, not its definition. -/
theorem scalar_reduction_distance_eq
    {J : Type} [Fintype J] [DecidableEq J]
    (source : BlockCode J ℤ) (target : BlockCode J (ZMod q))
    (hvalid : ∀ z, source.Codeword z ↔ target.Codeword (fun i => (z i : ZMod q)))
    (hzero : target.Codeword (0 : Word J (ZMod q))) (z : Word J ℤ) :
    source.relativeDistanceToCode z =
      target.relativeDistanceToCode (fun i => (z i : ZMod q)) := by
  have hsource : ∃ w, source.Codeword w := by
    refine ⟨0, (hvalid _).mpr ?_⟩
    simpa only [Pi.zero_apply, Int.cast_zero, Pi.zero_def] using hzero
  have htarget : ∃ w, target.Codeword w := ⟨0, hzero⟩
  apply le_antisymm
  · obtain ⟨w, hw, hd⟩ := target.exists_nearest_codeword_relative htarget
      (fun i => (z i : ZMod q))
    let v : Word J ℤ := fun i => if w i = (z i : ZMod q) then z i else (w i).val
    have hcast : (fun i => (v i : ZMod q)) = w := by
      funext i
      by_cases hi : w i = (z i : ZMod q)
      · simpa only [v, if_pos hi] using hi.symm
      · simp [v, hi]
    have hv : source.Codeword v := (hvalid v).mpr (hcast.symm ▸ hw)
    have hsame (i : J) : v i = z i ↔ w i = (z i : ZMod q) := by
      constructor
      · intro hi
        have h := congrArg (fun a : ℤ => (a : ZMod q)) hi
        simpa only [congrFun hcast i] using h
      · intro hi
        simp only [v, if_pos hi]
    have hcount : BlockCode.hammingDistance v z =
        BlockCode.hammingDistance w (fun i => (z i : ZMod q)) := by
      unfold BlockCode.hammingDistance
      congr 1
      ext i
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, ne_eq, hsame]
    calc
      source.relativeDistanceToCode z ≤ BlockCode.relativeHammingDistance v z :=
        source.relativeDistanceToCode_le_of_codeword hv
      _ = _ := by simpa only [BlockCode.relativeHammingDistance, hcount] using hd.symm
  · obtain ⟨w, hw, hd⟩ := source.exists_nearest_codeword_relative hsource z
    have hc : target.Codeword (fun i => (w i : ZMod q)) := (hvalid w).mp hw
    have hcount : BlockCode.hammingDistance (fun i => (w i : ZMod q))
        (fun i => (z i : ZMod q)) ≤ BlockCode.hammingDistance w z := by
      apply Finset.card_le_card
      intro i hi
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
      intro heq
      exact hi (congrArg (fun a : ℤ => (a : ZMod q)) heq)
    calc
      _ ≤ BlockCode.relativeHammingDistance (fun i => (w i : ZMod q))
          (fun i => (z i : ZMod q)) := target.relativeDistanceToCode_le_of_codeword hc
      _ ≤ BlockCode.relativeHammingDistance w z := by
        apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg _)
        exact_mod_cast hcount
      _ = _ := hd.symm

/-- The scalar-coordinate cochain metric also transports by representative lifting. -/
theorem flatDistance_eq_rsFlatDistance
    (P : ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : Word ι (Fin 2 → ℤ)) :
    (integerScalarCode P S).flattenedPairCode.relativeDistanceToCode (BlockCode.flattenPair z) =
      P.toBlockCode.flattenedPairCode.relativeDistanceToCode
        (BlockCode.flattenPair (reducePair z)) := by
  apply scalar_reduction_distance_eq
  · intro w
    change (∀ j, (integerScalarCode P S).Codeword (fun i => w (i, j))) ↔
      ∀ j, P.toBlockCode.Codeword (fun i => ((w (i, j) : ℤ) : ZMod q))
    apply forall_congr'
    intro j
    simpa only [ReedSolomon.Parameters.toBlockCode] using
      integerScalarCode_codeword_iff P S hDegree hS (fun i => w (i, j))
  · intro _j
    change P.Codeword (fun _ => 0)
    exact (P.fAdditive_of_degreeBound_pos hDegree).zero_mem

end HomotopicalEncryption.Protocol.Storage.ThreeLevel
