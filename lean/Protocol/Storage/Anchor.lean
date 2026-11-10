module

public import Protocol.Storage.Checkpoint
public import Protocol.Ledger.Sheaf
public import Protocol.Ledger.Certified

@[expose] public section

/-!
# One accepted history entry and its original storage context

The adapter below joins existing candidate evidence to the same sheaf
interpretation, original public artifact and exact sealed manifest. It derives
acceptance and the existing root inclusions rather than assuming them again.

`HistoryBindings` is an explicit application/runtime authentication contract.
It can bind the manifest through an authenticated block body or a dedicated
coordinate without choosing either wire format here. A concrete hash preimage
must exclude its own digest fields. No collision-resistance, persistence,
global run freshness, geometry migration or finality theorem is inferred.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage

open Sheaf CellularSheaf

universe u v w

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- Authentication of an actual ordered manifest under the same history entry. -/
structure HistoryBindings (F : CellularSheaf X)
    (Resource Nullifier : Type) (Slot : Type u) (Payload : Slot → Type v) where
  manifestIncluded :
    Ledger.Candidate Resource Nullifier (CochainPayloadInterpretation F) →
    Context F → List (ManifestItem Slot Payload) →
    TCB.Hash32 → TCB.Hash32 → Prop

variable {F : CellularSheaf X}
  {Resource Nullifier Asset : Type} [DecidableEq Nullifier]
  {Slot : Type u} {Payload : Slot → Type v} {Receipt : Type w}
  {runtime : TCB.RuntimeBoundary}
  {P : Ledger.Policy Resource Nullifier Asset (CochainPayloadInterpretation F)}
  {bindings : Evidence.RootBindings Resource Nullifier (CochainPayloadInterpretation F)}
  {candidate : Ledger.Candidate Resource Nullifier (CochainPayloadInterpretation F)}
  {scheme : CheckpointScheme F Slot Payload Receipt}

/--
An existing evidence-bearing transition anchored to its exact storage context.

The interpretation and artifact equalities are about actual objects, not
merely equality of their hashes. The final premise authenticates the exact
context, ordered leaves and manifest root through this candidate's block digest.
-/
structure TransitionAnchor
    (topologyBinds : SheafStateSnapshot F → TCB.Hash32 → Prop)
    (history : HistoryBindings F Resource Nullifier Slot Payload)
    (evidence : Evidence.Transition runtime P bindings candidate)
    (C : Context F) (manifest : SealedManifest scheme C) where
  policySnapshots : P.snapshots = Ledger.SnapshotModel.ofSheaf F topologyBinds
  snapshotMatches : candidate.snapshot = C.interpretation
  artifactMatches : evidence.envelope.proof.publicArtifact = C.artifact
  manifestIncluded : history.manifestIncluded candidate C manifest.manifest.items
    manifest.root candidate.proposal.blockDigest

namespace TransitionAnchor

variable {topologyBinds : SheafStateSnapshot F → TCB.Hash32 → Prop}
  {history : HistoryBindings F Resource Nullifier Slot Payload}
  {evidence : Evidence.Transition runtime P bindings candidate}
  {C : Context F} {manifest : SealedManifest scheme C}

/-- Candidate and storage retain the same original wire payload. -/
theorem cochain_matches
    (A : TransitionAnchor topologyBinds history evidence C manifest) :
    candidate.action.cochain = C.cochain :=
  evidence.proof_cochain_eq.symm.trans
    (congrArg TCB.HashedCommittedCochain.cochain A.artifactMatches)

/-- Snapshot-bound exactness follows from the existing candidate evidence. -/
theorem accepted
    (A : TransitionAnchor topologyBinds history evidence C manifest) :
    C.Accepted := by
  have h := evidence.valid.snapshotAccepted
  rw [A.policySnapshots] at h
  change AcceptedCommittedOneCochain candidate.snapshot candidate.action.cochain at h
  rw [A.snapshotMatches, A.cochain_matches] at h
  exact h

/-- The proposal names the same snapshot as the stored original artifact. -/
theorem snapshot_root_matches
    (A : TransitionAnchor topologyBinds history evidence C manifest) :
    candidate.proposal.snapshotRoot = C.key.snapshotRoot := by
  have h := evidence.valid.snapshotMatches
  rw [A.policySnapshots] at h
  change candidate.proposal.snapshotRoot = candidate.snapshot.snapshot.root at h
  rw [A.snapshotMatches] at h
  exact h

/-- The selected topology-root relation uses that very snapshot. -/
theorem topology_bound
    (A : TransitionAnchor topologyBinds history evidence C manifest) :
    topologyBinds C.interpretation.snapshot candidate.proposal.topologyRoot := by
  have h := evidence.valid.topologyBound
  rw [A.policySnapshots] at h
  change topologyBinds candidate.snapshot.snapshot candidate.proposal.topologyRoot at h
  rw [A.snapshotMatches] at h
  exact h

/-- The public artifact's leaf digest is preserved along the context join. -/
theorem artifact_digest_matches
    (A : TransitionAnchor topologyBinds history evidence C manifest) :
    evidence.envelope.proof.publicArtifact.digest = C.artifact.digest :=
  congrArg TCB.HashedCommittedCochain.digest A.artifactMatches

/-- The enclosing cochain root includes this payload and its distinct leaf digest. -/
theorem cochain_included
    (A : TransitionAnchor topologyBinds history evidence C manifest) :
    bindings.cochainIncluded C.cochain C.artifact.digest
      candidate.proposal.cochainRoot := by
  have h := evidence.cochainIncluded
  rw [A.cochain_matches, A.artifact_digest_matches] at h
  exact h

/-- Existing candidate evidence includes the same public artifact. -/
theorem artifact_included
    (A : TransitionAnchor topologyBinds history evidence C manifest) :
    bindings.artifactIncluded candidate C.artifact candidate.proposal.evidenceRoot := by
  rw [← A.artifactMatches]
  exact evidence.artifactIncluded

/-- The exact list/root is both sealed and authenticated by this history entry. -/
theorem manifest_anchored
    (A : TransitionAnchor topologyBinds history evidence C manifest) :
    scheme.manifestBound C manifest.manifest.items manifest.root ∧
      history.manifestIncluded candidate C manifest.manifest.items
        manifest.root candidate.proposal.blockDigest :=
  ⟨manifest.rootBound, A.manifestIncluded⟩

/-- The anchored transition uses the already-computed conservative update. -/
theorem toAcceptedUpdate
    (_A : TransitionAnchor topologyBinds history evidence C manifest) :
    Ledger.AcceptedUpdate P candidate.before candidate candidate.after :=
  evidence.toAcceptedUpdate

/-- Anchored accepted payloads are on the decoded exactness locus. -/
theorem decodedDistance_eq_zero
    (A : TransitionAnchor topologyBinds history evidence C manifest) :
    C.decodedDistance = 0 :=
  C.accepted_iff_decodedDistance_eq_zero.mp A.accepted

/-- Sealing/anchoring alone does not establish persistence: the receipt is required. -/
theorem persisted
    (_A : TransitionAnchor topologyBinds history evidence C manifest)
    (receipt : PersistenceReceipt manifest) :
    scheme.persisted C manifest.manifest.items manifest.root receipt.receipt :=
  receipt.persisted

/-- A different interpretation cannot be substituted, even with a named root. -/
theorem not_of_snapshot_ne
    (hMismatch : candidate.snapshot ≠ C.interpretation) :
    ¬ Nonempty (TransitionAnchor topologyBinds history evidence C manifest) := by
  rintro ⟨A⟩
  exact hMismatch A.snapshotMatches

/-- A different public artifact cannot replace the original commitment. -/
theorem not_of_artifact_ne
    (hMismatch : evidence.envelope.proof.publicArtifact ≠ C.artifact) :
    ¬ Nonempty (TransitionAnchor topologyBinds history evidence C manifest) := by
  rintro ⟨A⟩
  exact hMismatch A.artifactMatches

/-- An unrelated valid seal is unusable without this exact history inclusion. -/
theorem not_of_manifest_not_included
    (hMissing : ¬ history.manifestIncluded candidate C manifest.manifest.items
      manifest.root candidate.proposal.blockDigest) :
    ¬ Nonempty (TransitionAnchor topologyBinds history evidence C manifest) := by
  rintro ⟨A⟩
  exact hMissing A.manifestIncluded

variable {ValidatorId : Type*} [DecidableEq ValidatorId] {Signature : Type*}
  {committee : Consensus.Committee ValidatorId}
  {authentication : Consensus.VoteAuthentication ValidatorId Signature}

/-- A matching acceptance quorum signs the digest authenticating this exact manifest. -/
theorem quorum_manifest_anchored
    (certified : Ledger.CertifiedTransition runtime P bindings candidate committee authentication)
    (A : TransitionAnchor topologyBinds history certified.evidence C manifest) :
    history.manifestIncluded candidate C manifest.manifest.items manifest.root
      certified.quorum.target.proposal.blockDigest := by
  rw [certified.proposalMatches]
  exact A.manifestIncluded

/-- The same quorum's snapshot coordinate names the original storage snapshot. -/
theorem quorum_snapshot_matches
    (certified : Ledger.CertifiedTransition runtime P bindings candidate committee authentication)
    (A : TransitionAnchor topologyBinds history certified.evidence C manifest) :
    certified.quorum.target.proposal.snapshotRoot = C.key.snapshotRoot := by
  rw [certified.proposalMatches]
  exact A.snapshot_root_matches

end TransitionAnchor
end HomotopicalEncryption.Protocol.Storage
