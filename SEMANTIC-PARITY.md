# Manuscript--Lean semantic parity

Review dates: 2026-11-04; mathematics/storage, object-model and toolchain
follow-ups 2026-11-05.

**Completed mathematics follow-up:** the three native chain metrics remain
separate (cochain/local, plane, RS). The explicit systematic modular profile
now has an actual cellular/integral source, global native-distance comparisons,
a capacity-far original payload and its challenge analysis. Full Plucker
reconstruction and the geometric/fixed-compression obstructions are proved.
The expanded full build passes 9,253 jobs; the default build passes 9,248.
A fresh consolidated 139-declaration audit reports 103 standard-only and 36
with existing native arithmetic certificates. Paper 2's
[initial manuscript text](papers/paper2/DRAFT.md) records the shared contracts.
The earlier 4.35 and 4.24 counts below remain dated baselines.
The [HCP object crosswalk](docs/COCHAIN_PROXIMITY_TRACE.md#hcp-object-accounting-rotation-and-anonymity)
now accounts for HC01--HC44, including the intended ephemeral/anonymity flow
and the uninstantiated Helfer/Hodge/public-view joins. This is a documentation
audit, not a new concrete family or security theorem.

This is the shared register for manuscript ownership, notation, and issues
across the three papers. It follows the object/claim/status
separation used in the Jacobian project's `SEMANTIC-PARITY.md`. A paper split
does not create a second mathematical object or prove a missing comparison.

The detailed coding inventory remains in
[the proximity parity register](papers/proximity-prize/SEMANTIC_PARITY.md):
its O01--O40 core object IDs and T01--T20 claim IDs are reused here rather than
renumbered or assigned different proof statuses. The HCP appendices retain
their declaration and file coverage ledgers. Build, source and dependency
checks are recorded per toolchain below; they do not prove the open
application bridge.

## Current working status

This table separates the current sources from their last completed validation.
The main Lean/Mathlib upgrade was explicitly authorized after the successful
history-anchor baseline.

| Item | Current source / decision | Validation and remaining boundary |
|---|---|---|
| Toolchain and dependencies | Lean `v4.35.0`; Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`; all nine checkout revisions match. All 234 source modules use public-module interfaces (235 Lean files including Lake configuration). | **Current validation passes:** expanded aggregate/examples 9,253 jobs, default 9,248 jobs, and fresh 139-declaration audit. Earlier 9,233/9,228/68 and 4.24 results are preserved baselines. |
| History, snapshot and retained artifacts | Public block/event history references a snapshot-bound application sheaf and retained manifest; the StateBus is temporary processing state. `Storage.Anchor` and `ProjectionAnchor` join the same candidate, interpretation, original artifact, exact final prefix and actual gate database under explicit inclusion contracts. | Current-pin integration checks and the fresh nineteen-endpoint standard-axiom-only audit pass. P215--P216 retain the earlier baseline. Byte/hash/backend profiles, dynamic geometry and finality remain open. |
| Harmonic projection and metrics | Three native levels are retained. The actual modular source has `d_C ≤ d_P = D_RS ≤ 2d_C`, with factor two sharp for proper RS codes; the existing near projection uses `2d_C`, far calibration uses `d_C`. | Source/cell/payload compatibility and all-radius native comparisons are proved. Upstream Euclidean exactness, full-HCP residual and frame scores remain separate. The no-wrap Euclidean theorem is a first-shell result; a global zero-defect comparison is obstructed. |
| Plucker and possible moduli structure | Full concrete projective data now reconstruct the subspace/projector, identify genuine ranked points, and have constructive soundness. The raw quotient still contains the zero orbit. | H17 and D02 distinguish full data, a digest and identification with the operative kernel. No bundled projective variety or stack is asserted; visibility/security remains a separate profile. |
| Paper split and remaining mathematics | Paper 1 owns HCP/source geometry; Paper 2 records the shared commitment, validity, metric and evidence contracts in its draft; Paper 3 owns the coding analysis and explicit modular application. | Scoped Q08 native-metric construction and capacity family now pass. Arbitrary HCP/frame score identification, protocol/security refinements and stronger geometric claims retain their stated boundaries. |
| Intended HCP and anonymity family | HC01--HC44 distinguish Helfer interpretations/classes, actual Hodge/integral objects, structured noise, commitments, gates, public view, rotation and retained state. | Existing same-class/transport and conditional recovery results are traced. Concrete semantic realization, integral bundle, full-view compatibility, generated family and sampling/security experiment remain explicit. Orthogonal rotation and fixed-observation ambiguity have different proof obligations. |
| Palomar preparation | Two prospective entries, Papers 1 and 3, following the Jacobian setup. The user confirms Jacobian Part 1 is already under review. | [Preparation map](docs/PALOMAR_SUBMISSION_PLAN.md): finish current validation and scope alignment, then statement/proof wrappers, metadata, protected comparison and a frozen public submission snapshot. This repo has not been submitted or registered. |

The [active categorical map](docs/CATEGORICAL_ARCHITECTURE.md) records the
central projector and projective/moduli distinctions. The local working note
`docs/CHAIN_NETWORK_OBJECT_REVIEW.md` preserves the competing historical plans
and source readings outside the public subset. The numbered claims below
retain their existing IDs.

## Manuscript ownership and dependency table

The publication numbering, confirmed by the user on 2026-11-04, is:

| Paper | Manuscript / current artifact | Owns | Dependency |
|---|---|---|---|
| **1** | [Homotopical Encryption](papers/paper1/README.md); LaTeX and PDF | HCP foundations, hidden operators, mathematical commitment interfaces, conditional application projection | Supplies the mathematical interfaces used by Paper 2. |
| **2** | [Proof-Carrying Homotopical Encryption](papers/paper2/README.md); [initial manuscript text](papers/paper2/DRAFT.md), scope and bibliography; no TeX/PDF bundle yet | Commitments/public observations, typed protocol evidence, accepted transitions, three native metric contracts, runtime and security boundaries | Must identify its concrete objects with the Paper 1 interfaces it claims to instantiate. Recommended first scope: [one proof-carrying transition](papers/paper2/SCOPE.md). |
| **3** | [Capacity-Radius Proximity](papers/proximity-prize/README.md); LaTeX, PDF, standalone Lean target | Universal coding results, calibration, and the selected actual commitment-projection radius analysis | Its coding proofs do not depend on finishing Paper 2. The commitment-specific claim needs a bounded shared profile and an original-source distance comparison. |

The earlier assignment of “Paper 3” to product/whitepaper material is
superseded. Product material is unnumbered future work. Keep the existing
directories and O/T IDs; numbering does not create a new mathematical object.

| ID | Material / canonical owner | Paper 1: HCP manuscript | Paper 3: proximity manuscript | Dependency / disposition |
|---|---|---|---|---|
| S01 | HCP, operative projection, Hodge decomposition; `lean/HCP.lean`, `lean/Sheaf/` | **Owns** definitions and arguments in §§2--4. | No HCP hypothesis in its coding theorems. | Retain in HCP. A later HCP application cites these foundations. |
| S02 | Public classifier, Helfer bridge, fixed-coordinate ambiguity, CVP comparison; `lean/HCP.lean`, `lean/Hardness.lean`, `lean/CVP.lean` | **Owns** §§2--4. | Does not inherit these as coding-theorem assumptions. | The ambiguity theorem and universal coding theorems have independent hypotheses. |
| S03 | Exact cochain commitments, visibility, public artifacts; `lean/Sheaf/Commitment.lean`, `lean/Axioms/CochainCommitment/` | **Owns** §§4--5. | §7 reuses and traces the same payload; no replacement commitment. | Protocol-specific games and byte semantics belong to Paper 2. |
| S04 | Plücker/cochain/plane extraction and source score; `lean/Proximity/Concrete/` | **Owns** source semantics and the conditional application bridge in §§5--6. | §7 traces the actual edge-value extraction and existing public plane/pair calibration; the selected radius analysis consumes that same map. | Share definitions. The original-source metric comparison and a nonempty actual far region remain to be established for the chosen profile. |
| S05 | Finite words, interleaving, Hamming metrics, same-set MCA; `lean/Proximity/Core/`, `lean/Proximity/MCA/Definitions.lean` | §6 recalls the definitions needed for its endpoint. | **Owns** the universal coding presentation, §§2--3,6; O01--O11, O14--O19, O36. | Intentional shared vocabulary. Reuse the same objects and identify count/relative conventions explicitly. |
| S06 | Capacity-grid list equality, next-shell obstruction, fractional phase split; `lean/Proximity/ListDecoding/` | Cite through the application interface if used. No need to repeat proofs. | **Owns** §§4--5; T02--T06. | Independent of hidden geometry. The all-parameter realization, full phase split and real-radius endpoints now have Lean proofs. |
| S07 | Universal pair-MCA certificate bound and exact spectrum; `lean/Proximity/MCA/` | May consume a specialized coding theorem for a fixed pair. | **Owns** §6; T07--T13, T17--T19. | A universal bound is not an exact spectrum formula. The fixed-pair quantifier is retained. |
| S08 | Large-field family and boundary-field instance | The HCP runtime field is a separate application instance. | **Owns** the `q=3^n` family and `q=2^128+192513` example. | Neither instance is the canonical HCP field `q=12289`; no 128-bit guarantee transfers by naming. |
| S09 | Neutral source-to-code calibration; `lean/Proximity/Application/Calibration.lean` | Instantiates it only after identifying its target distance and proving the comparison. | **Owns** §7's generic contract; O23--O26, T14--T15, T20. | Shared interface. With an existing source metric, the application supplies `ρ_source ≤ D_pair ∘ extract`. |
| S10 | Canonical `q=12289`, `n=4096`, `k=1024`, `δ_J=2047/4096`; `lean/Proximity/Concrete/CanonicalRS/` | **Owns** §6's fixed-field endpoint and cited Johnson/MCA boundary. | §7 records canonical pair reduction, proved distance equality, and actual observed-payload calibration; T16 records the separate full-pair field-size obstruction. | Concrete modules are outside `ProximityPrize`'s standalone import closure. The full-pair obstruction does not settle a restricted actual projection image. |
| S11 | Runtime verification, storage, consensus, security games | States mathematical interfaces and future-work boundary. | Outside coding proofs. | Future **protocol** paper, `papers/paper2/`; do not merge its scope with the proximity manuscript. |

The dependency is therefore: HCP foundations support the HCP application
bridge; independent coding results can be consumed through an explicitly
calibrated interface. Shared definitions are intentional overlap. Repeating
the companion's capacity or certificate proofs in the HCP paper is unnecessary.
The [actual-object trace](docs/COCHAIN_PROXIMITY_TRACE.md) distinguishes one
commitment's two-coordinate pair from the affine line through two final
scalar outputs; these are different MCA specializations.

## Object and notation dictionary

Status axes are separate:

- **exact**: source inspection identifies the same object or a proved claim
  with its actual hypotheses;
- **parameterized**: a construction or conclusion takes an explicit input;
- **missing**: a claimed endpoint or required construction is not supplied;
- **not identified**: two objects are present without a proved comparison.

An assumption interface is **parameterized**, not a proved security theorem.
Editorial disposition is recorded separately as **corrected**, **retain**, or
**open**. Older compatibility declarations are retained; this review deletes
no mathematical objects.

| ID | Manuscript notation / semantic role | Canonical Lean owner | Identity, hypotheses, and guardrail | Paper owner |
|---|---|---|---|---|
| H01 | `x`, `α=π(x)`, `A_α=π⁻¹(α)` | `HCPBridge.Realization`, `Observation`, `HiddenHodgeWitness`; `lean/HCP.lean` | **parameterized** realization. A witness selects the operative representative; equal public values do not identify it or reconstruct a path. | HCP §§2,4 |
| H02 | `(α,b)` and `h_x(b)=P_{ker Δ_x}b` | `HCPBridge.Observation`, `operativeTarget`, `SolverExactOnOperativeTarget` | **exact** vector-level target. A commitment/proof about `b` is **not identified** with public access to the vector. | HCP §§2,5 |
| H03 | `δ₀`, `δ₁`, `Δ₁=δ₀δ₀*+δ₁*δ₁` | `Sheaf.CellularSheaf.delta0`, `delta1`, `degreeOneLaplacian` | **exact** concrete finite cellular construction. Restriction data include both vertex-to-edge and edge-to-face maps. | HCP §§2,4 |
| H04 | `P_H`, locally `P_{H_x}`, harmonic projection | `Sheaf.CellularSheaf.harmonicOneProjection`, `HodgeEncryptedCochain.harmonicOneProjection_observed`, `HCP.operativeHarmonicComponent`, `HCPBridge.operativeTarget`; `Laplacian.harmonicProjection` | **exact** recovery/retraction in the appropriate model and the central operative HCP target. Use `P`, reserving `π` for classifiers/extraction. An abstract subspace still needs identification with the operative kernel. Projection alone loses the orthogonal coordinate; the full Hodge splitting retains it. | HCP §§1--5 |
| H05 | `Δ_W=I-P_W`, residual `ρ_W(b)` | `lean/Laplacian/{Projection,Hodge}.lean` | **exact** projection model. Same kernel as a cellular Laplacian does not imply the same operator or positive spectrum. | HCP §§2,4 |
| H06 | `b=h+e`, `H×H⊥ ≃ C¹` | `HCP.hodgeDecompositionEquiv`, `decrypt_encrypt`; `Hodge_Decomposition_Theorem` | **exact** correctness and orthogonal decomposition. The full message/noise pair is the bijection's source; no distributional secrecy follows. | HCP §2 |
| H07 | `M_x`, `Th(M_x)`, Helfer equivalence | `Hcrypt.Helfer.*`, `HCPBridge.Realization` | **parameterized** by `ClosedFormulaInvariance` and factorization. Presentation-level `Δ_x` is outside the invariant signature. | HCP §§2,4 |
| H08 | Isometric transport `U₁`, fixed public coordinate `b` | `Sheaf.CellularSheaf.IsometricCochainEquiv`, `HCPBridge.IsometricPresentationEquivalence`, `FixedCoordinateNonstabilization` | **exact conditional** transport and separation. Transporting both presentation and observation preserves harmonicity; comparing one untransported `b` needs extra separation data. | HCP §2 |
| H09 | `V_B(R)` versus `Λ_B=Bℤⁿ` | `exists_matrix_ker_eq_range`, `CVP.ExplicitLattice`, `HarmonicCVPBridge` | **exact** distinct objects. An arbitrary-field linear kernel need not be a real self-adjoint Hodge operator. Projection preserves discrete CVP minimizers after the lattice and inclusion are supplied. | HCP §3 |
| H10 | `c=(q,n,c_edges,τ)`, decoded exact cochain | `Axioms.CochainCommitmentData`, `Sheaf.CellularSheaf.CochainPayloadInterpretation`, `AcceptedCommittedOneCochain` | Payload shape is **exact**; decoding/topology binding/exactness are **parameterized**. `c` names a payload here, not the HCP sample `b`. | HCP §§4--5 |
| H11 | Opening `a`, equivalence modulo `ker δ₀` | `Sheaf.CellularSheaf.openingEquivalent_iff_sub_mem_ker` | **exact** quotient relation. Raw coboundary equality does not uniquely bind a degree-zero message. | HCP §5 |
| H12 | Blinded value `δ₀a+sH_τ`, MAC tag `P_H c(m,ν)` | `Axioms.BlindedCommittedCochain`, `BlindedCommitmentAxioms`, `CohomologicalMACAxioms` | Geometry is typed; hiding and unforgeability are **parameterized** security assumptions. Specify the MAC's cochain carrier separately from an exact payload. | HCP §5 / protocol games |
| H13 | `Spec_multi(Δ_x)`, `FID(x)` | `lean/Laplacian/Spectral.lean` | **exact** spectral-class tag. Neither an injective representative ID nor the public classifier value; kernel dimension alone does not determine it. | HCP §§4--5 |
| H14 | `λ₁⁺`, spectral window, `Ω_k` | `Axioms.SpectralBounds`, `lean/Laplacian/Grassmannian/`, `Tsirelson.lean` | Window is **parameterized** admissibility. Projection-family gap `1` requires nonzero orthogonal complement. Infinite candidate families alone do not prove computational hardness. | HCP §4 |
| H15 | `L_σ(b,A)`, classical guess, density strategy | `lean/Laplacian/Likelihood.lean` | Euclidean formula corresponds to `gaussianLikelihood_correct`. Legacy normalized-success functions use `gaussianLikelihood`; the integral endpoints are **not identified** with the corrected formula or an HCP recovery game. | HCP §4 |
| H16 | `Ω₃`, `q:Ω→Ω₃`, Heyting implication | `Axioms.Heyting`, `Axioms.OracleModality` | Finite algebra is **exact**; public collapse is a supplied interface. Node actions are distinct from logical implication. Here `q` is local to §4; elsewhere it denotes a field/modulus. | HCP §4 / protocol policy |
| H17 | Frame `𝓕`, projective coordinate `Pl(𝓕)` | `lean/Proximity/Concrete/GrassmannianPlucker.lean`, `Concrete` and `Reconstruction` | **Proved for the concrete full point:** exterior multiplication reconstructs the subspace; full-shadow equality iff the same ranked point; both former soundness inputs and the fixed-metric harmonic projector are constructed. Focused build and eight standard-only audits pass. Generic alternative framed systems retain their explicit soundness inputs; digest-only observations remain separate. | HCP §§5--6 |
| H18 | Source score `ρ(𝓕)`, local `d_L`, plane `d_P`, RS `D` | `lean/Proximity/Concrete/ProjectionChain/Core.lean`; `Application.Projection` | **parameterized** metrics and comparisons. `D≤d_P≤d_L≤ρ` is the near direction; it does not imply a far lower bound. `ρ_W(b)` is a separate vector residual. | HCP §6 |
| H19 | `p_c` integer/semantic plane, scalar `Φ_*(p_c)` | `lean/Proximity/Concrete/CochainPlane/{Core,ReedSolomon}.lean` | **exact extraction**, **parameterized** alignment/distance control. Encoding `(x₀,x₁)↦x₀+g x₁ mod 12289` is lossy, unlike O10--O11's field-valued plane/pair equivalence. | HCP §6; compare proximity §3 |
| H20 | Stage, naturality, hard, and final certificates | `lean/Proximity/Concrete/Gates/{Stage,Final}.lean`, `GateEvidence.lean` | **exact conditional** composition. Naturality squares and local nondegeneracy are fields, not consequences of distance inequalities. Concrete far separation remains **parameterized**. | HCP §6 |
| H21 | Canonical `D(w)=min_c d_H(c,w)/4096` | `lean/Proximity/Concrete/CanonicalRS/Metric.lean`: `relativeHammingDistanceToCode` | **exact** relative metric and count-to-relative conversion. The absolute `hammingDistanceToCode` is a different function. | HCP §6; proximity O07, O23 |
| H22 | Canonical `Bad_Γ(𝓕₁,𝓕₂)` and `τ_cit/card F` | `lean/Proximity/Concrete/CanonicalRS/{CitedBounds,MCA}.lean` | **parameterized** literature boundary. The error belongs to a line/pair fixed before the challenge; it is not an attribute of one scalar received word. | HCP §6; proximity O15--O19, O36 |
| H23 | Integral stalk lattices and exact-component/full-sample join | `lean/Sheaf/Integral.lean`, `Sheaf/HarmonicLattice.lean`, `TCB/HCPObservation.lean` | **exact conditional** integral-preservation and harmonic-recovery theorems. `BoundHCPObservation` carries a supplied payload interpretation/classifier/binding relation and exports a carrier-level observation. A concrete modular/public realization and a join to `HCPBridge.Realization`/`HiddenHodgeWitness` remain **parameterized/not identified**. | Paper 1 algebra; Paper 2 public realization |
| H24 | Decoded exact-cochain distance `ρ_ex` | `lean/Sheaf/Distance.lean`; `Protocol/Storage/Context.lean` | **exact** Euclidean residual to `im δ₀`, nonnegative and 1-Lipschitz. In a shape/snapshot-bound context its zero locus is actual exact-payload acceptance. This is distinct from the full HCP residual and pair Hamming distance. | Paper 1 geometry; Paper 2 storage; Paper 3 comparison |
| H25 | Concrete/legacy cochain interpretation | `lean/Sheaf/CochainSemantics.lean` | **exact conditional** transport via carrier equivalences, actual coboundary/decoder commutation and binding equivalence; acceptance equivalence is derived. Ambient legacy gates remain explicit. No norm isometry is inferred. | Paper 1 semantic interface; Paper 2 consumer |
| H26 | Full-HCP residual versus exact-component view | `lean/Sheaf/ObservationQuotient.lean` | **proved obstruction**: a nonzero allowed coexact direction yields unbounded residual with fixed exact component. An exact-component-only extraction with zero-distance zero image cannot preserve a positive far region on the unrestricted Hodge carrier. This does not prove raw-byte factorization or exclude a restricted authenticated profile. | Paper 1; cited by Paper 3 §7 |
| H27 | Raw projective quotient versus Grassmannian locus | `GrassmannianPlucker.Concrete.ProjectiveShadow`, `projectiveFramedSystem`, `ValidRawCoordinate` | **exact carrier**, **parameterized validity**. The quotient includes the zero orbit; concrete `Normalized` and `SupportAdmissible` are `True`, so `ValidShadow` alone does not enforce the nonzero decomposable locus. The hashed-shadow semantic record retains both shadow and digest. | Papers 1--2; Paper 3 comparison |
| H28 | Presentation groupoid/moduli stack | Existing same-base sheaf morphisms, isometric cochain transport, classifier fibers and categorical interfaces | **Prospective, not constructed.** Choose the site/base, morphisms, automorphisms, transport and descent. General basis changes need transported metrics; the current Hodge covariance theorem assumes isometry. A set quotient or classifier fiber alone is not a stack. | Paper 1 organization; Paper 2 profile |
| H29 | Named axiom-interface contracts versus concrete proofs | `Axioms.lean`, `Axioms/{Foundation,SheafCoherence,Fibration,HomotopyClass,HelferFOL,Grassmannian,OracleModality,CochainCommitment}` | **parameterized** interface fields are explicit inputs, not global Lean axioms or constructed algorithms. Concrete cellular/Hodge results live in `Sheaf/`. The seven global project axioms remain isolated in the existing concrete cited-bound module and outside the focused closures. | Shared foundations and boundaries |
| H30 | Three native chain metrics `d_C`, `d_P`, `D_RS` | `Core/InterleavedMetric`, `Sheaf/SystematicCode/Modular`, `Storage/ThreeLevelMetrics`; [Paper 2 draft](papers/paper2/DRAFT.md) | Modular validity is defined by an actual integral cellular coboundary plus `q`-carry, then proved equivalent to RS validity. Scalar edits normalize by `2n`, whole-pair edits by `n`; focused proofs give `d_C ≤ d_P = D_RS ≤ 2d_C`. They do not redefine real decoded exactness or full-HCP/frame scores. | Paper 2 contracts; Paper 3 quantitative analysis |
| H31 | Helfer semantic carrier versus public fiber | `Helfer/{Signature,HomotopyEquivalence,Invariance}`, `Axioms/HelferFOL`; HC01--HC07 | **Typed interface and conditional forward theorem.** Bifibrancy belongs to the equivalence witness; relation laws/setoid/quotient on an admissible carrier are not bundled. Formula syntax/full fibrational semantics and a concrete `Realization` remain uninstantiated. | Paper 1 |
| H32 | Integral harmonic messages and allowed structured noise | `Sheaf/{Integral,HarmonicLattice}`; HC11--HC15 | **Exact generic constructions.** Message is integral harmonic; exact/coexact openings are arbitrary real cochains with no bound/sampler. No concrete bundled `IntegralStructure` or `HarmonicLatticePresentation` was found. Integer systematic openings do not instantiate those bundles. | Paper 1 objects; Paper 2 profile |
| H33 | Gate-admissible full HCP observation | `Gates/*`, `Proximity/Concrete/Gates*`, `TCB/HCPObservation`, `HCPBridge.Realization`; HC17--HC35 | **Join open.** Existing gates retain separate structural, spectral, alignment, quotient, naturality and far obligations. They construct no intended Helfer realization. The actual sheaf operator/classifier/target and selected full public view still need identification. | Papers 1--2 |
| H34 | Rotation correctness versus fixed-observation ambiguity | `Sheaf.CellularSheaf.IsometricCochainEquiv`, `HCPBridge.IsometricPresentationEquivalence`; HC16, HC39--HC44 | **Conditional geometric covariance proved.** Rotation transports `b,h,noise`; plaintext/lattice encoding and snapshot migration need their own laws. Ambiguity holds raw `b` fixed. Different coordinate vectors alone do not prove different semantic plaintexts. | Paper 1 geometry; Paper 2 lifecycle |
| H35 | Ephemeral representatives and anonymity | `Axioms.EphemeralFiberSpec`, `Protocol/Ephemeral`; [active plan](docs/PROTOCOL_PARITY_QUEUE.md#priority-1--ephemeral-representative-and-anonymity-flow) | **One supplied path/endpoint accounted for.** Class preservation is proved under path-respect. Indexed generation/transported state, one-fiber infinite-family bridge, lifecycle and finite/asymptotic privacy experiment are planned. Representative privacy, plaintext hiding and sender unlinkability are distinct claims. | Paper 1 family; Paper 2 experiment |

## Definition, notation, and claim issue table

P0 affects the meaning of a main claim or interface; P1 affects completeness
or precision of its presentation; P2 is editorial. **Open** rows need explicit
mathematical or author decisions, rather than silent copyediting.

| ID / priority | Location / related objects | Finding | Disposition and required action |
|---|---|---|---|
| D01 / P0 | HCP §§2,5; H02, H10, H23 | A decoded exact payload has `P_H δ₀a=0`, whereas HCP permits nonzero `h`. A proof about a vector also need not expose it. | **Partial construction; public realization open.** `HodgeEncryptedCochain` and `TCB.BoundHCPObservation` already join the exact component to the distinct full sample and prove harmonic recovery. Instantiate their supplied interpretation/classifier/`Binds` relation, specify public encoding/extraction, and identify the operative semantic witness before claiming a concrete public-data HCP realization. |
| D02 / P0 | HCP §§5--6; H17 | A full Plücker point reveals `W`. If this is the operative kernel, public disclosure conflicts with withholding it. A digest alone is a different observation. | **Open visibility choice; distinction added.** Identify which coordinate is public, verifier-private, or witness-only, and whether its subspace is the operative kernel. |
| D03 / P0 | HCP §6.1 and canonical bridge; H18, H20 | Closed near/far inequalities with equal radii overlap at the threshold. The current Lean `GapProximityProblem` also permits equality. A correct accept/reject solver cannot exist if an instance lies on both sides. | **Boundary criterion and strict view proved; profile convention open.** [GapBoundary](lean/Proximity/Application/GapBoundary.lean) characterizes overlap by equal radii plus threshold attainment and proves solver inconsistency there. `SeparatedGapProblem` retains the original score/radii and derives disjointness from numeric strictness. Legacy APIs remain unchanged. Concrete profiles still need strict gaps, an empty-shell proof, or an explicit half-open convention, with synchronized prose. The classical specification result supplies no efficient solver. |
| D04 / P1 | HCP §6.4--6.5; H20 | Stage-certificate existence uses naturality squares and local nondegeneracy. The earlier prose displayed only alignment, codeword preservation, and distance control. | **Corrected presentation.** The stage definitions now explicitly include those supplied fields and display both restriction/syndrome squares. This adds no new proof of an application instance. |
| D05 / P0 | HCP §4 likelihoods; H15 | An observation-dependent guess `span{b}` achieves likelihood `1`; averaging its likelihood is not the probability of recovering the operative kernel. A probability density is not itself a quantum computation model. | **Wording corrected; formal endpoint open.** Use likelihood-score terminology. Identify the corrected Euclidean integral and define a recovery experiment before claiming a quantitative classical/quantum security bound. |
| D06 / P1 | HCP §5 modular commitment; H10, H12, H23 | `δ₀a mod q` needs an integral/finite-field carrier and compatible encoding; an arbitrary real-linear restriction map does not define modular reduction. `dec_S` is currently supplied. | **Systematic modular profile constructed; full HCP realization open.** P220--P228 supply integer openings, reduction/codec and RS compatibility for their selected source. `Sheaf.IntegralStructure` separately specifies restriction-preserving stalk lattices and proves integral δ₀/δ₁ preservation; a concrete bundled instance for the intended HCP family is still missing. Cipher noise/openings remain arbitrary real cochains, so its full sample is not asserted integral. Record that family's reduction/decoder laws rather than identifying the whole real space with a nontrivial modular quotient. |
| D07 / P0 | HCP §5 MAC; H12 | If `c(m,ν)` is the same exact cochain used for raw commitments, its harmonic tag is zero. A verification equation alone is not an unforgeability theorem. | **Open instantiation; assumption wording corrected.** Give the MAC's cochain map and adversarial game in the protocol paper; keep unforgeability explicit in the main paper's assumption boundary. |
| D08 / P1 | HCP §3 complexity schema; H09 | Fixed dimensions, arbitrary real inputs, and an algorithm class do not yet specify an asymptotic bit-model hardness assumption. | **Open complexity refinement.** Supply encoded instance families, size/security parameter, success criterion, and oracle representation before a computational CVP-hardness claim. The current separation is an ambiguity obstruction. |
| D09 / P1 | HCP §4 Heyting collapse; H16 | “Not assumed faithful” is followed by an existential collision, which actually assumes noninjectivity. The domain `Ω` is not described locally. | **Corrected.** Define `Ω` as the hidden truth-value carrier and explicitly assume the displayed nonfaithfulness. |
| D10 / P2 | HCP §§1--5; H03--H04, H14 | Projection notation alternated `π_H`/`P_H`; restriction chains omitted edge-to-face data; `W_t` differed from the declared `W(t)`; matrix example left `e_i` unbound. | **Corrected.** Use `P_H`, include face-to-coface maps, retain `W(t)`, and use `e₁` with the displayed diagonal. Normalize Plücker spelling and heading capitalization. |
| D11 / P1 | HCP §6 MCA theorem/corollary; H22 | The cited-bound hypothesis was implicit, and the corollary assigned a pair/line bad-challenge fraction to a single word. | **Corrected.** Both statements explicitly assume the cited package; the corollary names the line formed with a second projected witness. No numerical security claim is added. |
| D12 / P1 | HCP appendices; H09 | Arbitrary-field linear kernels were called Hodge kernels; the matrix sanity example was mapped directly to the stronger typed HCP separation. | **Corrected.** Use “linear kernel” and identify the matrix example as a sanity example, retaining the typed theorem's additional hypotheses. |
| D13 / P1 | HCP bibliography | One reference printed an internal “replace metadata” note; the survey citation used an old date and lacked its URL. | **Corrected.** Use the author-posted preprint's DOI/date and the ePrint survey's July revision metadata. Exact cited theorem specialization remains a separate review task. |
| D14 / P1 | HCP §4 spectral fingerprint; H13 | “A sheaf Laplacian is a self-adjoint PSD operator” can be read as asserting that every PSD operator comes from a cellular sheaf. | **Corrected.** Define the fingerprint for a finite-dimensional self-adjoint PSD operator, including a sheaf Laplacian; no cellular realization is inferred. |
| D15 / P1 | HCP §4 projection spectral gap; H14 | The zero operator at `W=Rⁿ` has no nonzero eigenvalue, while the original final sentence described the whole family as having relative gap `1`. | **Corrected.** State the family conclusion for proper kernels `k<n`, as required by the preceding eigenvalue computation. |
| D16 / P1 | HCP §5 vector openings | A vertex-restricted opening gives both endpoint values only for an edge whose two endpoints are in the revealed set. “Every revealed incidence” did not fix this domain. | **Corrected.** Quantify the displayed edge equation over edges with both endpoints revealed. Boundary-edge verification needs additional authenticated data. |
| D17 / P2 | HCP PDF, long displayed lists and Lean ledgers | Several displayed prose lists exceeded the text width, and long Lean paths overflowed or stretched their lines. | **Corrected layout.** Convert prose lists to wrapping text, split equations, enable path breaks with `xurl`, and use consistent ragged-right Lean ledgers. |
| D18 / P1 | HCP cross-references throughout | Shared theorem counters made `cleveref` call definitions and propositions “Theorem,” including references to the public-observation definition. | **Corrected.** Use alias counters to preserve shared numbering while retaining each environment's actual reference type. |
| D19 / P0 | HCP full observation; H23--H26 | The exact-component storage view and full-HCP residual can forget different information. | **Mathematical obstruction proved.** The unrestricted coexact-ray theorem rules out factoring the full residual through the decoded exact component when a nonzero coexact direction is allowed. Identify the intended source/profile before a stronger original-HCP radius claim; raw serializer factorization remains explicit. |
| D20 / P0 | Storage and proximity source carrier | Requiring exact acceptance in every raw input would remove positive decoded-exactness farness. | **Interface separated.** `Storage.Context` requires shape/snapshot binding; `Accepted` is separate. The concrete fixture has a positive-distance nonexact raw input, without asserting a source-to-RS guarantee for that fixture. |
| D21 / P1 | Storage roots, stages and local lifecycle | Same-shaped hash names and slot presence do not identify prior mathematical artifacts or prove durability. | **Typed joins implemented.** Actual context/payload/digest-indexed relations, exact predecessor prefixes and exact sealed-manifest receipts are separate. Six manifest stages differ from seven legacy gate-evidence slots. Global run freshness, backend atomicity, root codecs and memory erasure remain profile/runtime work. |
| D22 / P1 | History entry to original snapshot/artifact and complete projection | Independent candidate validity and manifest sealing did not bind those actual objects together. | **Bounded semantic join implemented**, P215--P216. Actual interpretation/artifact equalities derive accepted context and snapshot/payload joins; supplied history/gate relations bind the exact manifest and gate database. The wire-field choice, concrete authentication, persistence implementation and dynamic geometry remain open. |
| D23 / P1 | H17, H27--H28; projective/stack terminology | The raw quotient contains zero and arbitrary exterior coordinates, while a projective Grassmannian point has additional validity conditions. A moduli analogy does not construct descent or metric transport. | **Definition boundary recorded.** Use the actual raw/frame/soundness predicates; distinguish classical reconstruction from its current Lean proof status. Keep stack packaging prospective and the public-point visibility decision explicit. |
| D24 / P1 | Lean/Mathlib version and validation | Older successful builds used Lean 4.24.0 and cannot certify the new 4.35.0 sources. | **Closed for the current pin:** pins, manifest, CI selection and source interfaces are updated; fresh expanded aggregate/default builds and the 139-declaration audit pass. The audit separates 103 standard-only endpoints from 36 with existing native arithmetic trust. Hosted CI and Palomar protected comparison are separate runs. |
| D25 / P1 | Helfer/class construction; H31 | The typed equivalence includes bifibrancy, while public classes are classifier fibers. Neither defines a quotient on all interpretations; `ClosedSemantics` supplies arbitrary satisfaction. | **Explicit construction boundary.** Select the bifibrant carrier/replacements, prove relation laws if using an actual quotient, and instantiate a precisely named semantic fragment or full interpretation. Full Helfer invariance remains external/explicit. |
| D26 / P0 | Intended HCP realization; H23, H33 | `Realization.laplacian` is not automatically an actual cellular Hodge matrix; `BoundHCPObservation.toObservation` forgets the larger artifact/snapshot view. | **Open same-object join.** Supply the true-operator matrix identification, semantic classifier agreement, hidden witness and operative-target equality; define the released view and compare every public field. Gate certificates alone establish no such family. |
| D27 / P0 | Structured noise, rotation and messages; H32, H34 | A fixed-raw-`b` decomposition may change its exact component and thus its committed payload. Rotation instead co-transports the observation; different harmonic coordinates can encode one plaintext. | **Object obligations recorded.** Fix actual message/lattice/noise and plaintext encoding; prove the intended public-view equality or authorized migration. A face-free axis-swap example has exact components `0`/`b` and fails identical-payload comparison under one fixed decoder. A coexact candidate still needs all envelope/gate joins. |
| D28 / P1 | Anonymity and ephemeral family; H35 | A same-class endpoint, infinite geometric candidate space or stable class tag does not specify a sampling/observation experiment. | **Recovered intent, not security completion.** Use the existing representative/path object; construct indexed generation and transport, one-fiber membership and lifecycle. State separately representative indistinguishability, plaintext hiding, account/sender anonymity, unlinkability and forward secrecy. Stable public account tags can link uses. |

## HCP theorem parity and remaining work

These are source-level correspondences, not a claim that the entire current
Lean tree was rebuilt during proofreading. Proximity theorem statuses remain
in T01--T20 of the linked detailed register.

| ID | Main-paper claim | Lean correspondence / actual hypothesis | Status / next action |
|---|---|---|---|
| HT01 | Hodge encryption correctness and unique operative target | `HCP.decrypt_encrypt`, `decrypt_coe_eq_harmonicProjection`, `HCPBridge.operativeTarget` | **exact** algebraic correctness. Separate key/noise distributions and security games. |
| HT02 | Helfer equivalence implies public equality | `HCPBridge.samePublicClass_of_homotopyEquivalent` | **parameterized** by closed-formula invariance and classifier factorization; the general Helfer theorem remains external. |
| HT03 | Public ambiguity defeats uniformly exact HCP recovery, including a fixed CVP oracle | `HCPBridge.no_solver_exactOnOperativeTarget_of_kernelSeparation`, `cvpOracle_insufficient_for_operativeTarget` | **exact conditional** impossibility. A concrete typed separation witness is still supplied; no average-case hardness theorem follows. |
| HT04 | Linear kernel realization and discrete projection bridge | `exists_matrix_ker_eq_range`; `HarmonicCVPBridge.isClosestLatticeVector_iff_projectedTarget` | **exact** distinct comparisons. Neither statement solves the remaining discrete lattice search. |
| HT05 | Accepted exact commitments are cocycles | `Sheaf.CellularSheaf.decoded_isOneCocycle`; `Axioms.oneCocycle_of_committedCochainWellFormed` | **exact** under supplied interpretation/coherence. Resolve D01 and D06 for a concrete HCP observation. |
| HT06 | Stage maps compose and final certificate yields calibrated gap projection | `ProjectionChain.Chain.toEvaluationProjection`; `Gates.CalibratedFinalCertificate.toCalibratedEndToEndReady` | **exact conditional** composition; concrete encoder, distance control, and far-separation inputs remain **parameterized**. Resolve D03's boundary convention. |
| HT07 | Canonical RS MCA fraction after projection | `CanonicalRS.CitedBounds.bounds`; `CanonicalRS.MCA.projectionBadChallengeFraction_le` | **parameterized** by the named literature axioms. Do not borrow the companion's `2^-128` field-size conclusion for `q=12289`. |
| HT08 | Spectral/density likelihood scores | `gaussianLikelihood_correct`, projection likelihood lemma; legacy normalized functions | Local formulas are represented. Corrected integrated recovery/security endpoint is **not identified**; D05 remains open. |
| HT09 | Intended gated Hodge-noise ambiguity and representative family | HC01--HC44 in the [object crosswalk](docs/COCHAIN_PROXIMITY_TRACE.md#hcp-object-accounting-rotation-and-anonymity); existing `Realization`, `BoundHCPObservation`, gates and `EphemeralFiberSpec` | **Not instantiated.** Construct the same actual semantic/cellular/integral objects, structured-noise samples and selected public view, with gate proofs. Rotation covariance and fixed-observation separation are distinct endpoints; the crosswalk adds no theorem. |

## What remains, by paper

The original open HCP items remain, with D01/D06 narrowed by the typed and
modular constructions. D25--D28 additionally make the intended semantic-family,
noise, full-observation and anonymity joins explicit. None blocks the universal
counting theorems of Paper 3.

| Issue | Existing progress | Completion decision / endpoint | Owner |
|---|---|---|---|
| D01 | Integral harmonic cipher, exact-component/full-sample record, and harmonic recovery | Present the existing join; instantiate the public binding/encoding path and its semantic witness if claiming a concrete HCP scheme. | Paper 1 interface; Paper 2 realization |
| D02 | Coordinate versus digest/proof distinction is explicit | Fix the public view and state whether its subspace is the operative kernel. | Papers 1--2 |
| D03 | Conditional solver pullback, exact overlap criterion and strict-gap view are proved; §6.1 states the boundary condition. | Instantiate disjoint promises for the selected profile through strict gaps or an empty-shell proof; an alternative half-open convention would require an explicit synchronized change. | Paper 1/application interface |
| D05 | Correct Euclidean likelihood and local identities | Define a recovery experiment and its success event, or retain only likelihood-score claims. | Paper 1 quantitative layer; Paper 2 security model |
| D06 | Integral stalk lattices and coboundary preservation | A systematic modular cellular profile and original codec are constructed in P220/P222. Arbitrary HCP integral presentations and production byte semantics still need their own compatibility laws. | Paper 1 algebra; Paper 2 wire format |
| D07 | Blinding geometry and a proposition-only MAC interface | Construct key/tag/verify and a security game if the MAC is a central claim; otherwise defer it explicitly. | Paper 2 |
| D08 | Algebraic ambiguity/oracle obstruction | Supply encoded families, distributions, input/security size, algorithm model and success criterion for a computational-hardness claim. | Paper 1 refinement; Paper 2 concrete scheme |
| D25 | Typed Helfer interpretation/equivalence and conditional theory factorization | Instantiate the selected semantic model and admissible carrier; package a quotient only after its relation laws. | Paper 1 |
| D26 | Cellular/Hodge core, bound observation, gates and storage adapters | Join their same actual operator, classifier, target and selected full public view into an intended `Realization`. | Papers 1--2 |
| D27 | Hodge noise, integral-message type and isometric covariance | Construct allowed samples and cross-presentation plaintext/lattice laws; distinguish fixed-view ambiguity from rotation migration. | Papers 1--2 |
| D28 | One supplied ephemeral endpoint/path and recovered family plan | Construct indexed generation/transport/lifecycle and the specified finite/asymptotic privacy experiment. | Paper 1 family; Paper 2 security |

Paper 2's bounded first endpoint and its required joins are in
[SCOPE.md](papers/paper2/SCOPE.md). Its full transition implementation need not
precede Paper 3. First fix the smaller shared commitment/extraction/metric
profile needed by the selected commitment-specific radius claim. A conditional protocol paper may
state cryptographic primitives as explicit assumptions. A claimed new
commitment or MAC scheme additionally needs the actual algorithms and
security argument.

### Paper 3 completion assessment

The [detailed coding register](papers/proximity-prize/SEMANTIC_PARITY.md)
retains the canonical O/T/Q IDs. All nine named generic coding statements now
have Lean endpoints, including the four construction/packaging tasks Q04--Q07.
That is a statement-level coverage count, not a percentage of research
completion or an instantiation of the commitment-specific application.

| Work | Current evidence | Needed for the fully formalized paper | Dependency on Paper 2 |
|---|---|---|---|
| Q04: all-parameter smooth family | **Complete:** actual Galois fields, all-parameter divisibility, exact-order subgroup domains and realized list/MCA endpoints in `Capacity.Realization`. | Preserve the explicit large-alphabet regime; it is not the canonical wire field. | None |
| Q05: complete list phase split | **Complete:** all three fractional regimes, greatest safe count, exact real interval, supremum and nonattainment in `ListDecoding.PhaseSplit` and `Capacity.ListPhase`. | No generic coding packaging remains; the supplied-code intermediate optimum is outside this result. | None |
| Q06: real boundary transition | **Complete:** `[0,1/4096)`, supremum and nonattainment in `MCA.RealThreshold`, using shared count/real shell semantics. | Retain the closed-ball endpoint convention and recorded arithmetic trust dependencies. | None |
| Q07: standalone distance packaging | **Complete:** attained minima, closeness interpretation, covering and good-challenge consequences in `Core.Distance` and `Application.DistanceCalibration`. The optional storage adapter also proves equality with the existing canonical real-infimum pair distance. | A generic distance API does not instantiate the independent source codec/comparison. | None |
| Q09: publication artifact | Papers 1 and 3 are synchronized with the new mathematics; Paper 2 has initial manuscript text. Current Lean full/default builds and the consolidated 139-endpoint audit pass. | Final 97/28-page PDF and local package hash/link checks pass. Preserve dated baseline evidence and regenerate the package from the final checkpoint. Publication, immutable release and Palomar protected comparison remain separate. | None |
| Novelty / related work | The primary-source comparison records the established same-set MCA event, sharper positive-gap regimes, elementary endpoint/deep-hole context and the random-linear average-radius benchmark; actual commitment and storage maps are traced. | A selected concrete source relation and quantitative theorem are still needed to assess commitment-specific novelty. Random-code guarantees do not instantiate the fixed smooth RS family. A map or formalization alone establishes neither priority nor a new cryptographic scheme. | Needs the bounded shared profile for the commitment-specific comparison. |
| Q08: selected actual commitment projection | **Complete for the explicit native modular profile:** actual integral cellular coboundary validity, same original payload/full layout, global three-metric calibration, a payload with all three distances `3/4`, original-artifact joins and canonical diagonal fixed-mix goodness. Expanded validation passes. | This is a raw received-context proximity profile, not a nonempty accepted-far gate. No identification with an arbitrary old HCP/frame geometry, unrestricted Euclidean capacity radius, universal fixed-mix preservation or cryptographic security is asserted. Those need their own profile/statement; two relevant global comparisons are refuted. | Paper 2 owns source/observation contracts; Paper 3 owns quantitative analysis. Full ledger/consensus/Rust is not required. |

The arbitrary supplied-code intermediate optimum, further exact MCA
transitions and broader challenge families (Q10--Q12) are new research beyond
this bounded paper. They are not missing wrappers. The standalone generic
mathematics is formalized; the intended commitment-specific claim additionally
requires Q08's actual source/codec profile and its quantitative theorem.

For the selected commitment-specific contribution, Q08 is additional required
work. On the accepted exact-frame carrier alone the chain maps every element
to an RS codeword, so positive farness needs a larger raw/noisy source. A fixed
scalar mix also has a nontrivial kernel even for canonical representatives.
Neither problem is resolved by running Rust. Rust is useful for wire-format
parity, experiments, counterexamples, and any reported costs; a mathematical
radius requires the comparison and challenge bound, or certified exhaustive
analysis of the declared finite profile.

## Axiom Stacks reuse candidates

The user suggested the new [AxiomMath/Stacks release](https://github.com/AxiomMath/Stacks).
The following source files were inspected at commit
`f8e70c5dd04bfabcb423d5e325461f527c85a5d6` on 2026-11-04. The project's
[tier description](https://github.com/AxiomMath/Stacks#structure) distinguishes
reviewed `StacksCore` from `StacksFrontier`; these candidates are in Core.
This is a targeted reuse review, not a coverage audit of the full release.

| ID | Source / Stacks tag | Inspected declaration / result | Potential use and exact remaining comparison | Disposition |
|---|---|---|---|---|
| A01 | [FiberedInGroupoidsEquiv.lean](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksCore/CategoryTheory/FiberedInGroupoidsEquiv.lean); [003V](https://stacks.math.columbia.edu/tag/003V) | `CategoryTheory.Functor.IsFiberedInGroupoids.iff_isFibered_and_fiber_isGroupoid`, `isFibered`, `fiber_isGroupoid`, `isStronglyCartesian` | Candidate canonical vocabulary for HCP §4's categorical fibration layer. The inspected code proves the equivalence and Cartesian-morphism consequences. HCP must supply the functor and groupoid-fiber hypotheses; this is not Helfer's model-categorical formula-invariance theorem. The tag's additional pseudofunctor clause was not established by this inspected file. | **Candidate adapter**, not adopted. Keep the HCP semantic assumptions explicit. |
| A02 | [SheafificationAdjoint.lean](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksCore/CategoryTheory/Sites/Sheafification/SheafificationAdjoint.lean); [00WH](https://stacks.math.columbia.edu/tag/00WH) | Registers existing Mathlib `CategoryTheory.sheafifyLift`, `toSheafify_sheafifyLift`, `sheafifyLift_unique` | Concrete universal-property vocabulary for a future realization of the oracle/sheafification interface. These declarations already exist in this repo's pinned Mathlib. Supply the site, value category, sheafification instance, and identification of the actual oracle construction; a three-valued public map alone is not that construction. | **Reuse existing Mathlib first**; application identification remains open. |
| A03 | [HomologicalComplex.lean](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksCore/Algebra/Homology/HomologicalComplex.lean); [010E](https://stacks.math.columbia.edu/tag/010E) | Registers Mathlib `HomologicalComplex` | Canonical carrier for a future bundling of the concrete `C⁰→C¹→C²` complex. Match the shape, objects, and differentials, extending the truncation explicitly if needed. The registration does not provide an inner product, adjoints, Hodge decomposition, or hidden-operator separation. | **Existing Mathlib object**; an adapter is optional until consumed. |
| A04 | [Presheaf.lean](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/StacksCore/CategoryTheory/Presheaf.lean); tags 00V2--00V3, 00V6--00V7 | Presheaves as functors; pointwise injectivity/surjectivity at the trivial topology, and their mono/epi/isomorphism comparisons for type-valued presheaves | Helps distinguish an actual functor/natural transformation from a named interface. HCP's face-to-coface cellular convention must be matched with the appropriate opposite poset/site before invoking presheaf results. This does not identify hidden paths with cellular restrictions. | **Candidate categorical packaging** for H01/H03 and the ownership register; no identity claimed. |

Compatibility is a separate obligation. The release pins
[Lean 4.34.0-rc2](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/lean-toolchain)
and [Mathlib `16edf57…`](https://github.com/AxiomMath/Stacks/blob/f8e70c5dd04bfabcb423d5e325461f527c85a5d6/lakefile.toml).
The main repo now pins Lean 4.35.0 and Mathlib `56a0058…`; it does not add
Stacks as a dependency. A02--A03's existing Mathlib declarations can be used
without importing the entire Stacks library. A01 still needs an adapter and
validation against the current pin before use here.

The inspected results do not fill the HCP-sample/commitment comparison,
Plücker visibility choice, promise-boundary convention, concrete source-to-RS
far separation, or cryptographic security games. Record any future adapter
against its specific row rather than marking those obligations proved merely
because a related Stacks tag is formalized.

## Proofreading validation

The main manuscript was read through its abstract, all seven body sections,
both appendices, and bibliography. The companion abstract, introduction,
application interface, proof ledger, and detailed parity register were read
to check the split. Copyedits preserve the distinction between proved
identities, supplied witnesses, and cited theorem inputs.

Validation on 2026-11-04:

- `latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex` with a
  temporary output directory completed successfully: 92 pages, no undefined
  references/citations, duplicate labels, missing glyphs, or overfull boxes.
- All 92 pages were rendered and visually checked in contact sheets; the
  revised commitment, naturality, and MCA displays were also inspected at
  page resolution. Cross-reference metadata and extracted text confirm that
  definitions, propositions, and corollaries retain their actual types.
- Local Markdown links in the shared register and its entry points resolve;
  issue IDs are unique. `git diff --check` passes.
- A temporary `lake env lean` probe passed against the existing pinned
  Mathlib for the three A02 declarations, `sheafificationAdjunction`,
  `Functor.IsFibered`, and `HomologicalComplex`. The two checked
  sheafification theorems report only `propext`, `Classical.choice`, and
  `Quot.sound` in their axiom lists. This was not a build of Stacks or a
  full-project Lean audit.

The table contains 18 definition/notation/claim issues: 11 corrected and
7 open. Open rows above are deliberately retained; publication ownership is
not a proof of a missing construction.

### Paper 3 and actual-object follow-up: 2026-11-04

All eight Paper 3 sections, abstract and bibliography were proofread.
The revision corrects distance/quantifier conventions, reference types,
related-work scope and formalization status; §7 now traces the existing
commitment rather than introducing a substitute. The detailed register adds
O41–O45 and C01–C06 for the actual map and existing concrete calibration,
while preserving O01–O40/T01–T20 and the standalone 18-module boundary.

The fresh standalone build passed (3,108 jobs), and its 12-theorem axiom probe
confirmed standard Lean axioms plus the explicitly recorded native-evaluation
dependencies for the boundary arithmetic. A separate build of concrete
`PublicCalibration`, `BridgeWitness` and `MCA.Spectrum` passed (7,411 jobs).
No fresh concrete axiom-audit result is claimed; the optional scratch probe
was interrupted. These builds do not prove the remaining profile inputs.

The Paper 3 TeX build passed with 23 pages and no undefined references or
citations, duplicate labels, missing glyphs, or overfull boxes. All final
pages were rendered and visually checked; the commitment extraction and
proof ledger were also inspected at page resolution. Two underfull-box
diagnostics have no visible clipping or overlap. The reviewed PDF is exported
to `output/pdf/capacity-radius-proximity-proofread.pdf` and the manuscript's
canonical `main.pdf`. Current link/ID/whitespace checks pass.

For the user's selected actual-projection analysis, resume the
[recovered quotient-aware bridge plan](docs/COCHAIN_PROXIMITY_TRACE.md#recovered-bridge-equivalence-plan)
and identify its intended source/observable score. The plane/pair equivalence
and public pullback calibration are proved. A distinct original-distance
claim additionally needs its quantitative comparison; a full raw-geometric
isometry is not an automatic prerequisite. Rust execution and the full
Paper 2 transition/consensus program are not prerequisites for that analysis.

### Paper 2 transition core

The authorized implementation adds a bounded conservative transition under
the existing `Protocol` layer. Validation is recorded separately from source
completion in the current record below.

| ID | Canonical object / claim | Implemented owner and boundary |
|---|---|---|
| P201 | Finite resource marking, additive asset value and conservative flow | `Protocol/Ledger/ValueFlow.lean` reuses Mathlib `Finsupp` and `AddMonoidHom`. Availability plus equal consumed/produced value proves conservation of the actual updated inventory. Resource ownership and valuation interpretation remain application data. |
| P202 | Typed action, source state and computed successor | `Ledger/{State,Transition}.lean`; the action carries its actual nullifier list and the same `CochainCommitmentData`. `Candidate.Valid` checks authorization, availability, conservation, nonempty/Nodup/Fresh consumption, payload/snapshot acceptance and proposal context. |
| P203 | Replay and connected-history preservation | `Ledger/{Nullifier,Transition}.lean`; accepted updates are deterministic, conserve declared asset value and preserve spent identifiers. A consumed nonempty action cannot be replayed with another proposal. Nullifier derivation/security against alternate encodings remains an application obligation. |
| P204 | Existing cellular-sheaf snapshot | `Ledger/Sheaf.lean` instantiates `SnapshotModel` with the original `CochainPayloadInterpretation F`, `SheafStateSnapshot F` and accepted exact-cochain predicate. The topology tag and topology root retain distinct roles and sizes. |
| P205 | TCB evidence bound to this transition | `Evidence/Transition.lean` reuses `WitnessVerifierEnvelope`; it derives validity from the observed statement and joins the exact payload, before/computed-after roots, transition digest and public hashed cochain inclusion through object-indexed relations. Full serialized proof/verifier inclusion, acyclic canonical root preimages and hash/proof verification remain concrete profile obligations. |
| P206 | Quorum attachment to the same candidate | `Ledger/Certified.lean` reuses `QuorumCertificate` and complete proposal equality; `ProposalRef` now includes a separate `snapshotRoot`. Hold/rejection cannot supply acceptance. Round/lock/finality proofs remain open. |
| P207 | Positive and adversarial fixtures | `Ledger/{Examples,EvidenceExamples}.lean`: positive-valued transfer, full toy evidence/quorum path, overspend/imbalance/replay/duplicate/empty-use/context rejections, and a still-valid changed-digest candidate rejected by the old envelope and quorum. These are specification fixtures, not production cryptographic schemes. |
| P208 | One raw sheaf-storage context | `Storage/Context.lean` retains the original interpretation, snapshot and public cochain artifact. Its key derives run/schema/snapshot/leaf/topology/parameter names; raw shape/context binding is distinct from exact acceptance. |
| P209 | Actual mathematical semantics | `Sheaf/CochainSemantics.lean` transports exactness, cocycles and acceptance through actual operator/decoder/binding equations. `Storage/Projection.Input` joins that interpretation to the existing chain's same payload. |
| P210 | Append-once manifest and local lifecycle | `Storage/Checkpoint.lean` retains actual dependent payload/digest entries, unique ordered slots, complete sealing and a persistence receipt for the exact context/list/root before local consumption. This is not global freshness, anti-cloning, disk durability or erasure. |
| P211 | Existing stage/gate levels retained | `Storage/Projection.lean` stores `PluckerCochainState`, `CochainPlaneState`, `StateBus`, hard/naturality/final evidence. Each step checks its exact predecessor and appends one leaf; final sealing requires the exact list of one final prefix and recovers the original `CertifiedStateBus`. |
| P212 | Independent source comparison and actual canonical observation | `Storage/Calibration.lean` derives decoded-source ≤ scaled pair distance from exact comparison cochains and local decoding-error bounds. `Storage/CanonicalRS.lean` joins the entire observed artifact and identifies real-infimum/generic pair minima. These proved interfaces do not instantiate the selected codec/control data. |
| P213 | Original HCP stack retained | `Storage/HCP.lean` reuses the exact artifact/snapshot of `BoundHCPObservation` and names its actual lifecycle context through a supplied function. The full encrypted observation remains distinct; H26 records the conditional unrestricted-source obstruction. |
| P214 | Raw-source and storage regression fixture | `Storage/Examples.lean` uses actual integer-list decoding in a concrete two-coordinate sheaf: nonexact `[1,0]` has positive decoded distance, zero is accepted, and payload/plane writes exercise the local lifecycle and context/receipt rejection cases. Its equality contracts are toy models and it supplies no source-to-RS radius guarantee. |
| P215 | History entry bound to the original storage objects | `Storage/Anchor.lean` joins existing candidate evidence to the same interpretation, whole public artifact and exact sealed manifest. Acceptance, payload/snapshot equality and root inclusions are derived; actual ordered manifest inclusion under the candidate's block digest remains an explicit authentication-profile premise. Matching-quorum and exact-receipt endpoints retain those objects. |
| P216 | Coherent projection and gate database in that history entry | `Storage/ProjectionAnchor.lean` uses the actual `SealedProjection.itemsMatch`, joins its RS word to the candidate payload, and separately includes its actual gate database under the proposal evidence root. `AnchorExamples.lean` exercises a positive transfer/quorum/receipt and rejects a different run, a substituted snapshot with the same artifact/manifest root, and persisted nonexact input. |
| P217 | Current toolchain and explicit coordinate interfaces | The main pin is Lean/Mathlib 4.35.0. Public module interfaces, matching transitive revisions and CI selection are updated. Explicit Euclidean/raw-coordinate conversions preserve the operators, targets and existing CVP distance; no new source metric or authentication profile is selected. Current-pin aggregate/example build passes (9,233 jobs). Fresh probes cover 68 distinct declarations: 64 standard-only and the same four native-dependent endpoints. The previous 4.24 results are preserved separately. |
| P218 | Full Plucker reconstruction | `GrassmannianPlucker/Reconstruction` constructs subspace/projector recovery, full-shadow iff ranked-point equality and both former soundness inputs. Focused build and eight exact-standard-three audits pass. `TCB/PluckerObservation` connects this to the operative HCP target under kernel identification; its focused build passes. |
| P219 | Canonical-lift obstruction | `Core/CanonicalLift` and `Sheaf/CanonicalLiftObstruction` prove affine/pair RS lift spanning and rule out a global zero-additive-loss Euclidean comparison for a nontrivial linear decoder. Focused builds and thirteen standard-only audits pass. Restricted profiles, additive defects and separate threshold results are not excluded. |
| P220 | Actual systematic cellular and modular source | `Core/Systematic`, `Sheaf/SystematicCode` and `Sheaf/SystematicCode/Modular` construct the interpolation/cellular maps and actual integral-coboundary congruence, with proved RS compatibility. Focused builds, six systematic and eight modular standard-only audits pass. Arbitrary old sheaves are not automatically identified with this model. |
| P221 | Coordinate codec and geometric criterion | `Storage/DistanceReflection`, `CoordinateCodec` and `NoWrapCalibration` prove full coordinate coverage, a decoded-norm bound and integer-syndrome validity reflection, retaining Euclidean exactness distance. Focused builds pass. The finite-shell bound certifies at most `1/n` for a nonempty source far region, not capacity-scale geometric farness. |
| P222 | Canonical no-wrap benchmark | `Storage/CanonicalSystematic` uses actual `q=12289,n=4096,k=1024`, constructs the original payload/list layout and positive unit-error source family, and joins the comparison to the original public artifact. Focused build and fifteen native-dependent audits pass; only existing generated native certificates occur. Positive decoded-far raw inputs are not accepted exact ledger anchors. |
| P223 | Native metric comparisons | `Core/InterleavedMetric` and `Storage/ThreeLevelMetrics` prove global `d_C ≤ d_P = D_RS ≤ 2d_C`, with separate scalar and whole-pair matching-representative transports on actual modular validity. Current full build and selected audits pass. These are native modular edit metrics, not real decoded exactness or a frame score. |
| P224 | Explicit challenge profiles | `MCA/ZeroDirection` proves all challenges good and pair/scalar distance equality. `MCA/Diagonal` proves noncancelling challenges good and bad set exactly `{-1}` for a non-codeword diagonal base at nonnegative radius. Focused builds and eleven standard-only audits each pass. These are explicit profiles, not uniform fixed-mix guarantees. |
| P225 | Paper 2 initial manuscript | [DRAFT.md](papers/paper2/DRAFT.md) records objects, real/modular validity, three native metric contracts, scale directions, full-point visibility and evidence ownership. It is initial text without a TeX/PDF bundle or completed security claim. |
| P226 | Capacity-scale original payload | `Core/DeepHole` proves actual monomial scalar/pair/flattened distances `(n-k)/n`. `Storage/CanonicalThreeLevel` serializes the original canonical payload, proves all three native distances `3/4`, joins its original public artifact and proves the canonical mix good for this diagonal family. Its only bad challenge is `-1`, with exact fraction `1/12289`. Full build and selected native-certificate audits pass. |
| P227 | Fixed compression obstruction | `Core/FixedChallenge` constructs a pair `(u,-γ₀⁻¹u)` at capacity distance in both native coordinate metrics whose challenge at any specified nonzero `γ₀` is zero. A uniform positive far transfer through arbitrary fixed compression is refuted; sampled-after-binding or proved restricted-profile goodness is required. Generic selected audits are standard-only. |
| P228 | Composable metric handoffs and sharp scale | `Storage/CanonicalCalibration` constructs the existing source-to-source, source-to-code and composed calibration objects on original raw contexts, and the existing `EvaluationProjection` with near score `2d_C`. `Core/MetricSharpness` proves actual `(X^k,0)` has pair distance capacity and scalar-coordinate distance half capacity, so the factor cannot be dropped. No full legacy frame `Γ`, security game or finality claim is constructed. |
| P229 | Expanded mathematics validation | All 234 source modules/235 Lean files have public headers, no active holes, no local cycles and the same seven explicit cited-bound axioms. Full/default builds pass 9,253/9,248 jobs. The fresh 139-report public-facade probe matches individual probes: 103 standard-only (100 exactly the standard three, three subsets), 36 with existing generated native arithmetic certificates; no selected cited-bound or `sorryAx` dependency. Focused closures are Prize 33, Protocol.Core 33, Storage.Core 79, CanonicalRS 58, CanonicalSystematic 70, CanonicalThreeLevel 78 and CanonicalCalibration 76; all exclude `Chain` and `CitedBounds`. |
| P230 | HCP, rotation and anonymity object accounting | Development crosswalk HC01--HC44 records actual definitions, source owners, retained/public roles, gate inputs and missing joins. It recovers the ephemeral/path anonymity plan and separates rotation/plaintext covariance from fixed-observation ambiguity. Paper 2 records the distinctions in its initial draft. No Lean statements/proofs or Paper 1/3 TeX/PDFs change in this documentation-only audit; current build/audit evidence remains P229. |

#### Current protocol validation

Earlier bounded-transition milestone, 2026-11-05, before the subsequent
mathematics/storage extension. With the pinned Lean/Mathlib dependencies:

- `lake build Protocol.Core Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples`
  passed (7,385 jobs), including the existing-sheaf adapter and the updated
  candidate/evidence/quorum fixtures.
- A fresh `#print axioms` report for twelve preservation, replay, evidence,
  fixture and sheaf-adapter endpoints passed. Every report contains exactly
  `propext`, `Classical.choice` and `Quot.sound`, with no project or
  native-evaluation axiom. The reproducible commands are in the
  [protocol guide](lean/Protocol/README.md#validation). These endpoints retain
  their explicit application and runtime hypotheses.
- The full default `lake build` passed (7,512 jobs), including the broader
  `Protocol`, `TCB` and `Proximity` compatibility aggregates. Both this and
  the focused build used `LEAN_NUM_THREADS=1` locally. These are local builds
  with the pinned dependencies, not a claim of an executed hosted CI run.
- That milestone's source inventory contained 193 Lean files including the Lake
  configuration. The source scan found no active `sorry`/`admit` and seven
  explicit project axioms in the concrete cited-bound module. The focused
  protocol import closure does not import that module; source scanning is
  distinct from the theorem-dependency report.

The protocol queue and [scope](papers/paper2/SCOPE.md) retain storage backend/lifecycle refinement,
mint/burn policy, concrete application/security profiles, Rust refinement and
consensus finality as separate work. The legacy `Chain` aggregate remains a
compatibility import; its spectral identity, fork choice and raw edge-sum
balance are not the semantics of the new resource kernel.

#### Mathematics and storage follow-up

The 2026-11-05 follow-up completes the four generic formalization tasks
Q04--Q07: actual all-parameter fields/subgroups, the full list phase split and
real safe interval, the boundary-field real supremum/nonattainment, and the
attained generic distance/covering/good-challenge interface. All nine named
standalone coding statements now have Lean endpoints; `ProximityPrize` has
passed its expanded aggregate build. Its local import closure has 25 modules
and contains neither the project's cited-bound module nor legacy `Chain`.

The coordinated build
`lake build ProximityPrize Sheaf.ObservationQuotient Protocol.Storage.Core Protocol.Storage.Examples Protocol.Storage.CanonicalRS`
passed (7,447 jobs), including all six projection/gate levels and the actual
canonical observation join. The expanded full default `lake build` also
passed (7,530 jobs), including the broad protocol compatibility aggregates.
Both used `LEAN_NUM_THREADS=1` with the unchanged Lean/Mathlib pins. These
local results do not assert that hosted CI has run. The fresh forty-endpoint
theorem-dependency audit passed with exit status zero and exactly forty
reports: 36 contain exactly `propext`, `Classical.choice`, `Quot.sound`;
four additionally contain `Lean.ofReduceBool` and `Lean.trustCompiler`.
The latter are the boundary-field real threshold and three optional
canonical-field adapter endpoints. No selected endpoint uses a project
cited-bound axiom or `sorryAx`; explicit application/codec/gate/persistence
hypotheses remain. The validation guide lists all forty declarations and the
four native dependencies.
The 64-module focused storage-core import closure has neither `CitedBounds`
nor `Chain`; source import inspection is distinct from the axiom report.
That earlier source inventory had 212 Lean files including the Lake
configuration. A comment-aware scan finds no active `sorry`/`admit`, and
exactly seven project axioms in the existing concrete cited-bound module.
The local module graph has no import cycles. The [validation guide](docs/MATH_STORAGE_VALIDATION.md)
contains reproduction commands for the expanded theorem audit.

The source profiles and three distance meanings are recorded in the
[storage guide](lean/Protocol/Storage/README.md). The
[primary-source comparison](docs/PROXIMITY_NOVELTY_COMPARISON.md) documents
the established MCA event and sharper literature regimes, the elementary
endpoint reasoning, and the concrete commitment/codec comparison still
needed. New module presence, source identities or storage roots alone do
not establish a new geometric radius, primitive security or novelty claim.

#### History-anchor validation and pre-upgrade baseline

The 2026-11-05 history-anchor follow-up passed the focused build of
`Protocol.Storage.Anchor`, `ProjectionAnchor` and `AnchorExamples`
(7,417 jobs), then the full default build (7,532 jobs). The separate fresh
nineteen-endpoint dependency probe passed with exactly nineteen distinct
reports, each containing exactly `propext`, `Classical.choice` and
`Quot.sound`. None uses native-evaluation trust, a project axiom or `sorryAx`.
These runs used `LEAN_NUM_THREADS=1` and the **pre-upgrade Lean 4.24.0 pin**
with Mathlib `f897ebcf72cd16f89ab4577d0c826cd14afaafc7`.

The corresponding source inventory has 215 Lean files, no active
`sorry`/`admit`, no local import cycles, and the same seven existing
cited-bound axioms. Focused local closures are Prize 25, Protocol.Core 33,
Storage.Core 77 and CanonicalRS 58; all exclude legacy `Chain` and project
`CitedBounds`. The source-radius profile, actual hash/encoding/backend
contracts, dynamic geometry and finality remain open.

The user subsequently authorized updating the main Lean/Mathlib pins.
The preceding results are a preserved baseline, not validation of that newer
toolchain. The [validation guide](docs/MATH_STORAGE_VALIDATION.md) reproduces
the nineteen-endpoint probe. [Palomar preparation](docs/PALOMAR_SUBMISSION_PLAN.md)
tracks the separate statement/comparison/metadata work; Jacobian Paper 1 is
already under review and is only the reference setup.

#### Lean 4.35 validation

The following **pre-addition 4.35 baseline** precedes the twenty-module
follow-up recorded in P218--P229 and the current validation guide.

The authorized main-repository upgrade is complete. Lean `v4.35.0` and Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679` have matching transitive checkouts.
All 214 source modules expose their public interfaces in the new module
system; the Lake configuration is the 215th Lean file. The full union of all
fifteen default targets and the explicit ledger/evidence/storage integration
targets passed with `LEAN_NUM_THREADS=4` (**9,233 jobs**).
The subsequent literal default `lake build` also passed (**9,228 jobs**).

Fresh dependency probes passed for forty mathematics/storage, nineteen anchor
and nine principal HCP/CVP declarations: **68 distinct reports**, 64 containing
exactly `propext`, `Classical.choice` and `Quot.sound`. The same four
boundary/canonical endpoints retain native arithmetic trust; on 4.35 this
prints as generated `_native.native_decide.ax_` certificate axioms. None of
these reports uses the seven cited-bound axioms or `sorryAx`.

The source scan finds no active proof holes or local import cycles and the
same seven explicitly declared cited-bound axioms. The four focused closure
counts remain 25/33/77/58. Explicit coordinate conversions and upstream API
repairs preserve the existing source/target propositions and metrics; they
do not supply Q08's codec/lifts, a nonempty far profile, authentication or
backend implementations. The [validation guide](docs/MATH_STORAGE_VALIDATION.md)
reproduces all three probes and distinguishes this run from the old pin.

### Manuscript alignment for the review package

Paper 1's appendix now explicitly inventories `Sheaf/Integral.lean`,
`Sheaf/HarmonicLattice.lean` and `TCB/HCPObservation.lean`: supplied integral
structure, integral coboundary preservation, the distinct exact component and
full Hodge sample, presented harmonic lattice endpoints and the typed
context/payload/snapshot join. Its wording retains the remaining modular
encoding and public-realization obligations; this is coverage of existing
results, not a new construction of those inputs.

The **pre-addition manuscript baseline** had 95 Paper 1 pages and 24 Paper 3 pages. Both final TeX builds
have zero warnings, undefined references/citations, missing glyphs and overfull
boxes. All 119 pages were rendered and visually checked, with changed pages
also reviewed at full resolution. Paper 1 now states the conditional
exact-component obstruction and the closed-promise boundary condition.
Paper 3's ledger agrees with all nine generic Lean endpoints and keeps the
uninstantiated application profile explicit.

The baseline canonical PDFs matched their then-current stable review exports.
Preserved baseline SHA-256:

- Paper 1: `64099877e8a362557d95cef37eec45c74661424d852e2a1223d6d6b1122a6cb9`.
- Paper 3: `c0cafc6a3c5fbf524a5c860e193f41fd0f029b8f7731bed0ec1605e93fb6b920`.

The current manuscript record below supersedes those baseline exports.

### Current native-metric manuscript alignment — 2026-11-05

Paper 1 now has **97 pages**, including genuine Plucker subspace/projector
recovery and the operative-kernel identification boundary. Paper 3 has
**28 pages**, including the intrinsic modular cellular profile, original-payload
comparison `d_C ≤ d_P = D_RS ≤ 2d_C`, the capacity-far payload, and explicit
challenge/Euclidean obstructions. Paper 2 has
[initial manuscript text](papers/paper2/DRAFT.md), without a TeX/PDF bundle.

Both final TeX passes have no undefined references/citations, missing glyphs
or overfull boxes. All **125 pages** were rendered and visually inspected,
with changed mathematical and ledger pages checked at higher resolution.
Eight Paper 1 and two Paper 3 underfull-box diagnostics remain; no visible
layout defect was found. The canonical and stable review PDFs match bytewise.

- Paper 1 SHA-256: `40f84530a5b0e95131c71189a9303b3e2ae0005ec4b9bcfead50846f22f6d46f`.
- Paper 3 SHA-256: `61d7589a75b48bc877c768df0795059220af7fc921ed6f681e8e5b391a8ab9e7`.

The current Lean record is P229: expanded/default builds 9,253/9,248 jobs
and 139 audited declarations. The shared development register intentionally
retains historical milestones; the planned Palomar release will select a
small statement/proof closure and matching account, excluding development
archives and plans. The local human-review package is broader and is not a
Palomar submission. Publication and protected comparison have not occurred.
