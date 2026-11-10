module

public import Protocol.Storage.PublicView
public import Mathlib.Probability.ProbabilityMassFunction.Monad

@[expose] public section

/-!
# Uniform whole-bucket reads with local private selection

The first retrieval profile downloads the entire fixed public bucket. Its
request is the existing public manifest, including the complete directory;
there is no selected slot/digest field. The server's complete response is a
function of that public request and target-independent randomness. Selection,
answer authentication and private HCP recovery are local postprocessing.

This gives exact selector independence within the same fixed manifest/public
access scope, for arbitrary server behavior and any selected observation of
the complete request/response and shared tape. It does not hide which bucket
was requested, who communicated or when. Per-record authorization, targeted
retries, errors or a later public target-bearing action extend the transcript
and need separate privacy analysis. Responses may be malicious; authentication
and recovery correctness are separate from this selector-privacy result.

The honest reply returns every supplied slot/ciphertext pair, with linear
whole-bucket download cost. There is no sublinear PIR or recipient-discovery
claim and no adoption of an OMR cryptographic implementation.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.Retrieval.UniformRead

variable {Slot Target Coins Result View : Type*}

/-- Request the complete fixed public manifest/bucket; the target stays local. -/
def request (manifest : PublicManifestView Slot) (_target : Target) :
    PublicManifestView Slot := manifest

/-- The honest baseline transfers every slot/ciphertext pair, without filtering. -/
def honestReply (database : List (Slot × List UInt8)) (_request : PublicManifestView Slot) :
    List (Slot × List UInt8) := database

/-- All server-visible protocol data before local selection or decryption.
The server may choose arbitrary response bytes from the request and tape. -/
def transcript (manifest : PublicManifestView Slot)
    (server : PublicManifestView Slot → Coins → List (Slot × List UInt8))
    (target : Target) (coin : Coins) :
    PublicManifestView Slot × List (Slot × List UInt8) :=
  (request manifest target, server (request manifest target) coin)

/-- Run any local lookup, hash verification and recovery only after downloading.
The result is local state, separate from the request/response transcript. -/
def run (manifest : PublicManifestView Slot)
    (server : PublicManifestView Slot → Coins → List (Slot × List UInt8))
    (finish : Target → List (Slot × List UInt8) → Result) (target : Target) (coin : Coins) :
    (PublicManifestView Slot × List (Slot × List UInt8)) × Result :=
  let visible := transcript manifest server target coin
  (visible, finish target visible.2)

/-- An arbitrary observation of the complete request, response and shared tape.
The tape distribution must be the same for each target in the experiment. -/
def view (manifest : PublicManifestView Slot)
    (server : PublicManifestView Slot → Coins → List (Slot × List UInt8))
    (observe : (PublicManifestView Slot × List (Slot × List UInt8)) → Coins → View)
    (target : Target) (coin : Coins) : View :=
  observe (transcript manifest server target coin) coin

/-- The actual request sends the same full manifest for every local target. -/
theorem request_eq (manifest : PublicManifestView Slot) (left right : Target) :
    request manifest left = request manifest right := rfl

/-- Any server, including a malicious one, sees identical protocol transcripts
for two targets at the same public manifest and shared tape. -/
theorem transcript_eq (manifest : PublicManifestView Slot)
    (server : PublicManifestView Slot → Coins → List (Slot × List UInt8))
    (left right : Target) (coin : Coins) :
    transcript manifest server left coin = transcript manifest server right coin := rfl

/-- Private local outputs and failures cannot change this protocol's public
projection; no target-specific follow-up request belongs to this baseline. -/
theorem run_public_eq (manifest : PublicManifestView Slot)
    (server : PublicManifestView Slot → Coins → List (Slot × List UInt8))
    (finish : Target → List (Slot × List UInt8) → Result) (left right : Target) (coin : Coins) :
    (run manifest server finish left coin).1 = (run manifest server finish right coin).1 := rfl

/-- No postprocessing of the full public transcript/tape distinguishes targets. -/
theorem view_eq (manifest : PublicManifestView Slot)
    (server : PublicManifestView Slot → Coins → List (Slot × List UInt8))
    (observe : (PublicManifestView Slot × List (Slot × List UInt8)) → Coins → View)
    (left right : Target) (coin : Coins) :
    view manifest server observe left coin = view manifest server observe right coin := rfl

/-- The honest response transfers the exact whole supplied bucket. -/
theorem honestReply_eq (database : List (Slot × List UInt8)) (manifest : PublicManifestView Slot) :
    honestReply database manifest = database := rfl

/-- Honest response ciphertext volume is the sum of every ciphertext's byte length.
Slot labels and the public request/transport envelope add serialization overhead. -/
theorem honestReply_payloadBytes (database : List (Slot × List UInt8))
    (manifest : PublicManifestView Slot) :
    ((honestReply database manifest).map (fun entry => entry.2.length)).sum =
      (database.map (fun entry => entry.2.length)).sum := rfl

noncomputable section

/-- The full server-view distribution under one target-independent shared PMF. -/
def distribution (manifest : PublicManifestView Slot)
    (server : PublicManifestView Slot → Coins → List (Slot × List UInt8))
    (observe : (PublicManifestView Slot × List (Slot × List UInt8)) → Coins → View)
    (coins : PMF Coins) (target : Target) : PMF View :=
  PMF.bind coins (fun coin => PMF.pure (view manifest server observe target coin))

/-- Exact equality of complete observed distributions, with no cryptographic
assumption, efficiency assumption or independence between internal failures. -/
theorem distribution_eq (manifest : PublicManifestView Slot)
    (server : PublicManifestView Slot → Coins → List (Slot × List UInt8))
    (observe : (PublicManifestView Slot × List (Slot × List UInt8)) → Coins → View)
    (coins : PMF Coins) (left right : Target) :
    distribution manifest server observe coins left =
      distribution manifest server observe coins right := rfl

/-- Every server-observable event has exactly the same mass for both targets. -/
theorem event_probability_eq (manifest : PublicManifestView Slot)
    (server : PublicManifestView Slot → Coins → List (Slot × List UInt8))
    (observe : (PublicManifestView Slot × List (Slot × List UInt8)) → Coins → View)
    (coins : PMF Coins) (left right : Target) (event : Set View) :
    coins.toOuterMeasure {coin | view manifest server observe left coin ∈ event} =
      coins.toOuterMeasure {coin | view manifest server observe right coin ∈ event} := rfl

end

end HomotopicalEncryption.Protocol.Storage.Retrieval.UniformRead
