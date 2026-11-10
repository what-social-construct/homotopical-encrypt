module

public import Protocol.Ledger.ValueFlow
public import Protocol.Ledger.Nullifier
public import TCB.ProofCarrying

@[expose] public section

/-!
# Public state for the first conservative protocol transition

`Resource` and `Nullifier` are application-owned types. Resource quantities
use mathlib's finite nonnegative markings; there is no account/UTXO choice
or new cochain carrier here. Hashes name public objects but are not themselves
proofs that those objects are bound. The evidence layer supplies indexed
binding relations for the actual states and artifacts.
-/

namespace HomotopicalEncryption.Protocol.Ledger

/-- Semantic state and public context for a bounded ledger transition.
The root of the state itself is named by a proposal, not stored recursively
inside its own hash preimage. Concrete root encodings remain a runtime profile.
-/
structure State (Resource Nullifier : Type) where
  marking : Marking Resource
  spent : Finset Nullifier
  tipHash : TCB.Hash32
  height : ℕ
  epoch : ℕ
  snapshotRoot : TCB.Hash32
  topologyRoot : TCB.Hash32
  cochainRoot : TCB.Hash32
  evidenceRoot : TCB.Hash32

/-- Interface over an existing snapshot/interpretation object.
`ofSheaf` in `Ledger.Sheaf` instantiates this with the existing cellular
sheaf payload interpretation; this structure does not replace that snapshot.
The 16-byte topology tag is not identified with a 32-byte topology root.
-/
structure SnapshotModel (Snapshot : Type*) where
  root : Snapshot → TCB.Hash32
  accepts : Snapshot → Axioms.CochainCommitmentData → Prop
  topologyBound : Snapshot → TCB.Hash32 → Prop

end HomotopicalEncryption.Protocol.Ledger
