module

public import Consensus.Geometry
public import Consensus.Reliability
public import Consensus.ProofOfValue

@[expose] public section

/-
  Consensus-facing import surface.

  Paper correspondence:
  - Paper 2: consensus and Proof-of-Value protocol architecture.
  - Paper 1 appendix ledger: subsequent protocol-paper boundary only.

  This layer assembles gate facts, runtime evidence, and geometric/proximity
  quantities into Proof-of-Value protocol decisions.
-/
