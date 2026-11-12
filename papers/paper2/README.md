# Paper 2 source: Proof-Carrying Homotopical Encryption

Working combined title: *Homotopical Encryption and Proof-Carrying Transactions*.

The [working manuscript](DRAFT.md) develops Hodge-structured cochain encryption
with commitments, visibility, codecs, storage and proof-carrying transitions.
It supplies the construction part of the combined HCP and transaction paper.
The [matching coupled-construction TeX section](sections/coupled-construction.tex)
states the proved class/lattice/cochain connection; the full Markdown draft
has no TeX/PDF bundle yet. The
[bibliography](references.bib) records relevant sources; the
[shared parity register](../../SEMANTIC-PARITY.md) maps objects and statements
to their canonical Lean declarations.

## Current construction

The [coupled family](../../lean/Sheaf/HCPCoupledFamily.lean) uses shared integer
face equations `y=B x`. Its intrinsic harmonic lattice consists exactly of
`(0,z,Bz)`: these messages are already cochains. Exact/coexact Hodge noise
produces the original encrypted cochain. A constructed
[strict cochain isomorphism](../../lean/HCP/CoupledSemantics.lean) proves typed
Helfer equivalence and public homological-class preservation across same-size
matrices, and an explicit harmonic-lattice equivalence preserves their integer
message coefficients. The generally nonisometric shear does not transport
Hodge noise; protocol rotations retain their actual isometry requirement.
The same file joins the actual Hodge matrix to the HCP operative projector.

The [canonical integer-matrix codec](../../lean/Protocol/Storage/CoupledCodec.lean)
and [snapshot profile](../../lean/Protocol/Storage/CoupledBinding.lean) name
that same sheaf, standard integral structure and metric. Matrix bytes remain
private in the hidden-operator profile. Hash-indexed recovery of native
harmonic-lattice ciphertexts is the storage path; encrypted linear-query
evaluation is an optional application. A later FHE comparison will specify
the actual supported computations and their security assumptions.

The [integral sample profile](../../lean/Sheaf/HCPCoupledEncoding.lean) and
[full-cochain codec](../../lean/Protocol/Storage/CoupledCiphertext.lean) close
the original-object encoding join: the decoded bytes are exactly the same
Hodge sample's full observation `(a,z-Bᵀu,Bz+u)`. This ciphertext digest is
separate from the exact-component artifact digest. Key/noise sampling,
concrete authentication/proof algorithms and full-view security remain work.

The commitment profile retains the original cochain payload, its declared
modulus/count/topology tag, the private cellular/Hodge interpretation and
explicit decoding/binding contracts. An integral cellular source and complete
coordinate codec support the modular cochain, plane-pair and RS views of that
same payload. Raw coboundary openings are identified modulo `ker delta0`;
the modular carry relation remains separate. These are commitment-construction
objects.

The base public storage view releases the original residue payload and its
six-coordinate context key. The retained manifest adds the actual sealed root
and ordered slot/digest directory. A separately declared `HCPDisclosure`
adds the same bound sample's `(class,b)` observation; the residue payload does
not disclose it automatically. Full operative-kernel Plücker coordinates are
outside the base profile. Any released roots, tags, proofs and selective
openings must appear in the chosen adversary view.

For the canonical systematic sheaf, releasing both the full cochain and exact
payload recovers the harmonic message when the decoder agrees with the
selected public layout. The draft states this disclosure boundary explicitly.

Actual integral isometric rotation transports harmonic messages and structured noise.
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
| Coupled harmonic lattice and proved semantic class | [HCPCoupledFamily](../../lean/Sheaf/HCPCoupledFamily.lean), [CoupledCVP](../../lean/HCP/CoupledCVP.lean), [CoupledSemantics](../../lean/HCP/CoupledSemantics.lean) |
| Concrete presentation bytes and original snapshot | [CoupledCodec](../../lean/Protocol/Storage/CoupledCodec.lean), [CoupledBinding](../../lean/Protocol/Storage/CoupledBinding.lean) |
| Original full Hodge ciphertext bytes | [HCPCoupledEncoding](../../lean/Sheaf/HCPCoupledEncoding.lean), [CoupledCiphertext](../../lean/Protocol/Storage/CoupledCiphertext.lean) |
| Commitment and coordinate profile | [CochainCommitment](../../lean/Axioms/CochainCommitment.lean), [CoordinateCodec](../../lean/Protocol/Storage/CoordinateCodec.lean) |
| Generic ledger and computed transition | [Ledger.Transition](../../lean/Protocol/Ledger/Transition.lean), [Ledger.ValueFlow](../../lean/Protocol/Ledger/ValueFlow.lean) |
| Bounded transition and checked transfer | [Protocol.Core](../../lean/Protocol/Core.lean), [Transfer](../../lean/Protocol/Transfer.lean), [PublicAssembly](../../lean/Protocol/Transfer/PublicAssembly.lean), [protocol guide](../../lean/Protocol/README.md) |
| Storage, public views and gates | [Storage.Core](../../lean/Protocol/Storage/Core.lean), [PublicView](../../lean/Protocol/Storage/PublicView.lean), [storage guide](../../lean/Protocol/Storage/README.md) |
| Rotation, recovery and retrieval | [Ephemeral](../../lean/Protocol/Ephemeral.lean), [Retrieval](../../lean/Protocol/Storage/Retrieval.lean) |
| Committee and proof/TCB envelopes | [Consensus.Quorum](../../lean/Protocol/Consensus/Quorum.lean), [TCB](../../lean/TCB.lean) |
| Integrity, leakage and primitive contracts | [Transfer.Security](../../lean/Protocol/Transfer/Security.lean), [Transfer.Confidentiality](../../lean/Protocol/Transfer/Confidentiality.lean), [Transfer.Primitives](../../lean/Protocol/Transfer/Primitives.lean) |

[Paper 1](../paper1/README.md) supplies HCP, harmonic lattices, semantic classes
and known-lattice CVP comparisons. [Paper 3](../paper3/README.md)
introduces full projective reconstruction and proves the quantitative
projection, metric and radius comparisons. Paper 2 owns the construction,
visibility and codec profiles consumed by those comparisons. The
[current family inventory](DRAFT.md#7-construction-ownership-and-remaining-protocol-work)
accounts for the checkpoint lifecycle, ledger, gates, evidence, proof/TCB and
committee objects without promoting their supplied contracts to algorithms.

## Remaining obligations

PoV/reliability policy, oracle/coregulator attachment points and the legacy
chain model are deferred or supporting families outside the bounded
transition claim. Authenticated quorums do not supply rounds, locking or finality.

Concrete credential/proof algorithms, message-bound knowledge and
unforgeability, finite packet/ciphertext/witness codecs, authenticated
roots/directories and secure recipient delivery require construction and
verification. The supplied primitive budgets do not establish adaptive
signing/corruption security, encryption privacy or anonymity. State origin,
executable refinement, global lifecycle enforcement and consensus finality
also require separate results. The archived prototype is not an implementation
proof of this protocol.
