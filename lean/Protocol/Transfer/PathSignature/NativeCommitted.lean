module

public import Protocol.Storage.OperatorCommitment
public import Protocol.Transfer.PathSignature.NativeProgram

@[expose] public section

/-!
# Versioned native witnesses with private operator-commitment openings

The existing bounded native witness retains its two presentations, integer
message and Hodge openings, and source-credential salt. A separate fixed-size
private nonce opens the target operator commitment. The public instance still
contains exactly the existing credential, snapshot and ciphertext names.

V2 witness, program and instance domains select this concrete checker without
reinterpreting V1 raw-operator-hash formats. Original matrix, native witness,
instance-body and program-body codecs are reused. The full key/message input
uses the existing path-signature framing; its geometric predicate remains
message-independent and requires a separate tagged proof construction.

The native geometry, lattice and byte recovery are unchanged. Operator binding
is expressed by equality or an actual collision of complete commitment
preimages. No hiding, hash security, proof-system security or nonce-sampling
claim is assumed or proved here.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommitted

open Storage.CoupledCodec
open Ephemeral.ScopeCodec (encodeFixed parseFixed parseFixed_encodeFixed)

abbrev Instance := NativeRelation.Instance
abbrev Program := NativeProgram.Program

/-- Only the private operator opening is added to the original native witness. -/
structure Witness (rows cols : ℕ) where
  native : NativeRelation.Witness rows cols
  operatorNonce : Storage.OperatorCommitment.Nonce

variable {rows cols : ℕ}

/-- ASCII `HODGE_NATIVE_WITNESS_V2`. -/
def witnessDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 78, 65, 84, 73, 86, 69, 95,
    87, 73, 84, 78, 69, 83, 83, 95, 86, 50]

def encodeWitnessBody (witness : Witness rows cols) (rest : Bytes) : Bytes :=
  frame (NativeRelation.encode witness.native) (encodeFixed witness.operatorNonce rest)

def parseWitnessBody (rows cols : ℕ) (bytes : Bytes) :
    Option (Witness rows cols × Bytes) := do
  let (nativeBytes, rest) ← parseFrame bytes
  let native ← NativeRelation.decode rows cols nativeBytes
  let (operatorNonce, rest) ← parseFixed 32 rest
  some (⟨native, operatorNonce⟩, rest)

@[simp] theorem parseWitnessBody_encodeWitnessBody (witness : Witness rows cols) (rest : Bytes) :
    parseWitnessBody rows cols (encodeWitnessBody witness rest) = some (witness, rest) := by
  cases witness
  simp [parseWitnessBody, encodeWitnessBody, parseFrame_frame]

def encodeWitness (witness : Witness rows cols) : Bytes :=
  witnessDomain ++ encodeWitnessBody witness []

def decodeWitness (rows cols : ℕ) (bytes : Bytes) : Option (Witness rows cols) :=
  match parseWitnessBody rows cols (bytes.drop witnessDomain.length) with
  | none => none
  | some (witness, rest) =>
    if rest = [] ∧ bytes = encodeWitness witness then some witness else none

@[simp] theorem decodeWitness_encodeWitness (witness : Witness rows cols) :
    decodeWitness rows cols (encodeWitness witness) = some witness := by
  simp [decodeWitness, encodeWitness]

theorem decodeWitness_eq_some_iff (bytes : Bytes) (witness : Witness rows cols) :
    decodeWitness rows cols bytes = some witness ↔ bytes = encodeWitness witness := by
  constructor
  · intro decoded
    unfold decodeWitness at decoded
    cases parsed : parseWitnessBody rows cols (bytes.drop witnessDomain.length) with
    | none => simp [parsed] at decoded
    | some pair =>
      rcases pair with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        exact canonical.2.trans (congrArg encodeWitness (Option.some.inj decoded))
      next => contradiction
  · rintro rfl
    exact decodeWitness_encodeWitness witness

theorem encodeWitness_injective : Function.Injective (@encodeWitness rows cols) := by
  intro first second same
  have parsed := congrArg (decodeWitness rows cols) same
  simpa only [decodeWitness_encodeWitness, Option.some.injEq] using parsed

theorem decodeWitness_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take witnessDomain.length ≠ witnessDomain) :
    decodeWitness rows cols bytes = none := by
  cases parsed : decodeWitness rows cols bytes with
  | none => rfl
  | some witness =>
    have canonical := (decodeWitness_eq_some_iff bytes witness).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encodeWitness, List.take_left]

/-- ASCII `HODGE_NATIVE_PROGRAM_V2`; its body reuses the exact V1 parameters. -/
def programDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 78, 65, 84, 73, 86, 69, 95,
    80, 82, 79, 71, 82, 65, 77, 95, 86, 50]

def encodeProgram (program : Program) : Bytes :=
  programDomain ++ NativeProgram.encodeProgramBody program []

def decodeProgram (bytes : Bytes) : Option Program :=
  match NativeProgram.parseProgramBody (bytes.drop programDomain.length) with
  | none => none
  | some (program, rest) =>
    if rest = [] ∧ bytes = encodeProgram program then some program else none

@[simp] theorem decodeProgram_encodeProgram (program : Program) :
    decodeProgram (encodeProgram program) = some program := by
  simp [decodeProgram, encodeProgram]

theorem decodeProgram_eq_some_iff (bytes : Bytes) (program : Program) :
    decodeProgram bytes = some program ↔ bytes = encodeProgram program := by
  constructor
  · intro decoded
    unfold decodeProgram at decoded
    cases parsed : NativeProgram.parseProgramBody (bytes.drop programDomain.length) with
    | none => simp [parsed] at decoded
    | some pair =>
      rcases pair with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        exact canonical.2.trans (congrArg encodeProgram (Option.some.inj decoded))
      next => contradiction
  · rintro rfl
    exact decodeProgram_encodeProgram program

theorem encodeProgram_injective : Function.Injective encodeProgram := by
  intro first second same
  have parsed := congrArg decodeProgram same
  simpa only [decodeProgram_encodeProgram, Option.some.injEq] using parsed

theorem decodeProgram_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take programDomain.length ≠ programDomain) : decodeProgram bytes = none := by
  cases parsed : decodeProgram bytes with
  | none => rfl
  | some program =>
    have canonical := (decodeProgram_eq_some_iff bytes program).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encodeProgram, List.take_left]

/-- ASCII `HODGE_NATIVE_INSTANCE_V2`; no private opening is serialized here. -/
def instanceDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 78, 65, 84, 73, 86, 69, 95,
    73, 78, 83, 84, 65, 78, 67, 69, 95, 86, 50]

def encodeInstance (publicInput : Instance) : Bytes :=
  instanceDomain ++ NativeProgram.encodeInstanceBody publicInput []

def decodeInstance (bytes : Bytes) : Option Instance :=
  match NativeProgram.parseInstanceBody (bytes.drop instanceDomain.length) with
  | none => none
  | some (publicInput, rest) =>
    if rest = [] ∧ bytes = encodeInstance publicInput then some publicInput else none

@[simp] theorem decodeInstance_encodeInstance (publicInput : Instance) :
    decodeInstance (encodeInstance publicInput) = some publicInput := by
  simp [decodeInstance, encodeInstance]

theorem decodeInstance_eq_some_iff (bytes : Bytes) (publicInput : Instance) :
    decodeInstance bytes = some publicInput ↔ bytes = encodeInstance publicInput := by
  constructor
  · intro decoded
    unfold decodeInstance at decoded
    cases parsed : NativeProgram.parseInstanceBody (bytes.drop instanceDomain.length) with
    | none => simp [parsed] at decoded
    | some pair =>
      rcases pair with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        exact canonical.2.trans (congrArg encodeInstance (Option.some.inj decoded))
      next => contradiction
  · rintro rfl
    exact decodeInstance_encodeInstance publicInput

theorem encodeInstance_injective : Function.Injective encodeInstance := by
  intro first second same
  have parsed := congrArg decodeInstance same
  simpa only [decodeInstance_encodeInstance, Option.some.injEq] using parsed

theorem decodeInstance_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take instanceDomain.length ≠ instanceDomain) : decodeInstance bytes = none := by
  cases parsed : decodeInstance bytes with
  | none => rfl
  | some publicInput =>
    have canonical := (decodeInstance_eq_some_iff bytes publicInput).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encodeInstance, List.take_left]

theorem decodeWitness_rejects_v1 (witness : NativeRelation.Witness rows cols) :
    decodeWitness rows cols (NativeRelation.encode witness) = none := by
  apply decodeWitness_rejects_wrong_domain
  change (NativeRelation.domain ++ _).take witnessDomain.length ≠ witnessDomain
  have sameLength : witnessDomain.length = NativeRelation.domain.length := by decide
  rw [sameLength, List.take_left]
  decide

theorem decodeProgram_rejects_v1 (program : Program) :
    decodeProgram (NativeProgram.encodeProgram program) = none := by
  apply decodeProgram_rejects_wrong_domain
  change (NativeProgram.programDomain ++ _).take programDomain.length ≠ programDomain
  have sameLength : programDomain.length = NativeProgram.programDomain.length := by decide
  rw [sameLength, List.take_left]
  decide

theorem decodeInstance_rejects_v1 (publicInput : Instance) :
    decodeInstance (NativeProgram.encodeInstance publicInput) = none := by
  apply decodeInstance_rejects_wrong_domain
  change (NativeProgram.instanceDomain ++ _).take instanceDomain.length ≠ instanceDomain
  have sameLength : instanceDomain.length = NativeProgram.instanceDomain.length := by decide
  rw [sameLength, List.take_left]
  decide

/-- Source credential and ciphertext names are unchanged; only the target
snapshot uses the separate nonce-bearing operator commitment. -/
def instanceFor (hash : Bytes → TCB.Hash32) (witness : Witness rows cols) : Instance where
  credential := hash (NativeRelation.credentialBytes witness.native)
  targetSnapshot := Storage.OperatorCommitment.commit hash (ofMatrix witness.native.target)
    witness.operatorNonce
  ciphertextDigest := hash (Storage.CoupledCiphertext.sampleBytes witness.native.target
    witness.native.z witness.native.a witness.native.u)

def Relation (profile : NativeRelation.Profile) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (witness : Witness rows cols) : Prop :=
  NativeRelation.Bounded profile witness.native ∧ instanceFor hash witness = publicInput

/-- The original bounds and actual three public names are checked, without
running the V1 raw-target-hash relation. -/
def check (rows cols : ℕ) (profile : NativeRelation.Profile) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (witnessBytes : Bytes) : Bool :=
  match decodeWitness rows cols witnessBytes with
  | none => false
  | some witness =>
    decide (NativeRelation.Bounded profile witness.native) &&
      decide (instanceFor hash witness = publicInput)

theorem check_eq_true_iff (profile : NativeRelation.Profile) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (witnessBytes : Bytes) :
    check rows cols profile hash publicInput witnessBytes = true ↔
      ∃ witness : Witness rows cols, decodeWitness rows cols witnessBytes = some witness ∧
        Relation profile hash publicInput witness := by
  cases parsed : decodeWitness rows cols witnessBytes with
  | none => simp [check, parsed]
  | some witness => simp [check, parsed, Relation]

theorem check_encode (profile : NativeRelation.Profile) (hash : Bytes → TCB.Hash32)
    (witness : Witness rows cols) (bounded : NativeRelation.Bounded profile witness.native) :
    check rows cols profile hash (instanceFor hash witness) (encodeWitness witness) = true := by
  simp [check, bounded]

def keyForInstance (credential targetSnapshot ciphertextDigest : TCB.Hash32) : Bytes :=
  encodeInstance ⟨credential, targetSnapshot, ciphertextDigest⟩

/-- Canonical full key/message input selects the actual V2 native checker. -/
def relation (program : Program) (hash : Bytes → TCB.Hash32)
    (input witnessBytes : Bytes) : Bool :=
  match Codec.decode input with
  | none => false
  | some (key, _message) =>
    match decodeInstance key with
    | none => false
    | some publicInput => check program.rows program.cols program.profile hash publicInput witnessBytes

theorem relation_canonical (program : Program) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (message witnessBytes : Bytes) :
    relation program hash (Codec.encode (encodeInstance publicInput) message) witnessBytes =
      check program.rows program.cols program.profile hash publicInput witnessBytes := by
  simp [relation]

/-- Honest bounded private bytes satisfy the V2 checker for every full message. -/
theorem relation_encode (program : Program) (hash : Bytes → TCB.Hash32)
    (witness : Witness program.rows program.cols)
    (bounded : NativeRelation.Bounded program.profile witness.native) (message : Bytes) :
    relation program hash (Codec.encode (encodeInstance (instanceFor hash witness)) message)
      (encodeWitness witness) = true := by
  rw [relation_canonical]
  exact check_encode program.profile hash witness bounded

theorem relation_eq_true_iff_canonical (program : Program) (hash : Bytes → TCB.Hash32)
    (input witnessBytes : Bytes) :
    relation program hash input witnessBytes = true ↔
      ∃ (publicInput : Instance) (message : Bytes) (witness : Witness program.rows program.cols),
        input = Codec.encode (encodeInstance publicInput) message ∧
        witnessBytes = encodeWitness witness ∧ Relation program.profile hash publicInput witness := by
  constructor
  · intro accepted
    cases parsed : Codec.decode input with
    | none => simp [relation, parsed] at accepted
    | some pair =>
      rcases pair with ⟨key, message⟩
      cases keyParsed : decodeInstance key with
      | none => simp [relation, parsed, keyParsed] at accepted
      | some publicInput =>
        have checked : check program.rows program.cols program.profile hash publicInput witnessBytes = true := by
          simpa [relation, parsed, keyParsed] using accepted
        obtain ⟨witness, decoded, valid⟩ := (check_eq_true_iff _ _ _ _).mp checked
        refine ⟨publicInput, message, witness, ?_, ?_, valid⟩
        · exact ((Codec.decode_eq_some_iff input key message).mp parsed).trans
            (congrArg (fun key => Codec.encode key message)
              ((decodeInstance_eq_some_iff key publicInput).mp keyParsed))
        · exact (decodeWitness_eq_some_iff witnessBytes witness).mp decoded
  · rintro ⟨publicInput, message, witness, rfl, rfl, bounded, names⟩
    rw [relation_canonical]
    simpa only [names] using check_encode program.profile hash witness bounded

def run (hash : Bytes → TCB.Hash32) (programBytes input witnessBytes : Bytes) : Bool :=
  match decodeProgram programBytes with
  | none => false
  | some program => relation program hash input witnessBytes

@[simp] theorem run_encodeProgram (hash : Bytes → TCB.Hash32) (program : Program)
    (input witnessBytes : Bytes) :
    run hash (encodeProgram program) input witnessBytes = relation program hash input witnessBytes := by
  simp [run]

theorem relation_rejects_v1_instance (program : Program) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (message witnessBytes : Bytes) :
    relation program hash (Codec.encode (NativeProgram.encodeInstance publicInput) message)
      witnessBytes = false := by
  simp [relation, decodeInstance_rejects_v1]

theorem run_rejects_v1_program (hash : Bytes → TCB.Hash32) (program : Program)
    (input witnessBytes : Bytes) :
    run hash (NativeProgram.encodeProgram program) input witnessBytes = false := by
  simp [run, decodeProgram_rejects_v1]

/-- The same original ciphertext and geometry retain their direct byte recovery. -/
theorem target_byte_recovery (witness : Witness rows cols) :
    Storage.CoupledRecovery.recover witness.native.target
      (Storage.CoupledCiphertext.sampleBytes witness.native.target witness.native.z
        witness.native.a witness.native.u) = some witness.native.z :=
  NativeRelation.target_byte_recovery witness.native

/-- A valid target names the operative matrix or distinct complete operator
commitment preimages with equal hashes, allowing the two nonces to differ. -/
theorem target_eq_or_operator_collision
    (profile : NativeRelation.Profile) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (witness : Witness rows cols)
    (valid : Relation profile hash publicInput witness)
    (operative : Matrix (Fin rows) (Fin cols) ℤ)
    (originalNonce : Storage.OperatorCommitment.Nonce)
    (snapshot : publicInput.targetSnapshot =
      Storage.OperatorCommitment.commit hash (ofMatrix operative) originalNonce) :
    witness.native.target = operative ∨
      (Storage.OperatorCommitment.encode (ofMatrix witness.native.target, witness.operatorNonce) ≠
          Storage.OperatorCommitment.encode (ofMatrix operative, originalNonce) ∧
        hash (Storage.OperatorCommitment.encode (ofMatrix witness.native.target, witness.operatorNonce)) =
          hash (Storage.OperatorCommitment.encode (ofMatrix operative, originalNonce))) := by
  have same : Storage.OperatorCommitment.commit hash (ofMatrix witness.native.target)
      witness.operatorNonce = Storage.OperatorCommitment.commit hash (ofMatrix operative) originalNonce :=
    (congrArg NativeRelation.Instance.targetSnapshot valid.2).trans snapshot
  exact Storage.OperatorCommitment.matrix_eq_or_collision hash witness.native.target operative
    witness.operatorNonce originalNonce same

/-- A valid extracted native witness recovers the original coefficients or
exhibits an actual operator-preimage or ciphertext-byte hash collision. -/
theorem extracted_target_or_collisions
    (profile : NativeRelation.Profile) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (witness : Witness rows cols)
    (valid : Relation profile hash publicInput witness)
    (operative : Matrix (Fin rows) (Fin cols) ℤ)
    (originalNonce : Storage.OperatorCommitment.Nonce)
    (originalZ : Fin cols → ℤ) (originalA : ℤ) (originalU : Fin rows → ℤ)
    (snapshot : publicInput.targetSnapshot =
      Storage.OperatorCommitment.commit hash (ofMatrix operative) originalNonce)
    (ciphertext : publicInput.ciphertextDigest =
      hash (Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU)) :
    witness.native.z = originalZ ∨
      (Storage.OperatorCommitment.encode (ofMatrix witness.native.target, witness.operatorNonce) ≠
          Storage.OperatorCommitment.encode (ofMatrix operative, originalNonce) ∧
        hash (Storage.OperatorCommitment.encode (ofMatrix witness.native.target, witness.operatorNonce)) =
          hash (Storage.OperatorCommitment.encode (ofMatrix operative, originalNonce))) ∨
      (Storage.CoupledCiphertext.sampleBytes witness.native.target witness.native.z witness.native.a
          witness.native.u ≠ Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU ∧
        hash (Storage.CoupledCiphertext.sampleBytes witness.native.target witness.native.z
          witness.native.a witness.native.u) =
          hash (Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU)) := by
  have namedCiphertext :
      hash (Storage.CoupledCiphertext.sampleBytes witness.native.target witness.native.z
        witness.native.a witness.native.u) =
        hash (Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU) :=
    (congrArg NativeRelation.Instance.ciphertextDigest valid.2).trans ciphertext
  rcases target_eq_or_operator_collision profile hash publicInput witness valid operative originalNonce
      snapshot with sameTarget | operatorCollision
  · by_cases sameBytes :
        Storage.CoupledCiphertext.sampleBytes witness.native.target witness.native.z witness.native.a
          witness.native.u = Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU
    · apply Or.inl
      rw [sameTarget] at sameBytes
      exact Storage.CoupledCiphertext.Disclosure.message_eq_of_sampleBytes_eq
        operative witness.native.z originalZ witness.native.a originalA witness.native.u originalU sameBytes
    · exact Or.inr (Or.inr ⟨sameBytes, namedCiphertext⟩)
  · exact Or.inr (Or.inl operatorCollision)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommitted
