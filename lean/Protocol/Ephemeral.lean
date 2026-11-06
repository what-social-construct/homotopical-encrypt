module

public import Axioms.Fibration

@[expose] public section

/-!
  Protocol lifecycle for ephemeral representatives.

  Path, classifier, transport, and representative mathematics remain in
  `Axioms.Fibration`. Generation, freshness, single-use consumption, replay
  exclusion, retirement, and runtime refinement belong under this module.
-/
