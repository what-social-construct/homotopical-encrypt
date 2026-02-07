# docs

| document | contents |
|----------|----------|
| [ARCHITECTURE](ARCHITECTURE.md) | full module map, mathematical pipeline, privacy model, consensus |
| [GEOMETRY](GEOMETRY.md) | homotopy equivalence, diagonal construction, orthogonality, Tsirelson bound, Hodge-hardness |
| [PRIMITIVES](PRIMITIVES.md) | helfer's logic → crypto: the cochain/fibration/homotopy foundations |
| [SECURITY](SECURITY.md) | security proofs, hodge-hardness, √2 bounds, ring spectral proofs |
| [CONSENSUS](CONSENSUS.md) | proof of value mechanics, spectral gap validation |
| [STORAGE](STORAGE.md) | sheaf-native storage, on/off-chain separation, routing |
| [ROADMAP](ROADMAP.md) | layer 1 implementation roadmap |
| [WIRE_FORMAT](WIRE_FORMAT.md) | binary wire format for network messages |

## quick reference

```
encrypt:   m → embed in ker(Δ) → add noise in im(δ)⊕im(δ*) → ciphertext
decrypt:   ciphertext → π_H (harmonic projection) → extract from ker(Δ) → m
identity:  spectral fingerprint := (eigenvalues, betti numbers, topology hash)
anonymity: homotopy class membership (infinite anonymity set, not N decoys)
consensus: proof of value := spectral gap ∈ [1/√2, 2√2]
```

## the key insight

cochains are dual to chains. encryption uses δ (push data to edges),
decryption uses δ* (project back to vertices). the adjoint relationship
δ* = δᵀ means encrypt/decrypt are mathematically forced inverses.
the hodge decomposition C^k = ker(Δ) ⊕ im(δ) ⊕ im(δ*) is the
cryptographic structure: message lives in ker(Δ), noise lives in its
orthogonal complement.

see `src/crypto/__init__.py` for the full cochain duality explanation.

## archive

historical docs preserved in [archive/](archive/) for reference.
