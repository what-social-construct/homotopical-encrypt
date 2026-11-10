# Architecture

The active architecture is the Lean development and its corresponding
manuscripts. Mathematical objects and proved relationships live under
`lean/`; the three-paper allocation is recorded in the
[shared parity register](SEMANTIC-PARITY.md).

| Guide | Scope |
|---|---|
| [Lean entry points](lean/README.md) | Definitions, proofs, assumptions and reproducible checks. |
| [Semantic ownership](docs/SEMANTIC_OWNERSHIP.md) | Canonical objects, morphisms and formal status. |
| [Categorical architecture](docs/CATEGORICAL_ARCHITECTURE.md) | Existing formal constructions and prospective categorical packaging. |
| [Gate architecture](docs/GATE_ARCHITECTURE.md) | Mathematical gate and protocol obligations. |
| [Trust boundaries](docs/TRUST_BOUNDARIES.md) | Separation of formal results from executable refinement. |
| [Earlier architecture pointer](docs/ARCHITECTURE.md) | Historical Python-led design provenance. |

Rust/Python prototypes and their runtime material are preserved under
[archive/runtime/](archive/runtime/). They are historical and are not maintained
as the active implementation. Their structure does not define the Lean
objects or establish protocol security.

The active validation scope is Lean plus the manuscripts. A future runtime
implementation needs its own explicit correspondence with the formal
specifications; moving the prototypes does not supply that correspondence.
