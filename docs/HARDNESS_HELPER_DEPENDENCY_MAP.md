# Hardness ↔ HelferFOL Dependency Map (Lean-first)

This file links existing hardness claims to explicit Helfer FOL obligations in
`lean/Axioms/HelferFOL.lean`.

## Ownership / separation-of-concerns (authoritative)

### Lean owns truth/specification

Lean modules define predicates, contracts, and theorem obligations.

1. **Equivalence definitions and laws**
   - Scope: homotopy-class equivalence relation (`refl/symm/trans`),
     path-based equality semantics, class-membership witness discipline.
   - Current anchors:
     - `lean/Axioms/HelferFOL.lean` (`DiagonalPathSemantics`,
       `HomotopyInvarianceFO`, `ClassWitnessSound`)
     - `lean/Axioms/PythonHomotopyRefinement.lean` (`Equivalent`,
       `equivalent_refl/symm/trans`, `Refines`)

2. **Invariant implication contracts**
   - Scope: implications like
     “if stage=`transaction` passes critical invariants,
     then consensus admissibility predicate holds.”
   - Current anchors:
     - `lean/Axioms/Consensus.lean` (consensus gate interfaces)
     - `lean/Axioms/StageAdmissibility.lean` (stage-level implication
       interface + Python refinement boundary)
   - Expansion target:
     - explicit stage-level admissibility predicates and implication theorems
       that Python validators are required to refine.

3. **Proof-system interface obligations**
   - Scope: completeness/soundness/zero-knowledge/statement-binding contracts
     for spectral, homotopy/geodesic, and class-membership proofs.
   - Current anchors:
     - `lean/Axioms/ZKP.lean` (`ZKP`, `ZKPWellFormed`)

4. **Hardness dependency graph**
   - Scope: Hodge→CVP reduction, ambiguity, strict-harder dependencies,
     explicitly parameterized by assumption bundles.
   - Current anchors:
     - `lean/Hardness.lean`
     - `lean/Axioms/Foundation.lean`
     - `lean/Axioms/HelferFOL.lean`

### Python owns geometry computation (candidate witnesses/invariants)

- Numeric eigendecompositions, decomposition/projection computation,
  witness construction, and non-consensus-critical orchestration.
- Main surfaces:
  - `src/invariants/*`
  - `src/proofs/*`
  - `src/primitives/homotopy.py`

### Rust owns deterministic consensus-critical enforcement

- Fixed-point checks, deterministic validity decisions, state transitions,
  mempool/commit rules, and network-facing consensus enforcement.
- Main surfaces:
  - `rust/node/src/consensus/*`
  - `rust/node/src/*` consensus-adjacent runtime paths

### Practical rule

**Lean defines what is true. Python computes candidate evidence.
Rust enforces admissibility deterministically.**

## Mapping

1. **Hodge ambiguity / class-membership ambiguity**
   - Depends on: `DiagonalPathSemantics`, `ClassWitnessSound`
   - Why: equality of identities is interpreted via path/witness semantics,
     not strict syntactic equality.

2. **Hodge strictly harder (CVP oracle insufficient globally)**
   - Depends on: `HomotopyInvarianceFO`, `CartesianLiftingPrinciple`
   - Why: solver behavior must be stable across homotopy-equivalent
     fibrational presentations and transport along lifts.

3. **Hodge decomposition as operative crypto split**
   - Depends on: `SigmaPiCoherent`
   - Why: existential/universal behavior tracks encrypt/decrypt obligations
     at the specification layer.

4. **Homotopy-equivalence based identity/privacy claims**
   - Depends on: `DiagonalPathSemantics`, `HomotopyInvarianceFO`,
     `ClassWitnessSound`
   - Why: class-membership proofs need path-based equality + FO invariance +
     witness discipline.

## Immediate proof plan

- Keep using `lean/Axioms/*` as explicit assumptions while filling proof holes
  in `lean/Hardness.lean`, `lean/Laplacian.lean`, `lean/Tsirelson.lean`.
- Incrementally replace assumptions by constructive lemmas as each dependency
  is discharged.

## Next organizational increments

1. Wire `src/invariants/unified.py` stage outputs to
   `PythonStageValidationSnapshot`/`RefinesTransactionCriticalPass`
   (docs + optional adapter helper).
2. Add a lightweight theorem/adapter in `lean/Hardness.lean` consuming
   `StageAdmissibilityWellFormed` alongside Foundation/Helfer assumptions.
3. Keep Rust consensus checks as the runtime realization of the Lean
   admissibility predicate (deterministic/fixed-point path).
