module

public import Consensus
public import Axioms.Consensus
public import Protocol.Evidence
public import Protocol.Oracle
public import Protocol.Consensus.Committee
public import Protocol.Consensus.Vote
public import Protocol.Consensus.Quorum

@[expose] public section

/-!
  Agreement and finality layer.

  Existing `Consensus` modules provide geometric and scoring lemmas. This
  This layer now owns registered weighted committees, fully bound authenticated
  votes, and strict two-thirds quorum certificates. Rounds, locking, agreement,
  and finality remain subsequent modules. Heyting gate evaluation and
  proof-of-value admissibility do not themselves constitute a quorum.
-/
