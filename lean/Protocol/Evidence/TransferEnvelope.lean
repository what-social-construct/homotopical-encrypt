module

public import Protocol.Evidence.TransferVerifier
public import Protocol.Evidence.Transition

@[expose] public section

/-!
# Representing a derived transfer in the existing semantic TCB

The caller first derives candidate validity from concrete resource checks and
the checked packet's indexed signature/payload soundness contracts. This
adapter only represents those already derived facts in the existing semantic
proof-carrying envelope; it supplies no additional verifier-soundness or
runtime-implementation theorem.

The actual compression witness is the candidate paired with its owned
transfer. Its shadow is the projected public intent, and shadow validity means
existence of a matching valid witness with the same payload and interpretation.
The original artifact, proof system and all object-indexed root/inclusion
proofs are retained. No unit witness, always-valid compression or new hash
binding fact is manufactured. The packet's byte-level inclusion is owned by
the operational transfer profile, not inferred from this compatibility bridge.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Evidence.TransferEnvelope

open Sheaf CellularSheaf
open TransferTranscript TransferVerifier

variable {Vertex Edge Face Owner Asset : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}
  {metadata : ProofMetadata}

/-- Already derived mathematics and the actual root/context joins, before TCB packaging. -/
structure Derivation
    (runtime : TCB.RuntimeBoundary)
    (policy : Ledger.Policy ℕ ℕ Asset (CochainPayloadInterpretation F))
    (bindings : RootBindings ℕ ℕ (CochainPayloadInterpretation F))
    (context : Storage.Context F)
    (payload : PayloadVerifier context.interpretation Owner metadata)
    (hashes : HashSuite Owner)
    (project : (Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F) ×
      Ledger.OwnedResource.Transfer Owner) → Intent Owner)
    (candidate : Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F))
    (packet : ProofPacket Owner) where
  transfer : Ledger.OwnedResource.Transfer Owner
  runtime_wellFormed : runtime.WellFormed
  valid : candidate.Valid policy
  action_eq : candidate.action = transfer.action context.cochain
  snapshot_eq : candidate.snapshot = context.interpretation
  project_eq : project (candidate, transfer) = packet.intent
  checkFact : Prop
  checked : checkFact
  beforeRootBound : bindings.stateRoot candidate.before candidate.proposal.beforeStateRoot
  afterRootBound : bindings.stateRoot candidate.after candidate.proposal.afterStateRoot
  transitionDigestBound : bindings.transitionDigest candidate candidate.proposal.blockDigest
  cochainIncluded : bindings.cochainIncluded context.cochain context.artifact.digest
    candidate.proposal.cochainRoot
  artifactIncluded : bindings.artifactIncluded candidate context.artifact
    candidate.proposal.evidenceRoot

namespace Derivation

variable {runtime : TCB.RuntimeBoundary}
  {policy : Ledger.Policy ℕ ℕ Asset (CochainPayloadInterpretation F)}
  {bindings : RootBindings ℕ ℕ (CochainPayloadInterpretation F)}
  {context : Storage.Context F}
  {payload : PayloadVerifier context.interpretation Owner metadata}
  {hashes : HashSuite Owner}
  {project : (Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F) ×
    Ledger.OwnedResource.Transfer Owner) → Intent Owner}
  {candidate : Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F)}
  {packet : ProofPacket Owner}

/-- The actual candidate/transfer projection, with a genuine existential shadow predicate. -/
def compression
    (_D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    TCB.CompressionBoundary.CompressionContract where
  Full := Ledger.Candidate ℕ ℕ (CochainPayloadInterpretation F) ×
    Ledger.OwnedResource.Transfer Owner
  Shadow := Intent Owner
  FullValid := fun witness => witness.1.Valid policy ∧
    witness.1.action = witness.2.action context.cochain ∧
    witness.1.snapshot = context.interpretation
  ShadowValid := fun shadow => ∃ witness,
    project witness = shadow ∧ witness.1.Valid policy ∧
      witness.1.action = witness.2.action context.cochain ∧
      witness.1.snapshot = context.interpretation
  Compresses := fun witness shadow => project witness = shadow
  sound := by
    intro witness shadow projected fullValid
    exact ⟨witness, projected, fullValid⟩
  BindsDigest := fun shadow digest => digest = hashes.intent shadow

def compressed
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    TCB.CompressionBoundary.CompressionContract.CompressedShadow D.compression where
  shadow := packet.intent
  digest := hashes.intent packet.intent
  bindsDigest := rfl

/-- The existing proof carrier records the caller's derived validity/check facts. -/
def proof
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    TCB.ProofCarryingCommittedCochain where
  publicArtifact := context.artifact
  proofSystem := payload.proofSystem
  statement := candidate.Valid policy
  VerifiesStatement := D.checkFact

theorem proof_wellFormed
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    D.proof.WellFormed :=
  ⟨context.artifactWellFormed, payload.proofSystem_wellFormed, D.valid, D.checked⟩

def observation
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    TCB.ObservationBoundary.ObservedStatement runtime where
  artifact := D.proof
  publicStatement := candidate.Valid policy
  accepted := by
    rcases D.runtime_wellFormed with
      ⟨canonical, _, domain, hashBinding, proofSound, _, _, _⟩
    exact ⟨canonical, domain, hashBinding, proofSound, D.proof_wellFormed⟩
  statementImpliesPublic := fun valid => valid

/-- Preserve the real witness, projected shadow, original artifact and computed root names. -/
def envelope
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    TCB.WitnessVerifier.WitnessVerifierEnvelope runtime where
  K := D.compression
  witness :=
    { witness := (candidate, D.transfer)
      compressed := D.compressed
      compresses := D.project_eq
      witnessValid := ⟨D.valid, D.action_eq, D.snapshot_eq⟩ }
  proof := D.proof
  observation := D.observation
  proofCarriesShadow :=
    { compressed := D.compressed
      statementImpliesShadowValid := fun valid =>
        ⟨(candidate, D.transfer), D.project_eq, valid, D.action_eq, D.snapshot_eq⟩ }
  proofCarriesWitnessShadow := rfl
  observationUsesProof := rfl
  stateUpdate :=
    { beforeRoot := candidate.proposal.beforeStateRoot
      afterRoot := candidate.proposal.afterStateRoot
      transitionDigest := candidate.proposal.blockDigest
      BindsPublicInputs :=
        bindings.stateRoot candidate.before candidate.proposal.beforeStateRoot ∧
        bindings.stateRoot candidate.after candidate.proposal.afterStateRoot ∧
        bindings.transitionDigest candidate candidate.proposal.blockDigest
      DomainSeparated := runtime.DomainSeparation }
  stateUpdateWellFormed :=
    ⟨⟨D.beforeRootBound, D.afterRootBound, D.transitionDigestBound⟩,
      D.runtime_wellFormed.2.2.1⟩

/-- Package independently derived validity into the existing candidate-indexed evidence. -/
def toEvidence
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    Transition runtime policy bindings candidate where
  envelope := D.envelope
  statementMatches := rfl
  payloadMatches := (congrArg Ledger.Action.cochain D.action_eq).symm
  beforeRootMatches := rfl
  afterRootMatches := rfl
  transitionDigestMatches := rfl
  beforeRootBound := D.beforeRootBound
  afterRootBound := D.afterRootBound
  transitionDigestBound := D.transitionDigestBound
  cochainIncluded := by
    change bindings.cochainIncluded candidate.action.cochain context.artifact.digest
      candidate.proposal.cochainRoot
    rw [D.action_eq]
    exact D.cochainIncluded
  artifactIncluded := D.artifactIncluded

theorem toEvidence_artifact
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    D.toEvidence.envelope.proof.publicArtifact = context.artifact := rfl

theorem toEvidence_witness
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    D.toEvidence.envelope.witness.witness = (candidate, D.transfer) := rfl

theorem toEvidence_shadow
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    D.toEvidence.envelope.witness.compressed.shadow = packet.intent := rfl

/-- The compatibility object yields the already-derived actual computed update. -/
theorem toAcceptedUpdate
    (D : Derivation runtime policy bindings context payload hashes project candidate packet) :
    Ledger.AcceptedUpdate policy candidate.before candidate candidate.after :=
  D.toEvidence.toAcceptedUpdate

end Derivation

end Hcrypt.Protocol.Evidence.TransferEnvelope
