import Mathlib

universe u v
open CategoryTheory

structure Wrapper (n : ℕ) (E : Type u) where
  val : E

instance (n : ℕ) (E : Type u) [Category.{v} E] : Category (Wrapper n E) :=
  InducedCategory.category Wrapper.val

instance (n : ℕ) (E : Type u) [Category.{v} E] : Category.{v} (Wrapper n E) :=
  InducedCategory.category Wrapper.val

def ToWrapper (n : ℕ) (E : Type u) [Category.{v} E] : E ⥤ Wrapper n E where
  obj X := ⟨X⟩
  map f := f
  map_id := by intro X; rfl
  map_comp := by intro X Y Z f g; rfl

def FromWrapper (n : ℕ) (E : Type u) [Category.{v} E] : Wrapper n E ⥤ E where
  obj W := W.val
  map f := f
  map_id := by intro W; rfl
  map_comp := by intro W Y Z f g; rfl

variable {E : Type u} [Category.{v} E]

example (n : ℕ) :
    ToWrapper n E ⋙ CategoryTheory.inducedFunctor (Wrapper.val : Wrapper n E → E)
      = Functor.id E := by
  refine CategoryTheory.Functor.ext (fun X => rfl) ?_
  intro X Y f
  aesop_cat

example (n : ℕ) :
    CategoryTheory.inducedFunctor (Wrapper.val : Wrapper n E → E) = FromWrapper n E := by
  refine CategoryTheory.Functor.ext (fun X => rfl) ?_
  intro X Y f
  aesop_cat

example (n : ℕ) :
    FromWrapper n E ⋙ ToWrapper n E = Functor.id (Wrapper n E) := by
  refine CategoryTheory.Functor.ext (fun X => by cases X <;> rfl) ?_
  intro X Y f
  aesop_cat

example (n : ℕ) :
    ToWrapper n E ⋙ FromWrapper n E = Functor.id E := by
  refine CategoryTheory.Functor.ext (fun X => rfl) ?_
  intro X Y f
  aesop_cat
