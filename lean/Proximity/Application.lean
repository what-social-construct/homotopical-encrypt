module

public import Proximity.Application.Projection
public import Proximity.Application.Problem
public import Proximity.Application.Calibration
public import Proximity.Application.DistanceCalibration
public import Proximity.Application.GapBoundary

@[expose] public section

/-!
# Generic proximity application interfaces

Abstract projection and source-to-code calibration contracts. No commitment,
cochain, runtime, or concrete field construction is imported here.
-/
