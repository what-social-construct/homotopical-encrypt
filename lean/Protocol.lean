module

public import HCP.AxisSignedSampler
public import HCP.NoiseSpanAttack
public import HCP.CoupledLattice
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

  The full intrinsic lattice, coefficient charts and inherited discrete
  topology are exported here. The narrow byte-recovery module needs only
  the exact decoder refinement, rather than the topological lattice machinery.

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
  estimates remain to be instantiated. Original native source and actual
  setup joins also connect fresh checked completions of the generated target
  to that same experiment's five-term bound. Arbitrary packet-adversary
  translation and general integrity retain their own obligations.
  Generic codec/lift instantiation,
  round/lock/finality and Rust refinement remain separate completion tasks.
  The optional HCP sampling and fixed-key span modules provide finite
  semantic checks and conditional leakage boundaries, not an asymptotic
  confidentiality theorem. The native reference sampler also has a concrete
  scalar recovery counterexample. A separate fresh-sign candidate has exact
  one-use ciphertext laws and ciphertext-only guessing bounds; its public
  operator-hash disclosure and migration/noise-refresh boundaries are explicit.
  The selected design target uses fresh geometry per public object and a
  private master for key management. Hiding operator binding and a secure
  proof primitive remain construction tasks, not properties of the old wire.
-/
