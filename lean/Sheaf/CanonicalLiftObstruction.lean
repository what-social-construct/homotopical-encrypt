module

public import Proximity.Core.CanonicalLift
public import Proximity.Core.Distance
public import Sheaf.Distance

@[expose] public section

/-!
# A real-linear decoder obstruction for unrestricted canonical RS payloads

For RS degree bound at least two, if a real-linear coordinate decoder sends
every canonical representative of every RS codeword to an exact cochain,
then its entire image is exact. This prevents a nonempty positive
decoded-distance family on that unrestricted profile. It does not exclude
bounded source profiles or a modular sheaf model.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Sheaf.CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}
  {q : ℕ} {ι : Type*} [Fintype ι] [Fact q.Prime]

/-- Mapping all canonical RS codeword lifts into the exact subspace makes
every input to this real-linear coordinate decoder exact. -/
theorem all_linear_decodes_exact_of_canonical_rs_lifts
    (F : CellularSheaf X)
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι)
    (hk : 2 ≤ P.degreeBound)
    (decode : (ι → ℝ) →ₗ[ℝ] F.C1)
    (hcode : ∀ word, P.Codeword word →
      F.IsExactOneCochain (decode (ProximityCoding.CanonicalLift.lift word)))
    (v : ι → ℝ) : F.IsExactOneCochain (decode v) := by
  let W : Submodule ℝ (ι → ℝ) := F.exactOneSubspace.comap decode
  have hW : W = ⊤ :=
    ProximityCoding.CanonicalLift.eq_top_of_contains_rs_lifts P hk W (by
      intro word hword
      exact hcode word hword)
  have hv : v ∈ W := by rw [hW]; trivial
  exact hv

/-- In particular, the independent decoded Euclidean exactness distance is
identically zero on this decoder's image. -/
theorem linear_decode_exactDistance_eq_zero_of_canonical_rs_lifts
    (F : CellularSheaf X)
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι)
    (hk : 2 ≤ P.degreeBound)
    (decode : (ι → ℝ) →ₗ[ℝ] F.C1)
    (hcode : ∀ word, P.Codeword word →
      F.IsExactOneCochain (decode (ProximityCoding.CanonicalLift.lift word)))
    (v : ι → ℝ) : F.exactDistance (decode v) = 0 :=
  F.exactDistance_eq_zero_of_exact
    (F.all_linear_decodes_exact_of_canonical_rs_lifts P hk decode hcode v)

/-- A surjective coordinate decoder would force the entire cochain space
to be exact, rather than provide a positive geometric far region. -/
theorem exactOneSubspace_eq_top_of_surjective_canonical_rs_decoder
    (F : CellularSheaf X)
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι)
    (hk : 2 ≤ P.degreeBound)
    (decode : (ι → ℝ) →ₗ[ℝ] F.C1) (hsurj : Function.Surjective decode)
    (hcode : ∀ word, P.Codeword word →
      F.IsExactOneCochain (decode (ProximityCoding.CanonicalLift.lift word))) :
    F.exactOneSubspace = ⊤ := by
  apply Submodule.eq_top_iff'.mpr
  intro v
  obtain ⟨u, rfl⟩ := hsurj v
  exact F.all_linear_decodes_exact_of_canonical_rs_lifts P hk decode hcode u

/-- Even one genuinely nonexact decoded vector rules out universal
codeword-to-exactness compatibility for canonical RS representatives. -/
theorem not_all_canonical_rs_lifts_exact_of_nonexact_linear_decode
    (F : CellularSheaf X)
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι)
    (hk : 2 ≤ P.degreeBound)
    (decode : (ι → ℝ) →ₗ[ℝ] F.C1)
    (v : ι → ℝ) (hv : ¬ F.IsExactOneCochain (decode v)) :
    ¬ (∀ word, P.Codeword word →
      F.IsExactOneCochain (decode (ProximityCoding.CanonicalLift.lift word))) := by
  intro hcode
  exact hv (F.all_linear_decodes_exact_of_canonical_rs_lifts P hk decode hcode v)

/-- The same conclusion for actual vector-symbol RS words, including the
two-coordinate pair extracted from a cochain commitment. -/
theorem all_linear_decodes_exact_of_canonical_interleaved_rs_lifts
    {σ : Type*} [Fintype σ]
    (F : CellularSheaf X)
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι)
    (hk : 2 ≤ P.degreeBound)
    (decode : (ι → σ → ℝ) →ₗ[ℝ] F.C1)
    (hcode : ∀ word, (P.vectorBlockCode σ).Codeword word →
      F.IsExactOneCochain (decode (ProximityCoding.CanonicalLift.interleavedLift word)))
    (v : ι → σ → ℝ) : F.IsExactOneCochain (decode v) := by
  let W : Submodule ℝ (ι → σ → ℝ) := F.exactOneSubspace.comap decode
  have hW : W = ⊤ :=
    ProximityCoding.CanonicalLift.eq_top_of_contains_interleaved_rs_lifts P hk W (by
      intro word hword
      exact hcode word hword)
  have hv : v ∈ W := by rw [hW]; trivial
  exact hv

/-- A full paired-codeword-to-exactness law leaves no positive decoded
geometric source distance anywhere in the decoder image. -/
theorem linear_decode_exactDistance_eq_zero_of_canonical_interleaved_rs_lifts
    {σ : Type*} [Fintype σ]
    (F : CellularSheaf X)
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι)
    (hk : 2 ≤ P.degreeBound)
    (decode : (ι → σ → ℝ) →ₗ[ℝ] F.C1)
    (hcode : ∀ word, (P.vectorBlockCode σ).Codeword word →
      F.IsExactOneCochain (decode (ProximityCoding.CanonicalLift.interleavedLift word)))
    (v : ι → σ → ℝ) : F.exactDistance (decode v) = 0 :=
  F.exactDistance_eq_zero_of_exact
    (F.all_linear_decodes_exact_of_canonical_interleaved_rs_lifts P hk decode hcode v)

/-- Thus one actual nonexact decoded input rules out the universal paired
compatibility law; no extra assumption about its positive distance is needed. -/
theorem not_all_canonical_interleaved_rs_lifts_exact_of_nonexact_linear_decode
    {σ : Type*} [Fintype σ]
    (F : CellularSheaf X)
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι)
    (hk : 2 ≤ P.degreeBound)
    (decode : (ι → σ → ℝ) →ₗ[ℝ] F.C1)
    (v : ι → σ → ℝ) (hv : ¬ F.IsExactOneCochain (decode v)) :
    ¬ (∀ word, (P.vectorBlockCode σ).Codeword word →
      F.IsExactOneCochain (decode (ProximityCoding.CanonicalLift.interleavedLift word))) := by
  intro hcode
  exact hv
    (F.all_linear_decodes_exact_of_canonical_interleaved_rs_lifts P hk decode hcode v)

/-- There is no uniform scaled comparison from the independently decoded
Euclidean exactness distance to pair/vector RS distance on all canonical
representatives, provided the linear decoder has any nonexact image. The
scale is arbitrary; positivity would not fix the zero-distance obstruction. -/
theorem not_uniform_rs_distance_comparison_of_nonexact_linear_decode
    {σ : Type*} [Fintype σ]
    (F : CellularSheaf X)
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι)
    (hk : 2 ≤ P.degreeBound)
    (decode : (ι → σ → ℝ) →ₗ[ℝ] F.C1)
    (v : ι → σ → ℝ) (hv : ¬ F.IsExactOneCochain (decode v)) :
    ¬ ∃ scale : ℝ, ∀ word : ι → σ → ZMod q,
      F.exactDistance (decode (ProximityCoding.CanonicalLift.interleavedLift word)) ≤
        scale * (P.vectorBlockCode σ).relativeDistanceToCode word := by
  rintro ⟨scale, hbound⟩
  apply F.not_all_canonical_interleaved_rs_lifts_exact_of_nonexact_linear_decode
    P hk decode v hv
  intro word hword
  apply (F.exactDistance_eq_zero_iff _).mp
  apply le_antisymm _ (F.exactDistance_nonneg _)
  have hzero := (P.vectorBlockCode σ).relativeDistanceToCode_eq_zero_of_codeword hword
  simpa only [hzero, mul_zero] using hbound word

end HomotopicalEncryption.Sheaf.CellularSheaf
