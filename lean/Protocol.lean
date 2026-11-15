module

public import HCP.AxisSignedSampler
public import HCP.NoiseSpanAttack
public import Protocol.Evidence
public import Protocol.Ephemeral
public import Protocol.Oracle
public import Protocol.Consensus
public import Protocol.Coregulator
public import Protocol.Ledger
public import Protocol.Storage
public import Protocol.Transfer

@[expose] public section

/-!
  Protocol-facing import surface.

  This is the one-way Paper 2 layer. Protocol modules may consume the core
  HCP, proximity, gate, and proof-carrying mathematics; those core modules
  must not import `Protocol`.

  Ledger resource transitions, candidate-indexed TCB evidence, and authenticated
  quorum attachment now have typed definitions and preservation theorems.
  Sheaf storage additionally has snapshot/payload contexts, typed stage prefixes,
  exact manifests and a receipt-indexed local consumption lifecycle. Ephemeral
  recovery has integral/encoded rotation laws and recipient-bound delivery
  receipts under explicit channel contracts. The selected native profile also
  exports canonical ciphertext/scoped-token codecs and exact rational
  transport/recovery through hash lookup. Owned-resource subjects sign the
  canonical two-slot exact-artifact/ciphertext root. Raw seals admit arbitrary
  bytes; separate original-observation certificates associate native meaning
  with that same context and history under explicit bindings. Oracle/coregulator surfaces
  remain attachment points. The finite native CRS reference construction uses
  canonical witness/program/byte-owner packet codecs, a bounded uniform seed
  law and authenticated exact-program selection on the original context. Its
  adaptive full-ciphertext forgery bound retains explicit hybrid, extraction,
  recovery and hash-collision terms. The tagged proof primitive and its security
  estimates remain to be instantiated. Generic codec/lift instantiation,
  round/lock/finality and Rust refinement remain separate completion tasks.
  The optional HCP sampling and fixed-key span modules provide finite
  semantic checks and conditional leakage boundaries, not an asymptotic
  confidentiality theorem.
-/
