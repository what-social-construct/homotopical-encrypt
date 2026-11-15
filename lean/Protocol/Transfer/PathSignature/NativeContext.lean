module

public import Protocol.Transfer.PathSignature.NativeRegistered
public import Protocol.Transfer.PathSignature.NativeSecurity
public import Protocol.Storage.CoupledBinding

@[expose] public section

/-!
# Native keys and actual setup at the original transfer context

The existing context-derived owner key agrees with the native witness key
when the original credential, snapshot binding, full ciphertext bytes and
selected ciphertext hash agree. These are equations on the existing objects;
no second storage context or alignment carrier is introduced.

Successful checking already selects the actual parsed program, verifier key
and public CRS. Identifying those parsed components with the selected
primitive's actual setup output gives verification at that same setup, on the
original full signing message and original packet's owner-signature bytes.
The full-view auxiliary equality likewise identifies the supplied ciphertext
bytes with the original configuration's selected ciphertext. These joins do
not establish primitive security, freshness or adversary-output alignment.
-/

set_option autoImplicit false

noncomputable section

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeContext

open Sheaf CellularSheaf HCPCoupledFamily

abbrev Bytes := List UInt8

variable {Owner Asset Receipt : Type}

/-- The original context-derived key names this exact native witness, using
the existing snapshot binding and the selected full-ciphertext bytes. -/
theorem contextKeyFor_instance {rows cols : ℕ}
    (witness : NativeRelation.Witness rows cols) (hash : Bytes → TCB.Hash32)
    (base : Operational.Config (sheaf witness.target) Owner Asset Receipt)
    (credentialFor : Owner → TCB.Hash32) (owner : Owner)
    (credential : credentialFor owner = hash (NativeRelation.credentialBytes witness))
    (snapshot : Storage.CoupledBinding.BindsSnapshot hash witness.target
      base.context.interpretation.snapshot)
    (sample : base.ciphertext = Storage.CoupledCiphertext.sampleBytes witness.target
      witness.z witness.a witness.u)
    (ciphertextHash : base.hashes.ciphertext base.ciphertext = hash base.ciphertext) :
    NativeRegistered.contextKeyFor base credentialFor owner =
      NativeProgram.encodeInstance (NativeRelation.instanceFor hash witness) := by
  have targetRoot :=
    Storage.CoupledBinding.context_root_eq hash witness.target base.context snapshot
  have ciphertextRoot : base.ciphertextDigest = hash
      (Storage.CoupledCiphertext.sampleBytes witness.target witness.z witness.a witness.u) := by
    change base.hashes.ciphertext base.ciphertext = _
    rw [ciphertextHash, sample]
  unfold NativeRegistered.contextKeyFor NativeProgram.keyForInstance NativeRelation.instanceFor
  rw [credential, ← targetRoot, ciphertextRoot]

variable {Seed VerifierKey PublicCRS Trapdoor Randomness : Type}
  {Validator Vertex Edge Face : Type}
  [DecidableEq Validator] [Fintype Vertex] [Fintype Edge] [Fintype Face]
  {committee : Consensus.Committee Validator}
  {authentication : Consensus.VoteAuthentication Validator Bytes}
  {hash : Bytes → TCB.Hash32}
  {X : OrientedTwoComplex Vertex Edge Face} {F : CellularSheaf X}

/-- The checked packet verifies under the selected primitive's actual setup
when the approved parsed key and CRS are its actual two components. -/
theorem checked_verifies_real_setup
    (approval : Certificates.Profile.Approval committee authentication hash)
    (base : Operational.Config F Owner Asset Receipt) (expected : NativeProgram.Program)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32) (seed : Seed)
    (setupKey : parseKey approval.descriptor.verifierKey =
      some ((family expected).setup seed).1)
    (setupCRS : parseCRS approval.descriptor.publicCRS =
      some ((family expected).setup seed).2)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (NativeRegistered.configure approval base expected parseKey parseCRS family credentialFor)
      transfer bytes) :
    (family expected).verify ((family expected).setup seed)
      (Codec.encode (NativeRegistered.contextKeyFor base credentialFor transfer.signer)
        (Signing.message base.codec base.metadata (base.intentFor transfer)))
      checked.proof.packet.ownerSignature = true := by
  obtain ⟨_code, _applicable, _epoch, key, publicCRS, keyParsed, crsParsed, verified⟩ :=
    NativeRegistered.checked_native_selection approval base expected parseKey parseCRS family
      credentialFor checked
  have keyEq : key = ((family expected).setup seed).1 :=
    Option.some.inj (keyParsed.symm.trans setupKey)
  have crsEq : publicCRS = ((family expected).setup seed).2 :=
    Option.some.inj (crsParsed.symm.trans setupCRS)
  have referenceEq : (key, publicCRS) = (family expected).setup seed :=
    Prod.ext keyEq crsEq
  rw [referenceEq] at verified
  simpa only [NativeRegistered.contextKeyFor, NativeProgram.keyForInstance] using verified

/-- Combine the actual context-key and setup joins for a witness with the
dimensions of the exact expected native program. -/
theorem checked_verifies_native_setup
    (approval : Certificates.Profile.Approval committee authentication hash)
    (expected : NativeProgram.Program)
    (witness : NativeRelation.Witness expected.rows expected.cols)
    (base : Operational.Config (sheaf witness.target) Owner Asset Receipt)
    (parseKey : Bytes → Option VerifierKey) (parseCRS : Bytes → Option PublicCRS)
    (family : NativeProgram.Program → CRS.Primitive Seed (VerifierKey × PublicCRS) Trapdoor Randomness)
    (credentialFor : Owner → TCB.Hash32) (seed : Seed)
    (setupKey : parseKey approval.descriptor.verifierKey =
      some ((family expected).setup seed).1)
    (setupCRS : parseCRS approval.descriptor.publicCRS =
      some ((family expected).setup seed).2)
    {transfer : Operational.ResourceTransfer Owner} {bytes : Bytes}
    (checked : Operational.CheckedTransfer
      (NativeRegistered.configure approval base expected parseKey parseCRS family credentialFor)
      transfer bytes)
    (credential : credentialFor transfer.signer = hash (NativeRelation.credentialBytes witness))
    (snapshot : Storage.CoupledBinding.BindsSnapshot hash witness.target
      base.context.interpretation.snapshot)
    (sample : base.ciphertext = Storage.CoupledCiphertext.sampleBytes witness.target
      witness.z witness.a witness.u)
    (ciphertextHash : base.hashes.ciphertext base.ciphertext = hash base.ciphertext) :
    (family expected).verify ((family expected).setup seed)
      (Codec.encode (NativeProgram.encodeInstance (NativeRelation.instanceFor hash witness))
        (Signing.message base.codec base.metadata (base.intentFor transfer)))
      checked.proof.packet.ownerSignature = true := by
  have verified := checked_verifies_real_setup approval base expected parseKey parseCRS family
    credentialFor seed setupKey setupCRS checked
  rw [contextKeyFor_instance witness hash base credentialFor transfer.signer credential snapshot
    sample ciphertextHash] at verified
  exact verified

variable {Reference Aux AdversaryCoins Coins : Type}

/-- The preferred full-view experiment supplies the original configuration's
actual selected ciphertext when its canonical native sample bytes agree. -/
theorem fullView_ciphertext_eq
    (template : CRS.Experiment Seed Reference Trapdoor Randomness (Bytes × Aux) AdversaryCoins Coins)
    (program : NativeProgram.Program) (hash : Bytes → TCB.Hash32)
    (challenge : Coins → NativeRelation.Witness program.rows program.cols) (coin : Coins)
    (base : Operational.Config F Owner Asset Receipt)
    (sample : base.ciphertext = Storage.CoupledCiphertext.sampleBytes (challenge coin).target
      (challenge coin).z (challenge coin).a (challenge coin).u) :
    ((NativeSecurity.fullViewExperiment template program hash challenge).auxiliary coin).1 =
      base.ciphertext :=
  (NativeSecurity.fullView_ciphertext template program hash challenge coin).trans sample.symm

end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeContext
