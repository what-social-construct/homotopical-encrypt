# Protocol Parity Queue (Lean ↔ Rust ↔ Python ↔ Paper 2)

This queue tracks protocol state machines, runtime ownership, and migration
work. It is adjacent to `SEMANTIC_PARITY_QUEUE.md`, which remains the source of
truth for mathematical meaning and cross-language object semantics.

## Ownership Rule

- **Lean** owns abstract protocol states, accepted-transition relations,
  safety/preservation theorems, and the mathematical statements carried by
  public evidence.
- **Rust** owns the production realization: randomness, concrete
  cryptography, canonical bytes, hashing, proof verification, database
  atomicity, zeroization, malformed-input rejection, concurrency, and
  networking.
- **Python** is a research/reference implementation unless a queue item says
  otherwise. It is not consensus authority.
- **Paper 2** specifies the protocol, security games, runtime threat model, and
  concrete evidence/state-transition flow.

The long-term refinement target is:

> Every Rust-accepted protocol transition realizes the corresponding Lean
> transition relation.

## Lean Workspace Layout

Keep one `lean/` workspace. Introduce a one-way protocol dependency layer:

```text
lean/
  Axioms/          shared mathematical interfaces
  Laplacian/       core Hodge/Grassmannian mathematics
  Proximity/       core projection mathematics
  TCB/             shared public-artifact boundaries
  Protocol/        Paper 2 protocol specifications and proofs
  Paper1.lean      aggregate import for the Paper 1 theorem surface
  Paper2.lean      imports Paper1 plus Protocol
```

Core mathematics must not import `Protocol`. Protocol modules may import the
core mathematics and shared public-artifact boundaries.

## Status Vocabulary

- **Proved:** Lean theorem over typed mathematical/protocol objects.
- **Specified:** Lean structure or proposition names the obligation, but no
  concrete implementation/refinement theorem discharges it.
- **Implemented:** Production Rust realizes the behavior and has appropriate
  tests/audit coverage.
- **Prototype:** Python or legacy Rust contains a research implementation that
  is not yet the normative production path.
- **Deprecated candidate:** likely superseded; retain until its surviving
  semantics/tests have been mapped.

## Priority 1 — Ephemeral Representative And Anonymity Flow

1. **Paper 1 mathematical family**
   - Rename the conceptual object to `EphemeralRepresentativeSpec`; keep
     `EphemeralFiberSpec` as a compatibility alias while references migrate.
   - The generated endpoint is the ephemeral hidden representative. Its path
     from the base is the class-membership witness.
   - Add an indexed `EphemeralRepresentativeFamily`, connect the path to
     `FiberSystem.transport`, and prove that an injective infinite family is an
     infinite subset of one public classifier fiber.
   - Do not call this a random cochain candidate. A committed cochain is
     downstream of the representative's sheaf/cochain geometry.

2. **Paper 2 generation and consumption state machine**
   - Specify generation, active, consumed, and retired states in Lean.
   - Define freshness, single-use, replay exclusion, and key-image/nullifier
     linkage as typed transition predicates.
   - Prove that accepted transitions cannot consume one ephemeral handle
     twice.
   - Leave CSPRNG calls, secret bytes, constant-time behavior, and memory
     zeroization to Rust realization obligations.

3. **Anonymity/security game**
   - State the finite-family/asymptotic sampling game used to interpret
     anonymity; do not treat `1/∞ = 0` as a literal uniform distribution.
   - Connect the protocol-relevant classifier fiber to the infinite
     Grassmannian/Laplacian family under explicit compatibility hypotheses.

## Priority 2 — Proximity Evidence And Sheaf Storage

4. **Per-commit active state bus**
   - Initialize a fresh active bus for each commitment/witness.
   - Bind it to commitment hash, topology hash, projection/parameter-set ID,
     and evidence schema version.
   - Each stage checks its own restriction and syndrome naturality equations
     once; later stages consume the certified predecessor.

5. **Finalized projection artifact**
   - Join the witness-local state bus, accepted cochain artifact, plane view,
     calibrated final certificate, and `GateEvidence` database in one Lean
     public-envelope specification.
   - Prove that the finalized evidence root refers to the same commitment and
     topology as the sheaf-storage plane view.
   - Persist the immutable evidence object in sheaf/content-addressed storage;
     clear the mutable active bus after finalization.

6. **Main-chain anchor**
   - Extend the Paper 2 transaction/state model with an evidence-root handle
     bound to the commitment, topology, parameters, and schema version.
   - The chain stores the bounded root/handle, not the private path, ephemeral
     representative, transported secret state, or full evidence database.
   - Specify replay, reorganization, retention, and garbage-collection
     behavior before production implementation.

## Priority 3 — Consensus, Ledger, And Coregulator

7. **Consensus specification burn-down**
   - `Axioms.Consensus` currently contains proposition-only assumptions.
   - Define typed candidate/block inputs, eligibility, selection, acceptance,
     and transition relations under `Protocol/Consensus`.
   - Retain the proved arithmetic/scoring lemmas in `Consensus/*`, but do not
     present them as an end-to-end consensus proof.

8. **Ledger and key-image state**
   - Move/refine the abstract `Chain.lean` state transitions under
     `Protocol/Ledger` and `Protocol/Chain`.
   - Tie key-image freshness to the ephemeral consumption state and prove
     monotonic spent-set/no-double-consumption results.
   - Add commitment/evidence-root coherence to transaction and block
     acceptance.

9. **Coregulator model**
   - `Axioms.Coregulator` currently names four proposition-only obligations.
   - Define typed predict/observe/update state, determinism, monotonic delay
     policy, and the stability/convergence claims actually required by Paper
     2.
   - Numerical estimation and floating/fixed-point realization remain Rust
     concerns, with explicit error/refinement bounds.

## Priority 4 — Folder Migration

10. **Create protocol import surfaces**
    - Add `Protocol.lean`, `Paper1.lean`, and `Paper2.lean` aggregate imports.
    - Move protocol-only modules incrementally, using temporary re-export
      shims so file movement is reviewable separately from theorem changes.
    - Split mixed modules rather than moving them wholesale. In particular:
      - path/class/transport mathematics stays outside `Protocol`;
      - ephemeral lifecycle moves under `Protocol`;
      - proximity mathematics stays in `Proximity`;
      - mutable evidence storage/finalization moves under `Protocol`.

## Priority 5 — Legacy Rust/Python Inventory

11. **Read-only deprecation map before deletion**
    - Inventory older Python and Rust files without changing production paths.
    - Classify each as **current implementation**, **reference prototype**,
      **test oracle**, **superseded/archive candidate**, or **unknown pending
      protocol contract**.
    - For every deprecation candidate, record the surviving Lean contract,
      Rust replacement, tests/fixtures worth preserving, and documentation
      references that must move.
    - Do not delete or archive a file merely because it predates the current
      architecture; wait until its behavior is represented by the new Lean
      protocol contract or intentionally rejected.

12. **Deprecation execution checkpoint**
    - Perform moves/deletions only after a clean Lean protocol checkpoint and
      passing Rust/Python test baselines.
    - Keep deprecation changes separate from mathematical theorem changes and
      from protocol-state refactors so each can be reverted independently.
