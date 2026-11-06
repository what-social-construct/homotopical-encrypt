module

public import Protocol.Transfer.Owned
public import Protocol.Transfer.Anchored

@[expose] public section

/-!
# The bounded owned-resource transfer profile

Actual byte/metadata/intent checks and explicit primitive soundness derive one
fixed-snapshot resource transition, represented in the original evidence and
manifest interfaces. Public spend identifiers, typed acyclic hash preimages
and exact source objects remain explicit. This exports no cryptographic
implementation, ledger geometry migration or finality theorem.
-/
