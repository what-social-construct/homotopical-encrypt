# Sheaf-Aware Storage Design

## The Beautiful Natural Transformation

You asked: "Shouldn't column families be stalks?"

**Answer**: YES! This is a genuine functor between categories!

```
Category SHEAF:              Category STORAGE:
─────────────────           ──────────────────
Objects:                    Objects:
  - Sheaf                     - Database
  - Stalks                    - Column families
  - Sections                  - Key-value pairs

Morphisms:                  Morphisms:
  - Projections               - Queries
  - Restrictions              - Filters
  - Gluing                    - Joins
```

## The Mapping

### Mathematical → Storage

**Stalk Contexts → Column Families**:
```
PRIVATE_STALK (dim=256) → CF "stalks_private"
PUBLIC_STALK (dim=1)    → CF "stalks_public"  
ZK_STALK (dim=32)       → CF "stalks_zk"
```

**Simplices → Keys**:
```
Vertex v          → Key: "vertex:v"
Edge (v0, v1)     → Key: "edge:v0:v1"
Face (v0, v1, v2) → Key: "face:v0:v1:v2"
```

**Stalk Data → Values**:
```
np.ndarray([256 floats]) → bincode serialize → bytes
```

**Sections → Batch Writes**:
```
Section = {v₀: s₀, v₁: s₁, ...}
        ↓
WriteBatch {
  CF("stalks_public")[v₀] = s₀.serialize()
  CF("stalks_public")[v₁] = s₁.serialize()
  ...
}
```

## Example: Account Balances

### Mathematical View
```python
# SheafState
bundle = StalkBundle(PUBLIC_STALK)
bundle.set_stalk(0, Stalk.from_value(1000.0))  # Alice: 1000
bundle.set_stalk(1, Stalk.from_value(500.0))   # Bob: 500
```

### Storage View
```rust
// SheafStore
store.set_stalk(
    StalkContext::Public,
    0,  // Alice
    &Stalk::from_value(1000.0)
);
store.set_stalk(
    StalkContext::Public,
    1,  // Bob
    &Stalk::from_value(500.0)
);
```

### On Disk
```
RocksDB:
├── CF: stalks_public/
│   ├── vertex:0 → [1000.0]  (1 float, 8 bytes)
│   └── vertex:1 → [500.0]   (1 float, 8 bytes)
├── CF: stalks_private/
│   ├── vertex:0 → [256 floats] (2KB)
│   └── vertex:1 → [256 floats] (2KB)
└── CF: stalks_zk/
    └── (empty for now)
```

## Natural Transformations

### Projection: Private → Public

**Mathematical**:
```python
PRIVATE_TO_PUBLIC: StalkProjection
  source = PRIVATE_STALK (dim=256)
  target = PUBLIC_STALK (dim=1)
  matrix = [1, 0, 0, ..., 0]  # Take first component

result = PRIVATE_TO_PUBLIC(private_stalk)
```

**Storage**:
```rust
// Functorial!
store.project_to_public(vertex_id)
  → get from CF "stalks_private"
  → apply projection (dim 256 → dim 1)
  → store in CF "stalks_public"
```

This is a **natural transformation** because:
1. It preserves structure (vertex IDs)
2. Commutes with restrictions (subsets of vertices)
3. Functorial (maps between functors)

## Advantages of Sheaf-Aware Storage

### 1. Conceptual Clarity
```
Blocks? Just 0-simplices with special data
Edges? 1-simplices (connections)
State? Section of PUBLIC_STALK bundle
```

### 2. Type Safety
```rust
// Can't mix contexts!
let private: Stalk = get_stalk(Private, v); ✅
let public: Stalk = get_stalk(Public, v);   ✅

set_stalk(Public, v, private); ❌ Type error!
```

### 3. Natural Operations
```rust
// These operations have geometric meaning!
store.project_to_public(v)     // Projection
store.get_section(Public)       // Global section
store.restrict_to(vertices)     // Restriction
store.glue(section1, section2)  // Gluing (future)
```

### 4. Cohomology-Ready
```rust
// Store cochains naturally
store.set_edge_data(
    Public,
    v0, v1,
    cochain_data  // ∈ C¹(X; ℝ)
);

// Boundary maps become queries!
let d0 = store.boundary_0();  // δ⁰: C⁰ → C¹
let d1 = store.boundary_1();  // δ¹: C¹ → C²
```

## Implementation Status

### ✅ Implemented (`sheaf_store.rs`)
- StalkContext enum (Private, Public, ZK)
- Stalk struct with serialization
- SimplexKey (Vertex, Edge, Face)
- SheafStore with get/set operations
- Projection (Private → Public)
- Section operations (batch write/read)
- Full test suite

### 🎯 Next Steps
1. Compare performance: SheafStore vs plain RocksDB
2. Add gluing conditions validation
3. Implement restriction operators
4. Add cohomology operations (boundary maps)
5. Benchmark on real chain data

## Comparison: Both Approaches

### SheafStore (Mathematical)
```rust
// Natural, sheaf-aware
store.set_stalk(Public, vertex, stalk);
store.get_section(Public);
store.project_to_public(vertex);
```

**Pros**:
- ✅ Mathematically consistent
- ✅ Type-safe (contexts enforced)
- ✅ Natural transformations explicit
- ✅ Ready for cohomology

**Cons**:
- ⏱️ Need to benchmark performance
- 🆕 New abstraction to learn

### BlockStore (Traditional)
```rust
// Plain key-value
store.store_block(block);
store.load_block(height);
```

**Pros**:
- ✅ Simple, proven pattern
- ✅ Performance well-understood
- ✅ Standard blockchain approach

**Cons**:
- ❌ No mathematical structure
- ❌ Just bytes (lose sheaf awareness)
- ❌ Manual serialization everywhere

## Recommendation

**Use BOTH**:

```rust
pub enum Storage {
    Sheaf(SheafStore),      // For state, balances, credentials
    Blocks(BlockStore),     // For blocks, transactions
}
```

**SheafStore** for:
- Account balances (PUBLIC_STALK)
- Private credentials (PRIVATE_STALK)
- ZK proofs (ZK_STALK)
- Anything with sheaf structure!

**BlockStore** for:
- Blocks (no sheaf structure)
- Transactions (already serialized)
- Key images (just a set)

## The Beauty

**Storage becomes a functor**:
```
F: SHEAF → ROCKSDB

F(Stalk)    = Column Family
F(Vertex)   = Key
F(Section)  = KeyValue Pairs
F(Project)  = Query + Write
```

This isn't just a metaphor - it's a genuine categorical construction!

We're not "storing sheaves" - we're **functorially embedding sheaves into storage**! 🎨📐

## Let's Implement Both and Compare! 🚀
