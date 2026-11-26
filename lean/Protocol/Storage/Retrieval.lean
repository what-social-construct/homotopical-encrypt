module

public import Protocol.Storage.Retrieval.ContentAddress
public import Protocol.Storage.Retrieval.Indexed
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

The focused leaves separate digest-indexed lookup, local ciphertext
authentication, a uniform whole-bucket privacy reference, native
exact/coexact query evaluation with the
original CVP comparison, private recipient recovery, and a conditional
joint-query obstruction. They reuse the original public manifest and HCP
samples. The indexed path consumes a supplied lookup function. The source
of each security claim remains visible: transcript
independence for uniform reads, actual collision alternatives for hashing,
and original Hodge/CVP laws for native correctness. The concrete coupled
decoder and exact rational held-token path retain original bound observations.
The canonical raw two-slot seal derives its public view and ciphertext naming.
A separate original-observation certificate supplies native decoding/message
meaning, and the existing transition anchor retains the same context and seal
in history. Owned signing uses that same canonical manifest root. Availability
and authentication remain explicit. Efficient private-query
sampling and recipient discovery are separate protocol work.
-/
