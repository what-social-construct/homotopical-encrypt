# Proof-Carrying Transactions for Homotopical Encryption

Paper 2 specifies how transactions store, verify and act on the same encrypted
cochain. It uses the encryption, recovery and transport interface established
in [Paper 1](../paper1/README.md). Read the [protocol PDF](construction.pdf),
its [TeX source](construction.tex), or the [working inventory](DRAFT.md).

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

The adaptive CRS reduction uses the raw-root relation. The nonce-bearing
version uses the private operator commitment and its own witness, program,
instance and original-context checker. A privacy experiment for that checker
must account for the signing answers, evidence proofs and released storage
records together.

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
