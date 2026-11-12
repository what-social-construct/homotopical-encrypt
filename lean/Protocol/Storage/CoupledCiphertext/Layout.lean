module

public import Protocol.Storage.CoupledCiphertext

@[expose] public section

/-!
# The original ciphertext ordering as a finite coordinate equivalence

This leaf upgrades `CoupledCiphertext.position` to an executable equivalence.
Rational transport matrices use the same exact/information/parity ordering as
the integer ciphertext codec. Reindexing changes no matrix action.
-/

set_option autoImplicit false

open scoped BigOperators

namespace HomotopicalEncryption.Protocol.Storage.CoupledCiphertext

open Sheaf HCPCoupledFamily

/-- Invert the original exact, information, parity byte-coordinate ordering. -/
def coordinateAt (rows cols : ℕ) (i : Fin (1 + cols + rows)) : Index (Fin rows) (Fin cols) :=
  if h0 : i.val = 0 then ⟨none, 0⟩
  else if hc : i.val < 1 + cols then
    ⟨some (.inl ⟨i.val - 1, by omega⟩), 0⟩
  else
    ⟨some (.inr ⟨i.val - (1 + cols), by omega⟩), 0⟩

/-- The existing codec position, now with its proved finite bound. -/
def coordinateIndex {rows cols : ℕ} (p : Index (Fin rows) (Fin cols)) :
    Fin (1 + cols + rows) := ⟨position p, position_lt p⟩

theorem coordinateAt_coordinateIndex {rows cols : ℕ} (p : Index (Fin rows) (Fin cols)) :
    coordinateAt rows cols (coordinateIndex p) = p := by
  rcases p with ⟨e, j⟩
  have hj : j = 0 := Subsingleton.elim _ _
  subst j
  cases e with
  | none => rfl
  | some e =>
    cases e with
    | inl c =>
      have hc : 1 + c.val < 1 + cols := by omega
      simp [coordinateAt, coordinateIndex, position, hc]
    | inr r =>
      have hr : ¬ 1 + cols + r.val < 1 + cols := by omega
      simp [coordinateAt, coordinateIndex, position, hr]

theorem coordinateIndex_coordinateAt (rows cols : ℕ) (i : Fin (1 + cols + rows)) :
    coordinateIndex (coordinateAt rows cols i) = i := by
  apply Fin.ext
  simp only [coordinateAt]
  split_ifs with h0 hc
  · simpa [coordinateIndex, position] using h0.symm
  · change 1 + (i.val - 1) = i.val
    omega
  · change 1 + cols + (i.val - (1 + cols)) = i.val
    omega

/-- One shared, executable coordinate equivalence for ciphertexts and tokens. -/
def coordinateEquiv (rows cols : ℕ) :
    Index (Fin rows) (Fin cols) ≃ Fin (1 + cols + rows) where
  toFun := coordinateIndex
  invFun := coordinateAt rows cols
  left_inv := coordinateAt_coordinateIndex
  right_inv := coordinateIndex_coordinateAt rows cols

def vectorToFinite {rows cols : ℕ} {R : Type*}
    (v : Index (Fin rows) (Fin cols) → R) : Fin (1 + cols + rows) → R :=
  fun i => v ((coordinateEquiv rows cols).symm i)

def vectorFromFinite {rows cols : ℕ} {R : Type*}
    (v : Fin (1 + cols + rows) → R) : Index (Fin rows) (Fin cols) → R :=
  fun p => v (coordinateEquiv rows cols p)

@[simp] theorem vectorFromFinite_toFinite {rows cols : ℕ} {R : Type*}
    (v : Index (Fin rows) (Fin cols) → R) :
    vectorFromFinite (vectorToFinite v) = v := by
  funext p
  simp [vectorFromFinite, vectorToFinite]

def matrixToFinite {rows cols : ℕ} {R : Type*}
    (A : Matrix (Index (Fin rows) (Fin cols)) (Index (Fin rows) (Fin cols)) R) :
    Matrix (Fin (1 + cols + rows)) (Fin (1 + cols + rows)) R :=
  fun i j => A ((coordinateEquiv rows cols).symm i) ((coordinateEquiv rows cols).symm j)

def matrixFromFinite {rows cols : ℕ} {R : Type*}
    (A : Matrix (Fin (1 + cols + rows)) (Fin (1 + cols + rows)) R) :
    Matrix (Index (Fin rows) (Fin cols)) (Index (Fin rows) (Fin cols)) R :=
  fun p q => A (coordinateEquiv rows cols p) (coordinateEquiv rows cols q)

@[simp] theorem matrixFromFinite_toFinite {rows cols : ℕ} {R : Type*}
    (A : Matrix (Index (Fin rows) (Fin cols)) (Index (Fin rows) (Fin cols)) R) :
    matrixFromFinite (matrixToFinite A) = A := by
  funext p q
  simp [matrixFromFinite, matrixToFinite]

/-- The finite matrix codec's multiplication is the same original coordinate action. -/
theorem matrix_action_reindex {rows cols : ℕ} {R : Type*} [Semiring R]
    (A : Matrix (Index (Fin rows) (Fin cols)) (Index (Fin rows) (Fin cols)) R)
    (v : Index (Fin rows) (Fin cols) → R) :
    vectorFromFinite ((matrixToFinite A).mulVec (vectorToFinite v)) = A.mulVec v := by
  funext p
  simp only [vectorFromFinite, matrixToFinite, vectorToFinite,
    Equiv.symm_apply_apply, Matrix.mulVec, dotProduct]
  exact Equiv.sum_comp (coordinateEquiv rows cols).symm (fun q => A p q * v q)

end HomotopicalEncryption.Protocol.Storage.CoupledCiphertext
