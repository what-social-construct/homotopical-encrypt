import Axioms.SheafCoherence

/-
  Typed exact-to-Hodge-blinded commitment bridge.

  Paper correspondence:
  - Paper 1 Section 5: an accepted exact payload `δ₀ a` and a separately
    blinded Hodge value `δ₀ a + s • H_τ`.

  The wire payload remains the exact committed one-cochain.  This module does
  not identify the Hodge-blinded value with that serialized payload; it records
  the extra typed data needed to construct the latter from the former.
-/

namespace Hcrypt
namespace Axioms

/--
Typed Hodge-blinding operations for one fixed sheaf cochain complex.

The scalar action and addition are carried explicitly because the lightweight
`SheafCochainComplex` interface intentionally places no global algebraic
typeclasses on `C1`.  `exact_orthogonal` is the typed meaning consumed from the
ambient Hodge-orthogonality gate.
-/
structure HodgeBlindingContext (S : SheafCoherence) where
  Scalar : Type
  add : S.Complex.C1 → S.Complex.C1 → S.Complex.C1
  smul : Scalar → S.Complex.C1 → S.Complex.C1
  IsHarmonic : S.Complex.C1 → Prop
  Orthogonal : S.Complex.C1 → S.Complex.C1 → Prop
  harmonicDirection : (Fin 16 → UInt8) → S.Complex.C1
  harmonicDirection_isHarmonic :
    ∀ τ, IsHarmonic (harmonicDirection τ)
  exact_orthogonal :
    S.Hodge.Orthogonality →
      ∀ (a : S.Complex.C0) (h : S.Complex.C1),
        IsHarmonic h → Orthogonal (S.Complex.coboundary0 a) h

/--
A Hodge-blinded value built over an already accepted exact cochain payload.

`base` is the public, topology-bound payload decoded as `δ₀ a`.  The
separate value is `decode base + s • H_τ`, where `s` is not the opening `a` and
`H_τ` is selected deterministically by the payload's topology hash.
-/
structure BlindedCommittedCochain
    (S : SheafCoherence)
    (B : HodgeBlindingContext S) where
  base : CochainCommitmentData
  baseAccepted : CommittedCochainWellFormed S base
  blindingScalar : B.Scalar
  value : S.Complex.C1
  value_eq :
    value = B.add (S.CommittedCochains.decode base)
      (B.smul blindingScalar (B.harmonicDirection base.topology_hash))

namespace BlindedCommittedCochain

/-- The base of a blinded commitment still carries its exactness witness. -/
theorem base_representsExactOneCochain
    {S : SheafCoherence}
    {B : HodgeBlindingContext S}
    (c : BlindedCommittedCochain S B) :
    RepresentsExactOneCochain S c.base :=
  exactOneCochain_of_committedCochainWellFormed c.baseAccepted

/-- The base exact payload is a degree-one cocycle. -/
theorem base_isOneCocycle
    {S : SheafCoherence}
    {B : HodgeBlindingContext S}
    (c : BlindedCommittedCochain S B) :
    IsOneCocycle S c.base :=
  oneCocycle_of_committedCochainWellFormed c.baseAccepted

/-- The topology-derived blinding direction is harmonic. -/
theorem harmonicDirection_isHarmonic
    {S : SheafCoherence}
    {B : HodgeBlindingContext S}
    (c : BlindedCommittedCochain S B) :
    B.IsHarmonic (B.harmonicDirection c.base.topology_hash) :=
  B.harmonicDirection_isHarmonic c.base.topology_hash

/--
The exact component of an accepted base payload is orthogonal to its selected
harmonic blinding direction.
-/
theorem exactComponent_orthogonal_harmonicDirection
    {S : SheafCoherence}
    {B : HodgeBlindingContext S}
    (c : BlindedCommittedCochain S B) :
    ∃ a : S.Complex.C0,
      S.CommittedCochains.decode c.base = S.Complex.coboundary0 a ∧
      B.Orthogonal (S.Complex.coboundary0 a)
        (B.harmonicDirection c.base.topology_hash) := by
  obtain ⟨a, ha⟩ := c.base_representsExactOneCochain
  refine ⟨a, ha, ?_⟩
  exact B.exact_orthogonal
    (sheaf_wellFormed_of_committedCochainWellFormed
      c.baseAccepted).2.2.2.2.2.1
    a
    (B.harmonicDirection c.base.topology_hash)
    c.harmonicDirection_isHarmonic

/--
The blinded value has an exact-plus-harmonic decomposition tied to the same
accepted payload and topology hash.
-/
theorem exists_exact_harmonic_decomposition
    {S : SheafCoherence}
    {B : HodgeBlindingContext S}
    (c : BlindedCommittedCochain S B) :
    ∃ a : S.Complex.C0,
      S.CommittedCochains.decode c.base = S.Complex.coboundary0 a ∧
      c.value = B.add (S.Complex.coboundary0 a)
        (B.smul c.blindingScalar
          (B.harmonicDirection c.base.topology_hash)) := by
  obtain ⟨a, ha⟩ := c.base_representsExactOneCochain
  refine ⟨a, ha, ?_⟩
  rw [c.value_eq, ha]

end BlindedCommittedCochain

end Axioms
end Hcrypt
