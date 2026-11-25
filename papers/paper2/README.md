# Proof-Carrying Transactions for Homotopical Encryption

Paper 2 constructs transaction, storage and verification interfaces that
consume the mathematical encryption mechanism established in
[Paper 1](../paper1/README.md). The readable manuscript is
[construction.pdf](construction.pdf), built from
[construction.tex](construction.tex) and the
[protocol section](sections/coupled-construction.tex). These filenames remain
stable. The [working inventory](DRAFT.md) records the broader protocol work.

An exact-component commitment can remain fixed while the full encrypted
cochain changes. The protocol therefore names both objects in one manifest,
retains its root through authorization and accepted history, and uses a
separate native certificate to connect the selected ciphertext to its
original Hodge observation. Recipient recovery consumes the same contexts,
held transport token and available ciphertext bytes.

| Construction | Proved protocol behavior |
|---|---|
| Native manifest and history | The signed intent, checked transfer and computed history anchor retain the same exact artifact, ciphertext directory and manifest root. |
| Original-observation certificate | The actual raw seal and decoded bytes are related to the original bound HCP observation and harmonic message. |
| Certificate subjects and gates | Canonical subjects retain the full intent and metadata; later verification consumes every predecessor check on the same seven-leaf bundle and database. |
| Scoped delivery and hash lookup | Canonical token/context checks join available bytes to original-coefficient recovery or an actual hash-collision alternative. |
| Bounded native credentials | Canonical witness/program/instance codecs check the original matrix, message, opening and credential bounds. |
| Approved execution | The owner checker uses the exact expected program, parsed verifier key, CRS, public names and full signing message. |
| Raw-root CRS reference | Fresh completion inherits the conditional five-term adaptive forgery bound on the original sampled execution. |
| Nonce-bearing version | Its separate native relation and approved owner checker retain the original snapshot/context and actual private operator opening. |

The coupled cellular operators, intrinsic harmonic lattice, semantic and
ciphertext transports, finite encryption/recovery algorithms, and one-use
random-oracle theorem belong to Paper 1. Their canonical Lean modules remain
where they are; source-directory names do not determine paper ownership.
Paper 2 cites these results and retains the protocol joins, rather than
repeating their mathematical proofs. [Paper 3](../paper3/README.md) owns the
coding, projection-distance and proximity analysis.

The two native profiles have distinct verification and security scopes. The
original bounded relation retains a raw target-matrix hash and is the relation
used by the existing adaptive CRS reduction. The nonce-bearing version uses
the private operator commitment and its own versioned witness, program and
instance. Its original-context checker is constructed. Paper 1's one-use
instance/ciphertext recovery theorem does not automatically bound recovery
from signing answers, evidence proofs or the complete public storage record.

The remaining protocol work is secure proof/signature primitive
instantiation, semantic setup refinement, complete field-circuit byte/hash
compilation, authenticated delivery and lifecycle enforcement, and security
for the full released view. Consensus finality and runtime refinement remain
separate from the transaction interfaces here.

The [shared parity register](../../SEMANTIC-PARITY.md) maps the original
objects and proved statements to Lean. Useful protocol entry points include:

- [Native manifests](../../lean/Protocol/Storage/NativeManifest.lean) and
  [checked owned transfers](../../lean/Protocol/Transfer/Native.lean).
- [Scoped native delivery](../../lean/Protocol/Ephemeral/NativeDelivery.lean)
  and [native retrieval](../../lean/Protocol/Storage/Retrieval/Native.lean).
- [Certificate profiles](../../lean/Protocol/Transfer/Certificates/Profile.lean)
  and [profile authentication](../../lean/Protocol/Transfer/Certificates/ProfileAuthentication.lean).
- [Raw-root native security](../../lean/Protocol/Transfer/PathSignature/NativeSecurity.lean)
  and its [application adapter](../../lean/Protocol/Transfer/PathSignature/NativeApplication.lean).
- [Nonce-bearing relation](../../lean/Protocol/Transfer/PathSignature/NativeCommitted.lean)
  and [original-context owner checker](../../lean/Protocol/Transfer/PathSignature/NativeCommittedContext.lean).

Build the reading copy from this directory with
`latexmk -pdf -interaction=nonstopmode -halt-on-error construction.tex`.
