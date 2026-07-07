import Proximity.ProjectionChain.Core

/-!
  Projection-chain import surface.

  Paper correspondence:
  - Paper 1 Section 6: staged projection chain from FrameWitness to canonical
    Reed--Solomon target.
  - Paper 1 Section 7: projection-chain theorem-surface row.

  The projection-chain package owns the typed projection map orchestration:
  Plucker/cochain data is composed through the plane-shadow and RS received-word
  boundaries into one `Chain.toEvaluationProjection`.

  Gate certificates for this chain live in `Proximity.Gates`.
-/
