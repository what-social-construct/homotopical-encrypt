# Consensus Status

The former consensus design has been archived at
[`archive/CONSENSUS.md`](archive/CONSENSUS.md). It treated spectral geometry as
if it directly supplied stake, agreement, and finality; those identifications
are no longer part of the active architecture.

Current sources:

- [`PROTOCOL_PARITY_QUEUE.md`](PROTOCOL_PARITY_QUEUE.md) tracks the proved
  authenticated weighted-quorum kernel and the remaining consensus work.
- [`../papers/paper2/README.md`](../papers/paper2/README.md) states the Paper 2
  consensus and Proof-of-Value scope.
- [`SEMANTIC_OWNERSHIP.md`](SEMANTIC_OWNERSHIP.md) fixes the meanings of
  `SheafState`, task-sheaf global sections, and the three distinct Laplacians.

Proof-carrying validity may filter proposals. It does not, by itself, provide
validator admission, leader or committee selection, Byzantine agreement,
locking, liveness, or finality.
