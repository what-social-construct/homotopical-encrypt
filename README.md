# Homotopical Encryption

This repository formalizes hidden Hodge operators, cellular-sheaf cochains,
proof-carrying transactions and Reed–Solomon proximity in Lean.

The working manuscript combines the HCP foundations and protocol construction
currently stored under `paper1` and `paper2`. The capacity-radius proximity
paper remains separate under `paper3`. The directory labels and earlier
focused verification entries are retained for source correspondence; a revised
combined submission is still being developed.

## Manuscripts

| Paper | Scope | Current preparation |
|---|---|---|
| [HCP foundations source (`paper1`)](papers/paper1/README.md) | Cellular/Hodge primitives, HCP, semantic classes, harmonic lattices, known-lattice CVP comparisons and exact-recovery ambiguity. | Existing [PDF](papers/paper1/main.pdf), [TeX](papers/paper1/main.tex) and [focused formalization entry](lean/Palomar/PaperOne/README.md), preceding the combined revision. |
| [Combined construction draft (`paper2`)](papers/paper2/README.md) | Hodge encryption, cochain commitments, concrete presentation bytes, visibility, storage and proof-carrying transitions. | [Working manuscript](papers/paper2/DRAFT.md) and [coupled-construction TeX section](papers/paper2/sections/coupled-construction.tex); full TeX/PDF and revised submission entry remain to be prepared. |
| [Paper 3: Capacity-Radius Proximity for Smooth-Domain Reed–Solomon Codes](papers/paper3/README.md) | Projective reconstruction in the projection chain, coding/list/MCA results, radii and native modular metric comparisons. | [PDF](papers/paper3/main.pdf), [TeX](papers/paper3/main.tex); internal verification configurations: [coding](lean/Palomar/PaperThree/README.md) and [application](lean/Palomar/PaperThree/Application/README.md). |

The [shared parity register](SEMANTIC-PARITY.md) assigns canonical objects and
statements to these papers. The [source ledger](docs/SOURCE_LEDGER.md)
indexes their literature. Paper 2 supplies the cochain construction and
protocol contracts consumed by Paper 3's application results. The HCP
foundations remain independent of the protocol and coding import closures.

Paper 3's coding and application configurations check different parts of
the same manuscript. The linked verification guides record their current
status. Paper 2's dedicated configuration remains to be prepared.

## Mathematical focus

The expository anchor is a homotopical analogue of encryption correctness:
admissible presentation transport commutes with encryption and recovery while
preserving the declared semantic class. The existing
[`transport_encrypt`](lean/Protocol/Ephemeral/Rotation.lean) theorem proves
this square for compatible integral chain isometries. The
[native coupled coordinate transport](lean/HCP/CoupledTransport.lean)
separately proves `M_C M_B⁻¹ Enc_B(z,a,u)=Enc_C(z,a,u)` for all same-size
coupled matrices, with identity/inverse/composition. It is not the cochain
shear. The [exact rational reference algorithm](lean/HCP/CoupledRational.lean)
now executes that map and private coefficient recovery with a proved
refinement to the original real operators. It carries no polynomial
execution-time claim. Supported encrypted
computations and a comparison with FHE remain explicit follow-up work.

A hidden presentation selects a degree-one Hodge operator

```math
\Delta_x=\delta_{0,x}\delta_{0,x}^{*}+\delta_{1,x}^{*}\delta_{1,x}.
```

Its degree-one cochain space has the Hodge splitting

```math
C_x^1=\ker(\Delta_x)\oplus\mathrm{im}(\delta_{0,x})\oplus\mathrm{im}(\delta_{1,x}^{*}).
```

An observed cochain has the form $b=h+e$, with $h\in\ker\Delta_x$ and
exact/coexact noise orthogonal to that kernel. Its operative harmonic
component is $P_{\ker\Delta_x}b$. HCP asks for that component from the public
class and cochain observation, while the operative presentation remains hidden.

The formalization distinguishes the real harmonic subspace from an integer
lattice inside it. Orthogonal target projection preserves the lattice's
closest vectors. A constructed family has one public observation and
different operative targets: a correct CVP oracle recovers the target when
given the private lattice, while the shared public input cannot select the
hidden member's answer uniformly.

The [coupled cellular family](lean/Sheaf/HCPCoupledFamily.lean) has shared
integer face equations `y=B x`. Its intrinsic harmonic lattice is exactly
`Λ_B={(0,z,Bz): z∈ℤⁿ} ⊂ C¹`: the message is already a cochain, and encryption
adds exact/coexact Hodge noise to it. A constructed
[cochain isomorphism and typed Helfer equivalence](lean/HCP/CoupledSemantics.lean)
preserve the declared public homotopy class and integer message coefficients
across same-size matrices. This generally nonisometric shear does not supply
the stronger Hodge rotation laws. The
[lattice presentation](lean/HCP/CoupledCVP.lean) has Gram matrix `I+BᵀB`;
[canonical matrix bytes](lean/Protocol/Storage/CoupledCodec.lean) and
[snapshot checks](lean/Protocol/Storage/CoupledBinding.lean) bind that same
profile to existing storage contexts.
The [integral native sample](lean/Sheaf/HCPCoupledEncoding.lean) has full
observation `(a,z−Bᵀu,Bz+u)`. Its
[ciphertext codec](lean/Protocol/Storage/CoupledCiphertext.lean) decodes to the
same original Hodge cochain, with a ciphertext digest distinct from the
exact-component artifact digest.
The [native execution path](lean/Protocol/Ephemeral/NativeTransport.lean)
uses a held rational token and the canonical full-ciphertext bytes for exact
migration or retained-base recovery. The receiver uses that token directly;
issuer generation derives it from the private presentations. The
[scope/token codecs](lean/Protocol/Ephemeral/TransportToken.lean) bind the
original recipient handle, epochs and context keys to the derived map.
[NativeDelivery](lean/Protocol/Ephemeral/NativeDelivery.lean) reuses the existing
scoped receipt, and [native hash recovery](lean/Protocol/Storage/Retrieval/Native.lean)
joins it to the original bound samples and directory lookup.
The [native manifest profile](lean/Protocol/Storage/NativeManifest.lean) now
seals the original exact artifact and separately named full ciphertext in two
slots. [Anchored native recovery](lean/Protocol/Storage/Retrieval/NativeAnchored.lean)
derives the public view and ciphertext membership from that actual target
seal, then associates recovery with the same context, manifest and accepted
history entry through the existing transition anchor. Harmonic projection
identifies the original target message without equating private openings.

The manifest root uses a supplied function of the public base and ordered
slot/digest directory; its byte codec, hash security and history authentication
remain profile obligations. Availability and canonical issued token bytes
remain explicit. The earlier owned-transfer one-slot manifest and signed
packet are unchanged; no relation identifies harmonic coefficients with
catalogue amounts or action semantics. Storage classifier alignment with the
coupled semantic realization remains open.

The intended public history uses ciphertext content IDs and selected action
links for auditing, while credential/policy proofs keep identity witnesses
private. Private retrieval addresses access metadata separately. This target
is recorded in the [parity register](SEMANTIC-PARITY.md); the bounded transfer
example still publishes owner/signer IDs and does not yet realize it.

This is a reusable context/profile-scoped capability, with the full-ciphertext
digest checked separately. Scope checks do not authenticate a caller, prevent
replay or confine copied matrix data. Omitting the private matrices as token
fields supplies no key-hiding guarantee for the derived map. Protected
delivery, shared-secret agreement, key/noise sampling and full-view security
remain explicit construction and proof obligations.

These are exact mathematical comparisons. Computational hardness and
encryption security require their stated additional assumptions.

## Build and read

The [Lean guide](lean/README.md) maps the mathematics to source modules and
the available verification configurations. From the repository root:

~~~sh
cd lean
lake exe cache get
lake build
lake build Palomar.PaperOne.Solution Palomar.PaperThree.Solution Palomar.PaperThree.Application.Solution
~~~

With a full TeX installation, run separately from the repository root:

~~~sh
latexmk -cd -pdf -interaction=nonstopmode -halt-on-error papers/paper1/main.tex
latexmk -cd -pdf -interaction=nonstopmode -halt-on-error papers/paper3/main.tex
~~~

Read the compiled PDFs beside their TeX sources under `papers/`; generated
review packages are described in the [output guide](docs/OUTPUTS.md) and live
locally under `output/packages/`. These commands describe how to reproduce the
checks; they do not certify a particular working tree.

## Layout

~~~text
lean/                       Definitions, proofs and verification entries
papers/paper1/              HCP foundations manuscript
papers/paper2/              Protocol draft
papers/paper3/              Coding/proximity manuscript
docs/                       Source ledger and current mathematical crosswalks
scripts/                    Lean/manuscript checks and package generation
output/                     Review packages and validation artifacts
archive/                    Historical prototypes, plans and review records
~~~

Rust/Python prototypes are preserved under `archive/runtime/`; earlier
plans and review records are under `archive/documentation/`. They are
historical material outside the active Lean/manuscript verification scope.

[MIT license](LICENSE).
