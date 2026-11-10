module

public import Sheaf.SystematicCode

@[expose] public section

/-!
# Modular validity of actual integral cellular coboundaries

An integer opening is embedded into the head stalk of the existing systematic
cellular sheaf, with zero tail. Its actual real coboundary has integral
coordinates. A raw integer cochain is modularly exact when that coboundary
differs from it by an integer multiple of `q` in each coordinate.

This source predicate does not mention RS codeword validity or a coding
distance. Its equivalence with the finite-field systematic RS code is proved
from the actual coboundary and reduction of the interpolation coefficients.
Modular exactness remains distinct from real `IsExactOneCochain` and storage
`Accepted`; no no-wrap hypothesis or Euclidean metric identity is asserted.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Sheaf.SystematicCode

open CellularSheaf

variable {q : ℕ} [Fact q.Prime] {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Actual integral head-stalk coefficients, one scalar for each information
coordinate and each of the two cochain columns. -/
abbrev IntegerOpening (S : Finset ι) := {s // s ∈ S} → Fin 2 → ℤ

/-- The integer opening embedded in the actual cellular degree-zero carrier.
The head contains its coefficients and the tail is zero. -/
def integralOpening
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a : IntegerOpening S) : (sheaf P S).C0 :=
  WithLp.toLp ((2 : ℕ) : ENNReal) fun coordinate =>
    let p := (Fintype.equivFin ({s // s ∈ S} × Fin 2)).symm coordinate.2
    if coordinate.1 then (a p.1 p.2 : ℝ) else 0

@[simp]
theorem integralOpening_head
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a : IntegerOpening S) (s : {s // s ∈ S}) (j : Fin 2) :
    integralOpening P S a
      ⟨true, (Fintype.equivFin ({s // s ∈ S} × Fin 2)) (s, j)⟩ = (a s j : ℝ) := by
  simp [integralOpening]

@[simp]
theorem integralOpening_tail
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a : IntegerOpening S) (s : {s // s ∈ S}) (j : Fin 2) :
    integralOpening P S a
      ⟨false, (Fintype.equivFin ({s // s ∈ S} × Fin 2)) (s, j)⟩ = 0 := by
  simp [integralOpening]

/-- Integer coordinates of the actual coboundary, proved below from `delta0`. -/
def integerCoboundary
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a : IntegerOpening S) : ι → Fin 2 → ℤ :=
  fun i j => P.integerEncode S (fun s => a s j) i

/-- The original cellular differential, not a separately supplied syndrome,
computes this integer encoding in each edge-stalk coordinate. -/
theorem delta0_integralOpening_coordinate
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a : IntegerOpening S) (i : ι) (j : Fin 2) :
    (sheaf P S).delta0 (integralOpening P S a) (layout (i, j)) =
      (integerCoboundary P S a i j : ℝ) := by
  rw [delta0_apply]
  simp [integerCoboundary,
    ProximityCoding.ReedSolomon.Parameters.realEncode,
    ProximityCoding.ReedSolomon.Parameters.integerEncode]

/-- Reducing the actual integral coboundary gives the original finite-field
systematic encoder with the reduced head-stalk opening. -/
theorem intCast_integerCoboundary
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (a : IntegerOpening S) (i : ι) (j : Fin 2) :
    (integerCoboundary P S a i j : ZMod q) =
      P.systematicEncode S (fun s => (a s j : ZMod q)) i := by
  simp [integerCoboundary,
    ProximityCoding.ReedSolomon.Parameters.integerEncode,
    ProximityCoding.ReedSolomon.Parameters.systematicEncode,
    P.intCast_integerCoefficient]

/-- Modular source validity: an actual integral cellular coboundary equals
the raw cochain plus an integer `q`-multiple in each coordinate. -/
def ModularExact
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → Fin 2 → ℤ) : Prop :=
  ∃ a : IntegerOpening S, ∃ carry : ι → Fin 2 → ℤ, ∀ i j,
    (sheaf P S).delta0 (integralOpening P S a) (layout (i, j)) =
      ((z i j + (q : ℤ) * carry i j : ℤ) : ℝ)

/-- The intrinsic coboundary-congruence predicate has an equivalent explicit
integer-coordinate witness form. Neither side mentions target codewords. -/
theorem modularExact_iff_integerCoboundary_residue
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (z : ι → Fin 2 → ℤ) :
    ModularExact P S z ↔ ∃ a : IntegerOpening S, ∀ i j,
      (integerCoboundary P S a i j : ZMod q) = (z i j : ZMod q) := by
  constructor
  · rintro ⟨a, carry, hcarry⟩
    refine ⟨a, ?_⟩
    intro i j
    have hreal := hcarry i j
    rw [delta0_integralOpening_coordinate] at hreal
    have hint : integerCoboundary P S a i j = z i j + (q : ℤ) * carry i j := by
      exact Int.cast_injective hreal
    have hmod := congrArg (fun t : ℤ => (t : ZMod q)) hint
    simpa only [Int.cast_add, Int.cast_mul, Int.cast_natCast,
      ZMod.natCast_self, zero_mul, add_zero] using hmod
  · rintro ⟨a, ha⟩
    have hdiv : ∀ i j, (q : ℤ) ∣ integerCoboundary P S a i j - z i j := by
      intro i j
      apply (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp
      rw [Int.cast_sub, ha i j, sub_self]
    choose carry hcarry using hdiv
    refine ⟨a, carry, ?_⟩
    intro i j
    rw [delta0_integralOpening_coordinate]
    have hint : integerCoboundary P S a i j = z i j + (q : ℤ) * carry i j := by
      linarith [hcarry i j]
    exact congrArg (fun t : ℤ => (t : ℝ)) hint

/-- Finite-field validity follows from actual integral cellular exactness
modulo `q`, using the original interpolation coefficients. -/
theorem vectorCodeword_of_modularExact
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : ι → Fin 2 → ℤ) (hz : ModularExact P S z) :
    P.VectorCodeword (Fin 2) (fun i j => (z i j : ZMod q)) := by
  obtain ⟨a, ha⟩ := (modularExact_iff_integerCoboundary_residue P S z).mp hz
  intro j
  have hw := P.systematicEncode_codeword S hDegree hS (fun s => (a s j : ZMod q))
  have heq : (fun i => (z i j : ZMod q)) =
      P.systematicEncode S (fun s => (a s j : ZMod q)) := by
    funext i
    exact (ha i j).symm.trans (intCast_integerCoboundary P S a i j)
  rw [heq]
  exact hw

/-- Each actual RS pair has an integral head opening: choose canonical
representatives only for its information coordinates. -/
theorem modularExact_of_vectorCodeword
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : ι → Fin 2 → ℤ)
    (hz : P.VectorCodeword (Fin 2) (fun i j => (z i j : ZMod q))) :
    ModularExact P S z := by
  apply (modularExact_iff_integerCoboundary_residue P S z).mpr
  let a : IntegerOpening S := fun s j => ((z s.val j : ZMod q).val : ℤ)
  refine ⟨a, ?_⟩
  intro i j
  rw [intCast_integerCoboundary]
  have ha : (fun s : {s // s ∈ S} => (a s j : ZMod q)) =
      (fun s => (z s.val j : ZMod q)) := by
    funext s
    simp [a]
  rw [ha]
  exact (congrFun ((P.codeword_iff_systematicEncode S hDegree hS _).mp (hz j)) i).symm

/-- The source/field validity bridge is a theorem about the actual cellular
differential; it is not the definition of modular source validity. -/
theorem modularExact_iff_vectorCodeword
    (P : ProximityCoding.ReedSolomon.Parameters (ZMod q) ι) (S : Finset ι)
    (hDegree : 0 < P.degreeBound) (hS : S.card = P.degreeBound)
    (z : ι → Fin 2 → ℤ) :
    ModularExact P S z ↔
      P.VectorCodeword (Fin 2) (fun i j => (z i j : ZMod q)) :=
  ⟨vectorCodeword_of_modularExact P S hDegree hS z,
    modularExact_of_vectorCodeword P S hDegree hS z⟩

end HomotopicalEncryption.Sheaf.SystematicCode
