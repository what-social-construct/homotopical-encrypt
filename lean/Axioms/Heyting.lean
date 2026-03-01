import Mathlib

/-
  Heyting collapse interface for runtime consensus truth values.

  This module is intentionally constructive at the 3-valued layer:
  - defines a concrete 3-element chain,
  - defines meet/join/implication,
  - proves residuation (hence valid Heyting implication on the chain).

  It also defines an abstract interface for collapsing a richer Heyting algebra
  Ω (e.g. coalition/open-set semantics) into this 3-valued image.
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
