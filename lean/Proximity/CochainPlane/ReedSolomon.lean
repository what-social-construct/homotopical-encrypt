import Proximity.CochainPlane.Core
import Proximity.RS.Target
import Axioms.CochainCommitment.Payload
import Mathlib.Data.ZMod.Basic

/-
  Reed-Solomon interpretation of cochain plane shadows.

  Paper correspondence:
  - Paper 1 Section 6: plane-shadow to RS received-word stage.

  The concrete projection from committed cochains to semantic two-coordinate
  plane shadows lives in `Proximity.CochainPlane`. This file begins only after
  that projection exists: it encodes each plane point into a finite field and
  interprets the resulting indexed family as an RS received word.
-/

namespace Hcrypt
namespace Proximity
namespace CochainReedSolomon

noncomputable section

variable {R F ι : Type}
variable [Field F] [Fintype F] [Fintype ι] [DecidableEq F]

/--
Canonical concrete RS field for the current hcrypt wire/runtime modulus.

This is only a finite-field boundary. The semantic cochain and plane-shadow
layers remain independent of the runtime payload modulus.
-/
abbrev CanonicalField :=
  ZMod Axioms.canonicalCochainModulus

/-- The current canonical cochain modulus is prime. -/
instance canonicalCochainModulus_prime :
    Fact (Nat.Prime Axioms.canonicalCochainModulus) :=
  ⟨by native_decide⟩

/--
Encoding boundary from a semantic plane point into an RS field element.

This is where concrete finite-field choices live. The cochain/plane layer does
not depend on the runtime commitment modulus or on RS field structure.
-/
structure PlaneEncoding (R F : Type) where
  encodePoint : (Fin 2 → R) → F

namespace PlaneEncoding

/-- Encode an indexed plane shadow as an RS received word. -/
def receivedWord
    (E : PlaneEncoding R F)
    {ι : Type}
    (p : CochainPlane.PlaneShadow R ι) :
    Word ι F :=
  fun i => E.encodePoint (p i)

/--
Integer plane encoding into the canonical RS field.

The parameter `mix` fixes how the second plane coordinate is folded into one
field symbol. This is a concrete encoding boundary, not a claim that this
particular `mix` has the final distance/non-collapse property.
-/
def integerCanonical
    (mix : CanonicalField) :
    PlaneEncoding ℤ CanonicalField where
  encodePoint p := ((p 0 : ℤ) : CanonicalField) + mix * ((p 1 : ℤ) : CanonicalField)

end PlaneEncoding

/-- The plane target induced by a selected RS target, metric, and plane encoding. -/
def rsPlaneTarget
    (T : ReedSolomonTarget.Target F ι)
    (D : ReedSolomonTarget.Target.ReceivedWordMetric T)
    (Φ : PlaneEncoding R F) :
    CochainPlane.PlaneTarget R ι where
  Codeword := fun p => T.parameters.Codeword (Φ.receivedWord p)
  distanceToCode := fun p => D.distanceToRS (Φ.receivedWord p)

/--
RS interpretation of an already-defined cochain-plane projection.

The projection itself remains the concrete `CochainPlane.PlaneExtractionContext`
extraction from `edge_values` into a semantic plane shadow. This structure only
records the later finite-field/RS interpretation of that plane.
-/
structure Interpretation
    {S : Axioms.SheafCoherence}
    (L : PluckerCochain.LocalSyndromeTarget S)
    (T : ReedSolomonTarget.Target F ι)
    (D : ReedSolomonTarget.Target.ReceivedWordMetric T)
    (E : CochainPlane.PlaneExtractionContext R ι)
    (Φ : PlaneEncoding R F) where
  projection : CochainPlane.Projection L E (rsPlaneTarget T D Φ)

namespace Interpretation

/-- Map a committed cochain through plane projection and then RS field encoding. -/
def receivedWord
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (_I : Interpretation L T D E Φ)
    (c : CochainBridge.CommittedCochain) :
    Word ι F :=
  Φ.receivedWord (E.projectedPlane c)

/-- An RS interpretation exposes an evaluation projection into the RS code shadow. -/
def toEvaluationProjection
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ) :
    EvaluationProjection
      (CochainPlane.localSyndromeInstance L)
      D.codeShadow where
  map := I.receivedWord
  preservesGlobalSections := by
    intro c hc
    exact I.projection.mapsCodewordsToTarget c hc
  distanceControlled := by
    intro c
    exact I.projection.distanceControlled c

/-- Accepted local cochain tests project to RS codewords under this interpretation. -/
theorem projected_localCodeword_is_RSCodeword
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ)
    (c : CochainBridge.CommittedCochain) :
    L.Codeword c → T.parameters.Codeword (I.receivedWord c) :=
  I.projection.mapsCodewordsToTarget c

/-- RS distance is bounded by the local cochain syndrome distance. -/
theorem projected_distance_le_localSyndromeDistance
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ)
    (c : CochainBridge.CommittedCochain) :
    D.distanceToRS (I.receivedWord c) ≤ L.distanceToCode c :=
  I.projection.distanceControlled c

end Interpretation

/--
Stage-local invariant checklist for the plane-to-RS interpretation.

This checklist is the finite-field encoding boundary. It records that the RS
received word is obtained only by encoding the already-projected plane shadow,
that accepted local cochains become RS codewords, and that the selected RS
metric remains controlled by the local syndrome distance.
-/
structure InvariantChecklist
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ) : Prop where
  receivedWordMatchesPlaneEncoding :
    ∀ c : CochainBridge.CommittedCochain,
      I.receivedWord c = Φ.receivedWord (E.projectedPlane c)
  localCodewordsMapToRSCodewords :
    ∀ c : CochainBridge.CommittedCochain,
      L.Codeword c → T.parameters.Codeword (I.receivedWord c)
  distanceControlled :
    ∀ c : CochainBridge.CommittedCochain,
      D.distanceToRS (I.receivedWord c) ≤ L.distanceToCode c

namespace InvariantChecklist

/-- Every plane-to-RS interpretation exposes its stage-local invariants. -/
def of_interpretation
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : PlaneEncoding R F}
    (I : Interpretation L T D E Φ) :
    InvariantChecklist I where
  receivedWordMatchesPlaneEncoding := by
    intro c
    rfl
  localCodewordsMapToRSCodewords := by
    intro c hc
    exact I.projection.mapsCodewordsToTarget c hc
  distanceControlled := by
    intro c
    exact I.projection.distanceControlled c

end InvariantChecklist

end

end CochainReedSolomon
end Proximity
end Hcrypt
