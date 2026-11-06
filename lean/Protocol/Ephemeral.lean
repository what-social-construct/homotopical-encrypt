module

public import Axioms.Fibration
public import Protocol.Ephemeral.Rotation
public import Protocol.Ephemeral.Delivery
public import Protocol.Ephemeral.HCP

@[expose] public section

/-!
  Protocol lifecycle for ephemeral representatives.

  The original path/classifier objects remain in `Axioms.Fibration`.
  Actual integral Hodge transport and coefficient recovery live in `Sheaf`;
  this facade exports compatible presented rotations, original-payload
  migration under explicit decoder laws, and recipient/epoch/context-bound
  delivery receipts under explicit channel contracts. Concrete axis-family
  examples are in `Protocol.Ephemeral.Examples`.

  Generation, secure delivery implementations, freshness, single-use
  consumption, replay exclusion, retirement and runtime refinement remain
  separate obligations. Scope equality does not authenticate a caller.
-/
