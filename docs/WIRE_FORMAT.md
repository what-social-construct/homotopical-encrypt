# Wire Format: What Messages Actually Look Like

## TL;DR

A homotopical ciphertext looks like this on the wire:

```
00000000  01 00 00 00 a3 f2 7b e4  5c 89 12 d4 a1 b3 c5 e7  |......{.\.......|
00000010  f9 0a 1b 2c 3d 4e 5f 60  71 82 93 a4 b5 c6 d7 e8  |...,=N_`q.......|
00000020  [... topology hash ...]  [... sender fingerprint ...]
00000080  [... vertex blocks ...]  [... edge syndromes ...]
```

**~1.5KB for 2-party, scales as O(n²) with parties.**

---

## Concrete Example: "Hello Bob"

Let's encrypt "Hello Bob" from Alice to Bob with λ=64.

### 1. Input

```
Plaintext: "Hello Bob" (9 bytes)
Parties: [alice, bob]
Security: λ = 64 (64-dimensional Hilbert spaces)
Modulus: q = 12289
```

### 2. Topology (Čech Nerve)

```
Alice (v0) ─────── Bob (v1)
           edge e0

Nerve = {
    0: [(0,), (1,)],      # 2 vertices
    1: [(0, 1)],          # 1 edge
    2: []                 # no triangles
}
```

### 3. Message Encoding

```python
# "Hello Bob" → bits → lattice element

"Hello Bob" = b'\x48\x65\x6c\x6c\x6f\x20\x42\x6f\x62'

# Expand to bits (72 bits for 9 bytes)
bits = [0,0,0,1,0,0,1,0,  # 'H' = 0x48
        1,0,1,0,0,1,1,0,  # 'e' = 0x65
        0,0,1,1,0,1,1,0,  # 'l' = 0x6c
        ...]

# Encode in ℤ_q^64
# bit=1 → q/2 = 6144
# bit=0 → 0
message_lattice = [
    0, 0, 0, 6144, 0, 0, 6144, 0,     # 'H'
    6144, 0, 6144, 0, 0, 6144, 6144, 0,  # 'e'
    0, 0, 6144, 6144, 0, 6144, 6144, 0,  # 'l'
    ...
    random, random, ...  # pad to 64 dims
]
```

### 4. Fibration Structure (SECRET!)

```python
# Each vertex gets secret LWE key
vertex_keys = {
    0: [3847, 1029, 5832, ...],  # Alice's secret (64 values in ℤ_q)
    1: [9281, 4756, 2103, ...],  # Bob's secret
}

# Edge gets secret restriction map
edge_keys = {
    (0, 1): [[8723, 1234, ...],  # 64×64 matrix A ∈ ℤ_q^{64×64}
             [4521, 8932, ...],
             ...]
}
```

### 5. Ciphertext Construction

```python
# Vertex block 0 (Alice): message + noise
vertex_0 = message_lattice + gaussian_noise(σ=3)
         = [238, 12034, 7, 6182, ...]  # 64 values

# Vertex block 1 (Bob): random + noise  
vertex_1 = random(64) + gaussian_noise(σ=3)
         = [9823, 4512, 1029, ...]  # 64 values

# Edge syndrome: A @ v1 - v0 (mod q) + noise
syndrome = edge_keys[(0,1)] @ vertex_1 - vertex_0 + noise
         = [7823, 2941, 8102, ...]  # 64 values
```

---

## The Actual Bytes

### Header (132 bytes fixed)

```
Offset  Size  Field                    Hex Example
──────────────────────────────────────────────────────────
0x0000  4     version                  01 00 00 00
0x0004  32    topology_hash            a3 f2 7b e4 5c 89 12 d4
                                       a1 b3 c5 e7 f9 0a 1b 2c
                                       3d 4e 5f 60 71 82 93 a4
                                       b5 c6 d7 e8 f9 0a 1b 2c
0x0024  64    sender_fingerprint       7b e4 a3 f2 ... (64 bytes)
0x0064  24    nonce                    (random 24 bytes)
0x007C  8     timestamp                (unix timestamp, little-endian)
──────────────────────────────────────────────────────────
Total header: 132 bytes
```

### Body: Vertex Blocks

```
Offset  Size  Field                    Description
──────────────────────────────────────────────────────────
0x0084  4     num_vertices             02 00 00 00  (2 vertices)
0x0088  4     vertex_block_size        80 00 00 00  (128 bytes each)

--- Vertex Block 0 (Alice) ---
0x008C  2     vertex_id                00 00
0x008E  4     data_length              80 00 00 00  (128 bytes)
0x0092  128   vertex_data              [64 × int16, mod 12289]

        Example decoded values:
        bytes 0-1:   0x00EE = 238
        bytes 2-3:   0x2F02 = 12034  
        bytes 4-5:   0x0007 = 7
        bytes 6-7:   0x1826 = 6182
        ... (64 values total)

--- Vertex Block 1 (Bob) ---  
0x0112  2     vertex_id                01 00
0x0114  4     data_length              80 00 00 00
0x0118  128   vertex_data              [64 × int16]
```

### Body: Edge Syndromes

```
Offset  Size  Field                    Description
──────────────────────────────────────────────────────────
0x0198  4     num_edges                01 00 00 00  (1 edge)

--- Edge 0 Syndrome ---
0x019C  2     edge_v0                  00 00
0x019E  2     edge_v1                  01 00
0x01A0  4     syndrome_length          80 00 00 00  (128 bytes)
0x01A4  128   syndrome_data            [64 × int16]
```

### Total Size

```
Header:           132 bytes
Vertices (2×):    2 × (2 + 4 + 128) = 268 bytes
Edges (1×):       1 × (4 + 4 + 128) = 136 bytes
────────────────────────────────────────────
Total:            ~540 bytes (for λ=64)

With λ=256:       ~1,700 bytes
```

---

## JSON View (for debugging)

```json
{
  "version": 1,
  "topology": {
    "hash": "a3f27be45c8912d4a1b3c5e7f90a1b2c3d4e5f6071829394b5c6d7e8f90a1b2c",
    "vertices": 2,
    "edges": 1
  },
  "sender": {
    "fingerprint": "7be4a3f2...",
    "betti": [1, 0],
    "spectral_gap": 0.0234
  },
  "ciphertext": {
    "vertex_blocks": {
      "0": {
        "id": 0,
        "data_base64": "AOICLwcAhiYA...",
        "decoded_preview": [238, 12034, 7, 6182, "..."]
      },
      "1": {
        "id": 1,
        "data_base64": "T2YQE3ADSgA...",
        "decoded_preview": [9823, 4512, 1029, "..."]
      }
    },
    "edge_syndromes": {
      "0,1": {
        "data_base64": "j3ALdBLKHA...",
        "decoded_preview": [7823, 2941, 8102, "..."]
      }
    }
  },
  "metadata": {
    "nonce": "x7y2...",
    "timestamp": 1706097600,
    "timestamp_human": "2026-01-24T13:00:00Z"
  }
}
```

---

## Authenticated Message (with Cohomological MAC)

If we add authentication, the format extends:

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATED CIPHERTEXT                      │
├─────────────────────────────────────────────────────────────────┤
│  Header (132 bytes)                                              │
├─────────────────────────────────────────────────────────────────┤
│  Vertex Blocks                                                   │
│  ├── v0: [64 × int16] = 128 bytes                               │
│  └── v1: [64 × int16] = 128 bytes                               │
├─────────────────────────────────────────────────────────────────┤
│  Edge Syndromes                                                  │
│  └── e0: [64 × int16] = 128 bytes                               │
├─────────────────────────────────────────────────────────────────┤
│  Cohomological MAC (NEW!)                                        │
│  ├── harmonic_residual: [64 × float32] = 256 bytes              │
│  ├── projection_coeffs: [β₀ × float32] = 4 bytes (for β₀=1)     │
│  └── mac_hash: 32 bytes                                          │
├─────────────────────────────────────────────────────────────────┤
│  TOTAL: ~830 bytes                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## ZK Proof Attached

If sender includes ZK proof of identity:

```
┌─────────────────────────────────────────────────────────────────┐
│                    CIPHERTEXT + ZK PROOF                         │
├─────────────────────────────────────────────────────────────────┤
│  [Standard ciphertext: ~540 bytes]                               │
├─────────────────────────────────────────────────────────────────┤
│  Homotopy Proof:                                                 │
│  ├── commitment: 32 bytes                                        │
│  ├── betti_response: [β₀, β₁] = 8 bytes                         │
│  ├── spectral_gap: 8 bytes (float64)                            │
│  ├── eigenvalue_commitments: [10 × 32] = 320 bytes              │
│  ├── challenge_response: 32 bytes                                │
│  └── timestamp: 8 bytes                                          │
├─────────────────────────────────────────────────────────────────┤
│  TOTAL: ~950 bytes                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Comparison to Other Schemes

| Scheme | Ciphertext Size (256-bit security) |
|--------|-----------------------------------|
| RSA-2048 | 256 bytes |
| ECDH P-256 | 65 bytes (ephemeral) + 16+ (symmetric) |
| Kyber-768 | 1088 bytes |
| **Homotopical (2-party)** | ~1700 bytes |
| **Homotopical (n-party)** | O(n² × λ) bytes |

We're ~2× Kyber for 2-party, but we get:
- Native multi-party
- ZK-friendly structure
- Threshold built-in
- Key agility (homotopy equivalence)

---

## Example Code

```python
# Encrypt and inspect bytes
from homotopical_encrypt import generate_credential, encrypt

cred = generate_credential(
    parties=['alice', 'bob'],
    connections=[('alice', 'bob')],
    security_parameter=64
)

ct = encrypt(b"Hello Bob", cred)

# Serialize
wire_bytes = ct.serialize()
print(f"Total size: {len(wire_bytes)} bytes")
print(f"Hex dump:\n{wire_bytes[:64].hex()}")

# Output:
# Total size: 542 bytes
# Hex dump:
# 0100000001c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8091a2b3c4d5e6f...
```
