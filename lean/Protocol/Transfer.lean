module

public import Protocol.Transfer.Owned
public import Protocol.Transfer.Anchored
public import Protocol.Transfer.PublicView
public import Protocol.Transfer.Security
public import Protocol.Transfer.Primitives
public import Protocol.Transfer.Authorization

@[expose] public section

/-!
# The bounded owned-resource transfer profile

Actual byte/metadata/intent checks and explicit primitive soundness derive one
fixed-snapshot resource transition, represented in the original evidence and
manifest interfaces. The same checks without assumed primitive soundness give
a one-shot accepted-invalid reduction and sampled error-composition theorem.
The exact released record retains its public identifiers and original objects.
Primitive error bounds, cryptographic implementations, ledger geometry migration
and finality remain separate obligations.

The primitive adapter refines the error decomposition into fresh-message
signature forgery, key compromise, queried-message authorization mismatch,
backend proof false acceptance and backend-to-original-statement mismatch.
Its algorithm-agreement equations and finite signing history are explicit;
the existing Rust spectral paths do not automatically instantiate them.

Full-intent owner signing reuses the existing packet codec, subject and
owner-key map. An authorized issuance batch projects to the existing query
history; full message reflection excludes queried unauthorized intents under
the same fixed policy and an explicit foreign-domain condition. Its PMF bound
retains four primitive/context failure terms. Concrete serialization, key
setup, arbitrary-history coverage and numerical security remain obligations.
-/
