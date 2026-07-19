/-
Chain Axiomatization (Swan Table 1 #9 — Goncharov)

Paper correspondence:
- Paper 2: chain architecture, consensus consumption, and proof-of-value
  protocol setting.
- Paper 1 appendix ledger: mentioned only as a formalization boundary for the
  subsequent protocol paper.

First-order axiomatization of the homotopical-encrypt blockchain.
Goncharov axiomatizes "select longest chain" in first-order logic;
we axiomatize Proof-of-Value (PoV) consensus where the SPECTRAL GAP
of the validator's fibration determines block production eligibility.

AXIOMS:

  1. Block Validity:    valid(B) ↔ spectral_gap(B.producer) ∈ [1/√2, 2√2]
                        ∧ β₀(B.nerve) = 1
                        ∧ key_images_fresh(B)
                        ∧ balance_preserved(B)

  2. Chain Extension:   extends(B, C) ↔ valid(B) ∧ B.prev = tip(C)
                        ∧ height(B) = height(tip(C)) + 1

  3. PoV Selection:     selected(v, epoch) ↔ eligible(v)
                        ∧ vrf_score(v, epoch) = max{vrf_score(w, epoch) | eligible(w)}
                        where eligible(v) ↔ spectral_gap(v) ∈ [1/√2, 2√2]

  4. Fork Resolution:   preferred(C₁, C₂) ↔ cumulative_gap(C₁) > cumulative_gap(C₂)
                        (replaces "longest chain" with "heaviest spectral weight")

  5. Transaction Associativity:
                        compose(compose(tx₁, tx₂), tx₃) ≃ compose(tx₁, compose(tx₂, tx₃))
                        via cochain linearity + homotopy path composition

  6. Sybil Resistance:  ∀ v, n : split(v, n).total_weight ≤ weight(v)
                        (splitting a validator into n copies cannot increase total weight)

References:
  - Goncharov & Nechesov (2023), "Axiomatization of Blockchain Theory"
  - Zhao (2020), "Algebraic Structure of Blockchains"
  - Helfer (2019), "First-order homotopical logic" (arXiv:1908.08944)
  - lean/Hardness.lean (Paper 1 hidden-operator comparison theorem surface)
  - lean/Tsirelson.lean (√2 bound — the consensus axioms)
-/

import Mathlib
import Axioms.CochainCommitment.Payload
import Axioms.SheafCoherence

set_option linter.mathlibStandardSet false

open scoped BigOperators
open scoped Real
open scoped Nat
open scoped Classical

set_option maxHeartbeats 400000
set_option maxRecDepth 4000

set_option relaxedAutoImplicit false
set_option autoImplicit false

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- BASIC TYPES
-- ═══════════════════════════════════════════════════════════════════════

/-- A validator is identified by a spectral fingerprint (hash of eigenvalues). -/
structure Validator where
  fingerprint : ℕ        -- hash of spectral data (unique identifier)
  spectral_gap : ℝ       -- λ₁ of sheaf Laplacian
  betti_0 : ℕ            -- β₀ = connected components
  betti_1 : ℕ            -- β₁ = independent cycles

/--
  A transaction carrying the canonical cochain commitment payload.

  `cochain_commitment` is the tested wire-facing object from
  `Axioms.CochainCommitment`: modulus, declared edge count, edge values in C¹,
  and topology hash. Chain-level proofs use `commitment_sum` as the ℤ-valued
  summary `Σᵢ edge_values[i]`; this is sound at the abstract level because δ is
  linear and balance is checked on accumulated commitments.
-/
structure Transaction where
  sender : ℕ
  recipient : ℕ
  key_image : ℕ              -- unique per fibration, prevents double-spend
  cochain_commitment : Hcrypt.Axioms.CochainCommitmentData

/-- Summary scalar for balance proofs: Σᵢ edge_values[i]. -/
def Transaction.commitment_sum (t : Transaction) : ℤ :=
  t.cochain_commitment.commitment_sum

/-- A block in the PoV chain. -/
structure Block where
  height : ℕ
  prev_hash : ℕ
  producer : Validator
  transactions : List Transaction
  vrf_score : ℝ            -- VRF output for leader election
  timestamp : ℕ

/-- A chain is a list of blocks (genesis at head). -/
def Chain := List Block


-- ═══════════════════════════════════════════════════════════════════════
-- AXIOM 1: BLOCK VALIDITY (PoV)
-- ═══════════════════════════════════════════════════════════════════════

/-- Tsirelson bounds for PoV consensus. -/
def pov_lower_bound : ℝ := 1 / Real.sqrt 2
def pov_upper_bound : ℝ := 2 * Real.sqrt 2

/-- A validator's spectral gap is within PoV bounds. -/
def spectral_gap_in_bounds (v : Validator) : Prop :=
  pov_lower_bound ≤ v.spectral_gap ∧ v.spectral_gap ≤ pov_upper_bound

/-- A validator has connected topology (β₀ = 1). -/
def topology_connected (v : Validator) : Prop :=
  v.betti_0 = 1

/-- All key images in a block are distinct (no double-spend within block). -/
def key_images_fresh (txs : List Transaction) : Prop :=
  ∀ (i j : Fin txs.length), i ≠ j →
    (txs.get i).key_image ≠ (txs.get j).key_image

/-- Transaction balance is preserved: Σ commitment sums = 0.
    Uses commitment_sum (Σ edge values) because δ is linear. -/
def balance_preserved (txs : List Transaction) : Prop :=
  (txs.map (·.commitment_sum)).sum = 0

/-- AXIOM 1: Block Validity Predicate. -/
def block_valid (b : Block) : Prop :=
  spectral_gap_in_bounds b.producer
  ∧ topology_connected b.producer
  ∧ key_images_fresh b.transactions
  ∧ balance_preserved b.transactions


-- ═══════════════════════════════════════════════════════════════════════
-- AXIOM 2: CHAIN EXTENSION
-- ═══════════════════════════════════════════════════════════════════════

def chain_tip : Chain → Option Block
  | [] => none
  | (b :: _) => some b

def chain_height : Chain → ℕ
  | [] => 0
  | (b :: _) => b.height

/-- AXIOM 2: Chain Extension Rule. -/
def block_extends (b : Block) (c : Chain) (tip_hash : ℕ) : Prop :=
  block_valid b
  ∧ b.prev_hash = tip_hash
  ∧ b.height = chain_height c + 1


-- ═══════════════════════════════════════════════════════════════════════
-- VALIDATION BOUNDARY: ABSTRACT LEDGER / RUNTIME SPEC
-- ═══════════════════════════════════════════════════════════════════════

/--
Abstract transaction shape expected by the consensus path.

Lean specifies the invariant; Rust owns byte parsing, canonical encodings, size
limits, and signature/proof verification before presenting a transaction at
this level.
-/
def TransactionWellFormed (tx : Transaction) : Prop :=
  tx.cochain_commitment.WellFormed

/-- A transaction whose commitment satisfies the full sheaf-semantic contract. -/
def TransactionCochainCoherent
    (S : Hcrypt.Axioms.SheafCoherence)
    (tx : Transaction) : Prop :=
  tx.cochain_commitment.CoherentWith S

/-- A transaction is fresh relative to the already-spent key-image set. -/
def TransactionFresh (spent_key_images : Set ℕ) (tx : Transaction) : Prop :=
  tx.key_image ∉ spent_key_images

/--
Consensus-level transaction acceptance.

This is intentionally abstract: runtime details such as byte decoding,
signature checks, proof transcript validation, and allocation bounds live in
Rust. Lean records the mathematical/state facts Rust must enforce.
-/
def TransactionAccepted (spent_key_images : Set ℕ) (tx : Transaction) : Prop :=
  TransactionWellFormed tx ∧ TransactionFresh spent_key_images tx

/-- Consensus acceptance refined by commitment coherence with a concrete sheaf. -/
def TransactionAcceptedInSheaf
    (S : Hcrypt.Axioms.SheafCoherence)
    (spent_key_images : Set ℕ)
    (tx : Transaction) : Prop :=
  TransactionCochainCoherent S tx ∧ TransactionFresh spent_key_images tx

/-- Sheaf-coherent transaction acceptance inherits ordinary acceptance. -/
theorem transactionAccepted_of_acceptedInSheaf
    {S : Hcrypt.Axioms.SheafCoherence}
    {spent_key_images : Set ℕ}
    {tx : Transaction}
    (h : TransactionAcceptedInSheaf S spent_key_images tx) :
    TransactionAccepted spent_key_images tx :=
  ⟨Hcrypt.Axioms.cochain_wellFormed_of_committedCochainWellFormed h.1, h.2⟩

/-- Every transaction in the block has the abstract well-formed shape. -/
def BlockWellFormed (b : Block) : Prop :=
  ∀ tx ∈ b.transactions, TransactionWellFormed tx

/-- Every transaction commitment in the block is coherent with one sheaf. -/
def BlockCochainsCoherent
    (S : Hcrypt.Axioms.SheafCoherence)
    (b : Block) : Prop :=
  ∀ tx ∈ b.transactions, TransactionCochainCoherent S tx

/-- Semantic block coherence inherits ordinary payload well-formedness. -/
theorem blockWellFormed_of_cochainsCoherent
    {S : Hcrypt.Axioms.SheafCoherence}
    {b : Block}
    (h : BlockCochainsCoherent S b) :
    BlockWellFormed b := by
  intro tx htx
  exact Hcrypt.Axioms.cochain_wellFormed_of_committedCochainWellFormed (h tx htx)

/--
All cochain payloads in a block are bound to the same topology hash.

This is the Lean-side predicate matching the Rust root-accumulation boundary:
commitments from different public topologies must not be aggregated into one
block cochain root.
-/
def BlockCochainTopologyCompatible (b : Block) : Prop :=
  ∀ tx ∈ b.transactions, ∀ ty ∈ b.transactions,
    tx.cochain_commitment.SameTopology ty.cochain_commitment

/--
All cochain payloads in a block have the same declared edge-vector length.

Rust checks this before accumulating edge values; Lean records it as a
mathematical precondition for treating the block body as one cochain batch.
-/
def BlockCochainEdgeCountCompatible (b : Block) : Prop :=
  ∀ tx ∈ b.transactions, ∀ ty ∈ b.transactions,
    tx.cochain_commitment.n_edge_values = ty.cochain_commitment.n_edge_values

/--
Block-level cochain compatibility required before homomorphic accumulation.

`BlockWellFormed` checks each payload individually; the topology and edge-count
conditions check that the block body is one coherent cochain batch.
-/
def BlockCochainPayloadsCompatible (b : Block) : Prop :=
  BlockWellFormed b
    ∧ BlockCochainTopologyCompatible b
    ∧ BlockCochainEdgeCountCompatible b

/-- No transaction in the block spends a previously-spent key image. -/
def BlockFreshAgainst (spent_key_images : Set ℕ) (b : Block) : Prop :=
  ∀ tx ∈ b.transactions, TransactionFresh spent_key_images tx

/--
Consensus-level block acceptance.

`block_valid` captures the existing PoV/geometric block predicate. The extra
fields isolate the runtime/state boundary: every transaction has acceptable
shape, the block cochain payloads form one compatible batch, and every key
image is fresh relative to prior ledger state.
-/
def BlockAccepted (spent_key_images : Set ℕ) (b : Block) : Prop :=
  block_valid b ∧ BlockCochainPayloadsCompatible b ∧ BlockFreshAgainst spent_key_images b

/--
Abstract ledger state used by preservation theorems.

The deployed Rust state contains storage indexes, account balances, roots, and
database metadata. Lean keeps only the parts needed for mathematical
state-transition invariants.
-/
structure LedgerState where
  spent_key_images : Set ℕ
  blocks : List Block

/-- The set of key images spent by a block. -/
def Block.keyImageSet (b : Block) : Set ℕ :=
  {ki | ∃ tx ∈ b.transactions, tx.key_image = ki}

/-- Apply one accepted transaction at the abstract ledger level. -/
def LedgerState.applyTransaction (s : LedgerState) (tx : Transaction) : LedgerState :=
  { s with spent_key_images := Set.insert tx.key_image s.spent_key_images }

/-- Apply one accepted block at the abstract ledger level. -/
def LedgerState.applyBlock (s : LedgerState) (b : Block) : LedgerState :=
  { spent_key_images := s.spent_key_images ∪ b.keyImageSet
  , blocks := b :: s.blocks }

/-- Applying a transaction records its key image as spent. -/
theorem applyTransaction_marks_key_image (s : LedgerState) (tx : Transaction) :
    tx.key_image ∈ (s.applyTransaction tx).spent_key_images := by
  change tx.key_image ∈ Set.insert tx.key_image s.spent_key_images
  exact Set.mem_insert tx.key_image s.spent_key_images

/-- Applying a transaction preserves all previously-spent key images. -/
theorem applyTransaction_preserves_spent
    (s : LedgerState) (tx : Transaction) {ki : ℕ}
    (hki : ki ∈ s.spent_key_images) :
    ki ∈ (s.applyTransaction tx).spent_key_images := by
  change ki ∈ Set.insert tx.key_image s.spent_key_images
  exact Set.mem_insert_of_mem tx.key_image hki

/-- Accepted transactions are fresh relative to the previous ledger state. -/
theorem acceptedTransaction_key_image_fresh
    {s : LedgerState} {tx : Transaction}
    (hacc : TransactionAccepted s.spent_key_images tx) :
    tx.key_image ∉ s.spent_key_images := by
  exact hacc.2

/-- Accepted blocks satisfy the original PoV/geometric validity predicate. -/
theorem blockAccepted_valid
    {spent_key_images : Set ℕ} {b : Block}
    (hacc : BlockAccepted spent_key_images b) :
    block_valid b := by
  exact hacc.1

/-- Accepted blocks have pairwise-fresh key images internally. -/
theorem blockAccepted_key_images_fresh
    {spent_key_images : Set ℕ} {b : Block}
    (hacc : BlockAccepted spent_key_images b) :
    key_images_fresh b.transactions := by
  rcases hacc.1 with ⟨_, _, hfresh, _⟩
  exact hfresh

/-- Accepted blocks have compatible cochain payloads. -/
theorem blockAccepted_cochainPayloadsCompatible
    {spent_key_images : Set ℕ} {b : Block}
    (hacc : BlockAccepted spent_key_images b) :
    BlockCochainPayloadsCompatible b := by
  exact hacc.2.1

/-- Accepted blocks have well-formed transaction payloads. -/
theorem blockAccepted_blockWellFormed
    {spent_key_images : Set ℕ} {b : Block}
    (hacc : BlockAccepted spent_key_images b) :
    BlockWellFormed b := by
  exact hacc.2.1.1

/-- Accepted blocks aggregate only cochain payloads with a shared topology hash. -/
theorem blockAccepted_cochainTopologyCompatible
    {spent_key_images : Set ℕ} {b : Block}
    (hacc : BlockAccepted spent_key_images b) :
    BlockCochainTopologyCompatible b := by
  exact hacc.2.1.2.1

/-- Accepted blocks aggregate only cochain payloads with a shared edge count. -/
theorem blockAccepted_cochainEdgeCountCompatible
    {spent_key_images : Set ℕ} {b : Block}
    (hacc : BlockAccepted spent_key_images b) :
    BlockCochainEdgeCountCompatible b := by
  exact hacc.2.1.2.2

/-- Every transaction in an accepted block is well-formed. -/
theorem blockAccepted_tx_wellFormed
    {spent_key_images : Set ℕ} {b : Block} {tx : Transaction}
    (hacc : BlockAccepted spent_key_images b)
    (htx : tx ∈ b.transactions) :
    TransactionWellFormed tx := by
  exact hacc.2.1.1 tx htx

/-- Accepted blocks spend no key image that was already present in ledger state. -/
theorem blockAccepted_tx_not_previously_spent
    {s : LedgerState} {b : Block} {tx : Transaction}
    (hacc : BlockAccepted s.spent_key_images b)
    (htx : tx ∈ b.transactions) :
    tx.key_image ∉ s.spent_key_images := by
  exact hacc.2.2 tx htx

/-- Applying a block records every transaction key image in that block. -/
theorem applyBlock_marks_tx_key_image
    (s : LedgerState) (b : Block) {tx : Transaction}
    (htx : tx ∈ b.transactions) :
    tx.key_image ∈ (s.applyBlock b).spent_key_images := by
  simp [LedgerState.applyBlock, Block.keyImageSet]
  exact Or.inr ⟨tx, htx, rfl⟩

/-- Applying a block preserves all previously-spent key images. -/
theorem applyBlock_preserves_spent
    (s : LedgerState) (b : Block) {ki : ℕ}
    (hki : ki ∈ s.spent_key_images) :
    ki ∈ (s.applyBlock b).spent_key_images := by
  simp [LedgerState.applyBlock]
  exact Or.inl hki


-- ═══════════════════════════════════════════════════════════════════════
-- AXIOM 3: PoV SELECTION
-- ═══════════════════════════════════════════════════════════════════════

def eligible (v : Validator) : Prop :=
  spectral_gap_in_bounds v ∧ topology_connected v

/-- AXIOM 3: PoV Leader Selection via VRF. -/
def is_selected (v : Validator) (validators : List Validator) (epoch : ℕ)
    (vrf : Validator → ℕ → ℝ) : Prop :=
  eligible v
  ∧ ∀ (w : Validator), w ∈ validators → eligible w → vrf w epoch ≤ vrf v epoch


-- ═══════════════════════════════════════════════════════════════════════
-- AXIOM 4: FORK RESOLUTION
-- ═══════════════════════════════════════════════════════════════════════

def cumulative_gap : Chain → ℝ
  | [] => 0
  | (b :: rest) => b.producer.spectral_gap + cumulative_gap rest

/-- AXIOM 4: Prefer chain with higher cumulative spectral weight. -/
def preferred (c1 c2 : Chain) : Prop :=
  cumulative_gap c1 > cumulative_gap c2


-- ═══════════════════════════════════════════════════════════════════════
-- AXIOM 5: TRANSACTION COMPOSITION ASSOCIATIVITY
-- ═══════════════════════════════════════════════════════════════════════

/-- Transaction composition via canonical cochain commitment addition. -/
def tx_compose (t1 t2 : Transaction) : Transaction :=
  { sender := t1.sender
  , recipient := t2.recipient
  , key_image := t1.key_image + t2.key_image
  , cochain_commitment := t1.cochain_commitment.add t2.cochain_commitment }

-- ── Helper lemmas for foldl / zipWith on ℤ ─────────────────────────

/-- foldl (+) extracts accumulator: foldl (+) a l = a + foldl (+) 0 l. -/
private theorem foldl_add_extract (a : ℤ) (l : List ℤ) :
    l.foldl (· + ·) a = a + l.foldl (· + ·) 0 := by
  induction l generalizing a with
  | nil => simp [List.foldl]
  | cons h t ih =>
    simp only [List.foldl]
    rw [ih (a + h), ih (0 + h)]
    ring

/-- Associativity of zipWith (+) under foldl (+) 0. -/
private theorem zipWith_add_foldl_assoc (a b c : List ℤ) :
    (List.zipWith (· + ·) (List.zipWith (· + ·) a b) c).foldl (· + ·) 0 =
    (List.zipWith (· + ·) a (List.zipWith (· + ·) b c)).foldl (· + ·) 0 := by
  induction a generalizing b c with
  | nil => simp [List.zipWith]
  | cons ha ta ih =>
    cases b with
    | nil => simp [List.zipWith]
    | cons hb tb =>
      cases c with
      | nil => simp [List.zipWith]
      | cons hc tc =>
        simp only [List.zipWith, List.foldl]
        rw [foldl_add_extract (0 + (ha + hb + hc)),
            foldl_add_extract (0 + (ha + (hb + hc)))]
        have : (0 : ℤ) + (ha + hb + hc) = 0 + (ha + (hb + hc)) := by ring
        rw [this]
        congr 1
        exact ih tb tc

/-- zipWith (+) l (replicate l.length 0) = l. -/
private theorem zipWith_add_replicate_zero_right (l : List ℤ) :
    List.zipWith (· + ·) l (List.replicate l.length 0) = l := by
  induction l with
  | nil => rfl
  | cons h t ih => simp [List.replicate, ih]

/-- zipWith (+) (replicate l.length 0) l = l. -/
private theorem zipWith_add_replicate_zero_left (l : List ℤ) :
    List.zipWith (· + ·) (List.replicate l.length 0) l = l := by
  induction l with
  | nil => rfl
  | cons h t ih => simp [List.replicate, ih]

-- ── Axiom 5 theorems ───────────────────────────────────────────────

/-- AXIOM 5: Transaction Composition is Associative (on commitment sums). -/
theorem tx_compose_assoc_sum (t1 t2 t3 : Transaction) :
    (tx_compose (tx_compose t1 t2) t3).commitment_sum =
    (tx_compose t1 (tx_compose t2 t3)).commitment_sum := by
  simp only [tx_compose, Transaction.commitment_sum]
  exact zipWith_add_foldl_assoc _ _ _

/-- Zero transaction with n zero-valued edges (identity element). -/
def zero_tx_n (n : ℕ) : Transaction :=
  { sender := 0
  , recipient := 0
  , key_image := 0
  , cochain_commitment := Hcrypt.Axioms.CochainCommitmentData.zero n }

/-- Right identity: composing t with zero_tx_n preserves commitment sum. -/
theorem tx_compose_identity_right_sum (t : Transaction) :
    (tx_compose t (zero_tx_n t.cochain_commitment.edge_values.length)).commitment_sum
    = t.commitment_sum := by
  simp only [tx_compose, zero_tx_n, Transaction.commitment_sum,
    Hcrypt.Axioms.CochainCommitmentData.add,
    Hcrypt.Axioms.CochainCommitmentData.zero,
    Hcrypt.Axioms.CochainCommitmentData.commitment_sum]
  rw [zipWith_add_replicate_zero_right]

/-- Left identity: composing zero_tx_n with t preserves commitment sum. -/
theorem tx_compose_identity_left_sum (t : Transaction) :
    (tx_compose (zero_tx_n t.cochain_commitment.edge_values.length) t).commitment_sum
    = t.commitment_sum := by
  simp only [tx_compose, zero_tx_n, Transaction.commitment_sum,
    Hcrypt.Axioms.CochainCommitmentData.add,
    Hcrypt.Axioms.CochainCommitmentData.zero,
    Hcrypt.Axioms.CochainCommitmentData.commitment_sum]
  rw [zipWith_add_replicate_zero_left]


-- ═══════════════════════════════════════════════════════════════════════
-- AXIOM 6: SYBIL RESISTANCE
-- ═══════════════════════════════════════════════════════════════════════

def quadratic_weight (gap : ℝ) : ℝ := gap ^ 2

/-- AXIOM 6: Sybil Resistance — splitting reduces total weight. -/
theorem sybil_resistance (gap : ℝ) (N : ℕ) (hgap : 0 < gap) (hN : 1 < N) :
    (N : ℝ) * quadratic_weight (gap / N) < quadratic_weight gap := by
  simp [quadratic_weight]
  rw [div_pow, mul_div_assoc']
  have hN_pos : (0 : ℝ) < (N : ℝ) := Nat.cast_pos'.mpr (by omega)
  have hN_sq_pos : (0 : ℝ) < (N : ℝ) ^ 2 := by positivity
  have hN_gt_one : (1 : ℝ) < (N : ℝ) := Nat.one_lt_cast.mpr hN
  have hgap_sq_pos : (0 : ℝ) < gap ^ 2 := by positivity
  rw [div_lt_iff₀ hN_sq_pos]
  -- Goal: ↑N * gap ^ 2 < gap ^ 2 * ↑N ^ 2
  have hN_lt_sq : (N : ℝ) < (N : ℝ) ^ 2 := by
    rw [sq]; exact lt_mul_of_one_lt_left hN_pos hN_gt_one
  calc ↑N * gap ^ 2
      < ↑N ^ 2 * gap ^ 2 := mul_lt_mul_of_pos_right hN_lt_sq hgap_sq_pos
    _ = gap ^ 2 * ↑N ^ 2 := by ring


-- ═══════════════════════════════════════════════════════════════════════
-- DERIVED PROPERTIES
-- ═══════════════════════════════════════════════════════════════════════

theorem valid_chain_increasing (b : Block) (c : Chain) (h : ℕ)
    (hext : block_extends b c h) :
    b.height = chain_height c + 1 :=
  hext.2.2

theorem fork_resolution_transitive (c1 c2 c3 : Chain)
    (h12 : preferred c1 c2) (h23 : preferred c2 c3) :
    preferred c1 c3 := by
  simp [preferred] at *
  linarith

theorem eligible_implies_connected (v : Validator) (h : eligible v) :
    v.betti_0 = 1 :=
  h.2


-- ═══════════════════════════════════════════════════════════════════════
-- PAPER-1 HARDNESS BOUNDARY
-- ═══════════════════════════════════════════════════════════════════════

/-
  This file does not import `Hardness.lean`. It is a protocol/chain axiomatization
  surface for Paper 2.

  `Hardness.lean` is the Paper 1 theorem surface for HCP, hidden-operator
  ambiguity, and the CVP comparison. Those theorems justify the mathematical
  recovery problem, but they are not chain axioms and are not used as Lean
  dependencies here.

  Axiom 3 (PoV selection):
    VRF unpredictability and spectral admissibility are protocol assumptions
    recorded in the consensus/runtime layer.

  Axiom 4 (fork resolution):
    cumulative_gap is treated as a chain-level score over admitted blocks.

  Axiom 6 (Sybil resistance):
    Even if an attacker creates many validators, quadratic weighting
    ensures total influence DECREASES. Combined with PoV bounds,
    sub-threshold validators get negligible weight.
-/

end
