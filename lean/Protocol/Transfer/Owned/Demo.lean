module

public import Protocol.Transfer.Owned.Executable
meta import Protocol.Transfer.Owned.Executable
public import Protocol.Storage.Examples
meta import Protocol.Storage.Examples

@[expose] public section

/-!
# Running one bounded owned transfer

From `lean/` run `lake build Protocol.Transfer.Owned.Demo`, then
`lake env lean --run Protocol/Transfer/Owned/Demo.lean`. The fixture uses the
existing exact zero payload and canonical byte-owner packet codec. Its toy
hashes, deterministic authorization bytes, and payload verifier only test
the declared execution path. The manifest retains raw ciphertext bytes.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.Owned.Demo

open Evidence.TransferTranscript
open Ephemeral.ScopeCodec (encodeFixed)
open Ledger.OwnedResource
open Storage.Examples (interpretation sheaf zero_accepted zeroContext zeroPayload)

abbrev Bytes := List UInt8
abbrev fixtureHash := Storage.Examples.hash
open Executable (run resourceCheck)

def ownerBytes (owner : Fin 2) : Bytes := [UInt8.ofNat (owner.val + 1)]

def catalog : Ledger.OwnedResource.Catalog Bytes Unit where
  owner id := ownerBytes (Fixture.catalog.owner id)
  asset := Fixture.catalog.asset
  amount := Fixture.catalog.amount
  positive := Fixture.catalog.positive

def transfer : ResourceTransfer Bytes where
  input := Fixture.transfer.input
  output := Fixture.transfer.output
  signer := ownerBytes Fixture.transfer.signer

def initialMarking : Ledger.Marking ℕ where
  support := {0}
  toFun id := if id = 0 then 1 else 0
  mem_support_toFun id := by
    by_cases h : id = 0 <;> simp [h]

def before : Ledger.State ℕ ℕ where
  marking := initialMarking
  spent := ∅
  tipHash := fixtureHash 40
  height := 0
  epoch := 1
  snapshotRoot := fixtureHash 10
  topologyRoot := fixtureHash 41
  cochainRoot := fixtureHash 42
  evidenceRoot := fixtureHash 43

def metadata : ProofMetadata where
  schemaVersion := 1
  statementId := fixtureHash 44
  policyId := fixtureHash 45
  proofSystemId := fixtureHash 46
  verifierId := fixtureHash 47

def fixtureDigest (domain : UInt8) (bytes : Bytes) : TCB.Hash32 :=
  fun i => if i = 0 then domain else bytes.foldl (· + ·) 0

def directoryBytes (entry : Storage.CiphertextManifest.Slot × TCB.Hash32) : Bytes :=
  (match entry.1 with
    | .exactArtifact => 0
    | .fullCiphertext => 1) :: encodeFixed entry.2 []

def hashes : HashSuite Bytes where
  state content := fixtureHash (UInt8.ofNat (content.height + 60))
  cochain _ := fixtureHash 12
  ciphertext := fixtureDigest 61
  cochainRoot digests := fixtureDigest 62 (digests.flatMap (fun h => encodeFixed h []))
  manifest preimage := fixtureDigest 63
    (Evidence.TransferCodec.encodeBase preimage.1 (preimage.2.flatMap directoryBytes))
  intent intent := fixtureDigest 64 (Evidence.TransferCodec.encodeIntent intent [])
  evidence packet := fixtureDigest 65 (Evidence.TransferCodec.encode packet)
  block preimage := fixtureDigest 66 (Evidence.TransferCodec.encodeDraft preimage.draft
    (encodeFixed preimage.evidenceRoot
      (encodeFixed preimage.intentDigest (encodeFixed preimage.manifestRoot []))))

def signature (intent : Intent Bytes) : Bytes :=
  71 :: Evidence.TransferCodec.encodeIntent intent []

def authorization : Evidence.TransferVerifier.Authorization Bytes where
  Authorized owner _ := owner = ownerBytes Fixture.transfer.signer
  verify owner intent bytes :=
    decide (owner = ownerBytes Fixture.transfer.signer) && decide (bytes = signature intent)
  sound owner intent bytes accepted := by
    exact of_decide_eq_true (Bool.and_eq_true_iff.mp accepted).1

def proofBytes : Bytes := [72]

def payload : Evidence.TransferVerifier.PayloadVerifier interpretation Bytes metadata where
  proofSystem := {
    Completeness := True
    Soundness := True
    ZeroKnowledge := True
    StatementBinding := True
  }
  proofSystem_wellFormed := ⟨trivial, trivial, trivial, trivial⟩
  verify intent bytes := decide (bytes = proofBytes) &&
    decide (Evidence.TransferCodec.encodePayload intent.base.cochain [] =
      Evidence.TransferCodec.encodePayload zeroPayload [])
  sound context intent _ interpretation_eq base_eq accepted := by
    have encoded : Evidence.TransferCodec.encodePayload intent.base.cochain [] =
        Evidence.TransferCodec.encodePayload zeroPayload [] :=
      of_decide_eq_true (Bool.and_eq_true_iff.mp accepted).2
    have parsed := congrArg Evidence.TransferCodec.parsePayload encoded
    have payload_eq : intent.base.cochain = zeroPayload := by
      simpa only [Evidence.TransferCodec.parsePayload_encodePayload, Option.some.injEq,
        Prod.mk.injEq, and_true] using parsed
    have context_payload : context.cochain = zeroPayload :=
      (congrArg Storage.PublicPayloadView.cochain base_eq).symm.trans payload_eq
    unfold Storage.Context.Accepted
    rw [interpretation_eq, context_payload]
    exact zero_accepted

def codec : Evidence.TransferVerifier.PacketCodec Bytes where
  encode := Evidence.TransferCodec.encode
  decode := Evidence.TransferCodec.decode
  decode_encode := Evidence.TransferCodec.decode_encode

def config (state : Ledger.State ℕ ℕ) (topology : state.topologyRoot = fixtureHash 41) :
    Config sheaf Bytes Unit Unit where
  catalog := catalog
  context := zeroContext
  ciphertext := [3,8,13]
  before := state
  hashes := hashes
  metadata := metadata
  authorization := authorization
  payload := payload
  codec := codec
  topologyBinds _ root := root = fixtureHash 41
  topologyBound := topology
  persisted _ _ _ _ := True
  committeeDigest := fixtureHash 48
  round := 0
  phase := 0

def packet (cfg : Config sheaf Bytes Unit Unit) : ProofPacket Bytes :=
  let intent := Executable.intentFor cfg transfer
  ⟨cfg.metadata, intent, signature intent, proofBytes⟩

def wrongManifest (cfg : Config sheaf Bytes Unit Unit) : ProofPacket Bytes :=
  let original := packet cfg
  let altered := { original.intent with manifestRoot := fixtureHash 99 }
  { original with intent := altered, ownerSignature := signature altered }

def execute : IO Unit := do
  let base := config before rfl
  let good := packet base
  let bytes := codec.encode good
  match accepted : run base transfer bytes with
  | none => throw (IO.userError "The original canonical packet was rejected")
  | some updated =>
    let inputSpent := decide (0 ∈ updated.spent)
    unless updated.marking 0 == 0 && updated.marking 1 == 1 && inputSpent do
      throw (IO.userError "The accepted update did not move and consume the original resource")
    unless (run base transfer (codec.encode (wrongManifest base))).isNone do
      throw (IO.userError "The changed manifest root was accepted")
    let replayConfig := config updated (Executable.topologyRoot_of_run base transfer bytes _ accepted)
    unless (run replayConfig transfer bytes).isNone do
      throw (IO.userError "The original packet was accepted a second time")
    let replayBytes := codec.encode (packet replayConfig)
    unless !resourceCheck replayConfig.catalog transfer replayConfig.before &&
        (run replayConfig transfer replayBytes).isNone do
      throw (IO.userError "The spent input was accepted under a fresh packet draft")
    IO.println s!"Accepted canonical packet ({bytes.length} bytes)"
    IO.println s!"Resource 0: {base.before.marking 0} -> {updated.marking 0}"
    IO.println s!"Resource 1: {base.before.marking 1} -> {updated.marking 1}"
    IO.println s!"Amount: {base.catalog.amount 0} -> {base.catalog.amount 1}"
    IO.println s!"Input 0 spent: {inputSpent}"
    IO.println "Changed manifest rejected"
    IO.println "Original packet replay rejected"
    IO.println "Replay with a fresh draft rejected"

end HomotopicalEncryption.Protocol.Transfer.Owned.Demo

def main : IO Unit := HomotopicalEncryption.Protocol.Transfer.Owned.Demo.execute
