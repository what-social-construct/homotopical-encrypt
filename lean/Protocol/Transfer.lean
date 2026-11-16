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
public import Protocol.Evidence.TransferCodec
public import Protocol.Transfer.Certificates.ProfileAuthentication
public import Protocol.Transfer.PathSignature.NativeRegistered
public import Protocol.Transfer.PathSignature.NativeSecurity
public import Protocol.Transfer.PathSignature.NativeSampler
public import Protocol.Transfer.PathSignature.NativeCircuit
public import Protocol.Transfer.PathSignature.NativeApplication
public import Protocol.Transfer.PathSignature.NativeCircuitBounds
public import Protocol.Transfer.PathSignature.NativeRecovery
public import Protocol.Transfer.PathSignature.NativeSignSampler
public import Protocol.Transfer.PathSignature.NativeSignPrivacy
public import Protocol.Transfer.PathSignature.NativeOperatorGuessing
public import Protocol.Transfer.PathSignature.NativeNoiseRefresh

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
retains four primitive/context failure terms. A canonical byte-owner packet
codec now serializes the original packet and complete quorum vote target;
general owner codecs and numerical security remain separate obligations.

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
circuit/CRS soundness and knowledge retain explicit security premises.

The finite native reference construction supplies canonical bounded witnesses,
program and public-key codecs, uniform finite seeds, the original coupled
transport and typed homotopy equivalence, and a checked arithmetic core. Its
adaptive CRS signing experiment executes actual queries and trapdoor extraction;
the full-ciphertext forgery bound separates winning-event hybrid transfer,
extraction failure, original coefficient recovery and two byte-hash collisions.
No security estimate follows from the finite sampler alone.

Authenticated profile descriptors select actual parsed program, verifier key
and CRS bytes. The native checker also requires the exact expected program and
derives its key from the original owner credential, context snapshot root and
ciphertext digest. Existing quorum votes authenticate the complete descriptor
proposal. Hash/signature security, secure setup and a concrete tagged
simulation-extractable proof engine remain assumptions to instantiate; the
arithmetic core does not compile canonical bytes, hashes or range checks.

The application adapter completes the actual generated target into the original
packet, checks its canonical signing subject and challenged key, and retains
all original operational checks. Accepted fresh completions imply a win in
that same generated transcript under the actual approved setup. The native
source theorem combines original credential/snapshot/ciphertext/hash joins
with the same-PMF five-term application bound. It covers this explicit
completion adapter; general packet adversaries and accepted-invalid integrity
retain their separate translation and policy/compromise/payload obligations.

The integer-core range checker supplies an explicit modulus criterion for the
original NoWrap lift. This is not yet a field-circuit compilation of byte,
range and hash checks. The bounded reference sampler now has an actual-byte
scalar recovery counterexample. A separate fresh-sign candidate proves equal
one-use ciphertext laws and a uniform-message guessing bound of 2^-n, with
independent tapes and partial coefficient decoders covered. Its raw operator
hash admits a plaintext-candidate test; no storage-view privacy follows.
Ordinary native transport retains its coexact opening. A canonical-byte
coexact correction produces the target candidate's desired opening, without
supplying independent key generation or a public refresh capability.
-/
