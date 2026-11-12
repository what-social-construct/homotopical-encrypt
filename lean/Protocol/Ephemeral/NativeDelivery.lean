module

public import Protocol.Ephemeral.NativeTransport
public import Protocol.Storage.HCP
public import Protocol.Storage.CoupledBinding

@[expose] public section

/-!
# Native token delivery on the original storage contexts

The one existing scoped-delivery receipt now retains the canonical native
token. Its delivery relation receives the exact token bytes and complete
recipient/epoch/context scope. Token generation derives those context names
from the actual contexts, rather than accepting independent header fields.

The executable use path checks scope, token bytes/hash and ciphertext bytes/hash
before exact rational migration or retained-base recovery. Authorization and
envelope delivery remain explicit application relations; protection of the
envelope requires a separate cryptographic construction and security argument.
Scope equality is neither caller authentication nor replay/freshness enforcement.
This is a reusable context/profile-scoped capability. The selected full
ciphertext digest is checked separately and is not identified with the exact
artifact digest in the original context key. A per-ciphertext or single-use
authorization profile needs its own explicit policy.
Possession of copied matrix data permits off-API application; these scope
checks do not cryptographically confine or revoke that data.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Ephemeral.NativeDelivery

open Sheaf CellularSheaf HCPCoupledFamily
open Storage

variable {rows cols : ℕ}

abbrev Bytes := List UInt8

/-- One scoped channel contract binds its envelope to the exact canonical token.
No encryption or authentication algorithm is inferred from these relations. -/
def contract {Envelope : Type*}
    (Authorized : TransportToken.Scope → Prop)
    (DeliversBytes : TransportToken.Scope → Bytes → Envelope → Prop) :
    ScopedDeliveryContract (TransportToken.Token rows cols) TCB.Hash32 Envelope where
  Authorized := Authorized
  Delivers scope token envelope := token.scope = scope ∧
    DeliversBytes scope (TransportToken.encode token) envelope

/-- Generate the derived map with scope names from the actual source/target contexts. -/
def tokenFor {B C : Matrix (Fin rows) (Fin cols) ℤ}
    (recipient : TCB.Hash32) (sourceEpoch targetEpoch : ℕ)
    (source : Context (sheaf B)) (target : Context (sheaf C)) : TransportToken.Token rows cols :=
  NativeTransport.derive (DeliveryScope.forContexts recipient sourceEpoch targetEpoch source target) B C

/-- The existing concrete private-presentation binding fixes the original
snapshot names retained in the token; no new snapshot or root is manufactured. -/
theorem tokenFor_snapshot_roots (hash : Bytes → TCB.Hash32)
    {B C : Matrix (Fin rows) (Fin cols) ℤ}
    (recipient : TCB.Hash32) (sourceEpoch targetEpoch : ℕ)
    (source : Context (sheaf B)) (target : Context (sheaf C))
    (sourceBound : CoupledBinding.BindsSnapshot hash B source.interpretation.snapshot)
    (targetBound : CoupledBinding.BindsSnapshot hash C target.interpretation.snapshot) :
    (tokenFor recipient sourceEpoch targetEpoch source target).scope.source.snapshotRoot =
        hash (CoupledCodec.encode (CoupledCodec.ofMatrix B)) ∧
      (tokenFor recipient sourceEpoch targetEpoch source target).scope.target.snapshotRoot =
        hash (CoupledCodec.encode (CoupledCodec.ofMatrix C)) :=
  ⟨sourceBound.symm, targetBound.symm⟩

variable {Envelope : Type*}
  {Authorized : TransportToken.Scope → Prop}
  {DeliversBytes : TransportToken.Scope → Bytes → Envelope → Prop}
  {B C : Matrix (Fin rows) (Fin cols) ℤ}
  {material : TransportToken.Token rows cols}
  {recipient : TCB.Hash32} {sourceEpoch targetEpoch : ℕ}
  {source : Context (sheaf B)} {target : Context (sheaf C)}

/-- Specialize the existing receipt; no parallel delivery carrier is introduced. -/
abbrev Receipt :=
  ScopedDelivery (contract (rows := rows) (cols := cols) Authorized DeliversBytes)
    material recipient sourceEpoch targetEpoch source target

theorem delivered_encoding (delivery : Receipt (material := material)
    (Authorized := Authorized) (DeliversBytes := DeliversBytes)
    (source := source) (target := target) (recipient := recipient)
    (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch)) :
    DeliversBytes delivery.scope
      (TransportToken.encode material)
      delivery.envelope := delivery.delivered.2

/-- Execute with the receipt's original scope and canonical material digest. -/
def migrateFor
    (delivery : Receipt (material := material) (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := target) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch))
    (hash : Bytes → TCB.Hash32) (request : TransportToken.Scope)
    (tokenBytes : Bytes) (ciphertextDigest : TCB.Hash32) (ciphertextBytes : Bytes) : Option Bytes :=
  delivery.useFor (fun material bytes => NativeTransport.migrateChecked (rows := rows) (cols := cols)
    hash delivery.scope
    (hash (TransportToken.encode material)) tokenBytes ciphertextDigest bytes) request ciphertextBytes

/-- Retained-base recovery uses the same original receipt and the explicit private source key. -/
def recoverFor
    (delivery : Receipt (material := material) (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := target) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch))
    (hash : Bytes → TCB.Hash32) (request : TransportToken.Scope)
    (tokenBytes : Bytes) (ciphertextDigest : TCB.Hash32) (ciphertextBytes : Bytes) :
    Option (Fin cols → ℤ) :=
  delivery.useFor (fun material bytes => NativeTransport.recoverChecked hash B delivery.scope
    (hash (TransportToken.encode material)) tokenBytes ciphertextDigest bytes) request ciphertextBytes

theorem migrateFor_sample
    (delivery : Receipt (material := tokenFor recipient sourceEpoch targetEpoch source target)
      (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := target) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch))
    (hash : Bytes → TCB.Hash32) (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    migrateFor delivery hash delivery.scope
        (TransportToken.encode (tokenFor recipient sourceEpoch targetEpoch source target))
        (hash (CoupledCiphertext.sampleBytes B z a u)) (CoupledCiphertext.sampleBytes B z a u) =
      some (CoupledCiphertext.sampleBytes C z a u) := by
  rw [migrateFor, ScopedDelivery.useFor_scope]
  exact NativeTransport.migrateChecked_derive_sample hash _ B C z a u

theorem recoverFor_sample
    (delivery : Receipt (material := tokenFor recipient sourceEpoch targetEpoch source target)
      (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := target) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch))
    (hash : Bytes → TCB.Hash32) (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    recoverFor delivery hash delivery.scope
        (TransportToken.encode (tokenFor recipient sourceEpoch targetEpoch source target))
        (hash (CoupledCiphertext.sampleBytes C z a u)) (CoupledCiphertext.sampleBytes C z a u) =
      some z := by
  rw [recoverFor, ScopedDelivery.useFor_scope]
  exact NativeTransport.recoverChecked_derive_sample hash _ B C z a u

theorem migrateFor_none_of_scope_ne
    (delivery : Receipt (material := material) (Authorized := Authorized) (DeliversBytes := DeliversBytes)
      (source := source) (target := target) (recipient := recipient)
      (sourceEpoch := sourceEpoch) (targetEpoch := targetEpoch))
    (hash : Bytes → TCB.Hash32) (request : TransportToken.Scope) (wrong : request ≠ delivery.scope)
    (tokenBytes : Bytes) (ciphertextDigest : TCB.Hash32) (ciphertextBytes : Bytes) :
    migrateFor delivery hash request tokenBytes ciphertextDigest ciphertextBytes = none :=
  delivery.useFor_eq_none_of_scope_ne _ request wrong ciphertextBytes

end HomotopicalEncryption.Protocol.Ephemeral.NativeDelivery
