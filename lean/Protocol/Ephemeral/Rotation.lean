module

public import Axioms.Fibration
public import Sheaf.Rotation
public import Sheaf.CoefficientRecovery
public import Protocol.Storage.Context

@[expose] public section

/-!
# Presented rotation and recipient recovery

The semantic plaintext is an integer coefficient vector in a declared
harmonic-lattice presentation. An actual integral chain isometry, together
with compatibility of the two encodings, transports that same plaintext.
Both direct target-key recovery and inverse-transport/base-key recovery are
derived from the observed cochain. The decoder is classical, not an efficient
cryptographic algorithm.

Payload migration below retains the original source and target contexts;
its decoder equation is an explicit encoding contract. No equality of roots,
hash authentication, network delivery, erasure or secrecy follows from it.
The bridge to an existing ephemeral path requires actual rotation material;
a class label or supplied path alone does not construct that material.
-/

set_option autoImplicit false

noncomputable section

namespace Hcrypt.Protocol.Ephemeral

open Sheaf CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F G L : CellularSheaf X}
  {I : IntegralStructure F} {J : IntegralStructure G} {M : IntegralStructure L}
  {Rank : Type*} [Fintype Rank]

/-- An actual integral Hodge rotation preserving the chosen integer encoding. -/
structure PresentedRotation
    (H : HarmonicLatticePresentation I Rank)
    (K : HarmonicLatticePresentation J Rank) where
  integral : IntegralCochainEquiv I J
  point_naturality : ∀ z : Rank → ℤ,
    integral.degreeOne (H.point z).1 = (K.point z).1

namespace PresentedRotation

variable {H : HarmonicLatticePresentation I Rank}
  {K : HarmonicLatticePresentation J Rank}
  {Q : HarmonicLatticePresentation M Rank}

/-- Move the actual full observed cochain with its presentation. -/
def rotateObserved (R : PresentedRotation H K) (b : F.C1) : G.C1 :=
  R.integral.degreeOne b

/-- A recipient holding the base key pulls back before coefficient recovery. -/
def recoverWithBase (R : PresentedRotation H K) (b : G.C1) :
    Option (Rank → ℤ) :=
  H.decodeCoefficients (R.integral.degreeOne.symm b)

/-- Inverse transport exactly restores every original observed cochain. -/
theorem pullback_rotateObserved (R : PresentedRotation H K) (b : F.C1) :
    R.integral.degreeOne.symm (R.rotateObserved b) = b :=
  R.integral.degreeOne.symm_apply_apply b

/-- Rotated encryption is actual target encryption of the same coefficient vector. -/
theorem transport_encrypt (R : PresentedRotation H K)
    (z : Rank → ℤ) (opening : HodgeNoise F) :
    R.integral.transportSample (H.encrypt z opening) =
      K.encrypt z (R.integral.toIsometricCochainEquiv.transportNoise opening) := by
  change HodgeEncryptedCochain.mk _ _ = HodgeEncryptedCochain.mk _ _
  congr 1
  apply Subtype.ext
  exact R.point_naturality z

/-- The target key recovers the original semantic plaintext after rotation. -/
theorem decode_rotated_encrypt (R : PresentedRotation H K)
    (z : Rank → ℤ) (opening : HodgeNoise F) :
    K.decodeCoefficients (R.rotateObserved (H.encrypt z opening).observed) = some z := by
  rw [K.decodeCoefficients_eq_some_iff]
  change G.harmonicOneProjection (R.integral.degreeOne (H.encrypt z opening).observed) = _
  rw [R.integral.toIsometricCochainEquiv.harmonicOneProjection_naturality,
    H.encrypt_projection_eq_point]
  exact R.point_naturality z

/-- The retained base key and actual inverse transport recover the same plaintext. -/
theorem recoverWithBase_rotated_encrypt (R : PresentedRotation H K)
    (z : Rank → ℤ) (opening : HodgeNoise F) :
    R.recoverWithBase (R.rotateObserved (H.encrypt z opening).observed) = some z := by
  unfold recoverWithBase
  rw [R.pullback_rotateObserved]
  exact H.decodeCoefficients_encrypt z opening

/-- Direct and retained-key recovery agree on every actual encoded source sample. -/
theorem recovery_routes_agree (R : PresentedRotation H K)
    (z : Rank → ℤ) (opening : HodgeNoise F) :
    R.recoverWithBase (R.rotateObserved (H.encrypt z opening).observed) =
      K.decodeCoefficients (R.rotateObserved (H.encrypt z opening).observed) := by
  rw [R.recoverWithBase_rotated_encrypt, R.decode_rotated_encrypt]

def refl (H : HarmonicLatticePresentation I Rank) : PresentedRotation H H where
  integral := IntegralCochainEquiv.refl I
  point_naturality _ := rfl

def symm (R : PresentedRotation H K) : PresentedRotation K H := by
  refine {
    integral := IntegralCochainEquiv.symm R.integral
    point_naturality := ?_
  }
  intro z
  change R.integral.degreeOne.symm (K.point z).1 = (H.point z).1
  apply R.integral.degreeOne.injective
  rw [LinearIsometryEquiv.apply_symm_apply]
  exact (R.point_naturality z).symm

def trans (R : PresentedRotation H K) (T : PresentedRotation K Q) :
    PresentedRotation H Q where
  integral := R.integral.trans T.integral
  point_naturality z := by
    change T.integral.degreeOne (R.integral.degreeOne (H.point z).1) = _
    rw [R.point_naturality]
    exact T.point_naturality z

/-- Successive rotations compose in the same order as their actual transports. -/
theorem rotateObserved_trans (R : PresentedRotation H K)
    (T : PresentedRotation K Q) (b : F.C1) :
    (R.trans T).rotateObserved b = T.rotateObserved (R.rotateObserved b) := rfl

/-- Reversing a rotation restores the actual ciphertext, not just a class label. -/
theorem rotateObserved_symm (R : PresentedRotation H K) (b : F.C1) :
    R.symm.rotateObserved (R.rotateObserved b) = b :=
  R.integral.degreeOne.symm_apply_apply b

end PresentedRotation

/-- Original payloads are related by the selected decoder/transport equation.
This is additional data, not a consequence of names or equal class labels. -/
structure PayloadRotation
    {H : HarmonicLatticePresentation I Rank}
    {K : HarmonicLatticePresentation J Rank}
    (R : PresentedRotation H K) (source : Storage.Context F)
    (target : Storage.Context G) : Prop where
  decoded_transport : target.interpretation.decode target.cochain =
    R.integral.degreeOne (source.interpretation.decode source.cochain)

namespace PayloadRotation

variable {H : HarmonicLatticePresentation I Rank}
  {K : HarmonicLatticePresentation J Rank}
  {R : PresentedRotation H K}
  {source : Storage.Context F} {target : Storage.Context G}

/-- Exact acceptance is preserved only after joining the actual target payload decoder. -/
theorem target_accepted (B : PayloadRotation R source target)
    (accepted : source.Accepted) : target.Accepted := by
  refine ⟨target.artifactWellFormed.1, target.boundToSnapshot, ?_⟩
  obtain ⟨a, ha⟩ := accepted.representsExact
  refine ⟨R.integral.degreeZero a, ?_⟩
  rw [B.decoded_transport, ha]
  exact LinearMap.congr_fun R.integral.delta0_commutes a

end PayloadRotation

/-- An existing ephemeral path can carry an actual compatible private rotation.
Neither path-respect nor its supplied admissibility proposition produces the
integral chain map or encoding law; these are retained as separate data. -/
structure EphemeralRotation
    {Rep : Type*} [Axioms.HasPathSpace Rep]
    (family : Rep → CellularSheaf X)
    (integrals : ∀ r, IntegralStructure (family r))
    (presentations : ∀ r, HarmonicLatticePresentation (integrals r) Rank)
    {classifier : Axioms.FibrationClassifier Rep} {base : Rep}
    (ephemeral : Axioms.EphemeralFiberSpec classifier base) where
  admissible : ephemeral.WellFormed
  rotation : PresentedRotation (presentations base)
    (presentations ephemeral.representative)

namespace EphemeralRotation

variable {Rep : Type*} [Axioms.HasPathSpace Rep]
  {family : Rep → CellularSheaf X}
  {integrals : ∀ r, IntegralStructure (family r)}
  {presentations : ∀ r, HarmonicLatticePresentation (integrals r) Rank}
  {classifier : Axioms.FibrationClassifier Rep} {base : Rep}
  {ephemeral : Axioms.EphemeralFiberSpec classifier base}

/-- The original path interface supplies class preservation under its existing law. -/
theorem samePublicFingerprint
    (_R : EphemeralRotation family integrals presentations ephemeral)
    (respects : Axioms.PathRespectsHomotopyClass classifier) :
    classifier.π ephemeral.representative = classifier.π base :=
  ephemeral.samePublicFingerprint respects

/-- The accompanying actual rotation supplies coefficient recovery independently. -/
theorem recover_rotated_encrypt
    (R : EphemeralRotation family integrals presentations ephemeral)
    (z : Rank → ℤ) (opening : HodgeNoise (family base)) :
    R.rotation.recoverWithBase
        (R.rotation.rotateObserved ((presentations base).encrypt z opening).observed) =
      some z :=
  R.rotation.recoverWithBase_rotated_encrypt z opening

end EphemeralRotation

end Hcrypt.Protocol.Ephemeral
