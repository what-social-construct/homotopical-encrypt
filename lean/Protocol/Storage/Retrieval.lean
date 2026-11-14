module

public import Protocol.Storage.Retrieval.ContentAddress
public import Protocol.Storage.Retrieval.UniformRead
public import Protocol.Storage.Retrieval.HodgeQuery
public import Protocol.Storage.Retrieval.Recovery
public import Protocol.Storage.Retrieval.Coupled
public import Protocol.Storage.Retrieval.Native
public import Protocol.Storage.Retrieval.NativeAnchored
public import Protocol.Storage.Retrieval.LinearQueryObstruction

@[expose] public section

/-!
# Hash-indexed retrieval and native Hodge query analysis

The focused leaves separate local ciphertext authentication, a uniform whole-
bucket privacy reference, native exact/coexact query evaluation with the
original CVP comparison, private recipient recovery, and a conditional
joint-query obstruction. They reuse the original public manifest and HCP
samples. No new database, fibration, key registry or proof-system carrier is
introduced. The source of each security claim remains visible: transcript
independence for uniform reads, actual collision alternatives for hashing,
and original Hodge/CVP laws for native correctness. The concrete coupled
decoder and exact rational held-token path retain original bound observations.
The native two-slot seal derives the target view and ciphertext naming, with
same-context recovery/history association through the existing transition
anchor. Availability/authentication remain explicit; the old owned-transfer
packet still uses its one-slot exact-artifact manifest. Efficient private-query
sampling and recipient discovery are separate protocol work.
-/
