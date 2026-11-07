module

public import TCB.ProofCarrying

@[expose] public section

/-!
# Actual primitive checks and their failure events

These interfaces retain the concrete byte-level verification algorithms and
the corresponding statement or signing history. They assume no semantic
soundness, zero knowledge, cryptographic error estimate or security parameter.

A verified signature is classified using the actual key, message bytes,
recorded signing queries and compromised-key predicate. The `Forgery` event
requires an uncompromised key and an unqueried message. Its name does not
assert an EUF-CMA theorem: a sampled key-generation, query and corruption game
must supply that theorem separately.

A proof backend's `Holds` predicate is indexed by the exact public-input bytes
it verifies. Relating those bytes and that predicate to an owner intent,
original cochain interpretation or accepted ledger update is a higher-level
encoding and semantic-refinement obligation.

The existing proof-carrying TCB carriers package already-established semantic
facts. This module instead records raw algorithms and actual failure events;
neither successful verification nor a proof-system label alone supplies truth.
-/

set_option autoImplicit false

namespace Hcrypt.TCB.PrimitiveChecks

/-- Concrete message, signature, proof or public-input bytes. -/
abbrev Bytes := List UInt8

/-- A selected signature-checking algorithm, without a soundness assumption. -/
structure SignatureVerifier (Key : Type) where
  verify : Key → Bytes → Bytes → Bool

/-- A recorded signing-query history and selected compromised-key predicate.
This record alone makes no claim that an execution generated the history. -/
structure SignatureHistory (Key : Type) where
  queries : List (Key × Bytes)
  compromised : Key → Prop

namespace SignatureHistory

variable {Key : Type}

/-- This exact key/message pair appears in the supplied byte-level query log. -/
def Queried (history : SignatureHistory Key) (key : Key) (message : Bytes) : Prop :=
  (key, message) ∈ history.queries

/-- Actual verified output on an uncompromised key and an unqueried message. -/
def Forgery (history : SignatureHistory Key) (backend : SignatureVerifier Key)
    (key : Key) (message signature : Bytes) : Prop :=
  backend.verify key message signature = true ∧
    ¬ history.compromised key ∧ ¬ history.Queried key message

/-- Verification alone permits a forgery, a compromised key or a previously
queried message. No owner-authorization conclusion is inferred from it. -/
theorem verified_cases (history : SignatureHistory Key) (backend : SignatureVerifier Key)
    (key : Key) (message signature : Bytes)
    (verified : backend.verify key message signature = true) :
    history.Forgery backend key message signature ∨
      history.compromised key ∨ history.Queried key message := by
  classical
  by_cases compromised : history.compromised key
  · exact Or.inr (Or.inl compromised)
  · by_cases queried : history.Queried key message
    · exact Or.inr (Or.inr queried)
    · exact Or.inl ⟨verified, compromised, queried⟩

end SignatureHistory

/-- A selected proof-checking algorithm and its exact byte-indexed statement.
The backend statement need not imply any particular higher-level predicate. -/
structure ProofVerifier where
  verify : Bytes → Bytes → Bool
  Holds : Bytes → Prop

namespace ProofVerifier

/-- The actual backend accepts bytes whose declared backend statement is false. -/
def FalseAccept (backend : ProofVerifier) (input proof : Bytes) : Prop :=
  backend.verify input proof = true ∧ ¬ backend.Holds input

/-- A successful backend check either has a true backend statement or exhibits
false acceptance. Higher-level statement reflection is a separate obligation. -/
theorem verified_cases (backend : ProofVerifier) (input proof : Bytes)
    (verified : backend.verify input proof = true) :
    backend.Holds input ∨ backend.FalseAccept input proof := by
  classical
  by_cases holds : backend.Holds input
  · exact Or.inl holds
  · exact Or.inr ⟨verified, holds⟩

end ProofVerifier

end Hcrypt.TCB.PrimitiveChecks
