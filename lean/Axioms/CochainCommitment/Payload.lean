import Mathlib.Data.Int.Basic
import Mathlib.Data.UInt
import Mathlib.Tactic

/-
  Cochain commitment payload.

  Paper correspondence:
  - Paper 1 Section 5: cochain commitment payload shape and well-formedness.
  - Paper 1 Section 6: consumed by the Plucker-to-cochain proximity bridge.

  Canonical wire-facing cochain commitment data shared by Lean, Python, and
  Rust. This file intentionally contains only the payload shape, lightweight
  well-formedness predicates, operations, and cheap lemmas.
-/

namespace Hcrypt
namespace Axioms

/-- Canonical commitment modulus used by the current Python/Rust commitment path. -/
def canonicalCochainModulus : ℕ := 12289

/-- Wire-format header bytes: modulus(4 LE) + n_edges(4 LE). -/
def cochainCommitmentHeaderBytes : ℕ := 8

/-- Each edge value is serialized as an i64, so 8 bytes. -/
def cochainCommitmentBytesPerEdge : ℕ := 8

/-- The topology hash suffix is currently 16 bytes. -/
def cochainCommitmentTopologyHashBytes : ℕ := 16

/-- Canonical byte length for a commitment with `n` edge values. -/
def cochainCommitmentWireLength (n : ℕ) : ℕ :=
  cochainCommitmentHeaderBytes
    + n * cochainCommitmentBytesPerEdge
    + cochainCommitmentTopologyHashBytes

/--
  A cochain commitment instance.

  Mirrors the wire format from Python/Rust:
    modulus(4 LE) + n_edges(4 LE) + edge_values(n × 8 i64 LE) + topology_hash(16)

  The edge values serialize the public exact `C¹` value `δ₀(a) mod q`.
  The topology hash is a declared 16-byte context tag. Authentication and the
  stronger `SheafStateSnapshot` root binding live in outer interfaces.
-/
structure CochainCommitmentData where
  /-- Commitment modulus q (default 12289 in Python/Rust). -/
  modulus : ℕ
  /-- Declared number of edge values (= |E| × stalk_dim). -/
  n_edge_values : ℕ
  /-- Actual commitment vector in C¹, represented by serialized edge values. -/
  edge_values : List ℤ
  /-- Declared topology tag; cryptographic/context binding is separate. -/
  topology_hash : Fin 16 → UInt8

namespace CochainCommitmentData

/-- The declared edge count agrees with the actual edge vector length. -/
def EdgeCountMatches (c : CochainCommitmentData) : Prop :=
  c.n_edge_values = c.edge_values.length

/-- The commitment has at least one edge value. -/
def NonemptyEdges (c : CochainCommitmentData) : Prop :=
  0 < c.n_edge_values

/-- The commitment uses the canonical modulus currently accepted by consensus. -/
def SupportedModulus (c : CochainCommitmentData) : Prop :=
  c.modulus = canonicalCochainModulus

/--
Consensus-facing well-formedness for the cochain commitment payload.

Rust owns byte parsing and allocation bounds. Lean records the shape that must
hold once bytes have been accepted as a cochain commitment.
-/
def WellFormed (c : CochainCommitmentData) : Prop :=
  SupportedModulus c ∧ EdgeCountMatches c ∧ NonemptyEdges c

/-- Summary scalar used by the current chain-level balance proofs. -/
def commitment_sum (c : CochainCommitmentData) : ℤ :=
  c.edge_values.foldl (· + ·) 0

/-- Two commitments are bound to the same public topology hash. -/
def SameTopology (c d : CochainCommitmentData) : Prop :=
  c.topology_hash = d.topology_hash

/-- Commitments can be added when their modulus, topology, and edge count agree. -/
def AddCompatible (c d : CochainCommitmentData) : Prop :=
  WellFormed c
    ∧ WellFormed d
    ∧ c.modulus = d.modulus
    ∧ c.n_edge_values = d.n_edge_values
    ∧ SameTopology c d

/-- Homomorphic addition at the payload level. -/
def add (c d : CochainCommitmentData) : CochainCommitmentData :=
  { modulus := c.modulus
  , n_edge_values := c.n_edge_values
  , edge_values := List.zipWith (· + ·) c.edge_values d.edge_values
  , topology_hash := c.topology_hash }

/-- Zero payload with `n` edge values for identity-style chain lemmas. -/
def zero (n : ℕ) : CochainCommitmentData :=
  { modulus := canonicalCochainModulus
  , n_edge_values := n
  , edge_values := List.replicate n 0
  , topology_hash := fun _ => 0 }

/-- A well-formed commitment has nonempty edge values. -/
theorem edge_values_nonempty_of_wellFormed
    {c : CochainCommitmentData} (hc : WellFormed c) :
    c.edge_values.length > 0 := by
  exact hc.2.1 ▸ hc.2.2

/-- A well-formed commitment has modulus greater than one. -/
theorem modulus_gt_one_of_wellFormed
    {c : CochainCommitmentData} (hc : WellFormed c) :
    c.modulus > 1 := by
  unfold WellFormed SupportedModulus canonicalCochainModulus at hc
  omega

/-- The canonical zero payload is well-formed exactly when `n > 0`. -/
theorem zero_wellFormed {n : ℕ} (hn : 0 < n) :
    WellFormed (zero n) := by
  unfold WellFormed SupportedModulus EdgeCountMatches NonemptyEdges zero
  simp [canonicalCochainModulus, hn]

end CochainCommitmentData

end Axioms
end Hcrypt
