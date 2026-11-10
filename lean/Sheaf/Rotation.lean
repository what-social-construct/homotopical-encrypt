module

public import Sheaf.Equivalence
public import Sheaf.HarmonicLattice

@[expose] public section

/-!
# Integral Hodge transport and rotation correctness

The actual degreewise chain isometry transports the message, exact/coexact
openings and observed cochain together. Preservation of the chosen integral
degree-one lattice is additional data; it does not follow from isometry.
The resulting harmonic-lattice equivalence and sample transport are derived.

These are mathematical rotation laws on a fixed base complex. They neither
generate an ephemeral representative nor authenticate recipient delivery,
serialized storage migration, retirement or physical erasure. Equality of
integer plaintext coefficients additionally requires compatibility of the
chosen harmonic-lattice presentations.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Sheaf.CellularSheaf

variable {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}
  {F G K : CellularSheaf X}

namespace IsometricCochainEquiv

/-- Identity transport keeps all three actual cochain degrees fixed. -/
def refl (F : CellularSheaf X) : IsometricCochainEquiv F F where
  degreeZero := LinearIsometryEquiv.refl ℝ _
  degreeOne := LinearIsometryEquiv.refl ℝ _
  degreeTwo := LinearIsometryEquiv.refl ℝ _
  delta0_commutes := by ext; rfl
  delta1_commutes := by ext; rfl

/-- Reverse a degreewise isometric chain equivalence. -/
def symm (e : IsometricCochainEquiv F G) : IsometricCochainEquiv G F where
  degreeZero := e.degreeZero.symm
  degreeOne := e.degreeOne.symm
  degreeTwo := e.degreeTwo.symm
  delta0_commutes := by
    apply LinearMap.ext
    intro a
    change e.degreeOne.symm (G.delta0 a) = F.delta0 (e.degreeZero.symm a)
    apply e.degreeOne.injective
    simpa using (LinearMap.congr_fun e.delta0_commutes (e.degreeZero.symm a)).symm
  delta1_commutes := by
    apply LinearMap.ext
    intro b
    change e.degreeTwo.symm (G.delta1 b) = F.delta1 (e.degreeOne.symm b)
    apply e.degreeTwo.injective
    simpa using (LinearMap.congr_fun e.delta1_commutes (e.degreeOne.symm b)).symm

/-- Compose actual chain transports, in the order first `e`, then `f`. -/
def trans (e : IsometricCochainEquiv F G) (f : IsometricCochainEquiv G K) :
    IsometricCochainEquiv F K where
  degreeZero := e.degreeZero.trans f.degreeZero
  degreeOne := e.degreeOne.trans f.degreeOne
  degreeTwo := e.degreeTwo.trans f.degreeTwo
  delta0_commutes := by
    apply LinearMap.ext
    intro a
    change f.degreeOne (e.degreeOne (F.delta0 a)) =
      K.delta0 (f.degreeZero (e.degreeZero a))
    rw [show e.degreeOne (F.delta0 a) = G.delta0 (e.degreeZero a) from
      LinearMap.congr_fun e.delta0_commutes a]
    exact LinearMap.congr_fun f.delta0_commutes (e.degreeZero a)
  delta1_commutes := by
    apply LinearMap.ext
    intro b
    change f.degreeTwo (e.degreeTwo (F.delta1 b)) =
      K.delta1 (f.degreeOne (e.degreeOne b))
    rw [show e.degreeTwo (F.delta1 b) = G.delta1 (e.degreeOne b) from
      LinearMap.congr_fun e.delta1_commutes b]
    exact LinearMap.congr_fun f.delta1_commutes (e.degreeOne b)

/-- Harmonic projection commutes with the actual transported presentation. -/
theorem harmonicOneProjection_naturality
    (e : IsometricCochainEquiv F G) (b : F.C1) :
    G.harmonicOneProjection (e.degreeOne b) =
      e.degreeOne (F.harmonicOneProjection b) := by
  change G.harmonicOneSubspace.starProjection (e.degreeOne b) =
    e.degreeOne (F.harmonicOneSubspace.starProjection b)
  rw [← e.map_harmonicOneSubspace]
  simpa using Submodule.starProjection_map_apply e.degreeOne
    F.harmonicOneSubspace (e.degreeOne b)

/-- Transport the existing real exact/coexact opening coordinates. -/
def transportNoise (e : IsometricCochainEquiv F G) (noise : HodgeNoise F) :
    HodgeNoise G where
  exactOpening := e.degreeZero noise.exactOpening
  coexactOpening := e.degreeTwo noise.coexactOpening

theorem transportNoise_exactComponent
    (e : IsometricCochainEquiv F G) (noise : HodgeNoise F) :
    (e.transportNoise noise).exactComponent = e.degreeOne noise.exactComponent :=
  (LinearMap.congr_fun e.delta0_commutes noise.exactOpening).symm

theorem transportNoise_coexactComponent
    (e : IsometricCochainEquiv F G) (noise : HodgeNoise F) :
    (e.transportNoise noise).coexactComponent = e.degreeOne noise.coexactComponent :=
  e.delta1_adjoint_naturality noise.coexactOpening

/-- Both components, hence the entire structured noise value, are transported. -/
theorem transportNoise_value
    (e : IsometricCochainEquiv F G) (noise : HodgeNoise F) :
    (e.transportNoise noise).value = e.degreeOne noise.value := by
  change (e.transportNoise noise).exactComponent +
    (e.transportNoise noise).coexactComponent =
      e.degreeOne (noise.exactComponent + noise.coexactComponent)
  rw [e.transportNoise_exactComponent, e.transportNoise_coexactComponent,
    e.degreeOne.map_add]

@[simp]
theorem transportNoise_refl (noise : HodgeNoise F) :
    (refl F).transportNoise noise = noise := by
  cases noise
  rfl

@[simp]
theorem transportNoise_symm (e : IsometricCochainEquiv F G) (noise : HodgeNoise F) :
    e.symm.transportNoise (e.transportNoise noise) = noise := by
  cases noise
  simp [transportNoise, symm]

theorem transportNoise_trans
    (e : IsometricCochainEquiv F G) (f : IsometricCochainEquiv G K)
    (noise : HodgeNoise F) :
    (e.trans f).transportNoise noise = f.transportNoise (e.transportNoise noise) := rfl

end IsometricCochainEquiv

/-- A chain isometry that also preserves the chosen degree-one integral lattice.
The opening coordinates remain real; integral noise is not asserted. -/
structure IntegralCochainEquiv (I : IntegralStructure F) (J : IntegralStructure G)
    extends IsometricCochainEquiv F G where
  integralOne_iff : ∀ b : F.C1,
    b ∈ I.integralOneCochains ↔ degreeOne b ∈ J.integralOneCochains

namespace IntegralCochainEquiv

variable {I : IntegralStructure F} {J : IntegralStructure G} {L : IntegralStructure K}

def refl (I : IntegralStructure F) : IntegralCochainEquiv I I where
  toIsometricCochainEquiv := IsometricCochainEquiv.refl F
  integralOne_iff _ := Iff.rfl

def symm (e : IntegralCochainEquiv I J) : IntegralCochainEquiv J I := by
  refine {
    toIsometricCochainEquiv := IsometricCochainEquiv.symm e.toIsometricCochainEquiv
    integralOne_iff := ?_
  }
  intro b
  change b ∈ J.integralOneCochains ↔ e.degreeOne.symm b ∈ I.integralOneCochains
  simpa only [LinearIsometryEquiv.apply_symm_apply] using
    (e.integralOne_iff (e.degreeOne.symm b)).symm

def trans (e : IntegralCochainEquiv I J) (f : IntegralCochainEquiv J L) :
    IntegralCochainEquiv I L where
  toIsometricCochainEquiv := e.toIsometricCochainEquiv.trans f.toIsometricCochainEquiv
  integralOne_iff b := (e.integralOne_iff b).trans (f.integralOne_iff (e.degreeOne b))

/-- Integral and harmonic membership are preserved by the same actual map. -/
theorem harmonicOne_iff (e : IntegralCochainEquiv I J) (b : F.C1) :
    b ∈ I.harmonicOneLattice ↔ e.degreeOne b ∈ J.harmonicOneLattice := by
  change (b ∈ I.integralOneCochains ∧ F.IsHarmonicOneCochain b) ↔
    (e.degreeOne b ∈ J.integralOneCochains ∧
      G.IsHarmonicOneCochain (e.degreeOne b))
  exact and_congr (e.integralOne_iff b)
    (e.toIsometricCochainEquiv.isHarmonicOneCochain_iff b)

/-- The intrinsic harmonic lattices are equivalent as additive groups. -/
def harmonicLatticeEquiv (e : IntegralCochainEquiv I J) :
    I.harmonicOneLattice ≃+ J.harmonicOneLattice where
  toFun h := ⟨e.degreeOne h.1, (e.harmonicOne_iff h.1).mp h.2⟩
  invFun h := ⟨e.degreeOne.symm h.1,
    (e.harmonicOne_iff (e.degreeOne.symm h.1)).mpr
      (by simp)⟩
  left_inv h := by
    apply Subtype.ext
    exact e.degreeOne.symm_apply_apply h.1
  right_inv h := by
    apply Subtype.ext
    exact e.degreeOne.apply_symm_apply h.1
  map_add' a b := by
    apply Subtype.ext
    exact e.degreeOne.map_add a.1 b.1

/-- Rotate the actual integral message and both opening coordinates together. -/
def transportSample (e : IntegralCochainEquiv I J) (sample : HodgeEncryptedCochain I) :
    HodgeEncryptedCochain J where
  message := e.harmonicLatticeEquiv sample.message
  opening := e.toIsometricCochainEquiv.transportNoise sample.opening

theorem transportSample_message
    (e : IntegralCochainEquiv I J) (sample : HodgeEncryptedCochain I) :
    (e.transportSample sample).message.1 = e.degreeOne sample.message.1 := rfl

theorem transportSample_opening
    (e : IntegralCochainEquiv I J) (sample : HodgeEncryptedCochain I) :
    (e.transportSample sample).opening =
      e.toIsometricCochainEquiv.transportNoise sample.opening := rfl

/-- Rotating a sample also transports its raw observed cochain. -/
theorem transportSample_observed
    (e : IntegralCochainEquiv I J) (sample : HodgeEncryptedCochain I) :
    (e.transportSample sample).observed = e.degreeOne sample.observed := by
  change e.degreeOne sample.message.1 +
    (e.toIsometricCochainEquiv.transportNoise sample.opening).value =
      e.degreeOne (sample.message.1 + sample.opening.value)
  rw [e.toIsometricCochainEquiv.transportNoise_value, e.degreeOne.map_add]

/-- The recipient's target projector recovers the transported original message. -/
theorem transportSample_projection
    (e : IntegralCochainEquiv I J) (sample : HodgeEncryptedCochain I) :
    G.harmonicOneProjection (e.transportSample sample).observed =
      e.degreeOne sample.message.1 :=
  (e.transportSample sample).harmonicOneProjection_observed

@[simp]
theorem transportSample_refl (sample : HodgeEncryptedCochain I) :
    (refl I).transportSample sample = sample := by
  cases sample
  rfl

@[simp]
theorem transportSample_symm (e : IntegralCochainEquiv I J)
    (sample : HodgeEncryptedCochain I) :
    (IntegralCochainEquiv.symm e).transportSample (e.transportSample sample) = sample := by
  cases sample with
  | mk message opening =>
    change HodgeEncryptedCochain.mk
      ((IntegralCochainEquiv.symm e).harmonicLatticeEquiv (e.harmonicLatticeEquiv message))
      (e.toIsometricCochainEquiv.symm.transportNoise
        (e.toIsometricCochainEquiv.transportNoise opening)) =
      HodgeEncryptedCochain.mk message opening
    rw [e.toIsometricCochainEquiv.transportNoise_symm]
    congr 1
    apply Subtype.ext
    exact e.degreeOne.symm_apply_apply message.1

/-- Successive rotations act on the same sample in their specified order. -/
theorem transportSample_trans
    (e : IntegralCochainEquiv I J) (f : IntegralCochainEquiv J L)
    (sample : HodgeEncryptedCochain I) :
    (IntegralCochainEquiv.trans e f).transportSample sample =
      f.transportSample (e.transportSample sample) := rfl

end IntegralCochainEquiv

end HomotopicalEncryption.Sheaf.CellularSheaf
