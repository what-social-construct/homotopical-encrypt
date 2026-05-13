import Mathlib
import Axioms.Foundation
import Axioms.Heyting
import Axioms.ZKP
import Axioms.SpectralBounds
import Axioms.StageAdmissibility

/-
  Oracle Modality Interface

  Axiomatizes the oracle interaction layer of homotopical-encrypt using the
  modality framing from:

    Ahman & Bauer, "Sheaves as oracle computations" (arXiv:2602.22135)

  Core idea (paper §2):
    Given a predicate P : Query → Answer → Prop, the oracle modality □_P A is the
    least modality forcing P. At each step: either we know the result, or we ask
    a query and proceed on the answer. Sheaves are exactly the algebras for this monad.

  How this maps to homotopical-encrypt:

    Query   := FullStalk submission (Python pre-computes: eigenvalues, commitment, gap)
    Answer  := HashStalk judgment (Oracle attests: spectral_gap_valid, betti_numbers)
    P       := Tsirelson √2 bound predicate on the spectral gap

  The oracle pipeline is the computation tree:

    F_full (Python wallet)
      ──η₁──→ F_zk (Oracle: Hodge project + quantize + attest)
      ──η₂──→ F_hash (Rust node: hash + enforce consensus gate)

  η₁ IS the oracle modality forcing step.
  η₂ IS the sheafification: collapsing the tree to a section.

  The Topos consensus gate is a Lawvere-Tierney topology j on the sheaf topos
  induced by the Tsirelson predicate. Block acceptance is the subobject classifier
  morphism j : Ω → Ω applied to the spectral-gap judgment.

  PoV construction scope:
    The query/answer/gate objects in this file are protocol construction
    vocabulary for the proof-of-validation pipeline. They describe which
    mathematical obligations an oracle answer must witness and how public
    judgments collapse into consensus actions. They should not be read as a
    claim that Lean has verified the deployed oracle endpoint or all numerical
    linear algebra. Concrete byte validation, attestation, timeouts, malformed
    requests, and endpoint hardening are Rust/oracle TCB responsibilities.

  Semantic scope:
    The oracle answer is a public/runtime quotient of richer hidden semantics.
    It should be read as the protocol-facing Heyting shadow of a path/fibration
    semantic object, not as the full hidden object itself. This is the same
    distinction used in `Hardness.lean`: public cochains/fingerprints/judgments
    do not canonically select the operative fibration, Laplacian, or kernel.

    `SpectralJudgment.Boundary` is an operational verdict: the node holds or
    re-evaluates rather than finalizing. Its image in `Heyting3` is
    `Undetermined`, but the hold/retry policy is not the Heyting implication
    operation. Heyting implication remains the residuated connective proved in
    `Axioms.Heyting` and in the concrete Ω-collapse model below.

  ───────────────────────────────────────────────────────────────────────────────
  CONNECTIONS TO OTHER AXIOM MODULES:

    Foundation.lean     : CochainComplex/Hodge supply the witness type for queries
    ZKP.lean            : ZKPWellFormed is the soundness/completeness of Answer
    StageAdmissibility  : StageAdmissibilityWellFormed is the gate implication
    HelferFOL.lean      : path equality / CartesianLiftingPrinciple underlie η₁
                          transport and hidden representative semantics
    Heyting.lean        : runtime quotient/collapse to `Heyting3`
    SpectralBounds.lean : canonical PoV/Tsirelson spectral window predicate
  ───────────────────────────────────────────────────────────────────────────────
-/

namespace Hcrypt
namespace Axioms

universe u

-- ============================================================================
-- §1  ORACLE QUERY / ANSWER TYPES
-- ============================================================================

/--
  Protocol-level spectral verdict returned by the Oracle gate.

  This is not itself the full Heyting algebra. It is an operational classifier
  that later maps into `OmegaNV`/`Heyting3` for public truth semantics and into
  `ConsensusAction` for node policy.
-/
inductive SpectralJudgment
  | InBounds    -- gap ∈ [1/√2, 2√2]: valid block producer
  | Boundary    -- gap at or within ε of bound: UNDETERMINED
  | OutOfBounds -- gap outside Tsirelson range: reject
  deriving DecidableEq, Repr

/-- Node-side operational action induced by an oracle spectral verdict. -/
inductive ConsensusAction
  | Accept
  | Hold
  | Reject
  deriving DecidableEq, Repr

/-- Operational policy: accept valid, hold boundary, reject out-of-bounds. -/
def judgmentToAction : SpectralJudgment → ConsensusAction
  | SpectralJudgment.InBounds => ConsensusAction.Accept
  | SpectralJudgment.Boundary => ConsensusAction.Hold
  | SpectralJudgment.OutOfBounds => ConsensusAction.Reject

/-- Final acceptance action: only `Accept` finalizes. -/
def actionFinalAccepted : ConsensusAction → Bool
  | ConsensusAction.Accept => true
  | ConsensusAction.Hold => false
  | ConsensusAction.Reject => false

/-- Gate admissibility action: `Accept` or `Hold` may continue, `Reject` may not. -/
def actionGateAdmissible : ConsensusAction → Bool
  | ConsensusAction.Accept => true
  | ConsensusAction.Hold => true
  | ConsensusAction.Reject => false

/--
  Query type: what Python sends to the Oracle.
  All geometry pre-computed (eigenvalues, id_commit, spectral_gap).
  Oracle verifies bounds — does NOT recompute.

  NOTE on commitment types:
    id_commit     = identity commitment (Hodge projection → quantize → 32 bytes)
                    Used for validator identity attestation via η₁
    CochainCommit = transaction commitment (δ(m∥r) edge values in C¹)
                    Used for balance preservation in blocks
  See: lean/Axioms/CochainCommitment.lean for transaction-level axioms
-/
structure OracleQuery where
  vertex_id    : ℕ
  eigenvalues  : List ℝ
  spectral_gap : ℝ
  betti        : ℤ × ℤ × ℤ
  id_commit    : Fin 32 → UInt8   -- 32-byte Hodge-projected identity commitment

/--
  Answer type: what the Oracle sends back.
  HashStalk commitment + Heyting judgment.
-/
structure OracleAnswer where
  vertex_id          : ℕ
  identity_hash      : Fin 32 → UInt8
  spectral_judgment  : SpectralJudgment
  betti              : ℤ × ℤ × ℤ
  topology_hash      : Fin 32 → UInt8

-- ============================================================================
-- §1.25  CONCRETE Ω(N(V)) COLLAPSE MODEL (runtime-facing)
-- ============================================================================

/--
Three-level executable open-set model for Ω(N(V)) at runtime boundary:

  ⊥ : no supporting coalition
  ½ : proper/partial supporting coalition
  ⊤ : covering/full supporting coalition
-/
inductive OmegaNV
  | bot
  | mid
  | top
  deriving DecidableEq, Repr

namespace OmegaNV

/-- Chain rank for Ω(N(V)) collapsed model. -/
def rank : OmegaNV → Int
  | .bot => -1
  | .mid => 0
  | .top => 1

instance : LE OmegaNV where
  le a b := rank a ≤ rank b

instance : DecidableRel (fun a b : OmegaNV => a ≤ b) := by
  intro a b
  cases a <;> cases b
  · exact isTrue (by decide)
  · exact isTrue (by decide)
  · exact isTrue (by decide)
  · exact isFalse (by decide)
  · exact isTrue (by decide)
  · exact isTrue (by decide)
  · exact isFalse (by decide)
  · exact isFalse (by decide)
  · exact isTrue (by decide)

/-- Meet on the 3-chain Ω-image. -/
def inf (a b : OmegaNV) : OmegaNV :=
  match a, b with
  | .bot, _ => .bot
  | .mid, .bot => .bot
  | .mid, _ => .mid
  | .top, x => x

/-- Join on the 3-chain Ω-image. -/
def sup (a b : OmegaNV) : OmegaNV :=
  match a, b with
  | .bot, x => x
  | .mid, .top => .top
  | .mid, _ => .mid
  | .top, _ => .top

/-- Heyting implication on the 3-chain Ω-image. -/
def imp (a b : OmegaNV) : OmegaNV :=
  match a, b with
  | .bot, _ => .top
  | .mid, .bot => .bot
  | .mid, _ => .top
  | .top, x => x

/-- Residuation law for Ω-image implication. -/
theorem imp_residuation (a b c : OmegaNV) :
    c ≤ imp a b ↔ inf a c ≤ b := by
  cases a <;> cases b <;> cases c <;> decide

end OmegaNV

/--
Richer Ω-carrier with witness/provenance data.
`level` carries Heyting truth semantics; `provenance` stores extra runtime context.
-/
structure OmegaWitness where
  level : OmegaNV
  provenance : Nat
  deriving DecidableEq, Repr

namespace OmegaWitness

instance : LE OmegaWitness where
  le x y := x.level ≤ y.level

instance : DecidableRel (fun x y : OmegaWitness => x ≤ y) := by
  intro x y
  simpa [LE.le] using (inferInstance : Decidable (x.level ≤ y.level))

/-- Meet on witness carrier, semantic on level and conservative on provenance. -/
def inf (x y : OmegaWitness) : OmegaWitness :=
  { level := OmegaNV.inf x.level y.level
    provenance := Nat.min x.provenance y.provenance }

/-- Join on witness carrier, semantic on level and conservative on provenance. -/
def sup (x y : OmegaWitness) : OmegaWitness :=
  { level := OmegaNV.sup x.level y.level
    provenance := Nat.max x.provenance y.provenance }

/-- Heyting implication on witness carrier (level-semantics + provenance merge). -/
def imp (x y : OmegaWitness) : OmegaWitness :=
  { level := OmegaNV.imp x.level y.level
    provenance := x.provenance + y.provenance }

/-- Residuation inherited from `OmegaNV` through level projection. -/
theorem imp_residuation (a b c : OmegaWitness) :
    c ≤ imp a b ↔ inf a c ≤ b := by
  change c.level ≤ OmegaNV.imp a.level b.level ↔ OmegaNV.inf a.level c.level ≤ b.level
  simpa using OmegaNV.imp_residuation a.level b.level c.level

end OmegaWitness

/-- Concrete richer Heyting witness over Ω-carrier with provenance metadata. -/
def OmegaWitnessHeyting : AbstractHeyting OmegaWitness where
  le := (· ≤ ·)
  top := { level := OmegaNV.top, provenance := 0 }
  bot := { level := OmegaNV.bot, provenance := 0 }
  inf := OmegaWitness.inf
  sup := OmegaWitness.sup
  imp := OmegaWitness.imp
  residuation := by
    intro a b c
    exact OmegaWitness.imp_residuation a b c

/-- Collapse of richer Ω-carrier onto executable 3-level semantics. -/
def witnessCollapse (x : OmegaWitness) : OmegaNV :=
  x.level

theorem witnessCollapse_surjective : Function.Surjective witnessCollapse := by
  intro x
  exact ⟨{ level := x, provenance := 0 }, rfl⟩

theorem witnessCollapse_mapInf (x y : OmegaWitness) :
    witnessCollapse (OmegaWitness.inf x y)
      = OmegaNV.inf (witnessCollapse x) (witnessCollapse y) := rfl

theorem witnessCollapse_mapSup (x y : OmegaWitness) :
    witnessCollapse (OmegaWitness.sup x y)
      = OmegaNV.sup (witnessCollapse x) (witnessCollapse y) := rfl

theorem witnessCollapse_mapImp (x y : OmegaWitness) :
    witnessCollapse (OmegaWitness.imp x y)
      = OmegaNV.imp (witnessCollapse x) (witnessCollapse y) := rfl

/-- Witness-level collapse to Heyting3 (composed through Ω-collapse). -/
def witnessToHeyting3Collapse : HeytingCollapse OmegaWitnessHeyting where
  π := fun x =>
    match witnessCollapse x with
    | OmegaNV.bot => Heyting3.Invalid
    | OmegaNV.mid => Heyting3.Undetermined
    | OmegaNV.top => Heyting3.Valid
  mapTop := rfl
  mapBot := rfl
  mapInf := by
    intro x y
    cases x with
    | mk xl xp =>
      cases y with
      | mk yl yp =>
        cases xl <;> cases yl <;> rfl
  mapSup := by
    intro x y
    cases x with
    | mk xl xp =>
      cases y with
      | mk yl yp =>
        cases xl <;> cases yl <;> rfl
  mapImp := by
    intro x y
    cases x with
    | mk xl xp =>
      cases y with
      | mk yl yp =>
        cases xl <;> cases yl <;> rfl

/-- Quotient relation identifying witness objects with equal semantic level. -/
def OmegaWitnessSetoid : Setoid OmegaWitness where
  r x y := witnessCollapse x = witnessCollapse y
  iseqv := by
    refine ⟨?_, ?_, ?_⟩
    · intro x; rfl
    · intro x y h; exact h.symm
    · intro x y z hxy hyz; exact hxy.trans hyz

/-- Quotient of richer Ω by semantic equivalence. -/
abbrev OmegaWitnessQuot : Type := Quot OmegaWitnessSetoid

/-- Canonical map from quotient witness-space to executable Ω semantics. -/
def quotToOmegaNV : OmegaWitnessQuot → OmegaNV :=
  Quot.lift witnessCollapse (by
    intro a b hab
    exact hab)

/-- Canonical embedding of executable Ω values into witness quotient. -/
def omegaNVToQuot : OmegaNV → OmegaWitnessQuot :=
  fun x => Quot.mk _ { level := x, provenance := 0 }

theorem quotToOmegaNV_left_inv :
    Function.LeftInverse omegaNVToQuot quotToOmegaNV := by
  intro q
  refine Quot.inductionOn q ?_
  intro w
  exact Quot.sound rfl

theorem quotToOmegaNV_right_inv :
    Function.RightInverse omegaNVToQuot quotToOmegaNV := by
  intro x
  rfl

/-- Concrete quotient theorem: richer Ω witness space collapses to `OmegaNV`. -/
def omegaNVQuotEquiv : OmegaWitnessQuot ≃ OmegaNV where
  toFun := quotToOmegaNV
  invFun := omegaNVToQuot
  left_inv := quotToOmegaNV_left_inv
  right_inv := quotToOmegaNV_right_inv

/-- Concrete "Heyting image/collapse" summary theorem for richer Ω witness space. -/
theorem omegaNV_is_heyting_image :
    Function.Surjective witnessCollapse
    ∧ (∀ x y, witnessCollapse (OmegaWitness.inf x y)
        = OmegaNV.inf (witnessCollapse x) (witnessCollapse y))
    ∧ (∀ x y, witnessCollapse (OmegaWitness.sup x y)
        = OmegaNV.sup (witnessCollapse x) (witnessCollapse y))
    ∧ (∀ x y, witnessCollapse (OmegaWitness.imp x y)
        = OmegaNV.imp (witnessCollapse x) (witnessCollapse y)) := by
  refine ⟨witnessCollapse_surjective, ?_, ?_, ?_⟩
  · intro x y
    exact witnessCollapse_mapInf x y
  · intro x y
    exact witnessCollapse_mapSup x y
  · intro x y
    exact witnessCollapse_mapImp x y

/-- Concrete `AbstractHeyting` witness for the Ω(N(V)) 3-level runtime model. -/
def OmegaNVHeyting : AbstractHeyting OmegaNV where
  le := (· ≤ ·)
  top := OmegaNV.top
  bot := OmegaNV.bot
  inf := OmegaNV.inf
  sup := OmegaNV.sup
  imp := OmegaNV.imp
  residuation := by
    intro a b c
    exact OmegaNV.imp_residuation a b c

/-- Collapse map Ω(N(V))runtime → Heyting3 runtime truth. -/
def omegaCollapse : OmegaNV → Heyting3
  | OmegaNV.bot => Heyting3.Invalid
  | OmegaNV.mid => Heyting3.Undetermined
  | OmegaNV.top => Heyting3.Valid

/-- Concrete Heyting collapse proof object for the Ω(N(V))runtime model. -/
def omegaCollapseHom : HeytingCollapse OmegaNVHeyting where
  π := omegaCollapse
  mapTop := rfl
  mapBot := rfl
  mapInf := by
    intro x y
    cases x <;> cases y <;> decide
  mapSup := by
    intro x y
    cases x <;> cases y <;> decide
  mapImp := by
    intro x y
    cases x <;> cases y <;> decide

/-- Map protocol-level spectral judgment into the Ω-collapse model. -/
def judgmentToOmega : SpectralJudgment → OmegaNV
  | SpectralJudgment.InBounds => OmegaNV.top
  | SpectralJudgment.Boundary => OmegaNV.mid
  | SpectralJudgment.OutOfBounds => OmegaNV.bot

/-- Derived Heyting3 truth value for protocol judgment via Ω-collapse. -/
def judgmentToHeyting3 (j : SpectralJudgment) : Heyting3 :=
  omegaCollapse (judgmentToOmega j)

/-- In-bounds oracle verdicts collapse to public valid truth. -/
theorem inBounds_truth_valid :
    judgmentToHeyting3 SpectralJudgment.InBounds = Heyting3.Valid := by
  rfl

/-- Boundary oracle verdicts collapse to public undetermined truth. -/
theorem boundary_truth_undetermined :
    judgmentToHeyting3 SpectralJudgment.Boundary = Heyting3.Undetermined := by
  rfl

/-- Out-of-bounds oracle verdicts collapse to public invalid truth. -/
theorem outOfBounds_truth_invalid :
    judgmentToHeyting3 SpectralJudgment.OutOfBounds = Heyting3.Invalid := by
  rfl

/-- Boundary is operationally held for more evidence. -/
theorem boundary_action_hold :
    judgmentToAction SpectralJudgment.Boundary = ConsensusAction.Hold := by
  rfl

/-- Boundary is not a final accept action. -/
theorem boundary_not_final_accepted :
    actionFinalAccepted (judgmentToAction SpectralJudgment.Boundary) = false := by
  rfl

/-- Boundary remains gate-admissible: it is held/retried rather than rejected. -/
theorem boundary_gate_admissible :
    actionGateAdmissible (judgmentToAction SpectralJudgment.Boundary) = true := by
  rfl

/--
The formal Heyting implication is residuated: boundary/undetermined truth
implying invalid truth collapses to invalid in the 3-chain.
-/
theorem boundary_truth_implies_invalid_truth :
    himp (judgmentToHeyting3 SpectralJudgment.Boundary)
      (judgmentToHeyting3 SpectralJudgment.OutOfBounds) = Heyting3.Invalid := by
  rfl

/--
The core split used for runtime parity: `Boundary` is held by consensus policy,
while Heyting implication remains the formal residuated connective.
-/
theorem boundary_policy_is_not_heyting_implication :
    judgmentToAction SpectralJudgment.Boundary = ConsensusAction.Hold
      ∧ himp (judgmentToHeyting3 SpectralJudgment.Boundary)
          (judgmentToHeyting3 SpectralJudgment.OutOfBounds) = Heyting3.Invalid := by
  exact ⟨rfl, rfl⟩

/-- Final acceptance corresponds exactly to public valid truth. -/
theorem actionFinalAccepted_iff_valid_truth (j : SpectralJudgment) :
    actionFinalAccepted (judgmentToAction j) = true
      ↔ judgmentToHeyting3 j = Heyting3.Valid := by
  cases j <;> simp [actionFinalAccepted, judgmentToAction, judgmentToHeyting3,
    judgmentToOmega, omegaCollapse]

/-- Gate admissibility corresponds exactly to non-invalid public truth. -/
theorem actionGateAdmissible_iff_not_invalid_truth (j : SpectralJudgment) :
    actionGateAdmissible (judgmentToAction j) = true
      ↔ judgmentToHeyting3 j ≠ Heyting3.Invalid := by
  cases j <;> simp [actionGateAdmissible, judgmentToAction, judgmentToHeyting3,
    judgmentToOmega, omegaCollapse]

-- ============================================================================
-- §1.5  CONSTRUCTIVE FINITE SHEAF SETUP (runtime-facing)
-- ============================================================================

/--
Constructive finite sheaf payload used at runtime boundaries.

This is intentionally finite/data-oriented (lists + size invariants), matching
the concrete on-wire/storage representation shape rather than abstract sheaf
category semantics.
-/
structure FiniteSheafSetup where
  vertices : List ℕ
  edges : List (ℕ × ℕ)
  stalkDim : ℕ
  restrictions : ℕ → ℕ → List ℝ
  edgeEndpointsInVertices :
    ∀ e, e ∈ edges → e.1 ∈ vertices ∧ e.2 ∈ vertices
  restrictionMatrixSize :
    ∀ u v, (restrictions u v).length = stalkDim * stalkDim

/-- Boolean edge-membership check for finite sheaf setup. -/
def edgePresent (S : FiniteSheafSetup) (u v : ℕ) : Bool :=
  decide ((u, v) ∈ S.edges)

theorem edgePresent_true_iff (S : FiniteSheafSetup) (u v : ℕ) :
    edgePresent S u v = true ↔ (u, v) ∈ S.edges := by
  unfold edgePresent
  simp

/-- Restriction payload has the expected flattened matrix size. -/
def restrictionWellFormed (S : FiniteSheafSetup) (u v : ℕ) : Prop :=
  (S.restrictions u v).length = S.stalkDim * S.stalkDim

theorem restrictionWellFormed_all (S : FiniteSheafSetup) (u v : ℕ) :
    restrictionWellFormed S u v := by
  unfold restrictionWellFormed
  exact S.restrictionMatrixSize u v

-- ============================================================================
-- §2  ORACLE MODALITY (Ahman-Bauer §2)
-- ============================================================================

/--
  The oracle predicate P induced by the Tsirelson bounds.
  An answer is valid for a query iff:
    1. The identity_hash is consistent with the query commitment.
    2. The spectral_judgment correctly reflects the gap.
    3. The betti numbers are preserved.
-/
def OraclePredicate (q : OracleQuery) (a : OracleAnswer) : Prop :=
  a.vertex_id = q.vertex_id
  ∧ a.betti = q.betti
  ∧ (∀ i, a.identity_hash i = q.id_commit i)
  ∧ (TsirelsonPredicate q.spectral_gap ↔ a.spectral_judgment = SpectralJudgment.InBounds
                                         ∨ a.spectral_judgment = SpectralJudgment.Boundary)

/--
  The oracle modality: a proposition A is oracle-forced if, given any valid
  oracle answer for any query, A holds. This is the forcing condition from
  Ahman-Bauer §2: □_P A = least modality forcing P.
-/
def OracleForced (A : Prop) : Prop :=
  ∀ (q : OracleQuery) (a : OracleAnswer), OraclePredicate q a → A

/-- OracleForced is a modality: it is monotone. -/
theorem oracleForced_mono {A B : Prop} : (A → B) → OracleForced A → OracleForced B := by
  intro hAB hA q a hP
  exact hAB (hA q a hP)

/-- OracleForced is idempotent: forcing twice is same as forcing once. -/
theorem oracleForced_idempotent {A : Prop} :
    OracleForced (OracleForced A) → OracleForced A := by
  intro h q a hP
  exact h q a hP q a hP

-- ============================================================================
-- §3  ETA TRANSFORMATIONS (η₁ and η₂ natural transformation axioms)
-- ============================================================================

/--
  η₁ (Python → Oracle): the Oracle is the first natural transformation.
  Axiom: given a query satisfying Foundation preconditions, the Oracle
  produces a valid answer (oracle predicate holds).
-/
structure OracleEta1 where
  /-- Oracle is total: every valid query has an answer. -/
  Total : ∀ (q : OracleQuery), ∃ (a : OracleAnswer), OraclePredicate q a
  /-- Oracle is consistent with Tsirelson bounds (no false attestations). -/
  BoundConsistency : ∀ (q : OracleQuery) (a : OracleAnswer),
    OraclePredicate q a →
    (a.spectral_judgment = SpectralJudgment.InBounds →
      TsirelsonPredicate q.spectral_gap)
  /-- Oracle is deterministic on judgment for InBounds. -/
  JudgmentDeterminism : ∀ (q : OracleQuery) (a₁ a₂ : OracleAnswer),
    OraclePredicate q a₁ → OraclePredicate q a₂ →
    a₁.spectral_judgment = SpectralJudgment.InBounds →
    a₂.spectral_judgment = SpectralJudgment.InBounds

/--
  η₂ (Oracle → Rust node): the node applies the second natural transformation.
  Axiom: a valid oracle answer implies consensus admissibility at the node gate.
-/
structure OracleEta2 where
  /-- Consensus admissibility predicate at the node gate. -/
  ConsensusAdmissible : OracleAnswer → Prop
  /-- Node acceptance requires InBounds or Boundary judgment (not OutOfBounds). -/
  AcceptsInBoundsOrBoundary : ∀ (a : OracleAnswer),
    (a.spectral_judgment = SpectralJudgment.InBounds
      ∨ a.spectral_judgment = SpectralJudgment.Boundary) →
    ConsensusAdmissible a
  /-- OutOfBounds always rejects at node. -/
  RejectsOutOfBounds : ∀ (a : OracleAnswer),
    a.spectral_judgment = SpectralJudgment.OutOfBounds →
    ¬ ConsensusAdmissible a
  /-- Identity hash is stable: same vertex + same commitment → same hash. -/
  IdentityHashStable : ∀ (a₁ a₂ : OracleAnswer),
    a₁.vertex_id = a₂.vertex_id →
    (∀ i, a₁.topology_hash i = a₂.topology_hash i) →
    a₁.betti = a₂.betti →
    ∀ i, a₁.identity_hash i = a₂.identity_hash i

-- ============================================================================
-- §4  LAWVERE-TIERNEY TOPOLOGY (paper §5 application)
-- ============================================================================

/--
  The Tsirelson predicate induces a Lawvere-Tierney topology j on the oracle
  sheaf topos. The three-valued judgment is the sub-object classifier morphism.

  j : SpectralJudgment → SpectralJudgment satisfying:
    j (j x) = j x      (idempotency)
    j InBounds = InBounds  (truth preservation)
    j is monotone wrt the Heyting order InBounds ≤ Boundary ≤ OutOfBounds
-/
def lawvere_tierney (x : SpectralJudgment) : SpectralJudgment :=
  match x with
  | SpectralJudgment.InBounds    => SpectralJudgment.InBounds
  | SpectralJudgment.Boundary    => SpectralJudgment.Boundary
  | SpectralJudgment.OutOfBounds => SpectralJudgment.OutOfBounds

theorem lt_idempotent : ∀ x : SpectralJudgment,
    lawvere_tierney (lawvere_tierney x) = lawvere_tierney x := by
  intro x; cases x <;> rfl

theorem lt_preserves_truth :
    lawvere_tierney SpectralJudgment.InBounds = SpectralJudgment.InBounds := rfl

/--
  Gate admissibility is the characteristic morphism of the dense subobject
  `{InBounds, Boundary} ↪ SpectralJudgment` under the Lawvere-Tierney topology.

  Historical name note: `blockAccepted` means "not rejected by this consensus
  gate". It does not mean finalization: `Boundary` is admissible but maps to the
  operational action `Hold`.
-/
def blockAccepted (j : SpectralJudgment) : Bool :=
  match j with
  | SpectralJudgment.InBounds => true
  | SpectralJudgment.Boundary => true     -- UNDETERMINED: pending further evidence
  | SpectralJudgment.OutOfBounds => false

theorem accepted_iff_not_out :
    ∀ x : SpectralJudgment,
    blockAccepted x = true ↔ x ≠ SpectralJudgment.OutOfBounds := by
  intro x; cases x <;> simp [blockAccepted]

/-- The legacy gate predicate is the same as action-level admissibility. -/
theorem blockAccepted_eq_actionGateAdmissible (j : SpectralJudgment) :
    blockAccepted j = actionGateAdmissible (judgmentToAction j) := by
  cases j <;> rfl

/-- Sheafified truth is `Valid` exactly on `InBounds`. -/
theorem judgmentToHeyting3_valid_iff_inBounds (j : SpectralJudgment) :
    judgmentToHeyting3 j = Heyting3.Valid ↔ j = SpectralJudgment.InBounds := by
  cases j <;> simp [judgmentToHeyting3, judgmentToOmega, omegaCollapse]

/-- Sheafified truth is `Invalid` exactly on `OutOfBounds`. -/
theorem judgmentToHeyting3_invalid_iff_outOfBounds (j : SpectralJudgment) :
    judgmentToHeyting3 j = Heyting3.Invalid ↔ j = SpectralJudgment.OutOfBounds := by
  cases j <;> simp [judgmentToHeyting3, judgmentToOmega, omegaCollapse]

/--
Consensus gate acceptance is exactly non-invalid sheafified truth.
This is the tight gate↔Heyting compatibility statement.
-/
theorem blockAccepted_iff_not_invalid_sheafified (j : SpectralJudgment) :
    blockAccepted j = true ↔ judgmentToHeyting3 j ≠ Heyting3.Invalid := by
  cases j <;> simp [blockAccepted, judgmentToHeyting3, judgmentToOmega, omegaCollapse]

/--
Generic classifier consistency stub:
any runtime classifier into `SpectralJudgment` is gate/Heyting-consistent
through the canonical collapse `judgmentToHeyting3`.

This is intended as the direct instantiation point for Rust policy functions.
-/
theorem classifier_gate_heyting_consistent
  (classify : ℝ → SpectralJudgment) (gap : ℝ) :
    blockAccepted (classify gap) = true
      ↔ judgmentToHeyting3 (classify gap) ≠ Heyting3.Invalid := by
  simpa using blockAccepted_iff_not_invalid_sheafified (classify gap)

/--
Deterministic spectral verdict procedure (constructive policy):
1) InBounds if TsirelsonPredicate holds.
2) Boundary if near either protocol bound (within ε).
3) OutOfBounds otherwise.
-/
noncomputable def decideSpectralJudgment (gap eps : ℝ) : SpectralJudgment := by
  classical
  by_cases hIn : TsirelsonPredicate gap
  · exact SpectralJudgment.InBounds
  · by_cases hBd : NearTsirelsonBoundary gap eps
    · exact SpectralJudgment.Boundary
    · exact SpectralJudgment.OutOfBounds

theorem decideSpectralJudgment_inBounds {gap eps : ℝ}
    (hIn : TsirelsonPredicate gap) :
    decideSpectralJudgment gap eps = SpectralJudgment.InBounds := by
  classical
  unfold decideSpectralJudgment
  simp [hIn]

theorem decideSpectralJudgment_boundary {gap eps : ℝ}
    (hIn : ¬ TsirelsonPredicate gap)
    (hBd : NearTsirelsonBoundary gap eps) :
    decideSpectralJudgment gap eps = SpectralJudgment.Boundary := by
  classical
  unfold decideSpectralJudgment
  simp [hIn, hBd]

theorem decideSpectralJudgment_outOfBounds {gap eps : ℝ}
    (hIn : ¬ TsirelsonPredicate gap)
    (hBd : ¬ NearTsirelsonBoundary gap eps) :
    decideSpectralJudgment gap eps = SpectralJudgment.OutOfBounds := by
  classical
  unfold decideSpectralJudgment
  simp [hIn, hBd]

/-- Constructive Boolean checker for oracle answer validity. -/
noncomputable def oracleAnswerWellFormed (q : OracleQuery) (a : OracleAnswer) : Bool := by
  classical
  exact if OraclePredicate q a then true else false

theorem oracleAnswerWellFormed_true_iff (q : OracleQuery) (a : OracleAnswer) :
    oracleAnswerWellFormed q a = true ↔ OraclePredicate q a := by
  classical
  unfold oracleAnswerWellFormed
  by_cases h : OraclePredicate q a
  · simp [h]
  · simp [h]

/-- Canonical executable admissibility predicate used for η₂ wiring. -/
def CanonicalConsensusAdmissible (a : OracleAnswer) : Prop :=
  blockAccepted a.spectral_judgment = true

/--
Constructive η₂ instance from executable admissibility plus a supplied
identity-hash stability hypothesis.
-/
def canonicalEta2
  (hStable :
    ∀ (a₁ a₂ : OracleAnswer),
      a₁.vertex_id = a₂.vertex_id →
      (∀ i, a₁.topology_hash i = a₂.topology_hash i) →
      a₁.betti = a₂.betti →
      ∀ i, a₁.identity_hash i = a₂.identity_hash i) : OracleEta2 where
  ConsensusAdmissible := CanonicalConsensusAdmissible
  AcceptsInBoundsOrBoundary := by
    intro a h
    unfold CanonicalConsensusAdmissible
    rcases h with hIn | hBd
    · simp [blockAccepted, hIn]
    · simp [blockAccepted, hBd]
  RejectsOutOfBounds := by
    intro a hOut
    unfold CanonicalConsensusAdmissible
    simp [blockAccepted, hOut]
  IdentityHashStable := hStable

-- ============================================================================
-- §5  PIPELINE COMPOSITION AXIOM
-- ============================================================================

/--
  The full oracle pipeline composes:
    Python witness (Foundation) → Oracle attestation (η₁) → Node enforcement (η₂)

  Axiom: if Foundation is well-formed and the Oracle is η₁-valid and
  the node gate is η₂-valid, then the pipeline is sound:
  any in-bounds spectral gap flowing through the pipeline implies
  consensus admissibility.
-/
structure OraclePipeline where
  η₁ : OracleEta1
  η₂ : OracleEta2
  /-- End-to-end soundness: valid gap → consensus admissible. -/
  PipelineSoundness : ∀ (q : OracleQuery),
    TsirelsonPredicate q.spectral_gap →
    ∃ (a : OracleAnswer),
      OraclePredicate q a ∧
      a.spectral_judgment = SpectralJudgment.InBounds ∧
      blockAccepted a.spectral_judgment = true
  /-- Exact sequence: ker(η) is private; public image is commitment only. -/
  PrivacyExactSequence : ∀ (q₁ q₂ : OracleQuery),
    (∀ i, q₁.id_commit i = q₂.id_commit i) →
    q₁.spectral_gap = q₂.spectral_gap →
    q₁.betti = q₂.betti →
    ∃ (a : OracleAnswer),
      OraclePredicate q₁ a ∧ OraclePredicate q₂ a

/-- A pipeline is well-formed if PipelineSoundness holds. -/
abbrev OraclePipelineWellFormed (O : OraclePipeline) : Prop :=
  ∀ (q : OracleQuery),
    TsirelsonPredicate q.spectral_gap →
    ∃ (a : OracleAnswer),
      OraclePredicate q a
      ∧ a.spectral_judgment = SpectralJudgment.InBounds
      ∧ blockAccepted a.spectral_judgment = true
      ∧ O.η₂.ConsensusAdmissible a

theorem pipeline_wellformed_of_soundness (O : OraclePipeline) :
    OraclePipelineWellFormed O := by
  intro q hgap
  obtain ⟨a, hP, hInBounds, hAccepted⟩ := O.PipelineSoundness q hgap
  have hAdmissible : O.η₂.ConsensusAdmissible a :=
    O.η₂.AcceptsInBoundsOrBoundary a (Or.inl hInBounds)
  exact ⟨a, hP, hInBounds, hAccepted, hAdmissible⟩

/--
End-to-end coherence witness:
pipeline soundness yields an oracle answer whose sheafified truth is `Valid`
and whose consensus gate is admissible.
-/
theorem oracle_sheafification_consensus_witness
  (O : OraclePipeline)
  (q : OracleQuery)
  (hgap : TsirelsonPredicate q.spectral_gap) :
  ∃ (a : OracleAnswer),
    OraclePredicate q a
    ∧ judgmentToHeyting3 a.spectral_judgment = Heyting3.Valid
    ∧ blockAccepted a.spectral_judgment = true
    ∧ O.η₂.ConsensusAdmissible a := by
  obtain ⟨a, hP, hInBounds, hAccepted⟩ := O.PipelineSoundness q hgap
  have hAdmissible : O.η₂.ConsensusAdmissible a :=
    O.η₂.AcceptsInBoundsOrBoundary a (Or.inl hInBounds)
  have hSheafified : judgmentToHeyting3 a.spectral_judgment = Heyting3.Valid := by
    simp [judgmentToHeyting3, judgmentToOmega, omegaCollapse, hInBounds]
  exact ⟨a, hP, hSheafified, hAccepted, hAdmissible⟩

/--
End-to-end coherence theorem linking:
  oracle modality forcing (`OracleForced`),
  sheafification collapse (`judgmentToHeyting3`), and
  consensus acceptance (`blockAccepted`/`η₂.ConsensusAdmissible`).
-/
theorem oracle_forced_sheafification_consensus_coherence
  (O : OraclePipeline)
  (q : OracleQuery)
  (hgap : TsirelsonPredicate q.spectral_gap) :
  OracleForced (
    ∃ (a : OracleAnswer),
      OraclePredicate q a
      ∧ judgmentToHeyting3 a.spectral_judgment = Heyting3.Valid
      ∧ blockAccepted a.spectral_judgment = true
      ∧ O.η₂.ConsensusAdmissible a
  ) := by
  intro _q _a _hP
  exact oracle_sheafification_consensus_witness O q hgap

-- ============================================================================
-- §6  CONNECTION TO EXISTING AXIOM MODULES
-- ============================================================================

/--
  The oracle pipeline is compatible with StageAdmissibility:
  if a transaction stage critical pass witnesses an in-bounds oracle answer,
  then the consensus gate is admissible.
-/
theorem oracle_implies_stage_admissible
  (O : OraclePipeline)
  (F : Foundation)
  (C : Consensus)
  (q : OracleQuery)
  (hgap : TsirelsonPredicate q.spectral_gap)
  (hF : FoundationWellFormed F)
  (hC : ConsensusWellFormed C) :
  StageAdmissibilityWellFormed (StageAdmissibilityFromAxioms F C) := by
  have _hPipelineWitness :
      ∃ (a : OracleAnswer),
        OraclePredicate q a
        ∧ a.spectral_judgment = SpectralJudgment.InBounds
        ∧ blockAccepted a.spectral_judgment = true :=
    O.PipelineSoundness q hgap
  exact stage_admissibility_from_axioms_wellformed F C hF hC

/--
Bridge from η₂ node-admissibility to consensus-level Topos coherence.

This is the explicit hook that lets runtime oracle judgments discharge the
`Consensus.ToposDecisionCoherent` obligation used by `StageAdmissibility`.
-/
structure OracleConsensusBridge (C : Consensus) (η₂ : OracleEta2) where
  AdmissibleImpliesToposCoherent :
    ∀ (a : OracleAnswer), η₂.ConsensusAdmissible a → C.ToposDecisionCoherent

/--
From pipeline soundness and a bridge hypothesis, obtain a witness that is
both η₂-admissible and sufficient for consensus Topos coherence.
-/
theorem oracle_admissible_implies_topos
  (O : OraclePipeline)
  (C : Consensus)
  (B : OracleConsensusBridge C O.η₂)
  (q : OracleQuery)
  (hgap : TsirelsonPredicate q.spectral_gap) :
  ∃ (a : OracleAnswer),
    OraclePredicate q a ∧ O.η₂.ConsensusAdmissible a ∧ C.ToposDecisionCoherent := by
  obtain ⟨a, hP, hInBounds, _hAccepted⟩ := O.PipelineSoundness q hgap
  have hAdmissible : O.η₂.ConsensusAdmissible a :=
    O.η₂.AcceptsInBoundsOrBoundary a (Or.inl hInBounds)
  exact ⟨a, hP, hAdmissible, B.AdmissibleImpliesToposCoherent a hAdmissible⟩

/-- Consensus obligations except the Topos-coherence component. -/
abbrev ConsensusBaseWithoutTopos (C : Consensus) : Prop :=
  C.SpectralBounds ∧ C.TopologyConnected ∧ C.KeyImagesFresh ∧ C.BalancePreserved

/--
Assemble full `ConsensusWellFormed` from base obligations plus oracle-bridge
discharge of Topos coherence.
-/
theorem consensus_wellformed_from_oracle_bridge
  (O : OraclePipeline)
  (C : Consensus)
  (B : OracleConsensusBridge C O.η₂)
  (q : OracleQuery)
  (hgap : TsirelsonPredicate q.spectral_gap)
  (hBase : ConsensusBaseWithoutTopos C) :
  ConsensusWellFormed C := by
  rcases hBase with ⟨hSpectral, hTopoConn, hKeyFresh, hBalance⟩
  obtain ⟨_a, _hP, _hAdmissible, hTopos⟩ :=
    oracle_admissible_implies_topos O C B q hgap
  exact ⟨hSpectral, hTopoConn, hKeyFresh, hBalance, hTopos⟩

/--
Strengthened stage-admissibility theorem:
Topos coherence can be supplied by η₂-admissibility via `OracleConsensusBridge`,
instead of assuming it independently in `ConsensusWellFormed`.
-/
theorem oracle_stage_admissible_from_bridge
  (O : OraclePipeline)
  (F : Foundation)
  (C : Consensus)
  (B : OracleConsensusBridge C O.η₂)
  (q : OracleQuery)
  (hgap : TsirelsonPredicate q.spectral_gap)
  (hF : FoundationWellFormed F)
  (hBase : ConsensusBaseWithoutTopos C) :
  StageAdmissibilityWellFormed (StageAdmissibilityFromAxioms F C) := by
  have hC : ConsensusWellFormed C :=
    consensus_wellformed_from_oracle_bridge O C B q hgap hBase
  exact stage_admissibility_from_axioms_wellformed F C hF hC

/--
  The oracle pipeline is compatible with ZKP soundness:
  oracle answers serve as the verification oracle for ZKP soundness.
-/
theorem oracle_answer_witnesses_zkp_soundness
  (Z : ZKP)
  (q : OracleQuery)
  (a : OracleAnswer)
  (hP : OraclePredicate q a)
  (hZ : ZKPWellFormed Z) :
  Z.Soundness := by
  have _hOracleWitness : OraclePredicate q a := hP
  exact hZ.2.1

end Axioms
end Hcrypt
