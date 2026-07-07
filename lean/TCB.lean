import TCB.ProofCarrying
import TCB.CompressionBoundary
import TCB.Runtime
import TCB.SNARK
import TCB.ObservationBoundary
import TCB.WitnessVerifier

/-
  Trusted computing base surfaces.

  Paper correspondence:
  - Paper 1 Sections 5 and 7: artifact/proof/runtime obligations are named as
    boundaries.
  - Paper 2: full runtime trust-boundary and implementation model.

  `Axioms` owns assumptions and mathematical specification contracts.
  `TCB` owns proof-carrying artifacts, compression boundaries, runtime
  acceptance predicates, observations, and witness/verifier envelopes.
-/
