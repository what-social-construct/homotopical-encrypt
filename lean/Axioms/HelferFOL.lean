import Mathlib

/-
  Helfer-oriented first-order homotopical logic interface.

  Paper correspondence:
  - Paper 1 Section 4: fibrational semantics and public equality semantics.
  - Paper 1 Section 7: Lean theorem-surface correspondence.

  Provenance/scope label:
  this module is a Lean interface inspired by Helfer-style first-order
  homotopical logic, especially path/diagonal semantics and fibration-style
  lifting principles. It is a formalization/specification boundary for external
  paper semantics, not a claim that the repo reproves the source paper.

  This module is Lean-first specification glue for the core paper semantics:
  - equality interpreted by path space / diagonal semantics,
  - Grothendieck-fibration style lifting assumptions,
  - Σ/Π behavior at the level of proof obligations,
  - homotopy-invariance of first-order statements.

  Role in the hcrypt stack:
  - this file owns the hidden semantic layer: equality is witnessed by paths,
    not by strict syntactic identity;
  - `Axioms.Heyting` owns the runtime/public truth collapse consumed by the
    protocol;
  - `Axioms.OracleModality` owns the public oracle/sheafification boundary;
  - `Hardness.lean` uses the resulting representative ambiguity to state why a
    CVP oracle for an already-presented lattice does not identify the hidden
    Hodge operator.

  It is intentionally axiomatic (interface-level) so implementation contracts
  in Python/Rust can be tied to explicit logical obligations while deeper
  constructive proofs are incrementally developed.

  Primitive split:
  - path equality is theorem/interface-owned here;
  - public class/fingerprint equality is a lossy classifier over hidden objects;
  - a class-membership witness is hidden path data whose public shadow is only
    equality of classifier values.
-/

namespace Hcrypt
namespace Axioms

universe u v

/-- Minimal path-space interface used for first-order equality semantics. -/
class HasPathSpace (A : Type u) where
  Path : A → A → Type u

/-- Axioms making the path-space interpretation an equivalence-style relation. -/
class PathAxioms (A : Type u) extends HasPathSpace A where
  refl : ∀ x : A, Path x x
  symm : ∀ {x y : A}, Path x y → Path y x
  trans : ∀ {x y z : A}, Path x y → Path y z → Path x z

/-- The diagonal statement: equality is interpreted by inhabited path-space. -/
def EqualityByPaths {A : Type u} [HasPathSpace A] (x y : A) : Prop :=
  Nonempty (HasPathSpace.Path x y)

theorem equalityByPaths_refl {A : Type u} [PathAxioms A] (x : A) :
  EqualityByPaths x x := by
  exact ⟨PathAxioms.refl x⟩

theorem equalityByPaths_symm {A : Type u} [PathAxioms A] {x y : A} :
  EqualityByPaths x y → EqualityByPaths y x := by
  intro hxy
  rcases hxy with ⟨p⟩
  exact ⟨PathAxioms.symm p⟩

theorem equalityByPaths_trans {A : Type u} [PathAxioms A] {x y z : A} :
  EqualityByPaths x y → EqualityByPaths y z → EqualityByPaths x z := by
  intro hxy hyz
  rcases hxy with ⟨p₁⟩
  rcases hyz with ⟨p₂⟩
  exact ⟨PathAxioms.trans p₁ p₂⟩

/-- Alias used when the path-space interpretation is treated as equivalence. -/
abbrev PathEquivalent {A : Type u} [HasPathSpace A] (x y : A) : Prop :=
  EqualityByPaths x y

/-- Path equivalence is reflexive under the path axioms. -/
theorem pathEquivalent_refl {A : Type u} [PathAxioms A] (x : A) :
    PathEquivalent x x :=
  equalityByPaths_refl x

/-- Path equivalence is symmetric under the path axioms. -/
theorem pathEquivalent_symm {A : Type u} [PathAxioms A] {x y : A} :
    PathEquivalent x y → PathEquivalent y x :=
  equalityByPaths_symm

/-- Path equivalence is transitive under the path axioms. -/
theorem pathEquivalent_trans {A : Type u} [PathAxioms A] {x y z : A} :
    PathEquivalent x y → PathEquivalent y z → PathEquivalent x z :=
  equalityByPaths_trans

/-- Public classifier/fingerprint map from hidden objects to public class data. -/
structure PublicClassifier (A : Type u) (P : Type v) where
  π : A → P

/-- Two hidden objects have the same public class/fingerprint. -/
def SamePublicClass {A : Type u} {P : Type v}
    (C : PublicClassifier A P) (x y : A) : Prop :=
  C.π x = C.π y

/-- Hidden fiber over a public class/fingerprint value. -/
def PublicFiber {A : Type u} {P : Type v}
    (C : PublicClassifier A P) (p : P) : Set A :=
  { x | C.π x = p }

/-- Public class of a hidden representative. -/
def PublicClassOf {A : Type u} {P : Type v}
    (C : PublicClassifier A P) (x : A) : Set A :=
  PublicFiber C (C.π x)

/-- Every representative lies in its own public class. -/
theorem mem_publicClassOf_self {A : Type u} {P : Type v}
    (C : PublicClassifier A P) (x : A) :
    x ∈ PublicClassOf C x := by
  rfl

/-- Same-public-class is reflexive. -/
theorem samePublicClass_refl {A : Type u} {P : Type v}
    (C : PublicClassifier A P) (x : A) :
    SamePublicClass C x x := by
  rfl

/-- Same-public-class is symmetric. -/
theorem samePublicClass_symm {A : Type u} {P : Type v}
    {C : PublicClassifier A P} {x y : A} :
    SamePublicClass C x y → SamePublicClass C y x := by
  intro h
  exact h.symm

/-- Same-public-class is transitive. -/
theorem samePublicClass_trans {A : Type u} {P : Type v}
    {C : PublicClassifier A P} {x y z : A} :
    SamePublicClass C x y → SamePublicClass C y z → SamePublicClass C x z := by
  intro hxy hyz
  exact hxy.trans hyz

/-- Path equality respects the public classifier. -/
def PathRespectsPublicClass {A : Type u} {P : Type v} [HasPathSpace A]
    (C : PublicClassifier A P) : Prop :=
  ∀ {x y : A}, PathEquivalent x y → SamePublicClass C x y

/-- Hidden witness that a secret representative lies in a public class. -/
structure ClassMembershipWitness {A : Type u} {P : Type v} [HasPathSpace A]
    (C : PublicClassifier A P) (secret representative : A) where
  path : HasPathSpace.Path secret representative

/-- A class-membership witness entails path equality. -/
theorem classMembership_path {A : Type u} {P : Type v} [HasPathSpace A]
    {C : PublicClassifier A P} {secret representative : A}
    (w : ClassMembershipWitness C secret representative) :
    PathEquivalent secret representative := by
  exact ⟨w.path⟩

/-- A class-membership witness has a public shadow when paths preserve class data. -/
theorem classMembership_samePublicClass {A : Type u} {P : Type v} [HasPathSpace A]
    {C : PublicClassifier A P} (hC : PathRespectsPublicClass C)
    {secret representative : A}
    (w : ClassMembershipWitness C secret representative) :
    SamePublicClass C secret representative := by
  exact hC (classMembership_path w)

/-- The public classifier is non-faithful when one public class has distinct hidden representatives. -/
def PublicClassifierNonFaithful {A : Type u} {P : Type v}
    (C : PublicClassifier A P) : Prop :=
  ∃ x y : A, x ≠ y ∧ SamePublicClass C x y

/-- Non-faithfulness gives a nontrivial public fiber. -/
theorem nonFaithful_has_nontrivial_fiber {A : Type u} {P : Type v}
    {C : PublicClassifier A P}
    (h : PublicClassifierNonFaithful C) :
    ∃ p : P, ∃ x y : A, x ∈ PublicFiber C p ∧ y ∈ PublicFiber C p ∧ x ≠ y := by
  rcases h with ⟨x, y, hxy, hpub⟩
  exact ⟨C.π x, x, y, rfl, hpub.symm, hxy⟩

/-- Minimal dependent transport primitive along hidden paths. -/
class HasPathTransport {A : Type u} [HasPathSpace A] (F : A → Type v) where
  transport : ∀ {x y : A}, HasPathSpace.Path x y → F x → F y

/-- Interface-level obligations extracted from Helfer-style semantics. -/
structure HelferFOL where
  /-- Equality/diagonal semantics is path-space based (not strict boolean equality). -/
  DiagonalPathSemantics : Prop
  /-- Fibration/cartesian-lift style transport principle is available. -/
  CartesianLiftingPrinciple : Prop
  /-- Σ/Π dependent behavior is coherent with encryption/decryption contracts. -/
  SigmaPiCoherent : Prop
  /-- Homotopy-equivalent structures satisfy the same first-order theory. -/
  HomotopyInvarianceFO : Prop
  /-- Equivalence-class witness discipline (class membership has witness semantics). -/
  ClassWitnessSound : Prop

abbrev HelferFOLWellFormed (H : HelferFOL) : Prop :=
  H.DiagonalPathSemantics
  ∧ H.CartesianLiftingPrinciple
  ∧ H.SigmaPiCoherent
  ∧ H.HomotopyInvarianceFO
  ∧ H.ClassWitnessSound

end Axioms
end Hcrypt
