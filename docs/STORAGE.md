# storage

## sheaf-theoretic storage structure

Storage embeds the sheaf into a persistence layer via a functor
F: Sh(X) → RocksDB that maps mathematical objects to column families:

```
    F(Stalk)     = column family (stalks_private, stalks_public, stalks_zk)
    F(Vertex v)  = key "vertex:v"
    F(Edge e)    = key "edge:v0:v1"
    F(Section)   = batch write over keys
    F(Projection) = query + context change
```

Three stalk contexts determine the column families:

```
    PRIVATE_STALK  (dim=256)  → CF "stalks_private"   full credential
    PUBLIC_STALK   (dim=1)    → CF "stalks_public"    balance commitment
    ZK_STALK       (dim=32)   → CF "stalks_zk"        zero-knowledge intermediate
```

The projection PRIVATE → PUBLIC is a natural transformation:
it preserves vertex identity and commutes with restrictions.

## on-chain vs off-chain

Two sheaves F_full and F_hash over the same base space X (the nerve
of accounts), connected by a natural transformation η: F_full → F_hash:

```
    F_full(v) ──η_v──→ F_hash(v)

    credential (256-dim)    ↦  hash (32 bytes)
    eigenvalues (n-dim)     ↦  spectral_gap (f64)
    cohomology groups       ↦  betti_numbers (i32, i32, i32)
    full fibration          ↦  topology_hash (32 bytes)
```

Naturality condition (consistency across topology):

```
         F_full(v) ──η_v──→ F_hash(v)
             │                  │
        F_full(e)          F_hash(e)
             │                  │
             ▼                  ▼
         F_full(w) ──η_w──→ F_hash(w)
```

F_hash(e) ∘ η_v = η_w ∘ F_full(e) for every edge e: v → w.

This yields an exact sequence for privacy:

```
    0 → ker(η) → F_full → F_hash → 0

    ker(η) := private data (fibration secrets, restriction maps)
    F_full := complete off-chain state
    F_hash := public on-chain commitments
```

Verification uses only F_hash. The blockchain := Γ(X, F_hash),
a section of hash commitments.

On-chain (F_hash, public, verified by all nodes):
- key images (double-spend prevention)
- cochain commitments, roots, or public shadows (amount balance proofs)
- spectral proofs (validity of fibration structure)
- topology nerve (public connection graph)

Off-chain (ker(η), private, held by parties):
- fibration secrets (restriction maps, stalks)
- full cochains and witness payloads unless explicitly marked public
- full ciphertexts (relayed via onion network)
- decryption keys (wallet-local)

The boundary between on-chain and off-chain is exactly the kernel
of η, which is determined by the fibration credential structure:
credential := (topology [public], fibration [private], spectrum [public]).

## verified encrypted data layer

The storage model should behave like a verified encrypted database with a
public proof ledger.

Full `SheafState` objects, private stalks, fibration representatives, homotopy
paths, openings, and raw cochain witnesses are stored encrypted by default.
Consensus stores only bounded handles and verification artifacts:

```
encrypted object / private witness blob
  → content hash or authenticated storage root
  → public shadow / cochain commitment / topology hash
  → proof-carrying artifact or oracle attestation
  → ledger state transition
```

This means a node should not have to decrypt full state to validate consensus.
It checks canonical bytes, roots, inclusion proofs, nullifiers, commitments,
oracle attestations, and proof statements against public inputs. Decryption is
for data owners or explicitly modeled threshold/deferred contexts, not for the
ordinary consensus path.

Public by default:
- hashes, roots, key images/nullifiers, topology hashes
- public stalks/shadows and bounded summaries
- proof bytes, oracle attestations, verification results

Encrypted by default:
- private stalks and fibration representatives
- full `SheafState` payloads
- full cochains/openings/witness data
- homotopy path material and private transaction bodies

## rust storage (rust/node/src/storage/)

```
sheaf_store.rs   sheaf-native storage: stalks indexed by cell, restrictions by edge
                 column families mirror stalk contexts (PRIVATE/PUBLIC/ZK)
                 sections stored as batch writes over vertex keys
blocks.rs        block storage with merkle proofs
state.rs         global state management (UTXO set, account balances)
keyimages.rs     spent key image set (bloom filter + backing store)
```

SheafStore maps storage operations to their geometric meaning:

```
    store.set_stalk(ctx, v, s)    →  assign stalk s to vertex v in context ctx
    store.get_section(ctx)        →  read global section Γ(X, F_ctx)
    store.project_to_public(v)    →  apply η_v: F_full(v) → F_hash(v)
    store.boundary_0()            →  coboundary δ⁰: C⁰ → C¹ as query
```

## wallet storage (src/chain/wallet_store.py)

Master key derivation: the spectral fingerprint of the master fibration
serves as both identity and encryption key. No separate key management.

Encryption process:
1. serialize credential to bytes
2. encrypt using master credential's Hodge system
   (message → ker(Δ), noise → im(δ) ⊕ im(δ*))
3. extract public metadata (fingerprint, topology hash)
4. compute expected invariants (Betti numbers, spectral gap)
5. store as labeled JSON

Decryption process:
1. load encrypted credential from wallet file
2. decrypt via harmonic projection using master credential
3. deserialize bytes back to credential structure
4. validate ALL invariants using UnifiedInvariantValidator
5. return credential if valid, None otherwise (fail loudly)

Key rotation: new master must be homotopy equivalent to old master
(same spectral fingerprint). Rotation changes the fibration while
preserving identity. Compromising the new key does not expose old
messages (forward secrecy by construction).

## chain storage (src/chain/chain_store.py)

The public ledger data is public by design: transparent consensus needs stable
bytes, roots, and proofs. Private state is not stored there in plaintext; the
ledger stores encrypted-object pointers, commitments, roots, nullifiers, and
proof-carrying artifacts.

```
data_dir/
├── blocks/           block files by height ({height:06d}.block)
├── state/            current state snapshots (JSON SheafState)
├── keyimages/        spent key image tracking (JSON hex list)
├── index/            hash ↔ height mappings
└── meta/             chain metadata
```

State uses harmonic projection model: account → harmonic balance,
not UTXO. Key images prevent double-spending via homotopy-path-based
image hashes.

## constant-size padding (src/crypto/padding.py)

All packets padded to 4096 bytes (4KB fixed). Format:

```
    [original_data] [random_padding] [length_marker (4 bytes)]
```

Length marker: last 4 bytes encode original data length (big-endian).
Decoy packets are indistinguishable from real packets (random data,
same padding, same size).

Combined with mixing delays (MixingNode) and random relay paths,
this provides comprehensive traffic analysis resistance.

## python state (src/chain/)

```
sheaf_state.py   SheafState := unified state bus
                 mempool, key images, spectral cache, block headers
                 all mutations traced via HashChain
chain_store.py   persistent storage adapter (abstracts backend)
account.py       AccountState := sovereignty layer
                 spectral fingerprint identity, connections, key rotation
wallet_store.py  wallet-local encrypted credential storage
```

## routing

Onion-routed via fiber bundle transport. The mathematical structure
is a fiber bundle π: E → B:

```
    B   := network graph (base space)
    F_v := encryption context at relay v (fiber)
    R_{v→e} := transition functions (restriction maps)
```

Each relay has its own fiber F_v (stalk at vertex v). Messages are
encrypted per-hop using parallel transport along the bundle. Both
content and metadata (routing path) are encrypted. Constant-size
padding prevents traffic analysis (padding.py).
