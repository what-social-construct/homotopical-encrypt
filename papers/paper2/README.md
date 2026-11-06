# Proof-Carrying Homotopical Encryption: Gate Certificates and Vertra Chain Architecture

Working title for Paper 2.

The [initial manuscript text](DRAFT.md) now records the shared chain objects,
real versus modular validity, three native metric levels, geometric comparison
boundaries and evidence contracts. It is an early working draft; no Paper 2
TeX/PDF manuscript or complete security argument is claimed.

Paper 2 owns the concrete visibility, encoding and storage profile, authorized
recipient key delivery, representative/key rotation and migration. It inherits
Paper 1's three visibility levels: private Hodge/restriction data and full
cochains unless explicitly exposed; public residue payload/modulus/count/tag;
and only the declared selective openings or proof statements. The selected
mathematical HCP theorem uses the existing `(class,b)` observation. A richer
storage or full-Plucker view needs its own compatibility conditions; the
visibility levels themselves are not being reopened.

The first public-data profile is now specified in
[Draft §2.1](DRAFT.md#21-base-public-input-and-declared-disclosures) and
implemented by [Storage.PublicView](../../lean/Protocol/Storage/PublicView.lean).
Its base record contains the existing six-coordinate context key and the
same original cochain payload. The retained manifest view adds the actual
sealed root and ordered `(slot,digest)` directory, without publishing semantic
checkpoint payloads. A separately named `HCPDisclosure` adds the existing
`(class,b)` observation from that same bound sample. The residue payload does
not implicitly disclose this pair.

These records fix the public values, not a complete wire transcript or a
hiding theorem. Public roots, tags, proof outputs and released extensions must
all appear in the eventual adversary view. The base profile excludes full
operative-kernel Plücker coordinates; a digest-only extension needs an explicit
digest projection and binding contract. Canonical bytes, selective access,
proof/verifier formats and cryptographic guarantees remain separate. Recipient
delivery and rotation are the next protocol objects to specify; current
validation is recorded [centrally](../../docs/MATH_STORAGE_VALIDATION.md).

The shared mathematical wiring is owned by Paper 1:
[actual cochain model and invariant homological tests](../../lean/Helfer/CochainModel.lean),
[integral cellular axis family](../../lean/Sheaf/HCPAxisFamily.lean),
[HCP realization](../../lean/HCP/AxisFamily.lean) and
[original observation/target adapter](../../lean/TCB/HCPRealization.lean), with
an [artifact-bound family adapter](../../lean/TCB/HCPAxisFamily.lean) that
retains the application-supplied acceptance, decoder and binding contracts.
The fragment is not full Helfer first-order semantics. The
[draft ledger](DRAFT.md#7-proof-ledger-and-remaining-protocol-work) and
[central validation record](../../docs/MATH_STORAGE_VALIDATION.md) distinguish
checked endpoints from integration work. These mathematical joins do not
construct a privacy game, recipient key-delivery scheme or rotation runtime.

The current mathematical profile keeps three native metrics:
scalar-coordinate cochain edits normalized by `2n`, whole integer-plane pair
edits normalized by `n`, and whole-pair RS distance after reduction. Actual
integral cellular coboundaries modulo `q` define the source valid locus.
Explicit matching representative lifts prove
`d_cochain ≤ d_plane = d_RS ≤ 2*d_cochain` for all integer representatives.
The near contract can consume the calibrated score `2*d_cochain`; the far
contract uses the native unit lower bound. Neither definition is replaced by
a target-distance pullback.

The [draft proof ledger](DRAFT.md#7-proof-ledger-and-remaining-protocol-work)
records focused builds and actual theorem dependencies. Canonical payload
and existing-interface specializations pass their focused builds and selected
reports. That completed native-metric baseline's aggregate/default builds pass
**9,253/9,248 jobs**. Its consolidated public-facade probe passes for 139
distinct selected endpoints
(103 standard-only, 36 with existing native arithmetic trust), matching the
individual reports. The earlier 9,233-job/68-endpoint result is a pre-addition
baseline. A capacity-scale native modular result is separate from the coarse no-wrap
Euclidean example and from the full HCP residual. Positive far inputs are raw
rejection candidates; accepted exact anchors have zero source distance under
the declared compatible interpretation. Cryptographic security remains open.

Paper 3 is the independent
[capacity-radius coding manuscript](../proximity-prize/README.md), not the
previously planned product whitepaper. The
[recommended first-submission scope](SCOPE.md) narrows the initial Paper 2
claim to one proof-carrying state transition and records which commitment,
encoding, evidence, and runtime obligations remain.

This README is a scope map, not a settled protocol specification. In
particular, the consensus and Proof-of-Value design is under re-audit before
it is promoted into a claim surface. The machine-readable working bibliography
is [references.bib](references.bib); inclusion there records a relevant source,
not adoption of its protocol or transfer of its security theorem.

Wider planned scope, beyond the bounded first endpoint:

- proof-carrying verification;
- gate certificates as protocol evidence;
- runtime trust boundaries;
- oracle/worker/attestation model;
- attacker-observation sites, protocol security games, and sheaf-theoretic
  security semantics;
- consensus and Proof of Value;
- execution frames, finite system slices, and task sheaves for relating local
  validator views to coherent terminating decisions;
- Grassmannian consensus geometry, including Karcher/Fréchet means for
  validator subspace aggregation;
- anonymous credential privacy and issuer-hiding credential flows;
- post-quantum identity/key-management comparisons, including
  forward-secure identity-based encryption;
- post-quantum authenticated key exchange and signcryption for protocol
  session establishment;
- oblivious message retrieval / private retrieval boundary for protocol
  storage and worker access;
- encrypted-computation framework risk, metamorphic testing, and implementation
  correctness boundaries for privacy-preserving runtimes;
- protocol implementation testing, including fuzzing and LLM-guided seed
  generation as possible later whitepaper material;
- Vertra chain architecture;
- Rust implementation boundary.

Paper 1 remains the mathematical HCP/formalization paper: the declared
homological fragment, actual cellular families and hidden operators, harmonic
recovery, CVP comparison and shared projection interfaces. Paper 3 owns the
independent RS/MCA coding theorems and their stated application profile.

## Consensus and PoV redesign checkpoint

- The existing `SheafState` remains the outer state bus. A task sheaf may be
  constructed over finite execution slices/local views of that state; it is not
  a replacement state model. Its stalks should contain only judgments supported
  by the accepted exact (C^1) payload and evidence bound to the same immutable
  `SheafStateSnapshot`.
- A task-sheaf global section is a coherent decision assignment, not a quorum
  certificate or finality proof. Authentication, strict weighted quorum
  intersection, locking/round transitions, and liveness remain separate
  protocol obligations.

- PoV should presently mean the proof-carrying **validity/admissibility** layer:
  exact cochain and projection gates, spectral-policy checks, topology and root
  compatibility, freshness and conservation predicates, and conservative
  reliability scoring. It does not by itself order blocks, resist Sybils, or
  establish agreement or finality.
- A consensus protocol must separately state its validator-admission or scarce-
  resource assumption, leader/committee selection rule, corruption and network
  model, fork-choice or finality rule, equivocation response, and liveness
  theorem. Those obligations must not be inherited from the PoV predicates.
- The current Python/Rust HMAC-based slot lottery is a prototype keyed lottery,
  not a public-key verifiable random function: it does not yet expose the public
  proof/verification interface required by the standard VRF definition. Paper 2
  must either replace it with such a construction or name and analyze the weaker
  primitive accurately.
- Spectral gaps, harmonic weights, and Grassmann/Plucker proximity may be useful
  admissibility evidence or score inputs. They are not automatically stake, a
  Sybil-cost resource, or a safe probability distribution. Any use in selection
  needs an explicit normalization, anti-splitting argument, grinding analysis,
  and incentive model.
- The first protocol-level choice is between an explicit chain-growth design
  with private slot leadership (Praos-like) and privately selected committees
  with Byzantine agreement (Algorand-like). A hybrid should be considered only
  after the assumptions and interface of each component are stated separately.
- Petri nets and categorical nets can give the evidence lifecycle a precise
  state-machine semantics. Their markings and transitions track protocol state,
  resources, and individually bound commitments; they do not supply leader
  election, network agreement, or finality merely by analogy.
- The proof-carrying evidence path can still reuse the existing
  Plucker/proximity objects instead of introducing a second public geometry
  layer: a private frame witness determines a normalized public Plucker shadow;
  a proof-carrying payload realizes that shadow as an accepted cochain
  commitment; the projection chain sends the committed cochain through the
  plane shadow to the canonical Reed--Solomon received word; hard-gate evidence
  records and the RS/MCA certificate give the finite verifier-facing audit
  target. In slogan form:

  ```text
  FrameWitness -> HashedPluckerShadow -> CochainCommitmentData
    -> PlaneShadow -> RS received word -> MCA-bound certificate
  ```
- The full Plucker shadow now has a checked subspace/projector reconstruction.
  If it names the operative kernel, it also determines the operative harmonic
  target on an observed vector. The current semantic hashed-shadow record
  contains both the shadow and a digest; a digest-only wire view is a separate
  construction. State that visibility choice before making a privacy claim.
- A pair must be bound before a sampled challenge, or its fixed challenge must
  be proved good for the authenticated line profile. The diagonal power-word
  profile has exactly the cancelling challenge `-1`; arbitrary fixed nonzero
  mixes admit capacity-far cancelling pairs. The particular diagonal witness
  does not establish a global deterministic far-preservation theorem.
- Rust is the consensus-facing runtime boundary: canonical byte parsing,
  resource bounds, proof and oracle-attestation verification, VRF checks,
  key-image checks, state-root/cochain-root recomputation, fork choice, and
  atomic state transitions.
- Python may construct candidates, witnesses, numerical references, and test
  vectors. It is not consensus authority.
- TEEs may be used as optional oracle/worker privacy hardening for witness
  handling and metadata reduction. A TEE result becomes consensus-facing only
  as an attestation or proof artifact verified by Rust against the stated
  Lean/protocol predicate; the TEE itself is not a consensus oracle.
- Breadth-first graph traversal, when used, is an implementation algorithm for
  public graph checks such as Čech-nerve connectedness, dependency/frontier
  walks, or block-DAG traversal. It is not a security assumption. If BFT-style
  voting/finality is added, it should be presented as a separate network
  agreement layer, not as the PoV validity predicate.

Protocol- and architecture-facing references:

The bibliography also records the categorical/Petri-net lineage and the
foundational consensus sources needed for the redesign. The prose list below
tracks the initial application-facing reading set.

- Matthieu Faitg, Azat M. Gainutdinov, Christoph Schweigert, and Jan-Ole
  Willprecht, "Deformations of mixed associators in module categories,"
  arXiv:2604.00837, 2026. Section 2.2.2 is an organizational analogy for
  packaging coherent pointwise data as structure on a representation functor;
  it does not prove the HCP Hodge equivalence or its monoidal refinement.
- Marc Gerritsma and Suyash Shrestha, "An Approximate Bounded Cochain
  Projection," arXiv:2607.07457, 2026. This is a later numerical/runtime source
  for exact-versus-approximate commuting cochain projections, not a dependency
  of Paper 1's exact finite cellular model.

- Hermann Karcher, "Riemannian center of mass and mollifier smoothing,"
  Communications on Pure and Applied Mathematics 30(5):509-541, 1977.
- Takao Inoué, "Grothendieck Topologies and Sheaf-Theoretic Foundations of
  Cryptographic Security: Attacker Models and Σ-Protocols as the First Step,"
  arXiv:2602.17301, 2026.
- Andrea Flamini, Karla Friedrichs, Jonathan Katz, Watson Ladd, Anja Lehmann,
  and Marek Sefranek, "Issuer-Hiding BBS-Based Anonymous Credentials without
  Policy Keys," Cryptology ePrint Archive, Paper 2026/870, 2026.
- Ben Fisch, Zeyu Liu, Eran Tromer, and Yunhao Wang, "UnifOMR: Oblivious
  Message Retrieval with Near-optimal Concrete Efficiency," Cryptology ePrint
  Archive, Paper 2026/910, 2026.
- Abhishek Kumar, Vikas Srivastava, Sumit Kumar Debnath, and Pantelimon
  Stănică, "A Post-Quantum Secure Lattice-Based Forward-Secure Identity Based
  Encryption with Applications to Internet of Things Architecture,"
  arXiv:2606.22340, 2026.
- Mostefa Kara, Konstantinos Karampidis, and Muath AlShaikh, "Post-Quantum
  Authenticated Key Exchange via Signcryption with Ephemeral Key Masking,"
  Cryptology ePrint Archive, Paper 2026/914, 2026.
- Yiteng Peng, Dongwei Xiao, Zhibo Liu, Zhenlan Ji, and Shuai Wang, "Detecting
  and Understanding Vulnerabilities in Fully Homomorphic Encryption
  Frameworks," arXiv:2606.22519, 2026.
- Keke Gai, Haochen Liang, Jing Yu, Liehuang Zhu, and Dusit Niyato, "LLAMA:
  Multi-Feedback Smart Contract Fuzzing Framework with LLM-Guided Seed
  Generation," arXiv:2507.12084, 2025.
