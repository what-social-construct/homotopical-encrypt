module

public import Protocol.Transfer.Signing
public import TCB.PrimitiveChecks

@[expose] public section

/-!
# Authorized owner-intent issuance and its existing byte-query history

An issuance record retains the existing metadata, full intent and actual
signature bytes together with authorization under the supplied relation.
Its owner is the signer's existing intent coordinate; no second owner or key
registry is introduced. Query bytes use the selected existing packet codec
and the owner-intent signing domain.

The byte history also admits foreign queries whose messages are explicitly
outside the owner-intent domain. Thus existing spectral-worker signatures can
coexist without pretending that a typed-only log covers every disclosed
signature. Full intent reflection, rather than key injectivity or equality of
policy names, recovers authorization from any queried owner-intent message.

These are data and policy-preservation facts. A record does not execute secret
signing, prove key setup, or establish coverage of arbitrary auxiliary data.
Coverage below retains actual signature bytes; the projection to query history
only retains key/message pairs. The history is a batch of supplied queries,
not an adaptive oracle execution or a chronological issuance state machine.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Issuance

open Evidence.TransferTranscript
open TCB.PrimitiveChecks

variable {Owner Key : Type}

/-- An owner-intent record authorized under this supplied relation.
Metadata may vary across records; matching policy names never identify two
authorization predicates. The same actual relation governs this whole log. -/
structure Issued (authorized : Owner → Intent Owner → Prop) where
  metadata : ProofMetadata
  intent : Intent Owner
  signature : Bytes
  authorization : authorized intent.transfer.signer intent

namespace Issued

variable {authorized : Owner → Intent Owner → Prop}

/-- The exact key/message query represented by this existing issuance record. -/
def query (codec : Evidence.TransferCheck.PacketCodec Owner) (keyFor : Owner → Key)
    (record : Issued authorized) : Key × Bytes :=
  (keyFor record.intent.transfer.signer, Signing.message codec record.metadata record.intent)

theorem query_key (codec : Evidence.TransferCheck.PacketCodec Owner) (keyFor : Owner → Key)
    (record : Issued authorized) :
    (record.query codec keyFor).1 = keyFor record.intent.transfer.signer := rfl

theorem query_message (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) (record : Issued authorized) :
    (record.query codec keyFor).2 = Signing.message codec record.metadata record.intent := rfl

end Issued

variable {authorized : Owner → Intent Owner → Prop}

/-- Project the actual issuance records to the existing byte-query shape. -/
def typedQueries (codec : Evidence.TransferCheck.PacketCodec Owner) (keyFor : Owner → Key)
    (records : List (Issued authorized)) : List (Key × Bytes) :=
  records.map (Issued.query codec keyFor)

theorem mem_typedQueries_iff (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) (records : List (Issued authorized)) (key : Key) (message : Bytes) :
    (key, message) ∈ typedQueries codec keyFor records ↔
      ∃ record ∈ records, keyFor record.intent.transfer.signer = key ∧
        Signing.message codec record.metadata record.intent = message := by
  constructor
  · intro member
    obtain ⟨record, recorded, same⟩ := List.mem_map.mp member
    exact ⟨record, recorded, congrArg Prod.fst same, congrArg Prod.snd same⟩
  · rintro ⟨record, recorded, key_eq, message_eq⟩
    exact List.mem_map.mpr ⟨record, recorded, Prod.ext key_eq message_eq⟩

theorem typedQuery_mem (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) {records : List (Issued authorized)}
    (record : Issued authorized) (recorded : record ∈ records) :
    record.query codec keyFor ∈ typedQueries codec keyFor records :=
  List.mem_map.mpr ⟨record, recorded, rfl⟩

/-- Appending typed issuances preserves the original queries in their original order. -/
theorem typedQueries_append (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) (left right : List (Issued authorized)) :
    typedQueries codec keyFor (left ++ right) =
      typedQueries codec keyFor left ++ typedQueries codec keyFor right := by
  simp only [typedQueries, List.map_append]

/-- Reuse the existing history, retaining a supplied foreign batch and compromise relation. -/
def history (codec : Evidence.TransferCheck.PacketCodec Owner) (keyFor : Owner → Key)
    (records : List (Issued authorized)) (foreignQueries : List (Key × Bytes))
    (compromised : Key → Prop) : SignatureHistory Key where
  queries := typedQueries codec keyFor records ++ foreignQueries
  compromised := compromised

theorem history_queries (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) (records : List (Issued authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop) :
    (history codec keyFor records foreignQueries compromised).queries =
      typedQueries codec keyFor records ++ foreignQueries := rfl

theorem history_compromised (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) (records : List (Issued authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop) :
    (history codec keyFor records foreignQueries compromised).compromised = compromised := rfl

theorem queried_iff (codec : Evidence.TransferCheck.PacketCodec Owner) (keyFor : Owner → Key)
    (records : List (Issued authorized)) (foreignQueries : List (Key × Bytes))
    (compromised : Key → Prop) (key : Key) (message : Bytes) :
    (history codec keyFor records foreignQueries compromised).Queried key message ↔
      (key, message) ∈ typedQueries codec keyFor records ∨ (key, message) ∈ foreignQueries := by
  simp only [SignatureHistory.Queried, history, List.mem_append]

/-- Every actual typed issuance is present in the combined byte-query history. -/
theorem issued_queried (codec : Evidence.TransferCheck.PacketCodec Owner) (keyFor : Owner → Key)
    {records : List (Issued authorized)} (foreignQueries : List (Key × Bytes))
    (compromised : Key → Prop) (record : Issued authorized) (recorded : record ∈ records) :
    (history codec keyFor records foreignQueries compromised).Queried
      (keyFor record.intent.transfer.signer) (Signing.message codec record.metadata record.intent) :=
  (queried_iff codec keyFor records foreignQueries compromised _ _).2
    (Or.inl (typedQuery_mem codec keyFor record recorded))

/-- A queried owner-domain message comes from an actual typed record with the
same full metadata and intent. Query membership alone asserts no equality of
the attempted and recorded signature bytes. -/
theorem queried_issued (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) (records : List (Issued authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop)
    (foreignOutside : ∀ key message, (key, message) ∈ foreignQueries → ¬ Signing.InDomain message)
    (metadata : ProofMetadata) (intent : Intent Owner)
    (queried : (history codec keyFor records foreignQueries compromised).Queried
      (keyFor intent.transfer.signer) (Signing.message codec metadata intent)) :
    ∃ record ∈ records, record.metadata = metadata ∧ record.intent = intent := by
  rcases (queried_iff codec keyFor records foreignQueries compromised _ _).1 queried with
    typed | foreign
  · obtain ⟨record, recorded, _key_eq, message_eq⟩ :=
      (mem_typedQueries_iff codec keyFor records _ _).1 typed
    exact ⟨record, recorded, Signing.message_metadata_eq codec message_eq,
      Signing.message_intent_eq codec message_eq⟩
  · exact False.elim (foreignOutside _ _ foreign (Signing.message_inDomain codec metadata intent))

/-- Full-intent reflection recovers the actual authorization relation even when
different owners share a verification key. Foreign messages cannot enter this domain. -/
theorem queried_authorized (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) (records : List (Issued authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop)
    (foreignOutside : ∀ key message, (key, message) ∈ foreignQueries → ¬ Signing.InDomain message)
    (metadata : ProofMetadata) (intent : Intent Owner)
    (queried : (history codec keyFor records foreignQueries compromised).Queried
      (keyFor intent.transfer.signer) (Signing.message codec metadata intent)) :
    authorized intent.transfer.signer intent := by
  obtain ⟨record, _recorded, _sameMetadata, sameIntent⟩ :=
    queried_issued codec keyFor records foreignQueries compromised foreignOutside metadata intent queried
  simpa only [sameIntent] using record.authorization

/-- The log covers these actual signature bytes, as well as the complete signed input. -/
def Covers (records : List (Issued authorized)) (metadata : ProofMetadata)
    (intent : Intent Owner) (signature : Bytes) : Prop :=
  ∃ record ∈ records, record.metadata = metadata ∧ record.intent = intent ∧
    record.signature = signature

theorem covers_record {records : List (Issued authorized)} (record : Issued authorized)
    (recorded : record ∈ records) :
    Covers records record.metadata record.intent record.signature :=
  ⟨record, recorded, rfl, rfl, rfl⟩

theorem covers_cons (record : Issued authorized) (records : List (Issued authorized)) :
    Covers (record :: records) record.metadata record.intent record.signature :=
  covers_record record (by simp)

theorem Covers.authorization {records : List (Issued authorized)} {metadata : ProofMetadata}
    {intent : Intent Owner} {signature : Bytes}
    (covered : Covers records metadata intent signature) :
    authorized intent.transfer.signer intent := by
  obtain ⟨record, _recorded, _metadata, sameIntent, _signature⟩ := covered
  simpa only [sameIntent] using record.authorization

/-- Signature coverage projects to query coverage for the same key and signed bytes. -/
theorem Covers.queried (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) {records : List (Issued authorized)}
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop)
    {metadata : ProofMetadata} {intent : Intent Owner} {signature : Bytes}
    (covered : Covers records metadata intent signature) :
    (history codec keyFor records foreignQueries compromised).Queried
      (keyFor intent.transfer.signer) (Signing.message codec metadata intent) := by
  obtain ⟨record, recorded, sameMetadata, sameIntent, _sameSignature⟩ := covered
  simpa only [sameMetadata, sameIntent] using
    issued_queried codec keyFor foreignQueries compromised record recorded

theorem Covers.append_left {left right : List (Issued authorized)}
    {metadata : ProofMetadata} {intent : Intent Owner} {signature : Bytes}
    (covered : Covers left metadata intent signature) :
    Covers (left ++ right) metadata intent signature := by
  obtain ⟨record, recorded, sameMetadata, sameIntent, sameSignature⟩ := covered
  exact ⟨record, List.mem_append.mpr (Or.inl recorded), sameMetadata, sameIntent, sameSignature⟩

theorem Covers.append_right {left right : List (Issued authorized)}
    {metadata : ProofMetadata} {intent : Intent Owner} {signature : Bytes}
    (covered : Covers right metadata intent signature) :
    Covers (left ++ right) metadata intent signature := by
  obtain ⟨record, recorded, sameMetadata, sameIntent, sameSignature⟩ := covered
  exact ⟨record, List.mem_append.mpr (Or.inr recorded), sameMetadata, sameIntent, sameSignature⟩

/-- Adding typed issuances preserves every previously covered key/message query. -/
theorem queried_append (codec : Evidence.TransferCheck.PacketCodec Owner)
    (keyFor : Owner → Key) (left right : List (Issued authorized))
    (foreignQueries : List (Key × Bytes)) (compromised : Key → Prop)
    (key : Key) (message : Bytes)
    (queried : (history codec keyFor left foreignQueries compromised).Queried key message) :
    (history codec keyFor (left ++ right) foreignQueries compromised).Queried key message := by
  rcases (queried_iff codec keyFor left foreignQueries compromised key message).1 queried with
    typed | foreign
  · apply (queried_iff codec keyFor (left ++ right) foreignQueries compromised key message).2
    apply Or.inl
    rw [typedQueries_append]
    exact List.mem_append.mpr (Or.inl typed)
  · exact (queried_iff codec keyFor (left ++ right) foreignQueries compromised key message).2
      (Or.inr foreign)

end HomotopicalEncryption.Protocol.Transfer.Issuance
