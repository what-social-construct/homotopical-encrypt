module

public import Axioms.CochainCommitment.Payload
public import Mathlib.Data.ZMod.Basic
public import Mathlib.Data.List.OfFn

@[expose] public section

/-!
# Constant-translation ambiguity of the ordinary graph commitment

This module models the restricted graph-incidence operator implemented by
`rust/node/src/crypto/commitment.rs`: an ordered edge `(u,v)` contributes
`a(v,j) - a(u,j)` in each common stalk coordinate. It does not model arbitrary
cellular restriction maps, private Hodge operators or harmonic blinding.

Adding the same stalk vector at every vertex leaves every edge coordinate
unchanged. A nonzero translation changes the designated message coordinate,
so neither the edge payload nor any deterministic encoding/hash of that same
payload binds that message. For modular assignments, the payload below is the
existing `CochainCommitmentData`, with canonical residue representatives and
one fixed topology tag. This is the actual algebraic ambiguity, rather than an
assumed cryptographic collision or a new hiding claim. It agrees with treating
coboundary openings modulo the information retained by the differential.

Rust parsing, integer overflow and byte serialization are separate contracts;
these theorems concern the stated modular incidence computation.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Sheaf.GraphCommitment

/-- The actual edge order and common stalk dimension of the runtime graph. -/
structure Layout (Vertex : Type*) where
  edges : List (Vertex × Vertex)
  stalkDim : ℕ

/-- One stalk vector at each vertex; no sheaf restriction maps are supplied. -/
abbrev Assignment {Vertex : Type*} (graph : Layout Vertex) (A : Type*) :=
  Vertex → Fin graph.stalkDim → A

variable {Vertex A Encoded : Type*} (graph : Layout Vertex)

/-- Runtime order is edge-major and then stalk-coordinate-major. -/
def edgeCoordinates [Sub A] (a : Assignment graph A) : List A :=
  graph.edges.flatMap fun edge =>
    List.ofFn fun coordinate : Fin graph.stalkDim => a edge.2 coordinate - a edge.1 coordinate

/-- Translate every vertex by the same stalk vector. -/
def translate [Add A] (a : Assignment graph A) (shift : Fin graph.stalkDim → A) :
    Assignment graph A :=
  fun vertex coordinate => a vertex coordinate + shift coordinate

theorem edgeCoordinates_length [Sub A] (a : Assignment graph A) :
    (edgeCoordinates graph a).length = graph.edges.length * graph.stalkDim := by
  unfold edgeCoordinates
  induction graph.edges with
  | nil => simp
  | cons edge rest ih => simp [ih, Nat.add_mul, Nat.add_comm]

/-- Global constant translation lies in the kernel of this incidence operator. -/
theorem edgeCoordinates_translate [AddCommGroup A] (a : Assignment graph A)
    (shift : Fin graph.stalkDim → A) :
    edgeCoordinates graph (translate graph a shift) = edgeCoordinates graph a := by
  simp [edgeCoordinates, translate]

/-- A nonzero translation changes the designated vertex/coordinate message. -/
theorem translate_coordinate_ne [AddCommGroup A] (a : Assignment graph A)
    (shift : Fin graph.stalkDim → A) (vertex : Vertex) (coordinate : Fin graph.stalkDim)
    (nonzero : shift coordinate ≠ 0) :
    translate graph a shift vertex coordinate ≠ a vertex coordinate := by
  simpa only [translate, ne_eq, add_eq_left] using nonzero

/-- Postprocessing an identical edge list cannot remove its alternative openings. -/
theorem observe_translate [AddCommGroup A] (observe : List A → Encoded)
    (a : Assignment graph A) (shift : Fin graph.stalkDim → A) :
    observe (edgeCoordinates graph (translate graph a shift)) =
      observe (edgeCoordinates graph a) :=
  congrArg observe (edgeCoordinates_translate graph a shift)

/-- Different messages have the same observed edge data even after deterministic postprocessing. -/
theorem alternative_observed_opening [AddCommGroup A] (observe : List A → Encoded)
    (a : Assignment graph A) (shift : Fin graph.stalkDim → A)
    (vertex : Vertex) (coordinate : Fin graph.stalkDim) (nonzero : shift coordinate ≠ 0) :
    ∃ other : Assignment graph A,
      other vertex coordinate ≠ a vertex coordinate ∧
        observe (edgeCoordinates graph other) = observe (edgeCoordinates graph a) :=
  ⟨translate graph a shift, translate_coordinate_ne graph a shift vertex coordinate nonzero,
    observe_translate graph observe a shift⟩

/-- In particular the assignment-to-observation map is not injective. -/
theorem not_injective_observe [AddCommGroup A] (observe : List A → Encoded)
    (a : Assignment graph A) (shift : Fin graph.stalkDim → A)
    (vertex : Vertex) (coordinate : Fin graph.stalkDim) (nonzero : shift coordinate ≠ 0) :
    ¬ Function.Injective (fun opening : Assignment graph A =>
      observe (edgeCoordinates graph opening)) := by
  intro injective
  have same := injective (observe_translate graph observe a shift)
  exact translate_coordinate_ne graph a shift vertex coordinate nonzero
    (congrFun (congrFun same vertex) coordinate)

section Modular

variable {q : ℕ}

/-- Existing public payload with residues in `[0,q)`, fixed topology and the original order. -/
def payload [NeZero q] (topology : Fin 16 → UInt8) (a : Assignment graph (ZMod q)) :
    Axioms.CochainCommitmentData where
  modulus := q
  n_edge_values := graph.edges.length * graph.stalkDim
  edge_values := (edgeCoordinates graph a).map fun value => (value.val : ℤ)
  topology_hash := topology

variable [NeZero q]

theorem payload_edgeCountMatches (topology : Fin 16 → UInt8)
    (a : Assignment graph (ZMod q)) :
    (payload graph topology a).EdgeCountMatches := by
  simp [Axioms.CochainCommitmentData.EdgeCountMatches, payload, edgeCoordinates_length]

/-- The existing shape predicate follows under the actual canonical-modulus/nonempty profile. -/
theorem payload_wellFormed (topology : Fin 16 → UInt8)
    (a : Assignment graph (ZMod q)) (canonical : q = Axioms.canonicalCochainModulus)
    (nonempty : 0 < graph.edges.length * graph.stalkDim) :
    (payload graph topology a).WellFormed :=
  ⟨canonical, payload_edgeCountMatches graph topology a, nonempty⟩

/-- Equal edge residues give equal full payloads, including the fixed header/tag. -/
theorem payload_translate (topology : Fin 16 → UInt8)
    (a : Assignment graph (ZMod q)) (shift : Fin graph.stalkDim → ZMod q) :
    payload graph topology (translate graph a shift) = payload graph topology a := by
  simp only [payload, edgeCoordinates_translate]

/-- Any deterministic serializer/hash of this unchanged payload has the same output. -/
theorem encoded_payload_translate (encode : Axioms.CochainCommitmentData → Encoded)
    (topology : Fin 16 → UInt8) (a : Assignment graph (ZMod q))
    (shift : Fin graph.stalkDim → ZMod q) :
    encode (payload graph topology (translate graph a shift)) =
      encode (payload graph topology a) :=
  congrArg encode (payload_translate graph topology a shift)

/-- The original payload admits an explicit different-message modular opening. -/
theorem alternative_payload_opening (topology : Fin 16 → UInt8)
    (a : Assignment graph (ZMod q)) (shift : Fin graph.stalkDim → ZMod q)
    (vertex : Vertex) (coordinate : Fin graph.stalkDim) (nonzero : shift coordinate ≠ 0) :
    ∃ other : Assignment graph (ZMod q),
      other vertex coordinate ≠ a vertex coordinate ∧
        payload graph topology other = payload graph topology a :=
  ⟨translate graph a shift, translate_coordinate_ne graph a shift vertex coordinate nonzero,
    payload_translate graph topology a shift⟩

/-- Full payload equality does not imply equality of the committed message coordinate. -/
theorem not_messageBinding (topology : Fin 16 → UInt8)
    (a : Assignment graph (ZMod q)) (shift : Fin graph.stalkDim → ZMod q)
    (vertex : Vertex) (coordinate : Fin graph.stalkDim) (nonzero : shift coordinate ≠ 0) :
    ¬ (∀ left right : Assignment graph (ZMod q),
      payload graph topology left = payload graph topology right →
        left vertex coordinate = right vertex coordinate) := by
  intro binding
  exact translate_coordinate_ne graph a shift vertex coordinate nonzero
    (binding (translate graph a shift) a (payload_translate graph topology a shift))

end Modular

namespace PathThree

/-- Three vertices with the exact ordered edges `(0,1),(1,2)` and one coordinate. -/
def layout : Layout (Fin 3) := ⟨[(0, 1), (1, 2)], 1⟩

/-- The first runtime opening has message three and random shares five/nine. -/
def original : Assignment layout (ZMod 12289) :=
  fun vertex _ => ![3, 5, 9] vertex

/-- The alternative opening adds seven to every vertex. -/
def shifted : Assignment layout (ZMod 12289) :=
  translate layout original (fun _ => 7)

theorem shifted_values : shifted = fun vertex _ => (![10, 12, 16] vertex : ZMod 12289) := by
  funext vertex coordinate
  fin_cases vertex <;> norm_num [shifted, translate, original]

theorem original_edges : edgeCoordinates layout original = [2, 4] := by
  norm_num [edgeCoordinates, layout, original, List.ofFn_succ]

theorem shifted_edges : edgeCoordinates layout shifted = [2, 4] := by
  rw [shifted, edgeCoordinates_translate, original_edges]

theorem messages_differ :
    shifted 0 ⟨0, by decide⟩ ≠ original 0 ⟨0, by decide⟩ := by
  decide

/-- Both distinct message openings give the same actual canonical payload. -/
theorem payload_collision (topology : Fin 16 → UInt8) :
    payload layout topology shifted = payload layout topology original :=
  payload_translate layout topology original (fun _ => 7)

theorem original_payload_edges (topology : Fin 16 → UInt8) :
    (payload layout topology original).edge_values = [2, 4] := by
  rw [payload, original_edges]
  change [(((2 : ZMod 12289).val : ℕ) : ℤ), (((4 : ZMod 12289).val : ℕ) : ℤ)] = [2, 4]
  decide

theorem original_payload_wellFormed (topology : Fin 16 → UInt8) :
    (payload layout topology original).WellFormed := by
  apply payload_wellFormed layout topology original rfl
  norm_num [layout]

theorem shifted_payload_wellFormed (topology : Fin 16 → UInt8) :
    (payload layout topology shifted).WellFormed := by
  rw [payload_collision]
  exact original_payload_wellFormed topology

/-- No deterministic payload encoding restores message binding in this example. -/
theorem encoded_collision (encode : Axioms.CochainCommitmentData → Encoded)
    (topology : Fin 16 → UInt8) :
    encode (payload layout topology shifted) = encode (payload layout topology original) :=
  congrArg encode (payload_collision topology)

end PathThree

end HomotopicalEncryption.Sheaf.GraphCommitment
