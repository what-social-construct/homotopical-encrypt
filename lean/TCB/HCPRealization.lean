module

public import TCB.HCPObservation
public import Hardness

@[expose] public section

/-!
# The actual cellular observation and the operative HCP target

The adapter identifies the matrix action in an existing Helfer/HCP
realization with the true cellular degree-one Hodge operator. Kernel,
projector and message recovery agreement are consequences, not fields.
The existing bound observation retains its original sample, exact payload,
snapshot and artifact. No hash, snapshot-binding or verification contract is
manufactured here.

The public-view lemma reuses the existing no-recovery proof when an explicitly
chosen view factors through the HCP observation. It does not assert that all
storage fields have that property. The manuscript's private witness, public
payload and selective opening/proof levels remain separate from the fields
retained in a semantic proof record.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.TCB.HCPRealization

open CategoryTheory CategoryTheory.Limits HomotopicalAlgebra
open Sheaf CellularSheaf

universe u₁ u₂ v₁ v₂ uRep uAux

variable
  {C : Type u₂} [Category.{v₂} C]
  [HasTerminal C] [HasBinaryProducts C] [ModelCategory C]
  {S : Helfer.Signature.{u₁, v₁}}
  {sem : Helfer.ClosedSemantics (C := C) S}
  {Rep : Type uRep}
  {Vertex Edge Face : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {cell : OrientedTwoComplex Vertex Edge Face}
  {F : CellularSheaf cell} {PublicClass : Type}

/-- The realized matrix acts as the true Hodge operator in the same declared
cellular coordinates. This is stronger than merely assigning an arbitrary
matrix to the representative. -/
structure CellularOperatorAlignment
    (F : CellularSheaf cell)
    (R : HCPBridge.Realization C S sem Rep
      (TotalCoord Edge F.edgeDim) ℝ PublicClass) where
  representative : Rep
  operatorAction : ∀ b : F.C1,
    WithLp.toLp 2 (Matrix.mulVec (R.laplacian representative) b) =
      F.degreeOneLaplacian b

namespace CellularOperatorAlignment

variable
  {R : HCPBridge.Realization C S sem Rep
    (TotalCoord Edge F.edgeDim) ℝ PublicClass}

/-- The operative matrix kernel is exactly the actual cellular harmonic space. -/
theorem matrixHarmonicSubspace_eq (A : CellularOperatorAlignment F R) :
    HCP.matrixHarmonicSubspace (R.laplacian A.representative) =
      F.harmonicOneSubspace := by
  ext b
  change Matrix.mulVec (R.laplacian A.representative) b = 0 ↔
    F.degreeOneLaplacian b = 0
  rw [← A.operatorAction b, WithLp.toLp_eq_zero]

/-- Fixed-metric harmonic recovery agrees after the actual operator join. -/
theorem operativeHarmonicComponent_eq (A : CellularOperatorAlignment F R)
    (b : F.C1) :
    HCP.operativeHarmonicComponent (R.laplacian A.representative) b =
      F.harmonicOneProjection b := by
  unfold HCP.operativeHarmonicComponent CellularSheaf.harmonicOneProjection
  simp only [A.matrixHarmonicSubspace_eq]
  rfl

end CellularOperatorAlignment

variable
  {integral : IntegralStructure F}
  {payload : CochainPayloadInterpretation F}
  {Lifecycle : Type}
  {classify : SheafStateSnapshot F → PublicClass}
  {Binds : HCPStackBinding Lifecycle PublicClass F.C1}

/-- A bound observation uses the same representative, actual cellular
operator and public classifier as the semantic HCP realization. The existing
payload, snapshot and binding relation are retained unchanged. -/
structure BoundObservationAlignment
    (O : BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (R : HCPBridge.Realization C S sem Rep
      (TotalCoord Edge F.edgeDim) ℝ PublicClass)
    extends CellularOperatorAlignment F R where
  classifier_eq : R.classifier.π representative = classify payload.snapshot

namespace BoundObservationAlignment

variable
  {O : BoundHCPObservation integral payload PublicClass Lifecycle classify Binds}
  {R : HCPBridge.Realization C S sem Rep
    (TotalCoord Edge F.edgeDim) ℝ PublicClass}

/-- The private semantic witness is tied to the original bound observation. -/
def hiddenWitness (A : BoundObservationAlignment O R) :
    HCPBridge.HiddenHodgeWitness R O.toObservation where
  representative := A.representative
  class_eq := A.classifier_eq

/-- The semantic operative target is the actual projection of this sample. -/
theorem operativeTarget_eq_projection (A : BoundObservationAlignment O R) :
    HCPBridge.operativeTarget R O.toObservation A.hiddenWitness =
      fun i => F.harmonicOneProjection O.cochainObject i := by
  change (fun i => HCP.operativeHarmonicComponent
    (R.laplacian A.representative) O.cochainObject i) = _
  rw [A.toCellularOperatorAlignment.operativeHarmonicComponent_eq]

/-- The existing bound Hodge sample supplies the same harmonic message as
the semantic HCP witness. No new message or cochain is introduced. -/
theorem operativeTarget_eq_message (A : BoundObservationAlignment O R) :
    HCPBridge.operativeTarget R O.toObservation A.hiddenWitness =
      fun i => O.latticeObject.1 i := by
  rw [A.operativeTarget_eq_projection, O.harmonicProjection_cochainObject]

/-- On samples whose message belongs to the selected explicit presentation,
the existing discrete CVP answer is exactly this same operative HCP target. -/
theorem cvp_solution_iff_operativeTarget
    (A : BoundObservationAlignment O R)
    {Rank : Type} [Fintype Rank]
    (H : HarmonicLatticePresentation integral Rank) (z : Rank → ℤ)
    (message_eq : O.encrypted.message = H.point z)
    (v : CVP.AmbientVector (TotalCoord Edge F.edgeDim)) :
    CVP.Solution (H.cvpInstance O.encrypted) v ↔
      v = HCPBridge.operativeTarget R O.toObservation A.hiddenWitness := by
  have sample_eq : O.encrypted = H.encrypt z O.encrypted.opening := by
    change HodgeEncryptedCochain.mk O.encrypted.message O.encrypted.opening =
      HodgeEncryptedCochain.mk (H.point z) O.encrypted.opening
    exact congrArg
      (fun message => HodgeEncryptedCochain.mk message O.encrypted.opening) message_eq
  rw [A.operativeTarget_eq_message]
  change CVP.Solution (H.cvpInstance O.encrypted) v ↔ v = O.encrypted.message.1
  rw [sample_eq]
  exact concreteSheafHCP_CVP_solution_iff_message H z O.encrypted.opening v

end BoundObservationAlignment

section PublicViews

variable
  {N : Type} [Fintype N] {P : Type}
  (R : HCPBridge.Realization C S sem Rep N ℝ P)

/-- Two actual released views with distinct operative targets exclude one
decoder that is exact on both examples. The selected HCP observations may
themselves differ: equality is required only for the views actually released.
This theorem does not supply that equality or assert hiding of any field. -/
theorem no_exact_view_decoder_of_same_view
    {View : Type*}
    (observe : (observation : HCPBridge.Observation P N ℝ) →
      HCPBridge.HiddenHodgeWitness R observation → View)
    (leftObservation rightObservation : HCPBridge.Observation P N ℝ)
    (leftWitness : HCPBridge.HiddenHodgeWitness R leftObservation)
    (rightWitness : HCPBridge.HiddenHodgeWitness R rightObservation)
    (sameView : observe leftObservation leftWitness =
      observe rightObservation rightWitness)
    (targets_ne : HCPBridge.operativeTarget R leftObservation leftWitness ≠
      HCPBridge.operativeTarget R rightObservation rightWitness) :
    ¬ ∃ solve : View → (N → ℝ),
      solve (observe leftObservation leftWitness) =
        HCPBridge.operativeTarget R leftObservation leftWitness ∧
      solve (observe rightObservation rightWitness) =
        HCPBridge.operativeTarget R rightObservation rightWitness := by
  rintro ⟨solve, hleft, hright⟩
  exact targets_ne
    (hleft.symm.trans ((congrArg solve sameView).trans hright))

/-- Reuse the existing impossibility proof for an explicitly selected view
whose value is determined by the HCP observation. Storage roots, proofs and
payloads need their own factorization proof before this theorem applies. -/
theorem no_exact_view_solver_of_factorization
    (hInv : Helfer.ClosedFormulaInvariance sem)
    (separation : HCPBridge.KernelSeparationWitness R)
    {View : Type*}
    (observe : (observation : HCPBridge.Observation P N ℝ) →
      HCPBridge.HiddenHodgeWitness R observation → View)
    (publicView : HCPBridge.Observation P N ℝ → View)
    (factors : ∀ observation witness,
      observe observation witness = publicView observation)
    {Aux : Type uAux} (aux : Aux) :
    ¬ ∃ solve : Aux → View → (N → ℝ),
      ∀ observation witness,
        solve aux (observe observation witness) =
          HCPBridge.operativeTarget R observation witness := by
  rintro ⟨solve, hsolve⟩
  apply HCPBridge.no_solver_exactOnOperativeTarget_of_kernelSeparation
    R hInv separation (solver := fun a observation => solve a (publicView observation))
    (aux := aux)
  intro observation witness
  change solve aux (publicView observation) = _
  rw [← factors observation witness]
  exact hsolve observation witness

end PublicViews

end Hcrypt.TCB.HCPRealization
