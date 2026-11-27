module

public import Protocol.Storage.CoupledCiphertext
public import Proximity.Application.DistanceCalibration
public import Proximity.Core.Systematic
public import Sheaf.ObservationQuotient

@[expose] public section

/-!
# Euclidean calibration for sparse native Hodge noise

The systematic interpolation matrix supplies the actual coupled sheaf. The
received pair reads two full native cochains in site order. The exact openings
are zero, and each nonzero coexact noise block remains visible after reduction.
Inside the unique-decoding radius the original harmonic cochains supply the
nearest Reed–Solomon pair, with an explicit squared Euclidean comparison.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.HodgeRSCalibration

open ProximityCoding
open Sheaf CellularSheaf HCPCoupledFamily

variable {ι Row Col : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype Row] [DecidableEq Row] [Fintype Col] [DecidableEq Col]
  {q : ℕ} [Fact q.Prime] {S : Finset ι}

/-- The existing native information and parity edges label the RS sites. -/
structure Layout (S : Finset ι) (Row Col : Type*) where
  information : Col ≃ {i // i ∈ S}
  parity : Row ≃ {i // i ∉ S}

def Layout.siteEquiv (L : Layout S Row Col) : Col ⊕ Row ≃ ι :=
  (Equiv.sumCongr L.information L.parity).trans (Equiv.sumCompl (· ∈ S))

/-- The coupled restriction coefficients are the actual integer RS coefficients. -/
noncomputable def matrix (P : ReedSolomon.Parameters (ZMod q) ι)
    (L : Layout S Row Col) : Matrix Row Col ℤ :=
  fun r c => P.integerCoefficient S (L.parity r).val (L.information c)

/-- Read the information and parity edge at each site from both full cochains. -/
def rawPair (L : Layout S Row Col) (v : Fin 2 → Index Row Col → ℤ) :
    ι → Fin 2 → ℤ :=
  fun i j => v j ⟨some (L.siteEquiv.symm i), 0⟩

variable (P : ReedSolomon.Parameters (ZMod q) ι) (L : Layout S Row Col)

noncomputable def receivedPair (z : Fin 2 → Col → ℤ) (u : Fin 2 → Row → ℤ) :
    ι → Fin 2 → ZMod q :=
  fun i j => (rawPair L (fun c => HCPCoupledEncoding.integerObserved (matrix P L) (z c) 0 (u c)) i j : ℤ)

/-- The reduction of the original harmonic cochains, obtained with zero noise. -/
noncomputable def harmonicPair (z : Fin 2 → Col → ℤ) : ι → Fin 2 → ZMod q :=
  receivedPair P L z 0

/-- The coexact error at the original sites, before reduction. -/
noncomputable def noise (u : Fin 2 → Row → ℤ) : ι → Fin 2 → ℤ :=
  rawPair L (fun j => HCPCoupledEncoding.integerObserved (matrix P L) 0 0 (u j))

noncomputable def siteEnergy (u : Fin 2 → Row → ℤ) (i : ι) : ℝ :=
  ∑ j : Fin 2, (noise P L u i j : ℝ) ^ 2

omit [DecidableEq Row] [DecidableEq Col] in
theorem receivedPair_eq_harmonicPair_add_noise (z : Fin 2 → Col → ℤ) (u : Fin 2 → Row → ℤ)
    (i : ι) (j : Fin 2) : receivedPair P L z u i j =
      harmonicPair P L z i j + (noise P L u i j : ZMod q) := by
  unfold harmonicPair receivedPair noise rawPair
  cases L.siteEquiv.symm i <;> simp [HCPCoupledEncoding.integerObserved, sub_eq_add_neg]

/-- Sum of the two native full HCP residual norms squared. -/
noncomputable def residualSq (z : Fin 2 → Col → ℤ) (u : Fin 2 → Row → ℤ) : ℝ :=
  ∑ j : Fin 2, ‖(sheaf (matrix P L)).kernelNormalizedDegreeOneLaplacian
    (HCPCoupledEncoding.sample (matrix P L) (z j) 0 (u j)).observed‖ ^ 2

omit [DecidableEq Row] [DecidableEq Col] in
theorem harmonicPair_codeword (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : Fin 2 → Col → ℤ) : (P.vectorBlockCode (Fin 2)).Codeword (harmonicPair P L z) := by
  intro j
  let data : {i // i ∈ S} → ZMod q := fun i => (z j (L.information.symm i) : ℤ)
  have encoded : (fun i => harmonicPair P L z i j) = P.systematicEncode S data := by
    funext i
    obtain ⟨i, rfl⟩ := L.siteEquiv.surjective i
    cases i with
    | inl c =>
      simp only [harmonicPair, receivedPair, rawPair, Equiv.symm_apply_apply,
        HCPCoupledEncoding.integerObserved, Pi.zero_apply, mul_zero, Finset.sum_const_zero, sub_zero]
      change (z j c : ZMod q) = P.systematicEncode S data (L.information c).val
      simp [P.systematicEncode_on, data]
    | inr r =>
      simp only [harmonicPair, receivedPair, rawPair, Equiv.symm_apply_apply,
        HCPCoupledEncoding.integerObserved, Pi.zero_apply, add_zero, Int.cast_sum, Int.cast_mul,
        matrix, P.intCast_integerCoefficient, ReedSolomon.Parameters.systematicEncode]
      exact Fintype.sum_equiv L.information _ _ (by intro c; simp [Layout.siteEquiv, data, mul_comm])
  change P.Codeword (fun i => harmonicPair P L z i j)
  rw [encoded]
  exact P.systematicEncode_codeword S hDegree hS data

theorem residualSq_eq_sum_siteEnergy (z : Fin 2 → Col → ℤ) (u : Fin 2 → Row → ℤ) :
    residualSq P L z u = ∑ i, siteEnergy P L u i := by
  rw [residualSq]
  simp_rw [HodgeEncryptedCochain.kernelNormalizedDegreeOneLaplacian_observed]
  rw [show (∑ i, siteEnergy P L u i) = ∑ j : Fin 2, ∑ i, (noise P L u i j : ℝ) ^ 2 from
    Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  let B := matrix P L
  have hm : (HCPCoupledEncoding.message B 0).1 = 0 := by
    change graphVector B (fun c => ((0 : Col → ℤ) c : ℝ)) = 0
    apply PiLp.ext
    rintro ⟨edge, j⟩
    cases edge with
    | none => simp [graphVector]
    | some edge => cases edge <;> simp [graphVector]
  have h : (HCPCoupledEncoding.sample B 0 0 (u j)).observed =
      (HCPCoupledEncoding.sample B (z j) 0 (u j)).opening.value := by
    change (HCPCoupledEncoding.message B 0).1 +
      (HCPCoupledEncoding.integerNoise B 0 (u j)).value = _
    rw [hm, zero_add]
    rfl
  rw [← h, ← HCPCoupledEncoding.integerObserved_cast_eq_observed, EuclideanSpace.real_norm_sq_eq]
  simp only [Fintype.sum_sigma, Fin.sum_univ_one,
    Fintype.sum_option, HCPCoupledEncoding.integerObserved, Int.cast_zero, zero_pow (by decide : 2 ≠ 0),
    zero_add]
  exact Fintype.sum_equiv L.siteEquiv _ _ (by
    intro i
    simp [noise, rawPair, B, HCPCoupledEncoding.integerObserved])

/-- A sparse error is visible in the residue pair, lies within the unique
decoding radius, and has bounded Euclidean energy at every changed site. -/
structure SparseNoise (z : Fin 2 → Col → ℤ) (u : Fin 2 → Row → ℤ) (M : ℝ) : Prop where
  visible : ∀ i, harmonicPair P L z i = receivedPair P L z u i → noise P L u i = 0
  small : 2 * BlockCode.hammingDistance (harmonicPair P L z) (receivedPair P L z u) <
    Fintype.card ι - P.degreeBound + 1
  bounded : ∀ i, siteEnergy P L u i ≤ M ^ 2

/-- Visible reduced mismatches count exactly the integer noise support. -/
theorem hammingDistance_eq_card_noiseSupport
    {z : Fin 2 → Col → ℤ} {u : Fin 2 → Row → ℤ} {M : ℝ} (profile : SparseNoise P L z u M) :
    BlockCode.hammingDistance (harmonicPair P L z) (receivedPair P L z u) =
      (Finset.univ.filter fun i => noise P L u i ≠ 0).card := by
  unfold BlockCode.hammingDistance
  apply congrArg Finset.card
  apply Finset.filter_congr
  intro i _
  constructor
  · intro different hzero
    apply different
    funext j
    simp [receivedPair_eq_harmonicPair_add_noise, hzero]
  · intro nonzero heq
    exact nonzero (profile.visible i heq)

theorem nearest (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    {z : Fin 2 → Col → ℤ} {u : Fin 2 → Row → ℤ} {M : ℝ} (profile : SparseNoise P L z u M) :
    let code := P.vectorBlockCode (Fin 2)
    let w := receivedPair P L z u
    let c := harmonicPair P L z
    code.hammingDistanceToCode w = BlockCode.hammingDistance c w ∧
      ∀ ⦃other⦄, code.Codeword other → BlockCode.hammingDistance other w ≤
        BlockCode.hammingDistance c w → other = c := by
  exact (P.vectorBlockCode (Fin 2)).hammingDistanceToCode_eq_and_unique_of_twice_lt
    (P.vectorDeterminedBy_degreeBound (Fin 2)) (hS ▸ S.card_le_univ)
    (harmonicPair_codeword P L hDegree hS z) profile.small

/-- The original squared Euclidean residual is bounded by the number of
whole-pair edits times the per-site noise energy envelope. -/
theorem residualSq_le_mul_pairDistance (hDegree : 0 < P.degreeBound)
    (hS : S.card = P.degreeBound) (hn : 0 < Fintype.card ι)
    {z : Fin 2 → Col → ℤ} {u : Fin 2 → Row → ℤ} {M : ℝ} (profile : SparseNoise P L z u M) :
    residualSq P L z u ≤ M ^ 2 * (Fintype.card ι : ℝ) *
      (P.vectorBlockCode (Fin 2)).relativeDistanceToCode (receivedPair P L z u) := by
  rw [residualSq_eq_sum_siteEnergy, BlockCode.relativeDistanceToCode,
    (nearest P L hDegree hS profile).1]
  have hn' : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast Nat.ne_of_gt hn
  rw [mul_assoc, mul_div_cancel₀ _ hn']
  unfold BlockCode.hammingDistance
  rw [mul_comm, ← nsmul_eq_mul, ← Finset.sum_const, Finset.sum_filter]
  apply Finset.sum_le_sum
  intro i _
  split_ifs with hi
  · exact profile.bounded i
  · have hz := profile.visible i (not_not.mp hi)
    simp [siteEnergy, hz]

/-- The two decoded columns define the existing affine MCA experiment. -/
noncomputable def challengeLine (z : Fin 2 → Col → ℤ) (u : Fin 2 → Row → ℤ) : AffineLine ι (ZMod q) where
  base i := receivedPair P L z u i 0
  direction i := receivedPair P L z u i 1

/-- A good challenge preserves a closed scalar rejection threshold whenever
the calibrated full residual exceeds that threshold's energy budget. -/
theorem scalarFar_of_residualSq_at_goodChallenge (hDegree : 0 < P.degreeBound)
    (hS : S.card = P.degreeBound) (hn : 0 < Fintype.card ι)
    {z : Fin 2 → Col → ℤ} {u : Fin 2 → Row → ℤ} {M δ : ℝ}
    (profile : SparseNoise P L z u M) (γ : ZMod q)
    (good : γ ∉ P.toBlockCode.badChallengeSetAt δ (challengeLine P L z u))
    (far : M ^ 2 * (Fintype.card ι : ℝ) * δ < residualSq P L z u) :
    δ < P.toBlockCode.relativeDistanceToCode ((challengeLine P L z u).point γ) := by
  by_contra! near
  have hp : BlockCode.pairWord (challengeLine P L z u) = receivedPair P L z u := by
    funext i j
    fin_cases j <;> simp [challengeLine]
  have hC : ∃ c, P.toBlockCode.Codeword c :=
    ⟨_, (harmonicPair_codeword P L hDegree hS z) 0⟩
  have comparison := P.toBlockCode.pairDistance_le_scalarDistance_of_good hC hn δ
    (challengeLine P L z u) γ good near
  rw [hp] at comparison
  have scale_nonneg : 0 ≤ M ^ 2 * (Fintype.card ι : ℝ) := by positivity
  exact not_lt_of_ge ((residualSq_le_mul_pairDistance P L hDegree hS hn profile).trans
    (mul_le_mul_of_nonneg_left (comparison.trans near) scale_nonneg)) far

section Ciphertext

variable {rows cols : ℕ} (L : Layout S (Fin rows) (Fin cols))

/-- Extract the site pair from two full native ciphertexts with zero exact edges. -/
def decodePair (L : Layout S (Fin rows) (Fin cols)) (ciphertext : Fin 2 → CoupledCodec.Bytes) :
    Option (ι → Fin 2 → ZMod q) :=
  match CoupledCiphertext.decode rows cols (ciphertext 0),
      CoupledCiphertext.decode rows cols (ciphertext 1) with
  | some left, some right =>
    if left ⟨none, 0⟩ = 0 ∧ right ⟨none, 0⟩ = 0 then
      some (fun i j => (rawPair L (Fin.cases left (fun _ => right)) i j : ℤ))
    else none
  | _, _ => none

theorem decodePair_sampleBytes (z : Fin 2 → Fin cols → ℤ) (u : Fin 2 → Fin rows → ℤ) :
    decodePair (q := q) L (fun j => CoupledCiphertext.sampleBytes (matrix P L) (z j) 0 (u j)) =
      some (receivedPair P L z u) := by
  simp only [decodePair, CoupledCiphertext.decode_sampleBytes,
    HCPCoupledEncoding.integerObserved, eq_self, and_self, ite_true]
  apply congrArg some
  funext i j
  fin_cases j <;> rfl

end Ciphertext

end HomotopicalEncryption.Protocol.Storage.HodgeRSCalibration
