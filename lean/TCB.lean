module

public import TCB.ProofCarrying
public import TCB.HCPObservation
public import TCB.HCPRealization
public import TCB.HCPAxisFamily
public import TCB.PluckerObservation
public import TCB.CompressionBoundary
public import TCB.Runtime
public import TCB.SNARK
public import TCB.ObservationBoundary
public import TCB.WitnessVerifier
public import TCB.PrimitiveChecks

@[expose] public section

/-
  Trusted computing base surfaces.

  Paper correspondence:
  - Paper 1 Section 5 and appendix ledger: artifact/proof/runtime obligations
    are named as boundaries.
  - Paper 2: full runtime trust-boundary and implementation model.

  `Axioms` owns assumptions and mathematical specification contracts.
  `TCB` owns proof-carrying artifacts, compression boundaries, runtime
  acceptance predicates, observations, and witness/verifier envelopes.

  Legacy proof/observation carriers include statement truth as a premise.
  `PrimitiveChecks` separately names actual byte-verification algorithms,
  signing history and backend false acceptance without assuming soundness.
  Protocol adapters must bind those bytes and backend statements to the
  original owner intent and cochain interpretation before using error bounds.
-/
