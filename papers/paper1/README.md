# Homotopical Encryption

*Homotopical Encryption: Hidden Hodge Operators and the Harmonic Cochain
Problem* develops the encryption mechanism and the mathematical problem it
creates. Read the [PDF](main.pdf) or [TeX source](main.tex).

The main body has four parts:

1. Cellular, semantic and Hodge primitives.
2. The Harmonic Cochain Problem and its public homotopy classes.
3. The coupled encryption construction: actual operators, entire intrinsic
   lattice, finite encoding/recovery, transport diagrams, private operator
   commitments and one-use random-oracle recovery.
4. CVP comparison, ending with a strict recovery separation on the
   fresh-sign family.

The coupled family uses one canonical private matrix throughout. Its integer
harmonic chart covers the full intrinsic lattice; exact byte recovery returns
the original coefficients. The manuscript walks through both runnable byte
round trips, including recovery of the original Boolean message in the
fresh-sign profile. [Lean demo](../../lean/Protocol/Storage/CoupledRecovery/Demo.lean)

The finite fresh-key instance has the proved
classical query bound `2^-n+(Q+2)/256^32`, including partial coefficient
recovery for positive scaling. The theorem specifies a fresh empty shared
oracle cache and `Q` postrelease decoder queries.

On those same ciphertexts one CVP call with the supplied operative lattice
recovers every message. The public bound remains in force for a decoder
with the same fixed CVP oracle. [Lean comparison](../../lean/HCP/CoupledRecoverySeparation.lean)

For each fixed ciphertext mask there are exactly `2^n` compatible messages
and operative lattices. Each lattice has its own unique closest point. The
basis-span lift also preserves all closest vectors for arbitrary CVP targets.
The coupled lift gives a one-query reduction to nearest-point search on
the specified harmonic lattice for rational CVP inputs. Its exact distance
decision problem is NP-complete. [Basis-span lift](../../lean/HCP/UnrestrictedCVPLift.lean) · [Coupled lift](../../lean/HCP/CoupledCVPLift.lean)

The different operative planes in that one public class form a graph chart
family. Their squared chordal distances are an explicit multiple of key
Hamming distance. [Projector geometry](../../lean/HCP/CoupledProjectorMetric.lean)

The post-conclusion appendix maps these results to canonical Lean declarations.
It also retains the earlier six-group Hodge/CVP table, whose
[focused verification entry](../../lean/Palomar/PaperOne/README.md) selects
16 main and 20 supporting declarations. That checked selection is separate
from the new coupled and random-oracle results; its source metadata pins the
earlier revision.

[Paper 2](../paper2/README.md) consumes this construction in payload, storage,
certificate and transaction interfaces. [Paper 3](../paper3/README.md) owns
coding and proximity results. Mathematical proofs have one canonical home
here; protocol joins remain in their own manuscript. Lean module paths retain
their historical locations without duplicating definitions.

The [shared parity register](../../SEMANTIC-PARITY.md) records precise
ownership and remaining work. The [source ledger](../../docs/SOURCE_LEDGER.md)
indexes the literature and its corresponding bibliographies.

Build the manuscript from this directory with
`latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex`.
Check the closing theorem from `lean/` with `lake build HCP.CoupledRecoverySeparation`.
