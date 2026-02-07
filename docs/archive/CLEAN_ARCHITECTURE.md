# Clean Architecture: Off-Chain Math + Oracle Interface + On-Chain Consensus

## Core Principle

**Oracle = Communication Interface, NOT Computation Engine**

```
┌─────────────────────────────────────────┐
│   OFF-CHAIN WORKERS (Python)            │
│   Math Computation + Signing            │
├─────────────────────────────────────────┤
│                                         │
│  • Eigenvalues, Hodge, Laplacian        │
│  • Generate hash traces                 │
│  • SIGN results with private key        │
│  • Submit to Oracle Interface           │
│                                         │
└─────────────────────────────────────────┘
              ↓ (signed computation)
┌─────────────────────────────────────────┐
│   ORACLE INTERFACE (Rust)               │
│   Communication Layer ONLY              │
├─────────────────────────────────────────┤
│                                         │
│  • Receive signed computations          │
│  • Verify signatures                    │
│  • Verify hash traces                   │
│  • Aggregate multiple submissions       │
│  • Forward to chain (NO math!)          │
│                                         │
└─────────────────────────────────────────┘
              ↓ (verified submission)
┌─────────────────────────────────────────┐
│   ON-CHAIN NODE (Rust)                  │
│   Consensus + State                     │
├─────────────────────────────────────────┤
│                                         │
│  • Accept oracle submissions            │
│  • Check √2 bounds                      │
│  • Block validation                     │
│  • State transitions                    │
│  • Secure memory                        │
│                                         │
└─────────────────────────────────────────┘
```

---

## Repository Structure

### Option A: Monorepo (Recommended)

```
homotopical-encrypt/  (Single repo)
├── src/              (Python - math computation)
│   ├── geometry/     (Laplacian, Hodge - stays Python)
│   ├── crypto/       (Encryption, hashing)
│   ├── invariants/   (Invariant computation)
│   └── chain/        (Wallet, routing - Python prototype)
│
├── rust/
│   ├── oracle/       (Interface layer)
│   │   ├── receiver.rs     (Receive signed computations)
│   │   ├── verifier.rs     (Verify signatures/hashes)
│   │   ├── aggregator.rs   (Collect multiple submissions)
│   │   └── submitter.rs    (Forward to chain)
│   │
│   └── node/         (On-chain)
│       ├── consensus/     (PoV verification)
│       ├── network/       (libp2p)
│       ├── storage/       (Block store)
│       └── mempool/       (TX pool)
│
└── docs/
```

**Benefits**:
- Single source of truth
- Easier development workflow
- Shared documentation
- Atomic commits across layers

### Option B: Separate Repos

```
homotopical-encrypt/          (Python - computation)
homotopical-encrypt-oracle/   (Rust - interface)
homotopical-encrypt-node/     (Rust - chain)
```

**Benefits**:
- Clear separation of concerns
- Independent versioning
- Different deployment cycles

**Recommendation**: **Monorepo** - development is easier, deployment can still be separate.

---

## Clean Separation of Concerns

### Layer 1: Off-Chain Workers (Python)

**Location**: `src/` (existing Python code)

**Responsibilities**:
- Compute eigenvalues (expensive!)
- Hodge decomposition
- Laplacian operations
- Invariant validation
- Generate hash traces
- **SIGN results with worker's key**

**Does NOT**:
- Talk to chain directly
- Handle networking
- Manage consensus

**Example Worker**:
```python
# src/oracle_worker/computation_service.py

class ComputationWorker:
    def __init__(self, worker_private_key):
        self.private_key = worker_private_key
        
    def compute_spectral_proof(self, topology: Dict) -> SignedComputation:
        """Compute spectral gap and sign result."""
        
        # 1. Do the math (expensive!)
        laplacian = build_laplacian(topology)
        eigenvalues = compute_eigenvalues(laplacian)
        spectral_gap = eigenvalues[1]
        
        # 2. Build hash trace
        trace = ComputationTrace()
        trace.add_step("build_laplacian", hash(topology), hash(laplacian))
        trace.add_step("eigendecomp", hash(laplacian), hash(eigenvalues))
        trace.add_step("extract_gap", hash(eigenvalues), hash(spectral_gap))
        
        # 3. SIGN the result
        signature = self.sign(spectral_gap, trace)
        
        # 4. Submit to oracle interface
        return SignedComputation(
            result=spectral_gap,
            trace=trace,
            worker_signature=signature,
            worker_pubkey=self.public_key()
        )
```

### Layer 2: Oracle Interface (Rust)

**Location**: `rust/oracle/`

**Responsibilities**:
- Receive signed computations from workers
- Verify worker signatures
- Verify hash traces
- Aggregate multiple worker submissions
- Check consensus (majority agree?)
- Forward verified results to chain

**Does NOT**:
- Compute eigenvalues
- Run Hodge decomposition
- Do any heavy math

**Example Oracle**:
```rust
// rust/oracle/src/interface.rs

pub struct OracleInterface {
    // Registered worker public keys
    trusted_workers: HashSet<PublicKey>,
    
    // Pending submissions
    pending: HashMap<RequestId, Vec<SignedComputation>>,
}

impl OracleInterface {
    // Receive computation from worker
    pub async fn receive_computation(
        &mut self,
        submission: SignedComputation,
    ) -> Result<()> {
        // 1. Verify worker signature
        if !self.verify_worker_signature(&submission) {
            return Err("Invalid worker signature");
        }
        
        // 2. Verify hash trace
        if !submission.trace.verify() {
            return Err("Invalid hash trace");
        }
        
        // 3. Add to pending
        self.pending
            .entry(submission.request_id)
            .or_insert(vec![])
            .push(submission);
        
        // 4. Check if we have consensus
        if let Some(consensus) = self.check_consensus(submission.request_id) {
            // Forward to chain
            self.submit_to_chain(consensus).await?;
        }
        
        Ok(())
    }
    
    // Check if multiple workers agree
    fn check_consensus(&self, request_id: RequestId) -> Option<Consensus> {
        let submissions = self.pending.get(&request_id)?;
        
        // Need at least 3 workers
        if submissions.len() < 3 {
            return None;
        }
        
        // Find majority result
        let mut results = HashMap::new();
        for sub in submissions {
            *results.entry(sub.result).or_insert(0) += 1;
        }
        
        // 2/3 consensus required
        let threshold = (submissions.len() * 2) / 3;
        for (result, count) in results {
            if count >= threshold {
                return Some(Consensus {
                    result,
                    worker_signatures: submissions.iter()
                        .filter(|s| s.result == result)
                        .map(|s| s.worker_signature.clone())
                        .collect(),
                });
            }
        }
        
        None
    }
    
    // Forward to chain
    async fn submit_to_chain(&self, consensus: Consensus) -> Result<()> {
        // Just communication - no computation!
        self.chain_client.submit_spectral_proof(consensus).await
    }
}
```

### Layer 3: On-Chain Node (Rust)

**Location**: `rust/node/`

**Responsibilities**:
- Receive oracle submissions
- Verify oracle signatures
- Check simple bounds (√2)
- Block validation
- Consensus (PoV)
- State machine
- Secure memory

**Does NOT**:
- Compute anything expensive
- Run eigenvalue decompositions

**Example Node**:
```rust
// rust/node/src/consensus/pov_verifier.rs

pub struct PoVVerifier {
    oracle_pubkey: PublicKey,
}

impl PoVVerifier {
    pub fn verify_spectral_proof(
        &self,
        proof: &OracleSubmission,
    ) -> bool {
        // 1. Verify oracle signature
        if !self.verify_oracle_sig(proof) {
            return false;
        }
        
        // 2. Check √2 bounds (SIMPLE!)
        let gap = proof.spectral_gap;
        if gap < 1.0/SQRT2 || gap > 2.0*SQRT2 {
            return false;
        }
        
        // 3. Verify worker consensus (oracle did this, we just check)
        if proof.worker_signatures.len() < 3 {
            return false;
        }
        
        // That's it! No heavy computation on-chain
        true
    }
}
```

---

## Security Model

### Trust Model

**Workers (Python)**:
- Staked (can be slashed)
- Multiple workers compute independently
- Results are signed
- Majority consensus required

**Oracle (Rust)**:
- Trusted interface (or decentralized set)
- Verifies worker signatures
- Aggregates submissions
- Forwards only consensus results

**Chain (Rust)**:
- Trusts oracle (verified signature)
- Double-checks simple properties (√2 bounds)
- Final authority on state

### Attack Resistance

**Malicious Worker**:
- Single worker can't fake result (need consensus)
- Invalid computation detected via hash trace
- Worker is slashed

**Compromised Oracle**:
- Can't fake worker signatures (cryptographically secured)
- Chain verifies oracle signature
- Multiple oracles possible (decentralize)

**Chain Level**:
- Only accepts signed oracle submissions
- Verifies simple bounds
- No trust in computation itself (verified off-chain)

---

## Communication Flow

### 1. User Submits Transaction

```
User → Chain: "Here's my transaction"
Chain: "Need spectral proof"
Chain → Oracle: "Request computation for topology X"
Oracle → Workers: "Who can compute this?"
```

### 2. Workers Compute

```
Worker 1 (Python):
  - Compute eigenvalues
  - Generate hash trace
  - Sign result
  - Submit to Oracle

Worker 2 (Python):
  - Same computation independently
  - Sign their result
  - Submit to Oracle

Worker 3 (Python):
  - Same computation independently
  - Sign their result
  - Submit to Oracle
```

### 3. Oracle Aggregates

```
Oracle (Rust):
  - Receives 3 submissions
  - Verifies all signatures
  - Verifies all hash traces
  - Checks consensus (do 2/3 agree?)
  - Forwards consensus to Chain
```

### 4. Chain Validates

```
Chain (Rust):
  - Receives oracle submission
  - Verifies oracle signature
  - Checks √2 bounds
  - Accepts transaction with proof
  - Updates state
```

---

## Why This is Secure

✅ **No Single Point of Failure**: Multiple workers compute

✅ **Cryptographic Security**: All results are signed

✅ **Hash-Traced**: Computation steps are verifiable

✅ **Consensus**: Majority agreement required

✅ **Slashing**: Bad actors lose stake

✅ **Lightweight Chain**: No expensive computation on-chain

✅ **Clean Separation**: Each layer does one thing well

---

## Rust Module Responsibilities

### `rust/oracle/` (Interface ONLY)

```rust
mod receiver;    // Receive signed computations from workers
mod verifier;    // Verify signatures and hash traces
mod aggregator;  // Collect multiple submissions, find consensus
mod submitter;   // Forward to chain
mod types;       // Shared types (SignedComputation, Consensus, etc.)
```

**NO**math heavy operations here!

### `rust/node/` (Chain)

```rust
mod consensus;   // PoV verification (verify oracle submissions)
mod network;     // P2P (libp2p)
mod storage;     // Block/state storage
mod mempool;     // Transaction pool
mod crypto;      // Secure memory, hashing, signatures
```

**NO** eigenvalues, NO Hodge, NO Laplacian!

---

## Python Stays for Math

**Keep in Python**:
- ✅ All Laplacian operations
- ✅ Eigenvalue decomposition
- ✅ Hodge decomposition
- ✅ Invariant computation
- ✅ Geometric operations

**Why**:
- Already implemented
- NumPy/SciPy are fast enough for off-chain
- Easy to iterate on math
- Workers don't need to be ultra-fast (not on critical path)

**When to port to Rust**:
- If workers become bottleneck (profile first!)
- If we need better memory security for workers
- For production hardening

**But NOT required** - Python is fine for off-chain computation!

---

## Summary

**Python** (src/):
- Does ALL the heavy math
- Signs results
- Submits to oracle

**Rust Oracle** (rust/oracle/):
- Communication interface
- Verifies signatures
- Aggregates consensus
- Forwards to chain
- **NO MATH**

**Rust Node** (rust/node/):
- Consensus
- Blocks
- State
- Secure memory
- **NO HEAVY MATH**

**Result**: Clean separation, secure, scalable

**Beautiful part**: Oracle is thin interface layer - all it does is verify, aggregate, communicate. Math stays where it's easy (Python), consensus stays where it's secure (Rust).
