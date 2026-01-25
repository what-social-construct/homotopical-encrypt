# Homotopical-Encrypt Documentation Index

## Quick Navigation

### 🎯 Start Here
- [PHILOSOPHY.md](PHILOSOPHY.md) - Core thesis: Structural Sovereignty, √2 geometry
- [HOMOTOPICAL_PRIMITIVES.md](HOMOTOPICAL_PRIMITIVES.md) - ALL primitives from cochain complex

### 🔐 Security
| Doc | Focus |
|-----|-------|
| [SECURITY_PROOFS.md](SECURITY_PROOFS.md) | Main theorem, √2 bounds, Tsirelson connection |
| [SECURITY_VULNERABILITIES.md](SECURITY_VULNERABILITIES.md) | Known issues, priority patches |
| [HOMOTOPY_EQUIVALENCE_PROOF.md](HOMOTOPY_EQUIVALENCE_PROOF.md) | Diagonal functor Δ, HoTT foundations, spectral gates |

### ⚙️ Primitives & Design
| Doc | Focus |
|-----|-------|
| [HOMOTOPICAL_PRIMITIVES.md](HOMOTOPICAL_PRIMITIVES.md) | Commitment (δ), MAC (ker Δ), Threshold, Signatures |
| [INVARIANT_PHILOSOPHY.md](INVARIANT_PHILOSOPHY.md) | By-construction types vs runtime validation |
| [WIRE_FORMAT.md](WIRE_FORMAT.md) | Actual bytes, JSON format, message structure |

### ⛓️ Chain Layer
| Doc | Focus |
|-----|-------|
| [CHAIN_ARCHITECTURE.md](CHAIN_ARCHITECTURE.md) | $HCRYPT chain, PoV consensus, transaction types |
| [PRIVACY_CHAIN_DESIGN.md](PRIVACY_CHAIN_DESIGN.md) | Ring sigs, stealth addresses, RingCT, key images |
| [PROOF_OF_VALUE.md](PROOF_OF_VALUE.md) | √2 spectral bounds, economic properties |

### 🌐 Vision & Integration
| Doc | Focus |
|-----|-------|
| [SOVEREIGNTY_VISION.md](SOVEREIGNTY_VISION.md) | Individual sovereignty, net neutrality |
| [RBN_INTEGRATION.md](RBN_INTEGRATION.md) | Connection to chloe_protocol / Revenge Banana |

### 📋 Meta
| Doc | Focus |
|-----|-------|
| [CRITIQUE.md](CRITIQUE.md) | What's novel, critical issues, next steps |

---

## Core Concepts Map

```
DIAGONAL PAIRING (Δ: Spec → Spec × Spec)
       HomotopyPath(F,G)
              │ π
              ▼
         Fib × Fib
              │ fingerprint
              ▼
         Spec × Spec ← Δ(Spec) = equivalence

PRIMITIVES (all from cochain):
├── Commitment: δ(m || r) ∈ C¹
├── MAC: ker(Δ) membership
├── Threshold: k vertices span ker(Δ)
└── Signature: path-space proof

INVARIANT LAYERS:
├── Type-level (ConnectedTopology, PositiveSpectralGap)
├── Smart constructors (Result[T, Error])
└── Verification (external inputs)

√2 BOUNDS (Tsirelson):
├── 1/√2 < λ₁ < 2√2 (valid geometry)
├── Fee multiplier = 1 / (β₁ + ε)
└── Concentration → self-penalizing
```

---

## Reading Order (Recommended)

1. **Foundations**: PHILOSOPHY.md → HOMOTOPY_EQUIVALENCE_PROOF.md
2. **Primitives**: HOMOTOPICAL_PRIMITIVES.md → INVARIANT_PHILOSOPHY.md
3. **Security**: SECURITY_PROOFS.md → SECURITY_VULNERABILITIES.md
4. **Chain**: CHAIN_ARCHITECTURE.md → PRIVACY_CHAIN_DESIGN.md → PROOF_OF_VALUE.md
5. **Integration**: SOVEREIGNTY_VISION.md → RBN_INTEGRATION.md
6. **Implementation**: WIRE_FORMAT.md → CRITIQUE.md

---

*Last updated: January 2026*
