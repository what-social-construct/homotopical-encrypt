module

public import TCB.CompressionBoundary
public import TCB.ObservationBoundary

@[expose] public section

/-
  Witness/verifier pattern.

  Paper correspondence:
  - Paper 2: witness/envelope, runtime observation and evidence handoff under
    explicit acceptance, extraction and byte-verification contracts.

  This module assembles a semantic witness/verifier envelope:

    full/private witness
      -> compressed public shadow
      -> proof-carrying artifact
      -> runtime-observed public statement
      -> public state-root update

  It does not define concrete byte formats, hash functions, storage engines, or
  proof systems. Those remain Rust/runtime obligations. Lean records the
  semantic handoff after validity has been established. The acceptance carrier
  contains statement truth and the witness contains its validity proof; the
  consequences below recover those supplied facts. They do not prove that a
  concrete Rust byte verifier establishes them. Data-indexed primitive checks
  and protocol adapters own that separate implication and its error events.
-/

namespace HomotopicalEncryption
namespace TCB
namespace WitnessVerifier

open CompressionBoundary
open CompressionBoundary.CompressionContract

/--
Public roots/digests for a state transition.

`BindsPublicInputs` is intentionally abstract: Rust owns canonical encoding,
domain separation, inclusion proofs, and the concrete authenticated database or
ledger root scheme.
-/
structure PublicStateUpdate where
  beforeRoot : Hash32
  afterRoot : Hash32
  transitionDigest : Hash32
  BindsPublicInputs : Prop
  DomainSeparated : Prop

def PublicStateUpdate.WellFormed (U : PublicStateUpdate) : Prop :=
  U.BindsPublicInputs ∧ U.DomainSeparated

/--
A full/private witness and its compressed public shadow under a compression
contract.
-/
structure WitnessCompression (K : CompressionContract) where
  witness : K.Full
  compressed : CompressedShadow K
  compresses : K.Compresses witness compressed.shadow
  witnessValid : K.FullValid witness

namespace WitnessCompression

variable {K : CompressionContract}

/-- A valid witness compresses to a valid public shadow. -/
theorem shadowValid (W : WitnessCompression K) :
    K.ShadowValid W.compressed.shadow :=
  K.sound W.compresses W.witnessValid

/-- A valid witness plus digest binding gives a well-formed compressed shadow. -/
theorem compressed_wellFormed (W : WitnessCompression K) :
    W.compressed.WellFormed :=
  ⟨shadowValid W, W.compressed.bindsDigest⟩

end WitnessCompression

/--
End-to-end witness/verifier envelope.

The envelope ties together:
- a private witness and compressed shadow;
- a proof-carrying artifact about that shadow;
- an observation carrying the semantic acceptance contract;
- a public state-root update bound to the accepted public inputs.
-/
structure WitnessVerifierEnvelope (R : RuntimeBoundary) where
  K : CompressionContract
  witness : WitnessCompression K
  proof : ProofCarryingCommittedCochain
  observation : ObservationBoundary.ObservedStatement R
  proofCarriesShadow : ProofCarriesCompressedShadow K proof
  proofCarriesWitnessShadow : proofCarriesShadow.compressed = witness.compressed
  observationUsesProof : observation.artifact = proof
  stateUpdate : PublicStateUpdate
  stateUpdateWellFormed : stateUpdate.WellFormed

namespace WitnessVerifierEnvelope

variable {R : RuntimeBoundary}

/-- The proof-carrying artifact accepted by the observation is well formed. -/
theorem proof_wellFormed (E : WitnessVerifierEnvelope R) :
    E.proof.WellFormed := by
  have hObservedArtifact : E.observation.artifact.WellFormed := by
    rcases E.observation.accepted with ⟨_, _, _, _, hArtifact⟩
    exact hArtifact
  simpa [E.observationUsesProof] using hObservedArtifact

/-- Runtime acceptance recovers the observed public statement. -/
theorem publicStatement_holds (E : WitnessVerifierEnvelope R) :
    E.observation.publicStatement :=
  ObservationBoundary.ObservedStatement.publicStatement_holds E.observation

/-- The proof certifies validity of the compressed public shadow it carries. -/
theorem proof_shadowValid (E : WitnessVerifierEnvelope R) :
    E.K.ShadowValid E.proofCarriesShadow.compressed.shadow :=
  ProofCarriesCompressedShadow.shadowValid E.proofCarriesShadow
    (proof_wellFormed E)

/--
The proof-carried shadow is the witness shadow, so the accepted artifact
certifies the witness-derived public shadow.
-/
theorem verified_witnessShadowValid (E : WitnessVerifierEnvelope R) :
    E.K.ShadowValid E.witness.compressed.shadow := by
  simpa [E.proofCarriesWitnessShadow] using proof_shadowValid E

/-- The witness itself also gives the same public-shadow validity. -/
theorem witness_shadowValid (E : WitnessVerifierEnvelope R) :
    E.K.ShadowValid E.witness.compressed.shadow :=
  WitnessCompression.shadowValid E.witness

/-- The compressed witness shadow is well formed. -/
theorem witness_compressed_wellFormed (E : WitnessVerifierEnvelope R) :
    E.witness.compressed.WellFormed :=
  WitnessCompression.compressed_wellFormed E.witness

/-- The public state update is well formed by the envelope contract. -/
theorem stateUpdate_wellFormed (E : WitnessVerifierEnvelope R) :
    E.stateUpdate.WellFormed :=
  E.stateUpdateWellFormed

end WitnessVerifierEnvelope

end WitnessVerifier
end TCB
end HomotopicalEncryption
