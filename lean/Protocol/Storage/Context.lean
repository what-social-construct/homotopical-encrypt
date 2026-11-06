module

public import Sheaf.Commitment
public import Sheaf.Distance
public import TCB.ObservationBoundary

@[expose] public section

/-!
# One immutable input context for a sheaf projection run

The context retains the original sheaf interpretation, snapshot and public
cochain artifact. Shape/context binding does not assert exactness. Acceptance
is a separate predicate, so noisy and invalid inputs remain available for a
nonvacuous proximity question.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Storage

open Sheaf CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- Public names shared by every checkpoint of one projection run. -/
structure ContextKey where
  runId : TCB.Hash32
  schemaVersion : ℕ
  snapshotRoot : TCB.Hash32
  cochainDigest : TCB.Hash32
  topologyTag : Fin 16 → UInt8
  parameterSet : TCB.Hash32

/-- Fixed interpretation and original payload; exactness is deliberately separate. -/
structure Context (F : CellularSheaf X) where
  runId : TCB.Hash32
  interpretation : CochainPayloadInterpretation F
  artifact : TCB.HashedCommittedCochain
  artifactWellFormed : artifact.WellFormed
  boundToSnapshot : interpretation.BoundToSnapshot artifact.cochain
  parameterSet : TCB.Hash32

namespace Context

variable {F : CellularSheaf X}

/-- The exact same payload is used by all later projections. -/
def cochain (C : Context F) : Axioms.CochainCommitmentData :=
  C.artifact.cochain

/-- Context names are derived from the objects rather than supplied again. -/
def key (C : Context F) : ContextKey where
  runId := C.runId
  schemaVersion := C.interpretation.snapshot.schemaVersion
  snapshotRoot := C.interpretation.snapshot.root
  cochainDigest := C.artifact.digest
  topologyTag := C.interpretation.snapshot.topologyHash
  parameterSet := C.parameterSet

/-- Exact-payload acceptance in this very interpretation and snapshot. -/
def Accepted (C : Context F) : Prop :=
  AcceptedCommittedOneCochain C.interpretation C.cochain

/-- Decoded geometric source score, independent of any RS extraction. -/
def decodedDistance (C : Context F) : ℝ :=
  F.exactDistance (C.interpretation.decode C.cochain)

/-- Context binding supplies the shape/tag obligations; zero residual supplies exactness. -/
theorem accepted_iff_decodedDistance_eq_zero (C : Context F) :
    C.Accepted ↔ C.decodedDistance = 0 := by
  constructor
  · intro h
    exact F.exactDistance_eq_zero_of_exact h.decoded_isExactOneCochain
  · intro h
    refine ⟨C.artifactWellFormed.1, C.boundToSnapshot, ?_⟩
    obtain ⟨a, ha⟩ :=
      (F.exactDistance_eq_zero_iff (C.interpretation.decode C.cochain)).1 h
    exact ⟨a, ha.symm⟩

theorem decodedDistance_nonneg (C : Context F) : 0 ≤ C.decodedDistance :=
  F.exactDistance_nonneg _

/-- Positive-radius farness excludes an already accepted exact payload. -/
theorem not_accepted_of_far (C : Context F) {radius : ℝ}
    (hpos : 0 < radius) (hfar : radius ≤ C.decodedDistance) :
    ¬ C.Accepted := by
  intro h
  have hzero := C.accepted_iff_decodedDistance_eq_zero.mp h
  linarith

/-- Reuse an existing runtime observation and its exact public artifact. -/
def ofObservation {runtime : TCB.RuntimeBoundary}
    (I : CochainPayloadInterpretation F)
    (O : TCB.ObservationBoundary.ObservedStatement runtime)
    (hbound : I.BoundToSnapshot O.cochain)
    (runId : TCB.Hash32)
    (parameters : TCB.Hash32) : Context F where
  runId := runId
  interpretation := I
  artifact := O.artifact.publicArtifact
  artifactWellFormed := O.publicArtifact_wellFormed
  boundToSnapshot := hbound
  parameterSet := parameters

@[simp]
theorem ofObservation_cochain {runtime : TCB.RuntimeBoundary}
    (I : CochainPayloadInterpretation F)
    (O : TCB.ObservationBoundary.ObservedStatement runtime)
    (hbound : I.BoundToSnapshot O.cochain)
    (runId : TCB.Hash32)
    (parameters : TCB.Hash32) :
    (ofObservation I O hbound runId parameters).cochain = O.cochain := rfl

theorem topologyTag_matches (C : Context F) :
    C.cochain.topology_hash = C.key.topologyTag :=
  C.boundToSnapshot.2.2.1

/-- Snapshot or parameter substitution changes the context key. -/
theorem key_ne_of_snapshot_ne (C D : Context F)
    (h : C.interpretation.snapshot.root ≠ D.interpretation.snapshot.root) :
    C.key ≠ D.key := by
  intro heq
  exact h (congrArg ContextKey.snapshotRoot heq)

theorem key_ne_of_parameters_ne (C D : Context F)
    (h : C.parameterSet ≠ D.parameterSet) : C.key ≠ D.key := by
  intro heq
  exact h (congrArg ContextKey.parameterSet heq)

theorem key_ne_of_runId_ne (C D : Context F)
    (h : C.runId ≠ D.runId) : C.key ≠ D.key := by
  intro heq
  exact h (congrArg ContextKey.runId heq)

end Context
end Hcrypt.Protocol.Storage
