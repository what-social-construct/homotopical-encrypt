module

public import Protocol.Storage.PublicStack.Continuation
meta import Protocol.Storage.PublicStack.Continuation
public import Protocol.Transfer.Owned.DemoFixture
meta import Protocol.Transfer.Owned.DemoFixture

public section

/-!
# Replay an authenticated two-transfer history from one ledger state

From `lean/`, run this file with `lake env lean --run` and `write DIR` for a
fresh directory. Then run it with `verify DIR` in a separate process. The
known fixture supplies the trusted starting state and history root. The reader
loads the two child stacks and their ciphertexts from disk.

Run `replicate DIR` and `reopen DIR` in separate processes to restore the same
history into a partially populated replica and reopen its active root.

Run `checkpoint DIR` and `open-checkpoint DIR` in separate processes to issue
the verified successor and open it in a store containing just the checkpoint.

Run `continue DIR` and `open-continuation DIR` to resume from the first
transfer's checkpoint, fetch the suffix, and reopen the resulting checkpoint.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack.HistoryDemo

open System (FilePath)
open TCB.PrimitiveChecks (Bytes)
open Protocol.Transfer.Owned (Config ResourceTransfer)
open Protocol.Evidence.TransferTranscript (ProofPacket)

/-- Authorize each catalog owner under the same deterministic test verifier. -/
private def authorization : Evidence.TransferVerifier.Authorization Bytes where
  Authorized owner intent := owner = Transfer.Owned.Demo.catalog.owner intent.transfer.input
  verify owner intent bytes :=
    decide (owner = Transfer.Owned.Demo.catalog.owner intent.transfer.input) &&
    decide (bytes = Transfer.Owned.Demo.signature intent)
  sound _ _ _ accepted := of_decide_eq_true (Bool.and_eq_true_iff.mp accepted).1

private def configFor (state : Ledger.State ℕ ℕ)
    (topology : state.topologyRoot = Transfer.Owned.Demo.fixtureHash 41) (ciphertext : Bytes) :
    Config Examples.sheaf Bytes Unit Unit :=
  { Transfer.Owned.Demo.config state topology with
    authorization := authorization
    ciphertext := ciphertext }

private def initial : Config Examples.sheaf Bytes Unit Unit :=
  configFor Transfer.Owned.Demo.before rfl [3, 8, 13]

private def siblingConfig (config : Config Examples.sheaf Bytes Unit Unit) :
    Config Examples.sheaf Bytes Unit Unit :=
  { config with
    before := { config.before with
      tipHash := Transfer.Owned.Demo.fixtureHash 201
      evidenceRoot := Transfer.Owned.Demo.fixtureHash 202 }
    topologyBound := config.topologyBound }

private def secondTransfer : ResourceTransfer Bytes where
  input := 1
  output := 2
  signer := Transfer.Owned.Demo.catalog.owner 1

private def packetFor (config : Config Examples.sheaf Bytes Unit Unit)
    (transfer : ResourceTransfer Bytes) : ProofPacket Bytes :=
  let intent := Transfer.Owned.Executable.intentFor config transfer
  ⟨config.metadata, intent, Transfer.Owned.Demo.signature intent, Transfer.Owned.Demo.proofBytes⟩

private structure Archive where
  root : TCB.Hash32
  evidenceAddress : TCB.Hash32
  objects : List (TCB.Hash32 × Bytes)

private def archive (config : Config Examples.sheaf Bytes Unit Unit)
    (packet : ProofPacket Bytes) (packetBytes : Bytes) : Archive :=
  let ciphertextDigest := Sha256.digestBytes config.ciphertext
  let ciphertextAddress := Sha256.toHash32 ciphertextDigest
  let directory := CellDirectory.Codec.encode config.context.key [(1, ciphertextAddress)]
  let directoryDigest := Sha256.digestBytes directory
  let directoryRoot := Sha256.toHash32 directoryDigest
  let release : ProofRelease := ⟨⟨config.context.key, directoryRoot⟩, config.context.cochain,
    ⟨1, ⟨config.hashes.proposal packet, .Valid⟩, packetBytes⟩⟩
  let manifest := release.manifest
  let manifestBytes := manifest.encode
  let digest := Sha256.digestBytes manifestBytes
  let root := Sha256.toHash32 digest
  ⟨root, manifest.evidenceAddress, [(root, manifestBytes), (directoryRoot, directory),
    (manifest.snapshotAddress, release.snapshot), (manifest.cochainAddress, release.cochain),
    (manifest.evidenceAddress, release.evidence), (ciphertextAddress, config.ciphertext)]⟩

private structure Fixture where
  first : Archive
  second : Archive
  sibling : Archive
  successor : Ledger.State ℕ ℕ

private def fixture : Option Fixture :=
  let transfer := Transfer.Owned.Demo.transfer
  let firstPacket := packetFor initial transfer
  let firstBytes := initial.codec.encode firstPacket
  match accepted : Transfer.Owned.Executable.run initial transfer firstBytes with
  | none => none
  | some rawMiddle => do
    let middle := materializeStateRoots rawMiddle
    let topology : middle.topologyRoot = Transfer.Owned.Demo.fixtureHash 41 :=
      (congrArg Ledger.State.topologyRoot (materializeStateRoots_eq rawMiddle)).trans
        (Transfer.Owned.Executable.topologyRoot_of_run initial transfer firstBytes rawMiddle accepted)
    let next := configFor middle topology [21, 34, 55]
    let secondPacket := packetFor next secondTransfer
    let secondBytes := next.codec.encode secondPacket
    let rawFinal ← Transfer.Owned.Executable.run next secondTransfer secondBytes
    let final := materializeStateRoots rawFinal

    -- This packet is accepted on its own branch with the same spendable input.
    let sibling := siblingConfig next
    let siblingPacket := packetFor sibling secondTransfer
    let siblingBytes := sibling.codec.encode siblingPacket
    let _ ← Transfer.Owned.Executable.run sibling secondTransfer siblingBytes
    return ⟨archive initial firstPacket firstBytes, archive next secondPacket secondBytes,
      archive sibling siblingPacket siblingBytes, final⟩

private structure NamedBytes where
  bytes : Bytes
  root : TCB.Hash32

private def nameBytes (bytes : Bytes) : NamedBytes :=
  let digest := Sha256.digestBytes bytes
  ⟨bytes, Sha256.toHash32 digest⟩

private def index (roots : List TCB.Hash32) : NamedBytes := nameBytes (HistoryIndex.encode roots)

private def ordered (data : Fixture) : NamedBytes := index [data.first.root, data.second.root]
private def reversed (data : Fixture) : NamedBytes := index [data.second.root, data.first.root]
private def duplicate (data : Fixture) : NamedBytes := index [data.first.root, data.first.root]
private def siblingContinuation (data : Fixture) : NamedBytes := index [data.first.root, data.sibling.root]

private def fetch (source : Archive) (address : TCB.Hash32) : IO (Option Bytes) :=
  let key := List.ofFn address
  pure ((source.objects.find? fun item => List.ofFn item.1 == key).map Prod.snd)

private def ownerMarker : String := "hodge-history-demo-v1\n"

private def populateFixture (store : FilePath) (data : Fixture) : IO Unit := do
  IO.FS.createDir store
  IO.FS.writeFile (store / "demo-owner") ownerMarker
  for child in [data.first, data.second, data.sibling] do
    unless (← restore store child.root (fetch child)).isSome do
      throw (IO.userError "Could not restore a fixture child stack")
  for history in [ordered data, reversed data, duplicate data, siblingContinuation data] do
    unless ← CellDirectory.Persistence.seedObject store history.bytes do
      throw (IO.userError "Could not store a fixture history index")
  unless (← openStack store data.sibling.root).isSome do
    throw (IO.userError "The active pointer did not name the last restored child")

private def writeFixture (store : FilePath) : IO Unit := do
  let some data := fixture
    | throw (IO.userError "The transfer checker did not accept the fixture chain and sibling")
  populateFixture store data
  IO.println "Stored two consecutive checked transfers, a valid sibling, and four history indices"

private def checkSuccessor (actual expected : Ledger.State ℕ ℕ) : IO Unit := do
  unless actual.height == 2 && actual.marking.support == ({2} : Finset ℕ) &&
      actual.marking 2 == 1 && decide (actual.spent = ({0, 1} : Finset ℕ)) &&
      List.ofFn actual.tipHash == List.ofFn expected.tipHash &&
      List.ofFn actual.evidenceRoot == List.ofFn expected.evidenceRoot do
    throw (IO.userError "Cold replay did not recover the exact final roots and spent resources")

private def verifyFixture (store : FilePath) : IO Unit := do
  unless (← IO.FS.readFile (store / "demo-owner")) = ownerMarker do
    throw (IO.userError "Use a directory created by the write phase")
  let some data := fixture
    | throw (IO.userError "The trusted fixture did not generate its expected history root")
  let trusted := ordered data
  let profile := { initial with ciphertext := [] }
  let some final ← replayHistory store trusted.root profile
    | throw (IO.userError "Cold replay rejected the expected ordered history")
  checkSuccessor final data.successor

  let wrongOrder := reversed data
  for (description, bad) in [("reversed order", wrongOrder), ("duplicate first root", duplicate data),
      ("valid sibling continuation", siblingContinuation data)] do
    if (← replayHistory store bad.root profile).isSome then
      throw (IO.userError s!"Cold replay accepted {description}")

  let path := CellDirectory.Persistence.objectPath store trusted.root
  let original ← IO.FS.readBinFile path
  try
    IO.FS.writeBinFile path ⟨wrongOrder.bytes.toArray⟩
    if (← replayHistory store trusted.root profile).isSome then
      throw (IO.userError "Cold replay accepted substituted index bytes at the trusted root")
  finally
    IO.FS.writeBinFile path original
  IO.println "Replayed both archived transfers to height 2 with the exact tip, evidence, and spent resources"
  IO.println "Rejected reversed roots, a duplicate first root, a valid sibling continuation, and substituted index bytes"

private def replicaMarker : String := "hodge-history-replication-demo-v1\n"

private def checkActiveRoot (store : FilePath) (expected : TCB.Hash32) : IO Unit := do
  unless (← LocalObjects.readFile (historyCheckpointPath store)) == some (List.ofFn expected) do
    throw (IO.userError "A failed sync displaced the prior active history root")

private def replicateFixture (store : FilePath) : IO Unit := do
  let some data := fixture
    | throw (IO.userError "The transfer checker did not accept the fixture chain and sibling")
  IO.FS.createDir store
  IO.FS.writeFile (store / "demo-owner") replicaMarker
  let source := store / "source"
  let target := store / "replica"
  populateFixture source data
  unless (← restore target data.first.root (LocalObjects.readObject source)).isSome do
    throw (IO.userError "Could not seed the first child in the replica")

  let trusted := ordered data
  let profile := { initial with ciphertext := [] }
  let first := data.first.objects.map (List.ofFn ∘ Prod.fst)
  let needed := (List.ofFn trusted.root :: first ++
    data.second.objects.map (List.ofFn ∘ Prod.fst)).eraseDups
  let missing := needed.filter (fun key => !first.contains key)
  let requests ← IO.mkRef ([] : List (List UInt8))
  let fromSource (address : TCB.Hash32) := do
    requests.modify (List.ofFn address :: ·)
    let some bytes ← LocalObjects.readObject source address
      | throw (IO.userError "The source did not have the requested fixture bytes")
    return some bytes

  let some (synced, final) ← restoreHistory target trusted.root profile fromSource
    | throw (IO.userError "Could not sync the accepted ordered history")
  let seen ← requests.get
  unless synced.fetched == 5 && synced.reused == 6 && seen.length == synced.fetched &&
      seen.length == missing.length && missing.all seen.contains do
    throw (IO.userError "Sync did not fetch exactly the missing history objects")
  checkSuccessor final data.successor

  requests.set []
  let some (repeated, final) ← restoreHistory target trusted.root profile fromSource
    | throw (IO.userError "Could not repeat the accepted sync")
  unless repeated.fetched == 0 && repeated.reused == needed.length && (← requests.get).isEmpty do
    throw (IO.userError "A complete replica sent a source request")
  checkSuccessor final data.successor

  let alternate := siblingContinuation data
  let withheld := List.ofFn data.sibling.evidenceAddress
  let attempted ← IO.mkRef false
  let incomplete (address : TCB.Hash32) := do
    if List.ofFn address == withheld then
      attempted.set true
      return none
    fromSource address
  if (← restoreHistory target alternate.root profile incomplete).isSome then
    throw (IO.userError "An incomplete history became active")
  unless ← attempted.get do
    throw (IO.userError "Sync did not reach the withheld evidence object")
  checkActiveRoot target trusted.root

  requests.set []
  if (← restoreHistory target alternate.root profile fromSource).isSome then
    throw (IO.userError "A valid sibling packet passed ordered replay")
  unless (← requests.get) == [withheld] &&
      (← LocalObjects.readObject target data.sibling.evidenceAddress).isSome do
    throw (IO.userError "The sibling retry did not obtain its final verified object")
  checkActiveRoot target trusted.root
  IO.println "Restored the ordered history with five source fetches and six reused objects"
  IO.println "Repeated sync with zero source requests"
  IO.println "Preserved the active history on missing evidence and a complete sibling continuation"

private def reopenFixture (store : FilePath) : IO Unit := do
  unless (← IO.FS.readFile (store / "demo-owner")) = replicaMarker do
    throw (IO.userError "Use a directory created by the replicate phase")
  let some data := fixture
    | throw (IO.userError "The trusted fixture did not generate its expected history root")
  let trusted := ordered data
  let profile := { initial with ciphertext := [] }
  let some final ← openHistory (store / "replica") trusted.root profile
    | throw (IO.userError "Could not reopen the active history from the replica")
  checkSuccessor final data.successor
  IO.println "Reopened the active replica from its trusted history root and recovered the exact successor"

private def checkpointMarker : String := "hodge-ledger-checkpoint-demo-v1\n"

private def expectedCheckpoint (state : Ledger.State ℕ ℕ) (historyRoot : TCB.Hash32) : NamedBytes :=
  nameBytes (LedgerCheckpoint.encode ⟨historyRoot, initial.context.key, state⟩)

private def checkpointFixture (store : FilePath) : IO Unit := do
  let some data := fixture
    | throw (IO.userError "The transfer checker did not accept the fixture chain and sibling")
  IO.FS.createDir store
  IO.FS.writeFile (store / "demo-owner") checkpointMarker
  let source := store / "source"
  populateFixture source data
  let trusted := ordered data
  let profile := { initial with ciphertext := [] }
  let some (_, final) ← restoreHistory source trusted.root profile (fun _ => pure none)
    | throw (IO.userError "Could not activate the verified history before issuing its checkpoint")
  checkSuccessor final data.successor

  let inactive := index [data.first.root]
  unless ← CellDirectory.Persistence.seedObject source inactive.bytes do
    throw (IO.userError "Could not store the valid inactive prefix")
  unless (← replayHistory source inactive.root profile).isSome do
    throw (IO.userError "The inactive prefix did not replay independently")
  if (← issueLedgerCheckpoint source inactive.root profile).isSome then
    throw (IO.userError "A valid inactive history issued a checkpoint")

  let expected := expectedCheckpoint data.successor trusted.root
  let some digest ← issueLedgerCheckpoint source trusted.root profile
    | throw (IO.userError "Could not issue the checkpoint for the active history")
  unless Sha256.key digest == List.ofFn expected.root do
    throw (IO.userError "The issuer did not name the expected checked successor")
  let some bytes ← LocalObjects.readObject source expected.root
    | throw (IO.userError "The issued checkpoint was unavailable at its expected address")
  unless bytes == expected.bytes do
    throw (IO.userError "The issued checkpoint did not contain the exact ledger record")
  unless ← CellDirectory.Persistence.seedObject (store / "checkpoint-only") bytes do
    throw (IO.userError "Could not copy the verified checkpoint to the checkpoint-only store")
  IO.println "Issued the exact checked successor, refused issuance for a valid inactive history, and copied just the checkpoint"

private def checkState (actual expected : Ledger.State ℕ ℕ) : IO Unit := do
  let roots := [(actual.tipHash, expected.tipHash), (actual.evidenceRoot, expected.evidenceRoot),
    (actual.snapshotRoot, expected.snapshotRoot), (actual.topologyRoot, expected.topologyRoot),
    (actual.cochainRoot, expected.cochainRoot)]
  unless decide (actual.marking = expected.marking) && decide (actual.spent = expected.spent) &&
      actual.height == expected.height && actual.epoch == expected.epoch &&
      roots.all (fun pair => List.ofFn pair.1 == List.ofFn pair.2) do
    throw (IO.userError "The recovered checkpoint differed from the checked state")

private def openCheckpointFixture (store : FilePath) : IO Unit := do
  unless (← IO.FS.readFile (store / "demo-owner")) = checkpointMarker do
    throw (IO.userError "Use a directory created by the checkpoint phase")
  let some data := fixture
    | throw (IO.userError "The trusted fixture did not generate its expected checkpoint root")
  let cold := store / "checkpoint-only"
  let entries ← (cold / "objects").readDir
  unless entries.size == 1 && (← LocalObjects.readFile (historyCheckpointPath cold)).isNone do
    throw (IO.userError "The cold store contained history artifacts alongside the checkpoint")
  let trusted := ordered data
  let expected := expectedCheckpoint data.successor trusted.root
  let context := initial.context.key
  let some recovered ← openLedgerCheckpoint cold expected.root trusted.root context
    | throw (IO.userError "Could not reopen the checkpoint from the checkpoint-only store")
  checkState recovered data.successor

  let wrongHistory := reversed data
  if (← openLedgerCheckpoint cold expected.root wrongHistory.root context).isSome then
    throw (IO.userError "The checkpoint opened under the wrong expected history")
  let wrongContext := { context with schemaVersion := context.schemaVersion + 1 }
  if (← openLedgerCheckpoint cold expected.root trusted.root wrongContext).isSome then
    throw (IO.userError "The checkpoint opened under the wrong expected context")

  let path := LocalObjects.objectPath cold expected.root
  let wrongPath := LocalObjects.objectPath cold trusted.root
  if ← wrongPath.pathExists then
    throw (IO.userError "The fixture's wrong address already exists")
  IO.FS.rename path wrongPath
  try
    if (← openLedgerCheckpoint cold expected.root trusted.root context).isSome then
      throw (IO.userError "A missing checkpoint object reopened")
    if (← openLedgerCheckpoint cold trusted.root trusted.root context).isSome then
      throw (IO.userError "The checkpoint opened at the wrong digest")
    IO.FS.writeBinFile path ⟨#[0]⟩
    if (← openLedgerCheckpoint cold expected.root trusted.root context).isSome then
      throw (IO.userError "A corrupted checkpoint object reopened")
  finally
    IO.FS.rename wrongPath path

  if topology : List.ofFn recovered.topologyRoot = List.ofFn (Transfer.Owned.Demo.fixtureHash 41) then
    let resumed := configFor recovered (List.ofFn_injective topology) initial.ciphertext
    let transfer := Transfer.Owned.Demo.transfer
    let bytes := initial.codec.encode (packetFor initial transfer)
    if (Transfer.Owned.Executable.run resumed transfer bytes).isSome then
      throw (IO.userError "Replay was accepted after reopening the spent state")
  else
    throw (IO.userError "The checkpoint did not preserve the expected topology root")
  IO.println "Reopened the exact ledger state from the sole checkpoint object and rejected replay against the spent state"
  IO.println "Rejected a wrong history, context, or digest and a missing or corrupted checkpoint object"

private def continuationMarker : String := "hodge-ledger-continuation-demo-v1\n"

private def checkContinuationStore (store : FilePath) (firstRoot : TCB.Hash32) : IO Unit := do
  if ← (LocalObjects.objectPath store firstRoot).pathExists then
    throw (IO.userError "Continuation fetched the first stack manifest despite the checkpoint")
  unless (← LocalObjects.readFile (historyCheckpointPath store)).isNone do
    throw (IO.userError "Continuation published a history pointer without restoring the entire history")

private def continueFixture (store : FilePath) : IO Unit := do
  let some data := fixture
    | throw (IO.userError "The transfer checker did not accept the fixture chain and sibling")
  IO.FS.createDir store
  IO.FS.writeFile (store / "demo-owner") continuationMarker
  let source := store / "source"
  let target := store / "replica"
  populateFixture source data
  let prior := index [data.first.root]
  let truncated := index []
  for history in [prior, truncated] do
    unless ← CellDirectory.Persistence.seedObject source history.bytes do
      throw (IO.userError "Could not store a fixture index for continuation")

  let profile := { initial with ciphertext := [] }
  let some (_, middle) ← restoreHistory source prior.root profile (fun _ => pure none)
    | throw (IO.userError "Could not activate the first transfer before issuing its checkpoint")
  let prefixCheckpoint := expectedCheckpoint middle prior.root
  let some issued ← issueLedgerCheckpoint source prior.root profile
    | throw (IO.userError "Could not issue the checkpoint for the first transfer")
  unless Sha256.key issued == List.ofFn prefixCheckpoint.root do
    throw (IO.userError "The issuer did not name the expected prefix checkpoint")
  let some bytes ← LocalObjects.readObject source prefixCheckpoint.root
    | throw (IO.userError "The prefix checkpoint was unavailable at its expected address")
  unless bytes == prefixCheckpoint.bytes do
    throw (IO.userError "The prefix checkpoint did not contain the exact first successor")
  unless ← CellDirectory.Persistence.seedObject target bytes do
    throw (IO.userError "Could not seed the prefix checkpoint into the replica")
  let entries ← (target / "objects").readDir
  unless entries.size == 1 do
    throw (IO.userError "The replica held additional objects before continuation")

  let extended := ordered data
  let expected := expectedCheckpoint data.successor extended.root
  let needed := (List.ofFn prior.root :: List.ofFn extended.root ::
    data.second.objects.map (List.ofFn ∘ Prod.fst)).eraseDups
  let requests ← IO.mkRef ([] : List (List UInt8))
  let fromSource (address : TCB.Hash32) := do
    requests.modify (List.ofFn address :: ·)
    let some object ← LocalObjects.readObject source address
      | throw (IO.userError "The source did not have the requested continuation object")
    return some object

  let some (continued, digest) ← continueHistory target prefixCheckpoint.root extended.root profile fromSource
    | throw (IO.userError "Could not continue the history from its prefix checkpoint")
  let seen ← requests.get
  unless continued.fetched == 8 && continued.reused == 1 && seen.length == continued.fetched &&
      seen.length == needed.length && needed.all seen.contains do
    throw (IO.userError "Continuation did not fetch exactly the two indices and the second stack's objects")
  unless Sha256.key digest == List.ofFn expected.root do
    throw (IO.userError "Continuation did not issue the expected successor checkpoint")

  requests.set []
  let some (repeated, digest) ← continueHistory target prefixCheckpoint.root extended.root profile fromSource
    | throw (IO.userError "Could not repeat the accepted continuation")
  unless repeated.fetched == 0 && repeated.reused == 9 && (← requests.get).isEmpty &&
      Sha256.key digest == List.ofFn expected.root do
    throw (IO.userError "A complete continuation changed its result or requested source bytes")

  let some (unchanged, digest) ← continueHistory target expected.root extended.root profile fromSource
    | throw (IO.userError "The new checkpoint could not anchor its unchanged history")
  unless unchanged.fetched == 0 && unchanged.reused == 2 && (← requests.get).isEmpty &&
      Sha256.key digest == List.ofFn expected.root do
    throw (IO.userError "Reusing the new checkpoint changed its digest or required suffix objects")

  for (description, wrong) in [("reversed history", reversed data), ("truncated history", truncated)] do
    requests.set []
    if (← continueHistory target prefixCheckpoint.root wrong.root profile fromSource).isSome then
      throw (IO.userError s!"Continuation accepted a {description}")
    unless (← requests.get) == [List.ofFn wrong.root] do
      throw (IO.userError s!"Continuation followed archive references in a {description}")

  let sibling := siblingContinuation data
  let siblingRequests := [List.ofFn sibling.root, List.ofFn data.sibling.root,
    List.ofFn data.sibling.evidenceAddress]
  requests.set []
  if (← continueHistory target prefixCheckpoint.root sibling.root profile fromSource).isSome then
    throw (IO.userError "A valid sibling packet passed ordered replay from the checkpoint")
  let seen ← requests.get
  unless seen.length == siblingRequests.length && siblingRequests.all seen.contains &&
      (← LocalObjects.readObject target data.sibling.evidenceAddress).isSome do
    throw (IO.userError "The sibling test did not obtain all of its missing verified bytes")
  checkContinuationStore target data.first.root
  IO.println "Continued from one cached checkpoint, fetching two indices and six objects for the new transfer"
  IO.println "Repeated continuation and reused the new checkpoint as an anchor with zero source requests"
  IO.println "Rejected reversal and truncation before suffix requests and a complete sibling during replay"

private def openContinuationFixture (store : FilePath) : IO Unit := do
  unless (← IO.FS.readFile (store / "demo-owner")) = continuationMarker do
    throw (IO.userError "Use a directory created by the continue phase")
  let some data := fixture
    | throw (IO.userError "The trusted fixture did not generate its expected continuation root")
  let target := store / "replica"
  checkContinuationStore target data.first.root
  let extended := ordered data
  let expected := expectedCheckpoint data.successor extended.root
  let some recovered ← openLedgerCheckpoint target expected.root extended.root initial.context.key
    | throw (IO.userError "Could not reopen the resulting continuation checkpoint")
  checkState recovered data.successor
  IO.println "Reopened the exact final state without the first stack manifest or an active history pointer"

def run (args : List String) : IO Unit :=
  match args with
  | ["write", dir] => writeFixture ⟨dir⟩
  | ["verify", dir] => verifyFixture ⟨dir⟩
  | ["replicate", dir] => replicateFixture ⟨dir⟩
  | ["reopen", dir] => reopenFixture ⟨dir⟩
  | ["checkpoint", dir] => checkpointFixture ⟨dir⟩
  | ["open-checkpoint", dir] => openCheckpointFixture ⟨dir⟩
  | ["continue", dir] => continueFixture ⟨dir⟩
  | ["open-continuation", dir] => openContinuationFixture ⟨dir⟩
  | _ => throw (IO.userError "Pass a mode and directory. Modes are write, verify, replicate, reopen, checkpoint, open-checkpoint, continue, and open-continuation")

end HomotopicalEncryption.Protocol.Storage.PublicStack.HistoryDemo

def main (args : List String) : IO Unit :=
  HomotopicalEncryption.Protocol.Storage.PublicStack.HistoryDemo.run args
