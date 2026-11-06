module

public import Mathlib.Analysis.Real.Sqrt

@[expose] public section

namespace Hcrypt
namespace Axioms

/-
  Spectral Bounds

  Paper correspondence:
  - Paper 1 Section 4: spectral admissibility interface.
  - Paper 2: Proof-of-Value spectral gate policy.

  Canonical Lean home for the PoV/Tsirelson spectral window used by the
  homotopical-encrypt construction.

  Scope:
    * The predicate below is a hard mathematical admissibility condition.
    * Boundary/marginal runtime handling lives in `OracleModality.lean`.
    * HCP hidden-operator hardness does not depend on this predicate; hardness
      comes from hidden fibration / hidden Laplacian / hidden kernel ambiguity.
-/

/-- Lower PoV/Tsirelson spectral-gap bound: `1 / sqrt 2 = sqrt 2 / 2`. -/
noncomputable def povSpectralLower : ℝ := Real.sqrt 2 / 2

/-- Upper PoV/Tsirelson spectral-gap bound: `2 * sqrt 2`. -/
noncomputable def povSpectralUpper : ℝ := 2 * Real.sqrt 2

/-- The consensus-valid spectral-gap window used by the PoV gate. -/
def SpectralGapInPoVBounds (gap : ℝ) : Prop :=
  povSpectralLower ≤ gap ∧ gap ≤ povSpectralUpper

/--
Boundary proximity predicate used by deterministic node/oracle policy.

This predicate only marks a gap as close to a boundary. The consensus action
associated to such a mark is defined separately in `OracleModality.lean`.
-/
def NearPoVSpectralBoundary (gap eps : ℝ) : Prop :=
  |gap - povSpectralLower| ≤ eps ∨ |gap - povSpectralUpper| ≤ eps

/--
PoV geometry object whose spectral gap is valid by construction.

This is the Lean shape matching the documentation: the `sqrt 2` bounds are a
consensus validity condition for geometrically admissible fibrations, not the
core HCP hidden-operator hardness assumption. Runtime code still has to compute
and attest the concrete gap; this structure records what a successfully
constructed PoV witness must carry.
-/
structure ByConstructionPoVGeometry where
  spectralGap : ℝ
  LaplacianConstructed : Prop
  OrthogonalTransport : Prop
  BoundedNerve : Prop
  gap_in_bounds : SpectralGapInPoVBounds spectralGap

/-- A by-construction PoV geometry witness has a gap in the PoV window. -/
theorem byConstruction_gap_in_bounds (G : ByConstructionPoVGeometry) :
    SpectralGapInPoVBounds G.spectralGap :=
  G.gap_in_bounds

/- Compatibility names used by the oracle-modality layer. -/

/-- Oracle-facing name for the PoV spectral predicate. -/
abbrev TsirelsonPredicate : ℝ → Prop := SpectralGapInPoVBounds

/-- Oracle-facing name for the lower PoV/Tsirelson bound. -/
noncomputable abbrev tsirelsonLower : ℝ := povSpectralLower

/-- Oracle-facing name for the upper PoV/Tsirelson bound. -/
noncomputable abbrev tsirelsonUpper : ℝ := povSpectralUpper

/-- Oracle-facing name for PoV boundary proximity. -/
abbrev NearTsirelsonBoundary : ℝ → ℝ → Prop := NearPoVSpectralBoundary

end Axioms
end Hcrypt
