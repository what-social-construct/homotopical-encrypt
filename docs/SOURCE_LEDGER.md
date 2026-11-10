# Source ledger

Updated 2026-11-09. This is the single source-reading register extracted from
the chain/network working review; that review retains architecture provenance.
Use source IDs as stable lookup keys. Full citation metadata stays in the
[Paper 1 bibliography](../papers/paper1/references.bib),
[Paper 2 bibliography](../papers/paper2/references.bib) and
[Paper 3 bibliography](../papers/paper3/references.bib).
Paper 3’s [manuscript](../papers/paper3/main.tex) contains its
source-to-claim comparison; the [live parity register](../SEMANTIC-PARITY.md)
records the mathematical objects and remaining obligations.

This is the working source ledger: use the topic/ID index for quick lookup,
then the source row for the version, reviewed material and proposed role.
Rows distinguish targeted primary-section reviews from abstract/metadata-only
checks. None is a complete independent proof audit. “Possible role” is an
assessment, not adoption of a construction or a claim that its theorem is
formalized here. Cryptographic sources require a separate security review
before their assumptions or guarantees enter a selected protocol.

### Bibliography correspondence

All **28 ledger sources** now have a BibTeX record in the relevant paper's
bibliography. File membership is a retrieval aid, not adoption, proof review,
or a claim that a source's theorem is formalized. The PDFs print sources
actually cited in their text; candidate records are retained for later work
without `\nocite{*}`. Paper 1 owns HCP primitives, recovery and CVP
comparisons, Paper 2 owns construction/protocol and application candidates,
and Paper 3 owns coding/proximity comparisons. The existing detailed rows
below retain their review depth and applicability conditions.

Here **P1** means [Paper 1 references.bib](../papers/paper1/references.bib),
**P2** means [Paper 2 references.bib](../papers/paper2/references.bib), and
**P3** means [Paper 3 references.bib](../papers/paper3/references.bib).
Metadata for the 19 newly added records was checked against the primary
versioned arXiv pages on 2026-11-09. Reviewed versions are retained rather
than silently upgraded: for example, `2611.05136v1` is the reviewed PRG
source even though version 2 was posted on November 5.

| Source ID | BibTeX key | File | Current role |
|---|---|---|---|
| 1312.6454 | `curryGhristNanda2015morse` | P1 | Computational comparison; retained maps/metric need justification. |
| 1808.01513 | `hansenGhrist2018sheaves` | P1 | Cited foundation; finite cellular/Hodge part only. |
| 1908.08944 | `helfer2019fol` | P1 | Cited semantic background; declared homological fragment only. |
| 2601.19830 | `dingKim2026plucker` | P3 | Projective-chain reconstruction comparison; specialized coordinates not adopted. |
| 2007.04099 | `ghristRiess2022tarski` | P2 | Candidate ordered-constraint semantics; no stalk/adjunction realization. |
| 2011.14057 | `riessHansenGhrist2020persistence` | P2 | Optional feature/learning comparison; no classifier adoption. |
| ePrint 2026/910 | `fischEtAl2026unifomr` | P2 | Planned retrieval comparison; metadata/abstract review only. |
| 2110.03789 | `gebhartHansenSchrater2023knowledgeSheaves` | P2 | Candidate schema/learning application; metadata/abstract review only. |
| 2512.00242 | `borgiSilvestriLio2025polynomialSheaf` | P2 | Candidate numerical diffusion layer; no implementation selected. |
| 2605.06395 | `tandonEtAl2026hilbertBundles` | P2 | Candidate sheaf/learning construction; no selection. |
| 2605.15778 | `ghrist2026liabilityNetworks` | P2 | Candidate constraint/transition pattern; no economic profile selected. |
| 2605.26883 | `cignaraleRinconGaleana2026jointCommitments` | P2 | Candidate policy/joint-evidence semantics; no adoption. |
| 2606.03861 | `abbadiniAlmeidaArrieta2026topos` | P2 | Candidate logical semantics; no topos construction adopted. |
| 2608.14556 | `zhengAllenBlanchette2026cochainMetrics` | P2 | Candidate metric comparison; no metric selected. |
| 2608.15397 | `boudourides2026harmonicCirculation` | P2 | Candidate network dynamics; no quorum/finality claim. |
| 2610.12384 | `faergemanKjaersgaard2026localConstancy` | P2 | Candidate family/transport organization; no realization. |
| 2610.28455 | `guadagnuoloEtAl2026bochner` | P2 | Candidate operator analysis; no kernel-preserving adapter. |
| 2610.37061 | `grahamEtAl2026gksSecurity` | P2 | Encrypted-computation comparison only; no construction/security adoption. |
| 2610.40746 | `odabasi2026enrichedHomotopy` | P2 | Candidate categorical organization; no adapter. |
| 2611.04670 | `borgiEtAl2026sheafMPNN` | P2 | Candidate computation architecture; no wire/consensus refinement. |
| 2611.05136 | `qian2026informationLoss` | P2 | Security-game comparison only; no HCP distributional reduction. |
| 2611.05209 | `fernandezHerreroInchiostro2026relative` | P2 | Candidate relative-family framework; no realization/adapter. |
| 0911.1298 | `beelenGhorpadeHoholdt2010affineGrassmann` | P3 | Candidate code comparison; no extraction identification. |
| 1507.01653 | `ketiWan2016deepHoles` | P3 | Cited classical deep-hole background. |
| ePrint 2025/2051 | `bordageEtAl2026polynomialMCA` | P3 | Cited MCA context; no quantitative bound imported. |
| 2608.22663 | `guruswamiLiSinghal2026averageRadius` | P3 | Random-code comparison; no ensemble transfer. |
| 2609.18098 | `liuEtAl2026hyperDerivativeAG` | P3 | Alternative-codec candidate; no metric transfer. |
| 2611.07607 | `alrabiahGoyalGuruswami2026` | P3 | Cited novelty comparison; no Lean adoption. |

### Quick topic and ID index

Source IDs are the lookup keys; each link jumps to its existing register row.
Search this file for an arXiv ID or `ePrint 2026/910` when working from a URL.

| Topic | Source IDs |
|---|---|
| Cellular sheaves, Hodge and categorical/family semantics | [1808.01513](#source-1808-01513), [1908.08944](#source-1908-08944), [2606.03861](#source-2606-03861), [2610.12384](#source-2610-12384), [2611.05209](#source-2611-05209), [2610.40746](#source-2610-40746) |
| Geometry, codes and reductions | [2601.19830](#source-2601-19830), [0911.1298](#source-0911-1298), [2609.18098](#source-2609-18098), [2608.22663](#source-2608-22663), [1312.6454](#source-1312-6454), [2011.14057](#source-2011-14057), [1507.01653](#source-1507-01653), [ePrint 2025/2051](#source-eprint-2025-2051), [2611.07607](#source-2611-07607) |
| Network dynamics, metrics and learning | [2608.15397](#source-2608-15397), [2608.14556](#source-2608-14556), [2605.06395](#source-2605-06395), [2610.28455](#source-2610-28455), [2512.00242](#source-2512-00242), [2611.04670](#source-2611-04670), [2110.03789](#source-2110-03789) |
| Ordered constraints and transitions | [2007.04099](#source-2007-04099), [2605.15778](#source-2605-15778), [2605.26883](#source-2605-26883) |
| Cryptographic games and private retrieval | [2611.05136](#source-2611-05136), [2610.37061](#source-2610-37061), [ePrint 2026/910](#source-eprint-2026-910) |

### Foundations and categorical organization

| Source | Result/definition examined | Possible role and boundary |
|---|---|---|
| <a id="source-1808-01513"></a>[Hansen–Ghrist, *Toward a Spectral Theory of Cellular Sheaves*, 1808.01513v2](https://arxiv.org/html/1808.01513v2) | Face-poset vector-space sheaves, weighted cochains and Hodge theory (§§2–3). Already cited by Paper 1. | Primary mathematical foundation. Our finite coordinate truncation gives concrete maps/laws; it does not formalize the entire paper. |
| <a id="source-1908-08944"></a>[Helfer, *First-order homotopical logic*, 1908.08944v2](https://arxiv.org/html/1908.08944v2) | Fibrational semantics and homotopy-invariant first-order interpretation, including Theorem 12.3. Already cited by Paper 1. | Interpretation/equivalence layer. The current `Helfer.CochainModel` constructs the nonzero-cohomology-test fragment in an actual Quillen cochain model; the full external first-order construction remains separate. |
| <a id="source-2606-03861"></a>[*A topos for étale-finite Heyting algebras*, 2606.03861v2](https://arxiv.org/pdf/2606.03861v2) | The étale-finite construction realizes `H` as `Sub(1)` of a topos (Theorem 5.25). | Possible logical semantics. Global truth values `Sub(1)` and the internal classifier object are distinct. Our abstract residuation interface alone does not establish all required lattice laws or construct this topos. |
| <a id="source-2610-12384"></a>[Færgeman–Kjærsgaard, *Local Constancy of the Betti Automorphic Category over the Moduli of Curves*, 2610.12384v2](https://arxiv.org/html/2610.12384v2) | Categories of derived sheaves with nilpotent singular support; fiber restriction is an equivalence over a contractible real analytic family (Theorem 10.1.0.1). Appendix B.1 organizes local constancy; global monodromy can remain. | Useful pattern: a parameter base, categories over it and coherent transport. No realization from our cellular sheaf or Helfer interfaces is supplied. Its categorical spectral projector is distinct from an orthogonal Hodge projector. Local equivalence alone does not establish metric preservation, key rotation or byte recovery. |
| <a id="source-2611-05209"></a>[Fernandez Herrero–Inchiostro, *Relative cohomology and base-change*, 2611.05209v1](https://arxiv.org/html/2611.05209v1) | **Primary §2 / Theorem 1 reviewed.** For a finite-type separated morphism between schemes locally of finite type over a locally Noetherian base, and a bounded termwise base-flat quasicoherent complex, derived pushforward has a local bounded base-flat model and the stated derived base-change comparison. Part (c) also requires the target to be base-flat and the cohomology to be coherent with proper support over that target. | Candidate for coherent constructions over parameter families. An actual scheme/relative-sheaf realization and comparison with the finite cellular model are required. It supplies no metric preservation, noise sampler or cryptographic security theorem. |
| <a id="source-2610-40746"></a>[Odabasi, *Homotopy in enriched functor categories: Frobenius exact structures and weak Serre functors*, 2610.40746v1](https://arxiv.org/html/2610.40746v1) | **Primary abstract and introduction reviewed.** Studies sufficient conditions for a selected exact structure on an additive enriched functor category to be Frobenius; weak Serre data support objectwise descriptions of the resulting homotopy relations. Detailed theorem/proof audit remains open. | Candidate functor/homotopy organization. Relating its exact/stable-category homotopy to the existing Helfer/Quillen cochain model requires an explicit adapter and its hypotheses. It gives no automatic isometry, noise distribution or encryption/retrieval security. |

### Geometry, code extraction and reduction

| Source | Result/definition examined | Possible role and boundary |
|---|---|---|
| <a id="source-2601-19830"></a>[*Grassmann–Plücker functions for orthogonal matroids*, 2601.19830v2](https://arxiv.org/html/2601.19830v2) | Restricted Plücker data for maximal isotropic subspaces of a split orthogonal space, with recovery of the subspace (Corollary 3.7). | A specialized algebraic comparison; our arbitrary real harmonic subspaces still have no selected orthogonal-matroid realization. **Status update, 2026-11-08:** [Reconstruction](../lean/Proximity/Concrete/GrassmannianPlucker/Reconstruction.lean) now recovers the subspace/projector and proves full-shadow equality exactly when genuine ranked points agree (`publicShadow_eq_iff_same_point`). This supersedes the initial review's soundness-only gap; digest inversion remains separate. |
| <a id="source-0911-1298"></a>[Beelen–Ghorpade–Høholdt, *Affine Grassmann Codes*, 0911.1298v2](https://arxiv.org/abs/0911.1298v2) | Span of all minors of a finite-field matrix, evaluated on all matrices; exact length, dimension and minimum distance. Section 7 identifies the normalized big-cell connection to Grassmann/Plücker evaluation. | Direct coding reference to assess for the extraction layer. Applying its distance requires choosing that finite-field chart/evaluation code and proving the identification. The current real shadow and subsequent plane-to-RS encoding do not supply this automatically. Minimum codeword distance does not prove the missing geometric-source-to-pair far comparison. |
| <a id="source-2609-18098"></a>[*Hyper-derivative Algebraic Geometry Codes via Local Expansions*, 2609.18098v1](https://arxiv.org/html/2609.18098v1) | Finite-field function evaluation through local derivative jets, with an ordered NRT metric. | Alternative codec research. Current paired RS words have independent coordinates and whole-pair Hamming distance. A derivative relation, new locus/codec and metric comparison would need construction before importing bounds. |
| <a id="source-2608-22663"></a>[Guruswami–Li–Singhal, *Average-Radius List-Decodability of Random Linear Codes*, 2608.22663v2](https://arxiv.org/html/2608.22663v2) | Random linear codes have a high-probability average-radius guarantee near finite-alphabet capacity, stronger than ordinary list decoding. | Paper 3 comparison source. Applying it needs an actual ensemble/transfer theorem for our fixed code; it constructs no harmonic projector or geometric-to-Hamming bridge. |
| <a id="source-1312-6454"></a>[Curry–Ghrist–Nanda, *Discrete Morse theory for computing cellular sheaf cohomology*, 1312.6454v2](https://arxiv.org/html/1312.6454v2) | Acyclic matching with invertible differential blocks gives a reduced cochain complex and chain-homotopy equivalence (Theorem 2.6). | Potential computational reduction with retained maps/certificates. Cohomology preservation allows dimension changes and does not automatically preserve Euclidean distances or literal harmonic representatives. Preserve lifts and the original metric if the original HCP target matters. |
| <a id="source-2011-14057"></a>[*Multidimensional Persistence Module Classification via Lattice-Theoretic Convolutions*, 2011.14057v2](https://arxiv.org/html/2011.14057v2) | Order-indexed homology/persistence features and meet/join convolutions for classification. | Optional feature/learning reference. Filtration persistence, disk retention and integral CVP lattices have separate meanings. The proposed invariants are incomplete classifiers and do not authenticate a snapshot. |
| <a id="source-1507-01653"></a>[Keti–Wan, *Deep Holes in Reed–Solomon Codes Based on Dickson Polynomials*, 1507.01653v4](https://arxiv.org/html/1507.01653v4#S2) | Primary §2 reviewed: the standard distance bounds give degree-`k` deep holes for proper RS codes. | Paper 3 §5 cites this classical witness. The exact interleaved multiplicity is the manuscript's interpolation deduction, rather than a formula attributed to this source. See the coding comparison (archived reference: `archive/documentation/docs/PROXIMITY_NOVELTY_COMPARISON.md`). |
| <a id="source-eprint-2025-2051"></a>[Bordage–Chiesa–Guan–Manzur, *All Polynomial Generators Preserve Distance with Mutual Correlated Agreement*, CCC 2026 / ePrint 2025/2051](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.CCC.2026.24) | Published primary introduction/§1.1 reviewed: broader polynomial-generator MCA formulations for linear codes. | Background citation in Paper 3 §6. No quantitative theorem, event identification or protocol reduction is imported by this citation; the comparison note (archived reference: `archive/documentation/docs/PROXIMITY_NOVELTY_COMPARISON.md`) records review depth. |
| <a id="source-2611-07607"></a>[Alrabiah–Goyal–Guruswami, *Combinatorial limitations of list-decoding Reed–Solomon codes*, 2611.07607v1](https://arxiv.org/html/2611.07607v1), [ECCC TR26-304](https://eccc.weizmann.ac.il/report/2026/304/) | **Primary Theorems 1.1, 1.2, 1.4 and proof overviews reviewed; complete proof audit remains open.** Posted November 5, 2026. Full-length extension-field codes of length `N=q^(4t)` at rates `q^(-2)` or `(1-q^(-1))^2` have `N^(Ω_q(log N))` nearby words just beyond Johnson. Specified full-length prime-field families have growing polynomial lists at a constant gap below capacity. | Paper 3 comparison, with no contradiction identified in its selected claims: our explicit family uses `n=256*2^u` subgroup points in a field of size `3^n`, not full length; the boundary prime also has length `4096` distinct from its field size. The endpoint list `choose(n,k)` and fractional-field budget allow exponential-in-length lists and assert no polynomial-list capacity theorem. Single-word lists do not automatically identify our pair-MCA event. No Lean adoption and no prerequisite for Paper 1 submission. |

### Network computation, metrics and learning

| Source | Result/definition examined | Possible role and boundary |
|---|---|---|
| <a id="source-2608-15397"></a>[*Consensus and Persistent Harmonic Edge Circulation in a Hodge-Theoretic Model of Networked Information Flow*, 2608.15397v2](https://arxiv.org/html/2608.15397v2) | Coupled scalar node/edge flow on a fixed connected complex; its harmonic edge component is conserved and the flow converges to a stated mean/harmonic limit. | Possible constant-sheaf dynamics example. Evolving cochains and retained geometry are distinct. Arbitrary sheaf stalks require different hypotheses; averaging consensus does not establish authenticated quorum/finality. |
| <a id="source-2608-14556"></a>[*Learning Discrete Riemannian Metrics for Physical Fields with Cochain-Frame Equivariance*, 2608.14556v2](https://arxiv.org/html/2608.14556v2) | Positive weights in the displayed fixed-incidence operator preserve its Euclidean harmonic kernel; the paper separately discusses intrinsic metric-dependent adjoints. | Makes the metric choice concrete. Changing the middle-degree metric can change harmonic representatives. Feature-channel orthogonal symmetry does not define cryptographic key rotation. No metric from this paper is selected. |
| <a id="source-2605-06395"></a>[*Consistent Geometric Deep Learning via Hilbert Bundles and Cellular Sheaves*, 2605.06395v3](https://arxiv.org/html/2605.06395v3) | Hilbert fibers, connection transport, sampled graph sheaves, finite-rank projection and conditional approximation results. | Potential learning/sheaf construction source. Its finite-dimensional graph case could fit after choosing bases, incidences and maps; infinite fibers, manifold sampling and connection results are additional infrastructure. Version 3, dated November 4, is the reviewed version. |
| <a id="source-2610-28455"></a>[*A Bochner Weitzenböck Decomposition for Cellular Sheaf Laplacians, Curvature and Neural Sheaf Diffusion*, 2610.28455v1](https://arxiv.org/html/2610.28455v1) | Uniform block operators decompose into a positive connection-like term and block-diagonal curvature. Holonomy results have invertibility/connectivity hypotheses. | Possible operator-analysis tool. Dropping curvature need not preserve the original kernel. Node-feature degree zero and HCP degree one must be identified through an actual construction. |
| <a id="source-2512-00242"></a>[*Polynomial Neural Sheaf Diffusion: A Spectral Filtering Approach on Cellular Sheaves*, 2512.00242v3](https://arxiv.org/html/2512.00242v3) | Polynomial spectral filters, finite-hop support and Chebyshev recurrence; stated stability bounds concern a properly scaled linear core. | Candidate efficient numerical layer. For `h` in `ker L`, `p(L)h = p(0)h`; exact preservation requires `p(0)=1`. Nonlinear gates and changing sheaves need additional analysis. |
| <a id="source-2611-04670"></a>[*Sheaf-MPNN: A Library for Sheaf Neural Networks as Message Passing*, 2611.04670v1](https://arxiv.org/html/2611.04670v1) | Local endpoint restrictions, edge discrepancy, adjoint pullbacks and aggregation realize the sheaf Laplacian; buffered message-passing steps implement polynomial diffusion. | Concrete modular computation pattern. Numerical message passing needs its own wire/delivery/authentication refinement when distributed. It supplies no ledger agreement theorem. |
| <a id="source-2110-03789"></a>[Gebhart–Hansen–Schrater, *Knowledge Sheaves: A Sheaf-Theoretic Framework for Knowledge Graph Embedding*, 2110.03789v2](https://arxiv.org/abs/2110.03789v2) | **Primary abstract and version metadata checked only.** The March 18, 2023 version is marked AISTATS 2023. It describes knowledge-graph embeddings as approximate global sections constrained by a schema, with adaptation to composite relations. Detailed definitions, experiments and proofs are not audited here. | Candidate application/schema and relational-learning reference. A knowledge graph, cellular base, ledger history and storage index need their actual maps rather than identification by name. Composite-relation inference is not private information retrieval or a cryptographic knowledge proof. |

### Ordered constraints, transitions and cryptographic comparisons

| Source | Result/definition examined | Possible role and boundary |
|---|---|---|
| <a id="source-2007-04099"></a>[Ghrist–Riess, *Cellular Sheaves of Lattices and the Tarski Laplacian*, 2007.04099v2](https://arxiv.org/html/2007.04099v2) | Lattice stalks with Galois adjunctions; fixed points of `id meet L` are global sections of the lower-map sheaf. Completeness and termination require the stated order hypotheses. | Promising `TaskSheaf` constraint-propagation model, after constructing its actual stalks/adjunctions. The current truth order `Invalid < Undetermined < Valid` makes the meet flow descending; evidence growth requires a deliberate order/semantics choice. DCC gives per-orbit termination, not a uniform round bound. |
| <a id="source-2605-15778"></a>[Ghrist, *Clearing in Liability Networks via Sheaves on Directed Hypergraphs*, 2605.15778v1](https://arxiv.org/html/2605.15778v1) | Local payment constraints, distribution/aggregation maps and global clearing as an equalizer/fixed-point problem; existence and uniqueness depend on additional hypotheses. | Useful local-constraint-to-global-transition pattern. Any economic interpretation remains unselected. Compiling a proposed clearing into the conservative kernel needs authorization, availability, freshness and conservation proofs for the same action. |
| <a id="source-2605-26883"></a>[Cignarale–Rincon Galeana, *A Dynamic Deontic Simplicial Logic for Joint Commitments*, 2605.26883v2](https://arxiv.org/html/2605.26883v2) | **Primary §§2,5–6 definitions and theorem statements reviewed; proof audit incomplete.** Version 2 is dated July 9, 2026. Agent-coloured simplices model social group commitments; dynamic modalities use precondition-filtered product updates. The paper presents static/dynamic soundness and completeness. | **Paper 2 candidate; no adoption or Lean formalization here, and no prerequisite for Paper 1 submission.** Could organize `Policy.authorized` and joint evidence, after constructing agent/state valuations and a correspondence theorem. A box action may hold vacuously when disabled; actual acceptance needs execution evidence. Product updates retain local valuations, whereas `Candidate.after` changes resources/nullifiers: a simulation law is needed. These normative commitments are distinct from cryptographic cochain payloads and their authentication/security contracts. |
| <a id="source-2611-05136"></a>[*Information Loss Is All You Need: TC0 Pseudorandomness from Worst-Case Lattices*, 2611.05136v1](https://arxiv.org/html/2611.05136v1) | Preliminary main-statement review: deterministic keyed rounding and a lattice quotient, with conditional worst-case lattice/LWE reductions. Its weak-PRF claim uses classical uniform random examples against a uniform quantum polynomial-time distinguisher; it does not establish chosen-input or quantum-query security. | Security-game comparison only. The paper's examples can determine the secret information-theoretically; the claimed barrier is computational. No HCP-to-distribution/reduction map is instantiated. Information loss alone establishes neither pseudorandomness nor distance preservation. A dedicated proof audit remains open. |
| <a id="source-2610-37061"></a>[*GKS Fully Homomorphic Encryption: Security Analysis*, 2610.37061v1](https://arxiv.org/html/2610.37061v1) | Preliminary game/deployment review: plaintext slots/ring, ciphertext algebra, secret ideal and quotient/retraction are separated. The security theorem retains an open balance lemma; the experiment needs clarification and KPA/CPA security is not claimed. | Helps separate encrypted storage, encrypted search/computation, custody and epoch capabilities. It does not establish authenticated database queries or expiration of copied ciphertext. No construction or security claim is adopted here. |
| <a id="source-eprint-2026-910"></a>[Fisch–Liu–Tromer–Wang, *UnifOMR: Oblivious Message Retrieval with Near-Optimal Concrete Efficiency*, ePrint 2026/910](https://eprint.iacr.org/2026/910) | **Primary abstract and ePrint metadata checked only.** Separates encrypted message contents from recipient/message metadata; compares OMR and PIR under strong detection-key-unlinkability and uses batch PIR in its construction. Detailed protocol/proof audit remains open. | Planned Paper 2 private-discovery/retrieval comparison, already in its bibliography. The reference does not select a detection-key representation, implementation, parameter set or security theorem for HCP. Hash authentication, selector privacy, recipient discovery and network anonymity require separate contracts. |
