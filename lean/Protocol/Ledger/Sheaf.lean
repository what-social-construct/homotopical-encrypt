module

public import Protocol.Ledger.State
public import Sheaf.Commitment

@[expose] public section

/-!
# Ledger snapshot adapter for the existing cellular-sheaf payload interpretation

The snapshot carrier is `CochainPayloadInterpretation F`, retaining its actual
sheaf snapshot and decoder. Acceptance is the existing exact-payload predicate.
The 32-byte topology-root relation is supplied on that very sheaf snapshot;
it is not identified with the payload's 16-byte topology tag.
-/

set_option autoImplicit false

namespace Hcrypt
namespace Protocol
namespace Ledger
namespace SnapshotModel

open Sheaf CellularSheaf

variable
  {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/-- Reuse a concrete sheaf payload interpretation as the ledger snapshot. -/
def ofSheaf
    (F : CellularSheaf X)
    (topologyBinds : SheafStateSnapshot F → TCB.Hash32 → Prop) :
    SnapshotModel (CochainPayloadInterpretation F) where
  root I := I.snapshot.root
  accepts I c := AcceptedCommittedOneCochain I c
  topologyBound I topologyRoot := topologyBinds I.snapshot topologyRoot

variable
  {F : CellularSheaf X}
  (topologyBinds : SheafStateSnapshot F → TCB.Hash32 → Prop)
  (I : CochainPayloadInterpretation F)

/-- The ledger names the actual existing sheaf snapshot root. -/
theorem ofSheaf_root :
    (ofSheaf F topologyBinds).root I = I.snapshot.root :=
  rfl

/-- Ledger acceptance uses the original exact committed-cochain predicate. -/
theorem ofSheaf_accepts_iff (c : Axioms.CochainCommitmentData) :
    (ofSheaf F topologyBinds).accepts I c ↔
      AcceptedCommittedOneCochain I c :=
  Iff.rfl

/-- The selected topology-root relation is indexed by the same sheaf snapshot. -/
theorem ofSheaf_topologyBound_iff (topologyRoot : TCB.Hash32) :
    (ofSheaf F topologyBinds).topologyBound I topologyRoot ↔
      topologyBinds I.snapshot topologyRoot :=
  Iff.rfl

variable {I} {c : Axioms.CochainCommitmentData}

/-- An accepted ledger payload retains the existing snapshot-binding proof. -/
theorem ofSheaf_accepts_boundToSnapshot
    (h : (ofSheaf F topologyBinds).accepts I c) :
    I.BoundToSnapshot c :=
  h.boundToSnapshot

/-- Accepted payloads satisfy the original wire-shape contract. -/
theorem ofSheaf_accepts_wellFormed
    (h : (ofSheaf F topologyBinds).accepts I c) :
    c.WellFormed :=
  h.wireWellFormed

/-- The declared tag matches the same snapshot, separately from topology roots. -/
theorem ofSheaf_accepts_topologyHash
    (h : (ofSheaf F topologyBinds).accepts I c) :
    c.topology_hash = I.snapshot.topologyHash :=
  h.boundToSnapshot.2.2.1

/-- The decoded accepted ledger payload is an exact one-cochain. -/
theorem ofSheaf_accepts_decoded_isExactOneCochain
    (h : (ofSheaf F topologyBinds).accepts I c) :
    F.IsExactOneCochain (I.decode c) :=
  h.decoded_isExactOneCochain

/-- The same decoded payload is a cocycle by the existing sheaf theorem. -/
theorem ofSheaf_accepts_decoded_isOneCocycle
    (h : (ofSheaf F topologyBinds).accepts I c) :
    F.IsOneCocycle (I.decode c) :=
  h.decoded_isOneCocycle

/-- Accepted payloads have the coordinate count of the concrete sheaf. -/
theorem ofSheaf_accepts_edgeValues_length
    (h : (ofSheaf F topologyBinds).accepts I c) :
    c.edge_values.length = F.edgeCoordinateCount :=
  h.edgeValues_length_eq_edgeCoordinateCount

end SnapshotModel
end Ledger
end Protocol
end Hcrypt
