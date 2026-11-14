module

public import Protocol.Transfer.Owned
public import Protocol.Transfer.Anchored
public import Protocol.Transfer.Native
public import Protocol.Transfer.PublicView
public import Protocol.Transfer.PublicAssembly
public import Protocol.Transfer.Confidentiality
public import Protocol.Transfer.Security
public import Protocol.Transfer.Primitives
public import Protocol.Transfer.Certificates
public import Protocol.Transfer.Certificates.Native
public import Protocol.Transfer.Certificates.Projection
public import Protocol.Transfer.Authorization
public import Protocol.Transfer.PathSignature

@[expose] public section

/-!
# The bounded owned-resource transfer profile

Actual byte/metadata/intent checks and explicit primitive soundness derive one
fixed-snapshot resource transition, represented in the original evidence and
manifest interfaces. The same checks without assumed primitive soundness give
a one-shot accepted-invalid reduction and sampled error-composition theorem.
The exact released record retains its public identifiers and original objects.
For fixed supplied setup and transfer, the same record is assembled from its
base payload, selected ciphertext digest and signature/proof bytes. A checked-release challenge shows
that changed public input IDs give perfect branch distinction.
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

The optional native path adapter reuses the original representative and rotation
with supplied credential-opening, partial finite decoding and path-realization
contracts. It feeds owner-signature bytes through the existing proof backend;
encoding/statement reflection, authenticated setup and knowledge security remain
explicit obligations rather than consequences of existential witness validity.

The native adapter uses this same two-slot manifest and the actual checked
history anchor. Its separate original-observation certificate and canonical
sample bytes connect retained-base recovery to the original harmonic message,
with an accepted byte-hash collision as the substitution alternative. The
certificate reflection rule records the additional exact-intent obligation
needed for a selected proof backend to entail a bound typed certificate.
The selected construction now supplies canonical public subjects, rational
calibration realization, complete subject/proof byte leaves and one immutable
seven-slot bundle. Its database-bound checker derives the actual slot/root
equations and enforces every required predecessor. Native and projection
intended statements reuse the original observations and accumulated certificates;
concrete circuit/CRS soundness and knowledge remain explicit obligations.
-/
