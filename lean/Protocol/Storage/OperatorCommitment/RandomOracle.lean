module

public import Protocol.Storage.OperatorCommitment
public import VCVio.OracleComp.Constructions.SampleableType.Measure
public import VCVio.OracleComp.EvalDist.Measure
public import VCVio.OracleComp.QueryTracking.RandomOracle.HiddenSeed

@[expose] public section

/-!
# Canonical operator commitments in the bounded-query random-oracle model

The secret encoding uses the existing operator packet, its original 32-byte
nonce, and the exact canonical commitment preimage. Public queries range over
all byte strings and share one lazy random-oracle cache; deriving a commitment
reads that same cache at its encoded opening. The ideal construction instead
uses a separate derivation table, independent of the public byte oracle.

A uniform nonce seed makes any fixed byte string an encoded opening with
probability at most `1 / 256^32`. The hidden-seed theorem then bounds any
adaptive, publicly query-bounded event by its ideal probability plus that
nonce-guessing term. The bound counts all public byte-oracle queries, while
uniform sampling and private derivation queries are uncharged.

This is a statement about sampled random oracles and explicitly bounded
oracle programs. It does not assert hiding for an arbitrary fixed hash, a
concrete hash implementation, an unbounded decoder, or an additional public
protocol transcript. No finite restriction on the original packet type is
introduced.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.OperatorCommitment.RandomOracle

open OracleSpec OracleComp
open scoped ENNReal

abbrev Bytes := CoupledCodec.Bytes
abbrev Packet := CoupledCodec.Packet

/-- Reuse the finite seed of the original private 32-byte nonce. -/
abbrev Seed := OperatorCommitment.NonceSeed

abbrev nonceOfSeed := OperatorCommitment.nonceOfSeed

theorem nonceOfSeed_injective : Function.Injective nonceOfSeed :=
  OperatorCommitment.nonceOfSeed_injective

theorem card_seed : Fintype.card Seed = 256 ^ 32 :=
  OperatorCommitment.card_nonceSeed

/-- One byte-addressed random oracle for the entire public hash namespace. -/
abbrev publicOracle : OracleSpec Bytes := fun _ => TCB.Hash32

/-- The exact existing packet/nonce preimage, without a new geometry carrier. -/
def encoding : SecretEncoding publicOracle Seed Packet TCB.Hash32 where
  enc seed packet := OperatorCommitment.encode (packet, nonceOfSeed seed)
  range_eq _ _ := rfl
  injective _ := by
    intro first second same
    exact congrArg Prod.fst (OperatorCommitment.encode_injective same)

theorem encoding_eq (seed : Seed) (packet : Packet) :
    encoding.enc seed packet = OperatorCommitment.encode (packet, nonceOfSeed seed) := rfl

/-- A fixed byte address can contain an opening for at most one nonce seed. -/
theorem seed_eq_of_encoded_eq {first second : Seed} {firstPacket secondPacket : Packet}
    (same : encoding.enc first firstPacket = encoding.enc second secondPacket) :
    first = second := by
  apply nonceOfSeed_injective
  exact congrArg Prod.snd (OperatorCommitment.encode_injective same)

/-- Uniform private nonces hit any fixed public byte address with probability
at most the reciprocal of the full 32-byte seed space. -/
theorem hit_probability_le (bytes : Bytes) :
    Pr{let seed ← $ᵗ Seed}[bytes ∈ Set.range (encoding.enc seed)] ≤
      ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
  classical
  by_cases hit : ∃ seed : Seed, bytes ∈ Set.range (encoding.enc seed)
  · obtain ⟨seed, packet, encoded⟩ := hit
    calc
      Pr{let other ← $ᵗ Seed}[bytes ∈ Set.range (encoding.enc other)] ≤
          Pr{let other ← $ᵗ Seed}[other = seed] := by
            apply prEvent_mono
            intro other member
            obtain ⟨otherPacket, otherEncoded⟩ := member
            exact seed_eq_of_encoded_eq (otherEncoded.trans encoded.symm)
      _ = ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
        rw [SampleableType.prEvent_uniformSample_eq_singleton, card_seed]
  · have zero : Pr{let seed ← $ᵗ Seed}[bytes ∈ Set.range (encoding.enc seed)] = 0 := by
      apply (prEvent_eq_zero_iff _ _).2
      intro seed _ member
      exact hit ⟨seed, member⟩
    rw [zero]
    exact bot_le

/-- Charge every public byte-oracle query, including queries in other hash
domains. Uniform draws and private commitment derivations are free. -/
def publicQuery : (publicOracle.withDerivations Packet TCB.Hash32).Domain → Prop
  | .inl (.inr _) => True
  | _ => False

instance : DecidablePred publicQuery := fun
  | .inl (.inl _) => isFalse id
  | .inl (.inr _) => isTrue trivial
  | .inr _ => isFalse id

/-- Real event probability: the original canonical opening is read through
the same random-oracle cache used by every public byte query. -/
noncomputable def realProbability {α : Type}
    (program : OracleComp (publicOracle.withDerivations Packet TCB.Hash32) α)
    (event : α → Prop) : ℝ≥0∞ :=
  Pr{
    let seed ← $ᵗ Seed
    let result ← (simulateQ (encoding.realImpl seed) program).run ∅}[event result.1]

/-- Ideal event probability: private derivations use an independent table;
the public oracle still answers every public byte query consistently. -/
noncomputable def idealProbability {α : Type}
    (program : OracleComp (publicOracle.withDerivations Packet TCB.Hash32) α)
    (event : α → Prop) : ℝ≥0∞ :=
  Pr{let result ←
    (simulateQ (SecretEncoding.idealImpl publicOracle Packet TCB.Hash32) program).run
      (∅, ∅)}[event result.1]

/-- The actual canonical operator commitment incurs at most one nonce-guess
term per public byte-oracle query, for any adaptive bounded program. -/
theorem event_probability_le {α : Type}
    {program : OracleComp (publicOracle.withDerivations Packet TCB.Hash32) α} {q : ℕ}
    (bound : IsQueryBoundP program publicQuery q) (event : α → Prop) :
    realProbability program event ≤ idealProbability program event +
      (q : ℝ≥0∞) * ((256 ^ 32 : ℕ) : ℝ≥0∞)⁻¹ := by
  have comparison := encoding.prEvent_realImpl_le_add_mul
    (ms := ($ᵗ Seed)) hit_probability_le (p := publicQuery)
    (fun _ _ => trivial) bound (fun _ result => event result.1)
  simpa only [realProbability, idealProbability, Functor.map_map, map_bind,
    OracleComp.prEvent_bind_const] using comparison

end HomotopicalEncryption.Protocol.Storage.OperatorCommitment.RandomOracle
