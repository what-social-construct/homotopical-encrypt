module

public import Consensus.Geometry
public import Consensus.Reliability
public import Consensus.ProofOfValue

@[expose] public section

/-
  Consensus-facing import surface.

  Paper correspondence:
  - Paper 2: consensus and Proof-of-Value protocol assembly.
  - The repository-wide status index is SEMANTIC-PARITY.md; this aggregate is
    outside Paper 1's selected appendix.

  This layer assembles gate facts, runtime evidence, and geometric/proximity
  quantities into Proof-of-Value protocol decisions.
-/
