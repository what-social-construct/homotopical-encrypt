module

public import Protocol.Storage.Checkpoint
public import Sheaf.CochainSemantics
public import Proximity.Concrete.Public

@[expose] public section

/-!
# The existing projection and gate levels in one storage context

The payloads below are the existing nested mathematical states and evidence
records. Advancing a prefix retains its exact predecessor. Storage names and
hashes authenticate these objects; they do not replace or manufacture their
proofs. The snapshot, artifact leaf and eventual manifest root remain distinct.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage.Projection

open Sheaf CellularSheaf
open HomotopicalEncryption.Proximity
open HomotopicalEncryption.Proximity.GrassmannianPlucker
open HomotopicalEncryption.Proximity.Gates.Projection
open HomotopicalEncryption.Proximity.GateEvidence.Projection

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {Fsheaf : CellularSheaf X}
  {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}
  {R K ι : Type} [Field K] [Fintype K] [Fintype ι] [DecidableEq K]
  {P : FramedSystem n r} {S : Axioms.SheafCoherence}
  {L : PluckerCochain.LocalSyndromeTarget S}
  {T : ReedSolomonTarget.Target K ι}
  {D : ReedSolomonTarget.Target.ReceivedWordMetric T}
  {E : CochainPlane.PlaneExtractionContext R ι}
  {Φ : CochainReedSolomon.PlaneEncoding R K}
  {sourceDisagreement : FrameWitness n r → ℝ}

/-- The actual legacy-chain semantics and payload identified with the fixed snapshot. -/
structure Input
    (C : Context Fsheaf)
    (Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement)
    (W : FrameWitness n r) where
  semantics : CochainSemantics C.interpretation S
  cochainMatches : Γ.committedCochain W = C.cochain

namespace Input

variable {C : Context Fsheaf}
  {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
  {W : FrameWitness n r}

/-- Concrete and legacy acceptance agree only with the stated ambient coherence. -/
theorem accepted_iff (input : Input C Γ W)
    (hS : Axioms.SheafCoherenceWellFormed S) :
    C.Accepted ↔ CochainBridge.CommittedCochain.AcceptedCocycle S
      (Γ.committedCochain W) := by
  simpa only [Context.Accepted, CochainBridge.CommittedCochain.AcceptedCocycle,
    input.cochainMatches] using
    input.semantics.accepted_iff hS C.cochain

/-- A valid source frame gives acceptance of this same stored payload. -/
theorem accepted_of_validFrame (input : Input C Γ W)
    (hW : PluckerCochain.ValidFrame P W) : C.Accepted := by
  have h := Γ.pluckerToCochain.preservesValidFrame W hW
  change CochainBridge.CommittedCochain.GlobalSectionCandidate S
    (Γ.committedCochain W) at h
  rw [input.cochainMatches] at h
  exact ((input.semantics.accepted_and_ambient_iff C.cochain).2 h).1

/-- Every existing RS state bus retains the fixed input cochain. -/
theorem state_cochain_matches (input : Input C Γ W) (bus : StateBus Γ W) :
    bus.committedCochain = C.cochain :=
  bus.previous.previous.committedCochain_matches.trans input.cochainMatches

theorem state_plane_matches (input : Input C Γ W) (bus : StateBus Γ W) :
    bus.planeShadow = E.projectedPlane C.cochain := by
  exact bus.previous.planeShadow_matches.trans
    (congrArg E.projectedPlane (input.state_cochain_matches bus))

theorem state_word_matches (input : Input C Γ W) (bus : StateBus Γ W) :
    bus.receivedWord = Φ.receivedWord (E.projectedPlane C.cochain) :=
  bus.receivedWord_matches.trans
    (congrArg Φ.receivedWord (input.state_plane_matches bus))

/-- A public plane view is joined by its actual original public artifact. -/
theorem public_plane_matches (input : Input C Γ W)
    {runtime : TCB.RuntimeBoundary}
    (view : CochainPlane.PublicBinding.PlaneView runtime E)
    (hArtifact : view.observation.artifact.publicArtifact = C.artifact) :
    view.planeShadow = Γ.planeShadow W := by
  have hc : view.observation.cochain = C.cochain :=
    congrArg TCB.HashedCommittedCochain.cochain hArtifact
  exact view.planeMatchesCochain.trans
    ((congrArg E.projectedPlane hc).trans
      (congrArg E.projectedPlane input.cochainMatches).symm)

end Input

/-- Three projection checkpoints followed by the existing three evidence levels. -/
inductive Stage where
  | cochain | plane | rs | hard | naturality | final
  deriving DecidableEq

instance : Fintype Stage where
  elems := {.cochain, .plane, .rs, .hard, .naturality, .final}
  complete stage := by cases stage <;> simp

/-- Each slot retains the actual existing mathematical type. -/
def Payload (runtime : TCB.RuntimeBoundary)
    (Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement)
    (κ : RadiusCalibration) (W : FrameWitness n r) : Stage → Type
  | .cochain => PluckerCochainState Γ W
  | .plane => CochainPlaneState Γ W
  | .rs => StateBus Γ W
  | .hard => HardGateEvidenceRecord runtime Γ
  | .naturality => NaturalityGateEvidenceRecord runtime Γ
  | .final => CalibratedFinalEvidenceRecord runtime Γ κ

variable {C : Context Fsheaf}
  {Γ : ProjectionChain.Chain P S L T D E Φ sourceDisagreement}
  {W : FrameWitness n r}

/-- An incremental prefix owns exactly the already-reached mathematical level. -/
inductive Prefix (input : Input C Γ W) (runtime : TCB.RuntimeBoundary)
    (κ : RadiusCalibration) where
  | initial
  | cochain (state : PluckerCochainState Γ W)
  | plane (state : CochainPlaneState Γ W)
  | rs (state : StateBus Γ W)
  | hard (state : StateBus Γ W) (record : HardGateEvidenceRecord runtime Γ)
  | naturality (state : StateBus Γ W)
      (record : NaturalityGateEvidenceRecord runtime Γ)
  | final (state : StateBus Γ W)
      (record : CalibratedFinalEvidenceRecord runtime Γ κ)

namespace Prefix

variable {input : Input C Γ W} {runtime : TCB.RuntimeBoundary}
  {κ : RadiusCalibration}

def count : Prefix input runtime κ → ℕ
  | .initial => 0
  | .cochain _ => 1
  | .plane _ => 2
  | .rs _ => 3
  | .hard _ _ => 4
  | .naturality _ _ => 5
  | .final _ _ => 6

/-- The exact leaves at this prefix, retaining each nested predecessor. -/
def items (digests : Stage → TCB.Hash32) : Prefix input runtime κ →
    List (ManifestItem Stage (Payload runtime Γ κ W))
  | .initial => []
  | .cochain s => [⟨.cochain, s, digests .cochain⟩]
  | .plane s =>
      [⟨.cochain, s.previous, digests .cochain⟩, ⟨.plane, s, digests .plane⟩]
  | .rs s =>
      [⟨.cochain, s.previous.previous, digests .cochain⟩,
       ⟨.plane, s.previous, digests .plane⟩, ⟨.rs, s, digests .rs⟩]
  | .hard s h =>
      [⟨.cochain, s.previous.previous, digests .cochain⟩,
       ⟨.plane, s.previous, digests .plane⟩, ⟨.rs, s, digests .rs⟩,
       ⟨.hard, h, digests .hard⟩]
  | .naturality s h =>
      [⟨.cochain, s.previous.previous, digests .cochain⟩,
       ⟨.plane, s.previous, digests .plane⟩, ⟨.rs, s, digests .rs⟩,
       ⟨.hard, h.hardGateRecord, digests .hard⟩,
       ⟨.naturality, h, digests .naturality⟩]
  | .final s h =>
      [⟨.cochain, s.previous.previous, digests .cochain⟩,
       ⟨.plane, s.previous, digests .plane⟩, ⟨.rs, s, digests .rs⟩,
       ⟨.hard, h.naturalityGateRecord.hardGateRecord, digests .hard⟩,
       ⟨.naturality, h.naturalityGateRecord, digests .naturality⟩,
       ⟨.final, h, digests .final⟩]

theorem length_items (digests : Stage → TCB.Hash32) (p : Prefix input runtime κ) :
    (p.items digests).length = p.count := by
  cases p <;> rfl

theorem slots_nodup (digests : Stage → TCB.Hash32) (p : Prefix input runtime κ) :
    ((p.items digests).map ManifestItem.slot).Nodup := by
  cases p <;> simp [items]

/-- Store a reached prefix after authenticating each actual payload/digest leaf. -/
def toOpenManifest {Receipt : Type*}
    (scheme : CheckpointScheme Fsheaf Stage (Payload runtime Γ κ W) Receipt)
    (p : Prefix input runtime κ) (digests : Stage → TCB.Hash32)
    (bound : ∀ item ∈ p.items digests,
      scheme.entryBound C item.slot item.payload item.digest) :
    OpenManifest scheme C where
  entries := (p.items digests).attach.map fun item =>
    ⟨item.val, bound item.val item.property⟩
  slotsNodup := by
    rw [List.map_map]
    change ((p.items digests).attach.map fun item => item.val.slot).Nodup
    rw [List.attach_map_val]
    exact p.slots_nodup digests

theorem items_toOpenManifest {Receipt : Type*}
    (scheme : CheckpointScheme Fsheaf Stage (Payload runtime Γ κ W) Receipt)
    (p : Prefix input runtime κ) (digests : Stage → TCB.Hash32)
    (bound : ∀ item ∈ p.items digests,
      scheme.entryBound C item.slot item.payload item.digest) :
    (toOpenManifest scheme p digests bound).items = p.items digests := by
  unfold OpenManifest.items toOpenManifest
  rw [List.map_map]
  exact List.attach_map_subtype_val _

theorem slots_toOpenManifest {Receipt : Type*}
    (scheme : CheckpointScheme Fsheaf Stage (Payload runtime Γ κ W) Receipt)
    (p : Prefix input runtime κ) (digests : Stage → TCB.Hash32)
    (bound : ∀ item ∈ p.items digests,
      scheme.entryBound C item.slot item.payload item.digest) :
    (toOpenManifest scheme p digests bound).slots =
      (p.items digests).map ManifestItem.slot := by
  unfold OpenManifest.slots toOpenManifest
  rw [List.map_map]
  exact List.attach_map_val

theorem final_has_all_slots (state : StateBus Γ W)
    (record : CalibratedFinalEvidenceRecord runtime Γ κ)
    (digests : Stage → TCB.Hash32) (stage : Stage) :
    stage ∈ ((Prefix.final state record : Prefix input runtime κ).items digests).map
      ManifestItem.slot := by
  cases stage <;> simp [items]

/-- Progression checks exact stored predecessors, not just matching stage labels. -/
inductive Step : Prefix input runtime κ → Prefix input runtime κ → Prop where
  | cochain (s : PluckerCochainState Γ W) : Step .initial (.cochain s)
  | plane (s : PluckerCochainState Γ W) (t : CochainPlaneState Γ W)
      (previous : t.previous = s) : Step (.cochain s) (.plane t)
  | rs (s : CochainPlaneState Γ W) (t : StateBus Γ W)
      (previous : t.previous = s) : Step (.plane s) (.rs t)
  | hard (s : StateBus Γ W) (h : HardGateEvidenceRecord runtime Γ) :
      Step (.rs s) (.hard s h)
  | naturality (s : StateBus Γ W) (h : HardGateEvidenceRecord runtime Γ)
      (t : NaturalityGateEvidenceRecord runtime Γ)
      (previous : t.hardGateRecord = h) : Step (.hard s h) (.naturality s t)
  | final (s : StateBus Γ W) (h : NaturalityGateEvidenceRecord runtime Γ)
      (t : CalibratedFinalEvidenceRecord runtime Γ κ)
      (previous : t.naturalityGateRecord = h) : Step (.naturality s h) (.final s t)

theorem count_step {before after : Prefix input runtime κ} (h : Step before after) :
    after.count = before.count + 1 := by
  cases h <;> rfl

/-- Every stage appends one exact leaf and leaves the earlier leaf list unchanged. -/
theorem items_append_of_step (digests : Stage → TCB.Hash32)
    {before after : Prefix input runtime κ} (h : Step before after) :
    ∃ item, after.items digests = before.items digests ++ [item] := by
  cases h with
  | cochain s => exact ⟨⟨.cochain, s, digests .cochain⟩, rfl⟩
  | plane s t previous =>
    exact ⟨⟨.plane, t, digests .plane⟩, by simp [items, previous]⟩
  | rs s t previous =>
    exact ⟨⟨.rs, t, digests .rs⟩, by simp [items, previous]⟩
  | hard s h => exact ⟨⟨.hard, h, digests .hard⟩, rfl⟩
  | naturality s h t previous =>
    exact ⟨⟨.naturality, t, digests .naturality⟩, by simp [items, previous]⟩
  | final s h t previous =>
    exact ⟨⟨.final, t, digests .final⟩, by simp [items, previous]⟩

theorem no_step_from_final (s : StateBus Γ W)
    (record : CalibratedFinalEvidenceRecord runtime Γ κ)
    {after : Prefix input runtime κ} : ¬ Step (.final s record) after := by
  intro h
  cases h

end Prefix

/-- A seal is coherent only when its exact list comes from one final typed prefix. -/
structure SealedProjection
    (input : Input C Γ W) (runtime : TCB.RuntimeBoundary) (κ : RadiusCalibration)
    {Receipt : Type*}
    (scheme : CheckpointScheme Fsheaf Stage (Payload runtime Γ κ W) Receipt) where
  state : StateBus Γ W
  evidence : CalibratedFinalEvidenceRecord runtime Γ κ
  digests : Stage → TCB.Hash32
  sealed : SealedManifest scheme C
  itemsMatch : sealed.manifest.items =
    (Prefix.final state evidence : Prefix input runtime κ).items digests

namespace SealedProjection

variable {input : Input C Γ W} {runtime : TCB.RuntimeBoundary}
  {κ : RadiusCalibration} {Receipt : Type*}
  {scheme : CheckpointScheme Fsheaf Stage (Payload runtime Γ κ W) Receipt}

/-- Seal the exact final prefix after binding each real leaf and the whole manifest. -/
def sealFinalPrefix (state : StateBus Γ W)
    (evidence : CalibratedFinalEvidenceRecord runtime Γ κ)
    (digests : Stage → TCB.Hash32)
    (leafBound : ∀ item ∈
      (Prefix.final state evidence : Prefix input runtime κ).items digests,
      scheme.entryBound C item.slot item.payload item.digest)
    (root : TCB.Hash32)
    (manifestBound : scheme.manifestBound C
      ((Prefix.final state evidence : Prefix input runtime κ).items digests) root) :
    SealedProjection input runtime κ scheme := by
  let stagePrefix : Prefix input runtime κ := .final state evidence
  let manifest := Prefix.toOpenManifest scheme stagePrefix digests leafBound
  refine
    { state := state
      evidence := evidence
      digests := digests
      sealed :=
        { manifest := manifest
          root := root
          complete := ?_
          rootBound := ?_ }
      itemsMatch := ?_ }
  · intro stage _
    change stage ∈ (Prefix.toOpenManifest scheme stagePrefix digests leafBound).slots
    rw [Prefix.slots_toOpenManifest]
    exact Prefix.final_has_all_slots state evidence digests stage
  · change scheme.manifestBound C
      (Prefix.toOpenManifest scheme stagePrefix digests leafBound).items root
    rw [Prefix.items_toOpenManifest]
    exact manifestBound
  · change (Prefix.toOpenManifest scheme stagePrefix digests leafBound).items = _
    exact Prefix.items_toOpenManifest scheme stagePrefix digests leafBound

theorem cochain_matches
    (block : SealedProjection input runtime κ scheme) :
    block.state.committedCochain = C.cochain :=
  input.state_cochain_matches block.state

theorem word_matches
    (block : SealedProjection input runtime κ scheme) :
    block.state.receivedWord = Φ.receivedWord (E.projectedPlane C.cochain) :=
  input.state_word_matches block.state

/-- The stored final theorem is recovered from the existing gate evidence. -/
def finalCertificate (block : SealedProjection input runtime κ scheme) :
    CalibratedFinalCertificate Γ κ := block.evidence.finalCertificate

/-- Recover the original certified state-bus type with the exact stored state. -/
def certifiedStateBus (block : SealedProjection input runtime κ scheme) :
    CertifiedStateBus Γ κ W where
  state := block.state
  certificate := block.finalCertificate

/-- Storage consumes the supplied far-region proof; persistence does not prove it. -/
theorem target_far (block : SealedProjection input runtime κ scheme)
    (hfar : κ.sourceFarRadius ≤ sourceDisagreement W) :
    κ.targetFarRadius ≤ D.distanceToRS block.state.receivedWord := by
  have hword : block.state.receivedWord = Γ.receivedWord W :=
    block.word_matches.trans
      (congrArg (fun c => Φ.receivedWord (E.projectedPlane c)) input.cochainMatches).symm
  rw [hword]
  exact block.evidence.finalWitness.noncollapse W hfar

end SealedProjection
end HomotopicalEncryption.Protocol.Storage.Projection
