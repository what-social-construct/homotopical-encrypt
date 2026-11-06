module

public import Proximity.Public
public import TCB.ProofCarrying
public import TCB.WitnessVerifier
public import Protocol.Evidence.Transition

@[expose] public section

/-!
  Protocol evidence boundary.

  Paper 1 owns the cochain, projection, and proximity statements. This module
  is the Paper 2 attachment point for commitment-bound evidence envelopes,
  their lifecycle, and runtime refinement contracts. `Evidence.Transition`
  joins a runtime-observed statement, cochain artifact, and authenticated roots
  to one concrete ledger candidate.
-/
