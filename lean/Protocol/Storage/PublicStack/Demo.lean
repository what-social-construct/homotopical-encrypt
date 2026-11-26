module

public import Protocol.Storage.PublicStack.Release
public import Protocol.Storage.PublicStack.Restore
public import Protocol.Storage.AnchorExamples
public import Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery
meta import Protocol.Storage.PublicStack.Release
meta import Protocol.Storage.PublicStack.Restore
meta import Protocol.Storage.AnchorExamples
meta import Protocol.Transfer.PathSignature.NativeSignSampler.CheckedRecovery

public section

/-!
# Restore an accepted public sheaf stack into a partially populated store

From `lean/`, run `lake env lean --run Protocol/Storage/PublicStack/Demo.lean restore DIR`
with a fresh directory whose parent exists. Then run the same command with
`read DIR` in a separate process. Both phases derive the expected root from
the fixed public release of the accepted equality-history fixture.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack.Demo

open System (FilePath)
open TCB.PrimitiveChecks (Bytes)
open Protocol.Transfer.PathSignature.NativeSignSampler

private def contextKey : ContextKey where
  runId := Examples.hash 22
  schemaVersion := Examples.snapshot.schemaVersion
  snapshotRoot := Examples.snapshot.root
  cochainDigest := Examples.hash 12
  topologyTag := Examples.snapshot.topologyHash
  parameterSet := Examples.hash 30

private def voteTarget : Consensus.VoteTarget where
  proposal := { Ledger.Examples.proposal with
    snapshotRoot := contextKey.snapshotRoot
    cochainRoot := Ledger.Examples.hash 14 }
  judgment := .Valid

private def firstKey : Fin 2 → Bool := ![false, true]
private def firstMessage : Fin 2 → Bool := ![true, false]
private def secondKey : Fin 2 → Bool := ![true, false]
private def secondMessage : Fin 2 → Bool := ![true, true]

private def first : Bytes := ciphertextBytes hadamardTwo 2 3 firstKey firstMessage
private def second : Bytes := ciphertextBytes hadamardTwo 2 (-2) secondKey secondMessage

private def ciphertextAddresses : TCB.Hash32 × TCB.Hash32 :=
  let firstDigest := Sha256.digestBytes first
  let secondDigest := Sha256.digestBytes second
  (Sha256.toHash32 firstDigest, Sha256.toHash32 secondDigest)

private def rows : CellDirectory.Codec.Entries :=
  let (firstAddress, secondAddress) := ciphertextAddresses
  [(1, firstAddress), (2, secondAddress), (3, firstAddress)]

private def directoryBytes : Bytes := CellDirectory.Codec.encode contextKey rows

private def pin : CellDirectory.CheckpointPin :=
  let digest := Sha256.digestBytes directoryBytes
  ⟨contextKey, Sha256.toHash32 digest⟩

private def release : Release := Release.ofPublic pin Examples.zeroPayload voteTarget

/- The equality-history fixture extends the existing accepted cochain example
with an exact cell-directory seal and independently issued public stack root. -/
private def scheme : CheckpointScheme Examples.sheaf ℕ (fun _ => Bytes) Unit where
  requiredSlots := {1, 2, 3}
  entryBound _ _ bytes digest := Sha256.digest bytes = digest
  manifestBound C items root :=
    Sha256.digest (CellDirectory.Codec.encode C.key
      (items.map fun item => (item.slot, item.digest))) = root
  persisted _ _ _ _ := False

private def entry (slot : ℕ) (bytes : Bytes) : ManifestEntry scheme AnchorExamples.context :=
  ⟨⟨slot, bytes, Sha256.digest bytes⟩, rfl⟩

private def cellManifest : OpenManifest scheme AnchorExamples.context :=
  ⟨[entry 1 first, entry 2 second, entry 3 first], by decide⟩

private def cellSeal : SealedManifest scheme AnchorExamples.context where
  manifest := cellManifest
  root := pin.directoryRoot
  complete := by
    intro slot present
    simpa only [scheme, cellManifest, OpenManifest.slots, entry, List.map_cons, List.map_nil,
      Finset.mem_insert, Finset.mem_singleton, List.mem_cons, List.not_mem_nil, or_false] using present
  rootBound := rfl

private def history : HistoryBindings Examples.sheaf (Fin 2) ℕ ℕ (fun _ => Bytes) where
  manifestIncluded candidate C items root blockDigest :=
    candidate = AnchorExamples.candidate ∧ C = AnchorExamples.context ∧
      items = cellSeal.manifest.items ∧ root = cellSeal.root ∧
      blockDigest = AnchorExamples.proposal.blockDigest

private theorem anchor : TransitionAnchor AnchorExamples.topologyBinds history
    AnchorExamples.evidence AnchorExamples.context cellSeal :=
  { policySnapshots := AnchorExamples.anchor.policySnapshots
    snapshotMatches := AnchorExamples.anchor.snapshotMatches
    artifactMatches := AnchorExamples.anchor.artifactMatches
    manifestIncluded := ⟨rfl, rfl, rfl, rfl, rfl⟩ }

private structure NamedRelease where
  manifest : Manifest
  bytes : Bytes
  root : TCB.Hash32

private def nameRelease (publicRelease : Release) : NamedRelease :=
  let manifest := publicRelease.manifest
  let bytes := manifest.encode
  let digest := Sha256.digestBytes bytes
  ⟨manifest, bytes, Sha256.toHash32 digest⟩

private def namedRelease : NamedRelease := nameRelease release

private theorem root_from_anchor :
    (Release.ofAnchor anchor cellSeal.rootBound).root = namedRelease.root := rfl

private def fixtureObjects : List (TCB.Hash32 × Bytes) :=
  let manifest := namedRelease.manifest
  let (firstAddress, secondAddress) := ciphertextAddresses
  [(namedRelease.root, namedRelease.bytes), (pin.directoryRoot, directoryBytes),
    (manifest.snapshotAddress, release.snapshot), (manifest.cochainAddress, release.cochain),
    (manifest.evidenceAddress, release.evidence), (firstAddress, first), (secondAddress, second)]

private def fromFixture (digest : TCB.Hash32) : IO (Option Bytes) :=
  pure ((fixtureObjects.find? fun item => List.ofFn item.1 == List.ofFn digest).map Prod.snd)

private def ownerMarker : String := "hodge-public-stack-restore-demo-v1\n"

private def markerPath (store : FilePath) : FilePath := store / "demo-owner"

private def restoreFixture (root : FilePath) : IO Unit := do
  IO.FS.createDir root
  IO.FS.writeFile (markerPath root) ownerMarker
  let source := root / "source"
  let replica := root / "replica"
  let some _ ← restore source namedRelease.root fromFixture
    | throw (IO.userError "Could not populate the source store")
  unless ← CellDirectory.Persistence.seedObject replica first do
    throw (IO.userError "Could not seed the replica's existing ciphertext")

  let requests ← IO.mkRef ([] : List (List UInt8))
  let fetch (digest : TCB.Hash32) := do
    requests.modify (List.ofFn digest :: ·)
    CellDirectory.Persistence.readObject source digest
  let some copied ← restore replica namedRelease.root fetch
    | throw (IO.userError "Could not restore the accepted release from the source")
  let prior := List.ofFn ciphertextAddresses.1
  let expected := (fixtureObjects.map (List.ofFn ∘ Prod.fst)).filter (· != prior)
  let seen ← requests.get
  unless copied.fetched == 6 && copied.reused == 1 && seen.length == expected.length &&
      expected.all seen.contains do
    throw (IO.userError "Restore did not fetch exactly the missing objects")

  requests.set []
  let some replay ← restore replica namedRelease.root fetch
    | throw (IO.userError "Could not repeat the same restore")
  unless replay.fetched == 0 && replay.reused == 7 && (← requests.get).isEmpty do
    throw (IO.userError "A complete replica requested bytes from the source")

  let otherTarget := { voteTarget with proposal := { voteTarget.proposal with round := 1 } }
  let other := nameRelease (Release.ofPublic pin Examples.zeroPayload otherTarget)
  let otherRoot := List.ofFn other.root
  let otherEvidence := List.ofFn other.manifest.evidenceAddress
  let tryAlternate (badEvidence : Option Bytes) (digest : TCB.Hash32) := do
    let key := List.ofFn digest
    if key == otherRoot then return some other.bytes
    if key == otherEvidence then return badEvidence
    CellDirectory.Persistence.readObject source digest
  if (← restore replica other.root (tryAlternate none)).isSome then
    throw (IO.userError "Restore published a stack with missing evidence")
  if (← restore replica other.root (tryAlternate (some release.evidence))).isSome then
    throw (IO.userError "Restore accepted substituted evidence")
  unless (← openStack replica namedRelease.root).isSome do
    throw (IO.userError "A failed restore displaced the prior accepted root")

  let evidenceAddress := namedRelease.manifest.evidenceAddress
  let evidencePath := CellDirectory.Persistence.objectPath replica evidenceAddress
  IO.FS.writeBinFile evidencePath ⟨release.snapshot.toArray⟩
  requests.set []
  let some repaired ← restore replica namedRelease.root fetch
    | throw (IO.userError "Could not restore the replica's damaged evidence record")
  unless repaired.fetched == 1 && repaired.reused == 6 &&
      (← requests.get) == [List.ofFn evidenceAddress] do
    throw (IO.userError "Repair did not fetch exactly the damaged object")
  IO.println "Restored the accepted public stack, fetching six objects and reusing one ciphertext"
  IO.println "Replayed with zero source requests and rejected missing or substituted evidence"
  IO.println "Repaired a damaged local record with one verified source fetch"

private def readFixture (root : FilePath) : IO Unit := do
  unless (← IO.FS.readFile (markerPath root)) = ownerMarker do
    throw (IO.userError "Use a directory created by this demo's restore phase")
  let replica := root / "replica"
  let some stack ← openStack replica namedRelease.root
    | throw (IO.userError "Could not open the replica at the expected stack root")
  let manifest := stack.manifest
  let snapshot ← CellDirectory.Persistence.readObject replica manifest.snapshotAddress
  let cochain ← CellDirectory.Persistence.readObject replica manifest.cochainAddress
  let evidence ← CellDirectory.Persistence.readObject replica manifest.evidenceAddress
  unless snapshot = some release.snapshot ∧ cochain = some release.cochain ∧
      evidence = some release.evidence do
    throw (IO.userError "The restored public records differ from the original release")
  let some directory ← openDirectory replica stack
    | throw (IO.userError "Could not open the verified directory from the restored stack")
  let some firstRead ← CellDirectory.Persistence.read replica directory 1
    | throw (IO.userError "Could not read the first cell")
  let some secondRead ← CellDirectory.Persistence.read replica directory 2
    | throw (IO.userError "Could not read the second cell")
  unless firstRead = first ∧ secondRead = second ∧
      (← CellDirectory.Persistence.read replica directory 3) = some first do
    throw (IO.userError "The restored ciphertexts differ from the originals")
  let firstRecovered := (CheckedRecovery.recover hadamardTwo 2 3 firstKey firstRead).map List.ofFn
  let secondRecovered :=
    (CheckedRecovery.recover hadamardTwo 2 (-2) secondKey secondRead).map List.ofFn
  unless firstRecovered = some (List.ofFn firstMessage) ∧
      secondRecovered = some (List.ofFn secondMessage) do
    throw (IO.userError "Could not recover both original messages")
  IO.println "Reopened the replica from one trusted root, verified all public roles, and recovered both messages"

def run (args : List String) : IO Unit :=
  match args with
  | ["restore", dir] => restoreFixture ⟨dir⟩
  | ["read", dir] => readFixture ⟨dir⟩
  | _ => throw (IO.userError "Usage is restore DIR or read DIR")

end HomotopicalEncryption.Protocol.Storage.PublicStack.Demo

def main (args : List String) : IO Unit :=
  HomotopicalEncryption.Protocol.Storage.PublicStack.Demo.run args
