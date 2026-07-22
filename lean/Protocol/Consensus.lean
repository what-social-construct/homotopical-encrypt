import Consensus
import Axioms.Consensus
import Protocol.Evidence
import Protocol.Oracle
import Protocol.Consensus.Committee
import Protocol.Consensus.Vote
import Protocol.Consensus.Quorum

/-!
  Agreement and finality layer.

  Existing `Consensus` modules provide geometric and scoring lemmas. This
  This layer now owns registered weighted committees, fully bound authenticated
  votes, and strict two-thirds quorum certificates. Rounds, locking, agreement,
  and finality remain subsequent modules. Heyting gate evaluation and
  proof-of-value admissibility do not themselves constitute a quorum.
-/
