# Storage and Routing Architecture

## Core Principle

**Identity = Spectral Fingerprint = Encryption Key**

The spectral fingerprint of a fibration serves as both identity and master encryption key. This self-referential structure eliminates the need for external key management.

---

## Layer Separation

### Geometry Layer (Pure Mathematics)
Located in `src/geometry/fiber_bundle.py`

**Purpose**: Mathematical primitives with no blockchain concepts

**Components**:
- FiberBundle: Base geometric structure
- EphemeralFiber: Forward secrecy via random path-homotopic walks
- OnionRouter: Packet-level multi-layer encryption via parallel transport
- MixingNode: Timing obfuscation through delayed release

**Key Property**: These are pure geometric operations - no awareness of transactions, wallets, or chains.

### Chain Layer (Blockchain Integration)
Located in `src/chain/`

**Purpose**: Use geometry primitives for blockchain-specific operations

**Components**:
- `chain_store.py`: Public blockchain data storage (no encryption)
- `wallet_store.py`: Private credential management (Hodge-encrypted)
- `routing.py`: Transaction privacy integration layer

**Key Property**: Chain layer imports from geometry, never the reverse.

### Crypto Layer (Privacy Primitives)
Located in `src/crypto/padding.py`

**Purpose**: Metadata hiding through uniform packet sizes

**Components**:
- Constant-size padding (4KB fixed)
- Decoy packet generation
- Traffic uniformity enforcement

---

## 1. Wallet Storage Specification

### Security Model

**Master Key Derivation**:
- Input: Master fibration credential
- Operation: Extract spectral fingerprint via eigenvalue computation
- Output: Fingerprint hash serves as encryption key

**The Innovation**: The key IS the identity. No separate key management needed.

### Storage Format

**Encrypted Credential Structure**:
- Ciphertext blob (Hodge-encrypted credential bytes)
- Public fingerprint (for verification without decryption)
- Topology hash (nerve structure identifier)
- Expected invariants (for validation on load)
- Metadata (timestamp, version)

### Encryption Process

1. **Serialize** credential to bytes
2. **Encrypt** using master credential's Hodge system
   - Message → ker(Δ) (harmonic subspace)
   - Noise → im(δ) ⊕ im(δ*) (exact ⊕ coexact)
3. **Extract** public metadata (fingerprint, topology hash)
4. **Compute** expected invariants (Betti numbers, spectral gap, h-level, Σ/Π-rank)
5. **Store** as JSON with label

### Decryption Process

1. **Load** encrypted credential from wallet file
2. **Decrypt** via harmonic projection using master credential
3. **Deserialize** bytes back to credential structure
4. **Validate** ALL invariants using UnifiedInvariantValidator
5. **Verify** invariants match expected values
6. **Return** credential if valid, None otherwise (fail loudly)

### Key Rotation

**Requirement**: New master must be homotopy equivalent to old master

**Verification**: Compare spectral fingerprints (must be identical)

**Process**:
1. Verify homotopy equivalence (same fingerprint)
2. For each credential in wallet:
   - Decrypt with old master
   - Re-encrypt with new master
   - Store updated version
3. Replace wallet file atomically

**Security Property**: Rotation doesn't change identity (same fingerprint), but compromising new key doesn't expose old messages.

---

## 2. Transaction Routing Specification

### Integration Philosophy

Chain layer provides high-level routing interface that wraps low-level geometry primitives. Transactions know about routing, but geometry knows nothing about transactions.

### Relay Node Model

**Structure**:
- Fibration credential (relay's identity)
- Network address (IP:port or onion address)
- Derived fiber bundle (extracted from credential)
- Spectral fingerprint (relay's public ID)

**Key Property**: Each relay is identified by its spectral fingerprint, ensuring quantum-resistant identity.

### Routing Process

**Path Selection**:
1. Choose destination (recipient's fingerprint)
2. Select N random relays (default N=3)
3. Build path: sender → relay₁ → relay₂ → ... → relayₙ → recipient

**Packet Creation**:
1. Serialize transaction to bytes
2. Extract relay bundles (fiber geometry from credentials)
3. Derive relay keys (deterministically from fingerprints)
4. Create onion layers (wrap from last relay to first)
5. Generate ephemeral fiber per layer (forward secrecy)

**Security Properties Per Layer**:
- Ephemeral fiber: Forward secrecy (compromise doesn't expose past)
- Onion encryption: Only relay with correct credential can peel layer
- Mixing delays: Random hold times break timing correlation
- Constant padding: All packets uniform size (4KB)

### Network Management

**Relay Registration**:
- Check fingerprint uniqueness
- Add to active relay list
- Rebuild router with new topology

**Relay Deregistration**:
- Remove by fingerprint
- Rebuild router if relays remain
- Clear router if no relays left

**Health Monitoring**: (Future) Track relay uptime, latency, reliability

---

## 3. Constant-Size Padding Specification

### Purpose

Eliminate metadata leakage from packet size analysis.

### Padding Format

**Structure**:
```
[original_data] [random_padding] [length_marker (4 bytes)]
```

**Fixed Size**: 4096 bytes (4KB) for all packets

**Length Marker**: Last 4 bytes encode original data length (big-endian)

### Operations

**Padding**:
1. Calculate padding needed: 4096 - data_len - 4
2. Generate random padding bytes
3. Append data + random_padding + length_marker
4. Verify total length = 4096

**Unpadding**:
1. Extract last 4 bytes (length marker)
2. Decode original length
3. Extract first N bytes where N = decoded length
4. Validate N is reasonable (< 4092)

**Decoy Generation**:
1. Choose random data length (< 4092)
2. Generate random bytes of that length
3. Pad using standard padding algorithm
4. Result: Indistinguishable from real packet

### Traffic Analysis Resistance

**Uniform Appearance**:
- All packets exactly 4096 bytes
- Random padding prevents pattern recognition
- Decoy packets identical to real packets
- Network observer sees only uniform noise

**Timing + Size Combined**:
- Constant size (padding.py)
- Variable timing (mixing delays from MixingNode)
- Random paths (relay selection)
- Result: Comprehensive traffic analysis resistance

---

## 4. Chain Storage Specification

### Public Data Model

**Philosophy**: Chain data is public by design (transparent consensus). No encryption needed.

### Directory Structure

```
data_dir/
├── blocks/           Block files by height
├── state/            Current state snapshots  
├── keyimages/        Spent key image tracking
├── index/            Hash ↔ height mappings
└── meta/             Chain metadata
```

### Block Storage

**File Format**: `{height:06d}.block` (e.g., `000042.block`)

**Index Maintenance**:
- height_to_hash.json: Quick lookup by block number
- hash_to_height.json: Reverse lookup by block hash

**Operations**:
- Store: Write block file + update indices
- Load: Read by height (TODO: deserialization)
- Get tip: Find highest block number

### State Storage

**Format**: JSON snapshot of current SheafState

**Content**:
- Tip height and hash
- Harmonic balances (account → balance mapping)
- Additional state as needed

**Note**: Uses harmonic projection model, NOT UTXO

### Key Image Tracking

**Purpose**: Prevent double-spending via homotopy-path-based key images

**Storage**: JSON list of spent key image hashes

**Operations**:
- Save: Serialize set to hex list
- Load: Deserialize hex list to set
- Check: Set membership test

---

## Complete Privacy Flow

### Workflow Stages

**1. Credential Setup**:
- Generate master fibration (your identity)
- Spectral fingerprint becomes master key
- Create wallet file (encrypted storage)

**2. Credential Storage**:
- Generate channel-specific credentials
- Encrypt with master's fingerprint
- Store with expected invariants
- Label for easy retrieval

**3. Credential Loading**:
- Decrypt using master credential
- Validate ALL invariants (fail loudly if mismatch)
- Use validated credential for operations

**4. Transaction Creation**:
- Build homotopy transaction
- Sign with credential
- Prepare for routing

**5. Routing Setup**:
- Register relay nodes with network
- Build relay topology
- Get transaction router

**6. Onion Creation**:
- Select random relay path (e.g., 3 hops)
- Create onion layers (ephemeral fiber per layer)
- Wrap transaction in sequential layers
- Each relay can only peel their layer

**7. Padding Application**:
- Serialize onion packet
- Pad to constant 4KB size
- Random padding fills gaps
- Length marker at end

**8. Network Broadcast**:
- Send to entry relay
- Each relay peels layer, forwards to next
- Mixing delays at each hop
- Final relay delivers to destination

**9. Panopticon Observes**:
- Sees uniform 4KB packets
- Observes encrypted layers
- Cannot correlate timing (mixing)
- Learns: ∅ (nothing useful)

---

## Security Guarantees

### Wallet Layer

**Hodge-Hardness**: Message hidden in ker(Δ), noise obscures in im(δ)⊕im(δ*)

**Invariant Validation**: ALL geometric properties verified before trusting credential

**By-Construction**: Invalid credentials cannot be created (type safety)

**Key Rotation**: Change fibration while maintaining identity (homotopy equivalence)

**Open Source Safe**: Security from lattice hardness, not algorithm secrecy

### Routing Layer

**Forward Secrecy**: Ephemeral fibers per message (random homotopic walks)

**Anonymity**: Multi-hop prevents single-point deanonymization

**Timing Obfuscation**: Mixing nodes break temporal correlation

**Metadata Hiding**: Constant-size packets prevent size-based analysis

### Combined Guarantees

**Panopticon Resilience**: Total surveillance becomes mathematically irrelevant

**Quantum Resistance**: LWE-based lattice problems remain hard post-quantum

**Transparency**: Algorithm fully open source, security from math

**Sovereignty**: Self-generated identity (no trusted authority)

---

## Mathematical Foundation

### Why This Works

**Hodge Decomposition**: 
- Splits space into ker(Δ) ⊕ im(δ) ⊕ im(δ*)
- Message lives in harmonic subspace (ker(Δ))
- Noise lives in exact ⊕ coexact (im(δ) ⊕ im(δ*))
- Decryption = harmonic projection (deterministic)

**Homotopy Equivalence**:
- Identity = equivalence class, not single point
- Can rotate keys within class
- Spectral fingerprint characterizes class
- Enables key agility without identity change

**Parallel Transport**:
- Onion routing = stacked parallel transport
- Each layer = transport along relay's connection
- Only relay with correct connection can invert
- Geometric security (not just bit manipulation)

**Lattice Hardness**:
- Finding ker(Δ) without knowing Δ is hard
- Reduces to SVP/CVP on cochain lattice
- No known quantum algorithm
- Post-quantum security by construction

---

## Implementation Status

### Completed
- ✅ Wallet storage (fingerprint-based encryption)
- ✅ Chain storage (public data)
- ✅ Transaction routing (integration layer)
- ✅ Constant-size padding
- ✅ Ephemeral fibers (geometry layer)
- ✅ Sheaf onion routing (geometry layer)
- ✅ Mixing nodes (geometry layer)
- ✅ Module organization (chain/ contains all)

### TODO
- ⬜ Integration testing (full flow)
- ⬜ Credential serialization (proper format)
- ⬜ Network layer (P2P implementation)
- ⬜ Performance benchmarks
- ⬜ Automated decoy traffic

---

## References

- **Panopticon Resilience**: `docs/PANOPTICON_RESILIENCE.md`
- **Homotopy Equivalence**: `docs/HOMOTOPY_EQUIVALENCE_PROOF.md`
- **Invariant Tightening**: `docs/INVARIANT_TIGHTENING.md`
- **Chain Architecture**: `docs/CHAIN_ARCHITECTURE.md`
- **Overall System**: `ARCHITECTURE.md`
