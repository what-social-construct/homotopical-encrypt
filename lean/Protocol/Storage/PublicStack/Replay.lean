module

public import Protocol.Storage.PublicStack.ProofRelease
public import Protocol.Storage.PublicStack.Restore
public import Protocol.Transfer.Owned.Executable

public section

/-!
# Recheck a restored transfer transcript

The caller provides the trusted stack root, original before-state and verifier
configuration. The restored directory supplies the ciphertext used to
recompute the transfer's signed manifest. The historical replay returns the
computed successor as a value.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack

open System (FilePath)
open Sheaf CellularSheaf
open TCB.PrimitiveChecks (Bytes)
open Evidence.TransferCodec (encodeVoteTarget encodeVoteTarget_injective)
open Evidence.TransferTranscript (ProofPacket)
open Transfer.Owned (Config ResourceTransfer)
open Transfer.Owned.Executable (successor)

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Recompute the proposal and acceptance verdict from the exact checked packet. -/
@[expose] def PacketRecord.checkPacket [DecidableEq Asset]
    (config : Config F Bytes Asset Receipt) (transfer : ResourceTransfer Bytes)
    (record : PacketRecord) : Option (ProofPacket Bytes) :=
  (Transfer.Owned.Executable.checkedPacket config transfer record.packetBytes).filter fun packet =>
    decide (encodeVoteTarget record.target = encodeVoteTarget ⟨config.hashes.proposal packet, .Valid⟩)

theorem PacketRecord.checkPacket_eq_some_iff [DecidableEq Asset]
    (config : Config F Bytes Asset Receipt) (transfer : ResourceTransfer Bytes)
    (record : PacketRecord) (packet : ProofPacket Bytes) :
    record.checkPacket config transfer = some packet ↔
      Transfer.Owned.Executable.checkedPacket config transfer record.packetBytes = some packet ∧
        record.target = ⟨config.hashes.proposal packet, .Valid⟩ := by
  simp only [checkPacket, Option.filter_eq_some_iff, decide_eq_true_eq,
    encodeVoteTarget_injective.eq_iff]

/-- The computed successor is the accepted transition's actual after-state. -/
theorem PacketRecord.successor_eq_checked [DecidableEq Asset]
    (config : Config F Bytes Asset Receipt) (transfer : ResourceTransfer Bytes)
    (record : PacketRecord) (packet : ProofPacket Bytes)
    (accepted : record.checkPacket config transfer = some packet) :
    ∃ checked : Transfer.Owned.CheckedTransfer config transfer record.packetBytes,
      successor config transfer packet = checked.candidate.after := by
  have packetAccepted := ((record.checkPacket_eq_some_iff config transfer packet).mp accepted).1
  have checkAccepted : Transfer.Owned.check config transfer record.packetBytes = true :=
    (Transfer.Owned.Executable.checkedPacket_isSome_eq_check _ _ _).symm.trans
      (congrArg Option.isSome packetAccepted)
  exact ⟨Transfer.Owned.CheckedTransfer.ofCheck checkAccepted,
    Transfer.Owned.Executable.successor_eq _ _ _ _ packetAccepted⟩

/-- Canonical packet evidence and the complete ciphertext it selects. -/
structure ArchivedPacket where
  record : PacketRecord
  ciphertext : Bytes

/-- Check the restored public inputs and the entire selected ciphertext. -/
def readArchivedPacket (store : FilePath) {root : TCB.Hash32} (stack : Verified root)
    (context : PublicPayloadView) : IO (Option ArchivedPacket) := do
  let manifest := stack.manifest
  let key := context.key
  unless manifest.context = key do return none
  unless (← LocalObjects.readObject store manifest.snapshotAddress) = some (snapshotBytes key) do
    return none
  unless (← LocalObjects.readObject store manifest.cochainAddress) =
      some (cochainBytes context.cochain) do
    return none
  let some evidence ← LocalObjects.readObject store manifest.evidenceAddress | return none
  let some record := PacketRecord.decode evidence | return none
  let some directory ← openDirectory store stack | return none
  let some ciphertext ← CellDirectory.Persistence.read store directory record.cellId
    | return none
  return some ⟨record, ciphertext⟩

/-- Reopen the authorized stack and recheck its packet against the selected ciphertext. -/
def replay [DecidableEq Asset] (store : FilePath) (root : TCB.Hash32)
    (config : Config F Bytes Asset Receipt) (transfer : ResourceTransfer Bytes) :
    IO (Option (Ledger.State ℕ ℕ)) := do
  let some stack ← openStack store root | return none
  let some archived ← readArchivedPacket store stack config.context.publicView | return none
  let oldConfig := { config with ciphertext := archived.ciphertext }
  return (archived.record.checkPacket oldConfig transfer).map (successor oldConfig transfer)

end HomotopicalEncryption.Protocol.Storage.PublicStack
