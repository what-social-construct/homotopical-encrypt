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
  - Paper 1 supplies the operative HCP target used by the adapters.
  - Paper 2: payload binding, proof-carrying artifacts, byte checks, runtime
    acceptance and evidence contracts.
  - Paper 3: full-projective recovery and source-calibration consequences
    through their specific mathematical owners.

  `Axioms` owns assumptions and mathematical specification contracts.
  `TCB` owns proof-carrying artifacts, compression boundaries, runtime
  acceptance predicates, observations, and witness/verifier envelopes.

  Legacy proof/observation carriers include statement truth as a premise.
  `PrimitiveChecks` separately names actual byte-verification algorithms,
  signing history and backend false acceptance without assuming soundness.
  Protocol adapters must bind those bytes and backend statements to the
  original owner intent and cochain interpretation before using error bounds.
-/
