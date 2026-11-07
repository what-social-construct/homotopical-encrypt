module

public import Protocol.Transfer.Owned
public import Protocol.Transfer.Anchored
public import Protocol.Transfer.PublicView
public import Protocol.Transfer.Security

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
-/
