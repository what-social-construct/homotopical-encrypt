import Mathlib
import Axioms.HomotopyClass

/-
  Fibration and ephemeral-fiber interface.

  This file owns the Lean-side mathematical vocabulary for fibers, transport,
  hidden fibration representatives, and ephemeral representatives.

  Trusted-computing-base split:
    - Lean specifies class/path semantics and transport admissibility.
    - Rust must enforce adversarial runtime facts: fresh generation, single-use
      consumption, zeroization/drop behavior, byte parsing, and endpoint limits.
    - Python may remain a research/reference implementation, but it is not the
      consensus authority for ephemeral-fiber lifecycle behavior.
-/

namespace Hcrypt
namespace Axioms

universe u v

/--
A dependent fiber system over a path-space base.

The base path-space supplies the homotopical notion of equality. The dependent
fiber assigns the data living over each base point, and `transport` moves fiber
data along hidden paths.
-/
structure FiberSystem (Base : Type u) [HasPathSpace Base] where
  Fiber : Base → Type v
  transport : ∀ {x y : Base}, HasPathSpace.Path x y → Fiber x → Fiber y

namespace FiberSystem

variable {Base : Type u} [HasPathSpace Base]

/-- A fiberwise invariant is preserved by all path transports. -/
def TransportPreserves (S : FiberSystem Base)
    (I : ∀ x : Base, S.Fiber x → Prop) : Prop :=
  ∀ {x y : Base} (p : HasPathSpace.Path x y) (a : S.Fiber x),
    I x a → I y (S.transport p a)

/--
Admissibility obligations for the transport used by protocol geometry.

This abstracts the role played by orthogonal/metric-preserving transport in the
runtime code without committing Lean to a concrete matrix representation.
-/
structure TransportAdmissibility (S : FiberSystem Base) where
  FiberInvariant : ∀ x : Base, S.Fiber x → Prop
  InvariantPreserved : TransportPreserves S FiberInvariant
  MetricOrOrthogonalPreserving : Prop

end FiberSystem

/-- A fibration classifier is the public homotopy-class fingerprint map. -/
abbrev FibrationClassifier (F : Type u) :=
  HomotopyClassifier F

/--
Ephemeral representative of a hidden fibration/fiber state.

Mathematically, the ephemeral representative is connected to the base hidden
representative by a path. If the public classifier respects paths, then the
ephemeral representative remains in the same public homotopy class.

`TransportAdmissible` is a Lean-side mathematical obligation. Runtime lifecycle
properties such as freshness, single-use, and memory wiping are intentionally
kept out of this structure.
-/
structure EphemeralFiberSpec {F : Type u} [HasPathSpace F]
    (C : FibrationClassifier F) (base : F) where
  representative : F
  path : HasPathSpace.Path base representative
  TransportAdmissible : Prop

namespace EphemeralFiberSpec

variable {F : Type u} [HasPathSpace F]

/-- The path witness makes an ephemeral representative path-equivalent to its base. -/
theorem pathEquivalent {C : FibrationClassifier F} {base : F}
    (e : EphemeralFiberSpec C base) :
    PathEquivalent base e.representative := by
  exact ⟨e.path⟩

/--
Ephemeral representatives preserve the public homotopy class whenever the
classifier is path-respecting.
-/
theorem sameHomotopyClass {C : FibrationClassifier F}
    (hC : PathRespectsHomotopyClass C) {base : F}
    (e : EphemeralFiberSpec C base) :
    SameHomotopyClass C base e.representative := by
  exact hC (pathEquivalent e)

/-- The public fingerprint of an ephemeral representative matches the base fingerprint. -/
theorem samePublicFingerprint {C : FibrationClassifier F}
    (hC : PathRespectsHomotopyClass C) {base : F}
    (e : EphemeralFiberSpec C base) :
    C.π e.representative = C.π base := by
  exact (sameHomotopyClass hC e).symm

/-- The ephemeral representative is a member of the base representative's public class. -/
theorem memHomotopyClassOf {C : FibrationClassifier F}
    (hC : PathRespectsHomotopyClass C) {base : F}
    (e : EphemeralFiberSpec C base) :
    e.representative ∈ HomotopyClassOf C base := by
  exact samePublicFingerprint hC e

/-- Mathematical well-formedness of an ephemeral representative. -/
abbrev WellFormed {C : FibrationClassifier F} {base : F}
    (e : EphemeralFiberSpec C base) : Prop :=
  e.TransportAdmissible

end EphemeralFiberSpec

/--
Rust-owned runtime obligations for ephemeral fibers.

Lean records these names so the TCB boundary is explicit, but it does not claim
to prove memory zeroization or endpoint hardening. Those are production runtime
properties for Rust tests, fuzzing, audit, and implementation review.
-/
structure EphemeralRuntimeObligations where
  FreshPerMessage : Prop
  SingleUse : Prop
  SecretTransportWiped : Prop
  RejectMalformedPublicBytes : Prop
  NoPythonConsensusAuthority : Prop

/--
Combined TCB contract for an ephemeral fiber.

The `MathSpec` is Lean-owned. The `Runtime` fields are Rust-owned obligations
that must be checked/hardened outside the proof kernel.
-/
structure EphemeralFiberTCBContract {F : Type u} [HasPathSpace F]
    (C : FibrationClassifier F) (base : F) where
  MathSpec : EphemeralFiberSpec C base
  Runtime : EphemeralRuntimeObligations

namespace EphemeralFiberTCBContract

variable {F : Type u} [HasPathSpace F]

/-- A TCB contract inherits the public-fingerprint theorem from its Lean math spec. -/
theorem samePublicFingerprint {C : FibrationClassifier F}
    (hC : PathRespectsHomotopyClass C) {base : F}
    (K : EphemeralFiberTCBContract C base) :
    C.π K.MathSpec.representative = C.π base := by
  exact EphemeralFiberSpec.samePublicFingerprint hC K.MathSpec

/-- Lean-side acceptance only checks mathematical admissibility. -/
abbrev MathAccepted {C : FibrationClassifier F} {base : F}
    (K : EphemeralFiberTCBContract C base) : Prop :=
  K.MathSpec.WellFormed

/-- Runtime acceptance is explicitly separate from Lean-side math acceptance. -/
abbrev RuntimeAccepted {F : Type u} [HasPathSpace F]
    {C : FibrationClassifier F} {base : F}
    (K : EphemeralFiberTCBContract C base) : Prop :=
  K.Runtime.FreshPerMessage
    ∧ K.Runtime.SingleUse
    ∧ K.Runtime.SecretTransportWiped
    ∧ K.Runtime.RejectMalformedPublicBytes
    ∧ K.Runtime.NoPythonConsensusAuthority

end EphemeralFiberTCBContract

end Axioms
end Hcrypt
