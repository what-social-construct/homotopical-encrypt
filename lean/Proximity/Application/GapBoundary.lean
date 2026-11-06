module

public import Proximity.Application.Problem

@[expose] public section

/-!
# Admissible boundaries for the existing closed gap promises

The compatibility problem uses `score ≤ nearRadius` and `farRadius ≤ score`
with only `nearRadius ≤ farRadius`. Its two promises overlap precisely at an
attained common boundary. No accept/reject solver can satisfy both contracts
there. A strict-gap view below retains the original problem and proves its
promises disjoint without changing any score, radius or legacy definition.

The classical specification solver characterizes logical consistency only;
it provides no executable, efficient or cryptographic decision procedure.
This concrete-application leaf is outside the standalone coding aggregate.
-/

namespace Hcrypt.Proximity

namespace GapProximityProblem

/-- Both closed promises hold exactly at an attained common boundary. -/
theorem near_and_far_iff (P : GapProximityProblem) (x : P.Instance) :
    P.Near x ∧ P.Far x ↔
      P.nearRadius = P.farRadius ∧ P.score x = P.nearRadius := by
  constructor
  · rintro ⟨hnear, hfar⟩
    exact ⟨le_antisymm P.gap (hfar.trans hnear),
      le_antisymm hnear (P.gap.trans hfar)⟩
  · rintro ⟨hradii, hscore⟩
    exact ⟨hscore.le, (hradii.symm.trans hscore.symm).le⟩

/-- Equality of radii is harmless only when no instance attains that boundary. -/
theorem exists_overlap_iff (P : GapProximityProblem) :
    (∃ x, P.Near x ∧ P.Far x) ↔
      P.nearRadius = P.farRadius ∧ ∃ x, P.score x = P.nearRadius := by
  constructor
  · rintro ⟨x, hx⟩
    obtain ⟨hradii, hscore⟩ := (P.near_and_far_iff x).mp hx
    exact ⟨hradii, x, hscore⟩
  · rintro ⟨hradii, x, hscore⟩
    exact ⟨x, (P.near_and_far_iff x).mpr ⟨hradii, hscore⟩⟩

theorem exists_overlap_iff_boundary_attained
    (P : GapProximityProblem) (hradii : P.nearRadius = P.farRadius) :
    (∃ x, P.Near x ∧ P.Far x) ↔ ∃ x, P.score x = P.nearRadius := by
  constructor
  · intro h
    exact (P.exists_overlap_iff.mp h).2
  · intro h
    exact P.exists_overlap_iff.mpr ⟨hradii, h⟩

/-- Logical admissibility of the unchanged two closed promises. -/
def PromisesDisjoint (P : GapProximityProblem) : Prop :=
  ∀ x, ¬ (P.Near x ∧ P.Far x)

theorem promisesDisjoint_of_strictGap
    (P : GapProximityProblem) (hgap : P.nearRadius < P.farRadius) :
    P.PromisesDisjoint := by
  intro x hx
  exact (ne_of_lt hgap) ((P.near_and_far_iff x).mp hx).1

/-- An empty boundary shell also permits a consistent closed promise. -/
theorem promisesDisjoint_of_boundary_empty
    (P : GapProximityProblem) (hempty : ¬ ∃ x, P.score x = P.nearRadius) :
    P.PromisesDisjoint := by
  intro x hx
  exact hempty ⟨x, ((P.near_and_far_iff x).mp hx).2⟩

theorem promisesDisjoint_iff_strictGap_or_boundary_empty
    (P : GapProximityProblem) :
    P.PromisesDisjoint ↔
      P.nearRadius < P.farRadius ∨ ¬ ∃ x, P.score x = P.nearRadius := by
  constructor
  · intro hdisjoint
    by_cases hstrict : P.nearRadius < P.farRadius
    · exact Or.inl hstrict
    · right
      rintro ⟨x, hscore⟩
      have hradii : P.nearRadius = P.farRadius :=
        le_antisymm P.gap (le_of_not_gt hstrict)
      exact hdisjoint x ((P.near_and_far_iff x).mpr ⟨hradii, hscore⟩)
  · rintro (hstrict | hempty)
    · exact P.promisesDisjoint_of_strictGap hstrict
    · exact P.promisesDisjoint_of_boundary_empty hempty

theorem promisesDisjoint_of_solverCorrect
    (P : GapProximityProblem) (solver : P.Solver) (hsolver : P.SolverCorrect solver) :
    P.PromisesDisjoint := by
  rintro x ⟨hnear, hfar⟩
  have hdecision : GapDecision.accept = GapDecision.reject :=
    (hsolver.1 x hnear).symm.trans (hsolver.2 x hfar)
  cases hdecision

theorem not_solverCorrect_of_overlap
    (P : GapProximityProblem) (solver : P.Solver)
    {x : P.Instance} (hnear : P.Near x) (hfar : P.Far x) :
    ¬ P.SolverCorrect solver := by
  intro hsolver
  exact P.promisesDisjoint_of_solverCorrect solver hsolver x ⟨hnear, hfar⟩

/-- An attained equal-radius threshold rules out every correct accept/reject solver. -/
theorem not_exists_correctSolver_of_boundary_attained
    (P : GapProximityProblem) (hradii : P.nearRadius = P.farRadius)
    (hboundary : ∃ x, P.score x = P.nearRadius) :
    ¬ ∃ solver : P.Solver, P.SolverCorrect solver := by
  obtain ⟨x, hnear, hfar⟩ :=
    P.exists_overlap_iff.mpr ⟨hradii, hboundary⟩
  rintro ⟨solver, hsolver⟩
  exact P.not_solverCorrect_of_overlap solver hnear hfar hsolver

/-- A classical specification, with no claim of decidability or efficiency. -/
noncomputable def specificationSolver (P : GapProximityProblem) : P.Solver := by
  classical
  exact fun x => if P.Near x then GapDecision.accept else GapDecision.reject

theorem specificationSolver_correct
    (P : GapProximityProblem) (hdisjoint : P.PromisesDisjoint) :
    P.SolverCorrect P.specificationSolver := by
  constructor
  · intro x hnear
    simp [specificationSolver, hnear]
  · intro x hfar
    have hnear : ¬ P.Near x := fun h => hdisjoint x ⟨h, hfar⟩
    simp [specificationSolver, hnear]

/-- Existence of a mathematical specification solver is exactly promise consistency. -/
theorem exists_correctSolver_iff_promisesDisjoint (P : GapProximityProblem) :
    (∃ solver : P.Solver, P.SolverCorrect solver) ↔ P.PromisesDisjoint := by
  constructor
  · rintro ⟨solver, hsolver⟩
    exact P.promisesDisjoint_of_solverCorrect solver hsolver
  · intro hdisjoint
    exact ⟨P.specificationSolver, P.specificationSolver_correct hdisjoint⟩

end GapProximityProblem

/-- A view retaining one existing gap problem and certifying numeric separation. -/
structure SeparatedGapProblem where
  problem : GapProximityProblem
  strictGap : problem.nearRadius < problem.farRadius

namespace GapProximityProblem

/-- Strengthen admissibility without replacing the carrier, score or radii. -/
def withStrictGap (P : GapProximityProblem)
    (hgap : P.nearRadius < P.farRadius) : SeparatedGapProblem :=
  ⟨P, hgap⟩

end GapProximityProblem

namespace SeparatedGapProblem

theorem promisesDisjoint (P : SeparatedGapProblem) : P.problem.PromisesDisjoint :=
  P.problem.promisesDisjoint_of_strictGap P.strictGap

end SeparatedGapProblem

/-- Strictly separated view of the original sheaf-side closed gap problem. -/
def sheafSeparatedGapProblem
    (S : SheafProximityInstance) (nearRadius farRadius : ℝ)
    (hgap : nearRadius < farRadius) : SeparatedGapProblem :=
  (sheafGapProblem S nearRadius farRadius hgap.le).withStrictGap hgap

/-- Strictly separated view of the original target closed gap problem. -/
def codeSeparatedGapProblem
    (C : CodeShadow) (nearRadius farRadius : ℝ)
    (hgap : nearRadius < farRadius) : SeparatedGapProblem :=
  (codeGapProblem C nearRadius farRadius hgap.le).withStrictGap hgap

namespace CalibratedEndToEndGapProjection

/-- Existing calibrated reductions retain their maps and promises under strict views. -/
def toSeparatedGapReduction
    {S : SheafProximityInstance} {C : CodeShadow}
    {sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius : ℝ}
    (projection : CalibratedEndToEndGapProjection S C
      sourceNearRadius sourceFarRadius targetNearRadius targetFarRadius)
    (hsource : sourceNearRadius < sourceFarRadius)
    (htarget : targetNearRadius < targetFarRadius) :
    GapReduction
      (sheafSeparatedGapProblem S sourceNearRadius sourceFarRadius hsource).problem
      (codeSeparatedGapProblem C targetNearRadius targetFarRadius htarget).problem :=
  projection.toGapReduction hsource.le htarget.le

end CalibratedEndToEndGapProjection
end Hcrypt.Proximity
