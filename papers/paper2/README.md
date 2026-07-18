# Proof-Carrying Homotopical Encryption: Gate Certificates And Vertra Chain Architecture

Working title for Paper 2.

Placeholder for the subsequent CS/protocol paper.

Expected scope:

- proof-carrying verification;
- gate certificates as protocol evidence;
- runtime trust boundaries;
- oracle/worker/attestation model;
- attacker-observation sites, protocol security games, and sheaf-theoretic
  security semantics;
- consensus and Proof of Value;
- Grassmannian consensus geometry, including Karcher/Fréchet means for
  validator subspace aggregation;
- anonymous credential privacy and issuer-hiding credential flows;
- post-quantum identity/key-management comparisons, including
  forward-secure identity-based encryption;
- post-quantum authenticated key exchange and signcryption for protocol
  session establishment;
- oblivious message retrieval / private retrieval boundary for protocol
  storage and worker access;
- encrypted-computation framework risk, metamorphic testing, and implementation
  correctness boundaries for privacy-preserving runtimes;
- protocol implementation testing, including fuzzing and LLM-guided seed
  generation as possible later whitepaper material;
- Vertra chain architecture;
- Rust implementation boundary.

Paper 1 should remain the math/formalization paper: HCP, hidden operators,
CVP comparison, projection chain, RS/MCA endpoint, and Lean theorem surfaces.

Consensus/runtime thesis:

- PoV/geometry supplies the block and validator admissibility/value predicate:
  spectral bounds, topology connectedness, cochain-root compatibility,
  key-image freshness, balance preservation, Heyting accept/hold/reject
  judgments, and discount-only proximity/reliability scoring.
- VRF slot assignment supplies ordering and fork-control: for a fixed epoch,
  only a slot-valid producer may extend the chain, and equivocation is handled
  by deterministic fork choice plus slashing/reputation evidence.
- The project-native VRF direction is fibration-keyed rather than stake-keyed:
  the current Python/Rust prototype derives a hash/HMAC VRF key from secret
  fibration/eigenvector material, binds the output to a public homotopy-class
  identity hash, and weights eligibility by harmonic or Plucker consensus
  geometry. This is a prototype slot-lottery construction, not yet a cleaned-up
  public-key VRF proof system.
- The concrete evidence path for that native slot lottery should reuse the
  existing Plucker/proximity objects instead of introducing a second public
  geometry layer: a private frame witness determines a normalized public
  Plucker shadow; a proof-carrying payload realizes that shadow as an accepted
  cochain commitment; the projection chain sends the committed cochain through
  the plane shadow to the canonical Reed--Solomon received word; hard-gate
  evidence records and the RS/MCA certificate give the finite verifier-facing
  audit target. In slogan form:

  ```text
  FrameWitness -> HashedPluckerShadow -> CochainCommitmentData
    -> PlaneShadow -> RS received word -> MCA-bound certificate
  ```
- The protocol should not claim that geometry alone replaces network agreement.
  Geometry reduces what validators must decide socially; VRF/fork-choice,
  liveness, finality, gossip, rollback bounds, and equivocation handling remain
  protocol/consensus-layer obligations.
- Rust is the consensus-facing runtime boundary: canonical byte parsing,
  resource bounds, proof and oracle-attestation verification, VRF checks,
  key-image checks, state-root/cochain-root recomputation, fork choice, and
  atomic state transitions.
- Python may construct candidates, witnesses, numerical references, and test
  vectors. It is not consensus authority.
- TEEs may be used as optional oracle/worker privacy hardening for witness
  handling and metadata reduction. A TEE result becomes consensus-facing only
  as an attestation or proof artifact verified by Rust against the stated
  Lean/protocol predicate; the TEE itself is not a consensus oracle.
- Breadth-first graph traversal, when used, is an implementation algorithm for
  public graph checks such as Čech-nerve connectedness, dependency/frontier
  walks, or block-DAG traversal. It is not a security assumption. If BFT-style
  voting/finality is added, it should be presented as a separate network
  agreement layer, not as the PoV validity predicate.

Protocol-facing references:

- Hermann Karcher, "Riemannian center of mass and mollifier smoothing,"
  Communications on Pure and Applied Mathematics 30(5):509-541, 1977.
- Takao Inoué, "Grothendieck Topologies and Sheaf-Theoretic Foundations of
  Cryptographic Security: Attacker Models and Σ-Protocols as the First Step,"
  arXiv:2602.17301, 2026.
- Andrea Flamini, Karla Friedrichs, Jonathan Katz, Watson Ladd, Anja Lehmann,
  and Marek Sefrane, "Issuer-Hiding BBS-Based Anonymous Credentials without
  Policy Keys." Working citation; verify venue metadata before submission.
- Ben Fisch, Zeyu Liu, Eran Tromer, and Yunhao Wang, "UnifOMR: Oblivious
  Message Retrieval with Near-optimal Concrete Efficiency." Working citation;
  verify venue metadata before submission.
- Abhishek Kumar, Vikas Srivastava, Sumit Kumar Debnath, and Pantelimon
  Stănică, "A Post-Quantum Secure Lattice-Based Forward-Secure Identity Based
  Encryption with Applications to Internet of Things Architecture,"
  arXiv:2606.22340, 2026.
- Mostefa Kara, Konstantinos Karampidis, and Muath AlShaikh, "Post-Quantum
  Authenticated Key Exchange via Signcryption with Ephemeral Key Masking."
  Working citation; verify venue metadata before submission.
- Yiteng Peng, Dongwei Xiao, Zhibo Liu, Zhenlan Ji, and Shuai Wang, "Detecting
  and Understanding Vulnerabilities in Fully Homomorphic Encryption
  Frameworks," arXiv:2606.22519, 2026.
- Keke Gai, Haochen Liang, Jing Yu, Liehuang Zhu, and Dusit Niyato, "LLAMA:
  Multi-Feedback Smart Contract Fuzzing Framework with LLM-Guided Seed
  Generation," arXiv:2507.12084, 2025.
