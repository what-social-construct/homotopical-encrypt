module

public import Protocol.Storage.PublicStack.HistoryIndex
public import Protocol.Storage.PublicStack.Replay

public section

/-!
# Ordered historical replay from one trusted checkpoint

The caller supplies the authenticated index root, initial ledger state, and
fixed verifier profile. Each listed child stack is opened by its address.
The checked successor of one transfer is the before-state of the next.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.PublicStack

open System (FilePath)
open Sheaf CellularSheaf
open TCB.PrimitiveChecks (Bytes)
open Transfer.Owned (CheckedTransfer Config ResourceTransfer)
open Transfer.Owned.Executable (successor)

variable {Vertex Edge Face Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- Evaluate the current history roots once before embedding them in another
packet. Subsequent reads index the computed bytes. -/
@[expose] def materializeStateRoots (state : Ledger.State ℕ ℕ) : Ledger.State ℕ ℕ :=
  let tip := Array.ofFn state.tipHash
  let evidence := Array.ofFn state.evidenceRoot
  { state with
    tipHash := fun i => tip[i.val]'(by simpa only [tip, Array.size_ofFn] using i.isLt)
    evidenceRoot := fun i => evidence[i.val]'(by simpa only [evidence, Array.size_ofFn] using i.isLt) }

@[simp] theorem materializeStateRoots_eq (state : Ledger.State ℕ ℕ) :
    materializeStateRoots state = state := by
  cases state
  simp [materializeStateRoots]

/-- Recover the declared transfer and run the existing checker on this step.
The successor preserves the topology named by the fixed verifier profile. -/
@[expose] def ArchivedPacket.advance [DecidableEq Asset] (archived : ArchivedPacket)
    (config : Config F Bytes Asset Receipt) : Option (Config F Bytes Asset Receipt) :=
  let current := { config with ciphertext := archived.ciphertext }
  (current.codec.decode archived.record.packetBytes).bind fun decoded =>
    let transfer := decoded.intent.transfer
    (archived.record.checkPacket current transfer).map fun packet =>
      { current with
        before := materializeStateRoots (successor current transfer packet)
        topologyBound := current.topologyBound }

/-- Every computed step has the actual checked transfer from its supplied state. -/
theorem ArchivedPacket.advance_sound [DecidableEq Asset] (archived : ArchivedPacket)
    (config next : Config F Bytes Asset Receipt) (accepted : archived.advance config = some next) :
    let current := { config with ciphertext := archived.ciphertext }
    ∃ (transfer : ResourceTransfer Bytes)
      (checked : CheckedTransfer current transfer archived.record.packetBytes),
      next.before = checked.candidate.after := by
  unfold advance at accepted
  dsimp only at accepted ⊢
  obtain ⟨decoded, _, result⟩ := Option.bind_eq_some_iff.mp accepted
  obtain ⟨packet, verified, rfl⟩ := Option.map_eq_some_iff.mp result
  obtain ⟨checked, stateEq⟩ := archived.record.successor_eq_checked _ _ _ verified
  exact ⟨decoded.intent.transfer, checked, by simpa only [materializeStateRoots_eq] using stateEq⟩

/-- Verify and advance one archived step from an authenticated history link. -/
def advanceNamedStack [DecidableEq Asset] (store : FilePath) (root : TCB.Hash32)
    (current : Config F Bytes Asset Receipt) : IO (Option (Config F Bytes Asset Receipt)) := do
  let some stack ← openNamedStack store root | return none
  let some archived ← readArchivedPacket store stack current.context.publicView | return none
  return archived.advance current

/-- Replay the canonical index in order from the independently trusted state.
The store supplies the named artifacts. A missing or rejected step fails the replay. -/
def replayHistory [DecidableEq Asset] (store : FilePath) (historyRoot : TCB.Hash32)
    (initial : Config F Bytes Asset Receipt) : IO (Option (Ledger.State ℕ ℕ)) := do
  let some bytes ← LocalObjects.readFile (LocalObjects.objectPath store historyRoot)
    | return none
  let some history := HistoryIndex.verify historyRoot bytes | return none
  let mut current := initial
  for root in history.roots do
    let some next ← advanceNamedStack store root current | return none
    current := next
  return some current.before

end HomotopicalEncryption.Protocol.Storage.PublicStack
