module

public import Protocol.Transfer.Certificates.Statement
public import Protocol.Transfer.Certificates.Evidence
public import Protocol.Consensus.Quorum

@[expose] public section

/-!
# Authenticated finite profile approval and exact implementation selection

The public descriptor retains the original metadata, parameter domain, claim
scope, rational calibration and actual public program/key/CRS bytes. Its
canonical format contains no private setup trapdoor. A complete existing
quorum proposal authenticates its dedicated registration root. This is a
setup approval, not an owned-transfer state update or a finality theorem.

Applicability compares all selected coordinates and the actual before-state
epoch. Program, verifier-key and CRS selection parses the approved bytes;
execution uses those actual parsed objects. An opaque identifier never
identifies an arbitrary function. The supplied parsers/interpreter and their
semantic refinement to the intended certificate relation remain explicit.
Neither registration nor execution agreement proves circuit soundness,
knowledge, honest setup generation or authenticated committee bootstrap.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Certificates.Profile

open Sheaf CellularSheaf
open _root_.HomotopicalEncryption.Protocol.Evidence.TransferTranscript
open Storage.CoupledCodec
open Ephemeral.ScopeCodec (encodeFixed parseFixed parseFixed_encodeFixed encodeFixed_append)

abbrev Bytes := List UInt8

/-- Exact public material approved for one finite certificate implementation. -/
structure Descriptor where
  metadata : ProofMetadata
  publicProfile : Bytes
  parameterSet : TCB.Hash32
  /-- `none` selects native certification; a level selects its required prefix. -/
  scope : Option Evidence.Level
  calibration : Option Codec.Calibration
  program : Bytes
  verifierKey : Bytes
  publicCRS : Bytes

def encodeMetadata (metadata : ProofMetadata) (rest : Bytes) : Bytes :=
  encodeNat metadata.schemaVersion
    (encodeFixed metadata.statementId
      (encodeFixed metadata.policyId
        (encodeFixed metadata.proofSystemId (encodeFixed metadata.verifierId rest))))

def parseMetadata (bytes : Bytes) : Option (ProofMetadata × Bytes) := do
  let (schemaVersion, rest) ← parseNat bytes
  let (statementId, rest) ← parseFixed 32 rest
  let (policyId, rest) ← parseFixed 32 rest
  let (proofSystemId, rest) ← parseFixed 32 rest
  let (verifierId, rest) ← parseFixed 32 rest
  some (⟨schemaVersion, statementId, policyId, proofSystemId, verifierId⟩, rest)

@[simp] theorem parseMetadata_encodeMetadata (metadata : ProofMetadata) (rest : Bytes) :
    parseMetadata (encodeMetadata metadata rest) = some (metadata, rest) := by
  cases metadata
  simp [parseMetadata, encodeMetadata]

theorem encodeMetadata_append (metadata : ProofMetadata) (rest suffix : Bytes) :
    encodeMetadata metadata rest ++ suffix = encodeMetadata metadata (rest ++ suffix) := by
  simp [encodeMetadata, encodeNat_append, encodeFixed_append]

def scopeTag : Option Evidence.Level → ℕ
  | none => 0
  | some .hard => 1
  | some .naturality => 2
  | some .final => 3

def scopeOfTag : ℕ → Option (Option Evidence.Level)
  | 0 => some none
  | 1 => some (some .hard)
  | 2 => some (some .naturality)
  | 3 => some (some .final)
  | _ => none

@[simp] theorem scopeOfTag_scopeTag (scope : Option Evidence.Level) :
    scopeOfTag (scopeTag scope) = some scope := by
  cases scope with
  | none => rfl
  | some level => cases level <;> rfl

def encodeScope (scope : Option Evidence.Level) (rest : Bytes) : Bytes :=
  encodeNat (scopeTag scope) rest

def parseScope (bytes : Bytes) : Option (Option Evidence.Level × Bytes) := do
  let (tag, rest) ← parseNat bytes
  let scope ← scopeOfTag tag
  some (scope, rest)

@[simp] theorem parseScope_encodeScope (scope : Option Evidence.Level) (rest : Bytes) :
    parseScope (encodeScope scope rest) = some (scope, rest) := by
  simp [parseScope, encodeScope]

theorem encodeScope_append (scope : Option Evidence.Level) (rest suffix : Bytes) :
    encodeScope scope rest ++ suffix = encodeScope scope (rest ++ suffix) :=
  encodeNat_append _ _ _

/-- ASCII `HODGE_CERTIFICATE_PROFILE_V1`. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 67, 69, 82, 84, 73, 70, 73, 67, 65, 84, 69, 95,
    80, 82, 79, 70, 73, 76, 69, 95, 86, 49]

def encodeBody (descriptor : Descriptor) (rest : Bytes) : Bytes :=
  encodeMetadata descriptor.metadata
    (frame descriptor.publicProfile
      (encodeFixed descriptor.parameterSet
        (encodeScope descriptor.scope
          (Codec.encodeCalibration descriptor.calibration
            (frame descriptor.program (frame descriptor.verifierKey
              (frame descriptor.publicCRS rest)))))))

def parseBody (bytes : Bytes) : Option (Descriptor × Bytes) := do
  let (metadata, rest) ← parseMetadata bytes
  let (publicProfile, rest) ← parseFrame rest
  let (parameterSet, rest) ← parseFixed 32 rest
  let (scope, rest) ← parseScope rest
  let (calibration, rest) ← Codec.parseCalibration rest
  let (program, rest) ← parseFrame rest
  let (verifierKey, rest) ← parseFrame rest
  let (publicCRS, rest) ← parseFrame rest
  some (⟨metadata, publicProfile, parameterSet, scope, calibration,
    program, verifierKey, publicCRS⟩, rest)

@[simp] theorem parseBody_encodeBody (descriptor : Descriptor) (rest : Bytes) :
    parseBody (encodeBody descriptor rest) = some (descriptor, rest) := by
  cases descriptor
  simp [parseBody, encodeBody, parseFrame_frame]

def encode (descriptor : Descriptor) : Bytes := domain ++ encodeBody descriptor []

def decode (bytes : Bytes) : Option Descriptor :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (descriptor, rest) =>
    if rest = [] ∧ bytes = encode descriptor then some descriptor else none

@[simp] theorem decode_encode (descriptor : Descriptor) :
    decode (encode descriptor) = some descriptor := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (descriptor : Descriptor) :
    decode bytes = some descriptor ↔ bytes = encode descriptor := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next same =>
        have descriptorEq : other = descriptor := Option.some.inj decoded
        subst other
        exact same.2
      next => contradiction
  · rintro rfl
    exact decode_encode descriptor

theorem encode_injective : Function.Injective encode := by
  intro first second same
  have decoded := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using decoded

theorem encode_eq_iff (first second : Descriptor) :
    encode first = encode second ↔ first = second :=
  ⟨fun same => encode_injective same, congrArg encode⟩

theorem encodeBody_append (descriptor : Descriptor) (rest suffix : Bytes) :
    encodeBody descriptor rest ++ suffix = encodeBody descriptor (rest ++ suffix) := by
  simp [encodeBody, encodeMetadata_append, frame_append, encodeFixed_append,
    encodeScope_append, Codec.encodeCalibration_append]

theorem decode_rejects_trailing (descriptor : Descriptor) (suffix : Bytes)
    (nonempty : suffix ≠ []) : decode (encode descriptor ++ suffix) = none := by
  have parsed : parseBody ((encode descriptor ++ suffix).drop domain.length) =
      some (descriptor, suffix) := by
    rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
    simp
  simp [decode, parsed, nonempty]

theorem decode_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take domain.length ≠ domain) : decode bytes = none := by
  cases parsed : decode bytes with
  | none => rfl
  | some descriptor =>
    have canonical := (decode_eq_some_iff bytes descriptor).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

/-- ASCII `HODGE_PROFILE_REGISTRATION_V1`. -/
def registrationDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 80, 82, 79, 70, 73, 76, 69, 95, 82, 69, 71,
    73, 83, 84, 82, 65, 84, 73, 79, 78, 95, 86, 49]

/-- The dedicated registration root contains the exact public descriptor bytes. -/
def rootPreimage (bytes : Bytes) : Bytes := registrationDomain ++ frame bytes []

theorem rootPreimage_injective : Function.Injective rootPreimage := by
  intro first second same
  have parsed := congrArg (fun bytes => parseFrame (bytes.drop registrationDomain.length)) same
  simpa [rootPreimage, parseFrame_frame] using parsed

def rootDigest (hash : Bytes → TCB.Hash32) (descriptor : Descriptor) : TCB.Hash32 :=
  hash (rootPreimage (encode descriptor))

/-- Parse exactly the approved descriptor bytes and check their dedicated root. -/
def check (hash : Bytes → TCB.Hash32) (root : TCB.Hash32) (bytes : Bytes) : Option Descriptor := do
  let descriptor ← decode bytes
  if hash (rootPreimage bytes) = root then some descriptor else none

theorem check_eq_some_iff (hash : Bytes → TCB.Hash32) (root : TCB.Hash32)
    (bytes : Bytes) (descriptor : Descriptor) :
    check hash root bytes = some descriptor ↔
      bytes = encode descriptor ∧ hash (rootPreimage bytes) = root := by
  cases parsed : decode bytes with
  | none => simp [check, parsed, ← decode_eq_some_iff]
  | some other =>
    have canonical := (decode_eq_some_iff bytes other).mp parsed
    have descriptorEq : bytes = encode descriptor ↔ other = descriptor := by
      constructor
      · intro same
        exact encode_injective (canonical.symm.trans same)
      · rintro rfl
        exact canonical
    by_cases checked : hash (rootPreimage bytes) = root <;>
      simp [check, parsed, checked, descriptorEq]

@[simp] theorem check_encode (hash : Bytes → TCB.Hash32) (descriptor : Descriptor) :
    check hash (rootDigest hash descriptor) (encode descriptor) = some descriptor :=
  (check_eq_some_iff hash _ _ descriptor).mpr ⟨rfl, rfl⟩

/-- A fetched approved profile is exact, or its registration preimage collides.
The collision concerns complete, unequal byte strings, not identifier names. -/
theorem check_original_or_collision (hash : Bytes → TCB.Hash32)
    (original returned : Descriptor) (bytes : Bytes)
    (accepted : check hash (rootDigest hash original) bytes = some returned) :
    returned = original ∨
      (rootPreimage bytes ≠ rootPreimage (encode original) ∧
        hash (rootPreimage bytes) = hash (rootPreimage (encode original))) := by
  obtain ⟨canonical, checked⟩ := (check_eq_some_iff hash _ bytes returned).mp accepted
  by_cases same : returned = original
  · exact Or.inl same
  · refine Or.inr ⟨?_, checked⟩
    intro samePreimage
    exact same (encode_injective (canonical.symm.trans (rootPreimage_injective samePreimage)))

/-- All existing metadata fields are compared by their finite values. -/
def metadataEqual (first second : ProofMetadata) : Bool :=
  decide (first.schemaVersion = second.schemaVersion ∧
    first.statementId = second.statementId ∧ first.policyId = second.policyId ∧
    first.proofSystemId = second.proofSystemId ∧ first.verifierId = second.verifierId)

theorem metadataEqual_eq_true_iff (first second : ProofMetadata) :
    metadataEqual first second = true ↔ first = second := by
  rw [metadataEqual, decide_eq_true_eq]
  exact (ProofMetadata.eq_iff first second).symm

def applies (descriptor : Descriptor) (metadata : ProofMetadata)
    (publicProfile : Bytes) (parameterSet : TCB.Hash32) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration) (actualEpoch approvedEpoch : ℕ) : Bool :=
  metadataEqual descriptor.metadata metadata &&
    decide (descriptor.publicProfile = publicProfile ∧ descriptor.parameterSet = parameterSet ∧
      descriptor.scope = scope ∧ descriptor.calibration = calibration ∧ actualEpoch = approvedEpoch)

theorem applies_eq_true_iff (descriptor : Descriptor) (metadata : ProofMetadata)
    (publicProfile : Bytes) (parameterSet : TCB.Hash32) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration) (actualEpoch approvedEpoch : ℕ) :
    applies descriptor metadata publicProfile parameterSet scope calibration actualEpoch approvedEpoch = true ↔
      descriptor.metadata = metadata ∧ descriptor.publicProfile = publicProfile ∧
        descriptor.parameterSet = parameterSet ∧ descriptor.scope = scope ∧
        descriptor.calibration = calibration ∧ actualEpoch = approvedEpoch := by
  simp only [applies, Bool.and_eq_true_iff, metadataEqual_eq_true_iff, decide_eq_true_eq]

theorem reject_wrong_metadata (descriptor : Descriptor) (metadata : ProofMetadata)
    (publicProfile : Bytes) (parameterSet : TCB.Hash32) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration) (actualEpoch approvedEpoch : ℕ)
    (wrong : descriptor.metadata ≠ metadata) :
    applies descriptor metadata publicProfile parameterSet scope calibration actualEpoch approvedEpoch = false := by
  cases outcome : applies descriptor metadata publicProfile parameterSet scope calibration actualEpoch approvedEpoch with
  | false => rfl
  | true =>
    exact False.elim (wrong ((applies_eq_true_iff _ _ _ _ _ _ _ _).1 outcome).1)

theorem reject_wrong_scope (descriptor : Descriptor) (metadata : ProofMetadata)
    (publicProfile : Bytes) (parameterSet : TCB.Hash32) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration) (actualEpoch approvedEpoch : ℕ)
    (wrong : descriptor.scope ≠ scope) :
    applies descriptor metadata publicProfile parameterSet scope calibration actualEpoch approvedEpoch = false := by
  cases outcome : applies descriptor metadata publicProfile parameterSet scope calibration actualEpoch approvedEpoch with
  | false => rfl
  | true =>
    obtain ⟨_, _, _, scopeEq, _, _⟩ := (applies_eq_true_iff _ _ _ _ _ _ _ _).1 outcome
    exact False.elim (wrong scopeEq)

theorem reject_wrong_epoch (descriptor : Descriptor) (metadata : ProofMetadata)
    (publicProfile : Bytes) (parameterSet : TCB.Hash32) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration) (actualEpoch approvedEpoch : ℕ)
    (wrong : actualEpoch ≠ approvedEpoch) :
    applies descriptor metadata publicProfile parameterSet scope calibration actualEpoch approvedEpoch = false := by
  cases outcome : applies descriptor metadata publicProfile parameterSet scope calibration actualEpoch approvedEpoch with
  | false => rfl
  | true =>
    obtain ⟨_, _, _, _, _, epochEq⟩ := (applies_eq_true_iff _ _ _ _ _ _ _ _).1 outcome
    exact False.elim (wrong epochEq)

/-- The exact canonical registration payload approved by the existing quorum.
It gives authenticated setup approval, not a mutable registry or finality. -/
structure Approval {Validator Signature : Type} [DecidableEq Validator]
    (committee : Consensus.Committee Validator)
    (authentication : Consensus.VoteAuthentication Validator Signature)
    (hash : Bytes → TCB.Hash32) where
  descriptor : Descriptor
  bytes : Bytes
  canonical : bytes = encode descriptor
  quorum : Consensus.QuorumCertificate committee authentication
  accepts : quorum.SupportsAcceptance
  rootBound : quorum.target.proposal.evidenceRoot = hash (rootPreimage bytes)

namespace Approval

variable {Validator Signature : Type} [DecidableEq Validator]
  {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Signature}
  {hash : Bytes → TCB.Hash32}

def ofQuorum (descriptor : Descriptor)
    (quorum : Consensus.QuorumCertificate committee authentication)
    (accepts : quorum.SupportsAcceptance)
    (rootBound : quorum.target.proposal.evidenceRoot = rootDigest hash descriptor) :
    Approval committee authentication hash where
  descriptor := descriptor
  bytes := encode descriptor
  canonical := rfl
  quorum := quorum
  accepts := accepts
  rootBound := rootBound

theorem canonical_root (approval : Approval committee authentication hash) :
    approval.quorum.target.proposal.evidenceRoot = rootDigest hash approval.descriptor := by
  rw [approval.rootBound, approval.canonical]
  rfl

theorem committee_epoch (approval : Approval committee authentication hash) :
    approval.quorum.target.proposal.epoch = committee.epoch := approval.quorum.committeeBound.2

theorem checked_descriptor_or_collision (approval : Approval committee authentication hash)
    (bytes : Bytes) (returned : Descriptor)
    (accepted : check hash approval.quorum.target.proposal.evidenceRoot bytes = some returned) :
    returned = approval.descriptor ∨
      (rootPreimage bytes ≠ rootPreimage (encode approval.descriptor) ∧
        hash (rootPreimage bytes) = hash (rootPreimage (encode approval.descriptor))) := by
  rw [approval.canonical_root] at accepted
  exact check_original_or_collision hash approval.descriptor returned bytes accepted

variable {Vertex Edge Face Owner Asset Receipt : Type}
  [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

def appliesConfig (approval : Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration) : Bool :=
  applies approval.descriptor base.metadata publicProfile base.context.key.parameterSet
    scope calibration base.before.epoch committee.epoch

theorem appliesConfig_epoch (approval : Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration)
    (applicable : approval.appliesConfig base publicProfile scope calibration = true) :
    base.before.epoch = approval.quorum.target.proposal.epoch := by
  obtain ⟨_, _, _, _, _, epochEq⟩ := (applies_eq_true_iff _ _ _ _ _ _ _ _).1 applicable
  exact epochEq.trans approval.committee_epoch.symm

end Approval

section Selection

variable {Program VerifierKey CRS : Type}

/-- Select the actual public implementation objects by parsing approved bytes. -/
def select (parseProgram : Bytes → Option Program) (parseKey : Bytes → Option VerifierKey)
    (parseCRS : Bytes → Option CRS) (descriptor : Descriptor) :
    Option (Program × VerifierKey × CRS) := do
  let program ← parseProgram descriptor.program
  let key ← parseKey descriptor.verifierKey
  let crs ← parseCRS descriptor.publicCRS
  some (program, key, crs)

theorem select_of_decodes (parseProgram : Bytes → Option Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option CRS)
    (descriptor : Descriptor) (program : Program) (key : VerifierKey) (crs : CRS)
    (programDecoded : parseProgram descriptor.program = some program)
    (keyDecoded : parseKey descriptor.verifierKey = some key)
    (crsDecoded : parseCRS descriptor.publicCRS = some crs) :
    select parseProgram parseKey parseCRS descriptor = some (program, key, crs) := by
  simp [select, programDecoded, keyDecoded, crsDecoded]

theorem select_eq_some_iff (parseProgram : Bytes → Option Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option CRS)
    (descriptor : Descriptor) (program : Program) (key : VerifierKey) (crs : CRS) :
    select parseProgram parseKey parseCRS descriptor = some (program, key, crs) ↔
      parseProgram descriptor.program = some program ∧
        parseKey descriptor.verifierKey = some key ∧ parseCRS descriptor.publicCRS = some crs := by
  cases programDecoded : parseProgram descriptor.program with
  | none => simp [select, programDecoded]
  | some actualProgram =>
    cases keyDecoded : parseKey descriptor.verifierKey with
    | none => simp [select, programDecoded, keyDecoded]
    | some actualKey =>
      cases crsDecoded : parseCRS descriptor.publicCRS with
      | none => simp [select, programDecoded, keyDecoded, crsDecoded]
      | some actualCRS =>
        simp [select, programDecoded, keyDecoded, crsDecoded]

/-- Execution uses the actual parsed program, key and CRS rather than names. -/
def execute (parseProgram : Bytes → Option Program) (parseKey : Bytes → Option VerifierKey)
    (parseCRS : Bytes → Option CRS)
    (run : Program → VerifierKey → CRS → Bytes → Bytes → Bool)
    (descriptor : Descriptor) (input proof : Bytes) : Bool :=
  match select parseProgram parseKey parseCRS descriptor with
  | none => false
  | some (program, key, crs) => run program key crs input proof

theorem execute_of_selected (parseProgram : Bytes → Option Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option CRS)
    (run : Program → VerifierKey → CRS → Bytes → Bytes → Bool)
    (descriptor : Descriptor) (program : Program) (key : VerifierKey) (crs : CRS)
    (selected : select parseProgram parseKey parseCRS descriptor = some (program, key, crs))
    (input proof : Bytes) :
    execute parseProgram parseKey parseCRS run descriptor input proof = run program key crs input proof := by
  simp [execute, selected]

theorem execute_rejects_unparsed (parseProgram : Bytes → Option Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option CRS)
    (run : Program → VerifierKey → CRS → Bytes → Bytes → Bool)
    (descriptor : Descriptor) (unparsed : select parseProgram parseKey parseCRS descriptor = none)
    (input proof : Bytes) :
    execute parseProgram parseKey parseCRS run descriptor input proof = false := by
  simp [execute, unparsed]

end Selection

namespace Approval

variable {Validator Signature Vertex Edge Face Owner Asset Receipt Program VerifierKey CRS : Type}
  [DecidableEq Validator] [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Signature}
  {hash : Bytes → TCB.Hash32}
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- The actual applicability guard runs before the approved parsed execution.
This operation retains the existing quorum and original raw configuration. -/
def verifyConfig (approval : Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration)
    (parseProgram : Bytes → Option Program) (parseKey : Bytes → Option VerifierKey)
    (parseCRS : Bytes → Option CRS)
    (run : Program → VerifierKey → CRS → Bytes → Bytes → Bool)
    (input proof : Bytes) : Bool :=
  approval.appliesConfig base publicProfile scope calibration &&
    Profile.execute parseProgram parseKey parseCRS run approval.descriptor input proof

theorem verifyConfig_rejects_inapplicable (approval : Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration)
    (parseProgram : Bytes → Option Program) (parseKey : Bytes → Option VerifierKey)
    (parseCRS : Bytes → Option CRS)
    (run : Program → VerifierKey → CRS → Bytes → Bytes → Bool)
    (inapplicable : approval.appliesConfig base publicProfile scope calibration = false)
    (input proof : Bytes) :
    approval.verifyConfig base publicProfile scope calibration parseProgram parseKey parseCRS run input proof = false := by
  simp only [verifyConfig, inapplicable, Bool.false_and]

theorem verifyConfig_of_selected (approval : Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt)
    (publicProfile : Bytes) (scope : Option Evidence.Level)
    (calibration : Option Codec.Calibration)
    (parseProgram : Bytes → Option Program) (parseKey : Bytes → Option VerifierKey)
    (parseCRS : Bytes → Option CRS)
    (run : Program → VerifierKey → CRS → Bytes → Bytes → Bool)
    (applicable : approval.appliesConfig base publicProfile scope calibration = true)
    (program : Program) (key : VerifierKey) (crs : CRS)
    (selected : select parseProgram parseKey parseCRS approval.descriptor = some (program, key, crs))
    (input proof : Bytes) :
    approval.verifyConfig base publicProfile scope calibration parseProgram parseKey parseCRS run input proof =
      run program key crs input proof := by
  simp only [verifyConfig, applicable, Bool.true_and]
  exact execute_of_selected parseProgram parseKey parseCRS run approval.descriptor
    program key crs selected input proof

end Approval
end HomotopicalEncryption.Protocol.Transfer.Certificates.Profile
