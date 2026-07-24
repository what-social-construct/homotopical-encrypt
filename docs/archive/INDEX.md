# Homotopical-Encrypt Documentation Index

> [!WARNING]
> **Historical and non-normative archive.** Documents under `docs/archive/`
> preserve earlier design exploration. They do not establish current theorem
> status, protocol behavior, security guarantees, wire formats, or implementation
> status. Start with [`../SEMANTIC_OWNERSHIP.md`](../SEMANTIC_OWNERSHIP.md),
> [`../TRUST_BOUNDARIES.md`](../TRUST_BOUNDARIES.md), and the active parity queues.

## Historical And Non-Normative Active-Path Retirements

These documents previously occupied active paths. Their active files are now
status stubs pointing to current sources; the complete earlier bodies are kept
here solely for provenance.

| Historical document | Active status page | Why retired |
|---|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | [active stub](../ARCHITECTURE.md) | Earlier Python-led architecture |
| [STORAGE.md](STORAGE.md) | [active stub](../STORAGE.md) | Earlier storage and routing plan |
| [SECURITY.md](SECURITY.md) | [active stub](../SECURITY.md) | Superseded theorem/security narrative |
| [PRIMITIVES.md](PRIMITIVES.md) | [active stub](../PRIMITIVES.md) | Superseded primitive and binding claims |
| [GEOMETRY.md](GEOMETRY.md) | [active stub](../GEOMETRY.md) | Superseded spectral/global-section claims |
| [ORACLE_SECURITY.md](ORACLE_SECURITY.md) | [active stub](../ORACLE_SECURITY.md) | Superseded oracle and consensus model |
| [WIRE_FORMAT.md](WIRE_FORMAT.md) | [active stub](../WIRE_FORMAT.md) | Illustrative, non-canonical byte layouts |
| [ROADMAP.md](ROADMAP.md) | [active stub](../ROADMAP.md) | Dated shipping status and milestones |
| [REFACTOR_PLAN.md](REFACTOR_PLAN.md) | [active stub](../REFACTOR_PLAN.md) | Completed/superseded migration plan |
| [CATEGORICAL_ARCHITECTURE.md](CATEGORICAL_ARCHITECTURE.md) | [current architecture](../CATEGORICAL_ARCHITECTURE.md) | Mixed categorical narrative predating the typed sheaf/state split |
| [CATCOLAB_MAP.md](CATCOLAB_MAP.md) | [current architecture](../CATEGORICAL_ARCHITECTURE.md) | Optional modeling-tool map that mixed verified Paper 1 data with prospective natural-transformation and colimit claims |
| [COMPARISON.md](COMPARISON.md) | [current workbench](../COMPARISON.md) | Comparison notebook with superseded global-section and commitment claims |
| [CONSENSUS.md](CONSENSUS.md) | [active status page](../CONSENSUS.md) | Spectral-stake and spectral-finality prototype |

## Historical Source Archives

| Archive | Status |
|---|---|
| [Legacy Python source](python/README.md) | Historical `src/primitives/` and `src/invariants/` layers, retired intact after semantic audit. They are non-normative and intentionally not an executable Python package. |

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
| [ARCHITECTURE.md](ARCHITECTURE.md) | Historical Python-led system architecture; archived, not a current specification |
| [STORAGE.md](STORAGE.md) | Historical Python/RocksDB storage and routing plan; archived, not a current specification |
| [HOMOTOPICAL_PRIMITIVES.md](HOMOTOPICAL_PRIMITIVES.md) | Commitment (δ), MAC (ker Δ), Threshold, Signatures |
| [INVARIANT_PHILOSOPHY.md](INVARIANT_PHILOSOPHY.md) | By-construction types vs runtime validation |
| [WIRE_FORMAT.md](WIRE_FORMAT.md) | Historical illustrative bytes and message structure |

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
6. **Historical implementation sketches**: WIRE_FORMAT.md → CRITIQUE.md

---

*Archive index updated: July 2026. Historical documents retain their original
dates and status language for provenance only.*
