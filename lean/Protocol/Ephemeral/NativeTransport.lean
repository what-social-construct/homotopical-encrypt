module

public import HCP.CoupledRational
public import Protocol.Ephemeral.TransportToken
public import Protocol.Storage.CoupledCiphertext.Layout

@[expose] public section

/-!
# Exact native transport using the scoped derived token

Only the derived rational operator is placed in a token. Its reindexing uses
the original ciphertext coordinate ordering. Byte migration and retained-base
recovery execute with rational arithmetic and reject nonintegral output when
integer ciphertext bytes are required. Generated samples satisfy that guard.

The checked functions validate canonical bytes, full scope and named hashes.
They do not authorize a caller or provide confidential delivery. The separate
native delivery adapter retains those contracts on the original contexts.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Ephemeral.NativeTransport

open Sheaf HCPCoupledFamily
open Storage
open HCP.CoupledRational

variable {rows cols : ℕ}

abbrev Bytes := List UInt8
abbrev Cochain := RationalCochain (Fin rows) (Fin cols)
abbrev Token := TransportToken.Token rows cols

/-- Generate only the derived operator and actual delivery scope as token data. -/
def derive (scope : TransportToken.Scope)
    (B C : Matrix (Fin rows) (Fin cols) ℤ) : Token (rows := rows) (cols := cols) where
  scope := scope
  operator := CoupledCiphertext.matrixToFinite (transportMatrix B C)

/-- Read the token operator in the original cochain coordinate index. -/
def indexedMatrix (token : Token (rows := rows) (cols := cols)) :
    Matrix (Index (Fin rows) (Fin cols)) (Index (Fin rows) (Fin cols)) ℚ :=
  CoupledCiphertext.matrixFromFinite token.operator

/-- Exact application needs the derived operator, not the private matrices. -/
def apply (token : Token (rows := rows) (cols := cols))
    (v : Cochain (rows := rows) (cols := cols)) : Cochain (rows := rows) (cols := cols) :=
  (indexedMatrix token).mulVec v

/-- Compute the inverse of the derived token by exact rational arithmetic. -/
def applyInverse (token : Token (rows := rows) (cols := cols))
    (v : Cochain (rows := rows) (cols := cols)) : Cochain (rows := rows) (cols := cols) :=
  (exactInverse (indexedMatrix token)).mulVec v

@[simp] theorem indexedMatrix_derive (scope : TransportToken.Scope)
    (B C : Matrix (Fin rows) (Fin cols) ℤ) :
    indexedMatrix (derive scope B C) = transportMatrix B C := by
  simp [indexedMatrix, derive]

theorem apply_derive (scope : TransportToken.Scope)
    (B C : Matrix (Fin rows) (Fin cols) ℤ) (v : Cochain) :
    apply (derive scope B C) v = applyTransport B C v := by
  simp [apply, applyTransport]

theorem applyInverse_derive (scope : TransportToken.Scope)
    (B C : Matrix (Fin rows) (Fin cols) ℤ) (v : Cochain) :
    applyInverse (derive scope B C) v = applyTransport C B v := by
  simp [applyInverse, exactInverse_transportMatrix, applyTransport]

theorem apply_derive_sample (scope : TransportToken.Scope)
    (B C : Matrix (Fin rows) (Fin cols) ℤ) (z : Fin cols → ℤ)
    (a : ℤ) (u : Fin rows → ℤ) :
    apply (derive scope B C) (sampleVector B z a u) = sampleVector C z a u := by
  rw [apply_derive, applyTransport_sampleVector]

theorem applyInverse_derive_sample (scope : TransportToken.Scope)
    (B C : Matrix (Fin rows) (Fin cols) ℤ) (z : Fin cols → ℤ)
    (a : ℤ) (u : Fin rows → ℤ) :
    applyInverse (derive scope B C) (sampleVector C z a u) = sampleVector B z a u := by
  rw [applyInverse_derive, applyTransport_sampleVector]

/-- Retained-base recovery uses the token inverse and the exact source decoder. -/
def recoverWithBase (B : Matrix (Fin rows) (Fin cols) ℤ)
    (token : Token (rows := rows) (cols := cols))
    (v : Cochain (rows := rows) (cols := cols)) : Option (Fin cols → ℤ) :=
  decodeCoefficients B (applyInverse token v)

theorem recoverWithBase_derive_sample (scope : TransportToken.Scope)
    (B C : Matrix (Fin rows) (Fin cols) ℤ) (z : Fin cols → ℤ)
    (a : ℤ) (u : Fin rows → ℤ) :
    recoverWithBase B (derive scope B C) (sampleVector C z a u) = some z := by
  rw [recoverWithBase, applyInverse_derive_sample, decodeCoefficients_sampleVector]

/-- Exact integer embedding of the original finite ciphertext coordinates. -/
def rationalize (v : CoupledCiphertext.IntegerCochain rows cols) :
    Cochain (rows := rows) (cols := cols) :=
  fun p => (v p : ℚ)

/-- An integer codec receives output only if every rational coordinate is integral. -/
def integerCoordinates (v : Cochain (rows := rows) (cols := cols)) :
    Option (CoupledCiphertext.IntegerCochain rows cols) :=
  if ∀ p, (v p).den = 1 then some (fun p => (v p).num) else none

@[simp] theorem integerCoordinates_rationalize (v : CoupledCiphertext.IntegerCochain rows cols) :
    integerCoordinates (rationalize v) = some v := by
  simp [integerCoordinates, rationalize]

/-- Migrate canonical full ciphertext bytes with a held token. -/
def migrateBytes (token : Token (rows := rows) (cols := cols)) (bytes : Bytes) : Option Bytes := do
  let v ← CoupledCiphertext.decode rows cols bytes
  let target ← integerCoordinates (apply token (rationalize v))
  some (CoupledCiphertext.encode target)

/-- Recover original coefficients from canonical target bytes with a retained base key. -/
def recoverBytesWithBase (B : Matrix (Fin rows) (Fin cols) ℤ)
    (token : Token (rows := rows) (cols := cols)) (bytes : Bytes) : Option (Fin cols → ℤ) := do
  let v ← CoupledCiphertext.decode rows cols bytes
  recoverWithBase B token (rationalize v)

theorem migrateBytes_derive_sample (scope : TransportToken.Scope)
    (B C : Matrix (Fin rows) (Fin cols) ℤ) (z : Fin cols → ℤ)
    (a : ℤ) (u : Fin rows → ℤ) :
    migrateBytes (derive scope B C) (CoupledCiphertext.sampleBytes B z a u) =
      some (CoupledCiphertext.sampleBytes C z a u) := by
  simp only [migrateBytes, CoupledCiphertext.decode_sampleBytes]
  change (do
    let target ← integerCoordinates (apply (derive scope B C) (sampleVector B z a u))
    some (CoupledCiphertext.encode target)) = _
  rw [apply_derive_sample]
  change (do
    let target ← integerCoordinates (rationalize (HCPCoupledEncoding.integerObserved C z a u))
    some (CoupledCiphertext.encode target)) = _
  simp [CoupledCiphertext.sampleBytes]

theorem recoverBytes_derive_sample (scope : TransportToken.Scope)
    (B C : Matrix (Fin rows) (Fin cols) ℤ) (z : Fin cols → ℤ)
    (a : ℤ) (u : Fin rows → ℤ) :
    recoverBytesWithBase B (derive scope B C) (CoupledCiphertext.sampleBytes C z a u) = some z := by
  simp only [recoverBytesWithBase, CoupledCiphertext.decode_sampleBytes]
  exact recoverWithBase_derive_sample scope B C z a u

/-- Canonical scope/token and source-ciphertext hash checks precede migration. -/
def migrateChecked (hash : Bytes → TCB.Hash32) (expected : TransportToken.Scope)
    (tokenDigest : TCB.Hash32) (tokenBytes : Bytes)
    (ciphertextDigest : TCB.Hash32) (ciphertextBytes : Bytes) : Option Bytes := do
  let token ← TransportToken.check rows cols hash expected tokenDigest tokenBytes
  let v ← CoupledCiphertext.check rows cols hash ciphertextDigest ciphertextBytes
  let target ← integerCoordinates (apply token (rationalize v))
  some (CoupledCiphertext.encode target)

/-- The same token checks guard the exact retained-base recovery algorithm. -/
def recoverChecked (hash : Bytes → TCB.Hash32) (B : Matrix (Fin rows) (Fin cols) ℤ)
    (expected : TransportToken.Scope) (tokenDigest : TCB.Hash32) (tokenBytes : Bytes)
    (ciphertextDigest : TCB.Hash32) (ciphertextBytes : Bytes) : Option (Fin cols → ℤ) := do
  let token ← TransportToken.check rows cols hash expected tokenDigest tokenBytes
  let v ← CoupledCiphertext.check rows cols hash ciphertextDigest ciphertextBytes
  recoverWithBase B token (rationalize v)

/-- Full canonical token/source-byte execution produces the target's original bytes. -/
theorem migrateChecked_derive_sample (hash : Bytes → TCB.Hash32)
    (scope : TransportToken.Scope) (B C : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    migrateChecked (rows := rows) (cols := cols) hash scope
        (hash (TransportToken.encode (derive scope B C))) (TransportToken.encode (derive scope B C))
        (hash (CoupledCiphertext.sampleBytes B z a u)) (CoupledCiphertext.sampleBytes B z a u) =
      some (CoupledCiphertext.sampleBytes C z a u) := by
  have ht := TransportToken.check_encode hash (derive scope B C)
  change TransportToken.check rows cols hash scope _ _ = _ at ht
  simp only [migrateChecked, ht, CoupledCiphertext.sampleBytes,
    CoupledCiphertext.check_encode]
  change (do
    let target ← integerCoordinates (apply (derive scope B C) (sampleVector B z a u))
    some (CoupledCiphertext.encode target)) = _
  rw [apply_derive_sample]
  change (do
    let target ← integerCoordinates (rationalize (HCPCoupledEncoding.integerObserved C z a u))
    some (CoupledCiphertext.encode target)) = _
  simp

/-- Full canonical token/target-byte execution recovers the original integer coefficients. -/
theorem recoverChecked_derive_sample (hash : Bytes → TCB.Hash32)
    (scope : TransportToken.Scope) (B C : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    recoverChecked hash B scope
        (hash (TransportToken.encode (derive scope B C))) (TransportToken.encode (derive scope B C))
        (hash (CoupledCiphertext.sampleBytes C z a u)) (CoupledCiphertext.sampleBytes C z a u) =
      some z := by
  have ht := TransportToken.check_encode hash (derive scope B C)
  change TransportToken.check rows cols hash scope _ _ = _ at ht
  simp only [recoverChecked, ht, CoupledCiphertext.sampleBytes,
    CoupledCiphertext.check_encode]
  exact recoverWithBase_derive_sample scope B C z a u

theorem migrateChecked_none_of_scope_ne (hash : Bytes → TCB.Hash32)
    (expected : TransportToken.Scope) (token : Token (rows := rows) (cols := cols))
    (wrong : token.scope ≠ expected) (tokenDigest ciphertextDigest : TCB.Hash32)
    (bytes : Bytes) :
    migrateChecked (rows := rows) (cols := cols) hash expected tokenDigest
        (TransportToken.encode token) ciphertextDigest bytes = none := by
  simp [migrateChecked, TransportToken.check_none_of_scope_ne hash expected token wrong tokenDigest]

/-- An accepted operator under a named derived-token digest acts as the native
transport, or the accepted canonical bytes exhibit an actual hash collision.
Parsing an arbitrary invertible matrix alone would not supply this relation. -/
theorem checked_operator_original_or_collision (hash : Bytes → TCB.Hash32)
    (scope : TransportToken.Scope) (B C : Matrix (Fin rows) (Fin cols) ℤ)
    (bytes : Bytes) (token : Token (rows := rows) (cols := cols))
    (checked : TransportToken.check rows cols hash scope
      (hash (TransportToken.encode (derive scope B C))) bytes = some token)
    (v : Cochain) :
    apply token v = applyTransport B C v ∨
      (bytes ≠ TransportToken.encode (derive scope B C) ∧
        hash bytes = hash (TransportToken.encode (derive scope B C))) := by
  rcases TransportToken.check_original_or_collision hash scope (derive scope B C) token bytes checked
    with same | collision
  · subst token
    exact Or.inl (apply_derive scope B C v)
  · exact Or.inr collision

end HomotopicalEncryption.Protocol.Ephemeral.NativeTransport
