import Proximity.Gates.Final
import TCB.Runtime

/-
  Proximity-specific gate certificates.

  Paper correspondence:
  - Paper 1 Section 6: projection-stage gates only; these should not be moved
    into the main HCP setup before the proximity section.
  - Paper 2: runtime evidence records may consume these certificates, but the
    protocol architecture is not developed in Paper 1.

  These gates name the invariants that sit between stage-local construction and
  the final RS far-region separation theorem. They are quotient-aware: collapse
  along intended directions is allowed, while far-to-near collapse is not.
-/

namespace Hcrypt
namespace Proximity
namespace Gates

open GrassmannianPlucker

noncomputable section

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
variable {R F ι : Type}
variable [Field F] [Fintype F] [Fintype ι] [DecidableEq F]

namespace Projection

variable
    {P : FramedSystem n r}
    {S : Axioms.SheafCoherence}
    {L : PluckerCochain.LocalSyndromeTarget S}
    {T : ReedSolomonTarget.Target F ι}
    {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
    {E : CochainPlane.PlaneExtractionContext R ι}
    {Φ : CochainReedSolomon.PlaneEncoding R F}
    {pluckerDisagreement : FrameWitness n r → ℝ}

/--
Source metric/disagreement gate.

This hard gate records that the source score used by the Plucker-side gap
problem is a well-defined public score: it is nonnegative and invariant under
the public Plucker quotient. It does not choose near/far radii and does not
prove final far separation.

This is a pre-chain gate: it depends only on the Plucker shadow system and the
chosen source disagreement score, not on a composed projection chain.
-/
structure SourceMetricGate
    (P : FramedSystem n r)
    (pluckerDisagreement : FrameWitness n r → ℝ) : Prop where
  disagreementNonnegative :
    ∀ W : FrameWitness n r, 0 ≤ pluckerDisagreement W
  disagreementQuotientInvariant :
    ∀ W V : FrameWitness n r,
      P.publicShadow W = P.publicShadow V →
        pluckerDisagreement W = pluckerDisagreement V

/--
Plucker chart/metric admissibility gate.

This gate records that valid frame witnesses land in the projective chart where
the selected Plucker metric and normalization are meaningful.

This is also pre-chain: it is about the Plucker chart/metric before any
committed cochain, plane shadow, or RS word is formed.
-/
structure PluckerMetricGate
    (P : FramedSystem n r) where
  ChartAdmissible : FrameWitness n r → Prop
  ProjectiveDistance : FrameWitness n r → FrameWitness n r → ℝ
  validFramesAdmissible :
    ∀ W : FrameWitness n r,
      PluckerCochain.ValidFrame P W → ChartAdmissible W
  distanceNonnegative :
    ∀ W V : FrameWitness n r, 0 ≤ ProjectiveDistance W V
  frameQuotientInvariant :
    ∀ W V U : FrameWitness n r,
      P.publicShadow W = P.publicShadow V →
        ProjectiveDistance W U = ProjectiveDistance V U

/--
Semantic alignment gate for the Plucker/cochain/plane/RS state bus.

It states that valid Plucker frames produce committed cochains aligned with the
plane extraction context, and that the received word is the encoded plane
shadow.
-/
structure SemanticAlignmentGate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) : Prop where
  validFramesAligned :
    ∀ W : FrameWitness n r,
      PluckerCochain.ValidFrame P W →
        E.Aligned (Γ.committedCochain W)
  planeShadowMatchesExtraction :
    ∀ W : FrameWitness n r,
      Γ.planeShadow W = E.projectedPlane (Γ.committedCochain W)
  receivedWordMatchesPlane :
    ∀ W : FrameWitness n r,
      Γ.receivedWord W = Φ.receivedWord (Γ.planeShadow W)

namespace SemanticAlignmentGate

/-- Every well-typed chain supplies the semantic-alignment gate for valid frames. -/
def of_chain
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) :
    SemanticAlignmentGate Γ where
  validFramesAligned := by
    intro W hW
    have hCandidate :
        CochainBridge.CommittedCochain.GlobalSectionCandidate S
          (Γ.committedCochain W) :=
      Γ.pluckerToCochain.preservesValidFrame W hW
    have hCodeword : L.Codeword (Γ.committedCochain W) :=
      L.codeword_of_globalCandidate hCandidate
    exact Γ.planeToRS.projection.alignsCodewords (Γ.committedCochain W) hCodeword
  planeShadowMatchesExtraction := by
    intro W
    rfl
  receivedWordMatchesPlane := by
    intro W
    rfl

end SemanticAlignmentGate

/--
Syndrome adequacy gate.

The existing local syndrome target proves global candidates have zero syndrome.
This gate names the stronger converse needed when a verifier treats a local
zero-syndrome test as global/sheaf evidence.
-/
structure SyndromeAdequacyGate
    (L : PluckerCochain.LocalSyndromeTarget S) : Prop where
  zeroSyndromeGlobalCandidate :
    ∀ c : CochainBridge.CommittedCochain,
      c.WellFormed →
        L.ZeroSyndrome (L.syndrome c) →
          CochainBridge.CommittedCochain.GlobalSectionCandidate S c

namespace SyndromeAdequacyGate

/-- Under adequacy, well-formed zero-syndrome cochains are local codewords. -/
theorem codeword_of_wellFormed_zeroSyndrome
    {L : PluckerCochain.LocalSyndromeTarget S}
    (G : SyndromeAdequacyGate L)
    {c : CochainBridge.CommittedCochain}
    (hWF : c.WellFormed)
    (hZero : L.ZeroSyndrome (L.syndrome c)) :
    L.Codeword c :=
  ⟨G.zeroSyndromeGlobalCandidate c hWF hZero, hZero⟩

end SyndromeAdequacyGate

/--
Public-shadow respect gate after the Plucker shadow.

The public Plucker shadow is already the quotient object. This gate records no
new collapse policy: it exposes that the downstream projection chain consumes
only that public shadow, so equality of public shadows gives equality of the
downstream committed cochain, plane shadow, and RS received word.
-/
structure PublicShadowRespectGate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) where
  committedCochain_respects_publicShadow :
    ∀ W V : FrameWitness n r,
      P.publicShadow W = P.publicShadow V →
        Γ.committedCochain W = Γ.committedCochain V
  planeShadow_respects_publicShadow :
    ∀ W V : FrameWitness n r,
      P.publicShadow W = P.publicShadow V →
        Γ.planeShadow W = Γ.planeShadow V
  receivedWord_respects_publicShadow :
    ∀ W V : FrameWitness n r,
      P.publicShadow W = P.publicShadow V →
        Γ.receivedWord W = Γ.receivedWord V

namespace PublicShadowRespectGate

/-- Every concrete projection chain respects equality of public Plucker shadows. -/
def of_chain
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) :
    PublicShadowRespectGate Γ where
  committedCochain_respects_publicShadow := by
    intro W V hShadow
    simp [ProjectionChain.Chain.committedCochain, hShadow]
  planeShadow_respects_publicShadow := by
    intro W V hShadow
    simp [ProjectionChain.Chain.planeShadow,
      ProjectionChain.Chain.committedCochain, hShadow]
  receivedWord_respects_publicShadow := by
    intro W V hShadow
    simp [ProjectionChain.Chain.receivedWord, ProjectionChain.Chain.planeShadow,
      ProjectionChain.Chain.committedCochain, hShadow]

/-- Equality in the public quotient gives the same committed cochain. -/
theorem committedCochain_eq_of_publicShadow_eq
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (G : PublicShadowRespectGate Γ)
    {W V : FrameWitness n r}
    (hShadow : P.publicShadow W = P.publicShadow V) :
    Γ.committedCochain W = Γ.committedCochain V :=
  G.committedCochain_respects_publicShadow W V hShadow

/-- Equality in the public quotient gives the same semantic plane shadow. -/
theorem planeShadow_eq_of_publicShadow_eq
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (G : PublicShadowRespectGate Γ)
    {W V : FrameWitness n r}
    (hShadow : P.publicShadow W = P.publicShadow V) :
    Γ.planeShadow W = Γ.planeShadow V :=
  G.planeShadow_respects_publicShadow W V hShadow

/-- Equality in the public quotient gives the same RS received word downstream. -/
theorem receivedWord_eq_of_publicShadow_eq
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (G : PublicShadowRespectGate Γ)
    {W V : FrameWitness n r}
    (hShadow : P.publicShadow W = P.publicShadow V) :
    Γ.receivedWord W = Γ.receivedWord V :=
  G.receivedWord_respects_publicShadow W V hShadow

end PublicShadowRespectGate

/--
Plucker-to-cochain non-collapse gate.

This is the local fidelity gate after the Plucker quotient has been fixed:
source far-ness must remain visible in the committed-cochain local test at the
selected intermediate radius.
-/
structure PluckerToCochainNonCollapseGate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (sourceFarRadius cochainFarRadius : ℝ) : Prop where
  separatesFar :
    ∀ W : FrameWitness n r,
      sourceFarRadius ≤ pluckerDisagreement W →
        cochainFarRadius ≤ L.distanceToCode (Γ.committedCochain W)

/--
Cochain-to-RS far gate.

This is the second far-side separation step: local cochain far-ness must remain
far after plane projection, finite-field encoding, and RS metric evaluation.
-/
structure CochainToRSFarGate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (cochainFarRadius targetFarRadius : ℝ) : Prop where
  separatesFar :
    ∀ W : FrameWitness n r,
      cochainFarRadius ≤ L.distanceToCode (Γ.committedCochain W) →
        targetFarRadius ≤ D.distanceToRS (Γ.receivedWord W)

/--
Two-step far-gate pipeline.

The intermediate cochain radius is explicit so later work can tune the exact
calibration instead of pretending every stage is isometric.
-/
structure FarGatePipeline
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (sourceFarRadius cochainFarRadius targetFarRadius : ℝ) : Prop where
  pluckerToCochain :
    PluckerToCochainNonCollapseGate Γ sourceFarRadius cochainFarRadius
  cochainToRS :
    CochainToRSFarGate Γ cochainFarRadius targetFarRadius

namespace FarGatePipeline

/-- The two far gates compose to the final far-region separation witness. -/
def toFarRegionSeparation
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {sourceFarRadius cochainFarRadius targetFarRadius : ℝ}
    (G : FarGatePipeline Γ sourceFarRadius cochainFarRadius targetFarRadius) :
    FarRegionSeparation
      Γ sourceFarRadius targetFarRadius :=
  FarNonCollapseWitness.of_noncollapse fun W hFar =>
    G.cochainToRS.separatesFar W
      (G.pluckerToCochain.separatesFar W hFar)

end FarGatePipeline

/--
Runtime binding gate for proximity witnesses.

Lean can name the mathematical projection gates; runtime still owns canonical
bytes, domain separation, hash binding, and proof verification.
-/
structure RuntimeBindingGate (R : TCB.RuntimeBoundary) : Prop where
  canonicalEncoding : R.CanonicalEncoding
  domainSeparation : R.DomainSeparation
  hashBindingVerified : R.HashBindingVerified
  proofVerificationSound : R.ProofVerificationSound

namespace RuntimeBindingGate

/-- Runtime binding gate exposes the hash-binding fact needed at the TCB boundary. -/
theorem hash_binding
    {R : TCB.RuntimeBoundary}
    (G : RuntimeBindingGate R) :
    R.HashBindingVerified :=
  G.hashBindingVerified

end RuntimeBindingGate

/--
Structural proximity-gate bundle for a concrete projection chain.

This bundle contains gates that are not alternative proofs of final separation:
pre-chain source/Plucker admissibility, structural respect for the public-shadow
quotient, and semantic alignment. Commitment/sheaf acceptance is established
before this bundle is formed, so the optional converse `SyndromeAdequacyGate`
is not required by the projection chain.
-/
structure StructuralBundle
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) where
  sourceMetric : SourceMetricGate P pluckerDisagreement
  pluckerMetric : PluckerMetricGate P
  publicShadowRespect : PublicShadowRespectGate Γ
  semanticAlignment : SemanticAlignmentGate Γ

namespace StructuralBundle

/-- Structural bundles expose the source metric/disagreement gate. -/
theorem source_metric
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (G : StructuralBundle Γ) :
    SourceMetricGate P pluckerDisagreement :=
  G.sourceMetric

/-- Structural bundles expose the pre-chain Plucker metric/chart gate. -/
def plucker_metric
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (G : StructuralBundle Γ) :
    PluckerMetricGate P :=
  G.pluckerMetric

/-- Structural bundles expose the semantic alignment gate. -/
theorem semantic_alignment
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (G : StructuralBundle Γ) :
    SemanticAlignmentGate Γ :=
  G.semanticAlignment

/-- Structural bundles expose the public-shadow respect gate. -/
def public_shadow_respect
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (G : StructuralBundle Γ) :
    PublicShadowRespectGate Γ :=
  G.publicShadowRespect

end StructuralBundle

/--
Complete proximity-gate bundle for a concrete projection chain and calibration.

This combines structural gates with the chosen final-separation route:
Plucker far -> cochain/local-syndrome far -> RS far. The quotient gate has
already run as part of the structural/post-Plucker phase, so it is not a second
route to the final theorem.
-/
structure Bundle
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (sourceFarRadius cochainFarRadius targetFarRadius : ℝ) where
  structural : StructuralBundle Γ
  farPipeline :
    FarGatePipeline Γ sourceFarRadius cochainFarRadius targetFarRadius

namespace Bundle

/-- A complete proximity-gate bundle yields far-region separation. -/
def toFarRegionSeparation
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {sourceFarRadius cochainFarRadius targetFarRadius : ℝ}
    (G : Bundle Γ sourceFarRadius cochainFarRadius targetFarRadius) :
    FarRegionSeparation
      Γ sourceFarRadius targetFarRadius :=
  G.farPipeline.toFarRegionSeparation

end Bundle

/--
Final structural naturality gate for the assembled projection chain.

This gate is checked only after the Plucker-to-cochain, cochain-to-plane, and
plane-to-RS maps have been fixed.  Commitment acceptance already supplies the
ambient sheaf-coherence and cocycle facts; this later gate carries the distinct
claims that the assembled projection commutes with the selected restriction
and coboundary/syndrome maps.

The two statements remain fields because their concrete typed squares depend
on the source and target restriction interfaces chosen by an instantiation.
-/
structure ProjectionNaturalityGate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) where
  RestrictionNaturality : Prop
  CoboundaryNaturality : Prop
  restrictionNaturality : RestrictionNaturality
  coboundaryNaturality : CoboundaryNaturality

/--
Hard gate certificate for the proximity pipeline.

This is the gate-to-gate invariant certificate. It contains the accumulated
stage certificate plus the earlier hard structural gates. The assembled-chain
naturality check and quantitative metric/radius proofs are appended by later,
thin certificates.
-/
structure HardGateCertificate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) where
  stage : ProjectionStageGateCertificate Γ
  gates : StructuralBundle Γ

namespace HardGateCertificate

/-- A hard gate certificate exposes the accumulated stage certificate. -/
theorem stage_certificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : HardGateCertificate Γ) :
    ProjectionStageGateCertificate Γ :=
  χ.stage

/-- A hard gate certificate exposes the structural hard gates. -/
def structural
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : HardGateCertificate Γ) :
    StructuralBundle Γ :=
  χ.gates

end HardGateCertificate

/--
Thin accumulated certificate for the final structural naturality check.

The previous hard-gate certificate is stored unchanged.  This wrapper appends
only the once-checked naturality gate for the fully assembled projection.
-/
structure NaturalityGateCertificate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement) where
  previous : HardGateCertificate Γ
  naturality : ProjectionNaturalityGate Γ

namespace NaturalityGateCertificate

/-- Append the final structural naturality check to an existing hard certificate. -/
def extend
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : HardGateCertificate Γ)
    (ν : ProjectionNaturalityGate Γ) :
    NaturalityGateCertificate Γ where
  previous := χ
  naturality := ν

/-- Recover the already-checked hard-gate certificate. -/
def hardGateCertificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : NaturalityGateCertificate Γ) :
    HardGateCertificate Γ :=
  χ.previous

/-- Recover the once-checked projection naturality gate. -/
def projectionNaturality
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : NaturalityGateCertificate Γ) :
    ProjectionNaturalityGate Γ :=
  χ.naturality

end NaturalityGateCertificate

/--
Calibrated final proximity certificate.

This is the gate-layer "everything passed" object. It consumes the hard-gate
certificate already extended through the naturality gate, then appends the
final quantitative far-region separation witness for the chosen radius
calibration. The projection orchestrator does not own this object;
statebus/evidence records can carry and bind it.
-/
structure CalibratedFinalCertificate
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (κ : RadiusCalibration) where
  previous : NaturalityGateCertificate Γ
  finalWitness :
    FarRegionSeparation
      Γ κ.sourceFarRadius κ.targetFarRadius

namespace CalibratedFinalCertificate

/-- Extend the naturality-checked chain with explicit final far separation. -/
def of_farRegionSeparation
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : NaturalityGateCertificate Γ)
    (κ : RadiusCalibration)
    (ω :
      FarRegionSeparation
        Γ κ.sourceFarRadius κ.targetFarRadius) :
    CalibratedFinalCertificate Γ κ where
  previous := χ
  finalWitness := ω

/--
Extend hard gates with a two-step far pipeline.

The intermediate cochain radius remains explicit in the far pipeline; the final
certificate records only the calibrated source/target radii.
-/
def of_farPipeline
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (χ : NaturalityGateCertificate Γ)
    (κ : RadiusCalibration)
    {cochainFarRadius : ℝ}
    (G :
      FarGatePipeline
        Γ κ.sourceFarRadius cochainFarRadius κ.targetFarRadius) :
    CalibratedFinalCertificate Γ κ :=
  of_farRegionSeparation χ κ G.toFarRegionSeparation

/-- The final certificate exposes the full hard-gate certificate it extends. -/
def hardGateCertificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    (Ω : CalibratedFinalCertificate Γ κ) :
    HardGateCertificate Γ :=
  Ω.previous.previous

/-- The final certificate exposes the once-checked projection naturality gate. -/
def projectionNaturality
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    (Ω : CalibratedFinalCertificate Γ κ) :
    ProjectionNaturalityGate Γ :=
  Ω.previous.naturality

/-- The final certificate exposes the accumulated projection-stage certificate. -/
def stageCertificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    (Ω : CalibratedFinalCertificate Γ κ) :
    ProjectionStageGateCertificate Γ :=
  Ω.previous.previous.stage

/-- The final certificate exposes the structural hard-gate bundle. -/
def structuralBundle
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    (Ω : CalibratedFinalCertificate Γ κ) :
    StructuralBundle Γ :=
  Ω.previous.previous.gates

/--
Forget down to the projection-chain final gate.

This lower-level certificate intentionally remembers only the accumulated stage
certificate plus the final metric witness. The full naturality and hard-gate
context remains available through `CalibratedFinalCertificate.previous`.
-/
def toProjectionChainFinalGate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    (Ω : CalibratedFinalCertificate Γ κ) :
    CalibratedFinalGateCertificate Γ κ :=
  CalibratedFinalGateCertificate.extend
    Ω.previous.previous.stage κ Ω.finalWitness

/-- The calibrated final certificate gives the final metric/radius check. -/
def finalCheck
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    (Ω : CalibratedFinalCertificate Γ κ) :
    CalibratedFinalCheck
      Γ
      κ.sourceNearRadius
      κ.sourceFarRadius
      κ.targetNearRadius
      κ.targetFarRadius :=
  CalibratedFinalCheck.of_witness
    κ Ω.finalWitness

/-- The calibrated final certificate gives end-to-end proximity readiness. -/
def calibratedReady
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    (Ω : CalibratedFinalCertificate Γ κ) :
    CalibratedEndToEndReady
      Γ
      κ.sourceNearRadius
      κ.sourceFarRadius
      κ.targetNearRadius
      κ.targetFarRadius :=
  Ω.finalCheck.toCalibratedEndToEndReady Ω.previous.previous.stage

end CalibratedFinalCertificate

/--
Certified state bus for one projected witness.

The `state` field carries the witness-local projection payloads and metric
handoffs. The `certificate` field is the single accumulated proof object:
because the calibrated final certificate contains the hard-gate certificate,
and the hard-gate certificate contains the stage certificate, downstream code
can project earlier gates from this object instead of checking or rebuilding
them again.
-/
structure CertifiedStateBus
    (Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement)
    (κ : RadiusCalibration)
    (W : FrameWitness n r) where
  state : StateBus Γ W
  certificate : CalibratedFinalCertificate Γ κ

namespace CertifiedStateBus

/-- Build a certified state bus from the already-aggregated final certificate. -/
def of_certificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    (κ : RadiusCalibration)
    (W : FrameWitness n r)
    (Ω : CalibratedFinalCertificate Γ κ) :
    CertifiedStateBus Γ κ W where
  state := StateBus.of_stageCertificate Ω.stageCertificate W
  certificate := Ω

/-- A certified state bus exposes the already-checked hard-gate certificate. -/
def hardGateCertificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    {W : FrameWitness n r}
    (bus : CertifiedStateBus Γ κ W) :
    HardGateCertificate Γ :=
  bus.certificate.hardGateCertificate

/-- A certified state bus exposes the already-checked stage certificate. -/
def stageCertificate
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    {W : FrameWitness n r}
    (bus : CertifiedStateBus Γ κ W) :
    ProjectionStageGateCertificate Γ :=
  bus.certificate.stageCertificate

/-- A certified state bus exposes the final calibrated readiness witness. -/
def calibratedReady
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    {W : FrameWitness n r}
    (bus : CertifiedStateBus Γ κ W) :
    CalibratedEndToEndReady
      Γ
      κ.sourceNearRadius
      κ.sourceFarRadius
      κ.targetNearRadius
      κ.targetFarRadius :=
  bus.certificate.calibratedReady

/-- The certified state bus retains the composed metric handoff. -/
theorem rsDistance_le_source
    {Γ : ProjectionChain.Chain P S L T D E Φ pluckerDisagreement}
    {κ : RadiusCalibration}
    {W : FrameWitness n r}
    (bus : CertifiedStateBus Γ κ W) :
    D.distanceToRS bus.state.receivedWord ≤ pluckerDisagreement W :=
  bus.state.rsDistance_le_source

end CertifiedStateBus

end Projection

end

end Gates
end Proximity
end Hcrypt
