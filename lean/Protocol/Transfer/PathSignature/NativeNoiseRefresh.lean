module

public import Protocol.Transfer.PathSignature.NativeSignSampler
public import HCP.CoupledTransport

@[expose] public section

/-!
# Coexact refresh after native presentation transport

The original transport retains the exact and coexact opening coordinates.
The fresh-sign sampler instead prescribes an opening depending on the target
presentation and plaintext. These are distinct operations: transporting a
sample does not in general produce a sample of that fresh distribution.

This module supplies the missing arithmetic correction. After transport to
the target presentation, add the target's coexact observation for the
difference of the desired and retained openings. The canonical byte operation
parses the actual original ciphertext and produces precisely the desired
target sample. It preserves the harmonic coefficients and exact opening.

The correction takes the required opening difference explicitly. It does not
construct a public refresh token, hide that difference, sample independent
target keys, or enforce one-use lifecycle. Those data and exposure conditions
are needed separately for a privacy claim.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeNoiseRefresh

open Sheaf CellularSheaf HCPCoupledFamily
open Storage.CoupledCiphertext
open scoped BigOperators

variable {rows cols : ℕ}

/-- Changing only the coexact opening adds precisely a zero-message target
coexact observation on the original integer cochain carrier. -/
theorem integerObserved_refresh (C : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (retained desired : Fin rows → ℤ) :
    HCPCoupledEncoding.integerObserved C z a retained +
      HCPCoupledEncoding.integerObserved C 0 0 (desired - retained) =
      HCPCoupledEncoding.integerObserved C z a desired := by
  funext edge
  rcases edge with ⟨position, component⟩
  cases position with
  | none => simp [HCPCoupledEncoding.integerObserved]
  | some position =>
    cases position <;>
      simp [HCPCoupledEncoding.integerObserved, mul_sub, Finset.sum_sub_distrib]

/-- Actual canonical-byte coexact correction. Malformed input bytes reject. -/
def refreshBytes (C : Matrix (Fin rows) (Fin cols) ℤ)
    (difference : Fin rows → ℤ) (bytes : List UInt8) : Option (List UInt8) := do
  let observed ← decode rows cols bytes
  some (encode (observed + HCPCoupledEncoding.integerObserved C 0 0 difference))

theorem refreshBytes_sampleBytes (C : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (retained desired : Fin rows → ℤ) :
    refreshBytes C (desired - retained) (sampleBytes C z a retained) =
      some (sampleBytes C z a desired) := by
  simp only [refreshBytes, decode_sampleBytes, bind, Option.bind, integerObserved_refresh]
  rfl

/-- At a fixed target presentation and message, different coexact openings
give different canonical full ciphertext bytes. -/
theorem sampleBytes_eq_iff_opening_eq (C : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (first second : Fin rows → ℤ) :
    sampleBytes C z a first = sampleBytes C z a second ↔ first = second := by
  constructor
  · intro same
    have observed := congrArg (decode rows cols) same
    rw [decode_sampleBytes, decode_sampleBytes] at observed
    have vectors := Option.some.inj observed
    funext row
    have parity := congrArg (fun value : IntegerCochain rows cols =>
      value ⟨some (.inr row), 0⟩) vectors
    simpa only [HCPCoupledEncoding.integerObserved, add_left_cancel_iff] using parity
  · rintro rfl
    rfl

/-- The byte correction realizes exactly the fresh-sign target's correlated
opening after ordinary transport has retained the source opening. -/
theorem refresh_signed_target (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (oldKey newKey message : Fin cols → Bool) :
    refreshBytes (NativeSignSampler.presentation A newKey)
      (NativeSignSampler.opening A newKey message - NativeSignSampler.opening A oldKey message)
      (sampleBytes (NativeSignSampler.presentation A newKey)
        (NativeSignSampler.coefficients d message) a (NativeSignSampler.opening A oldKey message)) =
      some (NativeSignSampler.ciphertextBytes A d a newKey message) :=
  refreshBytes_sampleBytes _ _ _ _ _

/-- Ordinary migrated bytes are already fresh-sign target bytes exactly when
the retained opening equals that target's prescribed opening. -/
theorem migrated_eq_fresh_iff (A : Matrix (Fin rows) (Fin cols) ℤ) (d a : ℤ)
    (oldKey newKey message : Fin cols → Bool) :
    sampleBytes (NativeSignSampler.presentation A newKey) (NativeSignSampler.coefficients d message)
      a (NativeSignSampler.opening A oldKey message) =
        NativeSignSampler.ciphertextBytes A d a newKey message ↔
      NativeSignSampler.opening A oldKey message = NativeSignSampler.opening A newKey message :=
  sampleBytes_eq_iff_opening_eq _ _ _ _ _

/-- The real cochain operation uses the existing native transport and adds
only a target coexact component, preserving the original harmonic message. -/
theorem transport_then_refresh (B C : Matrix (Fin rows) (Fin cols) ℤ)
    (z : Fin cols → ℤ) (a : ℤ) (retained desired : Fin rows → ℤ) :
    HCP.CoupledTransport.transport B C (HCPCoupledEncoding.sample B z a retained).observed +
      (HCPCoupledEncoding.sample C 0 0 (desired - retained)).observed =
      (HCPCoupledEncoding.sample C z a desired).observed := by
  rw [HCP.CoupledTransport.transport_observed]
  rw [← HCPCoupledEncoding.integerObserved_cast_eq_observed C z a retained,
    ← HCPCoupledEncoding.integerObserved_cast_eq_observed C 0 0 (desired - retained),
    ← HCPCoupledEncoding.integerObserved_cast_eq_observed C z a desired]
  apply PiLp.ext
  intro edge
  change ((HCPCoupledEncoding.integerObserved C z a retained edge : ℤ) : ℝ) +
    ((HCPCoupledEncoding.integerObserved C 0 0 (desired - retained) edge : ℤ) : ℝ) =
    ((HCPCoupledEncoding.integerObserved C z a desired edge : ℤ) : ℝ)
  exact_mod_cast congrFun (integerObserved_refresh C z a retained desired) edge

/-- A scalar example makes the migration/freshness distinction nonvacuous. -/
theorem scalar_migration_not_fresh :
    sampleBytes (fun _ _ : Fin 1 => (-1 : ℤ)) (fun _ : Fin 1 => (1 : ℤ)) 0
        (fun _ : Fin 1 => (1 : ℤ)) ≠
      sampleBytes (fun _ _ : Fin 1 => (-1 : ℤ)) (fun _ : Fin 1 => (1 : ℤ)) 0
        (fun _ : Fin 1 => (-1 : ℤ)) := by
  intro same
  have openingEq := (sampleBytes_eq_iff_opening_eq _ _ _ _ _).1 same
  have coordinate := congrFun openingEq 0
  norm_num at coordinate

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeNoiseRefresh
