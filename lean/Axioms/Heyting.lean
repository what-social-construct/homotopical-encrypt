import Mathlib

/-
  Heyting collapse interface for runtime consensus truth values.

  Paper correspondence:
  - Paper 1 Section 4: Heyting/public judgment surface used by HCP.
  - Paper 2: full consensus policy and runtime consumption of the collapsed
    truth value.

  This module is intentionally constructive at the 3-valued layer:
  - defines a concrete 3-element chain,
  - defines meet/join/implication,
  - proves residuation (hence valid Heyting implication on the chain).

  Semantic scope:
  - `Heyting3` is not the full internal logic of the hidden fibration/topos.
  - It is the runtime/public collapse used by consensus and oracle gates.
  - The richer Ω may carry provenance, open-set, sheaf, or path-space semantics.
  - The collapse Ω → `Heyting3` is intentionally lossy: many hidden witnesses
    may have the same public truth value.

  This matches the project architecture:
  - Helfer-style first-order homotopical logic supplies path-based equality and
    homotopy-invariant hidden semantics.
  - Profinite/completion viewpoints for Heyting algebras justify treating finite
    public judgments as shadows of richer intuitionistic semantic objects.
  - Runtime consensus only consumes the quotient/collapse, not the hidden object.
-/

namespace Hcrypt
namespace Axioms

universe u

/-- Runtime 3-valued truth object: ⊥ < ½ < ⊤. -/
inductive Heyting3
  | Invalid
  | Undetermined
  | Valid
  deriving DecidableEq, Repr

instance : LE Heyting3 where
  le a b :=
    match a, b with
    | .Invalid, _ => True
    | .Undetermined, .Invalid => False
    | .Undetermined, _ => True
    | .Valid, .Valid => True
    | .Valid, _ => False

instance : DecidableRel (fun a b : Heyting3 => a ≤ b) := by
  intro a b
  cases a <;> cases b
  · exact isTrue trivial
  · exact isTrue trivial
  · exact isTrue trivial
  · exact isFalse (by intro h; cases h)
  · exact isTrue trivial
  · exact isTrue trivial
  · exact isFalse (by intro h; cases h)
  · exact isFalse (by intro h; cases h)
  · exact isTrue trivial

/-- Meet on the chain (min). -/
def meet (a b : Heyting3) : Heyting3 :=
  match a, b with
  | .Invalid, _ => .Invalid
  | .Undetermined, .Invalid => .Invalid
  | .Undetermined, _ => .Undetermined
  | .Valid, x => x

/-- Join on the chain (max). -/
def join (a b : Heyting3) : Heyting3 :=
  match a, b with
  | .Invalid, x => x
  | .Undetermined, .Valid => .Valid
  | .Undetermined, _ => .Undetermined
  | .Valid, _ => .Valid

/--
Heyting implication on a finite chain:

  a → b = ⊤, if a ≤ b
  a → b = b, otherwise
-/
def himp (a b : Heyting3) : Heyting3 :=
  match a, b with
  | .Invalid, _ => .Valid
  | .Undetermined, .Invalid => .Invalid
  | .Undetermined, _ => .Valid
  | .Valid, x => x

/-- Negation in the chain Heyting algebra: ¬a = a → ⊥. -/
def negate (a : Heyting3) : Heyting3 :=
  himp a .Invalid

/-- Double negation in the chain Heyting algebra. -/
def doubleNegate (a : Heyting3) : Heyting3 :=
  negate (negate a)

/-- Core Heyting law for the 3-chain: residuation. -/
theorem himp_residuation (a b c : Heyting3) :
    c ≤ himp a b ↔ meet a c ≤ b := by
  cases a <;> cases b <;> cases c <;> decide

/-- Canonical truth-table point: U → I = I in the chain Heyting algebra. -/
theorem undetermined_implies_invalid :
    himp .Undetermined .Invalid = .Invalid := by
  decide

/-- Consequently, ¬U = I in the chain Heyting algebra. -/
theorem negate_undetermined :
    negate .Undetermined = .Invalid := by
  decide

/-- And ¬¬U = V for this 3-chain. -/
theorem doubleNegate_undetermined :
    doubleNegate .Undetermined = .Valid := by
  decide

/--
The finite runtime chain is still non-classical: double-negation elimination
fails at the public boundary value `Undetermined`.
-/
theorem doubleNegation_elimination_fails_at_undetermined :
    ¬ doubleNegate .Undetermined ≤ .Undetermined := by
  decide

/--
Consequently, the runtime collapse should not be read as validating classical
Boolean reasoning globally.
-/
theorem not_doubleNegationEliminates_Heyting3 :
    ¬ (∀ a : Heyting3, doubleNegate a ≤ a) := by
  intro h
  exact doubleNegation_elimination_fails_at_undetermined (h .Undetermined)

/--
Abstract Heyting carrier used for Ω-like semantics.
`residuation` is the key law required for implication.
-/
structure AbstractHeyting (Ω : Type u) where
  le : Ω → Ω → Prop
  top : Ω
  bot : Ω
  inf : Ω → Ω → Ω
  sup : Ω → Ω → Ω
  imp : Ω → Ω → Ω
  residuation : ∀ a b c, le c (imp a b) ↔ le (inf a c) b

/--
Heyting collapse map Ω → Heyting3 preserving the Heyting structure.
This is the formal target for an "image/collapse" theorem.
-/
structure HeytingCollapse {Ω : Type u} (H : AbstractHeyting Ω) where
  π : Ω → Heyting3
  mapTop : π H.top = .Valid
  mapBot : π H.bot = .Invalid
  mapInf : ∀ x y, π (H.inf x y) = meet (π x) (π y)
  mapSup : ∀ x y, π (H.sup x y) = join (π x) (π y)
  mapImp : ∀ x y, π (H.imp x y) = himp (π x) (π y)

/--
The public equivalence induced by a runtime Heyting collapse.

Two richer Ω-witnesses may be distinct while becoming indistinguishable to the
runtime consensus layer.
-/
def SamePublicTruth {Ω : Type u} {H : AbstractHeyting Ω}
    (C : HeytingCollapse H) (x y : Ω) : Prop :=
  C.π x = C.π y

/-- Public truth equivalence is reflexive. -/
theorem samePublicTruth_refl {Ω : Type u} {H : AbstractHeyting Ω}
    (C : HeytingCollapse H) (x : Ω) :
    SamePublicTruth C x x := by
  rfl

/-- Public truth equivalence is symmetric. -/
theorem samePublicTruth_symm {Ω : Type u} {H : AbstractHeyting Ω}
    {C : HeytingCollapse H} {x y : Ω} :
    SamePublicTruth C x y → SamePublicTruth C y x := by
  intro h
  exact h.symm

/-- Public truth equivalence is transitive. -/
theorem samePublicTruth_trans {Ω : Type u} {H : AbstractHeyting Ω}
    {C : HeytingCollapse H} {x y z : Ω} :
    SamePublicTruth C x y → SamePublicTruth C y z → SamePublicTruth C x z := by
  intro hxy hyz
  exact hxy.trans hyz

/--
A collapse is non-faithful when distinct hidden witnesses share a public truth
value. This is the Heyting-side analogue of the hidden-representative ambiguity
used in the Hodge hardness file.
-/
def CollapseNonFaithful {Ω : Type u} {H : AbstractHeyting Ω}
    (C : HeytingCollapse H) : Prop :=
  ∃ x y : Ω, x ≠ y ∧ SamePublicTruth C x y

/--
The collapsed image satisfies residuation in `Heyting3`.
This theorem is immediate from `himp_residuation` and serves as a reusable
bridge for downstream oracle/topos policy lemmas.
-/
theorem collapse_residuation {Ω : Type u} (H : AbstractHeyting Ω)
    (C : HeytingCollapse H) (a b c : Ω) :
    C.π c ≤ himp (C.π a) (C.π b) ↔ meet (C.π a) (C.π c) ≤ C.π b := by
  simpa using himp_residuation (C.π a) (C.π b) (C.π c)

end Axioms
end Hcrypt
