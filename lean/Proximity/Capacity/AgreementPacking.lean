module

public import Proximity.ListDecoding.PhaseSplit
public import Mathlib.Data.Fintype.Sigma

@[expose] public section

/-!
# Packing agreement subsets in interleaved Reed–Solomon lists

Every `k`-subset of agreement coordinates specifies at most one codeword
when the code is determined by `k` sites. Counting all these subsets gives
the finite-radius packing bound. The capacity witness gives an adjacent
threshold when the fractional budget lies between the packing bound at the
preceding radius and the exact endpoint list size.
-/

set_option autoImplicit false

namespace ProximityCoding

namespace CapacityList

open BlockCode

/-- Count each `k`-subset of a list member's agreement coordinates. -/
theorem ballCard_mul_choose_agreement_le
    {ι α : Type*} [Fintype ι] [Fintype α] [DecidableEq α]
    (C : BlockCode ι α) {k : ℕ} (hdet : DeterminedBy C k)
    (r : ℕ) (w : Word ι α) :
    C.ballCard r w * Nat.choose (Fintype.card ι - r) k ≤
      Nat.choose (Fintype.card ι) k := by
  classical
  let ListWord := {c : Word ι α // c ∈ C.Ball r w}
  let : Fintype ListWord := Fintype.ofFinite _
  let Agreement (c : ListWord) :=
    {s : Finset ι // s ∈ (agreementSet c.1 w).powersetCard k}
  let (c : ListWord) : Fintype (Agreement c) := Finset.Subtype.fintype _
  let signature : (Σ c, Agreement c) → {s : Finset ι // s.card = k} :=
    fun a => ⟨a.2.1, (Finset.mem_powersetCard.mp a.2.2).2⟩
  have hinjective : Function.Injective signature := by
    rintro ⟨c, s⟩ ⟨d, t⟩ h
    have hst : s.1 = t.1 := congrArg Subtype.val h
    obtain ⟨hs, hcard⟩ := Finset.mem_powersetCard.mp s.2
    have ht := (Finset.mem_powersetCard.mp t.2).1
    have hcd : c = d := Subtype.ext (hdet c.2.1 d.2.1 s.1 hcard (by
      intro i hi
      have hci := (Finset.mem_filter.mp (hs hi)).2
      have hdi := (Finset.mem_filter.mp (ht (hst ▸ hi))).2
      exact hci.trans hdi.symm))
    subst d
    exact congrArg (Sigma.mk c) (Subtype.ext hst)
  calc
    C.ballCard r w * Nat.choose (Fintype.card ι - r) k =
        ∑ _c : ListWord, Nat.choose (Fintype.card ι - r) k := by
      simp [BlockCode.ballCard, Nat.card_eq_fintype_card, ListWord]
    _ ≤ ∑ c : ListWord, Fintype.card (Agreement c) := by
      apply Finset.sum_le_sum
      intro c _
      have hpartition := agreement_card_add_hammingDistance c.1 w
      have hdist := c.2.2
      have hagree : Fintype.card ι - r ≤ (agreementSet c.1 w).card := by omega
      change _ ≤ Fintype.card {s : Finset ι // s ∈ (agreementSet c.1 w).powersetCard k}
      rw [Fintype.card_coe, Finset.card_powersetCard]
      exact Nat.choose_le_choose k hagree
    _ = Fintype.card (Σ c, Agreement c) := Fintype.card_sigma.symm
    _ ≤ Fintype.card {s : Finset ι // s.card = k} :=
      Fintype.card_le_of_injective signature hinjective
    _ = Nat.choose (Fintype.card ι) k := Fintype.card_finset_len _

end CapacityList

namespace ReedSolomon.Parameters

open BlockCode CapacityList

variable {F ι : Type*} [Field F] [Fintype F] [DecidableEq F] [Fintype ι]

/-- The agreement-subset packing inequality for interleaved RS words. -/
theorem vectorListSizeBound_mul_choose_agreement_le
    (P : Parameters F ι) (σ : Type*) [Fintype σ]
    (r : ℕ) (w : VectorWord ι F σ) :
    (P.vectorBlockCode σ).ballCard r w * Nat.choose (Fintype.card ι - r) P.degreeBound ≤
      Nat.choose (Fintype.card ι) P.degreeBound := by
  classical
  exact ballCard_mul_choose_agreement_le (P.vectorBlockCode σ)
    (P.vectorDeterminedBy_degreeBound σ) r w

/-- The packing bound at every radius with at least `k` agreements. -/
theorem vectorListSizeBound_packing
    (P : Parameters F ι) (σ : Type*) [Fintype σ]
    (r : ℕ) (hAgreement : P.degreeBound ≤ Fintype.card ι - r) :
    (P.vectorBlockCode σ).ListSizeBound r
      (Nat.choose (Fintype.card ι) P.degreeBound /
        Nat.choose (Fintype.card ι - r) P.degreeBound) := by
  intro w
  exact (Nat.le_div_iff_mul_le (Nat.choose_pos hAgreement)).mpr
    (P.vectorListSizeBound_mul_choose_agreement_le σ r w)

/-- A budget covering the packing bound one step below capacity, and below
the exact capacity list size, has its first unsafe count at capacity. -/
theorem vectorFractionalListGridCertificate_before_capacity
    (P : Parameters F ι) {σ : Type*} [Fintype σ] [Nonempty σ]
    (hDegree : 0 < P.degreeBound) (hk : P.degreeBound < Fintype.card ι)
    {ε : ℝ}
    (hsafe : ((Nat.choose (Fintype.card ι) P.degreeBound /
      (P.degreeBound + 1) : ℕ) : ℝ) ≤ ε * Fintype.card F)
    (hunsafe : ε * Fintype.card F < (Nat.choose (Fintype.card ι) P.degreeBound : ℝ)) :
    FiniteThreshold.ExactGridCertificate (Fintype.card ι)
      (fun r => FractionalListSizeBoundAt (P.vectorBlockCode σ)
        (relativeRadius (ι := ι) r) ε (Fintype.card F))
      (Fintype.card ι - P.degreeBound - 1) := by
  classical
  let r := Fintype.card ι - P.degreeBound - 1
  have hn : 0 < Fintype.card ι := hDegree.trans hk
  have hagree : Fintype.card ι - r = P.degreeBound + 1 := by dsimp [r]; omega
  have hnext : r + 1 = Fintype.card ι - P.degreeBound := by dsimp [r]; omega
  refine ⟨by omega, fun _ _ hrs =>
    fractionalListSizeBoundAt_antitone _ ε _ (relativeRadius_mono hrs), ?_, ?_⟩
  · intro w
    have hbound := P.vectorListSizeBound_packing σ r (by rw [hagree]; omega) w
    rw [hagree, Nat.choose_succ_self_right] at hbound
    rw [(P.vectorBlockCode σ).ballCardAt_relativeRadius_eq_ballCard hn w]
    exact (by exact_mod_cast hbound :
      ((P.vectorBlockCode σ).ballCard r w : ℝ) ≤
        (Nat.choose (Fintype.card ι) P.degreeBound / (P.degreeBound + 1) : ℕ)).trans hsafe
  · rw [hnext]
    exact fun h => hunsafe.not_ge ((P.vectorFractionalListSizeBoundAt_capacityGrid_iff
      (Classical.arbitrary σ) ε hDegree hn hk.le).mp h)

end ReedSolomon.Parameters

end ProximityCoding
