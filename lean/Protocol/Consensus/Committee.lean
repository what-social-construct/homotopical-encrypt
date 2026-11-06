module

public import Mathlib.Algebra.Order.BigOperators.Group.Finset
public import Mathlib.Tactic.NormNum
public import TCB.ProofCarrying

@[expose] public section

/-!
  Registered weighted committees and strict Byzantine quorums.

  Voting weights are natural numbers. A support set is a quorum exactly when
  it contains only registered members and carries strictly more than two
  thirds of the total registered voting weight:

      2 * totalWeight < 3 * supportWeight.

  The multiplication form is deliberate. It avoids division, floating-point
  thresholds, and floor-rounding ambiguity at the protocol boundary.
-/

namespace Hcrypt
namespace Protocol
namespace Consensus

open scoped BigOperators

universe u

/-- A finite, epoch-bound validator committee with positive integral weights. -/
structure Committee (ValidatorId : Type u) where
  /-- Digest binding the canonical runtime representation of this committee. -/
  digest : TCB.Hash32
  /-- Epoch in which this committee is authorized to vote. -/
  epoch : ℕ
  /-- Registered validator identifiers. `Finset` makes membership duplicate-free. -/
  members : Finset ValidatorId
  /-- Voting weight assigned to an identifier. Only registered weights count. -/
  votingWeight : ValidatorId → ℕ
  /-- A protocol committee cannot be empty. -/
  members_nonempty : members.Nonempty
  /-- Every registered validator contributes positive voting weight. -/
  member_weight_pos : ∀ v, v ∈ members → 0 < votingWeight v

namespace Committee

variable {ValidatorId : Type u}

/-- Total voting weight of the registered committee. -/
def totalWeight (C : Committee ValidatorId) : ℕ :=
  ∑ v ∈ C.members, C.votingWeight v

/-- Voting weight carried by a proposed support set. -/
def supportWeight (C : Committee ValidatorId) (supporters : Finset ValidatorId) : ℕ :=
  ∑ v ∈ supporters, C.votingWeight v

/-- Registration predicate for a validator identifier. -/
def Registered (C : Committee ValidatorId) (v : ValidatorId) : Prop :=
  v ∈ C.members

/-- The total weight of a well-formed committee is positive. -/
theorem totalWeight_pos (C : Committee ValidatorId) :
    0 < C.totalWeight := by
  obtain ⟨v, hv⟩ := C.members_nonempty
  have hv_le : C.votingWeight v ≤ C.totalWeight := by
    unfold totalWeight
    exact Finset.single_le_sum (fun w _ => Nat.zero_le (C.votingWeight w)) hv
  exact lt_of_lt_of_le (C.member_weight_pos v hv) hv_le

/-- Registered support cannot carry more than the total committee weight. -/
theorem supportWeight_le_totalWeight
    (C : Committee ValidatorId)
    {supporters : Finset ValidatorId}
    (hRegistered : supporters ⊆ C.members) :
    C.supportWeight supporters ≤ C.totalWeight := by
  unfold supportWeight totalWeight
  exact Finset.sum_le_sum_of_subset hRegistered

/-- Support weight is monotone under inclusion. -/
theorem supportWeight_mono
    (C : Committee ValidatorId)
    {S T : Finset ValidatorId}
    (hST : S ⊆ T) :
    C.supportWeight S ≤ C.supportWeight T := by
  unfold supportWeight
  exact Finset.sum_le_sum_of_subset hST

/-- Strict weighted quorum: registered support carrying more than two thirds. -/
def IsQuorum (C : Committee ValidatorId) (supporters : Finset ValidatorId) : Prop :=
  supporters ⊆ C.members
    ∧ 2 * C.totalWeight < 3 * C.supportWeight supporters

/-- The complete committee is itself a quorum. -/
theorem members_isQuorum (C : Committee ValidatorId) :
    C.IsQuorum C.members := by
  constructor
  · exact Finset.Subset.rfl
  · have hpos := C.totalWeight_pos
    change 2 * C.totalWeight < 3 * C.totalWeight
    exact (Nat.mul_lt_mul_right hpos).2 (by omega)

/-- A strict quorum has at least one supporter. -/
theorem nonempty_of_isQuorum
    (C : Committee ValidatorId)
    {supporters : Finset ValidatorId}
    (hQuorum : C.IsQuorum supporters) :
    supporters.Nonempty := by
  by_contra hEmpty
  rw [Finset.not_nonempty_iff_eq_empty] at hEmpty
  have hThreshold := hQuorum.2
  simp [supportWeight, hEmpty] at hThreshold

/-- Enlarging a quorum inside the registered committee preserves quorum status. -/
theorem isQuorum_mono
    (C : Committee ValidatorId)
    {S T : Finset ValidatorId}
    (hS : C.IsQuorum S)
    (hST : S ⊆ T)
    (hRegistered : T ⊆ C.members) :
    C.IsQuorum T := by
  refine ⟨hRegistered, ?_⟩
  have hWeight := C.supportWeight_mono hST
  have hThreshold := hS.2
  omega

/--
Two strict weighted quorums overlap in more than one third of total weight.

This is the arithmetic core of Byzantine quorum intersection. It does not yet
assert that an overlap member is honest; that conclusion additionally requires
the faulty weight to be strictly below one third.
-/
theorem quorum_intersection_weight
    [DecidableEq ValidatorId]
    (C : Committee ValidatorId)
    {S T : Finset ValidatorId}
    (hS : C.IsQuorum S)
    (hT : C.IsQuorum T) :
    C.totalWeight < 3 * C.supportWeight (S ∩ T) := by
  have hUnionRegistered : S ∪ T ⊆ C.members :=
    Finset.union_subset hS.1 hT.1
  have hUnionLe : C.supportWeight (S ∪ T) ≤ C.totalWeight :=
    C.supportWeight_le_totalWeight hUnionRegistered
  have hInclusionExclusion :
      C.supportWeight (S ∪ T) + C.supportWeight (S ∩ T)
        = C.supportWeight S + C.supportWeight T := by
    simpa [supportWeight] using
      (Finset.sum_union_inter
        (s₁ := S) (s₂ := T) (f := C.votingWeight))
  have hSThreshold := hS.2
  have hTThreshold := hT.2
  omega

/-- Any two strict weighted quorums have a common registered validator. -/
theorem quorum_intersection_nonempty
    [DecidableEq ValidatorId]
    (C : Committee ValidatorId)
    {S T : Finset ValidatorId}
    (hS : C.IsQuorum S)
    (hT : C.IsQuorum T) :
    (S ∩ T).Nonempty := by
  by_contra hEmpty
  rw [Finset.not_nonempty_iff_eq_empty] at hEmpty
  have hWeight := C.quorum_intersection_weight hS hT
  simp [supportWeight, hEmpty] at hWeight

/--
If faulty voting weight is strictly below one third, two quorums share a
non-faulty validator.
-/
theorem quorum_intersection_contains_nonfaulty
    [DecidableEq ValidatorId]
    (C : Committee ValidatorId)
    {S T faulty : Finset ValidatorId}
    (hS : C.IsQuorum S)
    (hT : C.IsQuorum T)
    (_hFaultyRegistered : faulty ⊆ C.members)
    (hFaultyWeight : 3 * C.supportWeight faulty < C.totalWeight) :
    ∃ v, v ∈ S ∧ v ∈ T ∧ v ∉ faulty := by
  have hNotSubset : ¬ S ∩ T ⊆ faulty := by
    intro hIntersectionSubset
    have hIntersectionLe := C.supportWeight_mono hIntersectionSubset
    have hIntersectionWeight := C.quorum_intersection_weight hS hT
    omega
  obtain ⟨v, hvIntersection, hvFaulty⟩ := Finset.not_subset.mp hNotSubset
  have hvBoth := Finset.mem_inter.mp hvIntersection
  exact ⟨v, hvBoth.1, hvBoth.2, hvFaulty⟩

/--
Flooring `2*n/3` is not a strict two-thirds test: with four validators, two
supporters meet the floored threshold but do not form a strict quorum.
-/
theorem two_of_four_meets_floor_but_not_strict :
    (4 * 2) / 3 ≤ 2 ∧ ¬ (2 * 4 < 3 * 2) := by
  norm_num

end Committee

end Consensus
end Protocol
end Hcrypt
