module

public import Protocol.Storage.PublicStack.Replay
meta import Protocol.Storage.PublicStack.Replay
public import Protocol.Transfer.Owned.DemoFixture
meta import Protocol.Transfer.Owned.DemoFixture

public section

/-!
# Cold verification of a restored owned-transfer packet

From `lean/`, run this file with `lake env lean --run` and `write DIR`
for a fresh directory. Run it again with `verify DIR` in a separate process.
The verifier gets the expected roots and the original ledger inputs from
the fixed fixture. It gets the checked packet and its ciphertext from disk.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack.ProofDemo

open System (FilePath)
open TCB.PrimitiveChecks (Bytes)
open Protocol.Transfer.Owned (CheckedTransfer Config)
open Protocol.Evidence.TransferTranscript (ProofPacket)

private def base : Config Examples.sheaf Bytes Unit Unit :=
  Transfer.Owned.Demo.config Transfer.Owned.Demo.before rfl

private def packet : ProofPacket Bytes := Transfer.Owned.Demo.packet base

private def packetBytes : Bytes := base.codec.encode packet

private def selectedCell : Nat := 1

private def ciphertextDigest : Sha256.DigestBytes := Sha256.digestBytes base.ciphertext

private def entries : CellDirectory.Codec.Entries :=
  [(selectedCell, Sha256.toHash32 ciphertextDigest)]

private def directoryBytes : Bytes := CellDirectory.Codec.encode base.context.key entries

private def pin : CellDirectory.CheckpointPin :=
  let digest := Sha256.digestBytes directoryBytes
  ⟨base.context.key, Sha256.toHash32 digest⟩

private def directory : CellDirectory.Verified base.context.key pin.directoryRoot :=
  ⟨entries, by simp [entries], rfl⟩

private theorem ciphertext_named :
    directory.entries.lookup selectedCell = some (Sha256.digest base.ciphertext) := rfl

private def releaseFor (value : ProofPacket Bytes) : ProofRelease :=
  ⟨pin, base.context.cochain,
    ⟨selectedCell, ⟨base.hashes.proposal value, .Valid⟩, base.codec.encode value⟩⟩

private def goodRelease : ProofRelease := releaseFor packet

private def badProofRelease : ProofRelease := releaseFor { packet with proofBytes := [73] }

private def wrongTargetRelease : ProofRelease :=
  let record := goodRelease.record
  let target := { record.target with proposal := { record.target.proposal with round := 1 } }
  { goodRelease with record := { record with target := target } }

private structure Archive where
  root : TCB.Hash32
  objects : List (TCB.Hash32 × Bytes)

private def archive (release : ProofRelease) : Archive :=
  let manifest := release.manifest
  let bytes := manifest.encode
  let digest := Sha256.digestBytes bytes
  let root := Sha256.toHash32 digest
  ⟨root, [(root, bytes), (manifest.directoryRoot, directoryBytes),
    (manifest.snapshotAddress, release.snapshot), (manifest.cochainAddress, release.cochain),
    (manifest.evidenceAddress, release.evidence), (Sha256.toHash32 ciphertextDigest, base.ciphertext)]⟩

private def good : Archive := archive goodRelease
private def badProof : Archive := archive badProofRelease
private def wrongTarget : Archive := archive wrongTargetRelease

private theorem root_from_checked
    (checked : CheckedTransfer base Transfer.Owned.Demo.transfer packetBytes) :
    (ProofRelease.ofChecked directory checked selectedCell ciphertext_named).root = good.root := by
  have same : checked.proof.packet = packet := Option.some.inj
    (checked.proof.decoded.symm.trans (base.codec.decode_encode packet))
  change (⟨⟨base.context.key, pin.directoryRoot⟩, base.context.cochain,
    ⟨selectedCell, ⟨base.hashes.proposal checked.proof.packet, .Valid⟩, packetBytes⟩⟩ :
    ProofRelease).root = good.root
  rw [same]
  rfl

private def fetch (source : Archive) (address : TCB.Hash32) : IO (Option Bytes) :=
  let key := List.ofFn address
  pure ((source.objects.find? fun item => List.ofFn item.1 == key).map Prod.snd)

private def ownerMarker : String := "hodge-proof-stack-demo-v1\n"

private def writeFixture (root : FilePath) : IO Unit := do
  IO.FS.createDir root
  unless (Transfer.Owned.Executable.checkedPacket base Transfer.Owned.Demo.transfer
      packetBytes).isSome do
    throw (IO.userError "Fixture packet failed the original transfer checker")
  IO.FS.writeFile (root / "demo-owner") ownerMarker
  for (name, source) in [("accepted", good), ("bad-proof", badProof), ("wrong-target", wrongTarget)] do
    unless (← restore (root / name) source.root (fetch source)).isSome do
      throw (IO.userError s!"Could not store the fixture at {name}")
  IO.println "Stored the checked packet and two hash-valid negative cases"

private def readRecord (store : FilePath) (expected : Archive) : IO PacketRecord := do
  let some stack ← openStack store expected.root
    | throw (IO.userError "Could not reopen the stack at the expected root")
  let some evidence ← LocalObjects.readObject store stack.manifest.evidenceAddress
    | throw (IO.userError "Could not read the record at its verified address")
  let some record := PacketRecord.decode evidence
    | throw (IO.userError "Stored evidence was not a canonical packet record")
  return record

private def verifyFixture (root : FilePath) : IO Unit := do
  unless (← IO.FS.readFile (root / "demo-owner")) = ownerMarker do
    throw (IO.userError "Use a directory created by the write phase")
  let accepted := root / "accepted"
  let original ← readRecord accepted good
  unless original.packetBytes == packetBytes do
    throw (IO.userError "Stored packet bytes differed from the checked transfer")

  -- The cold checker must reconstruct the ciphertext from the selected cell.
  let profile := { base with ciphertext := [] }
  let transfer := Transfer.Owned.Demo.transfer
  let some successor ← replay accepted good.root profile transfer
    | throw (IO.userError "Cold verification rejected the original checked packet")
  unless successor.marking transfer.input == 0 && successor.marking transfer.output == 1 &&
      decide (transfer.input ∈ successor.spent) &&
      List.ofFn successor.tipHash == List.ofFn original.target.proposal.blockDigest &&
      List.ofFn successor.evidenceRoot == List.ofFn original.target.proposal.evidenceRoot do
    throw (IO.userError "Cold verification did not recover the original successor")

  let badProofStore := root / "bad-proof"
  let altered ← readRecord badProofStore badProof
  let some parsed := base.codec.decode altered.packetBytes
    | throw (IO.userError "The bad-proof fixture was not a canonical transfer packet")
  unless parsed.proofBytes == [73] && parsed.proofBytes != packet.proofBytes do
    throw (IO.userError "The bad-proof fixture did not change the original proof")
  if (← replay badProofStore badProof.root profile transfer).isSome then
    throw (IO.userError "Cold verification accepted altered proof bytes")

  let wrongTargetStore := root / "wrong-target"
  let mismatched ← readRecord wrongTargetStore wrongTarget
  unless mismatched.packetBytes == original.packetBytes &&
      mismatched.target.proposal.round != original.target.proposal.round do
    throw (IO.userError "The wrong-target fixture did not retain the original packet")
  if (← replay wrongTargetStore wrongTarget.root profile transfer).isSome then
    throw (IO.userError "Cold verification accepted a mismatched vote target")

  if same : List.ofFn successor.topologyRoot = List.ofFn (Transfer.Owned.Demo.fixtureHash 41) then
    let spent := Transfer.Owned.Demo.config successor (List.ofFn_injective same)
    if (← replay accepted good.root spent transfer).isSome then
      throw (IO.userError "Cold verification accepted replay against the spent successor")
  else
    throw (IO.userError "Cold verification did not preserve the original topology root")
  IO.println "Cold verification recovered the accepted successor and consumed the original input"
  IO.println "Rejected a canonical packet with altered proof, a mismatched vote target, and replay against the spent successor"

def run (args : List String) : IO Unit :=
  match args with
  | ["write", dir] => writeFixture ⟨dir⟩
  | ["verify", dir] => verifyFixture ⟨dir⟩
  | _ => throw (IO.userError "Usage is write DIR or verify DIR")

end HomotopicalEncryption.Protocol.Storage.PublicStack.ProofDemo

def main (args : List String) : IO Unit :=
  HomotopicalEncryption.Protocol.Storage.PublicStack.ProofDemo.run args
