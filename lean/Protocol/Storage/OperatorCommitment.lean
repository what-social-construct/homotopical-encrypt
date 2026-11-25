module

public import Protocol.Storage.CoupledCodec
public import Protocol.Storage.Context
public import Protocol.Ephemeral.ScopeCodec
public import Sheaf.HCPCoupledFamily

@[expose] public section

/-!
# Private-nonce commitments to the existing coupled operator profile

The private opening pairs the original canonical coupling packet with a
32-byte nonce. The packet already retains the dimensions, ordered integral
matrix and fixed reconstruction profile; its matrix determines the existing
cellular sheaf, Euclidean Hodge operator, integral structure and harmonic
lattice. No independently chosen geometry or lattice is introduced here.

The executable commitment hashes one domain-separated canonical preimage.
The opening codec reuses the matrix codec and the existing fixed-width byte
framing. Successful opening checks bind to the original packet or exhibit an
actual collision between distinct encoded preimages, including the nonce.
The snapshot adapter uses the original sheaf-indexed snapshot and context.

The nonce is private opening material, not a public counter or the native
credential salt. A supplied hash function need not hide any information.
This construction proves encoding, checking and collision alternatives; it
does not instantiate a hash backend, nonce sampler, hiding theorem or proof
system. The raw-matrix snapshot profile remains a distinct reference format.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.OperatorCommitment

open Sheaf CellularSheaf
open CoupledCodec (Bytes Packet ofMatrix frame parseFrame parseFrame_frame frame_append)
open Ephemeral.ScopeCodec (encodeFixed parseFixed parseFixed_encodeFixed encodeFixed_append)

/-- A fixed 32-byte private opening nonce, reusing the existing byte-vector shape. -/
abbrev Nonce := TCB.Hash32

/-- The original coupling packet and its private nonce, with no duplicate geometry. -/
abbrev Opening := Packet × Nonce

/-- ASCII `HODGE_OPERATOR_COMMITMENT_V1`; selects this fixed coupled profile. -/
def domain : Bytes :=
  [72, 79, 68, 71, 69, 95, 79, 80, 69, 82, 65, 84, 79, 82, 95,
    67, 79, 77, 77, 73, 84, 77, 69, 78, 84, 95, 86, 49]

def encodeBody (opening : Opening) (rest : Bytes) : Bytes :=
  frame (CoupledCodec.encode opening.1) (encodeFixed opening.2 rest)

def parseBody (bytes : Bytes) : Option (Opening × Bytes) := do
  let (packetBytes, rest) ← parseFrame bytes
  let packet ← CoupledCodec.decode packetBytes
  let (nonce, rest) ← parseFixed 32 rest
  some ((packet, nonce), rest)

@[simp] theorem parseBody_encodeBody (opening : Opening) (rest : Bytes) :
    parseBody (encodeBody opening rest) = some (opening, rest) := by
  rcases opening with ⟨packet, nonce⟩
  simp [parseBody, encodeBody, parseFrame_frame]

/-- Canonical private bytes: domain, framed matrix packet, then framed 32-byte nonce. -/
def encode (opening : Opening) : Bytes := domain ++ encodeBody opening []

/-- Exact domain, canonical inner packet and fixed nonce width, with full consumption. -/
def decode (bytes : Bytes) : Option Opening :=
  match parseBody (bytes.drop domain.length) with
  | none => none
  | some (opening, rest) =>
    if rest = [] ∧ bytes = encode opening then some opening else none

@[simp] theorem decode_encode (opening : Opening) :
    decode (encode opening) = some opening := by
  simp [decode, encode]

theorem decode_eq_some_iff (bytes : Bytes) (opening : Opening) :
    decode bytes = some opening ↔ bytes = encode opening := by
  constructor
  · intro decoded
    unfold decode at decoded
    cases parsed : parseBody (bytes.drop domain.length) with
    | none => simp [parsed] at decoded
    | some value =>
      rcases value with ⟨other, rest⟩
      simp only [parsed] at decoded
      split at decoded
      next canonical =>
        have same : other = opening := Option.some.inj decoded
        exact canonical.2.trans (congrArg encode same)
      next => contradiction
  · rintro rfl
    exact decode_encode opening

theorem encode_injective : Function.Injective encode := by
  intro first second same
  have parsed := congrArg decode same
  simpa only [decode_encode, Option.some.injEq] using parsed

theorem encodeBody_append (opening : Opening) (rest suffix : Bytes) :
    encodeBody opening rest ++ suffix = encodeBody opening (rest ++ suffix) := by
  simp [encodeBody, frame_append, encodeFixed_append]

theorem decode_rejects_trailing (opening : Opening) (suffix : Bytes)
    (nonempty : suffix ≠ []) : decode (encode opening ++ suffix) = none := by
  have parsed : parseBody ((encode opening ++ suffix).drop domain.length) =
      some (opening, suffix) := by
    rw [encode, List.append_assoc, List.drop_left, encodeBody_append]
    simp
  simp [decode, parsed, nonempty]

theorem decode_rejects_wrong_domain (bytes : Bytes)
    (wrong : bytes.take domain.length ≠ domain) : decode bytes = none := by
  cases parsed : decode bytes with
  | none => rfl
  | some opening =>
    have canonical := (decode_eq_some_iff bytes opening).mp parsed
    apply False.elim
    apply wrong
    rw [canonical, encode, List.take_left]

/-- Public digest of this canonical private packet/nonce opening. -/
def commit (hash : Bytes → TCB.Hash32) (packet : Packet) (nonce : Nonce) : TCB.Hash32 :=
  hash (encode (packet, nonce))

/-- Check the original supplied packet and private nonce against their public digest. -/
def check (hash : Bytes → TCB.Hash32) (root : TCB.Hash32)
    (packet : Packet) (nonce : Nonce) : Bool :=
  decide (commit hash packet nonce = root)

theorem check_eq_true_iff (hash : Bytes → TCB.Hash32) (root : TCB.Hash32)
    (packet : Packet) (nonce : Nonce) :
    check hash root packet nonce = true ↔ commit hash packet nonce = root := by
  simp [check]

@[simp] theorem check_commit (hash : Bytes → TCB.Hash32) (packet : Packet) (nonce : Nonce) :
    check hash (commit hash packet nonce) packet nonce = true := by
  simp [check]

/-- Equal commitments retain the packet, or give an actual collision between
distinct complete operator preimages. The two private nonces may differ. -/
theorem packet_eq_or_collision (hash : Bytes → TCB.Hash32)
    (first second : Packet) (firstNonce secondNonce : Nonce)
    (same : commit hash first firstNonce = commit hash second secondNonce) :
    first = second ∨
      (encode (first, firstNonce) ≠ encode (second, secondNonce) ∧
        hash (encode (first, firstNonce)) = hash (encode (second, secondNonce))) := by
  by_cases equal : first = second
  · exact Or.inl equal
  · refine Or.inr ⟨?_, same⟩
    intro sameBytes
    exact equal (congrArg Prod.fst (encode_injective sameBytes))

/-- Accepted substitution for the original commitment retains its packet or
exhibits a collision on the actual accepted opening preimage. -/
theorem check_original_or_collision (hash : Bytes → TCB.Hash32)
    (original returned : Packet) (originalNonce returnedNonce : Nonce)
    (accepted : check hash (commit hash original originalNonce) returned returnedNonce = true) :
    returned = original ∨
      (encode (returned, returnedNonce) ≠ encode (original, originalNonce) ∧
        hash (encode (returned, returnedNonce)) = hash (encode (original, originalNonce))) :=
  packet_eq_or_collision hash returned original returnedNonce originalNonce
    ((check_eq_true_iff hash _ returned returnedNonce).mp accepted)

/-- Specialize packet binding to the same original finite integer matrix
carrier. No global digest injectivity or nonce equality is assumed. -/
theorem matrix_eq_or_collision (hash : Bytes → TCB.Hash32) {rows cols : ℕ}
    (B C : Matrix (Fin rows) (Fin cols) ℤ) (nonceB nonceC : Nonce)
    (same : commit hash (ofMatrix B) nonceB = commit hash (ofMatrix C) nonceC) :
    B = C ∨
      (encode (ofMatrix B, nonceB) ≠ encode (ofMatrix C, nonceC) ∧
        hash (encode (ofMatrix B, nonceB)) = hash (encode (ofMatrix C, nonceC))) := by
  rcases packet_eq_or_collision hash (ofMatrix B) (ofMatrix C) nonceB nonceC same with
    equal | collision
  · exact Or.inl (CoupledCodec.encode_matrix_injective (congrArg CoupledCodec.encode equal))
  · exact Or.inr collision

/-- Bind this private opening to the original sheaf-indexed snapshot root. -/
def BindsSnapshot (hash : Bytes → TCB.Hash32) {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) (nonce : Nonce)
    (snapshot : SheafStateSnapshot (HCPCoupledFamily.sheaf B)) : Prop :=
  commit hash (ofMatrix B) nonce = snapshot.root

/-- The same binding equation supplies the root in the original context key. -/
theorem context_root_eq (hash : Bytes → TCB.Hash32) {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) (nonce : Nonce)
    (C : Context (HCPCoupledFamily.sheaf B))
    (bound : BindsSnapshot hash B nonce C.interpretation.snapshot) :
    commit hash (ofMatrix B) nonce = C.key.snapshotRoot := bound

end HomotopicalEncryption.Protocol.Storage.OperatorCommitment
