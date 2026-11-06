module

public import Proximity.Core.BlockCode
public import Proximity.Core.ReedSolomon
public import Proximity.Core.PlanePair
public import Proximity.Core.FiniteThreshold
public import Proximity.Core.Distance
public import Proximity.Core.RadiusShell

@[expose] public section

/-!
# Proximity coding core

Application-independent block-code, Reed--Solomon, pair-word, and finite-grid
threshold foundations shared by the list-decoding and
mutual-correlated-agreement targets.
-/
