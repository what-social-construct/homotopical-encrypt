# Paper 2: Proof-Carrying Homotopical Encryption

Working title: *Proof-Carrying Homotopical Encryption: Gate Certificates and
Vertra Chain Architecture*.

The [working manuscript](DRAFT.md) specifies cochain commitments, visibility,
codecs, storage and proof-carrying transitions. It is a Markdown draft with
no TeX/PDF bundle or completed cryptographic security argument. The
[bibliography](references.bib) records relevant sources; the
[shared parity register](../../SEMANTIC-PARITY.md) maps objects and statements
to their canonical Lean declarations.

## Current construction

The commitment profile retains the original cochain payload, its declared
modulus/count/topology tag, the private cellular/Hodge interpretation and
explicit decoding/binding contracts. An integral cellular source and complete
coordinate codec support the modular cochain, plane-pair and RS views of that
same payload.

The base public storage view releases the original residue payload and its
six-coordinate context key. The retained manifest adds the actual sealed root
and ordered slot/digest directory. A separately declared `HCPDisclosure`
adds the same bound sample's `(class,b)` observation; the residue payload does
not disclose it automatically. Full operative-kernel Plücker coordinates are
outside the base profile. Any released roots, tags, proofs and selective
openings must appear in the chosen adversary view.

Actual integral rotation transports harmonic messages and structured noise.
Recipient recovery retains the same integer coefficients through target-key
decoding or inverse transport with the retained base key, under the supplied
encoding and delivery contracts. Hash-indexed lookup and full-bucket retrieval
reuse the original bound ciphertexts; efficient private retrieval remains a
separate construction.

## Conditional transition result

For a fixed catalogue, epoch, snapshot and before-state, one checked transfer
consumes an available owned resource and produces a distinct absent, unspent
resource with the same asset and positive amount. Its public nullifier is the
consumed resource ID. Structural packet checks, owner-signature soundness and
proof soundness for the original trusted payload interpretation derive
candidate validity and the computed state update. Operational acceptance does
not assume that validity in advance.

The evidence/history join retains the same artifact, original input manifest,
intent and complete proposal. The one-shot integrity experiment reduces
accepted-invalid outcomes to authorization or exact-payload check failures
and composes supplied failure budgets under one shared probability law.

## Lean sources and paper ownership

| Construction | Canonical entry |
|---|---|
| Commitment and coordinate profile | [CochainCommitment](../../lean/Axioms/CochainCommitment.lean), [CoordinateCodec](../../lean/Protocol/Storage/CoordinateCodec.lean) |
| Bounded transition and checked transfer | [Protocol.Core](../../lean/Protocol/Core.lean), [Transfer](../../lean/Protocol/Transfer.lean), [protocol guide](../../lean/Protocol/README.md) |
| Storage, public views and gates | [Storage.Core](../../lean/Protocol/Storage/Core.lean), [PublicView](../../lean/Protocol/Storage/PublicView.lean), [storage guide](../../lean/Protocol/Storage/README.md) |
| Rotation, recovery and retrieval | [Ephemeral](../../lean/Protocol/Ephemeral.lean), [Retrieval](../../lean/Protocol/Storage/Retrieval.lean) |
| Integrity and primitive contracts | [Transfer.Security](../../lean/Protocol/Transfer/Security.lean), [Transfer.Primitives](../../lean/Protocol/Transfer/Primitives.lean) |

[Paper 1](../paper1/README.md) supplies HCP, harmonic lattices, semantic classes
and known-lattice CVP comparisons. [Paper 3](../proximity-prize/README.md)
introduces full projective reconstruction and proves the quantitative
projection, metric and radius comparisons. Paper 2 owns the construction,
visibility and codec profiles consumed by those comparisons.

## Remaining obligations

Concrete credential/proof algorithms, message-bound knowledge and
unforgeability, finite packet/ciphertext/witness codecs, authenticated
roots/directories and secure recipient delivery require construction and
verification. The supplied primitive budgets do not establish adaptive
signing/corruption security, encryption privacy or anonymity. State origin,
executable refinement, global lifecycle enforcement and consensus finality
also require separate results. The archived prototype is not an implementation
proof of this protocol.
