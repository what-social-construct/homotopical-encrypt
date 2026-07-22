import Axioms.Coregulator
import Consensus.Geometry
import Protocol.Oracle

/-!
  Typed coregulator and reconciliation attachment point.

  The intended dynamics act on auxiliary degree-zero validator-view
  disagreement. Quantitative spectral/Karcher settling bounds may guide
  `Hold` re-evaluation, but they do not replace quorum finality and must not
  evolve the committed degree-one HCP cochain.
-/
