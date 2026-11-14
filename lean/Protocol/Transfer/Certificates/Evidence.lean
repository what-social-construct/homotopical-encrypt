module

public import Protocol.Transfer.Certificates.Codec
public import Proximity.Concrete.GateEvidence
public import TCB.PrimitiveChecks

@[expose] public section

/-!
# Canonical certificate evidence and prefix checks

Each evidence leaf names the actual public subject and submitted proof bytes.
The immutable root names all seven existing raw evidence slots. The selected
verification level requires five hard slots, then naturality, then the final
far-region slot. Committing a later slot does not certify it. The root is
outside its own preimage. Neither leaf nor root bytes serialize a
private mathematical certificate or manufacture its truth.

The raw prefix checker executes the selected backend on every preceding slot
with its exact subject bytes and rejects an incorrect slot claim. Its
monotonicity laws preserve the same subjects and proof arrays. Byte/root
binding to an existing evidence database is a separate refinement proposition;
the legacy slot-only database facts do not establish it. Certificate semantics
and the proof verifier's correctness remain separate from these finite checks.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Certificates.Evidence

open Storage.CoupledCodec
open Ephemeral.ScopeCodec (encodeFixed)
open Proximity.GateEvidence.Projection

abbrev Bytes := List UInt8

/-- Public evidence contains a public claim subject and its actual proof bytes. -/
structure Entry (Owner : Type) where
  subject : Codec.Subject Owner
  proof : Bytes

/-- ASCII `HODGE_CERTIFICATE_ENTRY_V1`. -/
def entryDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 67, 69, 82, 84, 73, 70, 73, 67, 65, 84, 69, 95,
    69, 78, 84, 82, 89, 95, 86, 49]

variable {Owner : Type}

def encodeBody (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (entry : Entry Owner) (rest : Bytes) : Bytes :=
  frame (Codec.encode codec entry.subject) (frame entry.proof rest)

def parseBody (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (bytes : Bytes) : Option (Entry Owner × Bytes) := do
  let (subjectBytes, rest) ← parseFrame bytes
  let subject ← Codec.decode codec subjectBytes
  let (proof, tail) ← parseFrame rest
  some (⟨subject, proof⟩, tail)

@[simp] theorem parseBody_encodeBody
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (entry : Entry Owner) (rest : Bytes) :
    parseBody codec (encodeBody codec entry rest) = some (entry, rest) := by
  cases entry
  simp [parseBody, encodeBody, parseFrame_frame, Codec.decode_encode]

def encode (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (entry : Entry Owner) : Bytes :=
  entryDomain ++ encodeBody codec entry []

/-- Both fields, the exact domain and complete consumption are checked. -/
def decode (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (bytes : Bytes) : Option (Entry Owner) :=
  match parseBody codec (bytes.drop entryDomain.length) with
  | none => none
  | some (entry, rest) =>
    if rest = [] ∧ bytes = encode codec entry then some entry else none

@[simp] theorem decode_encode
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (entry : Entry Owner) : decode codec (encode codec entry) = some entry := by
  simp [decode, encode]

theorem decode_eq_some_iff
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (bytes : Bytes) (entry : Entry Owner) :
    decode codec bytes = some entry ↔ bytes = encode codec entry := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody codec (bytes.drop entryDomain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next accepted =>
        have same : other = entry := Option.some.inj decoded
        exact accepted.2.trans (congrArg (encode codec) same)
      next => contradiction
  · rintro rfl
    exact decode_encode codec entry

theorem encode_injective
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner) :
    Function.Injective (encode codec) := by
  intro first second same
  have parsed := congrArg (decode codec) same
  simpa only [decode_encode, Option.some.injEq] using parsed

def check (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (digest : TCB.Hash32) (bytes : Bytes) :
    Option (Entry Owner) := do
  let entry ← decode codec bytes
  if hash bytes = digest then some entry else none

theorem check_eq_some_iff
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (digest : TCB.Hash32) (bytes : Bytes) (entry : Entry Owner) :
    check codec hash digest bytes = some entry ↔
      bytes = encode codec entry ∧ hash bytes = digest := by
  cases parsed : decode codec bytes with
  | none => simp [check, parsed, ← decode_eq_some_iff]
  | some other =>
    have canonical := (decode_eq_some_iff codec bytes other).mp parsed
    have entryEq : bytes = encode codec entry ↔ other = entry := by
      constructor
      · intro same
        exact encode_injective codec (canonical.symm.trans same)
      · rintro rfl
        exact canonical
    by_cases checked : hash bytes = digest <;> simp [check, parsed, checked, entryEq]

@[simp] theorem check_encode
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (entry : Entry Owner) :
    check codec hash (hash (encode codec entry)) (encode codec entry) = some entry :=
  (check_eq_some_iff codec hash _ _ entry).mpr ⟨rfl, rfl⟩

/-- A checked entry under an original leaf name is that complete subject/proof
entry, or exhibits unequal canonical bytes with equal hashes. -/
theorem check_original_or_collision
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (original returned : Entry Owner) (bytes : Bytes)
    (accepted : check codec hash (hash (encode codec original)) bytes = some returned) :
    returned = original ∨
      (bytes ≠ encode codec original ∧ hash bytes = hash (encode codec original)) := by
  obtain ⟨canonical, checked⟩ := (check_eq_some_iff codec hash _ bytes returned).mp accepted
  by_cases same : returned = original
  · exact Or.inl same
  · refine Or.inr ⟨?_, checked⟩
    intro sameBytes
    exact same (encode_injective codec (canonical.symm.trans sameBytes))

/-- Three successive gate levels over the original evidence slot schema. -/
inductive Level where
  | hard | naturality | final
  deriving DecidableEq

def Level.count : Level → ℕ
  | .hard => 5
  | .naturality => 6
  | .final => 7

theorem Level.count_le (level : Level) : level.count ≤ evidenceSlotCount := by
  cases level <;> decide

/-- Every later level requires all preceding original slot positions. -/
def Required (level : Level) (slot : EvidenceSlot) : Prop := slot.val < level.count

def slots (level : Level) : List EvidenceSlot :=
  List.ofFn fun index : Fin level.count =>
    ⟨index.val, Nat.lt_of_lt_of_le index.isLt level.count_le⟩

@[simp] theorem slots_length (level : Level) : (slots level).length = level.count :=
  List.length_ofFn

@[simp] theorem mem_slots_iff (level : Level) (slot : EvidenceSlot) :
    slot ∈ slots level ↔ Required level slot := by
  simp only [slots, List.mem_ofFn]
  constructor
  · rintro ⟨index, rfl⟩
    exact index.isLt
  · intro required
    exact ⟨⟨slot.val, required⟩, Fin.ext rfl⟩

/-- The existing seven database positions determine their actual claim tags. -/
def claimFor (slot : EvidenceSlot) : Codec.Claim :=
  match slot.val with
  | 0 => .stageCertificate
  | 1 => .sourceMetric
  | 2 => .pluckerMetric
  | 3 => .publicShadowRespect
  | 4 => .semanticAlignment
  | 5 => .projectionNaturality
  | _ => .finalFarRegion

def leafDigest
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (subjects : EvidenceSlot → Codec.Subject Owner)
    (proofs : EvidenceSlot → Bytes) (slot : EvidenceSlot) : TCB.Hash32 :=
  hash (encode codec ⟨subjects slot, proofs slot⟩)

def directory
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes) :
    List (EvidenceSlot × TCB.Hash32) :=
  (slots .final).map fun slot => (slot, leafDigest codec hash subjects proofs slot)

@[simp] theorem directory_length
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes) :
    (directory codec hash subjects proofs).length = evidenceSlotCount := by
  simp [directory, Level.count, evidenceSlotCount, hardGateEvidenceSlotCount]

/-- ASCII `HODGE_CERTIFICATE_ROOT_V1`, distinct from the entry domain. -/
def rootDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 67, 69, 82, 84, 73, 70, 73, 67, 65, 84, 69, 95,
    82, 79, 79, 84, 95, 86, 49]

def encodeDirectory : List (EvidenceSlot × TCB.Hash32) → Bytes → Bytes
  | [], rest => rest
  | (slot, digest) :: tail, rest =>
    encodeNat slot.val (encodeFixed digest (encodeDirectory tail rest))

/-- Fixed seven-slot schema and ordered raw slot/hash directory. The verified
level, enclosing root and private witnesses are outside this preimage, so
advancing verification retains the same already committed bundle/root. -/
def rootBytes (items : List (EvidenceSlot × TCB.Hash32)) : Bytes :=
  rootDomain ++ encodeNat evidenceSlotCount (encodeDirectory items [])

def rootDigest
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes) : TCB.Hash32 :=
  hash (rootBytes (directory codec hash subjects proofs))

/-- Bind an actual existing database to these public subjects and proof bytes.
This adds no truth to the underlying certificate and replaces no database. -/
structure DatabaseBinds
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (level : Level)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes)
    {runtime : TCB.RuntimeBoundary} (database : EvidenceDatabase runtime) : Prop where
  claims : ∀ slot, Required level slot → (subjects slot).claim = claimFor slot
  slots : ∀ slot, database.slotDigest slot = leafDigest codec hash subjects proofs slot
  root : database.rootDigest = rootDigest codec hash subjects proofs

namespace DatabaseBinds

/-- Byte/root binding retains the same complete bundle when projecting to an
already checked predecessor level. Only the required claim prefix changes. -/
theorem mono
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (hash : Bytes → TCB.Hash32) (earlier later : Level)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes)
    {runtime : TCB.RuntimeBoundary} {database : EvidenceDatabase runtime}
    (ordered : earlier.count ≤ later.count)
    (bound : DatabaseBinds codec hash later subjects proofs database) :
    DatabaseBinds codec hash earlier subjects proofs database where
  claims slot required := bound.claims slot (Nat.lt_of_lt_of_le required ordered)
  slots := bound.slots
  root := bound.root

end DatabaseBinds

/-- Execute the selected backend on every preceding slot and its exact public
input/proof bytes, with a separate actual slot-claim equality test. -/
def checkPrefix
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (backend : TCB.PrimitiveChecks.ProofVerifier) (level : Level)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes) : Bool :=
  (slots level).all fun slot =>
    decide ((subjects slot).claim = claimFor slot) &&
      backend.verify (Codec.encode codec (subjects slot)) (proofs slot)

theorem checkPrefix_eq_true_iff
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (backend : TCB.PrimitiveChecks.ProofVerifier) (level : Level)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes) :
    checkPrefix codec backend level subjects proofs = true ↔
      ∀ slot, Required level slot →
        (subjects slot).claim = claimFor slot ∧
          backend.verify (Codec.encode codec (subjects slot)) (proofs slot) = true := by
  simp only [checkPrefix, List.all_eq_true, mem_slots_iff,
    Bool.and_eq_true_iff, decide_eq_true_eq]

/-- Passing a later prefix entails every earlier check with unchanged subjects
and proof bytes. A later level cannot waive an earlier failed check. -/
theorem checkPrefix_mono
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (backend : TCB.PrimitiveChecks.ProofVerifier) (earlier later : Level)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes)
    (ordered : earlier.count ≤ later.count)
    (checked : checkPrefix codec backend later subjects proofs = true) :
    checkPrefix codec backend earlier subjects proofs = true := by
  apply (checkPrefix_eq_true_iff codec backend earlier subjects proofs).2
  intro slot required
  exact (checkPrefix_eq_true_iff codec backend later subjects proofs).1 checked slot
    (Nat.lt_of_lt_of_le required ordered)

theorem naturality_requires_hard
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (backend : TCB.PrimitiveChecks.ProofVerifier)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes)
    (checked : checkPrefix codec backend .naturality subjects proofs = true) :
    checkPrefix codec backend .hard subjects proofs = true :=
  checkPrefix_mono codec backend .hard .naturality subjects proofs (by decide) checked

theorem final_requires_naturality
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (backend : TCB.PrimitiveChecks.ProofVerifier)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes)
    (checked : checkPrefix codec backend .final subjects proofs = true) :
    checkPrefix codec backend .naturality subjects proofs = true :=
  checkPrefix_mono codec backend .naturality .final subjects proofs (by decide) checked

theorem final_requires_hard
    (codec : _root_.HomotopicalEncryption.Protocol.Evidence.TransferCheck.PacketCodec Owner)
    (backend : TCB.PrimitiveChecks.ProofVerifier)
    (subjects : EvidenceSlot → Codec.Subject Owner) (proofs : EvidenceSlot → Bytes)
    (checked : checkPrefix codec backend .final subjects proofs = true) :
    checkPrefix codec backend .hard subjects proofs = true :=
  naturality_requires_hard codec backend subjects proofs
    (final_requires_naturality codec backend subjects proofs checked)

end HomotopicalEncryption.Protocol.Transfer.Certificates.Evidence
