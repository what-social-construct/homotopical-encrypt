module

public import Protocol.Transfer.PathSignature.NativeRelation
public import Protocol.Transfer.PathSignature.Codec
public import Protocol.Ephemeral.ScopeCodec

@[expose] public section

/-!
# Canonical programs and public keys for the bounded native relation

Program bytes select the actual implemented dimensioned native checker,
including its magnitude and credential-salt bounds. Public key bytes retain
the three existing instance names: credential, target snapshot and ciphertext.
No private presentation or opening is placed in this public format.

The complete key/message input uses the existing path-signature codec. The
native geometric predicate does not depend on the message; therefore an
ordinary proof of its satisfiability need not be message-bound. The tagged CRS
proof construction must enforce fresh-message knowledge separately. This leaf
provides concrete canonical relation/program bytes, not an R1CS compiler,
cryptographic prover, credential one-wayness or individual-owner inference
from a shared homotopy class.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeProgram

open Storage.CoupledCodec
open Ephemeral.ScopeCodec (encodeFixed parseFixed parseFixed_encodeFixed encodeFixed_append)

/-- Exactly the finite native checker parameters selected by the program. -/
structure Program where
  rows : ℕ
  cols : ℕ
  profile : NativeRelation.Profile
  deriving DecidableEq

/-- ASCII `HODGE_NATIVE_PROGRAM_V1`. -/
def programDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 78, 65, 84, 73, 86, 69, 95,
    80, 82, 79, 71, 82, 65, 77, 95, 86, 49]

def encodeProgramBody (program : Program) (rest : Bytes) : Bytes :=
  encodeNat program.rows (encodeNat program.cols
    (encodeNat program.profile.bound (encodeNat program.profile.saltBytes rest)))

def parseProgramBody (bytes : Bytes) : Option (Program × Bytes) := do
  let (rows, rest) ← parseNat bytes
  let (cols, rest) ← parseNat rest
  let (bound, rest) ← parseNat rest
  let (saltBytes, rest) ← parseNat rest
  some (⟨rows, cols, ⟨bound, saltBytes⟩⟩, rest)

@[simp] theorem parseProgramBody_encodeProgramBody (program : Program) (rest : Bytes) :
    parseProgramBody (encodeProgramBody program rest) = some (program, rest) := by
  rcases program with ⟨rows, cols, ⟨bound, saltBytes⟩⟩
  simp [parseProgramBody, encodeProgramBody]

def encodeProgram (program : Program) : Bytes := programDomain ++ encodeProgramBody program []

def decodeProgram (bytes : Bytes) : Option Program :=
  match parseProgramBody (bytes.drop programDomain.length) with
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
    cases parsed : parseProgramBody (bytes.drop programDomain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        have same : other = program := Option.some.inj decoded
        exact canonical.2.trans (congrArg encodeProgram same)
      next => contradiction
  · rintro rfl
    exact decodeProgram_encodeProgram program

theorem encodeProgram_injective : Function.Injective encodeProgram := by
  intro first second same
  have parsed := congrArg decodeProgram same
  simpa only [decodeProgram_encodeProgram, Option.some.injEq] using parsed

theorem encodeProgramBody_append (program : Program) (rest suffix : Bytes) :
    encodeProgramBody program rest ++ suffix = encodeProgramBody program (rest ++ suffix) := by
  simp [encodeProgramBody, encodeNat_append]

theorem decodeProgram_rejects_trailing (program : Program) (suffix : Bytes)
    (nonempty : suffix ≠ []) : decodeProgram (encodeProgram program ++ suffix) = none := by
  have parsed : parseProgramBody ((encodeProgram program ++ suffix).drop programDomain.length) =
      some (program, suffix) := by
    rw [encodeProgram, List.append_assoc, List.drop_left, encodeProgramBody_append]
    simp
  simp [decodeProgram, parsed, nonempty]

theorem decodeProgram_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take programDomain.length ≠ programDomain) : decodeProgram bytes = none := by
  cases parsed : decodeProgram bytes with
  | none => rfl
  | some program =>
    have canonical := (decodeProgram_eq_some_iff bytes program).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encodeProgram, List.take_left]

/-- ASCII `HODGE_NATIVE_INSTANCE_V1`. This public domain is distinct from
the private witness, salted credential and program encodings. -/
def instanceDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 78, 65, 84, 73, 86, 69, 95,
    73, 78, 83, 84, 65, 78, 67, 69, 95, 86, 49]

def encodeInstanceBody (publicInput : NativeRelation.Instance) (rest : Bytes) : Bytes :=
  encodeFixed publicInput.credential
    (encodeFixed publicInput.targetSnapshot (encodeFixed publicInput.ciphertextDigest rest))

def parseInstanceBody (bytes : Bytes) : Option (NativeRelation.Instance × Bytes) := do
  let (credential, rest) ← parseFixed 32 bytes
  let (targetSnapshot, rest) ← parseFixed 32 rest
  let (ciphertextDigest, rest) ← parseFixed 32 rest
  some (⟨credential, targetSnapshot, ciphertextDigest⟩, rest)

@[simp] theorem parseInstanceBody_encodeInstanceBody
    (publicInput : NativeRelation.Instance) (rest : Bytes) :
    parseInstanceBody (encodeInstanceBody publicInput rest) = some (publicInput, rest) := by
  cases publicInput
  simp [parseInstanceBody, encodeInstanceBody]

def encodeInstance (publicInput : NativeRelation.Instance) : Bytes :=
  instanceDomain ++ encodeInstanceBody publicInput []

def decodeInstance (bytes : Bytes) : Option NativeRelation.Instance :=
  match parseInstanceBody (bytes.drop instanceDomain.length) with
  | none => none
  | some (publicInput, rest) =>
    if rest = [] ∧ bytes = encodeInstance publicInput then some publicInput else none

@[simp] theorem decodeInstance_encodeInstance (publicInput : NativeRelation.Instance) :
    decodeInstance (encodeInstance publicInput) = some publicInput := by
  simp [decodeInstance, encodeInstance]

theorem decodeInstance_eq_some_iff (bytes : Bytes) (publicInput : NativeRelation.Instance) :
    decodeInstance bytes = some publicInput ↔ bytes = encodeInstance publicInput := by
  constructor
  · intro decoded
    unfold decodeInstance at decoded
    cases parsed : parseInstanceBody (bytes.drop instanceDomain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        have same : other = publicInput := Option.some.inj decoded
        exact canonical.2.trans (congrArg encodeInstance same)
      next => contradiction
  · rintro rfl
    exact decodeInstance_encodeInstance publicInput

theorem encodeInstance_injective : Function.Injective encodeInstance := by
  intro first second same
  have parsed := congrArg decodeInstance same
  simpa only [decodeInstance_encodeInstance, Option.some.injEq] using parsed

theorem encodeInstanceBody_append (publicInput : NativeRelation.Instance) (rest suffix : Bytes) :
    encodeInstanceBody publicInput rest ++ suffix = encodeInstanceBody publicInput (rest ++ suffix) := by
  simp [encodeInstanceBody, encodeFixed_append]

theorem decodeInstance_rejects_trailing (publicInput : NativeRelation.Instance) (suffix : Bytes)
    (nonempty : suffix ≠ []) : decodeInstance (encodeInstance publicInput ++ suffix) = none := by
  have parsed : parseInstanceBody ((encodeInstance publicInput ++ suffix).drop instanceDomain.length) =
      some (publicInput, suffix) := by
    rw [encodeInstance, List.append_assoc, List.drop_left, encodeInstanceBody_append]
    simp
  simp [decodeInstance, parsed, nonempty]

theorem decodeInstance_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take instanceDomain.length ≠ instanceDomain) : decodeInstance bytes = none := by
  cases parsed : decodeInstance bytes with
  | none => rfl
  | some publicInput =>
    have canonical := (decodeInstance_eq_some_iff bytes publicInput).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encodeInstance, List.take_left]

/-- The context-bound public key contains only the three existing public names. -/
def keyForInstance (credential targetSnapshot ciphertextDigest : TCB.Hash32) : Bytes :=
  encodeInstance ⟨credential, targetSnapshot, ciphertextDigest⟩

/-- This is the actual implemented Boolean relation selected by canonical
program bytes. The complete message is parsed and retained in the public
input; geometric satisfiability itself remains message-independent. -/
def relation (program : Program) (hash : Bytes → TCB.Hash32)
    (input witness : Bytes) : Bool :=
  match Codec.decode input with
  | none => false
  | some (key, _message) =>
    match decodeInstance key with
    | none => false
    | some publicInput =>
      NativeRelation.check program.rows program.cols program.profile hash publicInput witness

theorem relation_eq_true_iff (program : Program) (hash : Bytes → TCB.Hash32)
    (input witnessBytes : Bytes) :
    relation program hash input witnessBytes = true ↔
      ∃ (key message : Bytes) (publicInput : NativeRelation.Instance)
        (witness : NativeRelation.Witness program.rows program.cols),
        Codec.decode input = some (key, message) ∧
        decodeInstance key = some publicInput ∧
        NativeRelation.decode program.rows program.cols witnessBytes = some witness ∧
        NativeRelation.Relation program.profile hash publicInput witness := by
  cases parsed : Codec.decode input with
  | none => simp [relation, parsed]
  | some pair =>
    rcases pair with ⟨key, message⟩
    cases instanceParsed : decodeInstance key with
    | none => simp [relation, parsed, instanceParsed]
    | some publicInput =>
      simp [relation, parsed, instanceParsed, NativeRelation.check_eq_true_iff,
        NativeRelation.Relation]
      constructor
      · rintro ⟨witness, decoded, bounded, names⟩
        exact ⟨witness, names.symm, decoded, bounded⟩
      · rintro ⟨witness, names, decoded, bounded⟩
        exact ⟨witness, decoded, bounded, names.symm⟩

theorem relation_canonical (program : Program) (hash : Bytes → TCB.Hash32)
    (publicInput : NativeRelation.Instance) (message witnessBytes : Bytes) :
    relation program hash (Codec.encode (encodeInstance publicInput) message) witnessBytes =
      NativeRelation.check program.rows program.cols program.profile hash publicInput witnessBytes := by
  simp [relation]

/-- Execute exactly the checker selected by the canonical public program bytes. -/
def run (hash : Bytes → TCB.Hash32) (programBytes input witness : Bytes) : Bool :=
  match decodeProgram programBytes with
  | none => false
  | some program => relation program hash input witness

@[simp] theorem run_encodeProgram (hash : Bytes → TCB.Hash32) (program : Program)
    (input witness : Bytes) :
    run hash (encodeProgram program) input witness = relation program hash input witness := by
  simp [run]

theorem run_eq_true_iff (hash : Bytes → TCB.Hash32) (programBytes input witness : Bytes) :
    run hash programBytes input witness = true ↔
      ∃ program, decodeProgram programBytes = some program ∧
        relation program hash input witness = true := by
  cases parsed : decodeProgram programBytes with
  | none => simp [run, parsed]
  | some program => simp [run, parsed]

/-- Accepted public-input bytes identify their complete original key/message
pair and private native witness, without a supplied encoding-reflection law. -/
theorem relation_eq_true_iff_canonical (program : Program) (hash : Bytes → TCB.Hash32)
    (input witnessBytes : Bytes) :
    relation program hash input witnessBytes = true ↔
      ∃ (publicInput : NativeRelation.Instance) (message : Bytes)
        (witness : NativeRelation.Witness program.rows program.cols),
        input = Codec.encode (encodeInstance publicInput) message ∧
        witnessBytes = NativeRelation.encode witness ∧
        NativeRelation.Relation program.profile hash publicInput witness := by
  constructor
  · intro accepted
    obtain ⟨key, message, publicInput, witness, inputDecoded, keyDecoded, witnessDecoded, valid⟩ :=
      (relation_eq_true_iff program hash input witnessBytes).1 accepted
    have keyCanonical := (decodeInstance_eq_some_iff key publicInput).1 keyDecoded
    have inputCanonical := (Codec.decode_eq_some_iff input key message).1 inputDecoded
    have witnessCanonical := (NativeRelation.decode_eq_some_iff witnessBytes witness).1 witnessDecoded
    exact ⟨publicInput, message, witness, inputCanonical.trans
      (congrArg (fun key => Codec.encode key message) keyCanonical), witnessCanonical, valid⟩
  · rintro ⟨publicInput, message, witness, rfl, rfl, valid⟩
    rw [relation_canonical]
    simpa only [valid.2] using NativeRelation.check_encode program.profile hash witness valid.1

/-- Recovering valid private bytes for a named original native target yields
its actual coefficients or one of the concrete byte-hash collision events. -/
theorem extracted_target_or_collisions
    (program : Program) (hash : Bytes → TCB.Hash32)
    (publicInput : NativeRelation.Instance) (message witnessBytes : Bytes)
    (accepted : relation program hash (Codec.encode (encodeInstance publicInput) message) witnessBytes = true)
    (operative : Matrix (Fin program.rows) (Fin program.cols) ℤ)
    (originalZ : Fin program.cols → ℤ) (originalA : ℤ) (originalU : Fin program.rows → ℤ)
    (snapshot : publicInput.targetSnapshot = hash (Storage.CoupledCodec.encode (ofMatrix operative)))
    (ciphertext : publicInput.ciphertextDigest =
      hash (Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU)) :
    ∃ witness : NativeRelation.Witness program.rows program.cols,
      NativeRelation.decode program.rows program.cols witnessBytes = some witness ∧
      (witness.z = originalZ ∨
        (Storage.CoupledCodec.encode (ofMatrix witness.target) ≠
            Storage.CoupledCodec.encode (ofMatrix operative) ∧
          hash (Storage.CoupledCodec.encode (ofMatrix witness.target)) =
            hash (Storage.CoupledCodec.encode (ofMatrix operative))) ∨
        (Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u ≠
            Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU ∧
          hash (Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u) =
            hash (Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU))) := by
  rw [relation_canonical] at accepted
  obtain ⟨witness, decoded, bounded, names⟩ :=
    (NativeRelation.check_eq_true_iff program.profile hash publicInput witnessBytes).1 accepted
  exact ⟨witness, decoded, NativeRelation.extracted_target_or_collisions
    program.profile hash publicInput witness ⟨bounded, names⟩ operative originalZ originalA originalU
      snapshot ciphertext⟩

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeProgram
