module

public import Protocol.Transfer.PathSignature.NativeRelation
public import Mathlib.Probability.ProbabilityMassFunction.Constructions
public import Mathlib.Data.Fintype.BigOperators
public import Mathlib.Data.Fintype.Prod
public import Mathlib.Data.Int.NatAbs

@[expose] public section

/-!
# Uniform finite seeds for the bounded native family

A seed contains two matrices, message and opening coordinates in a fixed
finite interval, and a fixed-length byte salt. Decoding constructs the actual
existing native witness. Every seed satisfies its selected bounds, so the
sampler supplies an honest challenge without a separate validity premise.

The seed PMF assigns the same inverse-cardinality mass to each finite seed;
the witness distribution is its explicit pushforward. The combined tape
samples that seed and an arbitrary fixed cryptographic-tape PMF by a constant
conditional law, with both marginals proved below. It can be used with the
full-ciphertext experiment via `challenge`.

This family includes degenerate matrices and zero messages/noise. Uniform
sampling and the seed-cardinality formula establish neither hardness nor
confidentiality, and no such claim is made for every selected profile.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSampler

open scoped BigOperators ENNReal

/-- A centered integer coordinate is selected from exactly `2 * bound + 1`
natural indices, retaining both endpoints after signed decoding. -/
abbrev Coordinate (bound : ℕ) := Fin (2 * bound + 1)

/-- Actual finite source/target matrices, message, exact/coexact openings and
byte salt, represented by the product of their finite coordinate spaces. -/
abbrev Seed (rows cols : ℕ) (profile : NativeRelation.Profile) :=
  (Fin rows → Fin cols → Coordinate profile.bound) ×
    (Fin rows → Fin cols → Coordinate profile.bound) ×
    (Fin cols → Coordinate profile.bound) ×
    Coordinate profile.bound ×
    (Fin rows → Coordinate profile.bound) ×
    (Fin profile.saltBytes → Fin 256)

def signed (bound : ℕ) (coordinate : Coordinate bound) : ℤ :=
  (coordinate.val : ℤ) - (bound : ℤ)

theorem signed_bounded (bound : ℕ) (coordinate : Coordinate bound) :
    (signed bound coordinate).natAbs ≤ bound := by
  unfold signed
  by_cases large : bound ≤ coordinate.val
  · rw [Int.natAbs_natCast_sub_natCast_of_ge large]
    have range := coordinate.isLt
    omega
  · have small : coordinate.val ≤ bound := by omega
    rw [Int.natAbs_natCast_sub_natCast_of_le small]
    omega

theorem signed_injective (bound : ℕ) : Function.Injective (signed bound) := by
  intro first second same
  apply Fin.ext
  unfold signed at same
  omega

def zeroCoordinate (bound : ℕ) : Coordinate bound := ⟨0, by omega⟩

def zeroSeed (rows cols : ℕ) (profile : NativeRelation.Profile) : Seed rows cols profile :=
  ⟨(fun _ _ => zeroCoordinate profile.bound),
    (fun _ _ => zeroCoordinate profile.bound),
    (fun _ => zeroCoordinate profile.bound),
    zeroCoordinate profile.bound,
    (fun _ => zeroCoordinate profile.bound),
    (fun _ => ⟨0, by decide⟩)⟩

instance (rows cols : ℕ) (profile : NativeRelation.Profile) :
    Nonempty (Seed rows cols profile) := ⟨zeroSeed rows cols profile⟩

/-- The finite seed constructs the existing native witness directly. -/
def decodeSeed {rows cols : ℕ} {profile : NativeRelation.Profile}
    (seed : Seed rows cols profile) : NativeRelation.Witness rows cols where
  source row col := signed profile.bound (seed.1 row col)
  target row col := signed profile.bound (seed.2.1 row col)
  z col := signed profile.bound (seed.2.2.1 col)
  a := signed profile.bound seed.2.2.2.1
  u row := signed profile.bound (seed.2.2.2.2.1 row)
  salt := List.ofFn fun index : Fin profile.saltBytes =>
    UInt8.ofNat (seed.2.2.2.2.2 index).val

/-- Every possible seed is valid for this same original native profile. -/
theorem decodeSeed_bounded {rows cols : ℕ} {profile : NativeRelation.Profile}
    (seed : Seed rows cols profile) : NativeRelation.Bounded profile (decodeSeed seed) := by
  refine ⟨fun row col => signed_bounded profile.bound (seed.1 row col),
    fun row col => signed_bounded profile.bound (seed.2.1 row col),
    fun col => signed_bounded profile.bound (seed.2.2.1 col),
    signed_bounded profile.bound seed.2.2.2.1,
    fun row => signed_bounded profile.bound (seed.2.2.2.2.1 row), ?_⟩
  simp [decodeSeed]

/-- No two finite seeds collapse to the same native witness. This concerns
the private coordinate representation, not the hash-derived public key. -/
theorem decodeSeed_injective (rows cols : ℕ) (profile : NativeRelation.Profile) :
    Function.Injective (@decodeSeed rows cols profile) := by
  intro first second same
  refine Prod.ext ?_ (Prod.ext ?_ (Prod.ext ?_ (Prod.ext ?_ (Prod.ext ?_ ?_))))
  · funext row col
    exact signed_injective profile.bound
      (congrArg (fun witness : NativeRelation.Witness rows cols => witness.source row col) same)
  · funext row col
    exact signed_injective profile.bound
      (congrArg (fun witness : NativeRelation.Witness rows cols => witness.target row col) same)
  · funext col
    exact signed_injective profile.bound
      (congrArg (fun witness : NativeRelation.Witness rows cols => witness.z col) same)
  · exact signed_injective profile.bound (congrArg NativeRelation.Witness.a same)
  · funext row
    exact signed_injective profile.bound
      (congrArg (fun witness : NativeRelation.Witness rows cols => witness.u row) same)
  · have saltEqual :
        List.ofFn (fun index : Fin profile.saltBytes => UInt8.ofNat (first.2.2.2.2.2 index).val) =
          List.ofFn (fun index : Fin profile.saltBytes => UInt8.ofNat (second.2.2.2.2.2 index).val) :=
      congrArg NativeRelation.Witness.salt same
    have functionsEqual := List.ofFn_injective saltEqual
    funext index
    apply Fin.ext
    have valueEqual := congrArg UInt8.toNat (congrFun functionsEqual index)
    simpa only [UInt8.toNat_ofNat_of_lt' (first.2.2.2.2.2 index).isLt,
      UInt8.toNat_ofNat_of_lt' (second.2.2.2.2.2 index).isLt] using valueEqual

/-- Cardinality is asserted for the seed product. Hash-derived public keys
need not retain this cardinality or the private sampler's uniformity. -/
theorem card_seed (rows cols : ℕ) (profile : NativeRelation.Profile) :
    Fintype.card (Seed rows cols profile) =
      (2 * profile.bound + 1) ^ (2 * rows * cols + cols + rows + 1) *
        256 ^ profile.saltBytes := by
  classical
  simp only [Seed, Coordinate, Fintype.card_prod, Fintype.card_fun, Fintype.card_fin,
    ← pow_mul]
  calc
    _ = (((((2 * profile.bound + 1) ^ (cols * rows) *
          (2 * profile.bound + 1) ^ (cols * rows)) *
          (2 * profile.bound + 1) ^ cols) * (2 * profile.bound + 1) ^ 1) *
          (2 * profile.bound + 1) ^ rows) * 256 ^ profile.saltBytes := by
      simp only [pow_one]
      ac_rfl
    _ = (2 * profile.bound + 1) ^ (cols * rows + cols * rows + cols + 1 + rows) *
        256 ^ profile.saltBytes := by
      rw [← pow_add, ← pow_add, ← pow_add, ← pow_add]
    _ = _ := congrArg (fun exponent => (2 * profile.bound + 1) ^ exponent * 256 ^ profile.saltBytes)
      (by ring)

noncomputable section

/-- Actual uniform finite-seed law using the current `PMF.ofFintype` API. -/
def uniformSeed (rows cols : ℕ) (profile : NativeRelation.Profile) : PMF (Seed rows cols profile) :=
  PMF.ofFintype (fun _ => (Fintype.card (Seed rows cols profile) : ℝ≥0∞)⁻¹) (by
    classical
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    exact ENNReal.mul_inv_cancel (by simp)
      (ENNReal.natCast_ne_top (Fintype.card (Seed rows cols profile))))

@[simp] theorem uniformSeed_apply (rows cols : ℕ) (profile : NativeRelation.Profile)
    (seed : Seed rows cols profile) :
    uniformSeed rows cols profile seed = (Fintype.card (Seed rows cols profile) : ℝ≥0∞)⁻¹ := rfl

theorem seed_mem_support (rows cols : ℕ) (profile : NativeRelation.Profile)
    (seed : Seed rows cols profile) : seed ∈ (uniformSeed rows cols profile).support := by
  rw [PMF.mem_support_iff, uniformSeed_apply]
  exact ENNReal.inv_ne_zero.mpr
    (ENNReal.natCast_ne_top (Fintype.card (Seed rows cols profile)))

def witnessDistribution (rows cols : ℕ) (profile : NativeRelation.Profile) :
    PMF (NativeRelation.Witness rows cols) :=
  (uniformSeed rows cols profile).map decodeSeed

/-- Every sampled private witness has exactly its unique seed's uniform mass. -/
theorem witnessDistribution_apply (rows cols : ℕ) (profile : NativeRelation.Profile)
    (seed : Seed rows cols profile) :
    witnessDistribution rows cols profile (decodeSeed seed) =
      (Fintype.card (Seed rows cols profile) : ℝ≥0∞)⁻¹ := by
  classical
  rw [witnessDistribution, PMF.map_apply]
  simp only [(decodeSeed_injective rows cols profile).eq_iff, uniformSeed_apply]
  simp

theorem support_bounded (rows cols : ℕ) (profile : NativeRelation.Profile)
    (witness : NativeRelation.Witness rows cols)
    (member : witness ∈ (witnessDistribution rows cols profile).support) :
    NativeRelation.Bounded profile witness := by
  obtain ⟨seed, _member, same⟩ :=
    (PMF.mem_support_map_iff decodeSeed (uniformSeed rows cols profile) witness).1 member
  rw [← same]
  exact decodeSeed_bounded seed

/-- The crypto-tape law is fixed independently of the sampled native seed. -/
def coins {Tape : Type} (rows cols : ℕ) (profile : NativeRelation.Profile) (tape : PMF Tape) :
    PMF (Seed rows cols profile × Tape) :=
  (uniformSeed rows cols profile).bind fun seed => tape.map fun crypto => (seed, crypto)

theorem coins_fst {Tape : Type} (rows cols : ℕ) (profile : NativeRelation.Profile) (tape : PMF Tape) :
    (coins rows cols profile tape).map Prod.fst = uniformSeed rows cols profile := by
  rw [coins, PMF.map_bind]
  have projected (seed : Seed rows cols profile) :
      (tape.map (fun crypto => (seed, crypto))).map Prod.fst = PMF.pure seed := by
    rw [PMF.map_comp]
    change tape.map (Function.const Tape seed) = PMF.pure seed
    exact PMF.map_const tape seed
  simp_rw [projected]
  exact PMF.bind_pure _

theorem coins_snd {Tape : Type} (rows cols : ℕ) (profile : NativeRelation.Profile) (tape : PMF Tape) :
    (coins rows cols profile tape).map Prod.snd = tape := by
  rw [coins, PMF.map_bind]
  have projected (seed : Seed rows cols profile) :
      (tape.map (fun crypto => (seed, crypto))).map Prod.snd = tape := by
    rw [PMF.map_comp]
    change tape.map id = tape
    exact PMF.map_id tape
  simp_rw [projected]
  exact PMF.bind_const _ _

/-- The actual bounded challenge function for a native/crypto product tape. -/
def challenge {rows cols : ℕ} {profile : NativeRelation.Profile} {Tape : Type}
    (coin : Seed rows cols profile × Tape) : NativeRelation.Witness rows cols :=
  decodeSeed coin.1

theorem challenge_bounded {rows cols : ℕ} {profile : NativeRelation.Profile} {Tape : Type}
    (coin : Seed rows cols profile × Tape) : NativeRelation.Bounded profile (challenge coin) :=
  decodeSeed_bounded coin.1

/-- In particular every sampled challenge belongs to the bounded native family. -/
theorem sampled_challenge_bounded {Tape : Type} (rows cols : ℕ)
    (profile : NativeRelation.Profile) (tape : PMF Tape)
    (coin : Seed rows cols profile × Tape)
    (_member : coin ∈ (coins rows cols profile tape).support) :
    NativeRelation.Bounded profile (challenge coin) := challenge_bounded coin

end
end HomotopicalEncryption.Protocol.Transfer.PathSignature.NativeSampler
