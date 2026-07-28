import Proximity.CanonicalRS.MCA.Line

/-
  Concrete paper-facing MCA surface for the canonical RS endpoint.

  Paper correspondence:
  - Paper 1 Section 6: MCA bad-challenge fraction and canonical bound.
  - Paper 1 appendix ledger: Lean-proved specialization from cited bounds.

  `CanonicalRS.MCA.Line` owns the canonical affine-line construction. This file
  owns the paper Definition 4.3 bad-challenge fraction and the MCA bound at the
  canonical RS endpoint.
-/

namespace Hcrypt
namespace Proximity
namespace CanonicalRS
namespace MCA

noncomputable section

/-- The canonical RS block code named by a bridge-data endpoint. -/
def blockCode (β : BridgeData) :
    BlockCode (Fin length) RSField :=
  β.rsTarget.parameters.toBlockCode

/-- Fraction of challenges in a subset of the canonical RS field. -/
noncomputable def challengeFraction (S : Finset RSField) : ℝ :=
  BlockCode.parameterFraction S

/--
The Definition 4.3 bad-challenge set for the canonical RS endpoint.

For a canonical line represented by final words `(f₁, f₂)`, this is the set of
challenges for which there exists a large coordinate set `S` such that
`f₁ + γ · f₂` agrees with the RS code on `S`, but the same `S` does not make
`(f₁, f₂)` agree with the two-fold interleaved code `C≡2`.
-/
noncomputable def badChallengeSet
    (β : BridgeData)
    (δ : ℝ)
    (L : Line) : Finset RSField :=
  (blockCode β).paperMCABadParameterSet (F := RSField) δ L.toPaperLine

/-- Fraction of Definition 4.3 bad challenges on a canonical RS affine line. -/
noncomputable def badChallengeFraction
    (β : BridgeData)
    (δ : ℝ)
    (L : Line) : ℝ :=
  challengeFraction (badChallengeSet β δ L)

/-- Paper Definition 4.3 MCA error bound for the canonical RS endpoint. -/
def PaperMCAErrorBound
    (β : BridgeData)
    (δ ε : ℝ) : Prop :=
  β.rsTarget.parameters.PaperMutualCorrelatedAgreementErrorBound δ ε

/-- The canonical bridge data carries the paper Definition 4.3 MCA bound. -/
theorem paperMCAErrorBound
    (β : BridgeData) :
    PaperMCAErrorBound
      β
      β.johnsonRadiusReal
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) :=
  β.paperMutualCorrelatedAgreementErrorBound

/--
Concrete bad-challenge fraction bound on every canonical RS affine line.

This is exactly the paper's `εmca(C, δ) ≤ ε` statement specialized to the
canonical RS endpoint and its Johnson-below radius.
-/
theorem badChallengeFraction_le
    (β : BridgeData)
    (L : Line) :
    badChallengeFraction β β.johnsonRadiusReal L ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  change
    BlockCode.parameterFraction
        ((blockCode β).paperMCABadParameterSet
          (F := RSField) β.johnsonRadiusReal L.toPaperLine) ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ))
  exact β.paperMutualCorrelatedAgreementErrorBound L.toPaperLine

/--
Strictly sub-radius canonical metric distance is witnessed by an actual RS
codeword at strictly smaller relative Hamming distance.
-/
theorem exists_codeword_relativeHammingDistance_lt_of_metric_lt
    (β : BridgeData)
    (w : Word (Fin length) RSField)
    (δ : ℝ)
    (hmetric : β.metric.distanceToRS w < δ) :
    ∃ c : Word (Fin length) RSField,
      (blockCode β).Codeword c ∧
        BlockCode.relativeHammingDistance c w < δ := by
  change
    relativeHammingDistanceToCode canonicalSmoothDomain β.bounds w < δ
    at hmetric
  have hlength : (0 : ℝ) < (length : ℝ) := by
    norm_num [length]
  have hinf :
      hammingDistanceToCode canonicalSmoothDomain β.bounds w <
        δ * (length : ℝ) :=
    (div_lt_iff₀ hlength).mp hmetric
  rcases exists_lt_of_csInf_lt
      (codewordDistanceSet_nonempty canonicalSmoothDomain β.bounds w)
      hinf with ⟨d, hd, hdlt⟩
  rcases hd with ⟨c, hc, rfl⟩
  refine ⟨c, ?_, ?_⟩
  · exact hc
  · have hdiv := (div_lt_iff₀ hlength).2 hdlt
    unfold BlockCode.relativeHammingDistance
    unfold ProximityPrize.BlockCode.relativeHammingDistance
    rw [Fintype.card_fin]
    unfold hammingDistanceReal at hdiv
    exact hdiv

/-!
### MCA transfer for one two-coordinate plane

The plane-induced line uses the two coordinates of one plane shadow as its
base and direction.  MCA then controls precisely those challenges for which a
close scalar evaluation fails to recover closeness of the full pair on the
same large coordinate set.
-/

/-- Definition 4.3 bad challenges for the affine line carried by one plane. -/
noncomputable def planeBadChallengeSet
    (β : BridgeData)
    (δ : ℝ)
    (p : CochainPlane.PlaneShadow ℤ (Fin length)) :
    Finset RSField :=
  badChallengeSet β δ (Line.ofPlaneShadow p)

/-- Fraction of Definition 4.3 bad challenges for one plane. -/
noncomputable def planeBadChallengeFraction
    (β : BridgeData)
    (δ : ℝ)
    (p : CochainPlane.PlaneShadow ℤ (Fin length)) :
    ℝ :=
  challengeFraction (planeBadChallengeSet β δ p)

/--
Membership in the plane bad set, expressed entirely through the concrete
challenge encoding and the reduced two-coordinate pair.
-/
theorem mem_planeBadChallengeSet
    (β : BridgeData)
    (δ : ℝ)
    (p : CochainPlane.PlaneShadow ℤ (Fin length))
    (γ : RSField) :
    γ ∈ planeBadChallengeSet β δ p ↔
      ∃ S : Finset (Fin length),
        BlockCode.LargeAgreementSetAt δ S ∧
          (blockCode β).CloseOnSet
            ((β.planeEncodingAt γ).receivedWord p) S ∧
            ¬ ((blockCode β).interleaved (Fin 2)).CloseOnSet
              (reduceIntegerPlane p) S := by
  change
    γ ∈ (blockCode β).paperMCABadParameterSet
        (F := RSField) δ (Line.ofPlaneShadow p).toPaperLine ↔ _
  rw [BlockCode.mem_paperMCABadParameterSet]
  constructor
  · rintro ⟨S, hlarge, hpoint, hpair⟩
    refine ⟨S, hlarge, ?_, ?_⟩
    · change
        (blockCode β).CloseOnSet ((Line.ofPlaneShadow p).point γ) S
        at hpoint
      rw [Line.ofPlaneShadow_point] at hpoint
      exact hpoint
    · change
        ¬ ((blockCode β).interleaved (Fin 2)).CloseOnSet
          (BlockCode.pairWord
            (Line.ofPlaneShadow p).base
            (Line.ofPlaneShadow p).direction) S
        at hpair
      rw [Line.pairWord_ofPlaneShadow] at hpair
      exact hpair
  · rintro ⟨S, hlarge, hpoint, hpair⟩
    refine ⟨S, hlarge, ?_, ?_⟩
    · change
        (blockCode β).CloseOnSet ((Line.ofPlaneShadow p).point γ) S
      rw [Line.ofPlaneShadow_point]
      exact hpoint
    · change
        ¬ ((blockCode β).interleaved (Fin 2)).CloseOnSet
          (BlockCode.pairWord
            (Line.ofPlaneShadow p).base
            (Line.ofPlaneShadow p).direction) S
      rw [Line.pairWord_ofPlaneShadow]
      exact hpair

/-- Every plane-induced line satisfies the canonical paper-MCA fraction bound. -/
theorem planeBadChallengeFraction_le
    (β : BridgeData)
    (p : CochainPlane.PlaneShadow ℤ (Fin length)) :
    planeBadChallengeFraction β β.johnsonRadiusReal p ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  change
    badChallengeFraction β β.johnsonRadiusReal (Line.ofPlaneShadow p) ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ))
  exact badChallengeFraction_le β (Line.ofPlaneShadow p)

/-- Pair closeness on `S` implies closeness of every affine challenge on `S`. -/
theorem challengeCloseOnSet_of_pairCloseOnSet
    (β : BridgeData)
    (p : CochainPlane.PlaneShadow ℤ (Fin length))
    (γ : RSField)
    (S : Finset (Fin length))
    (hpair :
      ((blockCode β).interleaved (Fin 2)).CloseOnSet
        (reduceIntegerPlane p) S) :
    (blockCode β).CloseOnSet
      ((β.planeEncodingAt γ).receivedWord p) S := by
  rcases hpair with ⟨c, hc, hagree⟩
  let cγ : Word (Fin length) RSField :=
    fun i => c i 0 + γ • c i 1
  refine ⟨cγ, ?_, ?_⟩
  · exact (β.rsTarget.toFAdditiveCode).linear_combination_mem
      γ (hc 0) (hc 1)
  · intro i hi
    have h := congrArg
      (fun x : Fin 2 → RSField => x 0 + γ • x 1)
      (hagree i hi)
    simpa [cγ, BridgeData.planeEncodingAt, integerPlaneEncodingAt,
      CochainReedSolomon.PlaneEncoding.integerCanonical,
      CochainReedSolomon.PlaneEncoding.receivedWord,
      reduceIntegerPlane, smul_eq_mul] using h

/-- Outside the MCA bad set, scalar closeness recovers pair closeness on `S`. -/
theorem pairCloseOnSet_of_not_mem_planeBadChallengeSet
    (β : BridgeData)
    (δ : ℝ)
    (p : CochainPlane.PlaneShadow ℤ (Fin length))
    (γ : RSField)
    (S : Finset (Fin length))
    (hγ : γ ∉ planeBadChallengeSet β δ p)
    (hlarge : BlockCode.LargeAgreementSetAt δ S)
    (hclose :
      (blockCode β).CloseOnSet
        ((β.planeEncodingAt γ).receivedWord p) S) :
    ((blockCode β).interleaved (Fin 2)).CloseOnSet
      (reduceIntegerPlane p) S := by
  by_contra hpair
  exact hγ ((mem_planeBadChallengeSet β δ p γ).2
    ⟨S, hlarge, hclose, hpair⟩)

/--
Good-challenge non-collapse in contrapositive form: pair-far on a large set
forces the scalar challenge word to be far on that same set.
-/
theorem challengeNotCloseOnSet_of_pairNotCloseOnSet
    (β : BridgeData)
    (δ : ℝ)
    (p : CochainPlane.PlaneShadow ℤ (Fin length))
    (γ : RSField)
    (S : Finset (Fin length))
    (hγ : γ ∉ planeBadChallengeSet β δ p)
    (hlarge : BlockCode.LargeAgreementSetAt δ S)
    (hpair :
      ¬ ((blockCode β).interleaved (Fin 2)).CloseOnSet
        (reduceIntegerPlane p) S) :
    ¬ (blockCode β).CloseOnSet
      ((β.planeEncodingAt γ).receivedWord p) S := by
  intro hclose
  exact hpair
    (pairCloseOnSet_of_not_mem_planeBadChallengeSet
      β δ p γ S hγ hlarge hclose)

/--
For an MCA-good challenge, strictly sub-radius scalar distance forces strictly
sub-radius distance of the full two-coordinate pair.
-/
theorem pairDistance_lt_of_metric_lt_of_goodChallenge
    (β : BridgeData)
    (δ : ℝ)
    (p : CochainPlane.PlaneShadow ℤ (Fin length))
    (γ : RSField)
    (hγ : γ ∉ planeBadChallengeSet β δ p)
    (hmetric :
      β.metric.distanceToRS
        ((β.planeEncodingAt γ).receivedWord p) < δ) :
    BridgeData.PlanePair.pairDistance β (reduceIntegerPlane p) < δ := by
  let w : Word (Fin length) RSField :=
    (β.planeEncodingAt γ).receivedWord p
  rcases exists_codeword_relativeHammingDistance_lt_of_metric_lt
      β w δ hmetric with ⟨c, hc, hcloseDist⟩
  let S : Finset (Fin length) :=
    Finset.univ.filter fun i => w i = c i
  have hpartition :
      S.card + BlockCode.hammingDistance c w =
        Fintype.card (Fin length) := by
    unfold BlockCode.hammingDistance
    unfold ProximityPrize.BlockCode.hammingDistance
    simpa [S, ne_comm] using
      (Finset.univ.filter_card_add_filter_neg_card_eq_card
        (fun i : Fin length => w i = c i))
  have hlarge : BlockCode.LargeAgreementSetAt δ S := by
    unfold BlockCode.LargeAgreementSetAt BlockCode.coordinateFraction
    have hcardReal :
        (S.card : ℝ) + (BlockCode.hammingDistance c w : ℝ) =
          (Fintype.card (Fin length) : ℝ) := by
      exact_mod_cast hpartition
    unfold BlockCode.hammingDistance at hcardReal
    have hcardPos : (0 : ℝ) < (Fintype.card (Fin length) : ℝ) := by
      simp [length]
    have hcomplement :
        1 - BlockCode.relativeHammingDistance c w =
          (S.card : ℝ) / (Fintype.card (Fin length) : ℝ) := by
      unfold BlockCode.relativeHammingDistance
      unfold ProximityPrize.BlockCode.relativeHammingDistance
      field_simp [ne_of_gt hcardPos]
      linarith
    calc
      1 - δ ≤ 1 - BlockCode.relativeHammingDistance c w := by
        linarith
      _ = (S.card : ℝ) / (Fintype.card (Fin length) : ℝ) :=
        hcomplement
  have hagree : BlockCode.AgreesOn w c S := by
    intro i hi
    exact (Finset.mem_filter.mp hi).2
  have hscalarClose : (blockCode β).CloseOnSet w S :=
    ⟨c, hc, hagree⟩
  have hpairClose :=
    pairCloseOnSet_of_not_mem_planeBadChallengeSet
      β δ p γ S hγ hlarge hscalarClose
  rcases hpairClose with ⟨cpair, hcpair, hpairAgree⟩
  have hhamming :
      BlockCode.hammingDistance cpair (reduceIntegerPlane p) ≤
        BlockCode.hammingDistance c w := by
    unfold BlockCode.hammingDistance
    unfold ProximityPrize.BlockCode.hammingDistance
    apply Finset.card_le_card
    intro i hi
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
    intro hcw
    have hiS : i ∈ S := by
      simp [S, hcw.symm]
    exact hi (hpairAgree i hiS).symm
  have hrelative :
      BlockCode.relativeHammingDistance cpair (reduceIntegerPlane p) ≤
        BlockCode.relativeHammingDistance c w := by
    unfold BlockCode.relativeHammingDistance
    unfold ProximityPrize.BlockCode.relativeHammingDistance
    exact div_le_div_of_nonneg_right
      (by exact_mod_cast hhamming)
      (Nat.cast_nonneg _)
  exact lt_of_le_of_lt
    (BridgeData.PlanePair.relativeDistanceToCode_le_of_codeword
      (BridgeData.PlanePair.pairCode β) hcpair)
    (lt_of_le_of_lt hrelative hcloseDist)

section ProjectionChain

open GrassmannianPlucker

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
variable
    {β : BridgeData}
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {E : CochainPlane.PlaneExtractionContext ℤ (Fin length)}
    {pluckerDisagreement : FrameWitness n r → ℝ}

/-- The Definition 4.3 bad challenges for the two coordinates of one projected plane. -/
noncomputable def projectedPlaneBadChallengeSet
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (W : FrameWitness n r) :
    Finset RSField :=
  planeBadChallengeSet β β.johnsonRadiusReal (Γ.planeShadow W)

/-- MCA bounds the bad-challenge fraction of every projected two-coordinate plane. -/
theorem projectedPlaneBadChallengeFraction_le
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (W : FrameWitness n r) :
    challengeFraction (projectedPlaneBadChallengeSet Γ W) ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  exact planeBadChallengeFraction_le β (Γ.planeShadow W)

/-- The Definition 4.3 bad challenges for a projection-induced final line. -/
noncomputable def projectionBadChallengeSet
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (f₁ f₂ : FrameWitness n r) :
    Finset RSField :=
  badChallengeSet β β.johnsonRadiusReal (Line.ofProjection Γ f₁ f₂)

/--
MCA applies after the projection chain lands in final RS coordinates.

For every canonical line whose base and direction are final words produced by
the projection chain, the paper Definition 4.3 bad-challenge fraction is
bounded by the canonical MCA error threshold.
-/
theorem projectionBadChallengeFraction_le
    (Γ :
      ProjectionChain.Chain
        P S L β.rsTarget β.metric E β.planeEncoding pluckerDisagreement)
    (f₁ f₂ : FrameWitness n r) :
    challengeFraction (projectionBadChallengeSet Γ f₁ f₂) ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ)) := by
  change
    badChallengeFraction β β.johnsonRadiusReal (Line.ofProjection Γ f₁ f₂) ≤
      ((β.rsTarget.threshold : ℝ) / (Fintype.card RSField : ℝ))
  exact badChallengeFraction_le β (Line.ofProjection Γ f₁ f₂)

end ProjectionChain

end

end MCA
end CanonicalRS
end Proximity
end Hcrypt
