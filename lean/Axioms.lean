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
  - Paper 1's HCP setup uses the typed Helfer/HCP fragment through its specific
    owners, rather than this complete aggregate.
  - Paper 2 consumes the commitment, oracle, consensus, ledger and
    stage-admissibility interfaces. SEMANTIC-PARITY.md records their separate
    status.-/
