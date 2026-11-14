module

public import Protocol.Storage.Context
public import Protocol.Storage.Checkpoint
public import Protocol.Storage.Projection
public import Protocol.Storage.Calibration
public import Protocol.Storage.CoordinateCodec
public import Protocol.Storage.HCP
public import Protocol.Storage.PublicView
public import Protocol.Storage.CiphertextManifest
public import Protocol.Storage.Anchor
public import Protocol.Storage.ProjectionAnchor

@[expose] public section

/-!
# Sheaf-storage mathematical core

The fixed original snapshot/artifact context, incremental typed projection
and gate prefixes, exact sealed manifest and receipt-indexed local consumption
lifecycle, together with the canonical raw two-slot exact-artifact/ciphertext
manifest, same-candidate history anchor and actual projection/gate-database
adapter. Raw sealing does not establish payload acceptance or native
ciphertext validity. The coupled decoder/observation certificate, canonical RS
application and executable backend remain separate layers. The focused
transition kernel is exported by `Protocol.Core`; it remains independent of
this storage layer.
-/
