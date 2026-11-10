module

public import Axioms.SpectralBounds

@[expose] public section

/-
  Spectral gate.

  Paper correspondence:
  - Paper 2: spectral admissibility and Proof-of-Value runtime policy.
  - The gate is a named predicate, not a quantitative hardness statement in
    Paper 1.

  The PoV/Tsirelson window is a hard admissibility predicate. Runtime boundary
  handling for near-boundary values lives in the oracle gate.
-/

namespace HomotopicalEncryption
namespace Gates

/-- Lower PoV/Tsirelson spectral-gap bound. -/
noncomputable abbrev povSpectralLower : ℝ :=
  HomotopicalEncryption.Axioms.povSpectralLower

/-- Upper PoV/Tsirelson spectral-gap bound. -/
noncomputable abbrev povSpectralUpper : ℝ :=
  HomotopicalEncryption.Axioms.povSpectralUpper

/-- Hard spectral-gap gate used by PoV consensus. -/
abbrev SpectralGapGate : ℝ → Prop :=
  HomotopicalEncryption.Axioms.SpectralGapInPoVBounds

/-- Boundary proximity marker for oracle hold/re-evaluate policy. -/
abbrev NearSpectralBoundary : ℝ → ℝ → Prop :=
  HomotopicalEncryption.Axioms.NearPoVSpectralBoundary

/-- By-construction PoV geometry witnesses pass the hard spectral gate. -/
theorem byConstruction_passes_spectral_gate
    (G : HomotopicalEncryption.Axioms.ByConstructionPoVGeometry) :
    SpectralGapGate G.spectralGap :=
  HomotopicalEncryption.Axioms.byConstruction_gap_in_bounds G

end Gates
end HomotopicalEncryption
