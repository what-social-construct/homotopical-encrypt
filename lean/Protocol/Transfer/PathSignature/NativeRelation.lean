module

public import Protocol.Storage.CoupledCiphertext.Disclosure
public import HCP.CoupledGeometry

@[expose] public section

/-!
# A bounded native private-witness relation

The private witness consists of two integer presentations, integral message
and opening coordinates, and a credential salt. Its executable canonical
decoder reuses the existing matrix and scalar-cochain codecs. The scalar
container inside the private format stores `(a,z,u)` coordinates; it is not
an assertion that those coordinates are an observed ciphertext.

The public instance names the salted source credential, target presentation
and target native ciphertext. Checking recomputes those names from the actual
decoded witness, with explicit magnitude and salt-length bounds. The original
Hodge sample, projection, native transport and typed homotopy equivalence are
then obtained from the existing objects and theorems.

This relation is finite for a fixed bounded profile, but supplies no R1CS
compiler, hash circuit, CRS proof system, credential one-wayness or hiding
theorem. A homotopy class does not identify an individual credential. The
original snapshot/artifact/lifecycle binding must still identify these public
roots with the application's actual storage objects.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeRelation

open Sheaf CellularSheaf HCPCoupledFamily
open scoped CochainComplex.Plus.modelCategoryQuillen
open Storage.CoupledCodec

/-- A selected finite witness profile; dimensions are type parameters. -/
structure Profile where
  bound : ℕ
  saltBytes : ℕ
  deriving DecidableEq

/-- The three separately named public objects of this native relation. -/
structure Instance where
  credential : TCB.Hash32
  targetSnapshot : TCB.Hash32
  ciphertextDigest : TCB.Hash32
  deriving DecidableEq

/-- The actual private presentations, message, openings and credential salt. -/
structure Witness (rows cols : ℕ) where
  source : Matrix (Fin rows) (Fin cols) ℤ
  target : Matrix (Fin rows) (Fin cols) ℤ
  z : Fin cols → ℤ
  a : ℤ
  u : Fin rows → ℤ
  salt : Bytes

variable {rows cols : ℕ}

/-- The scalar codec is reused as a private coordinate container, separately
from the actual observed native cochain produced by `sampleBytes`. -/
def openingCoordinates (witness : Witness rows cols) :
    Storage.CoupledCiphertext.IntegerCochain rows cols :=
  fun edge => match edge.1 with
    | none => witness.a
    | some (.inl col) => witness.z col
    | some (.inr row) => witness.u row

/-- ASCII `HODGE_NATIVE_WITNESS_V1`. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 78, 65, 84, 73, 86, 69, 95,
    87, 73, 84, 78, 69, 83, 83, 95, 86, 49]

def encodeBody (witness : Witness rows cols) (rest : Bytes) : Bytes :=
  frame (Storage.CoupledCodec.encode (ofMatrix witness.source))
    (frame (Storage.CoupledCodec.encode (ofMatrix witness.target))
      (frame (Storage.CoupledCiphertext.encode (openingCoordinates witness))
        (frame witness.salt rest)))

def encode (witness : Witness rows cols) : Bytes := domain ++ encodeBody witness []

def parseBody (rows cols : ℕ) (bytes : Bytes) : Option (Witness rows cols × Bytes) := do
  let (sourceBytes, rest) ← parseFrame bytes
  let source ← decodeMatrix rows cols sourceBytes
  let (targetBytes, rest) ← parseFrame rest
  let target ← decodeMatrix rows cols targetBytes
  let (openingBytes, rest) ← parseFrame rest
  let coordinates ← Storage.CoupledCiphertext.decode rows cols openingBytes
  let (salt, rest) ← parseFrame rest
  some
    ({ source := source
       target := target
       z := fun col => coordinates ⟨some (.inl col), 0⟩
       a := coordinates ⟨none, 0⟩
       u := fun row => coordinates ⟨some (.inr row), 0⟩
       salt := salt }, rest)

@[simp] theorem parseBody_encodeBody (witness : Witness rows cols) (rest : Bytes) :
    parseBody rows cols (encodeBody witness rest) = some (witness, rest) := by
  cases witness
  simp [parseBody, encodeBody, parseFrame_frame, openingCoordinates]

/-- Fixed dimensions, full consumption, exact domain and canonical re-encoding. -/
def decode (rows cols : ℕ) (bytes : Bytes) : Option (Witness rows cols) :=
  match parseBody rows cols (bytes.drop domain.length) with
  | none => none
  | some (witness, rest) =>
    if rest = [] ∧ bytes = encode witness then some witness else none

@[simp] theorem decode_encode (witness : Witness rows cols) :
    decode rows cols (encode witness) = some witness := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (witness : Witness rows cols) :
    decode rows cols bytes = some witness ↔ bytes = encode witness := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody rows cols (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        have same : other = witness := Option.some.inj decoded
        exact canonical.2.trans (congrArg encode same)
      next => contradiction
  · rintro rfl
    exact decode_encode witness

theorem encode_injective : Function.Injective (@encode rows cols) := by
  intro first second same
  have parsed := congrArg (decode rows cols) same
  simpa only [decode_encode, Option.some.injEq] using parsed

theorem encodeBody_append (witness : Witness rows cols) (rest suffix : Bytes) :
    encodeBody witness rest ++ suffix = encodeBody witness (rest ++ suffix) := by
  simp [encodeBody, frame_append]

theorem decode_rejects_trailing (witness : Witness rows cols) (suffix : Bytes)
    (nonempty : suffix ≠ []) : decode rows cols (encode witness ++ suffix) = none := by
  have parsed : parseBody rows cols ((encode witness ++ suffix).drop domain.length) =
      some (witness, suffix) := by
    rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
    simp
  simp [decode, parsed, nonempty]

theorem decode_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take domain.length ≠ domain) : decode rows cols bytes = none := by
  cases parsed : decode rows cols bytes with
  | none => rfl
  | some witness =>
    have canonical := (decode_eq_some_iff bytes witness).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

/-- Bounds retain all actual matrix and coordinate values, not just lengths. -/
def Bounded (profile : Profile) (witness : Witness rows cols) : Prop :=
  (∀ row col, (witness.source row col).natAbs ≤ profile.bound) ∧
    (∀ row col, (witness.target row col).natAbs ≤ profile.bound) ∧
    (∀ col, (witness.z col).natAbs ≤ profile.bound) ∧
    witness.a.natAbs ≤ profile.bound ∧
    (∀ row, (witness.u row).natAbs ≤ profile.bound) ∧
    witness.salt.length = profile.saltBytes

instance (profile : Profile) (witness : Witness rows cols) :
    Decidable (Bounded profile witness) := inferInstanceAs
      (Decidable ((∀ row col, (witness.source row col).natAbs ≤ profile.bound) ∧
        (∀ row col, (witness.target row col).natAbs ≤ profile.bound) ∧
        (∀ col, (witness.z col).natAbs ≤ profile.bound) ∧
        witness.a.natAbs ≤ profile.bound ∧
        (∀ row, (witness.u row).natAbs ≤ profile.bound) ∧
        witness.salt.length = profile.saltBytes))

/-- ASCII `HODGE_NATIVE_CREDENTIAL_V1`; independent of the snapshot/cipher domains. -/
def credentialDomain : Bytes :=
  [72, 79, 68, 71, 69, 95, 78, 65, 84, 73, 86, 69, 95,
    67, 82, 69, 68, 69, 78, 84, 73, 65, 76, 95, 86, 49]

def credentialBytes (witness : Witness rows cols) : Bytes :=
  credentialDomain ++ frame witness.salt (Storage.CoupledCodec.encode (ofMatrix witness.source))

/-- Construct names from this exact witness. Hash security is separate. -/
def instanceFor (hash : Bytes → TCB.Hash32) (witness : Witness rows cols) : Instance where
  credential := hash (credentialBytes witness)
  targetSnapshot := hash (Storage.CoupledCodec.encode (ofMatrix witness.target))
  ciphertextDigest := hash (Storage.CoupledCiphertext.sampleBytes
    witness.target witness.z witness.a witness.u)

/-- The intended bounded arithmetic/hash relation on the actual private bytes. -/
def Relation (profile : Profile) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (witness : Witness rows cols) : Prop :=
  Bounded profile witness ∧ instanceFor hash witness = publicInput

/-- Concrete finite private-witness validation, independent of a proof system. -/
def check (rows cols : ℕ) (profile : Profile) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (witnessBytes : Bytes) : Bool :=
  match decode rows cols witnessBytes with
  | none => false
  | some witness => decide (Bounded profile witness) && decide (instanceFor hash witness = publicInput)

theorem check_eq_true_iff (profile : Profile) (hash : Bytes → TCB.Hash32)
    (publicInput : Instance) (witnessBytes : Bytes) :
    check rows cols profile hash publicInput witnessBytes = true ↔
      ∃ witness : Witness rows cols, decode rows cols witnessBytes = some witness ∧
        Bounded profile witness ∧ instanceFor hash witness = publicInput := by
  cases parsed : decode rows cols witnessBytes with
  | none => simp [check, parsed]
  | some witness => simp [check, parsed]

theorem check_encode (profile : Profile) (hash : Bytes → TCB.Hash32)
    (witness : Witness rows cols) (bounded : Bounded profile witness) :
    check rows cols profile hash (instanceFor hash witness) (encode witness) = true := by
  simp [check, bounded]

/-- The canonical target bytes realize the existing original Hodge sample. -/
theorem target_decodes_original (witness : Witness rows cols) :
    Storage.CoupledCiphertext.decodeReal rows cols
      (Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u) =
      some (HCPCoupledEncoding.sample witness.target witness.z witness.a witness.u).observed :=
  Storage.CoupledCiphertext.decodeReal_sampleBytes witness.target witness.z witness.a witness.u

/-- The native private projector returns this same intrinsic harmonic message. -/
theorem target_harmonic_projection (witness : Witness rows cols) :
    (sheaf witness.target).harmonicOneProjection
        (HCPCoupledEncoding.sample witness.target witness.z witness.a witness.u).observed =
      (HCPCoupledEncoding.message witness.target witness.z).1 :=
  HCPCoupledEncoding.sample_projection witness.target witness.z witness.a witness.u

/-- The actual full native transport preserves the message/opening coordinates. -/
theorem transport_original_sample (witness : Witness rows cols) :
    HCP.CoupledTransport.transport witness.source witness.target
      (HCPCoupledEncoding.sample witness.source witness.z witness.a witness.u).observed =
        (HCPCoupledEncoding.sample witness.target witness.z witness.a witness.u).observed :=
  HCP.CoupledTransport.transport_observed witness.source witness.target witness.z witness.a witness.u

/-- Decoded endpoints have the existing typed Helfer equivalence. This is
distinct from an isometric presented rotation or a serialized general path. -/
theorem homotopy_equivalent (witness : Witness rows cols) :
    Helfer.HomotopyEquivalent
      (HCP.CoupledSemantics.semanticInterpretation witness.source)
      (HCP.CoupledSemantics.semanticInterpretation witness.target) :=
  HCP.CoupledSemantics.semanticEquivalence witness.source witness.target

/-- The original HCP operative target is the same graph-lattice message. -/
theorem operative_target (witness : Witness rows cols) :
    HCP.operativeHarmonicComponent
      (laplacianMatrix witness.target)
      (HCPCoupledEncoding.sample witness.target witness.z witness.a witness.u).observed =
      graphVector witness.target (fun col => (witness.z col : ℝ)) :=
  HCP.CoupledSemantics.operative_recovers_nativeSample witness.target witness.z witness.a witness.u

/-- The extracted target presentation is the operative one, or its distinct
canonical matrix bytes produce an actual collision at the named snapshot. -/
theorem target_eq_or_snapshot_collision
    (profile : Profile) (hash : Bytes → TCB.Hash32) (publicInput : Instance)
    (witness : Witness rows cols) (valid : Relation profile hash publicInput witness)
    (operative : Matrix (Fin rows) (Fin cols) ℤ)
    (snapshot : publicInput.targetSnapshot = hash (Storage.CoupledCodec.encode (ofMatrix operative))) :
    witness.target = operative ∨
      (Storage.CoupledCodec.encode (ofMatrix witness.target) ≠
          Storage.CoupledCodec.encode (ofMatrix operative) ∧
        hash (Storage.CoupledCodec.encode (ofMatrix witness.target)) =
          hash (Storage.CoupledCodec.encode (ofMatrix operative))) := by
  have namedSnapshot : hash (Storage.CoupledCodec.encode (ofMatrix witness.target)) =
      hash (Storage.CoupledCodec.encode (ofMatrix operative)) :=
    (congrArg Instance.targetSnapshot valid.2).trans snapshot
  by_cases same : witness.target = operative
  · exact Or.inl same
  · apply Or.inr
    refine ⟨?_, namedSnapshot⟩
    intro sameBytes
    exact same (Storage.CoupledCodec.encode_matrix_injective sameBytes)

/-- An extracted valid witness for an original named target recovers its
original coefficients, or demonstrates an actual snapshot/ciphertext byte
hash collision. Equality of hash values is never inverted as an axiom. -/
theorem extracted_target_or_collisions
    (profile : Profile) (hash : Bytes → TCB.Hash32) (publicInput : Instance)
    (witness : Witness rows cols) (valid : Relation profile hash publicInput witness)
    (operative : Matrix (Fin rows) (Fin cols) ℤ)
    (originalZ : Fin cols → ℤ) (originalA : ℤ) (originalU : Fin rows → ℤ)
    (snapshot : publicInput.targetSnapshot = hash (Storage.CoupledCodec.encode (ofMatrix operative)))
    (ciphertext : publicInput.ciphertextDigest =
      hash (Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU)) :
    witness.z = originalZ ∨
      (Storage.CoupledCodec.encode (ofMatrix witness.target) ≠
          Storage.CoupledCodec.encode (ofMatrix operative) ∧
        hash (Storage.CoupledCodec.encode (ofMatrix witness.target)) =
          hash (Storage.CoupledCodec.encode (ofMatrix operative))) ∨
      (Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u ≠
          Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU ∧
        hash (Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u) =
          hash (Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU)) := by
  have namedCiphertext :
      hash (Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u) =
        hash (Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU) :=
    (congrArg Instance.ciphertextDigest valid.2).trans ciphertext
  rcases target_eq_or_snapshot_collision profile hash publicInput witness valid operative snapshot with
    sameTarget | snapshotCollision
  · by_cases sameBytes :
        Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u =
          Storage.CoupledCiphertext.sampleBytes operative originalZ originalA originalU
    · apply Or.inl
      rw [sameTarget] at sameBytes
      exact Storage.CoupledCiphertext.Disclosure.message_eq_of_sampleBytes_eq
        operative witness.z originalZ witness.a originalA witness.u originalU sameBytes
    · exact Or.inr (Or.inr ⟨sameBytes, namedCiphertext⟩)
  · exact Or.inr (Or.inl snapshotCollision)

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeRelation
