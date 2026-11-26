module

public import Protocol.Transfer.PathSignature.NativeCommittedRelease
public import Protocol.Transfer.PathSignature.NativeCommittedRandomOracle

@[expose] public section

/-!
# Honest V2 release evidence

The owner signature is the selected V2 CRS prover's output on the full
canonical signing input and the encoded nonce-bearing witness. The proof
randomness is sampled inside the experiment. A supplied payload prover uses
the original intent and ciphertext in the same public oracle. Its failure
leaves the release without evidence.

The pointwise completeness theorem checks only the owner's signature. It
uses the supplied primitive's correctness for the actual V2 relation, when
the public reference and the three instance names agree with setup and the
witness. Payload acceptance, profile approval and simulation require their
own hypotheses.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease

open OracleComp
open NativeCommittedRandomOracle (PublicSpec)

/-- The honest producer receives the private witness, original public intent,
canonical signing input and full ciphertext. -/
abbrev EvidenceProducer (Owner Advice : Type) (rows cols : ℕ) :=
  Advice → NativeCommitted.Witness rows cols → Evidence.TransferTranscript.Intent Owner →
    List UInt8 → List UInt8 → OracleComp PublicSpec (Option (List UInt8 × List UInt8))

namespace HonestEvidence

variable {Owner Advice Seed Reference Trapdoor Randomness : Type} {rows cols : ℕ}

/-- Generate the payload proof for the original intent and ciphertext. -/
abbrev PayloadProducer (Owner Advice : Type) (rows cols : ℕ) :=
  Advice → NativeCommitted.Witness rows cols → Evidence.TransferTranscript.Intent Owner →
    List UInt8 → OracleComp PublicSpec (Option (List UInt8))

/-- Supply the already framed V2 input to the selected CRS prover. -/
def ownerSignature (primitive : CRS.Primitive Seed Reference Trapdoor Randomness)
    (reference : Reference) (signingInput : List UInt8)
    (witness : NativeCommitted.Witness rows cols) (randomness : Randomness) : List UInt8 :=
  primitive.prove reference signingInput (NativeCommitted.encodeWitness witness) randomness

/-- Produce actual owner-signature bytes and the supplied payload proof. -/
def crs [SampleableType Randomness]
    (program : NativeCommitted.Program)
    (family : NativeCommitted.Program → CRS.Primitive Seed Reference Trapdoor Randomness)
    (referenceFor : Advice → Reference)
    (payload : PayloadProducer Owner Advice program.rows program.cols) :
    EvidenceProducer Owner Advice program.rows program.cols :=
  fun advice witness intent signingInput ciphertext => do
    let randomness ← (liftM ($ᵗ Randomness) : OracleComp PublicSpec Randomness)
    let proof ← payload advice witness intent ciphertext
    pure (proof.map fun proofBytes =>
      (ownerSignature (family program) (referenceFor advice) signingInput witness randomness,
        proofBytes))

/-- The owner signature verifies on the original full signing input when
the reference comes from honest setup and the V2 names match the witness. -/
theorem ownerSignature_complete
    (program : NativeCommitted.Program)
    (family : NativeCommitted.Program → CRS.Primitive Seed Reference Trapdoor Randomness)
    (hash : List UInt8 → TCB.Hash32)
    (correct : CRS.Correct (family program) (NativeCommitted.relation program hash))
    (seed : Seed) (reference : Reference)
    (reference_eq : reference = (family program).setup seed)
    (inputs : Inputs Owner) (publicInput : NativeCommitted.Instance)
    (witness : NativeCommitted.Witness program.rows program.cols)
    (bounded : NativeRelation.Bounded program.profile witness.native)
    (names : NativeCommitted.instanceFor hash witness = publicInput)
    (randomness : Randomness) :
    (family program).verify reference (inputs.signingInputAt publicInput)
      (ownerSignature (family program) reference (inputs.signingInputAt publicInput)
        witness randomness) = true := by
  rw [reference_eq]
  apply correct seed
  rw [← names]
  exact NativeCommitted.relation_encode program hash witness bounded _

end HonestEvidence
end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeCommittedRelease
