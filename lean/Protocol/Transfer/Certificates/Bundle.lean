module

public import Protocol.Transfer.Certificates.Evidence

@[expose] public section

/-!
# One submitted byte bundle for all preceding certificate gates

The packet's proof bytes can contain this fixed seven-entry public bundle.
Each entry retains the exact subject and leaf proof bytes. The parser consumes
all seven entries and checks exact canonical re-encoding. Verification of a
level checks every preceding slot against its expected public subject and
executes the selected leaf backend on those exact bytes.

The wrapper backend retains the leaf backend's statement at the original
terminal public input. Successful wrapper execution entails actual terminal
leaf verification and all preceding Boolean checks. This supplies neither
certificate truth nor backend soundness: a false accepted wrapper statement
reduces to the actual terminal leaf's false acceptance.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Certificates

open Proximity.GateEvidence.Projection

/-- The same seven raw entries are retained at every verification level. -/
structure Bundle (Owner : Type) where
  entries : EvidenceSlot → Evidence.Entry Owner

namespace Bundle

open Storage.CoupledCodec
open _root_.HomotopicalEncryption.Protocol.Transfer.Certificates.Evidence
  (Level Required slots claimFor)

abbrev Bytes := List UInt8

variable {Owner : Type}

@[ext] theorem ext {first second : Bundle Owner}
    (entries : first.entries = second.entries) : first = second := by
  cases first
  cases second
  cases entries
  rfl

def toList (bundle : Bundle Owner) : List (Evidence.Entry Owner) :=
  List.ofFn bundle.entries

@[simp] theorem toList_length (bundle : Bundle Owner) :
    bundle.toList.length = evidenceSlotCount := List.length_ofFn

def ofList (entries : List (Evidence.Entry Owner))
    (length : entries.length = evidenceSlotCount) : Bundle Owner where
  entries slot := entries[slot.val]'(by rw [length]; exact slot.isLt)

@[simp] theorem ofList_toList (bundle : Bundle Owner) :
    ofList bundle.toList bundle.toList_length = bundle := by
  apply ext
  funext slot
  dsimp only [ofList, toList]
  simp only [List.getElem_ofFn]

/-- ASCII `HODGE_CERTIFICATE_BUNDLE_V1`. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 67, 69, 82, 84, 73, 70, 73, 67, 65, 84, 69, 95,
    66, 85, 78, 68, 76, 69, 95, 86, 49]

def encodeEntries
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner) :
    List (Evidence.Entry Owner) → Bytes → Bytes
  | [], rest => rest
  | entry :: tail, rest => frame (Evidence.encode codec entry) (encodeEntries codec tail rest)

/-- The count decreases independently of the supplied byte length. -/
def parseN
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner) :
    ℕ → Bytes → Option (List (Evidence.Entry Owner) × Bytes)
  | 0, bytes => some ([], bytes)
  | count + 1, bytes => do
    let (entryBytes, rest) ← parseFrame bytes
    let entry ← Evidence.decode codec entryBytes
    let (entries, tail) ← parseN codec count rest
    some (entry :: entries, tail)

@[simp] theorem parseN_encodeEntries
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (entries : List (Evidence.Entry Owner)) (rest : Bytes) :
    parseN codec entries.length (encodeEntries codec entries rest) = some (entries, rest) := by
  induction entries with
  | nil => rfl
  | cons entry tail ih =>
    simp [parseN, encodeEntries, parseFrame_frame, Evidence.decode_encode, ih]

def encode
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (bundle : Bundle Owner) : Bytes :=
  domain ++ encodeEntries codec bundle.toList []

/-- Seven entries, no trailing bytes and the exact domain/canonical encoding. -/
def decode
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (bytes : Bytes) : Option (Bundle Owner) :=
  match parseN codec evidenceSlotCount (bytes.drop domain.length) with
  | none => none
  | some (entries, rest) =>
    if length : entries.length = evidenceSlotCount then
      let bundle := ofList entries length
      if rest = [] ∧ bytes = encode codec bundle then some bundle else none
    else none

@[simp] theorem decode_encode
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (bundle : Bundle Owner) : decode codec (encode codec bundle) = some bundle := by
  have parsed : parseN codec evidenceSlotCount (encodeEntries codec bundle.toList []) =
      some (bundle.toList, []) := by
    simpa only [toList_length] using parseN_encodeEntries codec bundle.toList []
  simp [decode, encode, parsed, ofList_toList]

theorem decode_eq_some_iff
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (bytes : Bytes) (bundle : Bundle Owner) :
    decode codec bytes = some bundle ↔ bytes = encode codec bundle := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseN codec evidenceSlotCount (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨entries, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next length =>
        split at decoded
        next accepted =>
          have same : ofList entries length = bundle := Option.some.inj decoded
          exact accepted.2.trans (congrArg (encode codec) same)
        next => contradiction
      next => contradiction
  · rintro rfl
    exact decode_encode codec bundle

theorem encode_injective
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner) :
    Function.Injective (encode codec) := by
  intro first second same
  have decoded := congrArg (decode codec) same
  simpa only [decode_encode, Option.some.injEq] using decoded

def subjects (bundle : Bundle Owner) : EvidenceSlot → Codec.Subject Owner :=
  fun slot => (bundle.entries slot).subject

def proofs (bundle : Bundle Owner) : EvidenceSlot → Bytes :=
  fun slot => (bundle.entries slot).proof

/-- Canonical subject-byte comparison avoids requiring an owner equality test. -/
def verifyEntries
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (leaf : TCB.PrimitiveChecks.ProofVerifier) (level : Level)
    (expected : EvidenceSlot → Codec.Subject Owner) (bundle : Bundle Owner) : Bool :=
  (slots level).all fun slot =>
    (decide (Codec.encode codec (bundle.entries slot).subject = Codec.encode codec (expected slot)) &&
      decide ((bundle.entries slot).subject.claim = claimFor slot)) &&
      leaf.verify (Codec.encode codec (expected slot)) (bundle.entries slot).proof

theorem verifyEntries_eq_true_iff
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (leaf : TCB.PrimitiveChecks.ProofVerifier) (level : Level)
    (expected : EvidenceSlot → Codec.Subject Owner) (bundle : Bundle Owner) :
    verifyEntries codec leaf level expected bundle = true ↔
      ∀ slot, Required level slot →
        (bundle.entries slot).subject = expected slot ∧
          (bundle.entries slot).subject.claim = claimFor slot ∧
          leaf.verify (Codec.encode codec (expected slot)) (bundle.entries slot).proof = true := by
  simp only [verifyEntries, List.all_eq_true, Evidence.mem_slots_iff,
    Bool.and_eq_true_iff, decide_eq_true_eq, Codec.encode_eq_iff, and_assoc]

/-- Parse the actual submitted proof bytes, then check every required entry. -/
def verifyPrefix
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (leaf : TCB.PrimitiveChecks.ProofVerifier) (level : Level)
    (expected : EvidenceSlot → Codec.Subject Owner) (bytes : Bytes) : Bool :=
  match decode codec bytes with
  | none => false
  | some bundle => verifyEntries codec leaf level expected bundle

theorem verifyPrefix_eq_true_iff
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (leaf : TCB.PrimitiveChecks.ProofVerifier) (level : Level)
    (expected : EvidenceSlot → Codec.Subject Owner) (bytes : Bytes) :
    verifyPrefix codec leaf level expected bytes = true ↔
      ∃ bundle : Bundle Owner, decode codec bytes = some bundle ∧
        ∀ slot, Required level slot →
          (bundle.entries slot).subject = expected slot ∧
            (bundle.entries slot).subject.claim = claimFor slot ∧
            leaf.verify (Codec.encode codec (expected slot)) (bundle.entries slot).proof = true := by
  cases parsed : decode codec bytes with
  | none => simp [verifyPrefix, parsed]
  | some bundle => simp [verifyPrefix, parsed, verifyEntries_eq_true_iff]

/-- The same canonical submitted bundle must pass every preceding prefix. -/
theorem verifyPrefix_mono
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (leaf : TCB.PrimitiveChecks.ProofVerifier) (earlier later : Level)
    (expected : EvidenceSlot → Codec.Subject Owner) (bytes : Bytes)
    (ordered : earlier.count ≤ later.count)
    (checked : verifyPrefix codec leaf later expected bytes = true) :
    verifyPrefix codec leaf earlier expected bytes = true := by
  obtain ⟨bundle, parsed, checks⟩ := (verifyPrefix_eq_true_iff codec leaf later expected bytes).1 checked
  apply (verifyPrefix_eq_true_iff codec leaf earlier expected bytes).2
  exact ⟨bundle, parsed, fun slot required => checks slot (Nat.lt_of_lt_of_le required ordered)⟩

theorem naturality_requires_hard
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (leaf : TCB.PrimitiveChecks.ProofVerifier)
    (expected : EvidenceSlot → Codec.Subject Owner) (bytes : Bytes)
    (checked : verifyPrefix codec leaf .naturality expected bytes = true) :
    verifyPrefix codec leaf .hard expected bytes = true :=
  verifyPrefix_mono codec leaf .hard .naturality expected bytes (by decide) checked

theorem final_requires_naturality
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (leaf : TCB.PrimitiveChecks.ProofVerifier)
    (expected : EvidenceSlot → Codec.Subject Owner) (bytes : Bytes)
    (checked : verifyPrefix codec leaf .final expected bytes = true) :
    verifyPrefix codec leaf .naturality expected bytes = true :=
  verifyPrefix_mono codec leaf .naturality .final expected bytes (by decide) checked

theorem final_requires_hard
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (leaf : TCB.PrimitiveChecks.ProofVerifier)
    (expected : EvidenceSlot → Codec.Subject Owner) (bytes : Bytes)
    (checked : verifyPrefix codec leaf .final expected bytes = true) :
    verifyPrefix codec leaf .hard expected bytes = true :=
  naturality_requires_hard codec leaf expected bytes
    (final_requires_naturality codec leaf expected bytes checked)

/-- A failed preceding check forces rejection at every subsequent level. -/
theorem reject_of_previous_failed
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (leaf : TCB.PrimitiveChecks.ProofVerifier) (earlier later : Level)
    (expected : EvidenceSlot → Codec.Subject Owner) (bytes : Bytes)
    (ordered : earlier.count ≤ later.count)
    (failed : verifyPrefix codec leaf earlier expected bytes = false) :
    verifyPrefix codec leaf later expected bytes = false := by
  cases outcome : verifyPrefix codec leaf later expected bytes with
  | false => rfl
  | true =>
    have previous := verifyPrefix_mono codec leaf earlier later expected bytes ordered outcome
    rw [failed] at previous
    contradiction

def terminalSlot : Level → EvidenceSlot
  | .hard => EvidenceSlot.semanticAlignment
  | .naturality => EvidenceSlot.projectionNaturality
  | .final => EvidenceSlot.finalFarRegion

def terminalClaim : Level → Codec.Claim
  | .hard => .semanticAlignment
  | .naturality => .projectionNaturality
  | .final => .finalFarRegion

theorem terminal_required (level : Level) : Required level (terminalSlot level) := by
  unfold Required
  cases level <;> decide

@[simp] theorem claimFor_terminal (level : Level) :
    claimFor (terminalSlot level) = terminalClaim level := by
  cases level <;> rfl

/-- Every slot changes only its claim tag in the original complete subject. -/
def expectedSubjects (top : Codec.Subject Owner) : EvidenceSlot → Codec.Subject Owner :=
  fun slot => { top with claim := claimFor slot }

theorem expected_terminal_eq (level : Level) (top : Codec.Subject Owner)
    (claimMatches : top.claim = terminalClaim level) :
    expectedSubjects top (terminalSlot level) = top := by
  have same : claimFor (terminalSlot level) = top.claim :=
    (claimFor_terminal level).trans claimMatches.symm
  unfold expectedSubjects
  rw [same]

/-- The wrapper executes the finite bundle checker and preserves the selected
leaf statement at the original input. Its soundness is not assumed here. -/
def backend
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (level : Level) (leaf : TCB.PrimitiveChecks.ProofVerifier) :
    TCB.PrimitiveChecks.ProofVerifier where
  verify input bundleBytes :=
    match Codec.decode codec input with
    | none => false
    | some top => verifyPrefix codec leaf level (expectedSubjects top) bundleBytes
  Holds := leaf.Holds

/-- Actual wrapper acceptance executes the terminal leaf at the original exact
input, not at a detached statement or independently supplied proof array. -/
theorem backend_verified_terminal
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (level : Level) (leaf : TCB.PrimitiveChecks.ProofVerifier)
    (input bundleBytes : Bytes) (top : Codec.Subject Owner)
    (inputEq : input = Codec.encode codec top)
    (claimMatches : top.claim = terminalClaim level)
    (verified : (backend codec level leaf).verify input bundleBytes = true) :
    ∃ bundle : Bundle Owner, decode codec bundleBytes = some bundle ∧
      leaf.verify input (bundle.entries (terminalSlot level)).proof = true := by
  subst input
  simp only [backend, Codec.decode_encode] at verified
  obtain ⟨bundle, parsed, checks⟩ :=
    (verifyPrefix_eq_true_iff codec leaf level (expectedSubjects top) bundleBytes).1 verified
  have terminal := checks (terminalSlot level) (terminal_required level)
  rw [expected_terminal_eq level top claimMatches] at terminal
  exact ⟨bundle, parsed, terminal.2.2⟩

/-- A false accepted wrapper statement is false acceptance by the actual
terminal leaf proof contained in those canonical submitted bundle bytes. -/
theorem backend_falseAccept_to_leaf
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (level : Level) (leaf : TCB.PrimitiveChecks.ProofVerifier)
    (input bundleBytes : Bytes) (top : Codec.Subject Owner)
    (inputEq : input = Codec.encode codec top)
    (claimMatches : top.claim = terminalClaim level)
    (bad : (backend codec level leaf).FalseAccept input bundleBytes) :
    ∃ bundle : Bundle Owner, decode codec bundleBytes = some bundle ∧
      leaf.FalseAccept input (bundle.entries (terminalSlot level)).proof := by
  obtain ⟨bundle, parsed, verified⟩ :=
    backend_verified_terminal codec level leaf input bundleBytes top inputEq claimMatches bad.1
  exact ⟨bundle, parsed, verified, bad.2⟩

end Bundle
end HomotopicalEncryption.Protocol.Transfer.Certificates
