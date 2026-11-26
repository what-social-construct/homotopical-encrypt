module

public import Protocol.Storage.PublicStack.History
meta import Protocol.Storage.PublicStack.History
public import Protocol.Transfer.Owned.DemoFixture
meta import Protocol.Transfer.Owned.DemoFixture

public section

/-!
# Replay an authenticated two-transfer history from one ledger state

From `lean/`, run this file with `lake env lean --run` and `write DIR` for a
fresh directory. Then run it with `verify DIR` in a separate process. The
known fixture supplies the trusted starting state and history root. The reader
loads the two child stacks and their ciphertexts from disk.
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
  ⟨root, [(root, manifestBytes), (directoryRoot, directory),
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

private structure Index where
  bytes : Bytes
  root : TCB.Hash32

private def index (roots : List TCB.Hash32) : Index :=
  let bytes := HistoryIndex.encode roots
  let digest := Sha256.digestBytes bytes
  ⟨bytes, Sha256.toHash32 digest⟩

private def ordered (data : Fixture) : Index := index [data.first.root, data.second.root]
private def reversed (data : Fixture) : Index := index [data.second.root, data.first.root]
private def duplicate (data : Fixture) : Index := index [data.first.root, data.first.root]
private def siblingContinuation (data : Fixture) : Index := index [data.first.root, data.sibling.root]

private def fetch (source : Archive) (address : TCB.Hash32) : IO (Option Bytes) :=
  let key := List.ofFn address
  pure ((source.objects.find? fun item => List.ofFn item.1 == key).map Prod.snd)

private def ownerMarker : String := "hodge-history-demo-v1\n"

private def writeFixture (store : FilePath) : IO Unit := do
  IO.FS.createDir store
  let some data := fixture
    | throw (IO.userError "The transfer checker did not accept the fixture chain and sibling")
  IO.FS.writeFile (store / "demo-owner") ownerMarker
  for child in [data.first, data.second, data.sibling] do
    unless (← restore store child.root (fetch child)).isSome do
      throw (IO.userError "Could not restore a fixture child stack")
  for history in [ordered data, reversed data, duplicate data, siblingContinuation data] do
    unless ← CellDirectory.Persistence.seedObject store history.bytes do
      throw (IO.userError "Could not store a fixture history index")
  unless (← openStack store data.sibling.root).isSome do
    throw (IO.userError "The active pointer did not name the last restored child")
  IO.println "Stored two consecutive checked transfers, a valid sibling, and four history indices"

private def verifyFixture (store : FilePath) : IO Unit := do
  unless (← IO.FS.readFile (store / "demo-owner")) = ownerMarker do
    throw (IO.userError "Use a directory created by the write phase")
  let some data := fixture
    | throw (IO.userError "The trusted fixture did not generate its expected history root")
  let trusted := ordered data
  let profile := { initial with ciphertext := [] }
  let some final ← replayHistory store trusted.root profile
    | throw (IO.userError "Cold replay rejected the expected ordered history")
  unless final.height == 2 && final.marking.support == ({2} : Finset ℕ) &&
      final.marking 2 == 1 && decide (final.spent = ({0, 1} : Finset ℕ)) &&
      List.ofFn final.tipHash == List.ofFn data.successor.tipHash &&
      List.ofFn final.evidenceRoot == List.ofFn data.successor.evidenceRoot do
    throw (IO.userError "Cold replay did not recover the exact final roots and spent resources")

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

def run (args : List String) : IO Unit :=
  match args with
  | ["write", dir] => writeFixture ⟨dir⟩
  | ["verify", dir] => verifyFixture ⟨dir⟩
  | _ => throw (IO.userError "Usage is write DIR or verify DIR")

end HomotopicalEncryption.Protocol.Storage.PublicStack.HistoryDemo

def main (args : List String) : IO Unit :=
  HomotopicalEncryption.Protocol.Storage.PublicStack.HistoryDemo.run args
