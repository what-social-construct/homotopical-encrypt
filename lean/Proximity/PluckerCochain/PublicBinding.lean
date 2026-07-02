import Proximity.PluckerCochain.Concrete
import TCB.ObservationBoundary

/-
  Public/storage-layer binding between Plucker shadows and cochain payloads.

  The chain/storage layer constructs and accepts the actual
  `CochainCommitmentData` payload. Proximity should not pretend that every
  transaction commitment is definitionally produced by a Plucker encoder.
  Instead, the public layer carries an observed/proof-carrying statement that
  the accepted payload realizes a public Plucker shadow.

  A deterministic payload encoder is still useful as a special case, but the
  storage-native shape is relational:

      public Plucker shadow σ
        -- proof/public statement -->
      observed CochainCommitmentData c
-/

namespace Hcrypt
namespace Proximity
namespace PluckerCochain
namespace PublicBinding

open GrassmannianPlucker

noncomputable section

variable {n : Type} [Fintype n] [DecidableEq n] {r : ℕ}

/--
Public hash handle for a Plucker shadow.

The digest is a storage/proof-transcript handle. It does not replace the
mathematical shadow; it binds canonical public bytes for the shadow at the TCB
boundary.
-/
structure HashedPluckerShadow (P : FramedSystem n r) where
  shadow : P.Shadow
  digest : TCB.Hash32
  Binds : Prop

namespace HashedPluckerShadow

variable {P : FramedSystem n r}

/-- A hashed Plucker shadow is well formed when the shadow is valid and digest-bound. -/
def WellFormed (A : HashedPluckerShadow P) : Prop :=
  P.Normalized A.shadow ∧ P.SupportAdmissible A.shadow ∧ A.Binds

/-- Build a hash handle for the public shadow of a valid frame witness. -/
def ofFrame
    (W : FrameWitness n r)
    (digest : TCB.Hash32)
    (hBind : TCB.Hash32 → Prop)
    (_hW : ValidFrame P W) :
    HashedPluckerShadow P where
  shadow := P.publicShadow W
  digest := digest
  Binds := hBind digest

/-- A frame-derived hashed Plucker shadow is well formed when the digest binds. -/
theorem wellFormed_ofFrame
    (W : FrameWitness n r)
    (digest : TCB.Hash32)
    (hBind : TCB.Hash32 → Prop)
    (hDigest : hBind digest)
    (hW : ValidFrame P W) :
    (ofFrame (P := P) W digest hBind hW).WellFormed :=
  ⟨hW.2.1, hW.2.2, hDigest⟩

/-- Well-formed hash handles expose the runtime-owned digest binding fact. -/
theorem binds
    {A : HashedPluckerShadow P}
    (hA : A.WellFormed) :
    A.Binds :=
  hA.2.2

end HashedPluckerShadow

/--
Storage/public-layer realization relation.

`Realizes σ c` means the accepted cochain commitment payload `c` is the public
storage artifact corresponding to the Plucker shadow `σ`. Concrete byte
serialization, hash binding, inclusion proofs, and proof verification remain
runtime/TCB-owned.
-/
structure PayloadRealization (P : FramedSystem n r) where
  Realizes : P.Shadow → CochainBridge.CommittedCochain → Prop
  wellFormed_of_realizes :
    ∀ {σ : P.Shadow} {c : CochainBridge.CommittedCochain},
      Realizes σ c → c.WellFormed
  respects_shadow_eq :
    ∀ {σ τ : P.Shadow} {c : CochainBridge.CommittedCochain},
      σ = τ → Realizes σ c → Realizes τ c

namespace PayloadRealization

variable {P : FramedSystem n r}

/-- A realized payload over a frame witness uses that witness's public shadow. -/
def RealizesFrame
    (B : PayloadRealization P)
    (W : FrameWitness n r)
    (c : CochainBridge.CommittedCochain) : Prop :=
  ValidFrame P W ∧ B.Realizes (P.publicShadow W) c

/-- Realized frame payloads are well formed at the chain commitment layer. -/
theorem wellFormed_of_realizesFrame
    (B : PayloadRealization P)
    {W : FrameWitness n r}
    {c : CochainBridge.CommittedCochain}
    (h : B.RealizesFrame W c) :
    c.WellFormed :=
  B.wellFormed_of_realizes h.2

/-- Realized frame payloads become global-section candidates once sheaf coherence holds. -/
theorem globalSectionCandidate_of_realizesFrame
    {S : Axioms.SheafCoherence}
    (B : PayloadRealization P)
    (hS : Axioms.SheafCoherenceWellFormed S)
    {W : FrameWitness n r}
    {c : CochainBridge.CommittedCochain}
    (h : B.RealizesFrame W c) :
    CochainBridge.CommittedCochain.GlobalSectionCandidate S c :=
  ⟨B.wellFormed_of_realizesFrame h, hS⟩

/--
Deterministic encoders are a special case of public payload realization.

The relation is restricted to valid-frame shadows so the encoder's
well-formedness guarantee can be used without claiming all arbitrary shadows
are meaningful chain payloads.
-/
def ofPayloadEncoder
    (E : Concrete.PayloadEncoder P) :
    PayloadRealization P where
  Realizes := fun σ c =>
    c = E.encode σ ∧
      ∃ W : FrameWitness n r, ValidFrame P W ∧ σ = P.publicShadow W
  wellFormed_of_realizes := by
    intro σ c h
    rcases h with ⟨rfl, W, hW, hσ⟩
    simpa [hσ] using E.wellFormed_of_validFrame W hW
  respects_shadow_eq := by
    intro σ τ c hστ h
    subst hστ
    exact h

end PayloadRealization

/--
An observed public-layer binding from a runtime-accepted proof-carrying cochain
artifact to a Plucker frame witness.

The observation exposes the actual chain payload. Its public statement proves
that this payload realizes the Plucker public shadow.
-/
structure ObservedFrameBinding
    (R : TCB.RuntimeBoundary)
    {P : FramedSystem n r}
    (B : PayloadRealization P)
    (S : Axioms.SheafCoherence)
    (W : FrameWitness n r) where
  shadowArtifact : HashedPluckerShadow P
  shadowArtifactWellFormed : shadowArtifact.WellFormed
  shadowMatchesFrame : shadowArtifact.shadow = P.publicShadow W
  observation : TCB.ObservationBoundary.ObservedStatement R
  validFrame : ValidFrame P W
  sheafWellFormed : Axioms.SheafCoherenceWellFormed S
  statementRealizes :
    observation.publicStatement →
      B.Realizes shadowArtifact.shadow observation.cochain

namespace ObservedFrameBinding

variable
    {R : TCB.RuntimeBoundary}
    {P : FramedSystem n r}
    {B : PayloadRealization P}
    {S : Axioms.SheafCoherence}
    {W : FrameWitness n r}

/-- The observed cochain payload realizes the Plucker public shadow. -/
theorem realizes
    (O : ObservedFrameBinding R B S W) :
    B.Realizes (P.publicShadow W) O.observation.cochain :=
  B.respects_shadow_eq O.shadowMatchesFrame
    (O.statementRealizes
      (TCB.ObservationBoundary.ObservedStatement.publicStatement_holds O.observation))

/-- The Plucker-shadow hash handle is bound at the public/TCB layer. -/
theorem shadowDigestBinds
    (O : ObservedFrameBinding R B S W) :
    O.shadowArtifact.Binds :=
  HashedPluckerShadow.binds O.shadowArtifactWellFormed

/-- The observed payload is well formed as a chain cochain commitment. -/
theorem cochain_wellFormed
    (O : ObservedFrameBinding R B S W) :
    O.observation.cochain.WellFormed :=
  B.wellFormed_of_realizes O.realizes

/-- The observed payload is a global-section candidate under the supplied sheaf context. -/
theorem globalSectionCandidate
    (O : ObservedFrameBinding R B S W) :
    CochainBridge.CommittedCochain.GlobalSectionCandidate S
      O.observation.cochain :=
  ⟨O.cochain_wellFormed, O.sheafWellFormed⟩

/-- Any local syndrome target accepts the observed payload as a codeword. -/
theorem localCodeword
    {L : LocalSyndromeTarget S}
    (O : ObservedFrameBinding R B S W) :
    L.Codeword O.observation.cochain :=
  L.codeword_of_globalCandidate O.globalSectionCandidate

end ObservedFrameBinding

end

end PublicBinding
end PluckerCochain
end Proximity
end Hcrypt
