module

public import Protocol.Storage.CanonicalSystematic
public import Protocol.Storage.ThreeLevelMetrics
public import Proximity.Core.DeepHole
public import Proximity.MCA.Diagonal

@[expose] public section

/-!
# Three native distances for the original canonical cochain payload

The scalar-coordinate cochain metric uses actual integral coboundaries modulo
the declared prime. The integer plane edits whole two-coordinate symbols;
the RS pair distance is measured after reduction. The comparisons below use
the proved modular cellular correspondence and matching representative lifts.
They do not redefine the independent Euclidean decoded-cochain distance.

An explicit original payload lifts the two identical words `X^1024` on the
existing 4096-point subgroup. All three native distances are exactly `3/4`.
Its canonical fixed challenge is good because this particular line is
diagonal and the challenge is not `-1`. No global fixed-challenge goodness or
cryptographic security claim follows. Existing native arithmetic trust is
inherited from the canonical field/domain certificates.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Storage.CanonicalThreeLevel

open CanonicalSystematic
open ProximityPrize

/-- Native distance on all `2n` original scalar cochain positions. -/
def cochainDistance (c : Axioms.CochainCommitmentData) : ℝ :=
  (ThreeLevel.integerScalarCode parameters informationSet).flattenedPairCode.relativeDistanceToCode
    (BlockCode.flattenPair (layout.raw c))

/-- Native distance on the `n` original integer-plane pair positions. -/
def planeDistance (c : Axioms.CochainCommitmentData) : ℝ :=
  ((ThreeLevel.integerScalarCode parameters informationSet).interleaved (Fin 2)).relativeDistanceToCode
    (layout.raw c)

/-- RS pair distance after reducing the same original payload coordinates. -/
def rsPairDistance (c : Axioms.CochainCommitmentData) : ℝ :=
  (parameters.vectorBlockCode (Fin 2)).relativeDistanceToCode
    (ThreeLevel.reducePair (layout.raw c))

/-- The three independent native metrics have their proved directions and factor. -/
theorem native_distance_comparison (c : Axioms.CochainCommitmentData) :
    cochainDistance c ≤ planeDistance c ∧
      planeDistance c = rsPairDistance c ∧
      rsPairDistance c ≤ 2 * cochainDistance c :=
  ThreeLevel.three_native_distance_comparison parameters informationSet degreeBound_pos
    informationSet_card length_pos (layout.raw c)

theorem observed_planeDistance_eq_pairDistance
    (C : Context sheaf) {runtime : TCB.RuntimeBoundary}
    (O : Storage.CanonicalRS.Observation C runtime layout.extraction)
    (β : Hcrypt.Proximity.CanonicalRS.BridgeData) :
    planeDistance C.cochain =
      Hcrypt.Proximity.CanonicalRS.BridgeData.PlanePair.pairDistance β
        (Hcrypt.Proximity.CanonicalRS.PublicCalibration.extractedPair O.publicObservation) := by
  rw [O.extractedPair_matches, Storage.CanonicalRS.pairDistance_eq_generic]
  exact (native_distance_comparison C.cochain).2.1

/-- The established public source score agrees with the independently defined plane metric. -/
theorem observed_planeDistance_eq_publicSourceDistance
    (C : Context sheaf) {runtime : TCB.RuntimeBoundary}
    (O : Storage.CanonicalRS.Observation C runtime layout.extraction)
    (β : Hcrypt.Proximity.CanonicalRS.BridgeData) :
    planeDistance C.cochain =
      Hcrypt.Proximity.CanonicalRS.PublicCalibration.sourceDistanceToValid β O.publicObservation := by
  rw [O.publicSourceDistance_eq_pairDistance, Storage.CanonicalRS.pairDistance_eq_generic]
  change planeDistance C.cochain = rsPairDistance C.cochain
  exact (native_distance_comparison C.cochain).2.1

/-- Original modular cochain farness transfers to this same public artifact's pair. -/
theorem cochainFar_implies_observed_pairFar
    (C : Context sheaf) {runtime : TCB.RuntimeBoundary}
    (O : Storage.CanonicalRS.Observation C runtime layout.extraction)
    (β : Hcrypt.Proximity.CanonicalRS.BridgeData) (radius : ℝ)
    (hfar : radius ≤ cochainDistance C.cochain) :
    radius ≤ Hcrypt.Proximity.CanonicalRS.BridgeData.PlanePair.pairDistance β
      (Hcrypt.Proximity.CanonicalRS.PublicCalibration.extractedPair O.publicObservation) := by
  rw [← observed_planeDistance_eq_pairDistance C O β]
  exact hfar.trans (native_distance_comparison C.cochain).1

/-- Already accepted exact inputs have zero native proximity distance at every level. -/
theorem accepted_nativeDistances_zero
    (C : Context sheaf)
    (hdecode : C.interpretation.decode C.cochain = layout.decode C.cochain)
    (haccepted : C.Accepted) :
    cochainDistance C.cochain = 0 ∧ planeDistance C.cochain = 0 ∧
      rsPairDistance C.cochain = 0 := by
  have hword := pairCodeword_of_accepted C hdecode haccepted
  have hrs : rsPairDistance C.cochain = 0 :=
    (parameters.vectorBlockCode (Fin 2)).relativeDistanceToCode_eq_zero_of_codeword hword
  have hcomparison := native_distance_comparison C.cochain
  have hplane : planeDistance C.cochain = 0 := hcomparison.2.1.trans hrs
  have hnonneg : 0 ≤ cochainDistance C.cochain :=
    (ThreeLevel.integerScalarCode parameters informationSet).flattenedPairCode.relativeDistanceToCode_nonneg _
  have hcochain : cochainDistance C.cochain = 0 := by
    have hle := hcomparison.1
    rw [hplane] at hle
    exact le_antisymm hle hnonneg
  exact ⟨hcochain, hplane, hrs⟩

/-- Positive native-far tests apply before exact acceptance, not to accepted anchors. -/
theorem not_accepted_of_positive_cochainFar
    (C : Context sheaf)
    (hdecode : C.interpretation.decode C.cochain = layout.decode C.cochain)
    {radius : ℝ} (hpos : 0 < radius) (hfar : radius ≤ cochainDistance C.cochain) :
    ¬ C.Accepted := by
  intro haccepted
  have hzero := (accepted_nativeDistances_zero C hdecode haccepted).1
  rw [hzero] at hfar
  linarith

theorem degreeBound_le_card : parameters.degreeBound ≤ Fintype.card Index := by
  change Hcrypt.Proximity.CanonicalRS.degreeBound ≤ Fintype.card Index
  simpa only [Index, Fintype.card_fin] using degreeBound_le_length

theorem capacityRadius_eq_three_quarters :
    BlockCode.relativeRadius (ι := Index) (Fintype.card Index - parameters.degreeBound) =
      (3 : ℝ) / 4 := by
  have hn : Fintype.card Index = 4096 := by
    norm_num [Index, Hcrypt.Proximity.CanonicalRS.length]
  have hk : parameters.degreeBound = 1024 := rfl
  rw [BlockCode.relativeRadius, hn, hk]
  norm_num

/-- The actual original payload, using canonical lifts only for serialization. -/
def capacityIntegerWord (i : Index) (j : Fin 2) : ℤ :=
  (parameters.diagonalPowerPair i j).val

def capacityPayload : Axioms.CochainCommitmentData := payload capacityIntegerWord

theorem capacityPayload_wellFormed : capacityPayload.WellFormed :=
  payload_wellFormed capacityIntegerWord

@[simp] theorem capacityPayload_raw (i : Index) (j : Fin 2) :
    layout.raw capacityPayload i j = (parameters.diagonalPowerPair i j).val :=
  raw_payload capacityIntegerWord i j

@[simp] theorem reduce_capacityPayload :
    ThreeLevel.reducePair (layout.raw capacityPayload) = parameters.diagonalPowerPair := by
  funext i j
  simp only [ThreeLevel.reducePair, capacityPayload_raw, Int.cast_natCast,
    ZMod.natCast_zmod_val]

theorem capacityPayload_rsPairDistance : rsPairDistance capacityPayload = (3 : ℝ) / 4 := by
  unfold rsPairDistance
  rw [reduce_capacityPayload, ← capacityRadius_eq_three_quarters]
  have h := ProximityPrize.ReedSolomon.Parameters.diagonalPowerPair_relativeDistanceToCode_eq_capacity
    parameters degreeBound_pos degreeBound_le_card
  convert h using 1

theorem capacityPayload_planeDistance : planeDistance capacityPayload = (3 : ℝ) / 4 :=
  (native_distance_comparison capacityPayload).2.1.trans capacityPayload_rsPairDistance

theorem capacityPayload_cochainDistance : cochainDistance capacityPayload = (3 : ℝ) / 4 := by
  have hlift := ThreeLevel.flatDistance_eq_rsFlatDistance parameters informationSet
    degreeBound_pos informationSet_card (layout.raw capacityPayload)
  calc
    cochainDistance capacityPayload =
        parameters.toBlockCode.flattenedPairCode.relativeDistanceToCode
          (BlockCode.flattenPair parameters.diagonalPowerPair) := by
      simpa only [cochainDistance, reduce_capacityPayload] using hlift
    _ = (3 : ℝ) / 4 := by
      rw [← capacityRadius_eq_three_quarters]
      have h := ProximityPrize.ReedSolomon.Parameters.flat_diagonalPowerPair_relativeDistanceToCode_eq_capacity
        parameters degreeBound_pos degreeBound_le_card
      convert h using 1

/-- A nonempty original-payload family attains the native capacity radius at every level. -/
theorem exists_payload_at_capacity :
    ∃ c : Axioms.CochainCommitmentData, c.WellFormed ∧
      cochainDistance c = (3 : ℝ) / 4 ∧
      planeDistance c = (3 : ℝ) / 4 ∧ rsPairDistance c = (3 : ℝ) / 4 :=
  ⟨capacityPayload, capacityPayload_wellFormed, capacityPayload_cochainDistance,
    capacityPayload_planeDistance, capacityPayload_rsPairDistance⟩

/-- The affine line is extracted from the same two original integer coordinates. -/
def extractedLine (c : Axioms.CochainCommitmentData) :
    AffineLine Index Hcrypt.Proximity.CanonicalRS.RSField where
  base i := (layout.raw c i 0 : Hcrypt.Proximity.CanonicalRS.RSField)
  direction i := (layout.raw c i 1 : Hcrypt.Proximity.CanonicalRS.RSField)

/-- The existing integer-plane challenge encoding on the original stored payload. -/
def receivedWord (c : Axioms.CochainCommitmentData)
    (γ : Hcrypt.Proximity.CanonicalRS.RSField) :
    Word Index Hcrypt.Proximity.CanonicalRS.RSField :=
  (Hcrypt.Proximity.CanonicalRS.integerPlaneEncodingAt γ).receivedWord (layout.raw c)

theorem extractedLine_point (c : Axioms.CochainCommitmentData)
    (γ : Hcrypt.Proximity.CanonicalRS.RSField) :
    (extractedLine c).point γ = receivedWord c γ := rfl

@[simp] theorem capacityLine_base : (extractedLine capacityPayload).base =
    parameters.powerReceivedWord := by
  funext i
  simp only [extractedLine, capacityPayload_raw,
    ReedSolomon.Parameters.diagonalPowerPair, Int.cast_natCast, ZMod.natCast_zmod_val]

@[simp] theorem capacityLine_direction : (extractedLine capacityPayload).direction =
    parameters.powerReceivedWord := by
  funext i
  simp only [extractedLine, capacityPayload_raw,
    ReedSolomon.Parameters.diagonalPowerPair, Int.cast_natCast, ZMod.natCast_zmod_val]

theorem capacityLine_diagonal :
    (extractedLine capacityPayload).direction = (extractedLine capacityPayload).base := by
  rw [capacityLine_base, capacityLine_direction]

/-- The canonical order-4096 root cannot be the cancelling challenge. -/
theorem canonicalMix_ne_neg_one : Hcrypt.Proximity.CanonicalRS.canonicalMix ≠ -1 := by
  intro hneg
  have hroot : (Hcrypt.Proximity.CanonicalRS.canonicalPowerRoot.root :
      Hcrypt.Proximity.CanonicalRS.RSField) = -1 :=
    Hcrypt.Proximity.CanonicalRS.canonicalPowerRoot_root_coe.trans hneg
  have hpow : Hcrypt.Proximity.CanonicalRS.canonicalPowerRoot.root ^ 2 = 1 := by
    apply Units.ext
    change (Hcrypt.Proximity.CanonicalRS.canonicalPowerRoot.root :
      Hcrypt.Proximity.CanonicalRS.RSField) ^ 2 = 1
    rw [hroot]
    ring
  have hdiv := orderOf_dvd_of_pow_eq_one hpow
  rw [Hcrypt.Proximity.CanonicalRS.canonicalPowerRoot.order_eq_length] at hdiv
  norm_num [Hcrypt.Proximity.CanonicalRS.length] at hdiv

theorem capacityPayload_fold_distance (γ : Hcrypt.Proximity.CanonicalRS.RSField)
    (hne : γ ≠ -1) :
    parameters.toBlockCode.relativeDistanceToCode (receivedWord capacityPayload γ) =
      (3 : ℝ) / 4 := by
  rw [← extractedLine_point]
  change parameters.toBlockCode.relativeDistanceToCode
    (fun i => (extractedLine capacityPayload).base i +
      γ * (extractedLine capacityPayload).direction i) = (3 : ℝ) / 4
  rw [capacityLine_base, capacityLine_direction]
  rw [← capacityRadius_eq_three_quarters]
  have h := ProximityPrize.ReedSolomon.Parameters.diagonalPowerPair_fold_distance_eq_capacity
    parameters degreeBound_pos degreeBound_le_card γ hne
  convert h using 1

theorem capacityPayload_canonicalMix_scalarDistance :
    parameters.toBlockCode.relativeDistanceToCode
      (receivedWord capacityPayload Hcrypt.Proximity.CanonicalRS.canonicalMix) =
        (3 : ℝ) / 4 :=
  capacityPayload_fold_distance _ canonicalMix_ne_neg_one

def additiveCode : FAdditiveCode Hcrypt.Proximity.CanonicalRS.RSField Index
    Hcrypt.Proximity.CanonicalRS.RSField :=
  (parameters.fAdditive_of_degreeBound_pos degreeBound_pos).toFAdditiveCode

/-- Goodness holds for this actual diagonal payload at every noncancelling challenge. -/
theorem capacityPayload_goodChallenge (δ : ℝ)
    (γ : Hcrypt.Proximity.CanonicalRS.RSField) (hne : γ ≠ -1) :
    γ ∉ additiveCode.asBlockCode.badChallengeSetAt δ (extractedLine capacityPayload) :=
  additiveCode.not_mem_badChallengeSetAt_of_diagonal_of_ne_neg_one
    (extractedLine capacityPayload) capacityLine_diagonal δ γ hne

theorem capacityPayload_canonicalMix_good (δ : ℝ) :
    Hcrypt.Proximity.CanonicalRS.canonicalMix ∉
      additiveCode.asBlockCode.badChallengeSetAt δ (extractedLine capacityPayload) :=
  capacityPayload_goodChallenge δ _ canonicalMix_ne_neg_one

theorem capacityPower_not_codeword : ¬ parameters.Codeword parameters.powerReceivedWord := by
  intro hcode
  have hzero := parameters.toBlockCode.relativeDistanceToCode_eq_zero_of_codeword hcode
  have hcap : parameters.toBlockCode.relativeDistanceToCode parameters.powerReceivedWord =
      (3 : ℝ) / 4 := by
    rw [← capacityRadius_eq_three_quarters]
    have h := ProximityPrize.ReedSolomon.Parameters.powerReceivedWord_relativeDistanceToCode_eq_capacity
      parameters degreeBound_pos degreeBound_le_card
    convert h using 1
  linarith

theorem capacityPayload_badChallenges (δ : ℝ) (hδ : 0 ≤ δ) :
    additiveCode.asBlockCode.badChallengeSetAt δ (extractedLine capacityPayload) = {-1} := by
  apply additiveCode.badChallengeSetAt_eq_singleton_of_diagonal
    (extractedLine capacityPayload) capacityLine_diagonal _ length_pos δ hδ
  change ¬ parameters.Codeword (extractedLine capacityPayload).base
  rw [capacityLine_base]
  exact capacityPower_not_codeword

/-- The exact fraction is for this diagonal family, not a global security parameter. -/
theorem capacityPayload_badChallengeFraction (δ : ℝ) (hδ : 0 ≤ δ) :
    BlockCode.challengeFraction (additiveCode.asBlockCode.badChallengeSetAt δ
      (extractedLine capacityPayload)) = (1 : ℝ) / 12289 := by
  rw [capacityPayload_badChallenges δ hδ]
  simp only [BlockCode.challengeFraction, Finset.card_singleton, Nat.cast_one]
  have hq : Fintype.card Hcrypt.Proximity.CanonicalRS.RSField = 12289 := by
    change Fintype.card (ZMod Axioms.canonicalCochainModulus) = 12289
    rw [ZMod.card]
    rfl
  rw [hq]
  norm_num

end Hcrypt.Protocol.Storage.CanonicalThreeLevel
