# Source ledger

Updated 2026-11-26. This is the single source-reading register extracted from
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

All **36 ledger sources** now have a BibTeX record in the relevant paper's
bibliography. File membership is a retrieval aid, not adoption, proof review,
or a claim that a source's theorem is formalized. The PDFs print sources
actually cited in their text; candidate records are retained for later work
without `\nocite{*}`. Paper 1 owns the HCP primitives, native encryption
construction, recovery bounds and CVP comparisons. Paper 2 owns protocol and
application candidates,
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
| 2611.11828 | `kryazhev2026serreMultiplicativity` | P2 | Future richer graded/multiplicative invariants; no product/fibration adapter or Lean adoption. |
| Gentry 2009 thesis | `gentry2009fullyHomomorphic` | P1, P2 | Primary correctness/computation comparison for the homotopical analogy; no FHE construction adopted. |
| Micciancio 2001 exact CVP | `micciancio2001cvpp` | P1 | Section 3 gives NP-hardness with an integer basis, integer target and integral squared threshold. Paper 1 transfers the decision to the coupled harmonic lattice. |
| Regev 2009 author version | `regev2009lwe` | P1, P2 | Primary search-LWE definition and noisy-linear recovery motivation; HCP uses a different Hodge-structured noise model and no LWE reduction is supplied. |
| EUROCRYPT 2014 key-homomorphic encryption | `bonehEtAl2014keyHomomorphic` | P1, P2 | Ciphertext/key-transport novelty comparator; no security reduction or public translation algorithm transferred. |
| CL06 | `chaseLysyanskaya2006signaturesKnowledge` | P2 | Primary SimExt game organization; bounded conditional CRS reference uses supplied primitives, not that paper's complete construction/security theorem. |
| BGPR2022 | `bagheryEtAl2022signaturesKnowledge` | P2 | Tagged SE/SoK and Boolean-circuit construction reviewed more closely; compatible reference route, with no implemented backend or adopted security assumption. |
| VCVio | `vcvio2026library` | P1, P2 | Pinned HiddenSeed adapter supplies the independent-table classical random-oracle comparison used by Paper 1; native recovery is bounded by `2^-n+(Q+2)/256^32`. The differently correlated commitment-example simulator is not used. |
| 1312.6454 | `curryGhristNanda2015morse` | P1 | Computational comparison; retained maps/metric need justification. |
| 1808.01513 | `hansenGhrist2018sheaves` | P1 | Cited foundation; finite cellular/Hodge part only. |
| 1908.08944 | `helfer2019fol` | P1, P2 | Cited semantic background; declared homological fragment only. |
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
| Euclidean tensor prices 2026 | `openai2026euclideanTensorPrices` | P3 | Placed-wire prices and the direct-sum bound used for the agreement tensor. |
| Computational Algebra 2019 | `setiabrata2019computationalAlgebra` | P3 | Elimination theorem used to identify the closure of the projected feasibility locus. |

### Quick topic and ID index

Source IDs are the lookup keys; each link jumps to its existing register row.
Search this file for an arXiv ID or `ePrint 2026/910` when working from a URL.

| Topic | Source IDs |
|---|---|
| Cellular sheaves, Hodge and categorical/family semantics | [1808.01513](#source-1808-01513), [1908.08944](#source-1908-08944), [2606.03861](#source-2606-03861), [2610.12384](#source-2610-12384), [2611.05209](#source-2611-05209), [2610.40746](#source-2610-40746) |
| Multiplicative cohomology and richer logical profiles | [2611.11828](#source-2611-11828) |
| Geometry, codes and reductions | [Micciancio 2001](#source-micciancio-2001), [2601.19830](#source-2601-19830), [0911.1298](#source-0911-1298), [2609.18098](#source-2609-18098), [2608.22663](#source-2608-22663), [1312.6454](#source-1312-6454), [2011.14057](#source-2011-14057), [1507.01653](#source-1507-01653), [ePrint 2025/2051](#source-eprint-2025-2051), [2611.07607](#source-2611-07607), [Euclidean tensor prices](#source-euclidean-tensor-prices), [Elimination](#source-setiabrata-2019) |
| Network dynamics, metrics and learning | [2608.15397](#source-2608-15397), [2608.14556](#source-2608-14556), [2605.06395](#source-2605-06395), [2610.28455](#source-2610-28455), [2512.00242](#source-2512-00242), [2611.04670](#source-2611-04670), [2110.03789](#source-2110-03789) |
| Ordered constraints and transitions | [2007.04099](#source-2007-04099), [2605.15778](#source-2605-15778), [2605.26883](#source-2605-26883) |
| Cryptographic games and private retrieval | [CL06](#source-cl06), [BGPR2022](#source-bgpr2022), [VCVio](#source-vcvio), [2611.05136](#source-2611-05136), [2610.37061](#source-2610-37061), [ePrint 2026/910](#source-eprint-2026-910) |
| Encryption correctness, noisy recovery and presentation/key transport | [Regev 2009](#source-regev-2009), [Gentry 2009](#source-gentry-2009), [Boneh et al. 2014](#source-key-homomorphic-2014) |

### Foundations and categorical organization

| Source | Result/definition examined | Possible role and boundary |
|---|---|---|
| <a id="source-1808-01513"></a>[Hansen–Ghrist, *Toward a Spectral Theory of Cellular Sheaves*, 1808.01513v2](https://arxiv.org/html/1808.01513v2) | Face-poset vector-space sheaves, weighted cochains and Hodge theory (§§2–3). Already cited by Paper 1. | Primary mathematical foundation. Our finite coordinate truncation gives concrete maps/laws; it does not formalize the entire paper. |
| <a id="source-1908-08944"></a>[Helfer, *First-order homotopical logic*, 1908.08944v2](https://arxiv.org/html/1908.08944v2) | Fibrational semantics and homotopy-invariant first-order interpretation, including Theorem 12.3. Already cited by Paper 1. | Interpretation/equivalence layer. The current `Helfer.CochainModel` constructs the nonzero-cohomology-test fragment in an actual Quillen cochain model; the full external first-order construction remains separate. |
| <a id="source-2611-11828"></a>[Kryazhev, *Multiplicativity of the Serre Spectral Sequence in Homotopy Type Theory*, 2611.11828v1](https://arxiv.org/html/2611.11828v1) | **Primary introduction, §2, Theorems 3.26 and 4.7, and §5.1 reviewed on 2026-11-12; full proof/convention audit incomplete.** Coherent tower pairings induce spectral-sequence pairings. The type-family theorem uses fiberwise cohomology coefficients and the paper's `E₁` convention, with multiplicative convergence, Leibniz and graded-commutativity laws. It uses univalence/HITs and Eilenberg–Mac Lane mapping types; the author reports Coq HoTT formalization in progress. | Future richer graded/ring predicates, after constructing multiplicative cellular data and product-compatible transport plus an explicit comparison to its type-family model. Plain real linear stalks do not supply cup products. **Inference from our graph-family formulas:** injective `δ₀` and surjective `δ₁` give `H⁰=H²=0`, so its positive-degree products would be trivial; a useful multiplicative profile needs further structure/degrees. No metric, noise, transport-runtime or security theorem is transferred. |
| <a id="source-2606-03861"></a>[*A topos for étale-finite Heyting algebras*, 2606.03861v2](https://arxiv.org/pdf/2606.03861v2) | The étale-finite construction realizes `H` as `Sub(1)` of a topos (Theorem 5.25). | Possible logical semantics. Global truth values `Sub(1)` and the internal classifier object are distinct. Our abstract residuation interface alone does not establish all required lattice laws or construct this topos. |
| <a id="source-2610-12384"></a>[Færgeman–Kjærsgaard, *Local Constancy of the Betti Automorphic Category over the Moduli of Curves*, 2610.12384v2](https://arxiv.org/html/2610.12384v2) | Categories of derived sheaves with nilpotent singular support; fiber restriction is an equivalence over a contractible real analytic family (Theorem 10.1.0.1). Appendix B.1 organizes local constancy; global monodromy can remain. | Useful pattern: a parameter base, categories over it and coherent transport. No realization from our cellular sheaf or Helfer interfaces is supplied. Its categorical spectral projector is distinct from an orthogonal Hodge projector. Local equivalence alone does not establish metric preservation, key rotation or byte recovery. |
| <a id="source-2611-05209"></a>[Fernandez Herrero–Inchiostro, *Relative cohomology and base-change*, 2611.05209v1](https://arxiv.org/html/2611.05209v1) | **Primary §2 / Theorem 1 reviewed.** For a finite-type separated morphism between schemes locally of finite type over a locally Noetherian base, and a bounded termwise base-flat quasicoherent complex, derived pushforward has a local bounded base-flat model and the stated derived base-change comparison. Part (c) also requires the target to be base-flat and the cohomology to be coherent with proper support over that target. | Candidate for coherent constructions over parameter families. An actual scheme/relative-sheaf realization and comparison with the finite cellular model are required. It supplies no metric preservation, noise sampler or cryptographic security theorem. |
| <a id="source-2610-40746"></a>[Odabasi, *Homotopy in enriched functor categories: Frobenius exact structures and weak Serre functors*, 2610.40746v1](https://arxiv.org/html/2610.40746v1) | **Primary abstract and introduction reviewed.** Studies sufficient conditions for a selected exact structure on an additive enriched functor category to be Frobenius; weak Serre data support objectwise descriptions of the resulting homotopy relations. Detailed theorem/proof audit remains open. | Candidate functor/homotopy organization. Relating its exact/stable-category homotopy to the existing Helfer/Quillen cochain model requires an explicit adapter and its hypotheses. It gives no automatic isometry, noise distribution or encryption/retrieval security. |

### Geometry, code extraction and reduction

The pinned Mathlib revision supplies [the graph criterion](https://github.com/leanprover-community/mathlib4/blob/56a005855ea17e0b0958f73ec801ae140b0a1679/Mathlib/LinearAlgebra/Prod.lean)
for subspaces with bijective first projection, [nonzero projective points](https://github.com/leanprover-community/mathlib4/blob/56a005855ea17e0b0958f73ec801ae140b0a1679/Mathlib/LinearAlgebra/Projectivization/Basic.lean),
and [Frobenius matrix norms](https://github.com/leanprover-community/mathlib4/blob/56a005855ea17e0b0958f73ec801ae140b0a1679/Mathlib/Analysis/Matrix/Normed.lean).
Its [Grassmannian](https://github.com/leanprover-community/mathlib4/blob/56a005855ea17e0b0958f73ec801ae140b0a1679/Mathlib/RingTheory/Grassmannian.lean)
uses quotient rank. Our fixed Euclidean plane of dimension `r` in dimension
`n` corresponds to quotient rank `n-r`. The pinned file leaves affine
charts and representability as further work.

| Source | Result/definition examined | Possible role and boundary |
|---|---|---|
| <a id="source-micciancio-2001"></a>[Micciancio, *The hardness of the closest vector problem with preprocessing*](https://cseweb.ucsd.edu/~daniele/papers/CVPP.pdf) | **Primary §3 checked 2026-11-25.** The reduction from subset sum has an integer basis with an identity block scaled by two, an integer target and an integral squared threshold. | Exact NP-hardness input to the coupled graph threshold reduction. The preprocessing results and approximation results are outside that use. |
| <a id="source-2601-19830"></a>[*Grassmann–Plücker functions for orthogonal matroids*, 2601.19830v2](https://arxiv.org/html/2601.19830v2) | Restricted Plücker data for maximal isotropic subspaces of a split orthogonal space, with recovery of the subspace (Corollary 3.7). | A specialized algebraic comparison; our arbitrary real harmonic subspaces still have no selected orthogonal-matroid realization. **Status update, 2026-11-08:** [Reconstruction](../lean/Proximity/Concrete/GrassmannianPlucker/Reconstruction.lean) now recovers the subspace/projector and proves full-shadow equality exactly when genuine ranked points agree (`publicShadow_eq_iff_same_point`). This supersedes the initial review's soundness-only gap; digest inversion remains separate. |
| <a id="source-0911-1298"></a>[Beelen–Ghorpade–Høholdt, *Affine Grassmann Codes*, 0911.1298v2](https://arxiv.org/abs/0911.1298v2) | Span of all minors of a finite-field matrix, evaluated on all matrices; exact length, dimension and minimum distance. Section 7 identifies the normalized big-cell connection to Grassmann/Plücker evaluation. | Direct coding reference to assess for the extraction layer. Applying its distance requires choosing that finite-field chart/evaluation code and proving the identification. The current real shadow and subsequent plane-to-RS encoding do not supply this automatically. Minimum codeword distance does not prove the missing geometric-source-to-pair far comparison. |
| <a id="source-2609-18098"></a>[*Hyper-derivative Algebraic Geometry Codes via Local Expansions*, 2609.18098v1](https://arxiv.org/html/2609.18098v1) | Finite-field function evaluation through local derivative jets, with an ordered NRT metric. | Alternative codec research. Current paired RS words have independent coordinates and whole-pair Hamming distance. A derivative relation, new locus/codec and metric comparison would need construction before importing bounds. |
| <a id="source-2608-22663"></a>[Guruswami–Li–Singhal, *Average-Radius List-Decodability of Random Linear Codes*, 2608.22663v2](https://arxiv.org/html/2608.22663v2) | Random linear codes have a high-probability average-radius guarantee near finite-alphabet capacity, stronger than ordinary list decoding. | Paper 3 comparison source. Applying it needs an actual ensemble/transfer theorem for our fixed code; it constructs no harmonic projector or geometric-to-Hamming bridge. |
| <a id="source-1312-6454"></a>[Curry–Ghrist–Nanda, *Discrete Morse theory for computing cellular sheaf cohomology*, 1312.6454v2](https://arxiv.org/html/1312.6454v2) | Acyclic matching with invertible differential blocks gives a reduced cochain complex and chain-homotopy equivalence (Theorem 2.6). | Potential computational reduction with retained maps/certificates. Cohomology preservation allows dimension changes and does not automatically preserve Euclidean distances or literal harmonic representatives. Preserve lifts and the original metric if the original HCP target matters. |
| <a id="source-2011-14057"></a>[*Multidimensional Persistence Module Classification via Lattice-Theoretic Convolutions*, 2011.14057v2](https://arxiv.org/html/2011.14057v2) | Order-indexed homology/persistence features and meet/join convolutions for classification. | Optional feature/learning reference. Filtration persistence, disk retention and integral CVP lattices have separate meanings. The proposed invariants are incomplete classifiers and do not authenticate a snapshot. |
| <a id="source-1507-01653"></a>[Keti–Wan, *Deep Holes in Reed–Solomon Codes Based on Dickson Polynomials*, 1507.01653v4](https://arxiv.org/html/1507.01653v4#S2) | Primary §2 reviewed: the standard distance bounds give degree-`k` deep holes for proper RS codes. | Paper 3 §5 cites this classical witness. The exact interleaved multiplicity is the manuscript's interpolation deduction, rather than a formula attributed to this source. See the coding comparison (archived reference: `archive/documentation/docs/PROXIMITY_NOVELTY_COMPARISON.md`). |
| <a id="source-eprint-2025-2051"></a>[Bordage–Chiesa–Guan–Manzur, *All Polynomial Generators Preserve Distance with Mutual Correlated Agreement*, CCC 2026 / ePrint 2025/2051](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.CCC.2026.24) | Published primary introduction/§1.1 reviewed: broader polynomial-generator MCA formulations for linear codes. | Background citation in Paper 3 §6. No quantitative theorem, event identification or protocol reduction is imported by this citation; the comparison note (archived reference: `archive/documentation/docs/PROXIMITY_NOVELTY_COMPARISON.md`) records review depth. |
| <a id="source-2611-07607"></a>[Alrabiah–Goyal–Guruswami, *Combinatorial limitations of list-decoding Reed–Solomon codes*, 2611.07607v1](https://arxiv.org/html/2611.07607v1), [ECCC TR26-304](https://eccc.weizmann.ac.il/report/2026/304/) | **Primary Theorems 1.1, 1.2, 1.4 and proof overviews reviewed; complete proof audit remains open.** Posted November 5, 2026. Full-length extension-field codes of length `N=q^(4t)` at rates `q^(-2)` or `(1-q^(-1))^2` have `N^(Ω_q(log N))` nearby words just beyond Johnson. Specified full-length prime-field families have growing polynomial lists at a constant gap below capacity. | Paper 3 comparison, with no contradiction identified in its selected claims: our explicit family uses `n=256*2^u` subgroup points in a field of size `3^n`, not full length; the boundary prime also has length `4096` distinct from its field size. The endpoint list `choose(n,k)` and fractional-field budget allow exponential-in-length lists and assert no polynomial-list capacity theorem. Single-word lists do not automatically identify our pair-MCA event. No Lean adoption and no prerequisite for Paper 1 submission. |

### Field of definition of coding witnesses

| Source | Result examined | Role in Paper 3 |
|---|---|---|
| *Galois Obstruction Theory*, local checkout `galois-obstruction-theory` at `4f8a63cd946ab4a99d4fffe2bd42c1043f5c7d4a`, manuscript §1 and `Hodge/Correspondence/OrbitPoints.lean` | Equality of images is a pullback of the diagonal. Finite split labels carry a Galois action, and orbit cardinality gives the residue degree of each point. | Apply the collision test to marked support directions and compute which finite incidence patterns have rational representatives. For the four-pair matching over `F_17`, the two pencils are one orbit of length two. The uniform spectrum still requires the independent incidence bounds in §6. |
| [Stacks Project, Tag 03QR](https://stacks.math.columbia.edu/tag/03QR) | Étale schemes over a field and Galois sets of geometric points. | A finite reduced incidence locus over a finite field has an orbit of degree `d` visible exactly over extension degrees divisible by `d`. |
| [Jurrius–Pellikaan, *The Coset Leader and List Weight Enumerator*](https://ruudp.win.tue.nl/paper/71.pdf) | Extension codes, syndrome support subspaces, and list weight enumerators via arrangements. | Paper 3 counts all exact supports through the prescribed radius and obtains the worst list from the realized intersection-lattice strata. |

### Polynomial agreement certificate sources

| Source | Result examined | Role in Paper 3 |
|---|---|---|
| <a id="source-euclidean-tensor-prices"></a>[OpenAI, *Euclidean Geometry in the Asymptotic Spectrum of Tensors*](https://github.com/openai/math/blob/3344da59991ed94f9ba711217b29c1d760badfa6/preprints/Euclidean-geometry-in-the-asymptotic-spectrum-of-tensors-November-24-2026/paper.pdf) | Theorem 1.1 and the introduction give the Euclidean price of a wire, restriction monotonicity, and the sum bound from spectral-point additivity. | Paper 3 applies those price properties to a tagged agreement tensor. The finite-field certificate proofs are independent of the price construction. |
| <a id="source-setiabrata-2019"></a>[Setiabrata, *Math 4370, Computational Algebra*](https://math.mit.edu/~setia/4370fa19.pdf) | Theorem 6.17.1 gives the Zariski closure of a projection over an algebraically closed field as the variety of the elimination ideal. | Eliminating the normalized witness coefficients gives the closure of the received-pair locus. The Lean checks concern the finite linear equations and their affine fibers. |

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
| <a id="source-regev-2009"></a>[Regev, *On Lattices, Learning with Errors, Random Linear Codes, and Cryptography*, author version dated May 2, 2009](https://cims.nyu.edu/~regev/papers/qcrypto.pdf) | **Primary §1 definition reviewed on 2026-11-24.** Search LWE receives a public linear sample matrix and noisy modular products and recovers a hidden vector. The paper's lattice reductions and encryption construction have additional parameter and computational hypotheses. No full proof audit undertaken here. | Grounds the manuscript's CVP/LWE/HCP task comparison and noisy-algebraic motivation. HCP's exact/coexact noise is tied to private Hodge geometry. The comparison does not identify the problems, import LWE security, or prove that HCP is computationally harder than CVP. |
| <a id="source-gentry-2009"></a>[Gentry, *A Fully Homomorphic Encryption Scheme*, Stanford thesis, 2009](https://crypto.stanford.edu/craig/craig-thesis.pdf) | **Primary abstract and Definitions 2.1.1--2.1.6 reviewed on 2026-11-12.** Correctness of encrypted evaluation, compactness, fully/leveled homomorphic evaluation and separate circuit privacy. Full construction/reduction audit not undertaken here. | Expository anchor for comparing commuting encryption/recovery squares and, later, supported operations. Our proved integral-isometric presentation transport does not establish general FHE evaluation or adopt this scheme's security. |
| <a id="source-key-homomorphic-2014"></a>[Boneh et al., *Fully Key-Homomorphic Encryption, Arithmetic Circuit ABE and Compact Garbled Circuits*, EUROCRYPT 2014](https://crypto.stanford.edu/~dabo/pubs/abstracts/lattice-abe.html) | **Primary author abstract and bibliographic metadata reviewed on 2026-11-12.** Describes public ciphertext translation from key `x` to `(f(x),f)` retaining the plaintext, under its stated LWE assumptions. Detailed construction/proof audit remains open. | Required novelty comparator for presentation/key transport. Match actual key visibility, permitted maps, algorithms and security experiments; a commuting diagram or homotopical name alone does not establish novelty. No HCP reduction is supplied. |
| <a id="source-cl06"></a>[Chase–Lysyanskaya, *On Signatures of Knowledge*, CRYPTO 2006](https://cs.brown.edu/people/alysyans/papers/cl06.pdf) | **Primary §§2.2–3 examined on 2026-11-15.** SimExt games and the encrypt-then-prove construction: auxiliary dense CPA encryption holds message/witness, a simulation-sound NIZK proves consistency, and extraction decrypts. | The current native CRS interface follows its game organization. Its actual construction would need those auxiliary algorithms and assumptions; current HCP encryption does not automatically fill the public-encryption slot. No UC or quantitative security theorem is imported. |
| <a id="source-bgpr2022"></a>[Baghery–González–Pindado–Ràfols, *Signatures of knowledge for Boolean circuits under standard assumptions*, TCS 916 (2022), 86–110](https://imec-publications.be/server/api/core/bitstreams/16add66f-1230-43ee-80f1-9c0e93c7f206/content) | **Primary Definition 5 and §§5–6 examined on 2026-11-15.** Tagged Boolean extraction, component reductions and the statement/message hash tag; full component proof audit incomplete. | Compatible with straight-line trapdoor extraction. Actual encoded bilinear groups, selected matrix/kernel-DH assumptions, complete circuit refinement and tag-collision accounting remain necessary. No secure backend, numerical bounds or UC theorem is instantiated here. DOI: [10.1016/j.tcs.2022.03.006](https://doi.org/10.1016/j.tcs.2022.03.006). |
| <a id="source-vcvio"></a>[VCVio, revision `a95ea9221819`](https://github.com/Verified-zkEVM/VCVio/tree/a95ea922181968f96cbd2e668be6aef6892c67dc) | **Pinned dependency and primary semantics audited on 2026-11-25.** The [HiddenSeed module](https://github.com/Verified-zkEVM/VCVio/blob/a95ea922181968f96cbd2e668be6aef6892c67dc/VCVio/OracleComp/QueryTracking/RandomOracle/HiddenSeed.lean) compares a shared public/derivation cache with an independent ideal derivation table. Its adaptive event theorem charges `q * epsilon` when each public address belongs to the secret encoding with probability at most `epsilon`. It permits an infinite operator-packet type. The [commitment example simulator](https://github.com/Verified-zkEVM/VCVio/blob/a95ea922181968f96cbd2e668be6aef6892c67dc/Examples/CommitmentScheme/Hiding/CountBounds.lean) retains the challenge at its original cache address; that named hiding game is not the independent-root experiment required here. Earlier ElGamal and signature comparisons remain background. | **Used in H126–H128.** The exact canonical packet/nonce encoding gives `epsilon=256^-32`; the native public-only decoder game proves recovery at most `2^-n+(q+2)/256^32`. Existing Lean/Mathlib pins are unchanged. PolyFun/cslib are imported foundations; QuantumFoundations is a declared transitive package outside this theorem's import closure. No commitment-example hiding theorem, concrete hash security, tagged CRS primitive or quantum-adversary result is imported. |
| <a id="source-2007-04099"></a>[Ghrist–Riess, *Cellular Sheaves of Lattices and the Tarski Laplacian*, 2007.04099v2](https://arxiv.org/html/2007.04099v2) | Lattice stalks with Galois adjunctions; fixed points of `id meet L` are global sections of the lower-map sheaf. Completeness and termination require the stated order hypotheses. | Promising `TaskSheaf` constraint-propagation model, after constructing its actual stalks/adjunctions. The current truth order `Invalid < Undetermined < Valid` makes the meet flow descending; evidence growth requires a deliberate order/semantics choice. DCC gives per-orbit termination, not a uniform round bound. |
| <a id="source-2605-15778"></a>[Ghrist, *Clearing in Liability Networks via Sheaves on Directed Hypergraphs*, 2605.15778v1](https://arxiv.org/html/2605.15778v1) | Local payment constraints, distribution/aggregation maps and global clearing as an equalizer/fixed-point problem; existence and uniqueness depend on additional hypotheses. | Useful local-constraint-to-global-transition pattern. Any economic interpretation remains unselected. Compiling a proposed clearing into the conservative kernel needs authorization, availability, freshness and conservation proofs for the same action. |
| <a id="source-2605-26883"></a>[Cignarale–Rincon Galeana, *A Dynamic Deontic Simplicial Logic for Joint Commitments*, 2605.26883v2](https://arxiv.org/html/2605.26883v2) | **Primary §§2,5–6 definitions and theorem statements reviewed; proof audit incomplete.** Version 2 is dated July 9, 2026. Agent-coloured simplices model social group commitments; dynamic modalities use precondition-filtered product updates. The paper presents static/dynamic soundness and completeness. | **Paper 2 candidate; no adoption or Lean formalization here, and no prerequisite for Paper 1 submission.** Could organize `Policy.authorized` and joint evidence, after constructing agent/state valuations and a correspondence theorem. A box action may hold vacuously when disabled; actual acceptance needs execution evidence. Product updates retain local valuations, whereas `Candidate.after` changes resources/nullifiers: a simulation law is needed. These normative commitments are distinct from cryptographic cochain payloads and their authentication/security contracts. |
| <a id="source-2611-05136"></a>[*Information Loss Is All You Need: TC0 Pseudorandomness from Worst-Case Lattices*, 2611.05136v1](https://arxiv.org/html/2611.05136v1) | Preliminary main-statement review: deterministic keyed rounding and a lattice quotient, with conditional worst-case lattice/LWE reductions. Its weak-PRF claim uses classical uniform random examples against a uniform quantum polynomial-time distinguisher; it does not establish chosen-input or quantum-query security. | Security-game comparison only. The paper's examples can determine the secret information-theoretically; the claimed barrier is computational. No HCP-to-distribution/reduction map is instantiated. Information loss alone establishes neither pseudorandomness nor distance preservation. A dedicated proof audit remains open. |
| <a id="source-2610-37061"></a>[*GKS Fully Homomorphic Encryption: Security Analysis*, 2610.37061v1](https://arxiv.org/html/2610.37061v1) | Preliminary game/deployment review: plaintext slots/ring, ciphertext algebra, secret ideal and quotient/retraction are separated. The security theorem retains an open balance lemma; the experiment needs clarification and KPA/CPA security is not claimed. | Helps separate encrypted storage, encrypted search/computation, custody and epoch capabilities. It does not establish authenticated database queries or expiration of copied ciphertext. No construction or security claim is adopted here. |
| <a id="source-eprint-2026-910"></a>[Fisch–Liu–Tromer–Wang, *UnifOMR: Oblivious Message Retrieval with Near-Optimal Concrete Efficiency*, ePrint 2026/910](https://eprint.iacr.org/2026/910) | **Primary abstract and ePrint metadata checked only.** Separates encrypted message contents from recipient/message metadata; compares OMR and PIR under strong detection-key-unlinkability and uses batch PIR in its construction. Detailed protocol/proof audit remains open. | Planned Paper 2 private-discovery/retrieval comparison, already in its bibliography. The reference does not select a detection-key representation, implementation, parameter set or security theorem for HCP. Hash authentication, selector privacy, recipient discovery and network anonymity require separate contracts. |

### Architecture provenance for key use

The archived [ephemeral-message plan](archive/PANOPTICON_RESILIENCE.md)
and [routing/storage plan](archive/STORAGE_AND_ROUTING.md) distinguish
fresh per-message fibers from a persistent wallet master that re-encrypts
stored records during rotation. The [transaction architecture](archive/ARCHITECTURE.md)
also proposed new fiber points per transaction. These establish historical
intent only. The current selected design target is exact harmonic recovery,
fresh geometry per public encrypted object and persistent private master-key
management. The nonce-bearing operator opening and V2 native wire are now constructed
in [OperatorCommitment](../lean/Protocol/Storage/OperatorCommitment.lean) and
[NativeCommitted](../lean/Protocol/Transfer/PathSignature/NativeCommitted.lean).
The [finite instance-view reduction](../lean/Protocol/Transfer/PathSignature/NativeCommittedPrivacy.lean)
is explicit. A separate exact-byte random-oracle construction now proves
the bounded-query native recovery bound; the concrete implementation and
proof/storage transcript remain further security profiles. Wallet-at-rest and reused-geometry security remain separate. Current
[scoped native delivery](../lean/Protocol/Ephemeral/NativeDelivery.lean) is
reusable; freshness, protected delivery and retirement require their actual
selected policy and implementation.

### Operator-commitment provenance

The earlier [native primitive plan](archive/PRIMITIVES.md) preferred cochain
commitments over Pedersen for payload values. Its coboundary and Hodge-blinding
objects concern `C¹` values inside a sheaf; they do not commit to a varying
private operator.

There is also a concrete, separate operator-commitment prototype in
[`homotopical_zkp.py`](../archive/runtime/src/proofs/homotopical_zkp.py).
`_commit_laplacian` hashes a domain separator, the Laplacian snapshot, its path
parameter and a fresh 32-byte secret nonce. `GeodesicCommitment.to_public_bytes`
returns only the digest before opening. This is historical precedent for a
private-nonce operator hash, not evidence that a group-based operator
commitment was selected. The nonce is a private opening, distinct from a
public transaction counter or credential salt.

The prototype uses floating-point array bytes and publishes selected operator,
parameter and nonce openings in its proof. Its sampled indices include zero,
whose snapshot is the initial secret operator; opening that index discloses
it. Consequently the commitment idea must be separated from that archived
cut-and-open proof when constructing a non-disclosing profile. Canonical
encoding, the full released proof view and a quantitative hiding argument
remain required; the old comments do not supply them or select a ROM theorem.

The active [operator commitment](../lean/Protocol/Storage/OperatorCommitment.lean)
now replaces the prototype's floating-point preimage with the existing
canonical integer coupling packet and a separate private 32-byte nonce.
[Versioned native checking](../lean/Protocol/Transfer/PathSignature/NativeCommitted.lean)
and the [original-context adapter](../lean/Protocol/Transfer/PathSignature/NativeCommittedContext.lean)
retain the same geometry and public three-name instance. The
[finite instance-view theorem](../lean/Protocol/Transfer/PathSignature/NativeCommittedPrivacy.lean)
reduces recovery above `2^-n` to an explicit chosen-operator commitment test;
the [bounded-query random-oracle theorem](../lean/Protocol/Transfer/PathSignature/NativeCommittedRandomOracle.lean) now supplies a concrete recovery bound in that model.

The later [visibility audit](../archive/documentation/docs/SEMANTIC_PARITY_QUEUE.md)
explicitly reopened the choice between a private frame/shadow with a hiding
commitment and proof, a proved-safe public projection, or deliberate audit
disclosure. Its warning that hash binding is not hiding still applies.
The [architecture](archive/ARCHITECTURE.md) separately assigns outer hashes to
encrypted content and public audit/indexing. Preserve these three roles:
native cochain payload, private operator commitment, and outer content hash.

The core geometry must be fixed before selecting that commitment's preimage.
The active [coupled geometry](../lean/HCP/CoupledGeometry.lean) reconstructs
its cellular maps, standard Euclidean metrics, integral stalks and graph
encoding from the dimensions and integer coupling matrix. The actual
differential and true Hodge operator each determine that matrix in this fixed
profile. Its assembly, projection and coefficient diagrams are proved on the
same objects. This recovers the geometry-first direction of the earlier
plans without adopting their spectral-classification, anonymity or
adjoint-inverse claims. A larger profile must encode any additional varying
topology, metric, lattice or basis data; a derived Laplacian alone does not
generically bind those choices. The current snapshot is indexed by the sheaf,
with additional integral/decoder/profile bindings still explicit.

The earlier V1 witness uses the salt for its source credential and hashes the
bare target matrix for its snapshot root. V2 supplies a separate private
target opening and the versioned context and codec joins described above.
The shared byte random-oracle theorem covers its one-use public instance and
ciphertext. The concrete proof backend and its released-view simulation
estimate remain open.
