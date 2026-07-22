import Proximity.Public
import TCB.ProofCarrying
import TCB.WitnessVerifier

/-!
  Protocol evidence boundary.

  Paper 1 owns the cochain, projection, and proximity statements. This module
  is the Paper 2 attachment point for commitment-bound evidence envelopes,
  their lifecycle, and eventual runtime refinement contracts.
-/
