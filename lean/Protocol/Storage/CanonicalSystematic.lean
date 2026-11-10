module

public import Protocol.Storage.NoWrapCalibration
public import Sheaf.SystematicCode
public import Protocol.Storage.CanonicalRS

@[expose] public section

/-!
# The actual canonical systematic RS source profile

The parameters are the existing smooth subgroup code over `ZMod 12289`, with
length 4096 and dimension bound 1024. Its first 1024 positions form the
information set. The real systematic generator supplies an actual cellular
sheaf and its original serialized cochain payload.

A unit error outside the information set gives a well-formed original payload
with a nonzero geometric source distance, bounded coordinates and no wrapped
integer syndrome. This construction uses no literature-bound package or
authentication fixture. Snapshot/artifact authentication remains a separate
input when a storage context or public observation is supplied.

The finite-grid comparison is coarse: under its coordinate bound its
certified output radius cannot exceed the first positive Hamming shell,
`1/4096`. It does not close the capacity/Johnson-scale application problem.
The inherited canonical field/root certificates now use kernel-checked
arithmetic proofs, as recorded in the selected-dependency audit.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.CanonicalSystematic

open Sheaf CellularSheaf

abbrev Index := Fin HomotopicalEncryption.Proximity.CanonicalRS.length

/-- Exactly the existing canonical subgroup evaluation parameters. -/
def parameters := HomotopicalEncryption.Proximity.CanonicalRS.canonicalSmoothDomain.parameters

theorem degreeBound_le_length :
    HomotopicalEncryption.Proximity.CanonicalRS.degreeBound ≤ HomotopicalEncryption.Proximity.CanonicalRS.length := by
  norm_num [HomotopicalEncryption.Proximity.CanonicalRS.degreeBound, HomotopicalEncryption.Proximity.CanonicalRS.length]

/-- Embed the first 1024 information indices in the existing 4096-position domain. -/
def informationIndex (a : Fin HomotopicalEncryption.Proximity.CanonicalRS.degreeBound) : Index :=
  Fin.castLE degreeBound_le_length a

def informationSet : Finset Index := Finset.univ.image informationIndex

theorem informationSet_card : informationSet.card = parameters.degreeBound := by
  change informationSet.card = HomotopicalEncryption.Proximity.CanonicalRS.degreeBound
  unfold informationSet informationIndex
  rw [Finset.card_image_of_injective _ (Fin.castLE_injective degreeBound_le_length)]
  simp only [Finset.card_univ, Fintype.card_fin]

theorem degreeBound_pos : 0 < parameters.degreeBound := by
  change 0 < HomotopicalEncryption.Proximity.CanonicalRS.degreeBound
  norm_num [HomotopicalEncryption.Proximity.CanonicalRS.degreeBound]

theorem length_pos : 0 < Fintype.card Index := by
  simp only [Index, Fintype.card_fin]
  norm_num [HomotopicalEncryption.Proximity.CanonicalRS.length]

/-- The first parity position, strictly outside the information coordinates. -/
def outside : Index :=
  ⟨HomotopicalEncryption.Proximity.CanonicalRS.degreeBound, by
    norm_num [HomotopicalEncryption.Proximity.CanonicalRS.degreeBound, HomotopicalEncryption.Proximity.CanonicalRS.length]⟩

theorem outside_not_mem : outside ∉ informationSet := by
  rintro h
  obtain ⟨a, _ha, heq⟩ := Finset.mem_image.mp h
  have hval : a.val = HomotopicalEncryption.Proximity.CanonicalRS.degreeBound :=
    congrArg Fin.val heq
  exact (Nat.ne_of_lt a.isLt) hval

/-- The real generator is realized by the actual cellular restriction map. -/
def sheaf := Sheaf.SystematicCode.sheaf parameters informationSet

/-- Construct the layout before specializing the finite coordinate cardinality. -/
def systematicLayout {q : ℕ} [Fact q.Prime] {ι : Type}
    [Fintype ι] [DecidableEq ι]
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) :
    CoordinateLayout (Sheaf.SystematicCode.sheaf P S) ι where
  coordinate := Sheaf.SystematicCode.layout
  serialized := Fintype.equivFin _

def layout : CoordinateLayout sheaf Index := systematicLayout parameters informationSet

/-- Prove the structural model before specializing large finite dimensions. -/
theorem systematicModel {q : ℕ} [Fact q.Prime] {ι : Type}
    [Fintype ι] [DecidableEq ι]
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) :
    SystematicModel (systematicLayout P S) P S where
  exact_iff := Sheaf.SystematicCode.isExact_iff_realCheck_eq_zero P S

/-- The exactness identification is proved by the cellular construction. -/
theorem model : SystematicModel layout parameters informationSet :=
  systematicModel parameters informationSet

theorem coordinateCount : sheaf.edgeCoordinateCount = 8192 := by
  rw [layout.coordinateCount]
  norm_num [Index, HomotopicalEncryption.Proximity.CanonicalRS.length]

theorem delta1_zero : sheaf.delta1 = 0 := by
  apply LinearMap.ext
  intro b
  apply PiLp.ext
  intro coordinate
  exact Empty.elim coordinate.1

/-- With no faces, the actual Hodge kernel is the orthogonal exact complement. -/
theorem harmonicOneSubspace_eq_exactOrthogonal :
    sheaf.harmonicOneSubspace = sheaf.exactOneSubspace.orthogonal := by
  rw [CellularSheaf.harmonicOneSubspace, sheaf.ker_degreeOneLaplacian,
    delta1_zero, LinearMap.ker_zero, inf_top_eq]
  exact (LinearMap.orthogonal_range sheaf.delta0).symm

/-- This source distance is the harmonic component norm, not the full HCP residual. -/
theorem exactDistance_eq_harmonicProjection_norm (b : sheaf.C1) :
    sheaf.exactDistance b = ‖sheaf.harmonicOneProjection b‖ := by
  change ‖sheaf.exactOneSubspace.orthogonal.starProjection b‖ =
    ‖sheaf.harmonicOneSubspace.starProjection b‖
  simp only [harmonicOneSubspace_eq_exactOrthogonal]

/- Serialize every integer pair coordinate in the declared geometric order. -/
section Serialization

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
  {ι : Type} [Fintype ι]

def serializePayload (L : CoordinateLayout F ι) (z : ι → Fin 2 → ℤ) :
    Axioms.CochainCommitmentData where
  modulus := Axioms.canonicalCochainModulus
  n_edge_values := F.edgeCoordinateCount
  edge_values := List.ofFn fun i : Fin F.edgeCoordinateCount =>
    let p := L.coordinate.symm (L.serialized.symm i)
    z p.1 p.2
  topology_hash := fun _ => 0

omit [Fintype ι] in
theorem serializePayload_wellFormed (L : CoordinateLayout F ι) (z : ι → Fin 2 → ℤ)
    (hn : 0 < F.edgeCoordinateCount) : (serializePayload L z).WellFormed := by
  refine ⟨rfl, ?_, ?_⟩
  · exact List.length_ofFn.symm
  · exact hn

omit [Fintype ι] in
@[simp] theorem raw_serializePayload (L : CoordinateLayout F ι) (z : ι → Fin 2 → ℤ)
    (i : ι) (j : Fin 2) : L.raw (serializePayload L z) i j = z i j := by
  let idx := L.serialized (L.coordinate (i, j))
  change (List.ofFn fun a : Fin F.edgeCoordinateCount =>
    let p := L.coordinate.symm (L.serialized.symm a)
    z p.1 p.2).getD idx.val 0 = z i j
  rw [← List.getElem_eq_getD (h := by simp) 0]
  simp only [List.getElem_ofFn]
  change z (L.coordinate.symm (L.serialized.symm idx)).1
    (L.coordinate.symm (L.serialized.symm idx)).2 = z i j
  simp [idx]

end Serialization

def payload (z : Index → Fin 2 → ℤ) : Axioms.CochainCommitmentData :=
  serializePayload layout z

theorem payload_wellFormed (z : Index → Fin 2 → ℤ) : (payload z).WellFormed :=
  serializePayload_wellFormed layout z (by rw [coordinateCount]; norm_num)

/-- The actual original payload is read without changing or omitting a coordinate. -/
@[simp] theorem raw_payload (z : Index → Fin 2 → ℤ) (i : Index) (j : Fin 2) :
    layout.raw (payload z) i j = z i j :=
  raw_serializePayload layout z i j

theorem payload_not_exact_of_nonzero_syndrome
    {q : ℕ} [Fact q.Prime] {ι : Type} [Fintype ι] [DecidableEq ι]
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → Fin 2 → ℤ) (j : Fin 2)
    (hcheck : P.realCheck S (fun i => (z i j : ℝ)) ≠ 0) :
    ¬ (Sheaf.SystematicCode.sheaf P S).IsExactOneCochain
      ((systematicLayout P S).decode (serializePayload (systematicLayout P S) z)) := by
  intro hexact
  have hreal := (systematicModel P S).exact_iff _ |>.mp hexact
  apply hcheck
  simpa only [CoordinateLayout.decode_coordinate, raw_serializePayload] using hreal j

/-- A single integer error in component zero at the first parity position. -/
def unitWord (i : Index) (j : Fin 2) : ℤ := if i = outside ∧ j = 0 then 1 else 0

def unitPayload : Axioms.CochainCommitmentData := payload unitWord

theorem unitPayload_wellFormed : unitPayload.WellFormed := payload_wellFormed unitWord

theorem unitPayload_coordinate_bound (i : Index) (j : Fin 2) :
    |(layout.raw unitPayload i j : ℝ)| ≤ 1 := by
  rw [unitPayload, raw_payload]
  unfold unitWord
  split_ifs <;> norm_num

theorem unitPayload_noWrap (j : Fin 2) :
    parameters.NoWrap informationSet (fun i => layout.raw unitPayload i j) := by
  simp only [unitPayload, raw_payload]
  by_cases hj : j = 0
  · subst j
    simpa only [unitWord, and_true] using
      (parameters.single_outside_noWrap_nonzero informationSet outside outside_not_mem).1
  · intro i
    simp [ProximityCoding.ReedSolomon.Parameters.integerCheck,
      ProximityCoding.ReedSolomon.Parameters.integerEncode, unitWord, hj,
      Axioms.canonicalCochainModulus]

/-- Positive source distance is geometric nonexactness in the constructed sheaf. -/
theorem unitPayload_not_exact : ¬ sheaf.IsExactOneCochain (layout.decode unitPayload) := by
  apply payload_not_exact_of_nonzero_syndrome parameters informationSet unitWord (0 : Fin 2)
  have hword : (fun i => (unitWord i 0 : ℝ)) =
      (fun i => if i = outside then (1 : ℝ) else 0) := by
    funext i
    by_cases h : i = outside <;> simp [unitWord, h]
  rw [hword]
  exact (parameters.single_outside_noWrap_nonzero informationSet outside outside_not_mem).2

theorem unitPayload_sourceDistance_pos :
    0 < sheaf.exactDistance (layout.decode unitPayload) := by
  have hne : sheaf.exactDistance (layout.decode unitPayload) ≠ 0 := by
    intro hzero
    exact unitPayload_not_exact ((sheaf.exactDistance_eq_zero_iff _).mp hzero)
  exact lt_of_le_of_ne (sheaf.exactDistance_nonneg _) hne.symm

/-- The explicit bounded no-wrap source profile has a nonempty positive far region. -/
theorem exists_positive_source_payload :
    ∃ c : Axioms.CochainCommitmentData,
      c.WellFormed ∧
      (∀ i j, |(layout.raw c i j : ℝ)| ≤ 1) ∧
      (∀ j, parameters.NoWrap informationSet (fun i => layout.raw c i j)) ∧
      0 < sheaf.exactDistance (layout.decode c) :=
  ⟨unitPayload, unitPayload_wellFormed, unitPayload_coordinate_bound,
    unitPayload_noWrap, unitPayload_sourceDistance_pos⟩

/-- Actual real exactness reduces to finite-field code validity without a no-wrap premise. -/
theorem pairCodeword_of_accepted
    (C : Context sheaf)
    (hdecode : C.interpretation.decode C.cochain = layout.decode C.cochain)
    (haccepted : C.Accepted) :
    (parameters.vectorBlockCode (Fin 2)).Codeword
      (Calibration.extractedPair (K := HomotopicalEncryption.Proximity.CanonicalRS.RSField)
        layout.extraction C) := by
  change parameters.VectorCodeword (Fin 2)
    (fun i j => (layout.raw C.cochain i j : HomotopicalEncryption.Proximity.CanonicalRS.RSField))
  apply (parameters.vectorCodeword_iff_systematicCheck_eq_zero informationSet
    degreeBound_pos informationSet_card _).mpr
  have hexact : sheaf.IsExactOneCochain (layout.decode C.cochain) := by
    rw [← hdecode]
    exact haccepted.decoded_isExactOneCochain
  intro j
  funext i
  change parameters.systematicCheck informationSet
    (fun a => (layout.raw C.cochain a j : HomotopicalEncryption.Proximity.CanonicalRS.RSField)) i = 0
  have hreal := congrFun ((model.exact_iff _).mp hexact j) i
  have hcast : (parameters.integerCheck informationSet
      (fun a => layout.raw C.cochain a j) i : ℝ) = 0 := by
    rw [parameters.intCast_integerCheck_real]
    simpa only [CoordinateLayout.decode_coordinate, Pi.zero_apply] using hreal
  have hint : parameters.integerCheck informationSet
      (fun a => layout.raw C.cochain a j) i = 0 := by exact_mod_cast hcast
  rw [← parameters.intCast_integerCheck, hint]
  rfl

/-- On the explicit no-wrap profile, source validity and actual pair-code validity agree. -/
theorem accepted_iff_pairCodeword
    (C : Context sheaf)
    (hdecode : C.interpretation.decode C.cochain = layout.decode C.cochain)
    (hwrap : model.NoWrap C) :
    C.Accepted ↔ (parameters.vectorBlockCode (Fin 2)).Codeword
      (Calibration.extractedPair (K := HomotopicalEncryption.Proximity.CanonicalRS.RSField)
        layout.extraction C) :=
  ⟨pairCodeword_of_accepted C hdecode,
    model.accepted_of_pairCodeword C degreeBound_pos informationSet_card hdecode hwrap⟩

/-- A real storage context with the explicit decoder inherits the proved source bridge. -/
theorem decodedFar_implies_pairFar
    (C : Context sheaf)
    (hdecode : C.interpretation.decode C.cochain = layout.decode C.cochain)
    (hwrap : model.NoWrap C)
    {bound : ℝ} (hbound : 0 < bound)
    (hcoords : ∀ i j, |(layout.raw C.cochain i j : ℝ)| ≤ bound)
    (sourceRadius : ℝ) (hfar : sourceRadius ≤ C.decodedDistance) :
    sourceRadius / (Real.sqrt (8192 * bound ^ 2) * 4096) ≤
      (parameters.vectorBlockCode (Fin 2)).relativeDistanceToCode
        (Calibration.extractedPair (K := HomotopicalEncryption.Proximity.CanonicalRS.RSField)
          layout.extraction C) := by
  have h := model.decodedFar_implies_pairFar C degreeBound_pos informationSet_card
    length_pos hdecode hwrap hbound hcoords sourceRadius hfar
  convert h using 1;
    norm_num only [coordinateCount, Fintype.card_fin, HomotopicalEncryption.Proximity.CanonicalRS.length,
      Nat.cast_ofNat]

/-- The same nonempty raw family remains positive in any context naming that payload. -/
theorem unitPayload_context_sourceDistance_pos (C : Context sheaf)
    (hpayload : C.cochain = unitPayload)
    (hdecode : C.interpretation.decode C.cochain = layout.decode C.cochain) :
    0 < C.decodedDistance := by
  change 0 < sheaf.exactDistance (C.interpretation.decode C.cochain)
  rw [hdecode, hpayload]
  exact unitPayload_sourceDistance_pos

/-- The explicit unit-payload family satisfies the source comparison in any bound context. -/
theorem unitPayload_context_pairFar (C : Context sheaf)
    (hpayload : C.cochain = unitPayload)
    (hdecode : C.interpretation.decode C.cochain = layout.decode C.cochain) :
    C.decodedDistance / (Real.sqrt 8192 * 4096) ≤
      (parameters.vectorBlockCode (Fin 2)).relativeDistanceToCode
        (Calibration.extractedPair (K := HomotopicalEncryption.Proximity.CanonicalRS.RSField)
          layout.extraction C) := by
  have hwrap : model.NoWrap C := by
    intro j
    change parameters.NoWrap informationSet (fun i => layout.raw C.cochain i j)
    rw [hpayload]
    exact unitPayload_noWrap j
  have hcoords : ∀ i j, |(layout.raw C.cochain i j : ℝ)| ≤ 1 := by
    intro i j
    rw [hpayload]
    exact unitPayload_coordinate_bound i j
  have h := decodedFar_implies_pairFar C hdecode hwrap (by norm_num : (0 : ℝ) < 1)
    hcoords C.decodedDistance le_rfl
  simpa only [one_pow, mul_one] using h

/-- The bridge names the extracted pair of the same original public artifact.
The supplied bound package is used only to name its existing canonical pair code. -/
theorem observed_decodedFar_implies_pairFar
    (C : Context sheaf) {runtime : TCB.RuntimeBoundary}
    (O : Storage.CanonicalRS.Observation C runtime layout.extraction)
    (β : HomotopicalEncryption.Proximity.CanonicalRS.BridgeData)
    (hdecode : C.interpretation.decode C.cochain = layout.decode C.cochain)
    (hwrap : model.NoWrap C)
    {bound : ℝ} (hbound : 0 < bound)
    (hcoords : ∀ i j, |(layout.raw C.cochain i j : ℝ)| ≤ bound)
    (sourceRadius : ℝ) (hfar : sourceRadius ≤ C.decodedDistance) :
    sourceRadius / (Real.sqrt (8192 * bound ^ 2) * 4096) ≤
      HomotopicalEncryption.Proximity.CanonicalRS.BridgeData.PlanePair.pairDistance β
        (HomotopicalEncryption.Proximity.CanonicalRS.PublicCalibration.extractedPair O.publicObservation) := by
  rw [O.extractedPair_matches, Storage.CanonicalRS.pairDistance_eq_generic]
  exact decodedFar_implies_pairFar C hdecode hwrap hbound hcoords sourceRadius hfar

end HomotopicalEncryption.Protocol.Storage.CanonicalSystematic
