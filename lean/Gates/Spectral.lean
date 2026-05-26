import Axioms.SpectralBounds

/-
  Spectral gate.

  The PoV/Tsirelson window is a hard admissibility predicate. Runtime boundary
  handling for near-boundary values lives in the oracle gate.
-/

namespace Hcrypt
namespace Gates

/-- Lower PoV/Tsirelson spectral-gap bound. -/
noncomputable abbrev povSpectralLower : ℝ :=
  Hcrypt.Axioms.povSpectralLower

/-- Upper PoV/Tsirelson spectral-gap bound. -/
noncomputable abbrev povSpectralUpper : ℝ :=
  Hcrypt.Axioms.povSpectralUpper

/-- Hard spectral-gap gate used by PoV consensus. -/
abbrev SpectralGapGate : ℝ → Prop :=
  Hcrypt.Axioms.SpectralGapInPoVBounds

/-- Boundary proximity marker for oracle hold/re-evaluate policy. -/
abbrev NearSpectralBoundary : ℝ → ℝ → Prop :=
  Hcrypt.Axioms.NearPoVSpectralBoundary

/-- By-construction PoV geometry witnesses pass the hard spectral gate. -/
theorem byConstruction_passes_spectral_gate
    (G : Hcrypt.Axioms.ByConstructionPoVGeometry) :
    SpectralGapGate G.spectralGap :=
  Hcrypt.Axioms.byConstruction_gap_in_bounds G

end Gates
end Hcrypt
