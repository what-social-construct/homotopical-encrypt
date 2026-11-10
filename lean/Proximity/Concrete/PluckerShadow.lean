module

public import Proximity.Application.Projection

@[expose] public section

/-
  Plucker-coordinate shadow candidates.

  Paper correspondence:
  - Shared abstract shadow vocabulary, with full exterior/projective recovery
    in Paper 1 through the concrete owner.
  - Paper 3 can use a declared shadow as a projection source; this legacy
    interface alone supplies no exterior reconstruction theorem.

  The retired Python prototype has a concrete Plucker layer in
  `docs/archive/python/src/primitives/grassmann.py`:
  `to_plucker`, `from_plucker`, `plucker_inner_product`, and
  `plucker_distance`, built from `wedge_k` in the archived `algebra.py`.

  This legacy file leaves the raw coordinate and shadow operations abstract.
  The actual finite exterior-power/projective construction lives in
  `GrassmannianPlucker` and its concrete reconstruction owner. This interface
  records only the candidate shadow operations and their supplied laws.
-/

namespace Hcrypt
namespace Proximity
namespace PluckerShadow

/--
Abstract Plucker coordinate system.

`HiddenSubspace` may later be instantiated by a Grassmannian point/submodule.
`Coordinate` is the raw exterior-power coordinate vector. `Shadow` is the
normalized/projectivized public datum used by validators or proximity bridges.
-/
structure CoordinateSystem where
  HiddenSubspace : Type
  Coordinate : Type
  Shadow : Type
  toPlucker : HiddenSubspace → Coordinate
  normalize : Coordinate → Shadow
  /-- Raw coordinate is nonzero before projectivization. -/
  Nonzero : Coordinate → Prop
  /-- Decomposability: the coordinate really comes from a k-plane. -/
  Decomposable : Coordinate → Prop
  /-- Plucker quadratic relations / Grassmannian image condition. -/
  PluckerRelations : Coordinate → Prop
  /-- Normalized/projective representative is well formed. -/
  Normalized : Shadow → Prop
  /-- Coordinate support/minor pattern is admissible for the chosen regime. -/
  SupportAdmissible : Shadow → Prop
  /-- Projective sign/scale ambiguity for coordinates of the same subspace. -/
  ProjectivelyEquivalent : Coordinate → Coordinate → Prop

namespace CoordinateSystem

/-- Public shadow of a hidden subspace. -/
def publicShadow (P : CoordinateSystem) (W : P.HiddenSubspace) : P.Shadow :=
  P.normalize (P.toPlucker W)

/-- A hidden subspace has valid raw Plucker coordinates. -/
def ValidRawCoordinate (P : CoordinateSystem) (W : P.HiddenSubspace) : Prop :=
  P.Nonzero (P.toPlucker W)
    ∧ P.Decomposable (P.toPlucker W)
    ∧ P.PluckerRelations (P.toPlucker W)

/-- A hidden subspace has a valid normalized public Plucker shadow. -/
def ValidShadow (P : CoordinateSystem) (W : P.HiddenSubspace) : Prop :=
  P.Normalized (P.publicShadow W) ∧ P.SupportAdmissible (P.publicShadow W)

/--
Soundness of the Plucker shadow map.

This is intentionally a contract, not a theorem: the actual exterior-power
formalization should eventually prove it for a concrete coordinate system.
-/
structure Sound (P : CoordinateSystem) : Prop where
  valid_raw : ∀ W : P.HiddenSubspace, P.ValidRawCoordinate W
  valid_shadow : ∀ W : P.HiddenSubspace, P.ValidShadow W
  projective_invariance :
    ∀ c d : P.Coordinate,
      P.ProjectivelyEquivalent c d → P.normalize c = P.normalize d
  support_projective_invariant :
    ∀ c d : P.Coordinate,
      P.ProjectivelyEquivalent c d →
        P.SupportAdmissible (P.normalize c) →
          P.SupportAdmissible (P.normalize d)

/-- Sound coordinate systems give nonzero coordinates for every hidden subspace. -/
theorem nonzero_of_sound
    {P : CoordinateSystem}
    (hP : P.Sound)
    (W : P.HiddenSubspace) :
    P.Nonzero (P.toPlucker W) :=
  (hP.valid_raw W).1

/-- Sound coordinate systems give decomposable coordinates for every hidden subspace. -/
theorem decomposable_of_sound
    {P : CoordinateSystem}
    (hP : P.Sound)
    (W : P.HiddenSubspace) :
    P.Decomposable (P.toPlucker W) :=
  (hP.valid_raw W).2.1

/-- Sound coordinate systems satisfy Plucker relations for every hidden subspace. -/
theorem relations_of_sound
    {P : CoordinateSystem}
    (hP : P.Sound)
    (W : P.HiddenSubspace) :
    P.PluckerRelations (P.toPlucker W) :=
  (hP.valid_raw W).2.2

/-- Sound coordinate systems give normalized public shadows. -/
theorem normalizedShadow_of_sound
    {P : CoordinateSystem}
    (hP : P.Sound)
    (W : P.HiddenSubspace) :
    P.Normalized (P.publicShadow W) :=
  (hP.valid_shadow W).1

/-- Sound coordinate systems give admissible public shadow support. -/
theorem supportAdmissible_of_sound
    {P : CoordinateSystem}
    (hP : P.Sound)
    (W : P.HiddenSubspace) :
    P.SupportAdmissible (P.publicShadow W) :=
  (hP.valid_shadow W).2

/--
Granular invariant checklist for a concrete Plucker shadow.

This is useful before attempting to identify the shadow with an RS received
word: it separates coordinate-level algebra from public-shadow normalization
and support constraints.
-/
structure InvariantChecklist (P : CoordinateSystem) : Prop where
  nonzero : ∀ W : P.HiddenSubspace, P.Nonzero (P.toPlucker W)
  decomposable : ∀ W : P.HiddenSubspace, P.Decomposable (P.toPlucker W)
  pluckerRelations : ∀ W : P.HiddenSubspace, P.PluckerRelations (P.toPlucker W)
  normalized : ∀ W : P.HiddenSubspace, P.Normalized (P.publicShadow W)
  supportAdmissible : ∀ W : P.HiddenSubspace, P.SupportAdmissible (P.publicShadow W)
  projectiveInvariance :
    ∀ c d : P.Coordinate,
      P.ProjectivelyEquivalent c d → P.normalize c = P.normalize d

/-- A sound coordinate system supplies the granular invariant checklist. -/
theorem invariantChecklist_of_sound
    {P : CoordinateSystem}
    (hP : P.Sound) :
    P.InvariantChecklist where
  nonzero := nonzero_of_sound hP
  decomposable := decomposable_of_sound hP
  pluckerRelations := relations_of_sound hP
  normalized := normalizedShadow_of_sound hP
  supportAdmissible := supportAdmissible_of_sound hP
  projectiveInvariance := hP.projective_invariance

end CoordinateSystem

/--
Plucker shadow as a concrete `CodeShadow`.

This does not say the shadow is Reed-Solomon. It only packages a public Plucker
shadow with a codeword/validity predicate and a distance. A future RS bridge may
try to identify this `Word` with an RS received-word representation.
-/
structure AsCodeShadow (P : CoordinateSystem) where
  Codeword : P.Shadow → Prop
  distanceToCode : P.Shadow → ℝ
  soundCodeword :
    ∀ W : P.HiddenSubspace,
      P.ValidRawCoordinate W → P.ValidShadow W → Codeword (P.publicShadow W)

namespace AsCodeShadow

/-- The generic code-shadow surface induced by a Plucker shadow. -/
def toCodeShadow {P : CoordinateSystem} (S : AsCodeShadow P) :
    Hcrypt.Proximity.CodeShadow where
  Word := P.Shadow
  Codeword := S.Codeword
  distanceToCode := S.distanceToCode

/-- Valid hidden subspaces map to codewords in the Plucker shadow. -/
theorem codeword_of_valid_raw
    {P : CoordinateSystem}
    (S : AsCodeShadow P)
    {W : P.HiddenSubspace}
    (hRaw : P.ValidRawCoordinate W)
    (hShadow : P.ValidShadow W) :
    S.toCodeShadow.Codeword (P.publicShadow W) :=
  S.soundCodeword W hRaw hShadow

end AsCodeShadow

/--
Optional compatibility package between a Plucker shadow and another public
received-word model.

For the RS program, this is the place to later say that the RS received word is
obtained from, or agrees with, the Plucker/projective coordinate shadow. Keeping
this optional avoids forcing the RS bridge to go through Plucker if a cleaner
projection is found.
-/
structure CompatibleReceivedWord
    (P : CoordinateSystem)
    (Word : Type) where
  encode : P.Shadow → Word
  ShadowDeterminesWord : Prop
  CoordinateNaturality : Prop
  ShadowNaturality : Prop
  DistanceComparison : Prop

def CompatibleReceivedWord.Complete
    {P : CoordinateSystem} {Word : Type}
    (C : CompatibleReceivedWord P Word) : Prop :=
  C.ShadowDeterminesWord
    ∧ C.CoordinateNaturality
    ∧ C.ShadowNaturality
    ∧ C.DistanceComparison

end PluckerShadow
end Proximity
end Hcrypt
