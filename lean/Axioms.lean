module

public import Axioms.Foundation
public import Axioms.Consensus
public import Axioms.CochainCommitment
public import Axioms.Coregulator
public import Axioms.Fibration
public import Axioms.Grassmannian
public import Axioms.SheafCoherence
public import Axioms.Ledger
public import Axioms.ZKP
public import Axioms.HelferFOL
public import Axioms.HomotopyClass
public import Axioms.Heyting
public import Axioms.SpectralBounds
public import Axioms.OracleModality
public import Axioms.StageAdmissibility

@[expose] public section

/-
  Paper correspondence:
  - Paper 1 Section 4: semantic, public/private, exact, oracle, and commitment
    axiom surfaces.
  - Paper 1 appendix ledger: axiom-module theorem-surface correspondence.
  - Paper 2: consensus, ledger, and stage-admissibility interfaces are consumed
    by the protocol paper.
-/
