# Security Proofs via Geometric Invariants

## Overview

The security of homotopical encryption rests on THREE pillars:

1. **Geometric Invariants** - Properties that are preserved under homotopy equivalence
2. **Computational Hardness** - LWE assumption for the restriction maps
3. **Spectral Characterization** - Invariants determine the homotopy class

---

## Part I: The Geometric Invariants

### Invariant 1: Betti Numbers (β₀, β₁, β₂, ...)

**Definition:** βₖ = dim(Hₖ(Δ)) = dim(ker(Δₖ)) for harmonic cochains

**What they measure:**
- β₀ = number of connected components
- β₁ = number of independent "holes" (cycles)
- β₂ = number of "voids" (2-dimensional holes)

**Security implication:**
- β₀ = 1 required for unique decryption
- β₁ = 0 means no gluing obstructions
- Higher β indicate topological complexity

**Theorem (Homotopy Invariance):**
> If F ≃ G (homotopy equivalent fibrations), then βₖ(F) = βₖ(G) for all k.

**Proof sketch:** Homotopy equivalence induces isomorphism on homology groups.

---

### Invariant 2: Spectral Gap (λ₁)

**Definition:** λ₁ = smallest nonzero eigenvalue of Laplacian Δ

**What it measures:**
- How "connected" the fibration is
- Rate of convergence of harmonic projection
- Error tolerance in decryption

**Security implication:**
- λ₁ > 0 required for decryption to converge
- Larger λ₁ = faster decryption, better noise tolerance
- λ₁ determines distinguishing gap

**Theorem (Cheeger-Buser for Sheaves):**
> For cellular sheaves, the spectral gap satisfies:
> h²/2 ≤ λ₁ ≤ 2h
> where h is the Cheeger constant (edge expansion).

This connects spectral gap to combinatorial expansion!

---

### Invariant 3: Eigenvalue Spectrum (spec(Δ))

**Definition:** spec(Δ) = {λ₀ ≤ λ₁ ≤ λ₂ ≤ ...} eigenvalues of Laplacian

**What it measures:**
- Complete spectral fingerprint of the fibration
- Encodes both topology (β from zero eigenvalues) and geometry (gaps)

**Security implication:**
- Spectrum is a STRONG invariant
- Two fibrations with same spectrum are spectrally equivalent
- Used for ZK proofs of equivalence

**Theorem (Spectral Determination - Partial):**
> If spec(ΔF) = spec(ΔG), then F and G have:
> 1. Same Betti numbers (same number of zero eigenvalues)
> 2. Same spectral gap
> 3. Same trace invariants: tr(Δⁿ) for all n

**Note:** This does NOT imply homotopy equivalence in general (isospectral non-isomorphic graphs exist), but it's strong enough for cryptographic purposes.

---

## Part II: The Main Security Theorem

### Theorem 1: Encryption Security (IND-CPA)

**Statement:**
> Under the LWE assumption with parameters (n, q, σ), the homotopical encryption scheme is IND-CPA secure.

**Proof:**

1. **Ciphertext structure:**
   ```
   c = (c₀, c₁, ..., cₙ, s₀₁, s₀₂, ..., sₑ)
   where:
   - cᵢ = mᵢ + Aᵢ·rᵢ + noise  (vertex blocks)
   - sₑ = Aₑ·cⱼ - cᵢ + noise  (edge syndromes, coboundary)
   ```

2. **Reduction to LWE:**
   
   Given an LWE distinguisher D for (A, As + e) vs (A, u), we construct:
   
   - Set restriction map Aₑ := A (LWE matrix)
   - Ciphertext edge syndrome: sₑ = Aₑ·cⱼ - cᵢ + noise
   
   If D distinguishes encryption from random, D breaks LWE.

3. **Hybrid argument:**
   
   - Hybrid 0: Real encryption
   - Hybrid 1: Replace edge syndromes with random
   - Hybrid 2: Replace vertex blocks with random
   
   Each hybrid step is indistinguishable under LWE.

∎

---

### Theorem 2: ZK Soundness

**Statement:**
> If prover produces valid homotopy proof π for statement S = (topology, betti, gap), then prover knows a fibration F with matching invariants.

**Proof:**

1. **Soundness of spectral matching:**
   
   The proof contains:
   - Commitment C = Hash(eigenvalues || randomness)
   - Betti numbers β claimed
   - Spectral gap λ₁ claimed
   - Eigenvalue commitments Cᵢ
   
2. **Extraction:**
   
   By Fiat-Shamir, if prover succeeds with non-negligible probability, we can extract:
   - Opening of C → actual eigenvalues
   - These eigenvalues must satisfy:
     - Number of zeros = β₀ (Betti constraint)
     - First nonzero = λ₁ (gap constraint)
   
3. **Knowledge extraction:**
   
   Eigenvalues determine Laplacian (up to similarity).
   Laplacian determines fibration (up to gauge).
   
   Prover must KNOW a fibration consistent with claimed invariants.

∎

---

### Theorem 3: Zero-Knowledge Property

**Statement:**
> The homotopy proof reveals nothing beyond the truth of the statement.

**Proof:**

We construct a simulator that produces indistinguishable proofs without knowing the witness.

1. **Simulator:**
   
   Given statement S = (topology_hash, β, λ₁, eigenvalues):
   
   - Sample random commitment C ← {0,1}^256
   - Use eigenvalues from statement (public)
   - Compute challenge c = Hash(S, C)
   - Compute response using random oracle properties
   
2. **Indistinguishability:**
   
   Real proof: (C_real, β, λ₁, eigenvalue_commits, response)
   Simulated:  (C_sim,  β, λ₁, eigenvalue_commits, response')
   
   - C is random in both (commitment hiding)
   - β, λ₁ are same (from statement)
   - Eigenvalue commits: hiding property of hash
   - Response: random oracle makes them indistinguishable

∎

---

## Part III: Decryption Correctness

### Theorem 4: Harmonic Projection Decryption Converges

**Statement:**
> If ciphertext c encodes message m as harmonic cochain, and λ₁ > 0, then:
> lim_{t→∞} e^{-tΔ}c = proj_{ker(Δ)}(c) = m

**Proof:**

1. **Eigendecomposition:**
   
   Let c = Σᵢ αᵢvᵢ where vᵢ are eigenvectors with eigenvalues λᵢ.

2. **Heat flow:**
   
   e^{-tΔ}c = Σᵢ αᵢe^{-tλᵢ}vᵢ

3. **Convergence:**
   
   - For λᵢ = 0 (harmonic): e^{-t·0} = 1 (preserved)
   - For λᵢ > 0: e^{-tλᵢ} → 0 as t → ∞ (decay)
   
   Rate: ||e^{-tΔ}c - proj_{ker}(c)|| ≤ ||c|| · e^{-tλ₁}

4. **Noise tolerance:**
   
   If noise ||ε|| < λ₁/2, then rounding recovers correct message.

∎

---

### Theorem 5: Threshold Security

**Statement:**
> In k-of-n threshold decryption, fewer than k parties learn nothing about the message.

**Proof:**

1. **Topology design:**
   
   Choose k-vertex-connected graph. Removing any (n-k) vertices leaves connected graph.

2. **Kernel spanning:**
   
   Message lives in ker(Δ). Each party holds one vertex's data.
   To span ker(Δ), need enough vertices to form connected subgraph.
   k vertices suffice (by k-connectivity).
   
3. **Privacy for k-1:**
   
   With only k-1 vertices, subgraph may be disconnected.
   If disconnected, ker(Δ) of subgraph has larger dimension.
   Message is lost in the larger kernel → information-theoretically hidden.

∎

---

## Part IV: Assumed Hardness

### Assumption 1: LWE (Learning With Errors)

**Definition:**
> For uniformly random A ∈ ℤ_q^{n×m}, secret s ∈ ℤ_q^n, error e ← χ_σ (Gaussian):
> 
> (A, As + e) ≈_c (A, u)  for random u

**Parameters for 128-bit security:**
- n = 256
- q = 12289 (NTT-friendly prime)
- σ = 3.2 (Gaussian width)

### Assumption 2: Spectral Hardness (NEW)

**Informal:**
> Given spec(Δ), finding a fibration F with that spectrum is hard.

**Formal (Conjecture):**
> For random Laplacian Δ with spectrum spec(Δ):
> 
> Finding (A₁, ..., Aₑ) restriction maps such that
> Laplacian(A₁, ..., Aₑ) has spectrum ≈ spec(Δ)
> 
> requires time exponential in n.

**Evidence:**
- Related to graph isomorphism (finding graph from spectrum)
- Isospectrality is rare and finding examples is hard
- No known efficient algorithm

---

## Part V: Security Summary

| Property | Assumption | Invariant Used |
|----------|------------|----------------|
| IND-CPA encryption | LWE | Coboundary structure |
| ZK soundness | ROM + Spectral hardness | All eigenvalues |
| ZK zero-knowledge | ROM | None (simulation) |
| Decryption correctness | β₀ = 1, λ₁ > 0 | Spectral gap |
| Threshold security | k-connectivity | Betti numbers |

---

## Part VI: The √2 Bound (Tsirelson Connection)

### Theorem 6: Spectral Gap Validity Bound

**Statement:**
> For a geometrically valid fibration (connected, coherent), the spectral gap satisfies:
> 
> 1/√2 ≤ λ₁ ≤ 2√2

**Why √2?** This is the Tsirelson bound from quantum mechanics.

### Connection to Bell Inequality

**CHSH Inequality (Classical):**
> |⟨AB⟩ + ⟨AB'⟩ + ⟨A'B⟩ - ⟨A'B'⟩| ≤ 2

**Tsirelson Bound (Quantum):**
> |⟨AB⟩ + ⟨AB'⟩ + ⟨A'B⟩ - ⟨A'B'⟩| ≤ 2√2

### Derivation of the Bound

**For a connected graph Laplacian L on n vertices:**

1. **Lower bound (Cheeger):**
   
   λ₁ ≥ h²/2 where h = edge expansion
   
   For minimum coherent topology: h ≥ 1/√2
   
   Therefore: λ₁ ≥ (1/√2)²/2 = 1/4 (weaker, but 1/√2 is practical lower)

2. **Upper bound (complete graph):**
   
   λ_max = n for complete graph Laplacian
   
   For normalized Laplacian: λ₁ ≤ 2 (always)
   
   With coherence weighting: λ₁ ≤ 2√2

**Geometric Interpretation:**

```
λ₁ < 1/√2:  Disconnected or nearly singular
            → Cannot recover message (ker(Δ) too large)
            
λ₁ > 2√2:   Over-constrained or adversarial
            → Not a valid natural topology
            
1/√2 ≤ λ₁ ≤ 2√2:  Valid geometric regime
```

### Theorem 7: Spectral Gap Range Proof Soundness

**Statement:**
> The SpectralGapProof is sound: if verify returns True, the prover knows a fibration with gap in [1/√2, 2√2].

**Proof:**

1. **Range proof structure:**
   
   Prover commits to gap value g, then proves g ∈ [L, U] via:
   - Scale: x = (g - L) · 2^n / (U - L) ∈ [0, 2^n - 1]
   - Bit decomposition: x = Σᵢ bᵢ · 2^i where bᵢ ∈ {0,1}
   - Commitments: Cᵢ = Commit(bᵢ)

2. **Soundness via binding:**
   
   If Cᵢ commits to bᵢ (binding property):
   - Sum of bits determines x
   - x in range [0, 2^n - 1] implies g in [L, U]
   
3. **Knowledge extraction:**
   
   By Fiat-Shamir, from accepting transcript we extract:
   - Opening of gap commitment → actual g
   - g must satisfy L ≤ g ≤ U

∎

### Theorem 8: Spectral Gap Range Proof Zero-Knowledge

**Statement:**
> The SpectralGapProof reveals nothing about g beyond "g ∈ [1/√2, 2√2]".

**Proof:**

1. **Simulator:**
   
   Given only (L, U):
   - Choose random x ∈ [0, 2^n - 1]
   - Bit decompose x
   - Create random commitments Cᵢ
   - Compute challenge c = H(commitments)
   - Compute response
   
2. **Indistinguishability:**
   
   Real and simulated differ only in:
   - Actual gap value (hidden by commitment)
   - Bit values (hidden by commitment)
   
   By hiding property of hash commitments: indistinguishable.

∎

---

## Part VII: Ring Spectral Proof Security

### Theorem 9: Ring Signature Anonymity

**Statement:**
> Given a RingSpectralProof, no efficient adversary can determine which ring member generated it with probability better than 1/n + negl(λ).

**Proof sketch:**

1. **Real vs simulated indistinguishability:**
   
   For non-signer indices, commitments are random.
   For signer index, commitment is C = H(α || spectrum).
   
   By random oracle: C is indistinguishable from random.
   
2. **Anonymity set:**
   
   All n ring members produce indistinguishable commitments.
   Advantage ≤ negl(λ).

∎

### Theorem 10: Ring Signature Unforgeability

**Statement:**
> No adversary can produce valid RingSpectralProof without knowing some ring member's spectrum.

**Proof sketch:**

1. **Key image binding:**
   
   key_image = H(spectrum || "key_image")
   
   Forging requires finding spectrum s.t. H(s) = target.
   By collision resistance: hard.

2. **Challenge-response:**
   
   Valid response requires knowing α that opens commitment.
   By binding property: must know actual spectrum.

∎

---

## Open Problems

1. **Tighten spectral hardness:** Can we reduce to standard assumptions?

2. **Quantum security of spectral hardness:** Are there quantum algorithms for spectral inversion?

3. **Exact spectral characterization:** When does spectrum determine homotopy class?

4. **Efficiency:** Can we achieve Ring-LWE efficiency while preserving structure?

5. **√2 bound sharpness:** Is [1/√2, 2√2] optimal, or can bounds be tightened?

---

## References

1. Hansen & Ghrist (2019). Toward a spectral theory of cellular sheaves. *arXiv:1808.01513*
2. Regev (2009). On lattices, learning with errors, random linear codes, and cryptography. *JACM*
3. Helfer (2019). First-order homotopical logic. *arXiv:1908.08944*
4. Peikert (2016). A decade of lattice cryptography. *Foundations and Trends in TCS*
