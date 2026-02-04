# Oracle Architecture: Off-Chain Computation + On-Chain Verification

## Core Insight

**Heavy math should be OFF-CHAIN with hash-traced verification**

Similar to chloe_protocol's oracle integration:
- Compute eigenvalues/Hodge off-chain (Python or Rust workers)
- Submit results + hash trace to chain
- Chain verifies hashes, not eigenvalues
- Slashing for invalid submissions

---

## Clean Separation of Concerns

```
┌─────────────────────────────────────────────────────────┐
│                   OFF-CHAIN (Python/Rust)                │
│                   Heavy Computation                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  • Eigenvalue decomposition (O(n³))                     │
│  • Hodge decomposition (expensive)                      │
│  • Laplacian construction                               │
│  • Spectral gap computation                             │
│  • Homotopy equivalence checking                        │
│  • Invariant validation (full suite)                    │
│                                                         │
│  Result: (invariants, hash_trace, proof)                │
│                                                         │
└─────────────────────────────────────────────────────────┘
                          ↓ Submit
┌─────────────────────────────────────────────────────────┐
│                   ORACLE LAYER                          │
│                   Verification Service                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  • Accepts computation submissions                       │
│  • Validates hash traces (like chloe HashChain)         │
│  • Aggregates multiple oracle submissions               │
│  • Slashes for invalid results                          │
│  • Publishes verified invariants on-chain               │
│                                                         │
└─────────────────────────────────────────────────────────┘
                          ↓ Publish
┌─────────────────────────────────────────────────────────┐
│                   ON-CHAIN (Rust)                       │
│                   Lightweight Verification               │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  • Verify hash traces                                   │
│  • Check √2 bounds (simple comparison)                  │
│  • Validate spectral fingerprint format                 │
│  • Consensus on block validity                          │
│  • State transitions                                    │
│  • NO eigenvalue computation                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Hash Tracing (chloe_protocol Pattern)

### HashChain for Computation Verification

```rust
pub struct ComputationTrace {
    // Initial state
    input_hash: Hash,
    
    // Step-by-step computation trace
    steps: Vec<ComputationStep>,
    
    // Final result
    result_hash: Hash,
}

pub struct ComputationStep {
    operation: String,        // "eigenvalue_decomp", "hodge_project", etc.
    input_hash: Hash,         // Hash of input data
    output_hash: Hash,        // Hash of output data
    timestamp: u64,
    
    // Proof this step is valid
    proof: StepProof,
}

impl ComputationTrace {
    // Verify entire trace is valid
    pub fn verify(&self) -> bool {
        let mut current_hash = self.input_hash;
        
        for step in &self.steps {
            // Verify step connects to previous
            if step.input_hash != current_hash {
                return false;
            }
            
            // Verify step proof
            if !step.proof.verify() {
                return false;
            }
            
            current_hash = step.output_hash;
        }
        
        // Verify final result matches
        self.result_hash == current_hash
    }
}
```

### Example: Spectral Gap Computation Trace

```
Step 1: Build Laplacian
  Input: topology_hash(nerve)
  Operation: "construct_laplacian"
  Output: laplacian_hash(Δ)
  Proof: Δ = δδ* + δ*δ

Step 2: Eigenvalue Decomposition
  Input: laplacian_hash(Δ)
  Operation: "eigendecomp"
  Output: eigenvalues_hash([λ₀, λ₁, ..., λₙ])
  Proof: Δv = λv (spot check a few eigenvectors)

Step 3: Extract Spectral Gap
  Input: eigenvalues_hash([λ₀, λ₁, ..., λₙ])
  Operation: "extract_gap"
  Output: spectral_gap_hash(λ₁)
  Proof: λ₁ is first nonzero eigenvalue

Final: Submit (spectral_gap, trace)
  Chain verifies: trace.verify() && gap ∈ [1/√2, 2√2]
```

---

## Oracle Network Architecture

### Oracle Roles

**Computation Oracles** (Off-chain workers):
- Run Python/Rust computation nodes
- Compute eigenvalues, Hodge, invariants
- Generate hash traces
- Submit to oracle network
- Staked (slashable if wrong)

**Verification Oracles** (Validators):
- Receive computation submissions
- Verify hash traces
- Cross-check multiple submissions
- Slash invalid oracles
- Publish consensus result on-chain

**On-Chain Contracts** (Lightweight):
- Accept oracle submissions
- Verify simple properties (√2 bounds)
- Slash mechanism
- State updates

### Oracle Submission Flow

```
1. User creates transaction
   → Needs spectral proof
   
2. Computation Oracle picks up request
   → Computes eigenvalues off-chain
   → Generates hash trace
   → Signs submission
   
3. Multiple oracles compute independently
   → Each submits (result, trace, signature)
   
4. Verification Oracles check submissions
   → Verify hash traces
   → Check consensus (majority agrees?)
   → Slash outliers
   
5. Consensus result published on-chain
   → Transaction includes verified spectral proof
   → Chain just checks hash + bounds
   → No expensive computation on-chain
```

---

## Rust Architecture

### On-Chain (Lightweight)

```rust
// src/consensus/pov_verifier.rs
pub struct PoVVerifier {
    // NO eigenvalue computation here!
}

impl PoVVerifier {
    // Verify spectral proof (from oracle)
    pub fn verify_spectral_proof(
        &self,
        proof: &SpectralProof,
        topology_hash: Hash,
    ) -> bool {
        // 1. Verify hash trace
        if !proof.computation_trace.verify() {
            return false;
        }
        
        // 2. Verify topology matches
        if proof.topology_hash != topology_hash {
            return false;
        }
        
        // 3. Check √2 bounds (SIMPLE!)
        let gap = proof.spectral_gap;
        let lower = 1.0 / SQRT2;
        let upper = 2.0 * SQRT2;
        
        if gap < lower || gap > upper {
            return false;
        }
        
        // 4. Verify oracle signatures
        if !self.verify_oracle_consensus(&proof.oracle_signatures) {
            return false;
        }
        
        true
    }
}
```

### Off-Chain (Heavy Computation)

```rust
// oracle/src/computation_worker.rs
pub struct ComputationWorker {
    // This runs OFF-CHAIN
    // Can use Python via FFI or pure Rust
}

impl ComputationWorker {
    // Compute eigenvalues (expensive!)
    pub async fn compute_spectral_gap(
        &self,
        topology: &Nerve,
    ) -> Result<SpectralProofSubmission> {
        let mut trace = ComputationTrace::new();
        
        // Step 1: Build Laplacian
        let laplacian = self.build_laplacian(topology);
        trace.add_step("build_laplacian", topology_hash, laplacian_hash);
        
        // Step 2: Eigendecomposition (O(n³) - expensive!)
        let eigenvalues = self.eigendecomp(&laplacian);
        trace.add_step("eigendecomp", laplacian_hash, eigenvalues_hash);
        
        // Step 3: Extract gap
        let gap = eigenvalues[1]; // First nonzero
        trace.add_step("extract_gap", eigenvalues_hash, gap_hash);
        
        // Sign submission
        let signature = self.sign(&trace);
        
        Ok(SpectralProofSubmission {
            spectral_gap: gap,
            computation_trace: trace,
            oracle_signature: signature,
        })
    }
}
```

---

## Integration with chloe_protocol Pattern

### Shared Patterns

**chloe_protocol**:
- HashChain for tracing system state
- Merkle-tree-like audit trail
- Off-chain belief updates, on-chain commitments

**homotopical-encrypt**:
- ComputationTrace for verifying math
- Hash-traced spectral computations
- Off-chain eigenvalues, on-chain verification

### Unified Oracle Layer

```
┌────────────────────────────────────────────────────┐
│         Shared Oracle Infrastructure               │
├────────────────────────────────────────────────────┤
│                                                    │
│  chloe_protocol:                                   │
│  ├── Belief updates (off-chain SDE)                │
│  ├── Signal processing                             │
│  └── Consensus via HashChain                       │
│                                                    │
│  homotopical-encrypt:                              │
│  ├── Spectral computations (off-chain)             │
│  ├── Hodge projections                             │
│  └── Invariant verification via ComputationTrace   │
│                                                    │
│  Both use:                                         │
│  ├── Hash-traced execution                         │
│  ├── Off-chain heavy computation                   │
│  ├── On-chain lightweight verification             │
│  └── Slashing for invalid submissions              │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## Rust Module Structure

```
homotopical-encrypt-rust/
├── node/                   (On-chain consensus)
│   ├── consensus/
│   │   ├── pov_verifier.rs    (Verify spectral proofs)
│   │   ├── block_validator.rs
│   │   └── state_machine.rs
│   ├── network/
│   │   ├── p2p.rs              (libp2p)
│   │   └── rpc.rs              (JSON-RPC)
│   ├── storage/
│   │   ├── block_store.rs
│   │   └── state_store.rs
│   └── mempool/
│       └── tx_pool.rs
│
├── oracle/                 (Off-chain computation)
│   ├── computation_worker.rs  (Heavy math here)
│   ├── hash_trace.rs          (ComputationTrace)
│   ├── verification.rs         (Cross-check submissions)
│   └── rewards.rs              (Oracle incentives)
│
├── crypto/                 (Shared crypto primitives)
│   ├── laplacian.rs           (Can use Python FFI)
│   ├── hodge.rs
│   ├── secure_memory.rs       (zeroize)
│   └── fingerprint.rs
│
└── contracts/              (Smart contracts - WASM)
    ├── runtime/
    │   └── wasm_executor.rs
    └── precompiles/
        ├── verify_spectral.rs  (Verify oracle submission)
        ├── check_homotopy.rs   (Lightweight checks only)
        └── hash_trace.rs       (Verify computation traces)
```

---

## Gas Model (Revised)

### On-Chain Operations (Cheap)

```
Operation                      Gas Cost
─────────────────────────────────────────
Verify hash                    100
Check √2 bounds                50
Validate fingerprint format    100
Verify oracle signature        500
Check computation trace        1000 * steps
State transition               500
```

### Off-Chain Operations (FREE for users, paid to oracles)

```
Operation                      Oracle Reward
────────────────────────────────────────────
Eigenvalue decomposition       1000 tokens
Hodge decomposition            500 tokens
Invariant validation           200 tokens
Homotopy equivalence proof     800 tokens
```

**User pays**: Small on-chain verification fee
**Oracle earns**: Computation rewards (from protocol)
**Result**: Users don't pay for O(n³) computation!

---

## Security Model

### Oracle Staking

- Oracles must stake tokens to participate
- Slashed if they submit invalid computations
- Verified via hash trace + cross-checking

### Consensus Mechanism

- Multiple oracles compute independently
- Require 2/3 consensus on result
- Outliers are slashed
- Published result includes all signatures

### Attack Resistance

**Sybil Attack**: Staking prevents cheap oracles
**Collusion**: Need 2/3 of staked oracles (expensive)
**Invalid Results**: Hash trace makes cheating detectable
**Availability**: Multiple oracles ensure redundancy

---

## Migration Strategy

### Phase 1: Rust Node (On-Chain)
- Block validation
- Consensus (verify spectral proofs from oracle)
- State machine
- P2P networking
- Secure memory

### Phase 2: Oracle Network (Off-Chain)
- Computation workers (Python initially, Rust later)
- Hash tracing implementation
- Verification oracles
- Staking/slashing mechanism

### Phase 3: Integration
- Connect oracle to node
- Smart contracts that use oracle results
- User-facing wallet (submits to oracle, waits for verification)

---

## Benefits of This Architecture

✅ **Scalability**: Heavy computation doesn't bloat chain
✅ **Cost**: Users pay pennies for verification, not dollars for computation
✅ **Flexibility**: Oracle can use Python (fast dev) or Rust (performance)
✅ **Security**: Hash tracing makes invalid computation detectable
✅ **Decentralization**: Multiple oracles, no single point of failure
✅ **Clean Separation**: Chain does what chains do best (consensus), oracles do math

---

## Summary

**On-Chain (Rust)**:
- Consensus, blocks, state
- Verify hash traces
- Check √2 bounds
- Secure memory
- NO heavy math

**Off-Chain (Python/Rust Oracle)**:
- Eigenvalues, Hodge, Laplacian
- Generate hash traces
- Submit to chain
- Get rewards

**Result**: Fast, cheap, scalable, secure

**Beautiful part**: Same pattern as chloe_protocol's oracle integration - proven architecture!
