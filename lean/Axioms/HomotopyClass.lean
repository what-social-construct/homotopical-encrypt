module

public import Axioms.HelferFOL

@[expose] public section

/-
  Lean-native homotopy-class interface.

  Paper correspondence:
  - Paper 1: public classifier fibers and the distinction between
    path witnesses and equal public class values.
  - Paper 2: explicit observation/disclosure profiles that consume those
    mathematical objects.

  This file owns the mathematical vocabulary for public homotopy classes:
  hidden representatives, public fingerprints/classifiers, class membership,
  and non-faithful public collapse. Runtime implementations may later refine
  these objects, but the definitions here are not Python-shaped.
-/

namespace HomotopicalEncryption
namespace Axioms

universe u

/--
Lean-owned public homotopy-class fingerprint.

The fields are intentionally abstract protocol invariants rather than runtime
bytes. Implementations may encode them as hashes, arrays, or commitments later.
-/
structure HomotopyClassFingerprint where
  topologyHash : Nat
  bettiNumbers : List Nat
  harmonicDim : Nat
  hLevel : Nat
  sigmaRank : Nat
  piRank : Nat
  deriving DecidableEq, Repr

/-- A public classifier from hidden representatives to homotopy-class data. -/
abbrev HomotopyClassifier (F : Type u) :=
  PublicClassifier F HomotopyClassFingerprint

/-- Public homotopy-class equivalence induced by a classifier. -/
def SameHomotopyClass {F : Type u}
    (C : HomotopyClassifier F) (x y : F) : Prop :=
  SamePublicClass C x y

/-- Public homotopy class of a hidden representative. -/
def HomotopyClassOf {F : Type u}
    (C : HomotopyClassifier F) (x : F) : Set F :=
  PublicClassOf C x

/-- Membership in a public homotopy class is classifier equality. -/
theorem mem_homotopyClassOf_iff {F : Type u}
    (C : HomotopyClassifier F) (x y : F) :
    y ∈ HomotopyClassOf C x ↔ SameHomotopyClass C y x := by
  rfl

/-- Same-homotopy-class is reflexive. -/
theorem sameHomotopyClass_refl {F : Type u}
    (C : HomotopyClassifier F) (x : F) :
    SameHomotopyClass C x x := by
  exact samePublicClass_refl C x

/-- Same-homotopy-class is symmetric. -/
theorem sameHomotopyClass_symm {F : Type u}
    {C : HomotopyClassifier F} {x y : F} :
    SameHomotopyClass C x y → SameHomotopyClass C y x := by
  exact samePublicClass_symm

/-- Same-homotopy-class is transitive. -/
theorem sameHomotopyClass_trans {F : Type u}
    {C : HomotopyClassifier F} {x y z : F} :
    SameHomotopyClass C x y → SameHomotopyClass C y z → SameHomotopyClass C x z := by
  exact samePublicClass_trans

/-- Path equality preserves the public homotopy class for a classifier. -/
def PathRespectsHomotopyClass {F : Type u} [HasPathSpace F]
    (C : HomotopyClassifier F) : Prop :=
  PathRespectsPublicClass C

/-- Path-equivalent representatives have the same public class when the classifier respects paths. -/
theorem pathEquivalent_sameHomotopyClass {F : Type u} [HasPathSpace F]
    {C : HomotopyClassifier F} (hC : PathRespectsHomotopyClass C)
    {x y : F} :
    PathEquivalent x y → SameHomotopyClass C x y := by
  exact hC

/-- Hidden path witness that a secret representative belongs to a public class. -/
abbrev HomotopyClassWitness {F : Type u} [HasPathSpace F]
    (C : HomotopyClassifier F) (secret representative : F) :=
  ClassMembershipWitness C secret representative

/-- A hidden class-membership witness entails public homotopy-class equality. -/
theorem homotopyClassWitness_sameClass {F : Type u} [HasPathSpace F]
    {C : HomotopyClassifier F} (hC : PathRespectsHomotopyClass C)
    {secret representative : F}
    (w : HomotopyClassWitness C secret representative) :
    SameHomotopyClass C secret representative := by
  exact classMembership_samePublicClass hC w

/-- A public homotopy class is nontrivial when it contains a second hidden representative. -/
def HomotopyClassNontrivial {F : Type u}
    (C : HomotopyClassifier F) (x : F) : Prop :=
  ∃ y : F, y ≠ x ∧ y ∈ HomotopyClassOf C x

/-- The classifier is non-faithful when public data identifies distinct hidden representatives. -/
def HomotopyClassifierNonFaithful {F : Type u}
    (C : HomotopyClassifier F) : Prop :=
  PublicClassifierNonFaithful C

/-- A nontrivial class makes the classifier non-faithful. -/
theorem nontrivialClass_nonFaithful {F : Type u}
    {C : HomotopyClassifier F} {x : F}
    (h : HomotopyClassNontrivial C x) :
    HomotopyClassifierNonFaithful C := by
  rcases h with ⟨y, hy_ne, hy_mem⟩
  exact ⟨y, x, hy_ne, hy_mem⟩

/-- Non-faithfulness gives some nontrivial public homotopy class. -/
theorem nonFaithful_has_nontrivialClass {F : Type u}
    {C : HomotopyClassifier F}
    (h : HomotopyClassifierNonFaithful C) :
    ∃ x : F, HomotopyClassNontrivial C x := by
  rcases h with ⟨x, y, hxy, hpub⟩
  exact ⟨x, y, hxy.symm, hpub.symm⟩

/-- Hidden representative ambiguity is precisely non-faithful public classification. -/
abbrev HiddenRepresentativeAmbiguity {F : Type u}
    (C : HomotopyClassifier F) : Prop :=
  HomotopyClassifierNonFaithful C

end Axioms
end HomotopicalEncryption
