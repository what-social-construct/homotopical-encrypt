module

public import Protocol.Storage.Checkpoint

@[expose] public section

/-!
# Concrete payload/plane checkpoint fixtures

One loop edge has a two-dimensional stalk and zero degree-zero coboundary.
The decoder reads the original integer edge list into real coordinates.
Thus the shape/snapshot-bound payload `[1,0]` is genuinely nonexact, whereas
`[0,0]` is accepted. Storage checkpoints are available for both raw inputs.

The authentication and backend receipt profile is an explicit equality model
for these tests. It provides neither cryptographic security nor disk durability.
No projection-chain or far-separation theorem is assumed by the fixture.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Storage.Examples

open Sheaf CellularSheaf

def hash (byte : UInt8) : TCB.Hash32 := fun _ => byte

def complex : OrientedTwoComplex Unit Unit Empty where
  incidence01 _ _ := 0
  incidence12 _ face := Empty.elim face
  boundarySqZero _ face := Empty.elim face

def sheaf : CellularSheaf complex where
  vertexDim _ := 1
  edgeDim _ := 2
  faceDim face := Empty.elim face
  restrict01 _ _ := 0
  restrict12 _ face := Empty.elim face
  restrict02 _ face := Empty.elim face
  restrictionComp _ _ face := Empty.elim face

theorem delta0_zero (a : sheaf.C0) : sheaf.delta0 a = 0 := by
  ext coordinate
  simp [CellularSheaf.delta0, CellularSheaf.assemble, CellularSheaf.delta0At,
    OrientedTwoComplex.incidence01Real, complex]

def topologyTag : Fin 16 → UInt8 := fun _ => 7

def rawPayload : Axioms.CochainCommitmentData where
  modulus := Axioms.canonicalCochainModulus
  n_edge_values := 2
  edge_values := [1, 0]
  topology_hash := topologyTag

def zeroPayload : Axioms.CochainCommitmentData where
  modulus := Axioms.canonicalCochainModulus
  n_edge_values := 2
  edge_values := [0, 0]
  topology_hash := topologyTag

theorem rawPayload_wellFormed : rawPayload.WellFormed := by
  simp [Axioms.CochainCommitmentData.WellFormed,
    Axioms.CochainCommitmentData.SupportedModulus,
    Axioms.CochainCommitmentData.EdgeCountMatches,
    Axioms.CochainCommitmentData.NonemptyEdges, rawPayload]

theorem zeroPayload_wellFormed : zeroPayload.WellFormed := by
  simp [Axioms.CochainCommitmentData.WellFormed,
    Axioms.CochainCommitmentData.SupportedModulus,
    Axioms.CochainCommitmentData.EdgeCountMatches,
    Axioms.CochainCommitmentData.NonemptyEdges, zeroPayload]

def snapshot : SheafStateSnapshot sheaf where
  schemaVersion := 1
  root := hash 10
  topologyHash := topologyTag
  CanonicallyEncoded := True
  RootBindsCellularSheaf := True

/-- Actual list coordinates are interpreted as real cochain coordinates. -/
def interpretation : CochainPayloadInterpretation sheaf where
  snapshot := snapshot
  decode c := WithLp.toLp 2 fun coordinate =>
    (c.edge_values.getD coordinate.2.val 0 : ℝ)
  PayloadBindsSnapshot c := c = rawPayload ∨ c = zeroPayload

theorem coordinateCount : sheaf.edgeCoordinateCount = 2 := by
  change Fintype.card (Σ _ : Unit, Fin 2) = 2
  simp [Fintype.card_sigma]

theorem raw_bound : interpretation.BoundToSnapshot rawPayload := by
  refine ⟨⟨True.intro, True.intro⟩, ?_, rfl, Or.inl rfl⟩
  exact coordinateCount.symm

theorem zero_bound : interpretation.BoundToSnapshot zeroPayload := by
  refine ⟨⟨True.intro, True.intro⟩, ?_, rfl, Or.inr rfl⟩
  exact coordinateCount.symm

/-- An object/digest-indexed equality profile, used only for this fixture. -/
def leafBinds (c : Axioms.CochainCommitmentData) (digest : TCB.Hash32) : Prop :=
  (c = rawPayload ∧ digest = hash 11) ∨
    (c = zeroPayload ∧ digest = hash 12)

def rawArtifact : TCB.HashedCommittedCochain where
  cochain := rawPayload
  digest := hash 11
  Binds := leafBinds rawPayload (hash 11)

def zeroArtifact : TCB.HashedCommittedCochain where
  cochain := zeroPayload
  digest := hash 12
  Binds := leafBinds zeroPayload (hash 12)

def rawContext : Context sheaf where
  interpretation := interpretation
  artifact := rawArtifact
  artifactWellFormed := ⟨rawPayload_wellFormed, Or.inl ⟨rfl, rfl⟩⟩
  boundToSnapshot := raw_bound
  runId := hash 20
  parameterSet := hash 30

def zeroContext : Context sheaf where
  interpretation := interpretation
  artifact := zeroArtifact
  artifactWellFormed := ⟨zeroPayload_wellFormed, Or.inr ⟨rfl, rfl⟩⟩
  boundToSnapshot := zero_bound
  runId := hash 22
  parameterSet := hash 30

def otherRun : Context sheaf := { rawContext with runId := hash 21 }

theorem raw_decoded_first_coordinate :
    rawContext.interpretation.decode rawContext.cochain ⟨(), (0 : Fin 2)⟩ = 1 := by
  norm_num [rawContext, Context.cochain, rawArtifact, interpretation, rawPayload]

theorem raw_not_accepted : ¬ rawContext.Accepted := by
  intro h
  obtain ⟨a, ha⟩ := h.representsExact
  have hz : rawContext.interpretation.decode rawContext.cochain = 0 :=
    ha.trans (delta0_zero a)
  have hfirst := congrArg (fun y : sheaf.C1 => y ⟨(), (0 : Fin 2)⟩) hz
  rw [raw_decoded_first_coordinate] at hfirst
  norm_num at hfirst

/-- A genuinely positive geometric source distance exists among raw contexts. -/
theorem raw_decodedDistance_pos : 0 < rawContext.decodedDistance := by
  have hne : rawContext.decodedDistance ≠ 0 := by
    intro hzero
    exact raw_not_accepted (rawContext.accepted_iff_decodedDistance_eq_zero.mpr hzero)
  exact lt_of_le_of_ne rawContext.decodedDistance_nonneg hne.symm

theorem zero_accepted : zeroContext.Accepted := by
  refine ⟨zeroPayload_wellFormed, zero_bound, 0, ?_⟩
  rw [delta0_zero]
  ext coordinate
  rcases coordinate with ⟨edge, index⟩
  fin_cases index <;>
    simp [zeroContext, Context.cochain, zeroArtifact, interpretation, zeroPayload, sheaf] <;>
    rfl

inductive Slot where
  | payload | plane
  deriving DecidableEq

instance : Fintype Slot where
  elems := {.payload, .plane}
  complete slot := by cases slot <;> simp

def Payload : Slot → Type
  | .payload => Axioms.CochainCommitmentData
  | .plane => Fin 2 → ℤ

/-- Extract both actual coordinates from the original commitment payload. -/
def extract (c : Axioms.CochainCommitmentData) : Fin 2 → ℤ :=
  fun i => c.edge_values.getD i.val 0

/-- The stored plane consists of the very coordinates read by the sheaf decoder. -/
theorem decode_eq_extract (c : Axioms.CochainCommitmentData) (i : Fin 2) :
    interpretation.decode c ⟨(), i⟩ = (extract c i : ℝ) := rfl

def planeDigest (_C : Context sheaf) : TCB.Hash32 := hash 40

def expectedItems (C : Context sheaf) : List (ManifestItem Slot Payload) :=
  [⟨.payload, C.cochain, C.artifact.digest⟩,
   ⟨.plane, extract C.cochain, planeDigest C⟩]

/-- A toy root function; its public role stays separate from the run identifier. -/
def manifestRoot (C : Context sheaf) : TCB.Hash32 := fun i => C.runId i + 100

structure BackendReceipt where
  context : ContextKey
  items : List (ManifestItem Slot Payload)
  root : TCB.Hash32

def scheme : CheckpointScheme sheaf Slot Payload BackendReceipt where
  requiredSlots := {.payload, .plane}
  entryBound C := fun
    | .payload, value, digest => value = C.cochain ∧ digest = C.artifact.digest
    | .plane, value, digest => value = extract C.cochain ∧ digest = planeDigest C
  manifestBound C items root := items = expectedItems C ∧ root = manifestRoot C
  persisted C items root receipt :=
    receipt.context = C.key ∧ receipt.items = items ∧ receipt.root = root

def payloadEntry (C : Context sheaf) : ManifestEntry scheme C where
  item := ⟨.payload, C.cochain, C.artifact.digest⟩
  bound := ⟨rfl, rfl⟩

def planeEntry (C : Context sheaf) : ManifestEntry scheme C where
  item := ⟨.plane, extract C.cochain, planeDigest C⟩
  bound := ⟨rfl, rfl⟩

def oneEntry (C : Context sheaf) : OpenManifest scheme C :=
  (OpenManifest.empty scheme C).append (payloadEntry C) (by simp [payloadEntry])

def completed (C : Context sheaf) : OpenManifest scheme C :=
  (oneEntry C).append (planeEntry C) (by simp [oneEntry, payloadEntry, planeEntry])

theorem completed_items (C : Context sheaf) : (completed C).items = expectedItems C := by
  simp [completed, oneEntry, payloadEntry, planeEntry, expectedItems]

def sealed (C : Context sheaf) : SealedManifest scheme C where
  manifest := completed C
  root := manifestRoot C
  complete := by
    intro slot _hslot
    cases slot <;> simp [completed, oneEntry, payloadEntry, planeEntry]
  rootBound := ⟨completed_items C, rfl⟩

def backendReceipt (C : Context sheaf) : BackendReceipt where
  context := C.key
  items := expectedItems C
  root := manifestRoot C

def receipt (C : Context sheaf) : PersistenceReceipt (sealed C) where
  receipt := backendReceipt C
  persisted := ⟨rfl, (completed_items C).symm, rfl⟩

/-- Two real typed leaves are appended, sealed and consumed with a matching receipt. -/
theorem complete_execution (C : Context sheaf) :
    Checkpoint.Execution
      (.collecting (OpenManifest.empty scheme C)) (.consumed (sealed C) (receipt C)) := by
  apply Checkpoint.Execution.next
    (Checkpoint.Step.append (OpenManifest.empty scheme C) (payloadEntry C)
      (by simp [payloadEntry]))
  apply Checkpoint.Execution.next
    (Checkpoint.Step.append (oneEntry C) (planeEntry C)
      (by simp [oneEntry, payloadEntry, planeEntry]))
  apply Checkpoint.Execution.next (Checkpoint.Step.seal (sealed C))
  apply Checkpoint.Execution.next (Checkpoint.Step.consume (sealed C) (receipt C))
  exact Checkpoint.Execution.refl _

theorem duplicate_slot_rejected :
    ¬ (payloadEntry rawContext).item.slot ∉ (oneEntry rawContext).slots := by
  simp [oneEntry, payloadEntry]

theorem incomplete_manifest_rejected :
    ¬ (∀ slot ∈ scheme.requiredSlots, slot ∈ (oneEntry rawContext).slots) := by
  intro h
  have hplane := h Slot.plane (by simp [scheme])
  simp [oneEntry, payloadEntry] at hplane

theorem incomplete_seal_rejected :
    ¬ ∃ M : SealedManifest scheme rawContext, M.manifest = oneEntry rawContext := by
  rintro ⟨M, hmanifest⟩
  apply incomplete_manifest_rejected
  simpa only [hmanifest] using M.complete

theorem changed_run_receipt_rejected :
    ¬ scheme.persisted otherRun (sealed otherRun).manifest.items
      (sealed otherRun).root (backendReceipt rawContext) := by
  intro h
  have hrun := congrArg ContextKey.runId h.1
  have hbyte := congrFun hrun 0
  change (20 : UInt8) = 21 at hbyte
  exact (by decide : (20 : UInt8) ≠ 21) hbyte

theorem payload_transplant_rejected :
    ¬ scheme.entryBound rawContext Slot.payload zeroPayload rawContext.artifact.digest := by
  rintro ⟨h, _⟩
  have hvalues := congrArg Axioms.CochainCommitmentData.edge_values h
  norm_num [rawContext, Context.cochain, rawArtifact, zeroPayload, rawPayload] at hvalues

theorem plane_transplant_rejected :
    ¬ scheme.entryBound rawContext Slot.plane (fun _ => 0) (planeDigest rawContext) := by
  rintro ⟨h, _⟩
  have hfirst := congrFun h 0
  norm_num [extract, rawContext, Context.cochain, rawArtifact, rawPayload] at hfirst

theorem consumed_cannot_reopen :
    ¬ Checkpoint.Execution (.consumed (sealed rawContext) (receipt rawContext))
      (.sealed (sealed rawContext)) :=
  Checkpoint.not_execution_consumed_to_sealed _ _ _

theorem second_consumption_rejected (after : Checkpoint scheme rawContext) :
    ¬ Checkpoint.Step (.consumed (sealed rawContext) (receipt rawContext)) after :=
  Checkpoint.no_step_from_consumed _ _

end Hcrypt.Protocol.Storage.Examples
