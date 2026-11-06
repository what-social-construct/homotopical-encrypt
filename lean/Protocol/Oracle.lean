module

public import Gates.Oracle
public import TCB.ObservationBoundary

@[expose] public section

/-!
  Protocol consumption of authenticated oracle judgments.

  The shared Heyting algebra remains mathematical infrastructure. Signed
  attestations, round-bound judgments, retry transitions, and the operational
  handling of `Hold` belong here.
-/
