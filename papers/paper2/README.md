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
| Checked owned transfer | Acceptance derives the computed update, value preservation, input consumption, output creation and replay rejection. |
| Native manifest and history | The signed intent, checked transfer and computed history anchor retain the same exact artifact, ciphertext directory and manifest root. |
| Original-observation certificate | The actual raw seal and decoded bytes are related to the original bound HCP observation and harmonic message. |
| Certificate subjects and gates | Canonical subjects retain the full intent and metadata; later verification consumes every predecessor check on the same seven-leaf bundle and database. |
| Sampled scalar check | The retained intent fixes the pair before one uniform field challenge. Acceptance on a far modular cochain is bounded by the pair's MCA bad-challenge fraction. |
| Scoped delivery and hash lookup | Canonical token/context checks join available bytes to original-coefficient recovery or an actual hash-collision alternative. |
| Encrypted cell index | The SHA-256 address names the complete stored byte record. A direct lookup verifies the entire response before returning it. |
| Checked cell directory | A trusted context and directory root bind the ordered cell IDs and ciphertext digests. Verified fragments agree on overlaps and resolve IDs for whole-record reads. |
| Local restart reads | A writer verifies the directory and all referenced ciphertexts before atomically publishing the checkpoint. A fresh reader checks it against an independent pin and verifies the selected ciphertext. |
| Incremental public stack restore | The accepted release root names the directory, public snapshot descriptor, original cochain, and vote target. A replica reuses verified objects and publishes the root once every reference verifies. |
| Historical proof-packet replay | A fresh reader uses the restored packet and ciphertext with the original prior state and configured verifier. The checked packet must reproduce the accepted vote target. |
| Ordered history replay | An authenticated list of archive roots and one trusted starting state let a fresh reader check successive transfers and recover the final historical state. |
| Bounded native credentials | Canonical witness/program/instance codecs check the original matrix, message, opening and credential bounds. |
| Approved execution | The owner checker uses the exact expected program, parsed verifier key, CRS, public names and full signing message. |
| Raw-root CRS reference | Fresh completion inherits the conditional five-term adaptive forgery bound on the original sampled execution. |
| Nonce-bearing version | Its separate native relation and approved owner checker retain the original snapshot/context and actual private operator opening. |
| Nonce-bearing release recovery | The original checked release factors through the public instance, matched template and two evidence byte strings. The recovery bound transfers under a simulation premise on the joint prefix, including the sampled message and live byte-oracle cache. |
| Honest release experiment | The selected CRS prover uses the original nonce-bearing witness and full V2 signing input. A conditional comparison from the common native prefix implies the joint-prefix recovery premise. |
| Generated release acceptance | The generated owner and payload proofs pass the original packet checker under the stated setup, approval, observation binding and primitive correctness hypotheses. |
| Proof relation arithmetic | Paper 1 supplies the prime-field refinement of the bounded ciphertext equations for the native proof relation. |

The adaptive CRS reduction uses the raw-root relation. The nonce-bearing
version uses the private operator commitment and its own witness, program,
instance and original-context checker. In its release experiment, the
simulator receives the exact intent, signing input and full ciphertext.
With `m` disclosure values and query budgets `S` for the simulator and `Q`
for the decoder, the recovery bound is `m/2^n + (S+Q+2)/256^32 + ε` under a joint
prefix simulation error of at most `ε`. The one-use experiment retains
failed releases in its probability space. The honest branch samples proof
randomness internally and runs the selected CRS prover alongside the supplied
payload prover. Its common-prefix theorem reduces the joint simulation
premise to a conditional comparison of the released view and resulting cache.
The chosen backend still needs a quantitative simulation estimate and a
proof that its circuit implements the canonical relations.

The remaining protocol work is secure proof/signature primitive
instantiation, semantic setup refinement, complete field-circuit byte/hash
compilation, authenticated delivery and lifecycle enforcement, and security
for the full released view. Consensus finality and runtime refinement remain
separate from the transaction interfaces here.

The finite byte-owner example executes the canonical packet check and computes
the same successor as the specification. It moves seven units from resource
`0` to `1` and checks manifest substitution and both replay attempts. The
example supplies fixture hashes and verifiers. [Executable checker](../../lean/Protocol/Transfer/Owned/Executable.lean) · [Demo](../../lean/Protocol/Transfer/Owned/Demo.lean)

From `lean/` with the pinned dependencies:

```sh
lake build Protocol.Transfer.Owned.Demo
lake env lean --run Protocol/Transfer/Owned/Demo.lean
```

The [shared parity register](../../SEMANTIC-PARITY.md) maps the original
objects and proved statements to Lean. Useful protocol entry points include:

- [Native manifests](../../lean/Protocol/Storage/NativeManifest.lean) and
  [checked owned transfers](../../lean/Protocol/Transfer/Native.lean).
- [Scoped native delivery](../../lean/Protocol/Ephemeral/NativeDelivery.lean)
  and [native retrieval](../../lean/Protocol/Storage/Retrieval/Native.lean).
- [Encrypted cell index](../../lean/Protocol/Storage/EncryptedCell.lean)
  and [whole-record retrieval demo](../../lean/Protocol/Storage/EncryptedCell/Demo.lean).
- [Checked directory and fragment reads](../../lean/Protocol/Storage/CellDirectory.lean)
  and [directory demo](../../lean/Protocol/Storage/CellDirectory/Demo.lean).
- [Local checkpoint publication](../../lean/Protocol/Storage/CellDirectory/Persistence.lean)
  and [separate-process restart demo](../../lean/Protocol/Storage/CellDirectory/Persistence/Demo.lean).
- [Public stack release](../../lean/Protocol/Storage/PublicStack/Release.lean),
  [incremental restore](../../lean/Protocol/Storage/PublicStack/Restore.lean),
  and [replica demo](../../lean/Protocol/Storage/PublicStack/Demo.lean).
- [Historical proof-packet replay](../../lean/Protocol/Storage/PublicStack/Replay.lean)
  and [cold verification demo](../../lean/Protocol/Storage/PublicStack/ProofDemo.lean).
- [Ordered history replay](../../lean/Protocol/Storage/PublicStack/History.lean)
  and [consecutive-transfer demo](../../lean/Protocol/Storage/PublicStack/HistoryDemo.lean).
- [Certificate profiles](../../lean/Protocol/Transfer/Certificates/Profile.lean)
  and [profile authentication](../../lean/Protocol/Transfer/Certificates/ProfileAuthentication.lean).
- [Sampled scalar transfer check](../../lean/Protocol/Transfer/Certificates/SampledMCA.lean)
  and its [canonical metric handoff](../../lean/Protocol/Storage/CanonicalCalibration.lean).
- [Raw-root native security](../../lean/Protocol/Transfer/PathSignature/NativeSecurity.lean)
  and its [application adapter](../../lean/Protocol/Transfer/PathSignature/NativeApplication.lean).
- [Nonce-bearing relation](../../lean/Protocol/Transfer/PathSignature/NativeCommitted.lean)
  and [original-context owner checker](../../lean/Protocol/Transfer/PathSignature/NativeCommittedContext.lean).
- [Nonce-bearing release assembly](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease.lean)
  and [joint-prefix recovery bound](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease/Simulation.lean).
- [Honest evidence producer](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease/HonestEvidence.lean)
  and [common-prefix comparison](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease/Honest.lean).
- [Generated payload and packet acceptance](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRelease/Payload.lean)
  and [Paper 1's finite-field refinement](../paper1/README.md).

Build the reading copy from this directory with
`latexmk -pdf -interaction=nonstopmode -halt-on-error construction.tex`.
