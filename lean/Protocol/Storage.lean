module

public import Protocol.Evidence
public import TCB.CompressionBoundary
public import Protocol.Storage.Core
public import Protocol.Storage.CanonicalRS
public import Protocol.Storage.CanonicalSystematic
public import Protocol.Storage.DisclosureLeak
public import Protocol.Storage.CoupledCiphertext.Disclosure
public import Protocol.Storage.CoupledRecovery
public import Protocol.Storage.EncryptedCell
public import Protocol.Storage.CellDirectory.Persistence
public import Protocol.Storage.PublicStack.Release
public import Protocol.Storage.PublicStack.Continuation
public import Protocol.Storage.OperatorCommitment
public import Protocol.Storage.ThreeLevelMetrics
public import Protocol.Storage.CanonicalThreeLevel
public import Protocol.Storage.CanonicalCalibration
public import Protocol.Storage.HodgeRSCalibration
public import Protocol.Storage.Retrieval

@[expose] public section

/-!
  Sheaf-storage checkpoint and evidence-anchor interface.

  The mathematical core retains one snapshot/payload context, existing typed
  projection and gate prefixes, append-once manifests, sealing and receipt-bound
  local consumption. The history anchor joins the same candidate, snapshot,
  original artifact and sealed manifest, with explicit authentication-profile
  relations; its projection adapter retains the actual six-stage prefix and
  includes its gate database. The canonical application joins the same observed cochain
  to the existing pair calibration. Hashing, canonical bytes, actual codec/lift
  instantiation, database atomicity and crash consistency remain profile/runtime
  obligations. `Protocol.Storage.Core` is the focused import without the legacy
  broad evidence facade or optional canonical-field application.

  The canonical raw manifest has separate exact-artifact and full-ciphertext
  slots. Original-observation certificates add native decoding/message meaning
  to that same seal. The disclosure lemmas explain why an exact component alone
  cannot name distinct full ciphertexts; they imply no computational secrecy.

  The private-nonce operator profile separately commits to canonical coupling
  packet bytes and a private 32-byte opening. Its original snapshot/context
  join and explicit preimage-collision alternatives retain the same geometry.

`Protocol.Storage.Retrieval` separately analyzes hash-indexed encrypted-object
reads: uniform whole-bucket transcript privacy, local content verification,
original HCP recovery, native structured-noise/CVP query correctness and a
conditional disclosure from joint one-hot query views. The six-stage manifest
is not silently reinterpreted as an already implemented private database.

`Protocol.Storage.CellDirectory.Persistence` implements local publication and
process-restart reads under a caller-supplied checkpoint pin. Host disk
synchronization and reader privacy retain separate contracts.

`Protocol.Storage.PublicStack` names the public release under one root and
restores its complete set of digest-named records into a local store.
The proof-packet profile reruns the original transfer checker on restored records.
An ordered history index lets the reader replay several such records from one
trusted initial state.
History replication stages missing objects and checks each transition before
activating the replicated history.
An independently authenticated ledger checkpoint can reopen the complete
checked successor directly.
Continuation matches the authenticated ordered prefix and resumes at that state.
-/
