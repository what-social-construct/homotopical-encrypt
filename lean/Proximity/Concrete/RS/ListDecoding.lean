module

public import Proximity.Core.BlockCode

@[expose] public section

/-!
# Compatibility surface for finite block-code vocabulary

`ProximityPrize.BlockCode` now owns the application-independent definitions and
proofs. This module preserves the historical `HomotopicalEncryption.Proximity` names used by
the existing application bridge. Paper 3 owns the coding statements; new
coding-theory work should import the standalone owner directly.
-/

namespace HomotopicalEncryption
namespace Proximity

/-- Compatibility alias for standalone received words. -/
abbrev Word (ι α : Type*) :=
  ProximityPrize.Word ι α

/-- Compatibility alias for standalone finite block codes. -/
abbrev BlockCode (ι α : Type*) :=
  ProximityPrize.BlockCode ι α

namespace BlockCode

variable {ι α : Type*} [Fintype ι] [DecidableEq α]

def hammingDistance (u v : Word ι α) : ℕ :=
  ProximityPrize.BlockCode.hammingDistance u v

noncomputable def relativeRadius (r : ℕ) : ℝ :=
  ProximityPrize.BlockCode.relativeRadius (ι := ι) r

noncomputable def relativeHammingDistance
    (u v : Word ι α) : ℝ :=
  ProximityPrize.BlockCode.relativeHammingDistance u v

abbrev Close (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : Prop :=
  ProximityPrize.BlockCode.Close C r w

abbrev CloseAt (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : Prop :=
  ProximityPrize.BlockCode.CloseAt C δ w

abbrev Ball
    (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : Set (Word ι α) :=
  ProximityPrize.BlockCode.Ball C r w

abbrev BallAt
    (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : Set (Word ι α) :=
  ProximityPrize.BlockCode.BallAt C δ w

noncomputable abbrev ballCard
    (C : BlockCode ι α) (r : ℕ) (w : Word ι α) : ℕ :=
  ProximityPrize.BlockCode.ballCard C r w

noncomputable abbrev ballCardAt
    (C : BlockCode ι α) (δ : ℝ) (w : Word ι α) : ℕ :=
  ProximityPrize.BlockCode.ballCardAt C δ w

abbrev ListSizeBound (C : BlockCode ι α) (r L : ℕ) : Prop :=
  ProximityPrize.BlockCode.ListSizeBound C r L

abbrev ListSizeBoundAt (C : BlockCode ι α) (δ : ℝ) (L : ℕ) : Prop :=
  ProximityPrize.BlockCode.ListSizeBoundAt C δ L

theorem closeAt_of_close
    (C : BlockCode ι α) {r : ℕ} {w : Word ι α}
    (hw : C.Close r w) :
    C.CloseAt (relativeRadius (ι := ι) r) w :=
  ProximityPrize.BlockCode.closeAt_of_close C hw

@[simp]
theorem relativeRadius_zero :
    relativeRadius (ι := ι) 0 = 0 :=
  ProximityPrize.BlockCode.relativeRadius_zero

theorem relativeRadius_mono {r s : ℕ} (hrs : r ≤ s) :
    relativeRadius (ι := ι) r ≤ relativeRadius (ι := ι) s :=
  ProximityPrize.BlockCode.relativeRadius_mono hrs

theorem codeword_mem_ball_zero
    (C : BlockCode ι α) {c : Word ι α}
    (hc : C.Codeword c) :
    c ∈ C.Ball 0 c :=
  ProximityPrize.BlockCode.codeword_mem_ball_zero C hc

theorem close_of_mem_ball
    (C : BlockCode ι α) {r : ℕ} {w c : Word ι α}
    (hc : c ∈ C.Ball r w) :
    C.Close r w :=
  ProximityPrize.BlockCode.close_of_mem_ball C hc

theorem exists_mem_ball_of_close
    (C : BlockCode ι α) {r : ℕ} {w : Word ι α}
    (hw : C.Close r w) :
    ∃ c : Word ι α, c ∈ C.Ball r w :=
  ProximityPrize.BlockCode.exists_mem_ball_of_close C hw

end BlockCode

namespace BlockCode

variable {ι α : Type*}

abbrev interleaved (C : BlockCode ι α) (τ : Type*) :
    BlockCode ι (τ → α) :=
  ProximityPrize.BlockCode.interleaved C τ

theorem codeword_of_interleaved_component
    (C : BlockCode ι α) {τ : Type*}
    {w : Word ι (τ → α)} (hw : (C.interleaved τ).Codeword w)
    (j : τ) :
    C.Codeword fun i => w i j :=
  ProximityPrize.BlockCode.codeword_of_interleaved_component C hw j

end BlockCode

/-- Compatibility alias for the standalone additive-code interface. -/
abbrev FAdditiveCode
    (F ι α : Type*) [Zero α] [Add α] [SMul F α] :=
  ProximityPrize.FAdditiveCode F ι α

namespace FAdditiveCode

variable {F ι α : Type*} [Zero α] [Add α] [SMul F α]

abbrev asBlockCode (C : FAdditiveCode F ι α) : BlockCode ι α :=
  ProximityPrize.FAdditiveCode.asBlockCode C

theorem linear_combination_mem
    (C : FAdditiveCode F ι α)
    (a : F) {u v : Word ι α}
    (hu : C.Codeword u) (hv : C.Codeword v) :
    C.Codeword fun i => u i + a • v i :=
  ProximityPrize.FAdditiveCode.linearCombination_mem C a hu hv

end FAdditiveCode

end Proximity
end HomotopicalEncryption
