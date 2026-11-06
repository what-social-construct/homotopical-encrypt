module

public import Proximity.Core.Distance
public import Proximity.Application.Calibration
public import Proximity.ListDecoding.Capacity
public import Proximity.MCA.Pair

@[expose] public section

/-!
# Coding distances, agreement sets and the neutral calibration interface

This module identifies the generic scalar and pair distances with the
paper's closed-nearness predicates. It proves good-challenge farness with
the non-strict conclusion required at a closed-ball endpoint, and proves
the Reed--Solomon covering bound directly by interpolation. No concrete
commitment, runtime object or cited-bound axiom is imported.
-/

namespace ProximityPrize
namespace BlockCode

section Agreement

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

omit [Fintype ι] [DecidableEq α] in
/-- Repeating one base codeword gives a codeword at every interleaving width. -/
theorem interleaved_nonempty
    (C : BlockCode ι α) (hC : ∃ c, C.Codeword c) (σ : Type*) :
    ∃ c, (C.interleaved σ).Codeword c := by
  obtain ⟨c, hc⟩ := hC
  exact ⟨fun i _ => c i, fun _ => hc⟩

/-- Agreement on `S` leaves at most the complementary coordinates mismatched. -/
theorem hammingDistance_add_card_le_length_of_agreesOn
    {w c : Word ι α} {S : Finset ι} (h : AgreesOn w c S) :
    hammingDistance c w + S.card ≤ Fintype.card ι := by
  have hsubset : S ⊆ CapacityList.agreementSet c w := by
    intro i hi
    simp only [CapacityList.agreementSet, Finset.mem_filter, Finset.mem_univ, true_and]
    exact (h i hi).symm
  have hcard := Finset.card_le_card hsubset
  have hpartition := CapacityList.agreement_card_add_hammingDistance c w
  omega

theorem closeOnLargeSet_iff_close
    (C : BlockCode ι α) (r : ℕ) (w : Word ι α) :
    C.CloseOnLargeSet r w ↔ C.Close r w := by
  constructor
  · rintro ⟨S, hlarge, c, hc, hagree⟩
    refine ⟨c, hc, ?_⟩
    have hd := hammingDistance_add_card_le_length_of_agreesOn hagree
    unfold LargeAgreementSet at hlarge
    omega
  · rintro ⟨c, hc, hd⟩
    refine ⟨CapacityList.agreementSet c w, ?_, c, hc, ?_⟩
    · have hpartition := CapacityList.agreement_card_add_hammingDistance c w
      unfold LargeAgreementSet
      omega
    · intro i hi
      exact (Finset.mem_filter.mp hi).2.symm

theorem closeOnLargeSetAt_iff_closeAt
    (C : BlockCode ι α) (hlength : 0 < Fintype.card ι)
    (δ : ℝ) (w : Word ι α) :
    C.CloseOnLargeSetAt δ w ↔ C.CloseAt δ w := by
  have hn : (0 : ℝ) < Fintype.card ι := by exact_mod_cast hlength
  constructor
  · rintro ⟨S, hlarge, c, hc, hagree⟩
    refine ⟨c, hc, ?_⟩
    have hd := hammingDistance_add_card_le_length_of_agreesOn hagree
    have hdReal : (hammingDistance c w : ℝ) + S.card ≤ Fintype.card ι := by
      exact_mod_cast hd
    have hlargeReal : (1 - δ) * Fintype.card ι ≤ S.card :=
      (le_div_iff₀ hn).mp hlarge
    unfold relativeHammingDistance
    apply (div_le_iff₀ hn).mpr
    nlinarith
  · rintro ⟨c, hc, hd⟩
    refine ⟨CapacityList.agreementSet c w, ?_, c, hc, ?_⟩
    · have hpartition := CapacityList.agreement_card_add_hammingDistance c w
      have hpartitionReal :
          ((CapacityList.agreementSet c w).card : ℝ) + hammingDistance c w =
            Fintype.card ι := by exact_mod_cast hpartition
      have hdReal : (hammingDistance c w : ℝ) ≤ δ * Fintype.card ι :=
        (div_le_iff₀ hn).mp hd
      unfold LargeAgreementSetAt coordinateFraction
      apply (le_div_iff₀ hn).mpr
      nlinarith
    · intro i hi
      exact (Finset.mem_filter.mp hi).2.symm

end Agreement

section GoodChallenge

variable {ι F : Type*} [Fintype ι] [Fintype F] [DecidableEq F] [Add F] [Mul F]

/--
At a good challenge, a nearest scalar word's actual agreement set admits a
pair-codeword. The pair distance is therefore no larger than that scalar
distance whenever the scalar is within the tested closed radius.
-/
theorem pairDistance_le_scalarDistance_of_good
    (C : BlockCode ι F) (hC : ∃ c, C.Codeword c)
    (hlength : 0 < Fintype.card ι) (δ : ℝ) (L : AffineLine ι F) (γ : F)
    (hgood : γ ∉ C.badChallengeSetAt δ L)
    (hnear : C.relativeDistanceToCode (L.point γ) ≤ δ) :
    (C.interleaved (Fin 2)).relativeDistanceToCode (pairWord L) ≤
      C.relativeDistanceToCode (L.point γ) := by
  classical
  let d := C.relativeDistanceToCode (L.point γ)
  have hclose : C.CloseAt d (L.point γ) :=
    (C.closeAt_iff_relativeDistanceToCode_le hC d (L.point γ)).mpr le_rfl
  obtain ⟨S, hlarge, hscalar⟩ :=
    (C.closeOnLargeSetAt_iff_closeAt hlength d (L.point γ)).mpr hclose
  have hlargeδ : LargeAgreementSetAt δ S :=
    (sub_le_sub_left hnear 1).trans hlarge
  have hpair : C.PairCloseOnSet L S := by
    by_contra hbad
    exact hgood ((C.mem_badChallengeSetAt δ L γ).mpr ⟨S, hlargeδ, hscalar, hbad⟩)
  have hpairClose : (C.interleaved (Fin 2)).CloseAt d (pairWord L) :=
    ((C.interleaved (Fin 2)).closeOnLargeSetAt_iff_closeAt
      hlength d (pairWord L)).mp ⟨S, hlarge, hpair⟩
  exact ((C.interleaved (Fin 2)).closeAt_iff_relativeDistanceToCode_le
    (C.interleaved_nonempty hC (Fin 2)) d (pairWord L)).mp hpairClose

/-- Pair distance at least `δ` gives scalar distance at least `δ`, not `> δ`. -/
theorem scalarDistance_ge_of_pairDistance_ge_of_good
    (C : BlockCode ι F) (hC : ∃ c, C.Codeword c)
    (hlength : 0 < Fintype.card ι) (δ : ℝ) (L : AffineLine ι F) (γ : F)
    (hgood : γ ∉ C.badChallengeSetAt δ L)
    (hfar : δ ≤ (C.interleaved (Fin 2)).relativeDistanceToCode (pairWord L)) :
    δ ≤ C.relativeDistanceToCode (L.point γ) := by
  by_contra h
  have hlt := lt_of_not_ge h
  have hpair := C.pairDistance_le_scalarDistance_of_good
    hC hlength δ L γ hgood hlt.le
  exact (not_lt_of_ge hfar) (hpair.trans_lt hlt)

/-- A covering bound at the tested radius forces exact endpoint equality. -/
theorem scalarDistance_eq_of_pairDistance_ge_of_good_of_le
    (C : BlockCode ι F) (hC : ∃ c, C.Codeword c)
    (hlength : 0 < Fintype.card ι) (δ : ℝ) (L : AffineLine ι F) (γ : F)
    (hgood : γ ∉ C.badChallengeSetAt δ L)
    (hfar : δ ≤ (C.interleaved (Fin 2)).relativeDistanceToCode (pairWord L))
    (hcover : C.relativeDistanceToCode (L.point γ) ≤ δ) :
    C.relativeDistanceToCode (L.point γ) = δ :=
  le_antisymm hcover
    (C.scalarDistance_ge_of_pairDistance_ge_of_good hC hlength δ L γ hgood hfar)

end GoodChallenge
end BlockCode

namespace ReedSolomon.Parameters

open BlockCode

variable {F ι : Type*}
variable [Field F] [Fintype F] [DecidableEq F] [Fintype ι] [DecidableEq ι]

omit [Fintype F] [DecidableEq F] [DecidableEq ι] in
/-- Positive-degree Reed--Solomon codes contain their zero word. -/
theorem code_nonempty (P : ReedSolomon.Parameters F ι) (hDegree : 0 < P.degreeBound) :
    ∃ c, P.toBlockCode.Codeword c :=
  ⟨fun _ => 0, (P.fAdditive_of_degreeBound_pos hDegree).zero_mem⟩

omit [Fintype F] in
/-- Interpolation on any `k` coordinates proves the scalar covering radius. -/
theorem close_capacity
    (P : ReedSolomon.Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (w : Word ι F) :
    P.toBlockCode.Close (Fintype.card ι - P.degreeBound) w := by
  classical
  obtain ⟨S, _hSsubset, hS⟩ := Finset.exists_subset_card_eq
    (show P.degreeBound ≤ (Finset.univ : Finset ι).card by simpa using hk)
  refine ⟨P.interpolateWord S w, P.interpolateWord_codeword hDegree hS w, ?_⟩
  have hagree : AgreesOn w (P.interpolateWord S w) S := by
    intro i hi
    exact (P.interpolateWord_eq_on S w hi).symm
  have hd := hammingDistance_add_card_le_length_of_agreesOn hagree
  omega

omit [Fintype F] in
/-- The same interpolation set covers every interleaving width. -/
theorem vector_close_capacity
    (P : ReedSolomon.Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (σ : Type*) [Fintype σ] [DecidableEq σ] (w : Word ι (σ → F)) :
    (P.vectorBlockCode σ).Close (Fintype.card ι - P.degreeBound) w := by
  classical
  obtain ⟨S, _hSsubset, hS⟩ := Finset.exists_subset_card_eq
    (show P.degreeBound ≤ (Finset.univ : Finset ι).card by simpa using hk)
  let c : Word ι (σ → F) := fun i j => P.interpolateWord S (fun a => w a j) i
  have hc : (P.vectorBlockCode σ).Codeword c :=
    fun j => P.interpolateWord_codeword hDegree hS (fun a => w a j)
  refine ⟨c, hc, ?_⟩
  have hagree : AgreesOn w c S := by
    intro i hi
    funext j
    exact (P.interpolateWord_eq_on S (fun a => w a j) hi).symm
  have hd := hammingDistance_add_card_le_length_of_agreesOn hagree
  omega

omit [Fintype F] in
theorem relativeDistanceToCode_le_capacity
    (P : ReedSolomon.Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (w : Word ι F) :
    P.toBlockCode.relativeDistanceToCode w ≤
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  exact (P.toBlockCode.closeAt_iff_relativeDistanceToCode_le
    (P.code_nonempty hDegree) _ w).mp
      (P.toBlockCode.closeAt_of_close (P.close_capacity hDegree hk w))

omit [Fintype F] in
theorem vector_relativeDistanceToCode_le_capacity
    (P : ReedSolomon.Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι)
    (σ : Type*) [Fintype σ] [DecidableEq σ] (w : Word ι (σ → F)) :
    (P.vectorBlockCode σ).relativeDistanceToCode w ≤
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) := by
  exact ((P.vectorBlockCode σ).closeAt_iff_relativeDistanceToCode_le
    (P.toBlockCode.interleaved_nonempty (P.code_nonempty hDegree) σ) _ w).mp
      ((P.vectorBlockCode σ).closeAt_of_close (P.vector_close_capacity hDegree hk σ w))

/-- At the covering endpoint, a far pair has scalar distance exactly that endpoint. -/
theorem scalarDistance_eq_capacity_of_pairFar_of_good
    (P : ReedSolomon.Parameters F ι) (hDegree : 0 < P.degreeBound)
    (hk : P.degreeBound ≤ Fintype.card ι) (L : AffineLine ι F) (γ : F)
    (hgood : γ ∉ P.badChallengeSetAt
      (relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound)) L)
    (hfar : relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) ≤
      (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (pairWord L)) :
    P.toBlockCode.relativeDistanceToCode (L.point γ) =
      relativeRadius (ι := ι) (Fintype.card ι - P.degreeBound) :=
  P.toBlockCode.scalarDistance_eq_of_pairDistance_ge_of_good_of_le
    (P.code_nonempty hDegree) (hDegree.trans_le hk) _ L γ hgood hfar
    (P.relativeDistanceToCode_le_capacity hDegree hk (L.point γ))

end ReedSolomon.Parameters

namespace BlockCode

variable {ι α : Type} [Fintype ι] [DecidableEq α]

/-- The neutral interface uses the actual generic block-code distance. -/
noncomputable def toCodeDistanceModel (C : BlockCode ι α) : Application.CodeDistanceModel where
  Word := Word ι α
  Codeword := C.Codeword
  distanceToCode := C.relativeDistanceToCode

/-- The same code locus and minimum distance as a source validity model. -/
noncomputable def toSourceValidityModel
    (C : BlockCode ι α) : Application.SourceValidityModel where
  Observation := Word ι α
  Valid := C.Codeword
  distanceToValid := C.relativeDistanceToCode
  distance_nonneg := C.relativeDistanceToCode_nonneg
  valid_zero_distance _ := C.relativeDistanceToCode_eq_zero_of_codeword

/-- Identity calibration identifies the neutral interface with the coding object. -/
noncomputable def distanceCalibration
    (C : BlockCode ι α) :
    Application.SourceToCodeCalibration C.toSourceValidityModel C.toCodeDistanceModel where
  extract := id
  mapsValid _ h := h
  noncollapse _ := le_rfl

end BlockCode
end ProximityPrize
