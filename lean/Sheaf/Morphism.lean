module

public import Sheaf.Cellular

@[expose] public section

/-!
# Morphisms of finite cellular sheaves

This module gives the typed same-base natural-transformation object needed by
the Paper 1 cellular-sheaf layer. A morphism consists of one linear map on every
stalk, compatible with the restriction maps on each incident flag. The
stalkwise maps induce maps on `C⁰`, `C¹`, and `C²`, and restriction naturality
forces those induced maps to commute with the cellular coboundaries.

This is deliberately narrower than a pullback or pushforward along a map of
cell complexes. No adjunction or round-trip equivalence is asserted here.
-/

set_option autoImplicit false

open scoped BigOperators RealInnerProductSpace

noncomputable section

namespace Hcrypt
namespace Sheaf
namespace CellularSheaf

variable
  {Vertex Edge Face : Type*}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face}

/--
A stalkwise linear morphism between two cellular sheaves on the same finite
oriented complex.

The naturality laws are required only on genuine incidences. Nonincident
restriction-map values never contribute to the cellular coboundaries.
-/
structure Morphism (F G : CellularSheaf X) where
  vertexMap :
    ∀ v, Coord (F.vertexDim v) →ₗ[ℝ] Coord (G.vertexDim v)
  edgeMap :
    ∀ e, Coord (F.edgeDim e) →ₗ[ℝ] Coord (G.edgeDim e)
  faceMap :
    ∀ f, Coord (F.faceDim f) →ₗ[ℝ] Coord (G.faceDim f)
  naturality01 :
    ∀ v e, X.VertexEdgeIncident v e →
      (edgeMap e).comp (F.restrict01 v e) =
        (G.restrict01 v e).comp (vertexMap v)
  naturality12 :
    ∀ e f, X.EdgeFaceIncident e f →
      (faceMap f).comp (F.restrict12 e f) =
        (G.restrict12 e f).comp (edgeMap e)
  naturality02 :
    ∀ v e f,
      X.VertexEdgeIncident v e →
      X.EdgeFaceIncident e f →
      (faceMap f).comp (F.restrict02 v f) =
        (G.restrict02 v f).comp (vertexMap v)

namespace Morphism

variable {F G H : CellularSheaf X}

/-- Componentwise map induced on degree-zero cochains. -/
def mapC0 (η : Morphism F G) : F.C0 →ₗ[ℝ] G.C0 :=
  assemble G.vertexDim fun v =>
    (η.vertexMap v).comp (component F.vertexDim v)

/-- Componentwise map induced on degree-one cochains. -/
def mapC1 (η : Morphism F G) : F.C1 →ₗ[ℝ] G.C1 :=
  assemble G.edgeDim fun e =>
    (η.edgeMap e).comp (component F.edgeDim e)

/-- Componentwise map induced on degree-two cochains. -/
def mapC2 (η : Morphism F G) : F.C2 →ₗ[ℝ] G.C2 :=
  assemble G.faceDim fun f =>
    (η.faceMap f).comp (component F.faceDim f)

@[simp] theorem mapC0_apply
    (η : Morphism F G) (x : F.C0)
    (v : Vertex) (i : Fin (G.vertexDim v)) :
    η.mapC0 x ⟨v, i⟩ = η.vertexMap v (component F.vertexDim v x) i :=
  rfl

@[simp] theorem mapC1_apply
    (η : Morphism F G) (x : F.C1)
    (e : Edge) (i : Fin (G.edgeDim e)) :
    η.mapC1 x ⟨e, i⟩ = η.edgeMap e (component F.edgeDim e x) i :=
  rfl

@[simp] theorem mapC2_apply
    (η : Morphism F G) (x : F.C2)
    (f : Face) (i : Fin (G.faceDim f)) :
    η.mapC2 x ⟨f, i⟩ = η.faceMap f (component F.faceDim f x) i :=
  rfl

private lemma weighted_naturality01
    (η : Morphism F G)
    (v : Vertex) (e : Edge)
    (x : Coord (F.vertexDim v)) :
    X.incidence01Real v e •
        η.edgeMap e (F.restrict01 v e x) =
      X.incidence01Real v e •
        G.restrict01 v e (η.vertexMap v x) := by
  by_cases h : X.incidence01Real v e = 0
  · simp [h]
  have hIncident : X.VertexEdgeIncident v e :=
    (X.incidence01Real_ne_zero_iff v e).mp h
  have hNatural :=
    LinearMap.congr_fun (η.naturality01 v e hIncident) x
  simpa [LinearMap.comp_apply] using
    congrArg (fun y => X.incidence01Real v e • y) hNatural

private lemma weighted_naturality12
    (η : Morphism F G)
    (e : Edge) (f : Face)
    (x : Coord (F.edgeDim e)) :
    X.incidence12Real e f •
        η.faceMap f (F.restrict12 e f x) =
      X.incidence12Real e f •
        G.restrict12 e f (η.edgeMap e x) := by
  by_cases h : X.incidence12Real e f = 0
  · simp [h]
  have hIncident : X.EdgeFaceIncident e f :=
    (X.incidence12Real_ne_zero_iff e f).mp h
  have hNatural :=
    LinearMap.congr_fun (η.naturality12 e f hIncident) x
  simpa [LinearMap.comp_apply] using
    congrArg (fun y => X.incidence12Real e f • y) hNatural

/-- Naturality of the induced cochain maps at `δ₀`. -/
theorem mapC1_delta0 (η : Morphism F G) :
    η.mapC1.comp F.delta0 = G.delta0.comp η.mapC0 := by
  apply LinearMap.ext
  intro x
  apply PiLp.ext
  intro p
  rcases p with ⟨e, i⟩
  simp only [mapC1, mapC0, delta0, assemble, delta0At, component,
    LinearMap.comp_apply, LinearMap.sum_apply, LinearMap.smul_apply]
  change
    (η.edgeMap e
      ((Finset.univ : Finset Vertex).sum fun v =>
        X.incidence01Real v e •
          F.restrict01 v e (component F.vertexDim v x))) i =
      ((Finset.univ : Finset Vertex).sum fun v =>
        X.incidence01Real v e •
          G.restrict01 v e
            (η.vertexMap v (component F.vertexDim v x))) i
  rw [map_sum]
  simp_rw [map_smul]
  simp_rw [η.weighted_naturality01]

/-- Naturality of the induced cochain maps at `δ₁`. -/
theorem mapC2_delta1 (η : Morphism F G) :
    η.mapC2.comp F.delta1 = G.delta1.comp η.mapC1 := by
  apply LinearMap.ext
  intro x
  apply PiLp.ext
  intro p
  rcases p with ⟨f, i⟩
  simp only [mapC2, mapC1, delta1, assemble, delta1At, component,
    LinearMap.comp_apply, LinearMap.sum_apply, LinearMap.smul_apply]
  change
    (η.faceMap f
      ((Finset.univ : Finset Edge).sum fun e =>
        X.incidence12Real e f •
          F.restrict12 e f (component F.edgeDim e x))) i =
      ((Finset.univ : Finset Edge).sum fun e =>
        X.incidence12Real e f •
          G.restrict12 e f
            (η.edgeMap e (component F.edgeDim e x))) i
  rw [map_sum]
  simp_rw [map_smul]
  simp_rw [η.weighted_naturality12]

/-- Identity cellular-sheaf morphism. -/
def id (F : CellularSheaf X) : Morphism F F where
  vertexMap _ := LinearMap.id
  edgeMap _ := LinearMap.id
  faceMap _ := LinearMap.id
  naturality01 _ _ _ := by ext; rfl
  naturality12 _ _ _ := by ext; rfl
  naturality02 _ _ _ _ _ := by ext; rfl

/-- Composition of cellular-sheaf morphisms. -/
def comp (θ : Morphism G H) (η : Morphism F G) : Morphism F H where
  vertexMap v := (θ.vertexMap v).comp (η.vertexMap v)
  edgeMap e := (θ.edgeMap e).comp (η.edgeMap e)
  faceMap f := (θ.faceMap f).comp (η.faceMap f)
  naturality01 v e hve := by
    rw [LinearMap.comp_assoc, η.naturality01 v e hve]
    rw [← LinearMap.comp_assoc, θ.naturality01 v e hve]
    rw [LinearMap.comp_assoc]
  naturality12 e f hef := by
    rw [LinearMap.comp_assoc, η.naturality12 e f hef]
    rw [← LinearMap.comp_assoc, θ.naturality12 e f hef]
    rw [LinearMap.comp_assoc]
  naturality02 v e f hve hef := by
    rw [LinearMap.comp_assoc, η.naturality02 v e f hve hef]
    rw [← LinearMap.comp_assoc, θ.naturality02 v e f hve hef]
    rw [LinearMap.comp_assoc]

end Morphism

end CellularSheaf
end Sheaf
end Hcrypt
