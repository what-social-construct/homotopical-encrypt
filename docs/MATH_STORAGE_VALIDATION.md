# Mathematics and sheaf-storage validation

This record covers the concrete Helfer/Hodge/CVP family and observation
adapters, Q04--Q07 and the native modular profile, the sheaf/storage adapters,
and D03's gap-boundary interface. It distinguishes
source coverage, checked proof statements and theorem dependencies. It does
not certify a concrete cryptographic scheme, an uninstantiated source-radius
profile, an efficient gap solver or a storage backend.



## Current primitive and TCB comparison — 2026-11-07

The actual-runtime comparison and original-object joins are recorded in
[Paper 2 §6.4](../papers/paper2/DRAFT.md#64-actual-primitives-and-the-trusted-computing-boundary)
and the [protocol queue](PROTOCOL_PARITY_QUEUE.md#actual-primitive-comparison-and-tcb-joins--2026-11-07).
Existing worker spectral signatures and sampled matrix verification do not
instantiate owner-intent authorization or snapshot-bound decoded-cochain
acceptance. Concrete primitive error estimates therefore remain open.

| Source | Checked statement and boundary |
|---|---|
| [TCB.PrimitiveChecks](../lean/TCB/PrimitiveChecks.lean) | Actual byte-signature/proof algorithms, byte-indexed backend statement, finite query history and compromised-key predicate. Verified signatures split into fresh forgery, compromise or queried message; successful proof verification does not assert statement truth. No soundness, ZK or numerical estimate is built in. |
| [Transfer.Primitives](../lean/Protocol/Transfer/Primitives.lean) | Explicit owner/key/message/history and proof-input/check-agreement equations preserve the actual parsed packet, exact intent/metadata and original interpretation. Accepted-invalid implies fresh forgery, compromise, queried-unauthorized message, false backend proof statement or backend/original-context mismatch. The same PMF gives the five-term bound and supplied-budget corollary, without independence. |
| [Sheaf.GraphCommitment](../lean/Sheaf/GraphCommitment.lean) | Actual ordered incidence differences and canonical modular residues form the existing full `CochainCommitmentData`. Global stalk translation preserves payload and all deterministic observations while changing the designated message. At modulus 12289, path-three openings `[3,5,9]` and `[10,12,16]` both give `[2,4]`; both payloads are well formed. This is an ordinary-incidence obstruction, separate from private restrictions, harmonic blinding and authenticated C¹ payload binding. |
| Legacy TCB/ZKP carriers | Comment-only clarification: proof/observation/envelope acceptance contains supplied statement truth and feature assumptions. No code/API token or semantic definition changes. The data-indexed primitive implication must be established separately. |

Primitive-game instantiation requires correct secret-key setup/registration and
history covering honest signatures already present in the release or auxiliary
input. The recorded history is not an adaptive oracle execution. The backend
proof statement needs a finite-encoding/arithmetization comparison to the
original trusted context, not matching names. No global digest injectivity,
actual SNARK/ZK implementation, primitive error estimate, runtime refinement,
external-history authentication or finality is proved by these interfaces.

The current Rust comparison identifies public-seed bootstrap keys, spectral
rather than owner-intent messages, signature-entry counting, permissive optional
parsing, a sampled-matrix statement, unsupported opening-count error labels and
Python/Rust challenge-generator disagreement. Runtime comments and success
diagnostics now describe their actual scope; acceptance/arithmetic algorithms
are unchanged. Fixed public comparisons and source hashes are in local
`output/validation/primitive-runtime-comparison.json`. These are source audits
and an independent generator translation, not native Rust refinement.

### Primitive comparison validation

Focused builds pass for the low-level/legacy TCB batch (3,156 jobs), graph
payload (3,140), primitive transfer adapter (3,460) and combined transfer/sheaf/
TCB facade (3,779). Added modules have no local warnings/errors; upstream
warnings are replayed separately. The fresh seven-facade probe passes
**667 distinct selected reports**: **631 standard-only** (537 exactly the usual
three and 94 subsets), plus **36 retaining existing native arithmetic
certificates**. All **62 additions are standard-only**: 29 exact-three,
11 axiom-free and 22 proper nonempty subsets. All 605 preceding dependency
sets match exactly. No selected report uses a cited-bound axiom or `sorryAx`.
These reports do not discharge explicit primitive/refinement assumptions.

| Added selected group | Reports |
|---|---:|
| Byte-level TCB records and check classification | 9 |
| Original-transfer primitive/error composition | 24 |
| Ordered graph and actual modular payload ambiguity | 29 |

The current static audit covers **262 source modules / 263 Lean files**,
without active holes, unresolved imports or cycles and with the same seven
isolated cited-bound axioms. All **35** recorded focused closures exclude
legacy `Chain` and `CitedBounds`. New closures contain 6 local modules for
`TCB.PrimitiveChecks`, 56 for `Transfer.Primitives`, and 2 for
`Sheaf.GraphCommitment`; the transfer facade contains 65.
The expanded union passes **9,281 jobs** and literal default passes
**9,274 jobs**, on the unchanged Lean/Mathlib 4.35 pins.

Local artifacts under `output/validation/` are `primitive-{full,default}-build.log`,
`primitive-{all,new}-axioms.lean`, `primitive-all-axioms.log`,
`primitive-axiom-summary.json`, `primitive-source-audit.json`,
`primitive-comment-scope-audit.json` and `primitive-runtime-comparison.json`.
Six legacy Lean bodies are unchanged after comment/whitespace normalization;
three Rust files change comments only. The geodesic source additionally changes
two success diagnostics and removes their opening-count display arguments;
acceptance/arithmetic tokens are unchanged. Runtime behavior is not formally
verified by that source audit.

Reproduce the added proof/dependency endpoints from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build Protocol.Transfer Sheaf TCB
cat > /tmp/primitive-new-axioms.lean <<'LEAN'
import TCB.PrimitiveChecks
import Protocol.Transfer.Primitives
import Sheaf.GraphCommitment

#print axioms Hcrypt.TCB.PrimitiveChecks.Bytes
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureVerifier
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureHistory
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureHistory.Queried
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureHistory.Forgery
#print axioms Hcrypt.TCB.PrimitiveChecks.SignatureHistory.verified_cases
#print axioms Hcrypt.TCB.PrimitiveChecks.ProofVerifier
#print axioms Hcrypt.TCB.PrimitiveChecks.ProofVerifier.FalseAccept
#print axioms Hcrypt.TCB.PrimitiveChecks.ProofVerifier.verified_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.SignatureProfile
#print axioms Hcrypt.Protocol.Transfer.Primitives.PayloadProfile
#print axioms Hcrypt.Protocol.Transfer.Primitives.ParsedFor
#print axioms Hcrypt.Protocol.Transfer.Primitives.Forgery
#print axioms Hcrypt.Protocol.Transfer.Primitives.CompromisedKey
#print axioms Hcrypt.Protocol.Transfer.Primitives.QueriedUnauthorized
#print axioms Hcrypt.Protocol.Transfer.Primitives.ProofFalseAccept
#print axioms Hcrypt.Protocol.Transfer.Primitives.StatementMismatch
#print axioms Hcrypt.Protocol.Transfer.Primitives.authorizationFailure_implies_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.payloadFailure_implies_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.acceptedInvalid_implies_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.forgeryEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.compromisedKeyEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.queriedUnauthorizedEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.proofFalseAcceptEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.statementMismatchEvent
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.forgeryProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.compromisedKeyProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.queriedUnauthorizedProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.proofFalseAcceptProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.statementMismatchProbability
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.acceptedInvalidEvent_subset_cases
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.acceptedInvalidProbability_le
#print axioms Hcrypt.Protocol.Transfer.Primitives.Experiment.acceptedInvalidProbability_le_of_bounds
#print axioms Hcrypt.Sheaf.GraphCommitment.Layout
#print axioms Hcrypt.Sheaf.GraphCommitment.Assignment
#print axioms Hcrypt.Sheaf.GraphCommitment.edgeCoordinates
#print axioms Hcrypt.Sheaf.GraphCommitment.translate
#print axioms Hcrypt.Sheaf.GraphCommitment.edgeCoordinates_length
#print axioms Hcrypt.Sheaf.GraphCommitment.edgeCoordinates_translate
#print axioms Hcrypt.Sheaf.GraphCommitment.translate_coordinate_ne
#print axioms Hcrypt.Sheaf.GraphCommitment.observe_translate
#print axioms Hcrypt.Sheaf.GraphCommitment.alternative_observed_opening
#print axioms Hcrypt.Sheaf.GraphCommitment.not_injective_observe
#print axioms Hcrypt.Sheaf.GraphCommitment.payload
#print axioms Hcrypt.Sheaf.GraphCommitment.payload_edgeCountMatches
#print axioms Hcrypt.Sheaf.GraphCommitment.payload_wellFormed
#print axioms Hcrypt.Sheaf.GraphCommitment.payload_translate
#print axioms Hcrypt.Sheaf.GraphCommitment.encoded_payload_translate
#print axioms Hcrypt.Sheaf.GraphCommitment.alternative_payload_opening
#print axioms Hcrypt.Sheaf.GraphCommitment.not_messageBinding
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.layout
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.original
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.shifted
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.shifted_values
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.original_edges
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.shifted_edges
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.messages_differ
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.payload_collision
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.original_payload_edges
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.original_payload_wellFormed
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.shifted_payload_wellFormed
#print axioms Hcrypt.Sheaf.GraphCommitment.PathThree.encoded_collision
LEAN
LEAN_NUM_THREADS=4 lake env lean /tmp/primitive-new-axioms.lean
```

The consolidated 667-report probe retains the same seven facade imports as
the preceding integrity milestone and appends these 62 names. Earlier dated
entries below retain their milestone counts and source snapshots.

## Current one-shot integrity — 2026-11-06

The conditional Paper 2 transition now has a soundness-free operational layer
and an explicit sampled integrity experiment. The raw algorithms do not assume
that verification implies semantic authorization or payload acceptance. This
avoids proving an error bound in a model that already excludes every error.
The exact interfaces retain their universal contracts and project to the same
checker, original context, policy and parsed candidate.

| Source | Checked statement and boundary |
|---|---|
| [TransferCheck](../lean/Protocol/Evidence/TransferCheck.lean) | Actual canonical parser, metadata/intent equality and signature/proof Boolean checks without primitive soundness. Exact [TransferVerifier](../lean/Protocol/Evidence/TransferVerifier.lean) projections run definitionally the same check and retain the same packet. |
| [Operational](../lean/Protocol/Transfer/Operational.lean) | Same original input, owned-resource policy and staged proposal. Local authorization and original-context acceptance derive validity. Actual Boolean acceptance plus invalidity of the actually parsed candidate implies authorization false acceptance or exact-payload false acceptance under that trusted interpretation. |
| [PublicView](../lean/Protocol/Transfer/PublicView.lean) | Actual checked packet bytes, typed packet, complete proposal and original input-manifest base/root/directory. Canonical-byte and original-object joins are proved. Exposed resource/signer IDs and metadata distinguish records directly; this release is not the whole network transcript. |
| [Security](../lean/Protocol/Transfer/Security.lean) | Explicit view, auxiliary input, PMF tape and adversary determine the same attempt. Event inclusion gives `Pr[AcceptedInvalid] ≤ Pr[AuthorizationFailure] + Pr[PayloadFailure]`; supplied bounds compose without independence. Support-local good events give zero error. The exact-config specialization gives ideal zero only under its universal contracts. `ofCheckedRelease` uses the actual release projection. |

The experiment fixes the trusted setup, including the actual interpretation,
original source state and selected algorithms. Additional setup information,
catalog/prior-state access, openings and access metadata must enter its declared
auxiliary input or an extended view. No primitive error estimate, security
parameter, efficient-adversary class, adaptive signing/proof oracle, corruption
policy, confidentiality, anonymity, authenticated state origin, runtime
refinement, external-history hash authentication, durable application or
finality result is established. Exact
canonical-codec and topology setup contracts remain explicit. The one-entry
manifest supplies no additional proximity radius or six-stage gate theorem.

Paper 2 §6.3 and the shared register H50--H53, D32, P253--P257 and HC45--HC47
record this step. Paper 1/3 sources and reviewed PDFs are unchanged. The entry
below records the preceding owned-resource milestone; its counts and closure
sizes are historical baselines rather than validation of later source.

### One-shot integrity validation

Focused checks pass for the raw/exact packet modules (3,406 jobs), operational
profile (3,408), refactored exact owned/history profile (3,418), actual released
view (3,411), sampled security module (3,458) and complete facade (3,467).
These modules have no local warnings or errors; upstream warnings are replayed
separately. The expanded union passes **9,278 jobs** and literal default passes
**9,271 jobs**, on the unchanged Lean/Mathlib 4.35 pins.

The static scan covers **259 public source modules / 260 Lean files**, with no
active holes, unresolved local imports or cycles and the same seven isolated
cited-bound axioms. All **32** recorded focused closures exclude legacy `Chain`
and `CitedBounds`. Current closure sizes are raw packet checks 47, operational
transfer 50, actual released view 53, sampled security 54, exact owned profile
52, anchored profile 60 and facade 63.

The fresh seven-facade probe passes **605 distinct selected reports**:
**569 standard-only** (508 exactly the usual three, 61 subsets) and
**36 retaining existing native arithmetic certificates**. All **105 additions
are standard-only**: 79 exactly the three, 24 axiom-free and two proper
nonempty subsets. Every preceding 500 dependency set is unchanged. No selected
report uses a cited-bound axiom or `sorryAx`. Dependency reports do not
discharge the explicit setup, primitive-error or runtime assumptions.

| Added selected group | Reports |
|---|---:|
| Soundness-free canonical packet checks | 14 |
| Original operational transfer and failure reduction | 28 |
| Actual released transfer record and distinguishers | 36 |
| Shared-PMF experiment, bounds and ideal specialization | 17 |
| Exact-to-operational algorithm/candidate joins | 10 |

Local artifacts are `security-{full,default}-build.log`,
`security-{all,new}-axioms.lean`, `security-all-axioms.log`,
`security-axiom-summary.json` and `security-source-audit.json` under
`output/validation/`, plus focused build logs. Reproduce the added endpoints:

```sh
LEAN_NUM_THREADS=4 lake build Protocol.Transfer
cat > /tmp/security-new-axioms.lean <<'LEAN'
import Protocol.Transfer

#print axioms Hcrypt.Protocol.Evidence.TransferCheck.Authorization
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.PayloadVerifier
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.PacketCodec
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.PacketCodec.encode_injective
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.check
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.check_sound
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.ofCheck
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.check_true
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.packet_eq
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.signatureVerified_expected
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.CheckedPacket.proofVerified_expected
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.check_true_iff
#print axioms Hcrypt.Protocol.Evidence.TransferCheck.reject_malformed
#print axioms Hcrypt.Protocol.Transfer.Operational.ResourceTransfer
#print axioms Hcrypt.Protocol.Transfer.Operational.ResourceChecks
#print axioms Hcrypt.Protocol.Transfer.Operational.Config
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.manifest
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.cochainRoot
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.draftFor
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.intentFor
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.subject
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.candidateFor
#print axioms Hcrypt.Protocol.Transfer.Operational.Config.policy
#print axioms Hcrypt.Protocol.Transfer.Operational.Prechecks
#print axioms Hcrypt.Protocol.Transfer.Operational.check
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.ofCheck
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.check_true
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.candidate
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.candidate_eq
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.successor_eq
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.draft_eq
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.subject_eq
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.valid
#print axioms Hcrypt.Protocol.Transfer.Operational.CheckedTransfer.accepted_update
#print axioms Hcrypt.Protocol.Transfer.Operational.Attempt
#print axioms Hcrypt.Protocol.Transfer.Operational.AcceptedInvalid
#print axioms Hcrypt.Protocol.Transfer.Operational.AuthorizationFailure
#print axioms Hcrypt.Protocol.Transfer.Operational.PayloadFailure
#print axioms Hcrypt.Protocol.Transfer.Operational.acceptedInvalid_implies_failure
#print axioms Hcrypt.Protocol.Transfer.Operational.not_acceptedInvalid_of_good
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ext
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.eq_iff
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.transfer
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.base
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.metadata
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.nullifiers
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_packetBytes_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_transfer_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_input_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_output_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_signer_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_metadata_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_base_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_proposal_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.ne_of_manifest_ne
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.inputTest
#print axioms Hcrypt.Protocol.Transfer.Owned.PublicTransferView.inputTest_distinguishes
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_bytes
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_decoded
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_canonical
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_intent
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_transfer
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_metadata
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_base
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_manifest
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_manifest_base
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_manifest_root
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_manifest_directory
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_proposal
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_proposal_computed
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_proposal_draft
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_source_evidence
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_nullifiers
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.publicView_eq
#print axioms Hcrypt.Protocol.Transfer.Security.Adversary
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.attempt
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidEvent
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.authorizationFailureEvent
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.payloadFailureEvent
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.authorizationFailureProbability
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.payloadFailureProbability
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidEvent_subset_failures
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability_le
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability_le_of_bounds
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability_eq_zero_of_no_failures
#print axioms Hcrypt.Protocol.Transfer.Security.ofCheckedRelease
#print axioms Hcrypt.Protocol.Transfer.Security.ofCheckedRelease_view
#print axioms Hcrypt.Protocol.Transfer.Security.ofCheckedRelease_attempt
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.Authorization.operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PayloadVerifier.operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PacketCodec.operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.check_eq_operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.operational
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.ofOperational
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.operational
#print axioms Hcrypt.Protocol.Transfer.Owned.check_eq_operational
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.operational
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.operational_candidate
#print axioms Hcrypt.Protocol.Transfer.Security.Experiment.acceptedInvalidProbability_eq_zero_of_exact_config
LEAN
LEAN_NUM_THREADS=4 lake env lean /tmp/security-new-axioms.lean
```

The full 605-declaration probe retains the earlier seven facade imports:
`ProximityPrize`, `Sheaf`, `Protocol.Storage`, `TCB`, `Protocol.Ephemeral`,
`Protocol.Ephemeral.Examples` and `Protocol.Transfer`. It combines the preceding
500 selected reports with these 105 additions.

## Current owned-resource transition — 2026-11-06

The conditional first Paper 2 transition is now implemented through
[Protocol.Transfer](../lean/Protocol/Transfer.lean). It transfers one whole
owned resource to a distinct absent/unspent identifier of the same asset and
positive catalog value, with the consumed ID as its public nullifier. The
snapshot and epoch stay fixed. Catalog units are not cochain coefficients,
edge sums, Hodge energies or proximity distances; splitting, fee outputs,
mint/burn and anonymous nullifiers are other profiles.

The eight-module surface retains original objects and explicit assumptions:

| Source | Constructed endpoint and boundary |
|---|---|
| [OwnedResource](../lean/Protocol/Ledger/OwnedResource.lean) | Actual owner/asset/value interpretation, unit flow, input-derived nullifier, availability/conservation/update/inventory proofs and spent-input/output rejection. A distinct-owner mechanical fixture transfers value seven using supplied headers, without cryptographic/runtime fixtures. |
| [TransferTranscript](../lean/Protocol/Evidence/TransferTranscript.lean) | Typed signing-domain intent, complete metadata and packet, state-content projection/reconstruction and separate leaf/cochain/manifest/evidence/block preimages. Source historical evidence is explicit in the intent; parent names its tip. Final proposal supplies target tip/evidence. No preimage contains its own digest and no global hash injectivity is assumed. |
| [TransferVerifier](../lean/Protocol/Evidence/TransferVerifier.lean) | Actual parsing/canonical-byte/metadata/intent checks followed by selected signature and payload Boolean verifiers. Soundness indexes the trusted actual interpretation, with equality required for the original context; it does not quantify over arbitrary decoders sharing names. Primitive implementations and their indexed soundness remain inputs. |
| [TransferManifest](../lean/Protocol/Storage/TransferManifest.lean) | Exact seal of one original input payload/leaf digest, prepared before current proof/block data. Hash preimage and public directory retain the same context. This is separate from the six-stage projection manifest; persistence requires a real matching receipt. |
| [TransferEnvelope](../lean/Protocol/Evidence/TransferEnvelope.lean) | Represents already-derived validity and exact joins in the old semantic TCB using the actual candidate/transfer witness and projected-intent existential shadow. It creates no `True` runtime, unit witness or new verifier-soundness result. |
| [Owned](../lean/Protocol/Transfer/Owned.lean) | Structural checks plus actual checked packet derive `Candidate.Valid` and `check_implies_accepted_update`. Parser identity fixes one candidate/successor. Value, input consumption, output creation, conditional unit inventory and replay consequences follow from the actual existing update. Boolean specification is noncomputable, not a Rust refinement. |
| [Anchored](../lean/Protocol/Transfer/Anchored.lean) | Entire packet metadata/signature/proof bytes determine the evidence preimage; exact input manifest enters block construction. Existing evidence/history anchors retain the actual candidate, artifact, context and computed successor. A supplied acceptance quorum must match the complete final proposal. |
| [Facade](../lean/Protocol/Transfer.lean) | Separate focused entry for this profile; the lower-level `Protocol.Core` and standalone coding target retain their scopes. |

The owner authorizes the pre-proof intent, not a recursively self-containing
final header. Hash and codec implementations, metadata-to-catalog/verifier
interpretation, topology authentication, signature/proof security, authentic
prior-state origin, allocation/byte bounds, atomic backend behavior and
consensus finality remain explicit contracts. Receipt or quorum existence is
not manufactured. S2 private rotation can supply a context but does not turn
this fixed-snapshot update into ledger geometry or epoch migration. Papers 1
and 3 and their reviewed PDFs are unchanged; Paper 2 §6.2 carries the account.

### Owned-transfer validation

The expanded union passes **9,274 jobs** and literal default passes **9,267**
on the unchanged Lean/Mathlib 4.35 pins. Focused builds pass for resources
(3,151), transcript (3,404), trusted-interpretation verifier (3,405), input
manifest (3,405), TCB representation (3,409), checked update (3,408) and the
complete facade (3,417). All added modules have no local warning or error;
upstream linter/deprecation warnings are replayed separately.

The fresh public-facade probe passes **500 distinct selected declarations**:
**464 standard-only** (429 exactly the usual three and 35 subsets), plus
**36 retaining existing native arithmetic certificates**. All **145 added
reports are standard-only**: 123 exactly the three, 19 axiom-free and three
proper nonempty subsets. All 355 preceding dependency sets match exactly.
No selected cited-bound axiom or `sorryAx` occurs. These dependency reports
do not discharge the explicit primitive/profile assumptions.

| Added selected group | Reports |
|---|---:|
| Owned-resource semantics and mechanical fixture | 32 |
| Typed transcript/preimage/proposal construction | 34 |
| Operational codec/signature/trusted-decoder checks | 13 |
| Original input manifest and receipt consequence | 12 |
| Existing TCB/evidence representation | 12 |
| Checked candidate/update and determinism | 25 |
| Exact roots, history and optional quorum | 17 |

The static scan covers **255 public source modules / 256 Lean files** including
Lake configuration, with no active holes, unresolved imports or cycles and
the same seven isolated cited-bound axioms. All **28** recorded focused
closures exclude legacy `Chain` and `CitedBounds`. New closure sizes are
resources 13, transcript 46, verifier 47, manifest 47, envelope 51, checked
transfer 50, anchored transfer 58 and facade 59. The preceding twenty closures
are unchanged.

Local artifacts under `output/validation/` are
`transfer-{full,default}-build.log`, `transfer-{all,new}-axioms.lean`,
`transfer-all-axioms.log`, `transfer-axiom-summary.json` and
`transfer-source-audit.json`, plus the module-specific focused logs.
Reproduce the added public entry/probe from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Transfer Protocol.Core \
  Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.Core Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalThreeLevel Protocol.Storage.CanonicalCalibration \
  Protocol.Ephemeral.Examples Protocol.Ephemeral.HCP
cat > /tmp/transfer-new-axioms.lean <<'LEAN'
import Protocol.Transfer

#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Catalog
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.values
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.value_single
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer.flow
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer.action
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer.nullifiers_nonempty
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Transfer.nullifiers_nodup
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.InventoryInvariant
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.enabled
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.conserves
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.fresh
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.flow_input
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.flow_output
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.flow_other
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.after_input
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.after_output
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.after_other
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.preserves_inventory
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.input_spent_after
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.reused_input_rejected
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Checks.reused_output_rejected
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.catalog
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.transfer
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.before
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.checks
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.inventory
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.candidate
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.after_marking
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.before_value
#print axioms Hcrypt.Protocol.Ledger.OwnedResource.Fixture.after_value
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.ofState
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.restore
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.reconstruct
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.ofState_restore
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.afterFor
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.StateContent.ofState_after
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft.ofProposal
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft.complete
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft.reconstruct
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProposalDraft.ofProposal_complete
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.Intent
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProofMetadata
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProofMetadata.ext
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProofMetadata.eq_iff
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ProofPacket
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ManifestPreimage
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ManifestPreimage.ofView
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ManifestPreimage.toView
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.ManifestPreimage.reconstruct
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.BlockPreimage
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.blockPreimage
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_draft
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_evidenceRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_blockDigest
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_parentDigest
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_beforeStateRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_afterStateRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_snapshotRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_topologyRoot
#print axioms Hcrypt.Protocol.Evidence.TransferTranscript.HashSuite.proposal_cochainRoot
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.Authorization
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PayloadVerifier
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PacketCodec
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.PacketCodec.encode_injective
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.check
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.check_sound
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.ofCheck
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.check_true
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.authorized
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.CheckedPacket.accepted
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.check_true_iff
#print axioms Hcrypt.Protocol.Evidence.TransferVerifier.reject_malformed
#print axioms Hcrypt.Protocol.Storage.TransferManifest.inputItem
#print axioms Hcrypt.Protocol.Storage.TransferManifest.preimage
#print axioms Hcrypt.Protocol.Storage.TransferManifest.scheme
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_items
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_root
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView_base
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView_root
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView_directory
#print axioms Hcrypt.Protocol.Storage.TransferManifest.sealed_publicView_preimage
#print axioms Hcrypt.Protocol.Storage.TransferManifest.persisted_of_receipt
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.compression
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.compressed
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.proof
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.proof_wellFormed
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.observation
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.envelope
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toEvidence
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toEvidence_artifact
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toEvidence_witness
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toEvidence_shadow
#print axioms Hcrypt.Protocol.Evidence.TransferEnvelope.Derivation.toAcceptedUpdate
#print axioms Hcrypt.Protocol.Transfer.Owned.Config
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.manifest
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.cochainRoot
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.draftFor
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.intentFor
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.subject
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.policy
#print axioms Hcrypt.Protocol.Transfer.Owned.Prechecks
#print axioms Hcrypt.Protocol.Transfer.Owned.check
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.ofCheck
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.check_true
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.candidate
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.candidate_eq
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.successor_eq
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.draft_eq
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.subject_eq
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.valid
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.accepted_update
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.value_preserved
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.input_consumed
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.output_created
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.inventory_preserved
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.replay_rejected
#print axioms Hcrypt.Protocol.Transfer.Owned.check_implies_accepted_update
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.bindings
#print axioms Hcrypt.Protocol.Transfer.Owned.Config.history
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.packet_transfer
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.packet_metadata
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.packet_included
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.source_reconstruct
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.successor_reconstruct
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.before_root_bound
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.after_root_bound
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.transition_bound
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.cochain_included
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.artifact_included
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.derivation
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.evidence
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.anchor
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.anchored_update
#print axioms Hcrypt.Protocol.Transfer.Owned.CheckedTransfer.certified
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/transfer-new-axioms.lean
```

## Current recipient recovery and rotation — 2026-11-06

This preceding rotation/recovery milestone is retained as a baseline; the
owned-transfer profile above records the subsequent source and checks.

The bounded rotation profile preserves a declared integer coefficient vector,
not equality of its ambient coordinates. Seven new modules retain the existing
cellular sheaf, integral structure, harmonic-lattice presentation, Hodge sample,
bound HCP observation and storage context objects:

| Module | Constructed endpoint and explicit boundary |
|---|---|
| [CoefficientRecovery](../lean/Sheaf/CoefficientRecovery.lean) | Integer encoding injectivity and a partial classical decoder from the actual observed cochain. It projects with the private Hodge key and returns coefficients exactly on the chosen presented range; no efficient codec or arbitrary CVP solver is supplied. |
| [Integral rotation](../lean/Sheaf/Rotation.lean) | Actual chain-isometry identity/inverse/composition, projector naturality, an explicit integral-one lattice law, derived harmonic-lattice equivalence and actual message/noise/sample transport with roundtrip/composition. Isometry alone proves no integrality or native Hamming preservation. |
| [Actual axis rotation](../lean/HCP/AxisRotation.lean) | Constructs integral coordinate exchange and proves the encoding law for every integer input. Weighted `(1,2)` becomes `(2,1)` and retains coefficient two; the old fixed-input right sample instead decodes to one. |
| [Presented rotation](../lean/Protocol/Ephemeral/Rotation.lean) | Actual integral geometry plus the chosen encoding law proves direct target-key and retained-base/inverse-key recovery of the same plaintext. A decoder/transport equation transfers exact-payload acceptance. The legacy ephemeral path is joined to actual family endpoints and separate rotation data, not used to generate that data. |
| [Scoped delivery](../lean/Protocol/Ephemeral/Delivery.lean) | Original recipient, epoch labels, context identifiers, actual private rotation and envelope index supplied authorization/channel relations. Whole-scope mismatch returns `none`. Matching labels authenticate no caller and prevent no replay; epoch labels still need authenticated state binding. |
| [Original bound-sample join](../lean/Protocol/Ephemeral/HCP.lean) | Actual full-sample transport between existing bound HCP records derives the original payload decoder equation from their existing decoded-exact-component fields. Both recipient routes require actual source message membership in the chosen presented lattice. The constructor retains supplied target artifact/acceptance/binding proofs. |
| [Recipient axis fixture](../lean/Protocol/Ephemeral/Examples.lean) | Instantiates the actual rotation and encoding law and derives coefficient-two recovery through the scoped receipt, retaining original contexts/envelopes and channel proofs as inputs. No dummy hashes or authorization/channel facts are constructed. |

Paper 2 §6.1 states these results and their scope. The base complex is fixed;
fresh generation, authenticated channel implementation, lifecycle/retirement,
atomic storage updates, physical erasure, privacy games and any further
coordinate/metric or topology-change comparisons remain separate obligations.
The decoder is noncomputable. Source/target classifiers may differ in the
bound-sample adapter; no equality of class labels, roots or released views is
inferred there. Papers 1 and 3 and their reviewed PDFs are unchanged.


### Rotation/recovery validation

The expanded union of all fifteen default roots and explicit integration
entries passes **9,266 jobs**; the literal default passes **9,259 jobs** on the
unchanged Lean/Mathlib 4.35 pins. Focused checks pass for the coefficient leaf
(3,335), integral rotation (3,336), actual axis rotation (3,584), presented
rotation (3,395), scoped delivery/recipient fixture (3,611) and original bound
HCP adapter (3,401). Replayed upstream linter/deprecation warnings remain;
these added modules have no local warning or error.

The fresh public-facade probe passes **355 distinct selected declarations**:
**319 standard-only** (306 exactly the three logical axioms and thirteen
subsets), plus **36 retaining existing native arithmetic certificates**.
All **87 added reports are standard-only**: 86 exactly the three and one
axiom-free (`DeliveryScope`). All 268 preceding dependency sets match exactly.
No selected result depends on a cited-bound axiom or `sorryAx`.

| New selected group | Reports |
|---|---:|
| Presented-coefficient recovery | 5 |
| Integral chain/noise/sample transport | 25 |
| Actual same-coefficient axis rotation | 15 |
| Presented rotation, payload law and legacy path endpoint join | 18 |
| Private recipient delivery scope/receipt | 13 |
| Original bound HCP sample/payload migration | 8 |
| Actual recipient axis fixture | 3 |

The static source scan covers **247 public source modules / 248 Lean files**
including Lake configuration, with no active holes, unresolved imports or
local cycles and the same seven isolated cited-bound axioms. All twenty
recorded focused closures exclude `Chain` and `CitedBounds`. The seven added
closures (including each entry) are coefficient recovery 7, integral rotation
8, axis rotation 22, presented rotation 37, delivery 38, bound-HCP rotation 43
and recipient axis fixture 47. All thirteen earlier closures are unchanged.

Local evidence is under `output/validation/`: `rotation-{full,default}-build.log`,
`rotation-{all,new}-axioms.lean`, `rotation-all-axioms.log`,
`rotation-axiom-summary.json` and `rotation-source-audit.json`; focused build
logs retain their module-specific names. These are selected dependency and
source checks, not a claim that channel or primitive assumptions have been
instantiated. No new project axiom or native arithmetic certificate is added.

Reproduce the added checks from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Ephemeral.Examples Protocol.Ephemeral.HCP \
  Protocol.Core Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.Core Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalThreeLevel Protocol.Storage.CanonicalCalibration
cat > /tmp/rotation-new-axioms.lean <<'LEAN'
import Protocol.Ephemeral
import Protocol.Ephemeral.Examples

#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.point_injective
#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients
#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients_eq_some_iff
#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients_eq_none_iff
#print axioms Hcrypt.Sheaf.CellularSheaf.HarmonicLatticePresentation.decodeCoefficients_encrypt
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.refl
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.symm
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.trans
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.harmonicOneProjection_naturality
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_exactComponent
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_coexactComponent
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_value
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_refl
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_symm
#print axioms Hcrypt.Sheaf.CellularSheaf.IsometricCochainEquiv.transportNoise_trans
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.refl
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.symm
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.trans
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.harmonicOne_iff
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.harmonicLatticeEquiv
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_message
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_opening
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_observed
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_projection
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_refl
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_symm
#print axioms Hcrypt.Sheaf.CellularSheaf.IntegralCochainEquiv.transportSample_trans
#print axioms Hcrypt.HCP.AxisRotation.integralOne_iff
#print axioms Hcrypt.HCP.AxisRotation.integralAxisSwap
#print axioms Hcrypt.HCP.AxisRotation.point_naturality
#print axioms Hcrypt.HCP.AxisRotation.transport_encrypt_eq_encrypt
#print axioms Hcrypt.HCP.AxisRotation.decode_rotated_encrypt
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_observed
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_coordinates
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_message
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_decode
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_pullback
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_pullback_decode
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_coefficient_two
#print axioms Hcrypt.HCP.AxisRotation.fixedWeightedSample_decode_one
#print axioms Hcrypt.HCP.AxisRotation.rotatedWeightedSample_ne_fixedSample
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.rotateObserved
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.recoverWithBase
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.pullback_rotateObserved
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.transport_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.decode_rotated_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.recoverWithBase_rotated_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.recovery_routes_agree
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.refl
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.symm
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.trans
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.rotateObserved_trans
#print axioms Hcrypt.Protocol.Ephemeral.PresentedRotation.rotateObserved_symm
#print axioms Hcrypt.Protocol.Ephemeral.PayloadRotation
#print axioms Hcrypt.Protocol.Ephemeral.PayloadRotation.target_accepted
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation.samePublicFingerprint
#print axioms Hcrypt.Protocol.Ephemeral.EphemeralRotation.recover_rotated_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.DeliveryScope
#print axioms Hcrypt.Protocol.Ephemeral.DeliveryScope.forContexts
#print axioms Hcrypt.Protocol.Ephemeral.DeliveryContract
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.scope
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_rotated_encrypt
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_eq_none_of_scope_ne
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_recipient
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_sourceEpoch
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_targetEpoch
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_sourceKey
#print axioms Hcrypt.Protocol.Ephemeral.RecoveryDelivery.recoverFor_wrong_targetKey
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation.cochainObject_eq
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation.payloadRotation
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation.decode_target
#print axioms Hcrypt.Protocol.Ephemeral.BoundSampleRotation.recover_with_base
#print axioms Hcrypt.Protocol.Ephemeral.bindRotatedSample
#print axioms Hcrypt.Protocol.Ephemeral.bindRotatedSample_artifact
#print axioms Hcrypt.Protocol.Ephemeral.boundSampleRotation_bindRotatedSample
#print axioms Hcrypt.Protocol.Ephemeral.Examples.axisPresentedRotation
#print axioms Hcrypt.Protocol.Ephemeral.Examples.receipt_recovers_weighted_two
#print axioms Hcrypt.Protocol.Ephemeral.Examples.receipt_rejects_other_epoch
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/rotation-new-axioms.lean
```

## Current public-observation profile — 2026-11-06

This preceding public-input milestone is retained as a baseline; the recipient
rotation follow-up above records the subsequent source and checks.

The first Paper 2 public-input profile is now implemented in
[PublicView](../lean/Protocol/Storage/PublicView.lean), exported through
`Protocol.Storage.Core`:

- `Context.publicView` releases the same original cochain payload and all six
  derived context-key coordinates. Snapshot/run/parameter substitutions are
  observable; equality requires both the header and original payload.
- `SealedManifest.publicView` retains that base input, the actual sealed root
  and ordered slot/digest directory. The directory preserves the original
  slot order and uniqueness, while omitting dependent checkpoint witnesses.
- `hcpDisclosure` adds the existing `(class,b)` observation from the same
  bound sample. Equality of HCP pairs alone does not imply equality of these
  larger releases. A public class announcement without `b` is the separate
  tuple of the base view and that snapshot's classifier value.
- `TCB.HCPRealization.no_exact_view_decoder_of_same_view` requires only
  pairwise equality of the actual released views and different operative
  targets to exclude one decoder exact on both. It supplies neither equality
  of storage records nor cryptographic hiding. The earlier global
  factorization criterion is retained.

Paper 2 §2.1 fixes the data/access boundary. Canonical bytes, authenticated
opening requests, proof/verifier metadata, released history extensions and
their cryptographic binding remain explicit contracts. No new serializer,
hash implementation, key rotation or privacy experiment is claimed. Papers
1 and 3 and their reviewed PDFs are unchanged in this step.


### Public-observation validation

The expanded union of all fifteen default roots and explicit integration
entries passes **9,259 jobs**; the literal default passes **9,254 jobs** on
the unchanged Lean/Mathlib 4.35 pins. The new leaf's focused build passes
3,396 jobs and the pairwise adapter's focused build passes 3,383 jobs. Replayed
upstream linter/deprecation warnings remain; the added code has no local
warning or error.

A fresh public-facade probe passes **268 distinct selected declarations**:
**232 standard-only** (220 exactly the usual three axioms and twelve subsets),
and **36 retaining existing native arithmetic certificates**. All **33 new
reports** are standard-only: 26 use exactly the three, seven use no axioms.
All 235 preceding dependency sets match exactly. No selected result depends
on a cited-bound axiom or `sorryAx`.

The static scan covers **240 public source modules / 241 Lean files** including
Lake configuration, with no active holes, unresolved imports or local cycles,
and the same seven isolated cited-bound axioms. The new public-view closure
has 38 modules; `Protocol.Storage.Core` now has 80. The other eleven recorded
closures are unchanged. All thirteen exclude `Chain` and `CitedBounds`.
The local artifacts are `public-observation-{full,default}-build.log`,
`public-observation-{all,new}-axioms.lean`, `public-observation-all-axioms.log`,
`public-observation-axiom-summary.json` and
`public-observation-source-audit.json` under `output/validation/`.
These are selected dependency reports, not a security or runtime certificate.

To reproduce the added checks from `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Storage.PublicView Protocol.Storage.Core \
  TCB.HCPRealization Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.AnchorExamples Protocol.Storage.CanonicalThreeLevel \
  Protocol.Storage.CanonicalCalibration HCP.AxisFamily TCB.HCPAxisFamily
cat > /tmp/public-observation-new-axioms.lean <<'LEAN'
import Protocol.Storage
import TCB

#print axioms Hcrypt.Protocol.Storage.PublicPayloadView
#print axioms Hcrypt.Protocol.Storage.PublicPayloadView.ext
#print axioms Hcrypt.Protocol.Storage.PublicPayloadView.eq_iff
#print axioms Hcrypt.Protocol.Storage.PublicPayloadView.ne_of_key_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView
#print axioms Hcrypt.Protocol.Storage.Context.publicView_eq_iff
#print axioms Hcrypt.Protocol.Storage.Context.publicView_topologyTag_matches
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_key_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_snapshot_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_runId_ne
#print axioms Hcrypt.Protocol.Storage.Context.publicView_ne_of_parameters_ne
#print axioms Hcrypt.Protocol.Storage.PublicManifestView
#print axioms Hcrypt.Protocol.Storage.PublicManifestView.ext
#print axioms Hcrypt.Protocol.Storage.PublicManifestView.eq_iff
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView_base
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView_directory_slots
#print axioms Hcrypt.Protocol.Storage.SealedManifest.publicView_directory_slots_nodup
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.forget
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.ext
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.eq_iff
#print axioms Hcrypt.Protocol.Storage.HCPDisclosure.ne_of_base_ne
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_forget
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_cochain
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_leafDigest
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_snapshotRoot
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_runId
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_observation
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_eq_iff
#print axioms Hcrypt.Protocol.Storage.hcpDisclosure_same_observation_distinct_parameters
#print axioms Hcrypt.TCB.HCPRealization.no_exact_view_decoder_of_same_view
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/public-observation-new-axioms.lean
```

## Current cellular HCP implementation — 2026-11-06

This preceding construction/validation milestone is retained as a baseline;
the public-observation profile above is its subsequent follow-up.

The five-module follow-up constructs an actual finite integral cellular HCP
family in a proved homological fragment of the typed Helfer interface. It
reuses the existing positive CVP comparison and negative public-recovery/oracle
argument. The full union of all fifteen default roots plus explicit transition,
storage and HCP targets passes **9,258 jobs**; the literal default `lake build`
passes **9,253 jobs**, with `LEAN_NUM_THREADS=4` and unchanged Lean/Mathlib 4.35 pins.

The source scan has **239 public source modules / 240 Lean files** including
Lake configuration. It finds no active proof holes, unresolved local imports
or cycles and the same seven cited-bound axioms. No new project axiom or native
certificate is introduced. The source snapshot is recorded separately from
proof-dependency evidence.

A fresh probe through public facades (`ProximityPrize`, `Sheaf`,
`Protocol.Storage`, `TCB`) passes **235 distinct declarations**:

- **199 standard-only**: 194 exactly the usual three axioms and five subsets.
- **36 retain existing native arithmetic certificates**, all generated names
  containing `_native.native_decide.ax_`.
- **All 96 new reports are standard-only**: 94 exactly the three and two subsets.
- All 139 retained dependency sets match their preceding reports exactly;
  no selected result uses a cited-bound axiom or `sorryAx`.

| New checked group | Reports | Dependency boundary |
|---|---:|---|
| Actual cochain model / homological-test invariance | 17 | Standard-only. |
| Integral cellular axis family / actual spectrum / lattices | 20 | Standard-only. |
| Concrete semantic realization / positive and negative CVP / weighted encoding | 43 | Standard-only; two elementary coefficient facts use subsets. |
| Generic actual-operator / bound-observation / selected-view adapter | 9 | Standard-only; application profile fields remain explicit. |
| Concrete artifact-bound family / actual spectral gate | 7 | Standard-only; no artifact bindings or hashes are manufactured. |

The example with `b=(1,1)` has two distinct nonzero ambient harmonic targets,
each coefficient one in its own lattice basis. The weighted example uses the
existing integer lattice encryptor with coefficients **2 and 1**, at common
`b=(1,2)`, and proves that no exact function of the selected HCP input recovers
both coefficients. Each actual lattice CVP has a unique answer equal to its
operative target. This is a finite exact-recovery obstruction, not an
asymptotic/distributional privacy theorem.

The semantic model is Mathlib's genuine bounded-below real cochain Quillen
model. The selected nonzero-cohomology tests are proved invariant for all typed
interpretations. Full Helfer first-order syntax/fibrational semantics, a bundled
homotopy quotient, an infinite generated representative family, actual full
storage-view hiding and protocol key delivery remain separate work.

The existing observation adapter derives cellular kernel/projector/message and
CVP agreement from actual operator action and classifier alignment. Original
payload/snapshot/hash/proof contracts remain inputs. Its public-view extension
requires an explicit factorization proof; equality of a class label alone does
not establish equality of a richer record. The computed positive spectral gap
one is connected to the actual spectral gate.

Current local import closures (including each entry) are: `ProximityPrize` 33,
`Protocol.Core` 33, `Storage.Core` 79, `Storage.CanonicalRS` 58,
`Storage.CanonicalSystematic` 70, `Storage.CanonicalThreeLevel` 78,
`Storage.CanonicalCalibration` 76; new entries `Helfer.CochainModel` 8,
`Sheaf.HCPAxisFamily` 8, `HCP.AxisFamily` 19, `TCB.HCPRealization` 23 and
`TCB.HCPAxisFamily` 30. All twelve exclude `Chain` and `CitedBounds`.

### Reproduce the new selected checks

From `lean/`, the example and adapters are in the public `TCB` facade:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build HCP.AxisFamily TCB.HCPAxisFamily \
  Protocol.Core Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples \
  Protocol.Storage.Core Protocol.Storage.Examples Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalRS Protocol.Storage.CanonicalThreeLevel \
  Protocol.Storage.CanonicalCalibration
cat > /tmp/cellular-hcp-new-axioms.lean <<'LEAN'
import TCB

#print axioms Hcrypt.Helfer.CochainModel.boundedContainsZero
#print axioms Hcrypt.Helfer.CochainModel.Data.differential_comp
#print axioms Hcrypt.Helfer.CochainModel.Data.strictlyGE
#print axioms Hcrypt.Helfer.CochainModel.Data.StrictIso.complexIso
#print axioms Hcrypt.Helfer.CochainModel.Data.StrictIso.modelIso
#print axioms Hcrypt.Helfer.CochainModel.module_injective
#print axioms Hcrypt.Helfer.CochainModel.model_isFibrant
#print axioms Hcrypt.Helfer.CochainModel.model_isCofibrant
#print axioms Hcrypt.Helfer.CochainModel.homologyIso
#print axioms Hcrypt.Helfer.CochainModel.closedTestInvariance
#print axioms Hcrypt.Helfer.CochainModel.homotopyEquivalence_of_iso
#print axioms Hcrypt.Helfer.CochainModel.equivalent_of_iso
#print axioms Hcrypt.Helfer.CochainModel.equivalent_refl
#print axioms Hcrypt.Helfer.CochainModel.Data.StrictIso.equivalent
#print axioms Hcrypt.Helfer.CochainModel.ofSheaf
#print axioms Hcrypt.Helfer.CochainModel.strictIso_of_isometricCochainEquiv
#print axioms Hcrypt.Helfer.CochainModel.equivalent_of_isometricCochainEquiv
#print axioms Hcrypt.Sheaf.HCPAxisFamily.delta0_eq_zero
#print axioms Hcrypt.Sheaf.HCPAxisFamily.delta1_adjoint_eq
#print axioms Hcrypt.Sheaf.HCPAxisFamily.degreeOneLaplacian_apply
#print axioms Hcrypt.Sheaf.HCPAxisFamily.harmonic_iff
#print axioms Hcrypt.Sheaf.HCPAxisFamily.standardStalkLattice
#print axioms Hcrypt.Sheaf.HCPAxisFamily.integralStructure
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_observed
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_exactComponent
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_messages_ne
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_noise_orthogonal
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_projection
#print axioms Hcrypt.Sheaf.HCPAxisFamily.laplacianMatrix_mulVec
#print axioms Hcrypt.Sheaf.HCPAxisFamily.laplacianMatrix_eq_diagonal
#print axioms Hcrypt.Sheaf.HCPAxisFamily.axisSwap
#print axioms Hcrypt.Sheaf.HCPAxisFamily.eigenvalue_eq_zero_or_one
#print axioms Hcrypt.Sheaf.HCPAxisFamily.positiveSpectralGap_eq_one
#print axioms Hcrypt.Sheaf.HCPAxisFamily.harmonicLatticePresentation
#print axioms Hcrypt.Sheaf.HCPAxisFamily.harmonicLatticePresentation_point
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_message_eq_point
#print axioms Hcrypt.Sheaf.HCPAxisFamily.sample_eq_encrypt_one
#print axioms Hcrypt.HCP.AxisFamily.semanticEquivalence
#print axioms Hcrypt.HCP.AxisFamily.theory_zero_eq_one
#print axioms Hcrypt.HCP.AxisFamily.publicProjection_laplacian
#print axioms Hcrypt.HCP.AxisFamily.realization
#print axioms Hcrypt.HCP.AxisFamily.operatorAction
#print axioms Hcrypt.HCP.AxisFamily.matrixHarmonicSubspace_eq
#print axioms Hcrypt.HCP.AxisFamily.operativeHarmonicComponent_eq
#print axioms Hcrypt.HCP.AxisFamily.isometricPresentation
#print axioms Hcrypt.HCP.AxisFamily.fixedCoordinateNonstabilization
#print axioms Hcrypt.HCP.AxisFamily.kernelSeparation
#print axioms Hcrypt.HCP.AxisFamily.same_public_class
#print axioms Hcrypt.HCP.AxisFamily.kernel_ambiguous
#print axioms Hcrypt.HCP.AxisFamily.classifier_nonfaithful
#print axioms Hcrypt.HCP.AxisFamily.no_exact_representative_decoder
#print axioms Hcrypt.HCP.AxisFamily.left_target_eq_message
#print axioms Hcrypt.HCP.AxisFamily.right_target_eq_message
#print axioms Hcrypt.HCP.AxisFamily.same_observation_distinct_targets
#print axioms Hcrypt.HCP.AxisFamily.both_targets_nonzero
#print axioms Hcrypt.HCP.AxisFamily.sample_observation_and_exact_component
#print axioms Hcrypt.HCP.AxisFamily.sample_public_observations_eq
#print axioms Hcrypt.HCP.AxisFamily.shared_observation_distinct_nonzero_targets
#print axioms Hcrypt.HCP.AxisFamily.cvp_solution_iff_message
#print axioms Hcrypt.HCP.AxisFamily.cvp_existsUnique
#print axioms Hcrypt.HCP.AxisFamily.cvp_solution_iff_left_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.cvp_solution_iff_right_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.no_exact_public_solver
#print axioms Hcrypt.HCP.AxisFamily.no_sound_and_harmonic_exact_public_solver
#print axioms Hcrypt.HCP.AxisFamily.cvp_oracle_insufficient
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_message
#print axioms Hcrypt.HCP.AxisFamily.weightedOpening_value
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_observed
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_exactComponent
#print axioms Hcrypt.HCP.AxisFamily.weighted_public_observations_eq
#print axioms Hcrypt.HCP.AxisFamily.weighted_coefficients_values
#print axioms Hcrypt.HCP.AxisFamily.weighted_coefficients_ne
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_messages_ne
#print axioms Hcrypt.HCP.AxisFamily.weightedSample_message_ne_zero
#print axioms Hcrypt.HCP.AxisFamily.weighted_target_eq_message
#print axioms Hcrypt.HCP.AxisFamily.weighted_same_observation_distinct_targets
#print axioms Hcrypt.HCP.AxisFamily.weighted_both_targets_nonzero
#print axioms Hcrypt.HCP.AxisFamily.weighted_cvp_solution_iff_operativeTarget
#print axioms Hcrypt.HCP.AxisFamily.weighted_cvp_existsUnique
#print axioms Hcrypt.HCP.AxisFamily.no_exact_encoded_message_decoder
#print axioms Hcrypt.TCB.HCPRealization.CellularOperatorAlignment
#print axioms Hcrypt.TCB.HCPRealization.CellularOperatorAlignment.matrixHarmonicSubspace_eq
#print axioms Hcrypt.TCB.HCPRealization.CellularOperatorAlignment.operativeHarmonicComponent_eq
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.hiddenWitness
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.operativeTarget_eq_projection
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.operativeTarget_eq_message
#print axioms Hcrypt.TCB.HCPRealization.BoundObservationAlignment.cvp_solution_iff_operativeTarget
#print axioms Hcrypt.TCB.HCPRealization.no_exact_view_solver_of_factorization
#print axioms Hcrypt.TCB.HCPAxisFamily.operatorAlignment
#print axioms Hcrypt.TCB.HCPAxisFamily.actualSpectralGate
#print axioms Hcrypt.TCB.HCPAxisFamily.observationAlignment
#print axioms Hcrypt.TCB.HCPAxisFamily.bindSample
#print axioms Hcrypt.TCB.HCPAxisFamily.bindSample_artifact
#print axioms Hcrypt.TCB.HCPAxisFamily.operativeTarget_eq_original_message
#print axioms Hcrypt.TCB.HCPAxisFamily.cvp_solution_iff_operativeTarget
LEAN
LEAN_NUM_THREADS=2 lake env lean /tmp/cellular-hcp-new-axioms.lean
```

The 139-declaration probe in the preserved native-metric section below supplies
the retained selection. The fresh combined 235-report probe uses the union of
these declarations and the four public facades named above. This follow-up
supersedes the preceding inventory/build snapshot without changing its earlier
record. The final Paper 1 PDF has **99 pages**. Its final TeX pass has no LaTeX
warnings, undefined references/citations, missing glyphs or overfull boxes.
Eight underfull-box diagnostics remain without a visible layout defect. All
99 pages were rendered and visually inspected; pages 21--23, 87 and 94--95
were also checked at higher resolution. Paper 3 is unchanged at 28 pages and
retains its preceding visual review. Both canonical PDFs match their stable
review exports bytewise. The local `cellular-hcp-pdf-qa.json` records the check;
the preceding 97-page Paper 1 export is preserved under
`output/pdf/baselines/2026-11-06-pre-cellular-hcp/`.

- Current Paper 1 SHA-256: `beb20f8c4a67ef4afcd0bfe950cfb444cfaf38b9abba1c3150fa0c2a3930a213`.
- Unchanged Paper 3 SHA-256: `61d7589a75b48bc877c768df0795059220af7fc921ed6f681e8e5b391a8ab9e7`.

## Native-metric baseline — 2026-11-05

The twenty-module mathematics follow-up is complete for the declared native
modular source profile. The full union of all fifteen default roots and the
explicit transition/storage/native-application targets passes **9,253 jobs**;
the literal default `lake build` passes **9,248 jobs**. Both use
`LEAN_NUM_THREADS=4` and the unchanged Lean/Mathlib 4.35 pin.

The current source inventory has **235 Lean files**, including the Lake
configuration, and **234 source modules** with public-module interfaces.
A comment-aware scan finds no active `sorry`/`admit`/`sorryAx`, no unresolved
local imports or cycles, and the same seven explicitly declared cited-bound
axioms. Every Lean file is within 10,000 lines; the largest is
`Hardness.lean`, 1,038 lines. These are source checks, not theorem-dependency
claims.

The **fresh consolidated public-facade probe passes 139 distinct reports**.
It reproduces every individual group exactly: **103 standard-only** (100 use
exactly the usual three axioms; three use a subset), and **36 with existing
native arithmetic certificates**. Every extra dependency in those 36 names
contains `_native.native_decide.ax_`; none is a cited-bound axiom or `sorryAx`.
The arithmetic trust comes from existing concrete modulus/root certificates;
no new `native_decide` certificate or project axiom is introduced by this
follow-up. Explicit theorem/profile assumptions remain part of every result.

After the full runs, final review added two module-introduction qualifiers
only: the constant-one vector in affine-lift spanning and the RS degree bound
at least two in the decoder obstruction. Statements and proofs are unchanged.
The two affected modules pass a focused rebuild (3,338 jobs), and the complete
static source inventory was refreshed for those final bytes.

| Selected group | Reports | Standard-only | Existing native certificates |
|---|---:|---:|---:|
| `plucker-reconstruction` | 8 | 8 | 0 |
| `q08-canonical-lift` | 13 | 13 | 0 |
| `q08-systematic` | 6 | 6 | 0 |
| `q08-modular-coboundary` | 8 | 8 | 0 |
| `q08-zero-direction` | 11 | 11 | 0 |
| `q08-diagonal-mca` | 11 | 11 | 0 |
| `q08-root-generic` | 27 | 27 | 0 |
| `q08-native-chain` | 11 | 11 | 0 |
| `q08-metric-sharpness` | 4 | 4 | 0 |
| `q08-canonical-systematic` | 15 | 0 | 15 |
| `q08-canonical-three-level` | 16 | 0 | 16 |
| `q08-canonical-calibration` | 9 | 4 | 5 |

The results concern distinct claims:

- Full genuine Plucker data reconstruct the subspace and fixed-metric harmonic
  projector; identification with the operative kernel gives mathematical
  target recovery, without a finite-encoding efficiency or digest claim.
- Actual integral cellular coboundary congruence is proved equivalent to RS
  validity. Native cochain, integer-plane and RS distances satisfy
  `d_C ≤ d_P = D_RS ≤ 2d_C`; the near factor two is sharp.
- The original canonical payload has all three native distances `3/4`.
  The canonical mix is good for that diagonal family, whose sole bad challenge
  is `-1`, with exact fraction `1/12289`.
- A capacity-far counterfamily refutes uniform positive far preservation by
  an arbitrary fixed nonzero scalar challenge.
- The separate Euclidean no-wrap comparison is a coarse first-shell theorem.
  Canonical-lift spanning obstructs an unrestricted zero-additive-loss
  Euclidean comparison for a nontrivial linear decoder.
- Raw positive-far contexts are proximity/rejection inputs. Accepted exact
  contexts have zero native distance under the stated decoder contract.
  No nonempty accepted-far gate, full legacy frame-chain instance, new
  commitment security game or consensus finality is constructed.

Current local import closures, including their entry modules:

| Entry | Modules | Boundary |
|---|---:|---|
| `ProximityPrize` | 33 | No `Chain` or `CitedBounds`. |
| `Protocol.Core` | 33 | Same conservative kernel boundary. |
| `Protocol.Storage.Core` | 79 | Generic context/codec/anchor layer. |
| `Protocol.Storage.CanonicalRS` | 58 | Existing optional public-observation adapter. |
| `Protocol.Storage.CanonicalSystematic` | 70 | Explicit no-wrap source profile. |
| `Protocol.Storage.CanonicalThreeLevel` | 78 | Native canonical payload/capacity/challenge results. |
| `Protocol.Storage.CanonicalCalibration` | 76 | Composable far and scaled-near contracts. |

All seven closures exclude `Chain` and `CitedBounds`. Source imports do not
imply that every imported declaration was axiom-audited. The earlier
9,233/9,228/68-result record below is retained as the pre-addition 4.35
baseline, followed by the older 4.24 milestones.

### Native-metric manuscript baseline

Paper 1's 97-page PDF and Paper 3's 28-page PDF both pass their final TeX
runs without undefined references/citations, missing glyphs or overfull boxes.
All 125 pages were rendered and inspected; changed pages received additional
high-resolution review. Underfull-box diagnostics remain (eight and two
respectively), without a visible layout defect. Canonical and stable review
copies match bytewise:

- Paper 1: `40f84530a5b0e95131c71189a9303b3e2ae0005ec4b9bcfead50846f22f6d46f`.
- Paper 3: `61d7589a75b48bc877c768df0795059220af7fc921ed6f681e8e5b391a8ab9e7`.

Paper 1 records full Plucker recovery with its kernel/visibility qualifications;
Paper 3 records the constructed modular profile, native metric theorem,
capacity family and obstruction boundaries. Paper 2's initial manuscript
records shared source and observation contracts, without a TeX/PDF bundle.

### Reproduce the current checks

From `lean/`:

```sh
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Core Protocol.Ledger.Examples \
  Protocol.Ledger.EvidenceExamples Protocol.Storage.Core \
  Protocol.Storage.Examples Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalRS Protocol.Storage.CanonicalThreeLevel \
  Protocol.Storage.CanonicalCalibration
```

The combined probe imports the public facades used by reviewers, rather than
relying on a private proof-body traversal. Its selected declarations are:

```sh
cat > /tmp/native-metrics-axioms.lean <<'LEAN'
import ProximityPrize
import Sheaf
import Protocol.Storage
import TCB.PluckerObservation

#print axioms Hcrypt.Protocol.Storage.Calibration.decodedDistance_le_norm
#print axioms Hcrypt.Protocol.Storage.Calibration.decodedDistance_le_scaled_pairDistance_of_reflection
#print axioms Hcrypt.Protocol.Storage.Calibration.decodedFar_implies_pairFar_of_reflection
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.calibrationFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.calibration_extract_eq_original_pair
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.cochainToPlaneFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.evaluationProjectionFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.extracted_codeword_of_modular_valid
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.planeNear_of_scaledSourceNear
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.planeToRSFor
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.sourceFar_implies_planeFar
#print axioms Hcrypt.Protocol.Storage.CanonicalCalibration.sourceFar_implies_rsFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.accepted_iff_pairCodeword
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.exactDistance_eq_harmonicProjection_norm
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.exists_positive_source_payload
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.harmonicOneSubspace_eq_exactOrthogonal
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.informationSet_card
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.model
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.observed_decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.raw_payload
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_context_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_context_sourceDistance_pos
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_noWrap
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_not_exact
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_sourceDistance_pos
#print axioms Hcrypt.Protocol.Storage.CanonicalSystematic.unitPayload_wellFormed
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.accepted_nativeDistances_zero
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.canonicalMix_ne_neg_one
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_badChallengeFraction
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_badChallenges
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_canonicalMix_good
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_canonicalMix_scalarDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_cochainDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_planeDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_rsPairDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.capacityPayload_wellFormed
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.cochainFar_implies_observed_pairFar
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.exists_payload_at_capacity
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.native_distance_comparison
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.not_accepted_of_positive_cochainFar
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.observed_planeDistance_eq_pairDistance
#print axioms Hcrypt.Protocol.Storage.CanonicalThreeLevel.observed_planeDistance_eq_publicSourceDistance
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.aligned
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.coordinateCount
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.decode_coordinate
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.locallyNondegenerate
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.norm_decode_le
#print axioms Hcrypt.Protocol.Storage.CoordinateLayout.norm_decode_sq_le
#print axioms Hcrypt.Protocol.Storage.SystematicModel.accepted_of_pairCodeword
#print axioms Hcrypt.Protocol.Storage.SystematicModel.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.flatDistance_eq_rsFlatDistance
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerPairCode_codeword_iff_modularExact
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerPairCode_codeword_iff_reduced
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerScalarCode_codeword_iff
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.integerScalarCode_nonempty
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.liftMatching_hamming
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.liftMatching_pair_eq_iff
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.planeDistance_eq_rsDistance
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.reduce_liftMatching
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.reduced_hamming_le
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.scalar_reduction_distance_eq
#print axioms Hcrypt.Protocol.Storage.ThreeLevel.three_native_distance_comparison
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.harmonicProjector_eq_of_publicShadow_eq
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.projectiveFramedSystem_sound
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.projectiveSoundInputs
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.publicShadow_eq_iff_same_point
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverHarmonicProjector_frame
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_frame
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.recoverSubspace_zero
#print axioms Hcrypt.Proximity.GrassmannianPlucker.Concrete.toLaplacian_eq_of_publicShadow_eq
#print axioms Hcrypt.Sheaf.CellularSheaf.all_linear_decodes_exact_of_canonical_interleaved_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.all_linear_decodes_exact_of_canonical_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.exactOneSubspace_eq_top_of_surjective_canonical_rs_decoder
#print axioms Hcrypt.Sheaf.CellularSheaf.linear_decode_exactDistance_eq_zero_of_canonical_interleaved_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.linear_decode_exactDistance_eq_zero_of_canonical_rs_lifts
#print axioms Hcrypt.Sheaf.CellularSheaf.not_all_canonical_interleaved_rs_lifts_exact_of_nonexact_linear_decode
#print axioms Hcrypt.Sheaf.CellularSheaf.not_all_canonical_rs_lifts_exact_of_nonexact_linear_decode
#print axioms Hcrypt.Sheaf.CellularSheaf.not_uniform_rs_distance_comparison_of_nonexact_linear_decode
#print axioms Hcrypt.Sheaf.SystematicCode.delta0_integralOpening_coordinate
#print axioms Hcrypt.Sheaf.SystematicCode.intCast_integerCoboundary
#print axioms Hcrypt.Sheaf.SystematicCode.integralOpening_head
#print axioms Hcrypt.Sheaf.SystematicCode.integralOpening_tail
#print axioms Hcrypt.Sheaf.SystematicCode.isExact_iff_realCheck_eq_zero
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_iff_integerCoboundary_residue
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_iff_vectorCodeword
#print axioms Hcrypt.Sheaf.SystematicCode.modularExact_of_vectorCodeword
#print axioms Hcrypt.Sheaf.SystematicCode.ofWord_isExact_of_vectorCodeword_of_noWrap
#print axioms Hcrypt.Sheaf.SystematicCode.vectorCodeword_of_modularExact
#print axioms Hcrypt.TCB.PluckerObservation.operativeHarmonicComponent_eq_of_same_full_shadow
#print axioms Hcrypt.TCB.PluckerObservation.recover_eq_operativeHarmonicComponent
#print axioms ProximityPrize.AffineLine.point_eq_base_of_direction_eq_zero
#print axioms ProximityPrize.AffineLine.point_eq_scale_of_diagonal
#print axioms ProximityPrize.AffineLine.point_neg_one_eq_zero_of_diagonal
#print axioms ProximityPrize.BlockCode.badChallengeSetAt_eq_empty_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.badChallengeSet_eq_empty_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.flattenedPairCode_distance_comparison
#print axioms ProximityPrize.BlockCode.hammingDistanceToCode_pairWord_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.hammingDistance_pairWord_of_directions_eq_zero
#print axioms ProximityPrize.BlockCode.not_badOnSet_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.not_mem_badChallengeSetAt_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.not_mem_badChallengeSet_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.one_le_length_mul_relativeDistanceToCode_of_not_codeword
#print axioms ProximityPrize.BlockCode.pairCloseOnSet_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.pairDistance_eq_scalarDistance_at_every_challenge_of_direction_eq_zero
#print axioms ProximityPrize.BlockCode.pairFar_of_flatFar
#print axioms ProximityPrize.BlockCode.relativeDistanceToCode_pairWord_of_direction_eq_zero
#print axioms ProximityPrize.CanonicalLift.eq_top_of_contains_affine_lifts
#print axioms ProximityPrize.CanonicalLift.eq_top_of_contains_interleaved_rs_lifts
#print axioms ProximityPrize.CanonicalLift.eq_top_of_contains_rs_lifts
#print axioms ProximityPrize.CanonicalLift.lift_apply
#print axioms ProximityPrize.CanonicalLift.wrap_coordinate_identity
#print axioms ProximityPrize.FAdditiveCode.badChallengeSetAt_eq_singleton_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.badChallengeSet_eq_singleton_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.badOnSet_neg_one_univ_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.challengeFraction_badChallengeSetAt_eq_of_diagonal
#print axioms ProximityPrize.FAdditiveCode.not_badOnSet_of_diagonal_of_noncancelling
#print axioms ProximityPrize.FAdditiveCode.not_mem_badChallengeSetAt_of_diagonal_of_ne_neg_one
#print axioms ProximityPrize.FAdditiveCode.not_mem_badChallengeSetAt_of_diagonal_of_noncancelling
#print axioms ProximityPrize.FAdditiveCode.not_mem_badChallengeSet_of_diagonal_of_noncancelling
#print axioms ProximityPrize.FAdditiveCode.pairCloseOnSet_of_diagonal_of_noncancelling
#print axioms ProximityPrize.ReedSolomon.Parameters.codeword_iff_systematicCheck_eq_zero
#print axioms ProximityPrize.ReedSolomon.Parameters.diagonalPowerPair_fold_distance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.diagonalPowerPair_relativeDistanceToCode_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.fixedCancellingLine_flatDistance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.fixedCancellingLine_pairDistance_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.fixedCancellingLine_scalarDistance_eq_zero
#print axioms ProximityPrize.ReedSolomon.Parameters.flat_diagonalPowerPair_relativeDistanceToCode_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.integerCheck_eq_zero_of_codeword_of_noWrap
#print axioms ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_flat_far_preservation
#print axioms ProximityPrize.ReedSolomon.Parameters.no_fixedChallenge_pair_far_preservation
#print axioms ProximityPrize.ReedSolomon.Parameters.no_unit_pair_distance_bound_by_flat_distance
#print axioms ProximityPrize.ReedSolomon.Parameters.realCheck_components_eq_zero_of_vectorCodeword_of_noWrap
#print axioms ProximityPrize.ReedSolomon.Parameters.scaledPowerWord_hammingDistanceToCode_eq_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.single_outside_noWrap_nonzero
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_flatDistance_eq_half_capacity
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_not_pairDistance_le_flatDistance
#print axioms ProximityPrize.ReedSolomon.Parameters.zeroDirectionPowerLine_pairDistance_eq_capacity
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/native-metrics-axioms.lean
```

## Completed pre-addition Lean 4.35 record

The main repository pins Lean `v4.35.0` and Mathlib
`56a005855ea17e0b0958f73ec801ae140b0a1679`. All nine dependency checkouts
match the manifest. The full union of all fifteen default targets and the
explicit ledger/evidence/storage integration targets passed with
`LEAN_NUM_THREADS=4` (**9,233 jobs**, 2026-11-05).
The subsequent literal default `lake build` also passed (**9,228 jobs**).
All three fresh probes passed on this pin: **68 distinct declarations**, with
64 using exactly `propext`, `Classical.choice` and `Quot.sound`, and the same
four boundary/canonical endpoints retaining native arithmetic dependencies.
The forty-endpoint group has 36 standard-only reports; all nineteen anchor
and nine HCP/CVP reports are standard-only. None uses any of the seven
cited-bound axioms or `sorryAx`. Explicit theorem/profile hypotheses remain.

On Lean 4.35, the native dependencies print as generated constants with names
containing `_native.native_decide.ax_`, including the modulus-primality and
root-order certificates. The older `Lean.ofReduceBool`/`Lean.trustCompiler`
names below describe the preserved 4.24 reports. The new names do not remove
native trust or make these four endpoints eligible for a three-axiom-only
submission.

## Preserved Lean 4.24 mathematics/storage baseline

Validated 2026-11-05 on Lean 4.24.0. The focused mathematics/storage module build passed
(7,447 jobs). `Proximity.Application.GapBoundary` also passed its module build.
The expanded full default build passed (7,530 jobs). The **fresh forty-endpoint
axiom report passed**, with exit status zero and exactly forty distinct
declaration reports: 36 standard-only and four with the existing native
arithmetic dependencies listed below. None contains a project cited-bound
axiom or `sorryAx`. The [shared parity register](../SEMANTIC-PARITY.md)
records the remaining source-profile and manuscript obligations separately.

The comment-aware source scan now covers 215 Lean files including the Lake
configuration: no active `sorry`/`admit`, seven project axioms in the existing
concrete cited-bound module, and no local import cycles.

A source scan for `sorry`/`admit`, custom axiom declarations or import cycles
answers source questions. A successful build checks the declared statements
under their actual hypotheses. Neither substitutes for checking that those
statements express the manuscript claim. `#print axioms` lists global logical
and evaluation dependencies; ordinary theorem arguments and supplied profile,
verification, decoding or persistence hypotheses still need statement review.

## Reproduce the builds

Use the pinned `lean/lean-toolchain`, `lakefile.lean` and `lake-manifest.json`.
From the repository root:

```sh
cd lean
lake exe cache get
LEAN_NUM_THREADS=4 lake build
LEAN_NUM_THREADS=4 lake build Protocol.Core Protocol.Ledger.Examples \
  Protocol.Ledger.EvidenceExamples Protocol.Storage.Core \
  Protocol.Storage.Examples Protocol.Storage.AnchorExamples \
  Protocol.Storage.CanonicalRS
```

The full union was checked in one invocation with the same four-thread
setting. The commands above also expose the default/integration checks
separately. Hosted CI is a separate run.

Static local source import closures, including the entry module and excluding
Mathlib/dependency modules, were inspected as follows:

| Entry point | Local modules | Source import boundary |
|---|---:|---|
| `ProximityPrize` | 25 | No project `CitedBounds` module or legacy `Chain`. |
| `Protocol.Core` | 33 | No project `CitedBounds` module or legacy `Chain`. |
| `Protocol.Storage.Core` | 77 | Includes the new history/projection anchor and bounded transition dependencies; no project `CitedBounds` module or legacy `Chain`. |
| `Protocol.Storage.CanonicalRS` | 58 | Optional concrete application; no project `CitedBounds` module or legacy `Chain`. Native arithmetic dependencies remain a separate question. |

These counts describe the current source graph, not a theorem-axiom result.
They do not mean every imported theorem was audited.

## History-anchor follow-up

The new `Protocol.Storage.Anchor`, `ProjectionAnchor` and `AnchorExamples`
focused build passed (7,417 jobs), with `LEAN_NUM_THREADS=1` and unchanged
pins. This result is separate from the earlier 7,447-job mathematics/storage
milestone and forty-endpoint report. The full aggregate passed (7,532 jobs),
and the new nineteen-endpoint probe passed: each report contains exactly the
three standard Lean axioms, with no native trust, project axiom or `sorryAx`.
These are the pre-upgrade Lean 4.24.0/Mathlib-pin results preserved before the
user-authorized main-toolchain update; they do not certify the newer pin.

The source scan and import-closure table above include the three new files.
`Protocol.Core` and `ProximityPrize` retain their earlier focused boundaries;
the optional `CanonicalRS` entry does not acquire the new anchor imports.

Reproduce the new checks from `lean/`:

```sh
LEAN_NUM_THREADS=1 lake build Protocol.Storage.Anchor \
  Protocol.Storage.ProjectionAnchor Protocol.Storage.AnchorExamples
LEAN_NUM_THREADS=1 lake build
```

The separate anchor probe checks nineteen endpoints. It retains the explicit
history/gate inclusion, snapshot interpretation, verifier and backend
hypotheses; a short logical-axiom list does not instantiate those profiles.

```sh
cat > /tmp/hcrypt-anchor-axioms.lean <<'LEAN'
import Protocol.Storage.Core
import Protocol.Storage.AnchorExamples

#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.accepted
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.snapshot_root_matches
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.cochain_included
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.manifest_anchored
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.decodedDistance_eq_zero
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.quorum_manifest_anchored
#print axioms Hcrypt.Protocol.Storage.TransitionAnchor.quorum_snapshot_matches
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.word_matches_candidate
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.exact_prefix_anchored
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.gate_database_included
#print axioms Hcrypt.Protocol.Storage.ProjectionAnchor.target_far
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.anchored_update
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.anchored_positive_value
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.quorum_anchors_same_manifest
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.quorum_names_same_snapshot
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.anchored_manifest_persisted
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.other_run_rejected
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.other_snapshot_rejected
#print axioms Hcrypt.Protocol.Storage.AnchorExamples.raw_persisted_but_not_anchorable
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/hcrypt-anchor-axioms.lean
```

## Read the dependency report

Keep these trust boundaries separate:

- `propext`, `Classical.choice` and `Quot.sound` are the usual Lean logical
  dependencies. Their presence does not discharge a theorem's explicit inputs.
- Existing `native_decide` arithmetic certificates add native-evaluation
  dependencies: generated `_native.native_decide.ax_` constants on 4.35,
  or `Lean.ofReduceBool`/`Lean.trustCompiler` in the old report. Record
  which endpoints actually print them, particularly at the boundary and
  canonical finite-field instances.
- The seven project axioms in
  [CitedBounds](../lean/Proximity/Concrete/CanonicalRS/CitedBounds.lean) are a
  distinct literature-bound trust boundary, including numerical witness
  constants. A module build alone neither proves those assumptions nor says
  whether a selected theorem uses them.

An `Axioms/` interface can instead be a structure of explicit hypotheses;
its directory name does not make those fields global Lean `axiom`
declarations. Conversely, a short axiom list does not establish cryptographic
security, a concrete codec/lift instance, disk durability or physical erasure.

The probe contains exactly forty distinct declarations:

| Group | Endpoints |
|---|---:|
| Q04 actual fields, subgroups and realized family bounds | 5 |
| Q05/Q06 grid and real-radius conclusions | 4 |
| Q07 minimum distance, good-challenge farness and covering endpoint | 3 |
| Concrete/legacy semantics and full-HCP obstruction | 4 |
| Context/HCP identity and local checkpoint lifecycle | 5 |
| Granular projection and controlled exact lifts | 6 |
| Optional canonical artifact/pair comparison | 3 |
| Concrete positive and rejection fixtures | 6 |
| D03 overlap, solver consistency and strict-gap view | 4 |

## Reproduce the forty-endpoint probe

Run this block from `lean/`, after the focused build. It writes only a scratch
file under `/tmp`; it changes no source file. A valid report requires exit
status zero and one dependency report for each of the forty commands, with
no unknown declarations or elaboration errors.

```sh
cat > /tmp/math-storage-axiom-audit.lean <<'LEAN'
import ProximityPrize
import Sheaf.ObservationQuotient
import Protocol.Storage.Core
import Protocol.Storage.Examples
import Protocol.Storage.CanonicalRS
import Proximity.Application.GapBoundary

/- Representative new endpoints only. Importing a module is not itself an
axiom audit. Check every report below, including native-arithmetic trust at
the boundary/canonical field instances; do not infer standard-only results
before this file has actually run successfully. -/

-- Q04: actual finite fields, power domains and realized family bounds (5).
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.length_dvd_fieldCard_sub_one
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.card_RSField
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.rootUnit_order
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_fractionalListSizeBoundAt_capacity
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_pairMCAErrorBoundAt

-- Q05 and Q06: exact grid/real-radius packaging (4).
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListPhaseSplit
#print axioms ProximityPrize.ReedSolomon.Parameters.vectorFractionalListRealThreshold
#print axioms ProximityPrize.Capacity.SmoothQuarterFamily.realized_listRealThreshold
#print axioms ProximityPrize.MCA.BoundaryField.pairMCA_real_128_threshold

-- Q07: attained minimum, correct good-challenge boundary and covering endpoint (3).
#print axioms ProximityPrize.BlockCode.closeAt_iff_relativeDistanceToCode_le
#print axioms ProximityPrize.BlockCode.scalarDistance_ge_of_pairDistance_ge_of_good
#print axioms ProximityPrize.ReedSolomon.Parameters.scalarDistance_eq_capacity_of_pairFar_of_good

-- Concrete/legacy semantics and the full-HCP information-loss obstruction (4).
#print axioms Hcrypt.Sheaf.CellularSheaf.CochainSemantics.accepted_iff
#print axioms Hcrypt.Sheaf.CellularSheaf.CochainPayloadInterpretation.identitySemantics
#print axioms Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_residual_norm_factors_exactComponent
#print axioms Hcrypt.Sheaf.CellularSheaf.HodgeEncryptedCochain.not_far_preserving_exactComponent

-- Context identity, exact acceptance and local manifest lifecycle (5).
#print axioms Hcrypt.Protocol.Storage.Context.accepted_iff_decodedDistance_eq_zero
#print axioms Hcrypt.Protocol.Storage.ofHCPObservation_decodedDistance
#print axioms Hcrypt.Protocol.Storage.OpenManifest.entry_eq_of_slot_eq
#print axioms Hcrypt.Protocol.Storage.Checkpoint.persisted_of_step_from_sealed
#print axioms Hcrypt.Protocol.Storage.Checkpoint.consumed_terminal

-- Granular original projection states and controlled exact-lift comparison (6).
#print axioms Hcrypt.Protocol.Storage.Projection.Prefix.items_append_of_step
#print axioms Hcrypt.Protocol.Storage.Projection.SealedProjection.certifiedStateBus
#print axioms Hcrypt.Protocol.Storage.Projection.SealedProjection.target_far
#print axioms Hcrypt.Protocol.Storage.Calibration.LiftControl.decodedFar_implies_pairFar
#print axioms Hcrypt.Protocol.Storage.Calibration.LiftControl.accepted_of_pairCodeword
#print axioms Hcrypt.Protocol.Storage.Calibration.no_liftControl_of_nonexact_codeword

-- Optional canonical application: actual artifact, pair and geometric bound (3).
#print axioms Hcrypt.Protocol.Storage.CanonicalRS.pairDistance_eq_generic
#print axioms Hcrypt.Protocol.Storage.CanonicalRS.Observation.extractedPair_matches
#print axioms Hcrypt.Protocol.Storage.CanonicalRS.Observation.decodedFar_implies_pairFar

-- Concrete nonexact input, accepted zero and object-indexed storage fixtures (6).
#print axioms Hcrypt.Protocol.Storage.Examples.raw_decodedDistance_pos
#print axioms Hcrypt.Protocol.Storage.Examples.zero_accepted
#print axioms Hcrypt.Protocol.Storage.Examples.complete_execution
#print axioms Hcrypt.Protocol.Storage.Examples.changed_run_receipt_rejected
#print axioms Hcrypt.Protocol.Storage.Examples.payload_transplant_rejected
#print axioms Hcrypt.Protocol.Storage.Examples.second_consumption_rejected

-- D03: overlap, solver inconsistency and unchanged-object strict-gap view (4).
#print axioms Hcrypt.Proximity.GapProximityProblem.near_and_far_iff
#print axioms Hcrypt.Proximity.GapProximityProblem.not_exists_correctSolver_of_boundary_attained
#print axioms Hcrypt.Proximity.GapProximityProblem.exists_correctSolver_iff_promisesDisjoint
#print axioms Hcrypt.Proximity.SeparatedGapProblem.promisesDisjoint
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/math-storage-axiom-audit.lean
```

Fresh report outcome: **passed**, with the following dependency classes:

| Dependency class | Endpoints |
|---|---:|
| Exactly `propext`, `Classical.choice`, `Quot.sound` | 36 |
| Those three plus generated native certificate axioms on 4.35 (native compiler trust on 4.24) | 4 |
| Project cited-bound axiom or `sorryAx` | 0 |

The four native-arithmetic endpoints are:

- `ProximityPrize.MCA.BoundaryField.pairMCA_real_128_threshold`.
- `Hcrypt.Protocol.Storage.CanonicalRS.pairDistance_eq_generic`.
- `Hcrypt.Protocol.Storage.CanonicalRS.Observation.extractedPair_matches`.
- `Hcrypt.Protocol.Storage.CanonicalRS.Observation.decodedFar_implies_pairFar`.

All selected generic-family, semantic-transport, HCP-obstruction, storage-core,
fixture and gap-boundary endpoints are in the standard-only class. This is
an audit of the forty listed declarations, not every theorem in the project;
their explicit profile, codec, gate and persistence hypotheses remain.

## Reproduce the HCP/CVP port probe

These nine additional declarations cover the central projection, explicit
coordinate transport, separation and lattice-solution bridges touched by the
4.35 port. All nine fresh reports contain exactly the three standard axioms.
The coordinate conversions retain the Euclidean carriers and existing CVP
squared distance; they introduce no source-radius or authentication profile.

From `lean/`:

```sh
cat > /tmp/hcrypt-hcp-axioms.lean <<'LEAN'
import Hardness

#print axioms Hcrypt.HCP.decrypt_eq_orthogonalProjection
#print axioms Hcrypt.HCPBridge.IsometricPresentationEquivalence.harmonic_iff_transport
#print axioms Hcrypt.HCPBridge.IsometricPresentationEquivalence.operativeHarmonicComponent_naturality
#print axioms Hcrypt.HCPBridge.operativeTargets_ne_of_kernelSeparation
#print axioms Hcrypt.HCPBridge.no_solver_exactOnOperativeTarget_of_kernelSeparation
#print axioms Hcrypt.HCPBridge.cvpOracle_insufficient_for_operativeTarget
#print axioms HarmonicCVPBridge.solution_iff_projectedTarget
#print axioms concreteSheafHCP_CVP_solution_iff_message
#print axioms concreteSheafHCP_CVP_existsUnique
LEAN
LEAN_NUM_THREADS=1 lake env lean /tmp/hcrypt-hcp-axioms.lean
```

The [storage guide](../lean/Protocol/Storage/README.md) explains the preserved
objects, distinct roots, three distance meanings and local/runtime boundary.
The [shared parity register](../SEMANTIC-PARITY.md) and
[Paper 3 register](../papers/proximity-prize/SEMANTIC_PARITY.md) retain the
separate profile, radius, scope and novelty obligations.
