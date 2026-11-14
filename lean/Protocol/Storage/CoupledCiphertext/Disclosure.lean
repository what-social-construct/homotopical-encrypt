module

public import Protocol.Storage.CoupledCiphertext

@[expose] public section

/-!
# Exact-component observations do not name native ciphertexts

In one fixed coupled presentation, changing the harmonic message or coexact
opening leaves the exact component unchanged when its opening is fixed.
Full canonical ciphertext bytes, however, determine the original message
coefficients even when both opening coordinates vary. This follows from the
existing decoder and harmonic projector, rather than a new recovery object.

Consequently exact-component data alone cannot determine either the native
message or its full ciphertext bytes on two distinct-message samples. A
commitment to that component is therefore not automatically a commitment to
the full Hodge observation. This is an information/encoding statement, not
computational secrecy or a hardness reduction. The presentation is fixed;
unknown-presentation recovery is a separate question. Distinct byte strings
are not assumed to have unequal hashes.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CoupledCiphertext.Disclosure

open Sheaf CellularSheaf HCPCoupledFamily HCPCoupledEncoding

/-- Fixing the exact opening hides all changes of native message and coexact
opening from the exact component itself. -/
theorem sample_exactComponent_eq {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) (z z' : Fin cols → ℤ)
    (a : ℤ) (u u' : Fin rows → ℤ) :
    (sample B z a u).opening.exactComponent =
      (sample B z' a u').opening.exactComponent := rfl

/-- At a fixed presentation, full native bytes determine the original message
even if the exact and coexact openings are allowed to vary. -/
theorem message_eq_of_sampleBytes_eq {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) (z z' : Fin cols → ℤ)
    (a a' : ℤ) (u u' : Fin rows → ℤ)
    (same : sampleBytes B z a u = sampleBytes B z' a' u') : z = z' := by
  have decoded := congrArg (decodeReal rows cols) same
  rw [decodeReal_sampleBytes, decodeReal_sampleBytes] at decoded
  have projected := congrArg (sheaf B).harmonicOneProjection (Option.some.inj decoded)
  rw [sample_projection, sample_projection] at projected
  funext c
  have coordinate := congrArg (fun b : C1 (Fin rows) (Fin cols) => information b c) projected
  change (z c : ℝ) = (z' c : ℝ) at coordinate
  exact_mod_cast coordinate

theorem sampleBytes_ne_of_message_ne {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) (z z' : Fin cols → ℤ)
    (a a' : ℤ) (u u' : Fin rows → ℤ) (different : z ≠ z') :
    sampleBytes B z a u ≠ sampleBytes B z' a' u' := by
  intro same
  exact different (message_eq_of_sampleBytes_eq B z z' a a' u u' same)

/-- No function of the exact component is correct on both native messages. -/
theorem no_exact_message_decoder {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) (z z' : Fin cols → ℤ)
    (a : ℤ) (u u' : Fin rows → ℤ) (different : z ≠ z') :
    ¬ ∃ recover : C1 (Fin rows) (Fin cols) → (Fin cols → ℤ),
      recover (sample B z a u).opening.exactComponent = z ∧
        recover (sample B z' a u').opening.exactComponent = z' := by
  rintro ⟨recover, left, right⟩
  exact different (left.symm.trans
    ((congrArg recover (sample_exactComponent_eq B z z' a u u')).trans right))

/-- Exact-component data cannot reconstruct both distinct full ciphertexts. -/
theorem no_exact_ciphertext_encoder {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) (z z' : Fin cols → ℤ)
    (a : ℤ) (u u' : Fin rows → ℤ) (different : z ≠ z') :
    ¬ ∃ encodeFull : C1 (Fin rows) (Fin cols) → List UInt8,
      encodeFull (sample B z a u).opening.exactComponent = sampleBytes B z a u ∧
        encodeFull (sample B z' a u').opening.exactComponent = sampleBytes B z' a u' := by
  rintro ⟨encodeFull, left, right⟩
  exact sampleBytes_ne_of_message_ne B z z' a a u u' different
    (left.symm.trans
      ((congrArg encodeFull (sample_exactComponent_eq B z z' a u u')).trans right))

/-- Distinct messages can have the same exact component while their canonical
full ciphertexts differ; neither complete object is determined by that component. -/
theorem exact_component_does_not_determine_ciphertext {rows cols : ℕ}
    (B : Matrix (Fin rows) (Fin cols) ℤ) (z z' : Fin cols → ℤ)
    (a : ℤ) (u u' : Fin rows → ℤ) (different : z ≠ z') :
    (sample B z a u).opening.exactComponent =
        (sample B z' a u').opening.exactComponent ∧
      sampleBytes B z a u ≠ sampleBytes B z' a u' ∧
      (¬ ∃ recover : C1 (Fin rows) (Fin cols) → (Fin cols → ℤ),
        recover (sample B z a u).opening.exactComponent = z ∧
          recover (sample B z' a u').opening.exactComponent = z') :=
  ⟨sample_exactComponent_eq B z z' a u u',
    sampleBytes_ne_of_message_ne B z z' a a u u' different,
    no_exact_message_decoder B z z' a u u' different⟩

end HomotopicalEncryption.Protocol.Storage.CoupledCiphertext.Disclosure
