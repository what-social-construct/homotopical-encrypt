# Geometry: Homotopy Equivalence and the Diagonal Construction

## Grothendieck Fibrations (from Helfer)

A Grothendieck fibration p: E → B is a functor where:
- E := total category (all fibration credentials)
- B := base category (the Čech nerve / topology)
- p⁻¹(b) := fiber over b (all credentials with that topology)

Two fibrations F, G over the same base are homotopy equivalent (F ≃ G) if
there exist natural transformations η: F ⇒ G and ε: G ⇒ F with
ε ∘ η ≃ id_F and η ∘ ε ≃ id_G.

This is the anonymity relation: F ≃ G means they are cryptographically
indistinguishable. The path η witnesses the equivalence, but we never
reveal it — only that it exists.

## The Diagonal Construction

In HoTT, equality a = b IS the path space Path(a, b). The identity type
Id_A(a, b) is constructed as a pullback over the diagonal Δ: A → A × A:

```
           Path(F, G)
              │
              │  π (forgets the path)
              ▼
    {point} ────→ Fib × Fib
       (F,G)     (pair of fibrations)
              │
              │  spectral fingerprint
              ▼
         Spec ────→ Spec × Spec
              Δ
```

Path(F, G) non-empty ⟺ F = G in the homotopical sense.

The ZK proof structure follows directly:
1. Public statement = (Spec_F, Spec_G) ∈ Spec × Spec
2. Witness = element of Path(F, G)
3. Verification = check (Spec_F, Spec_G) lies on the diagonal image
4. If Spec_F = Spec_G, then by spectral determination, Path(F, G) ≠ ∅

Why the diagonal matters:
- Δ(Spec) = (Spec, Spec) represents reflexivity (F ≃ F)
- points on the diagonal = potentially equivalent fibrations
- points OFF diagonal = definitely non-equivalent
- ZK proof = prove you're on the diagonal without revealing WHERE

## The Helfer Logic Table

The correspondence between first-order homotopical logic and our
cryptographic constructions:

| Logic | HoTT | Fibration | Crypto |
|-------|------|-----------|--------|
| True | Unit | terminal fibration | valid signature |
| False | Empty | initial fibration | reject |
| A ∧ B | A × B | product fibration | AND of conditions |
| A ∨ B | A + B | coproduct fibration | OR of conditions |
| A → B | A → B | exponential | implication / witness |
| ∃x.P(x) | Σ-type | dependent sum | encryption (hiding) |
| ∀x.P(x) | Π-type | dependent product | decryption (global sections) |
| a = b | Path(a,b) | path fibration | homotopy equivalence |

The Σ/Π duality is the encrypt/decrypt duality:
- Σ_f F (dependent sum) = "there exists a message in the harmonic space"
  → this is the encryption: hiding the witness
- Π_f F (dependent product) = "for all vertices, agreement on message"
  → this is the decryption: recovering the global section

## The Orthogonality Setup

The Hodge decomposition is the cryptographic foundation:

```
    C^k(X, F) = ker(Δ_k) ⊕ im(δ_{k-1}) ⊕ im(δ_k*)
                  ↑          ↑         ↑
              harmonic    exact    coexact
              (message)   (noise)   (noise)
```

These three subspaces are mutually orthogonal. The inner product on C^k
makes them perpendicular:

```
    ⟨h, δα⟩ = 0     for all h ∈ ker(Δ), α ∈ C^{k-1}
    ⟨h, δ*β⟩ = 0    for all h ∈ ker(Δ), β ∈ C^{k+1}
    ⟨δα, δ*β⟩ = 0   for all α, β
```

This orthogonality is the encrypt/decrypt guarantee:
- message m lives in ker(Δ_k) (harmonic subspace)
- noise e lives in im(δ_{k-1}) ⊕ im(δ_k*) (orthogonal complement)
- ciphertext b = m + e
- projection π_H(b) = π_H(m) + π_H(e) = m + 0 = m

The noise vanishes exactly under harmonic projection because it lives
in the orthogonal complement. No approximation, no error correction —
the geometry forces perfect recovery (up to lattice rounding).

The Hodge star * exchanges the exact and coexact subspaces:
```
    *: im(δ) ↔ im(δ*)
```
This duality is why we need both components in the noise: exact noise
alone would be detectable via δ*, and vice versa.

## The √2 Bound (Tsirelson Maximum)

The spectral gap validity range [1/√2, 2√2] is the Tsirelson bound
from quantum information theory:

```
    CHSH inequality (classical):  |S| ≤ 2
    Tsirelson bound (quantum):    |S| ≤ 2√2
```

In our context, 2√2 is the maximum boundary of what coherent geometry can achieve. A spectral gap exceeding 2√2 would violate the geometric constraints of the
cochain complex, just as a quantum correlation exceeding 2√2 would
violate quantum mechanics.

The lower bound 1/√2 is the reciprocal: below this, the geometry is
too weakly connected to support reliable harmonic projection.

```
    λ₁ < 1/√2  :  geometry too disconnected (cannot recover message)
    λ₁ > 2√2   :  geometry over-constrained (not a valid fibration)
    λ₁ ∈ [1/√2, 2√2] :  valid geometric regime (Tsirelson window)
```

**The problem:**
```
    Given:   b = h + e  where h ∈ ker(Δ_k), e ∈ im(δ_{k-1}) ⊕ im(δ_k*)
    Without: Δ_k
    Find:    h
```

**This is strictly harder than standard LWE:**

In standard LWE, the adversary receives (A, As + e) where e is
random Gaussian noise. In Hodge-hardness, the noise is structured:
it is given by im(δ_{k-1}) ⊕ im(δ_k*), a proper subspace of the full space.

This gives the adversary less information:
- standard LWE noise: isotropic Gaussian (fills all dimensions)
- Hodge noise: confined to orthogonal complement of ker(Δ)
- the adversary knows the noise avoids ker(Δ) but cannot identify
  which subspace ker(Δ) IS without knowing Δ

The reduction is tight (from hardness.py):
```
    Hodge-hardness → CVP on harmonic sublattice → CVP on q-ary lattice
```

Any algorithm solving Hodge-hardness gives an algorithm for CVP on
the lattice defined by ker(Δ) ⊂ C^k(X, ℤ_q). The converse is NOT
true — solving standard CVP does not help with Hodge-hardness because
the structured noise constrains the problem to a specific sublattice
that the adversary cannot identify.

No separate LWE "safety net" is needed. The geometric structure is
a lattice problem, not a wrapper around one.

## Spectral Determination Theorem

**Theorem.** Let F and G be cellular sheaves over the same Čech nerve N.
Then F ≃ G (homotopy equivalent) if and only if:

1. Topological invariants match:
   - βₖ(F) = βₖ(G) for all k (Betti numbers)
   - χ(F) = χ(G) (Euler characteristic)

2. Spectral invariants match:
   - spec(Δ_F) = spec(Δ_G) (eigenvalue spectrum)
   - λ₁(F) = λ₁(G) (spectral gap)

3. Cohomological invariants match:
   - H*(N; F) ≅ H*(N; G) (Čech cohomology)

**Proof (forward).** F ≃ G implies homotopy equivalence induces
isomorphism on cohomology (Hansen–Ghrist). Therefore H*(N; F) ≅ H*(N; G),
therefore βₖ(F) = βₖ(G). Spectral properties are preserved under
homotopy equivalence up to gauge transformation. ∎

**Proof (backward).** This is the hard direction, via the Spectral
Determination Lemma: for cellular sheaves over finite simplicial
complexes, the spectrum plus Betti numbers determines the sheaf up
to isomorphism:

1. Betti numbers determine dim(ker(Δₖ)) for each k
2. full spectrum determines eigenspaces
3. together they determine Δ up to conjugation
4. Δ determines restriction maps up to gauge
5. restriction maps determine the sheaf

This is STRONGER than needed: isomorphism ⟹ homotopy equivalence. ∎

## Deterministic Invariant Gates

The theorem gives us deterministic (not probabilistic) verification:

**β-gate** (topological): Betti numbers are integers — either they match
exactly or they don't. Deterministic, no approximation.

**λ-gate** (spectral gap): λ₁ is a real number, but for fixed-precision
arithmetic it's effectively deterministic within numerical tolerance.

**spec-gate** (full spectrum): sorted eigenvalues must match within
tolerance. If lengths differ, reject immediately.

**Combined gate**: if all three pass, the fibrations are homotopy
equivalent by the Spectral Determination Theorem. 

```
topology_hash mismatch  → REJECT: different base topology
β mismatch              → REJECT: different Betti numbers
λ₁ mismatch             → REJECT: different spectral gap
spec mismatch           → REJECT: different spectrum
all pass                → ACCEPT: homotopy equivalence proven
```

## ZK Proof of Homotopy Equivalence

**Relation R:**
```
R := { (fingerprint, fibration) :
       spectral_invariants(fibration) = fingerprint }
```

**Completeness.** If prover has valid fibration F with matching
invariants, all gates pass by definition. Verifier accepts. ∎

**Soundness.** If prover's fibration has different invariants,
at least one gate fails deterministically. By contrapositive of
Spectral Determination: different spectrum ⟹ not equivalent.
Prover cannot produce proof for non-equivalent fibration. ∎

**Zero-Knowledge.** The proof reveals ONLY values already in the
public statement (Betti numbers, spectral gap, eigenvalues). It
does not reveal:
- the actual restriction maps R_{v→e}
- the eigenvectors (only eigenvalues)
- the specific fibration structure
- any path of equivalence

A simulator given only the public fingerprint produces
indistinguishable proofs by the hiding property of hash
commitments. ∎

## The Hopf Fibration as Model

The Hopf fibration S¹ ↪ S³ → S² gives the geometric intuition:

| Hopf fibration | our construction |
|----------------|------------------|
| S³ (total space) | all fibrations / keys |
| S² (base space) | equivalence classes (public fingerprint) |
| S¹ (fiber) | equivalent keys under homotopy |
| global phase e^{iγ} | homotopy equivalence F ≃ G |

The global phase invariance |ψ⟩ ∼ e^{iγ}|ψ⟩ IS exactly analogous
to homotopy equivalence. Just as S¹ fibers are phase-equivalent
states projecting to the same Bloch sphere point, our fibrations in
the same homotopy class project to the same spectral fingerprint.

Proving class membership IS proving you're in the fiber over that point.

## Base Change Functors

Following Helfer, topology change is functorial:

```
f*:  Fib(B') → Fib(B)    pullback   (contravariant)
Σ_f: Fib(B)  → Fib(B')   dependent sum (covariant)
Π_f: Fib(B)  → Fib(B')   dependent product (covariant)
```

- f* (pullback): given topology morphism f: B → B', pull back fibration.
  value transfer between topologies = pullback of cochains.
- Σ_f (dependent sum): total space of F over image of f.
  encryption = ∃ message in harmonic space (existential hiding).
- Π_f (dependent product): sections of F over fibers of f.
  decryption = ∀ vertices, agreement on message (universal recovery).

