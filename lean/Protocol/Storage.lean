import Protocol.Evidence
import TCB.CompressionBoundary

/-!
  Abstract storage and evidence-anchor boundary.

  Lean specifies immutable finalized evidence, content-addressed roots, and
  root-preserving state transitions. Concrete hashing, canonical bytes,
  database batches, retention, and crash consistency remain Rust obligations.
-/
