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

Track three independent axes:

- **Lean coverage:** Unmapped / Interface-only / Specified / Proved /
  Runtime-refined.
- **Semantic verdict:** Preserve / Preserve after rename / Partial / Conflicts
  with canonical model / Rejected.
- **Disposition:** Active implementation / Active reference / Test oracle /
  Quarantine / Deprecation candidate / Archived / Deleted.

“Implemented” may be recorded as runtime evidence, but it is not a substitute
for a Lean refinement theorem. Likewise, an old semantic claim may be rejected
without creating a Lean version of the mistake.

## Priority 1 — Ephemeral Representative And Anonymity Flow

1. **Paper 1 mathematical family**
   - **Current state:** Lean contains only the supplied abstract path
     `EphemeralFiberSpec.path`. `EphemeralRepresentativeSpec`, the indexed
     family, concrete generation, and the lifecycle state machine do not yet
     exist; `Protocol/Ephemeral.lean` is currently an import-only attachment
     point.
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
   - Bind it to the exact-cochain commitment hash, canonical
     `SheafStateSnapshot` root, topology metadata, projection/parameter-set ID,
     and evidence schema version.
   - Each stage checks its own restriction and syndrome naturality equations
     once; later stages consume the certified predecessor.

5. **Finalized projection artifact**
   - Join the witness-local state bus, accepted cochain artifact, plane view,
     calibrated final certificate, and `GateEvidence` database in one Lean
     public-envelope specification.
   - Prove that the finalized evidence root refers to the same exact cochain
     and `SheafStateSnapshot` as the stored plane view.
   - Persist the immutable evidence object in sheaf/content-addressed storage;
     clear the mutable active bus after finalization.

6. **Main-chain anchor**
   - Extend the Paper 2 transaction/state model with an evidence-root handle
     bound to the exact cochain, `SheafStateSnapshot` root, topology metadata,
     parameters, and schema version.
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
   - **Initial quorum kernel proved:**
     `Protocol/Consensus/Committee.lean` defines registered positive integral
     voting weights and the division-free strict threshold
     `2 * totalWeight < 3 * supportWeight`;
     `Protocol/Consensus/Vote.lean` binds authenticated votes to committee,
     epoch, height, round, phase, block/parent, state, topology, cochain,
     evidence roots, and the collapsed Heyting judgment; and
     `Protocol/Consensus/Quorum.lean` prevents duplicate signer weight and
     proves weighted quorum intersection. Under faulty weight below one third
     and a non-faulty no-double-vote premise, two certificates have the same
     target.
   - **Still pending:** round/phase transitions, locking/unlocking rules,
     proposal selection, equivocation evidence, finality promotion, liveness,
     and a Rust refinement theorem. A quorum certificate is therefore not yet
     presented as a complete consensus or finality proof.

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
    - Audit in dependency order: `primitives`, `invariants`, `proofs`,
      `geometry`, `crypto`, `chain`, `network`, `consensus`, then `oracle`.
      Finish classification of one layer before treating the next layer as
      authoritative.
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

    Record each exported object with: source file and symbol, active importers,
    claimed semantics, canonical Lean owner, Lean coverage, semantic verdict,
    runtime owner/replacement, tests or fixtures to preserve, paper scope,
    disposition, blocker, and replacement commit. Coverage, semantic validity,
    and file disposition are separate axes; one “done” badge is insufficient.

    A file may be archived only when:
    1. every exported symbol and active importer is inventoried;
    2. every semantic claim is preserved, corrected, or explicitly rejected;
    3. preserved mathematics has a Lean owner or explicit runtime-only contract;
    4. production behavior has a Rust replacement or is declared unnecessary;
    5. useful fixtures/tests are migrated and parity baselines pass;
    6. active papers/docs point to canonical owners;
    7. no active import remains except a documented compatibility shim; and
    8. the Lean, Rust, and Python checkpoint builds pass.

    Deletion additionally requires no compatibility consumer, a recoverable
    archive/provenance copy or git checkpoint, and a separate revertible cleanup
    commit. Archived source must carry a non-normative header naming its
    replacement and any rejected claims.

12. **Deprecation execution checkpoint**
    - Perform moves/deletions only after a clean Lean protocol checkpoint and
      passing Rust/Python test baselines.
    - Keep deprecation changes separate from mathematical theorem changes and
      from protocol-state refactors so each can be reverted independently.
