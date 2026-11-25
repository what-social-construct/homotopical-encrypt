module

public import Protocol.Storage.CoupledCiphertext
public import HCP.CoupledDecoding
public import HCP.CoupledLattice

@[expose] public section

/-!
# Direct byte recovery for the coupled harmonic-lattice mechanism

Encryption is the existing `CoupledCiphertext.sampleBytes`: it constructs the
canonical bytes of the original Hodge observation from its integer message
and exact/coexact openings. The recipient below parses those same bytes and
uses the existing exact rational inverse with its private presentation.
No transport token, rotation, sample message field or stored plaintext is
read by this recovery algorithm.

The executable result refines the original harmonic-lattice partial decoder
on every byte input. Canonical private presentation bytes can be parsed by the
existing matrix codec; its fixed profile determines the same intrinsic
lattice and basis. These are correctness and input-language statements, not
an authentication, sampling, privacy or complexity theorem.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CoupledRecovery

open Sheaf CellularSheaf HCPCoupledFamily

abbrev Bytes := List UInt8

variable {rows cols : ℕ}

/-- Recover integer lattice coefficients from canonical ciphertext bytes and
the private coupling matrix, using exact rational arithmetic. -/
def recover (B : Matrix (Fin rows) (Fin cols) ℤ) (bytes : Bytes) :
    Option (Fin cols → ℤ) := do
  let observed ← CoupledCiphertext.decode rows cols bytes
  HCP.CoupledRational.decodeCoefficients B (CoupledCiphertext.rationalize observed)

/-- Load the same private presentation from its existing canonical bytes. -/
def recoverWithKeyBytes (rows cols : ℕ) (keyBytes ciphertextBytes : Bytes) :
    Option (Fin cols → ℤ) := do
  let B ← CoupledCodec.decodeMatrix rows cols keyBytes
  recover B ciphertextBytes

/-- Every original generated ciphertext recovers its original coefficient vector. -/
theorem recover_sampleBytes (B : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    recover B (CoupledCiphertext.sampleBytes B z a u) = some z := by
  simp only [recover, CoupledCiphertext.decode_sampleBytes]
  exact HCP.CoupledRational.decodeCoefficients_sampleVector B z a u

/-- Both finite byte codecs feed the actual private recovery algorithm. -/
theorem recoverWithKeyBytes_encode_sample (B : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (u : Fin rows → ℤ) :
    recoverWithKeyBytes rows cols (CoupledCodec.encode (CoupledCodec.ofMatrix B))
      (CoupledCiphertext.sampleBytes B z a u) = some z := by
  simp only [recoverWithKeyBytes, CoupledCodec.decodeMatrix_encode]
  exact recover_sampleBytes B z a u

/-- Malformed ciphertext bytes are rejected before any rational inversion. -/
theorem recover_none_of_decode_none (B : Matrix (Fin rows) (Fin cols) ℤ)
    (bytes : Bytes) (malformed : CoupledCiphertext.decode rows cols bytes = none) :
    recover B bytes = none := by
  simp [recover, malformed]

/-- The shared rational conversion realizes the same original real cochain. -/
theorem realize_rationalize (observed : CoupledCiphertext.IntegerCochain rows cols) :
    HCP.CoupledRational.realize (CoupledCiphertext.rationalize observed) =
      CoupledCiphertext.realize observed := by
  apply PiLp.ext
  intro p
  simp [HCP.CoupledRational.realize, CoupledCiphertext.rationalize,
    CoupledCiphertext.realize]

/-- The actual byte algorithm equals canonical parsing followed by the
original semantic harmonic-lattice decoder, including malformed inputs. -/
theorem recover_refines_lattice (B : Matrix (Fin rows) (Fin cols) ℤ) (bytes : Bytes) :
    recover B bytes =
      (CoupledCiphertext.decodeReal rows cols bytes).bind
        (HCP.CoupledCVP.harmonicLatticePresentation B).decodeCoefficients := by
  cases decoded : CoupledCiphertext.decode rows cols bytes with
  | none => simp [recover, CoupledCiphertext.decodeReal, decoded]
  | some observed =>
    simp only [recover, CoupledCiphertext.decodeReal, decoded, Option.map_some,
      Option.bind_some]
    change HCP.CoupledRational.decodeCoefficients B (CoupledCiphertext.rationalize observed) =
      (HCP.CoupledCVP.harmonicLatticePresentation B).decodeCoefficients
        (CoupledCiphertext.realize observed)
    rw [← HCP.CoupledDecoding.decodeCoefficients_realize, realize_rationalize]

/-- Successful byte recovery is exactly membership in the original integer
Hodge-encryption language for the returned message. This imposes no opening
magnitude bounds and is not an authenticity or privacy statement. -/
theorem recover_eq_some_iff_sampleBytes (B : Matrix (Fin rows) (Fin cols) ℤ)
    (bytes : Bytes) (z : Fin cols → ℤ) :
    recover B bytes = some z ↔
      ∃ (a : ℤ) (u : Fin rows → ℤ), bytes = CoupledCiphertext.sampleBytes B z a u := by
  constructor
  · intro accepted
    cases decoded : CoupledCiphertext.decode rows cols bytes with
    | none => simp [recover, decoded] at accepted
    | some observed =>
      have recovered : HCP.CoupledRational.decodeCoefficients B
          (fun p => (observed p : ℚ)) = some z := by
        change HCP.CoupledRational.decodeCoefficients B
          (CoupledCiphertext.rationalize observed) = some z
        unfold recover at accepted
        rw [decoded] at accepted
        change HCP.CoupledRational.decodeCoefficients B
          (CoupledCiphertext.rationalize observed) = some z at accepted
        exact accepted
      obtain ⟨a, u, same⟩ :=
        (HCP.CoupledDecoding.decode_integer_eq_some_iff_observed B observed z).mp recovered
      refine ⟨a, u, ?_⟩
      have canonical := (CoupledCiphertext.decode_eq_some_iff bytes observed).mp decoded
      exact canonical.trans (congrArg CoupledCiphertext.encode same.symm)
  · rintro ⟨a, u, rfl⟩
    exact recover_sampleBytes B z a u

end HomotopicalEncryption.Protocol.Storage.CoupledRecovery
