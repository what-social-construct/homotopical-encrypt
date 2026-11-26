# Homotopical Encryption

*Homotopical Encryption: Hidden Hodge Operators and the Harmonic Cochain
Problem* develops the encryption mechanism and the mathematical problem it
creates. Read the [PDF](main.pdf) or [TeX source](main.tex).

The main body has four parts:

1. Cellular, semantic and Hodge primitives.
2. The Harmonic Cochain Problem and its public homotopy classes.
3. The coupled encryption construction, including the actual operators, entire
   intrinsic lattice, finite encoding and recovery, a prime-field representation
   of the bounded ciphertext equations, the fresh-sign encryption and
   decryption algorithms, exact reuse consequences, transport diagrams,
   private operator commitments and one-use random-oracle privacy.
4. CVP comparison, ending with a strict recovery separation on the
   fresh-sign family.

The coupled family uses one canonical private matrix throughout. Its integer
harmonic chart covers the full intrinsic lattice; exact byte recovery returns
the original coefficients. The manuscript walks through both runnable byte
round trips, including recovery of the original Boolean message in the
fresh-sign profile. [Lean demo](../../lean/Protocol/Storage/CoupledRecovery/Demo.lean)

The checked fresh-sign decoder accepts exactly the canonical ciphertexts
generated at its declared public parameters. The ciphertext reveals the
one-time mask and provides no authentication. Every sign key decrypts a
valid ciphertext to its own compatible message. Two ciphertexts under
the same key reveal their plaintext XOR, and one known plaintext recovers
that key and the other plaintext. [Checked decoder](../../lean/Protocol/Transfer/PathSignature/NativeSignSampler/CheckedRecovery.lean) · [Reuse theorems](../../lean/Protocol/Transfer/PathSignature/NativeSignSampler/Reuse.lean)

For the bounded mechanism, the rank-one arithmetic equations and binary range
gates give an explicit field assignment for every valid integer sample. Over
a prime field satisfying the modulus bounds, a satisfying field assignment has
a unique bounded integer lift of its native arithmetic wires that obeys the
original ciphertext equations. Paper 2 builds on this refinement in its proof
relation.
[Lean range refinement](../../lean/Protocol/Transfer/PathSignature/NativeCircuitRanges.lean)

The finite fresh-key instance has the proved
classical query bound `2^-n+(Q+2)/256^32`, including partial coefficient
recovery for positive scaling. The theorem specifies a fresh empty shared
oracle cache and `Q` postrelease decoder queries. For every fixed pair of
messages in the same experiment, the challenge-bit success bound is
`1/2+(Q+2)/256^32`. [Chosen-message theorem](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRandomOracle/Indistinguishability.lean)

On those same ciphertexts one CVP call with the supplied operative lattice
recovers every message. The public bound remains in force for a decoder
with the same fixed CVP oracle. [Lean comparison](../../lean/HCP/CoupledRecoverySeparation.lean)

For each fixed ciphertext mask there are exactly `2^n` compatible messages
and operative lattices. Each lattice has its own unique closest point. The
basis-span lift also preserves all closest vectors for arbitrary CVP targets.
The coupled lift gives a one-query reduction to nearest-point search on
the specified harmonic lattice for rational CVP inputs. Its exact distance
decision problem is NP-complete. [Basis-span lift](../../lean/HCP/UnrestrictedCVPLift.lean) · [Coupled lift](../../lean/HCP/CoupledCVPLift.lean)

The coupled CVP objective splits into the squared Hodge residual and the
graph Gram quadratic form in the coefficient error. For one fresh-sign
ciphertext, every compatible key gives the same minimum squared cost, and
the next larger cost is exactly `d+1` higher when `n>0`.
[Residual split](../../lean/HCP/CoupledCVPResidual.lean) · [Fresh-sign gap](../../lean/HCP/CoupledSignResidual.lean)

For a uniform finite family at one public observation, the most frequent
operative target gives the exact optimal recovery rate. On the actual
fresh-sign ciphertext, disclosing `r` distinct sign bits raises it to
`2^r/2^n`. Appending the common minimum CVP cost leaves it unchanged.
[Typed bound](../../lean/HCP/FiniteRecovery/Typed.lean) · [Native disclosure](../../lean/HCP/FiniteRecovery/Native.lean)

In the nonce-bearing random-oracle experiment, a deterministic sign-key
disclosure with `m` possible values gives the upper bound
`m/2^n + (Q+2)/256^32`, including adaptive decoder queries.
[Oracle disclosure bound](../../lean/Protocol/Transfer/PathSignature/NativeCommittedRandomOracle/Disclosure.lean)

The different operative planes in that one public class form a graph chart
family. Their squared chordal distances are an explicit multiple of key
Hamming distance. [Projector geometry](../../lean/HCP/CoupledProjectorMetric.lean)

The appendix's current correspondence table maps these results to canonical
Lean declarations in this repository. Its historical Palomar section
preserves the six-group Hodge/CVP crosswalk from the submission. The source
pin and verification record describe that earlier 36-declaration selection.
[Historical Palomar entry](../../lean/Palomar/PaperOne/README.md)

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
Check the residual and gap with `lake build HCP.CoupledSignResidual`.
Check the disclosure results with `lake build HCP.FiniteRecovery.Typed HCP.FiniteRecovery.Native`.
Check the sampled-oracle extension with
`lake build Protocol.Transfer.PathSignature.NativeCommittedRandomOracle.Disclosure`.
