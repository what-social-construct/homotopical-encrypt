module

public import TCB.ProofCarrying

@[expose] public section

/-
  Compression boundary.

  Paper correspondence:
  - Paper 2: concrete compression/observation, digest/root, proof and storage
    contracts.
  - Paper 1 supplies only the mathematical distinction between a
    full observation and a compressed or exact-component view.

  This module records the abstract pattern shared by hash commitments,
  proof-carrying artifacts, SNARKs, oracle attestations, and authenticated
  storage roots:

    full/private witness -> public shadow -> digest/root/proof -> verifier

  It does not choose Poseidon, SHA-256, a Merkle tree, or a SNARK backend.
  Rust owns those concrete encodings and verifiers. Lean records the semantic
  obligations that compression must preserve.
-/

namespace Hcrypt
namespace TCB
namespace CompressionBoundary

/--
A semantic compression contract from a full object/witness to a public shadow.

`Full` may be a private fibration representative, a large cochain/sheaf object,
or a full execution/witness trace. `Shadow` is the bounded public datum that can
be hashed, proven about, attested, or stored under an authenticated root.
-/
structure CompressionContract where
  Full : Type
  Shadow : Type
  /-- Validity predicate on the full/private object. -/
  FullValid : Full → Prop
  /-- Validity predicate on the bounded public shadow. -/
  ShadowValid : Shadow → Prop
  /-- Semantic compression/projection relation. -/
  Compresses : Full → Shadow → Prop
  /--
  Compression soundness: valid full objects only compress to valid public
  shadows.
  -/
  sound :
    ∀ {w : Full} {s : Shadow},
      Compresses w s → FullValid w → ShadowValid s
  /--
  Digest/root binding for the public shadow.

  The concrete hash, transcript domain, serialization, and byte-level checks
  are Rust-owned runtime obligations.
  -/
  BindsDigest : Shadow → Hash32 → Prop

namespace CompressionContract

/-- A public shadow plus its digest/root binding. -/
structure CompressedShadow (K : CompressionContract) where
  shadow : K.Shadow
  digest : Hash32
  bindsDigest : K.BindsDigest shadow digest

/-- A compressed shadow that also carries the public validity fact. -/
def CompressedShadow.WellFormed {K : CompressionContract}
    (C : CompressedShadow K) : Prop :=
  K.ShadowValid C.shadow ∧ K.BindsDigest C.shadow C.digest

/-- Build a well-formed compressed shadow from a valid full witness. -/
def compressWitness
    (K : CompressionContract)
    (w : K.Full)
    (s : K.Shadow)
    (digest : Hash32)
    (_hCompress : K.Compresses w s)
    (_hFull : K.FullValid w)
    (hBind : K.BindsDigest s digest) :
    CompressedShadow K where
  shadow := s
  digest := digest
  bindsDigest := hBind

/-- The shadow produced from a valid full witness satisfies public validity. -/
theorem compressedShadow_valid_of_witness
    (K : CompressionContract)
    {w : K.Full} {s : K.Shadow} {digest : Hash32}
    (hCompress : K.Compresses w s)
    (hFull : K.FullValid w)
    (hBind : K.BindsDigest s digest) :
    K.ShadowValid (K.compressWitness w s digest hCompress hFull hBind).shadow :=
  K.sound hCompress hFull

/-- The compressed shadow built from a valid witness is well formed. -/
theorem compressedShadow_wellFormed_of_witness
    (K : CompressionContract)
    {w : K.Full} {s : K.Shadow} {digest : Hash32}
    (hCompress : K.Compresses w s)
    (hFull : K.FullValid w)
    (hBind : K.BindsDigest s digest) :
    (K.compressWitness w s digest hCompress hFull hBind).WellFormed := by
  exact ⟨K.sound hCompress hFull, hBind⟩

/--
A proof-carrying artifact realizes a compressed public statement when its
statement implies the shadow-validity predicate.
-/
structure ProofCarriesCompressedShadow
    (K : CompressionContract)
    (P : ProofCarryingCommittedCochain) where
  compressed : CompressedShadow K
  statementImpliesShadowValid : P.statement → K.ShadowValid compressed.shadow

namespace ProofCarriesCompressedShadow

variable {K : CompressionContract} {P : ProofCarryingCommittedCochain}

/--
A well-formed proof-carrying artifact certifies the validity of its compressed
public shadow.
-/
theorem shadowValid
    (C : ProofCarriesCompressedShadow K P)
    (hP : P.WellFormed) :
    K.ShadowValid C.compressed.shadow :=
  C.statementImpliesShadowValid hP.2.2.1

end ProofCarriesCompressedShadow

end CompressionContract

end CompressionBoundary
end TCB
end Hcrypt
