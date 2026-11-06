module

public import Protocol.Evidence
public import TCB.CompressionBoundary
public import Protocol.Storage.Core
public import Protocol.Storage.CanonicalRS
public import Protocol.Storage.CanonicalSystematic
public import Protocol.Storage.ThreeLevelMetrics
public import Protocol.Storage.CanonicalThreeLevel
public import Protocol.Storage.CanonicalCalibration

@[expose] public section

/-!
  Sheaf-storage checkpoint and evidence-anchor interface.

  The mathematical core retains one snapshot/payload context, existing typed
  projection and gate prefixes, append-once manifests, sealing and receipt-bound
  local consumption. The history anchor joins the same candidate, snapshot,
  original artifact and sealed manifest, with explicit authentication-profile
  relations; its projection adapter retains the actual six-stage prefix and
  includes its gate database. The canonical application joins the same observed cochain
  to the existing pair calibration. Hashing, canonical bytes, actual codec/lift
  instantiation, database atomicity and crash consistency remain profile/runtime
  obligations. `Protocol.Storage.Core` is the focused import without the legacy
  broad evidence facade or optional canonical-field application.
-/
