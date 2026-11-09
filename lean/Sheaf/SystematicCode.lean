module

public import Sheaf.Distance
public import Proximity.Core.Systematic

@[expose] public section

/-!
# A cellular sheaf realizing the integer-lifted systematic RS code

Two vertices and one edge carry a genuine finite cellular sheaf. The tail
restriction is zero and the head restriction is the actual real systematic
encoder. Its exact degree-one cochains are therefore exactly the real
systematic pairs. This realizes a specific source profile; it does not
identify an arbitrary existing sheaf with the code or assert secrecy.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Sheaf.SystematicCode

open CellularSheaf
open scoped BigOperators

variable {q : ℕ} [Fact q.Prime] {ι : Type*} [Fintype ι] [DecidableEq ι]

def complex : OrientedTwoComplex Bool Unit Empty where
  incidence01 v _ := if v then 1 else -1
  incidence12 _ f := Empty.elim f
  boundarySqZero _ f := Empty.elim f

/-- Fixed pair coordinates on the edge stalk. -/
def layout : (ι × Fin 2) ≃ TotalCoord Unit (fun _ => Fintype.card (ι × Fin 2)) where
  toFun p := ⟨(), (Fintype.equivFin (ι × Fin 2)) p⟩
  invFun p := (Fintype.equivFin (ι × Fin 2)).symm p.2
  left_inv p := (Fintype.equivFin (ι × Fin 2)).symm_apply_apply p
  right_inv p := by
    rcases p with ⟨⟨⟩, i⟩
    simp

/-- The original real encoder function in the fixed information and edge coordinates. -/
def generatorFun (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (data : Coord (Fintype.card ({a // a ∈ S} × Fin 2))) :
    Coord (Fintype.card (ι × Fin 2)) :=
  WithLp.toLp ((2 : ℕ) : ENNReal) fun idx =>
    let p := (Fintype.equivFin (ι × Fin 2)).symm idx
    P.realEncode S
      (fun a => data ((Fintype.equivFin ({a // a ∈ S} × Fin 2)) (a, p.2))) p.1

/-- The actual encoder preserves addition of the same input coordinate vectors. -/
theorem generatorFun_add (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a b : Coord (Fintype.card ({a // a ∈ S} × Fin 2))) :
    generatorFun P S (a + b) = generatorFun P S a + generatorFun P S b := by
  apply PiLp.ext
  intro idx
  simp [generatorFun, ProximityPrize.ReedSolomon.Parameters.realEncode,
    add_mul, Finset.sum_add_distrib]

/-- The same encoder preserves real scalar multiplication. -/
theorem generatorFun_smul (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (r : ℝ) (a : Coord (Fintype.card ({a // a ∈ S} × Fin 2))) :
    generatorFun P S (r • a) = r • generatorFun P S a := by
  apply PiLp.ext
  intro idx
  simp [generatorFun, ProximityPrize.ReedSolomon.Parameters.realEncode,
    mul_assoc, Finset.mul_sum]

/-- The original systematic cellular restriction map, with named linearity proofs. -/
def generator (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) :
    Coord (Fintype.card ({a // a ∈ S} × Fin 2)) →ₗ[ℝ]
      Coord (Fintype.card (ι × Fin 2)) where
  toFun := generatorFun P S
  map_add' := generatorFun_add P S
  map_smul' := generatorFun_smul P S

def sheaf (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι) :
    CellularSheaf complex where
  vertexDim _ := Fintype.card ({a // a ∈ S} × Fin 2)
  edgeDim _ := Fintype.card (ι × Fin 2)
  faceDim f := Empty.elim f
  restrict01 v _ := if v then generator P S else 0
  restrict12 _ f := Empty.elim f
  restrict02 _ f := Empty.elim f
  restrictionComp _ _ f := Empty.elim f

theorem generator_apply
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (data : Coord (Fintype.card ({a // a ∈ S} × Fin 2))) (p : ι × Fin 2) :
    generator P S data ((Fintype.equivFin (ι × Fin 2)) p) =
      P.realEncode S
        (fun a => data ((Fintype.equivFin ({a // a ∈ S} × Fin 2)) (a, p.2))) p.1 := by
  simp [generator, generatorFun]

theorem delta0_apply
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a : (sheaf P S).C0) (p : ι × Fin 2) :
    (sheaf P S).delta0 a (layout p) =
      P.realEncode S
        (fun s => a ⟨true,
          (Fintype.equivFin ({a // a ∈ S} × Fin 2)) (s, p.2)⟩) p.1 := by
  change ((sheaf P S).delta0At () a)
    ((Fintype.equivFin (ι × Fin 2)) p) = _
  simp only [CellularSheaf.delta0At, LinearMap.sum_apply,
    LinearMap.smul_apply, LinearMap.comp_apply]
  rw [Fintype.sum_bool]
  simp only [OrientedTwoComplex.incidence01Real, complex, sheaf]
  simp only [Bool.false_eq_true, ite_true, ite_false,
    Int.cast_one, Int.cast_neg, LinearMap.zero_apply]
  change (((1 : ℝ) • generator P S
      (CellularSheaf.component
        (fun _ : Bool => Fintype.card ({a // a ∈ S} × Fin 2)) true a) +
      (-1 : ℝ) • (0 : Coord (Fintype.card (ι × Fin 2))))
        ((Fintype.equivFin (ι × Fin 2)) p)) = _
  rw [one_smul, smul_zero, add_zero, generator_apply]
  rfl

/-- Source vectors are actual edge-stalk coordinates in the chosen layout. -/
def ofWord (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → Fin 2 → ℝ) : (sheaf P S).C1 :=
  WithLp.toLp 2 fun coordinate =>
    z (layout.symm coordinate).1 (layout.symm coordinate).2

@[simp]
theorem ofWord_apply
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → Fin 2 → ℝ) (i : ι) (j : Fin 2) :
    ofWord P S z (layout (i, j)) = z i j := by
  simp [ofWord]

/-- Exactness is derived from the actual cellular coboundary, not postulated. -/
theorem isExact_iff_realCheck_eq_zero
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (b : (sheaf P S).C1) :
    (sheaf P S).IsExactOneCochain b ↔
      ∀ j, P.realCheck S (fun i => b (layout (i, j))) = 0 := by
  constructor
  · rintro ⟨a, rfl⟩ j
    apply (P.realCheck_eq_zero_iff S _).2
    refine ⟨fun s => a ⟨true,
      (Fintype.equivFin ({a // a ∈ S} × Fin 2)) (s, j)⟩, ?_⟩
    funext i
    exact (delta0_apply P S a (i, j)).symm
  · intro hb
    let a : (sheaf P S).C0 := WithLp.toLp 2 fun coordinate =>
      let p := (Fintype.equivFin ({a // a ∈ S} × Fin 2)).symm coordinate.2
      b (layout (p.1.val, p.2))
    refine ⟨a, ?_⟩
    apply PiLp.ext
    intro coordinate
    obtain ⟨⟨i, j⟩, rfl⟩ := layout.surjective coordinate
    rw [delta0_apply]
    have hi := congrFun (hb j) i
    change b (layout (i, j)) - P.realEncode S _ i = 0 at hi
    have ha : (fun s : {a // a ∈ S} =>
        a ⟨true, (Fintype.equivFin ({a // a ∈ S} × Fin 2)) (s, j)⟩) =
        (fun s => b (layout (s.val, j))) := by
      funext s
      simp [a]
    rw [ha]
    exact (sub_eq_zero.mp hi).symm

theorem ofWord_isExact_iff
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → Fin 2 → ℝ) :
    (sheaf P S).IsExactOneCochain (ofWord P S z) ↔
      ∀ j, P.realCheck S (fun i => z i j) = 0 := by
  rw [isExact_iff_realCheck_eq_zero]
  simp only [ofWord_apply]

/-- No-wrap received pairs that are genuine RS codewords decode to exact
cochains in this constructed cellular sheaf. -/
theorem ofWord_isExact_of_vectorCodeword_of_noWrap
    (P : ProximityPrize.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : ι → Fin 2 → ℤ)
    (hw : P.VectorCodeword (Fin 2) (fun i j => (z i j : ZMod q)))
    (hwrap : ∀ j, P.NoWrap S (fun i => z i j)) :
    (sheaf P S).IsExactOneCochain (ofWord P S (fun i j => (z i j : ℝ))) := by
  apply (ofWord_isExact_iff P S _).2
  exact P.realCheck_components_eq_zero_of_vectorCodeword_of_noWrap
    S hDegree hS z hw hwrap

end Hcrypt.Sheaf.SystematicCode
