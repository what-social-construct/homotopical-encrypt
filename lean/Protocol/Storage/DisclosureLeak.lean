module

public import Protocol.Storage.PublicView
public import Protocol.Storage.CanonicalSystematic

@[expose] public section

/-!
# Direct HCP-message recovery in the canonical systematic source

The same exact payload and full cochain that appear in an explicit HCP
disclosure determine the harmonic message for the canonical systematic RS
sheaf. Its face carrier is empty, so its coexact noise component vanishes.
This is an algebraic disclosure result; the real cochain still has no selected
finite wire codec, and the base storage release does not include it.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Storage

open Sheaf CellularSheaf

variable
  {integral : IntegralStructure CanonicalSystematic.sheaf}
  {payload : CochainPayloadInterpretation CanonicalSystematic.sheaf}
  {PublicClass Lifecycle : Type*}
  {classify : SheafStateSnapshot CanonicalSystematic.sheaf → PublicClass}
  {Binds : TCB.HCPStackBinding Lifecycle PublicClass CanonicalSystematic.sheaf.C1}

/-- In the selected canonical sheaf, the full-cochain disclosure and the
interpretation's decoded exact payload determine the harmonic message. -/
theorem canonical_hcpDisclosure_recovers_message
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32) :
    O.latticeObject.1 =
      WithLp.toLp 2 (hcpDisclosure O identify parameters).observation.2 -
        payload.decode (hcpDisclosure O identify parameters).base.cochain := by
  change O.latticeObject.1 = O.cochainObject - payload.decode O.artifact.cochain
  exact O.message_eq_cochainObject_sub_decoded_of_delta1_zero
    CanonicalSystematic.delta1_zero

/-- When the private interpretation agrees on this artifact with the selected
canonical public layout, the right-hand side reads only the disclosed full
cochain and the original public payload. -/
theorem canonical_hcpDisclosure_recovers_message_of_layout
    (O : TCB.BoundHCPObservation integral payload PublicClass Lifecycle classify Binds)
    (identify : Lifecycle → TCB.Hash32) (parameters : TCB.Hash32)
    (hdecode : payload.decode O.artifact.cochain =
      CanonicalSystematic.layout.decode O.artifact.cochain) :
    O.latticeObject.1 =
      WithLp.toLp 2 (hcpDisclosure O identify parameters).observation.2 -
        CanonicalSystematic.layout.decode
          (hcpDisclosure O identify parameters).base.cochain := by
  rw [canonical_hcpDisclosure_recovers_message O identify parameters,
    hcpDisclosure_cochain, hdecode]

end HomotopicalEncryption.Protocol.Storage
