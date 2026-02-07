# Invariant Philosophy: Validation vs. By-Construction

## The Question

In chloe_protocol, invariant validation makes sense:
- Multiple agents can produce bad signals
- Need mathematical supervision for learning
- Runtime checking catches violations

**But in cryptography, should we use the same pattern?**

---

## Two Approaches

### 1. Runtime Validation (chloe_protocol style)

```python
# Generate credential
cred = generate_credential(...)

# Check after
validator = InvariantValidator()
violations = validator.validate(cred)
if violations:
    raise InvalidCredential(violations)
```

**Pros:**
- Catches bugs
- Same pattern everywhere
- Can handle external inputs

**Cons:**
- Implies the system might produce invalid outputs
- Overhead on every operation
- Not how crypto usually works

### 2. By-Construction Guarantees (crypto style)

```python
# The construction GUARANTEES invariants
# If it returns, it's valid. If it can't satisfy, it raises.

def generate_credential(...):
    topology = build_connected_topology(...)  # ALWAYS connected
    # Can't even create if β₀ ≠ 1
    
    fibration = generate_lwe_fibration(...)
    # Full rank by construction
    
    return Credential(...)  # Valid by construction
```

**Pros:**
- No runtime overhead
- Stronger guarantee (can't even create invalid)
- Standard crypto pattern

**Cons:**
- Harder to implement
- Can't validate external inputs this way

---

## My Recommendation: BOTH, Different Roles

### For Internal Operations: By-Construction

The internal crypto operations should be **correct by construction**:

```python
class Credential:
    def __init__(self, ...):
        # These are NOT optional checks - they're assertions about our code
        assert self._is_connected(), "BUG: topology not connected"
        assert self._spectral_gap() > 0, "BUG: no spectral gap"
        # If we hit these, it's a bug in generation, not bad input
```

### For External Inputs: Validation

When receiving data from outside (network, files), validate:

```python
class CiphertextValidator:
    """Validates incoming ciphertexts from untrusted sources."""
    
    def validate(self, ciphertext: bytes) -> Result[Ciphertext, ValidationError]:
        # Parse
        try:
            ct = Ciphertext.deserialize(ciphertext)
        except:
            return Err(ParseError())
        
        # Check structure
        if not self._valid_topology_hash(ct):
            return Err(TopologyMismatch())
        
        # Check bounds
        if not self._values_in_range(ct):
            return Err(ValueOutOfRange())
        
        return Ok(ct)
```

### For ZK Proofs: Verification IS the Point

ZK proofs are DESIGNED to be verified:

```python
def verify_homotopy_proof(proof, statement) -> bool:
    """This IS the security - not a "check", it's the protocol."""
    
    # These aren't optional validations - they're the verification algorithm
    if proof.betti != statement.betti:
        return False  # Proof invalid
    
    if abs(proof.spectral_gap - statement.spectral_gap) > tolerance:
        return False  # Proof invalid
    
    return True  # Proof valid
```

---

## The Homotopical Insight

Here's why homotopy makes this cleaner:

**Traditional crypto:**
- Correctness: `Decrypt(Encrypt(m)) = m`
- This is a THEOREM about the algorithm

**Homotopical crypto:**
- Correctness: `Decrypt(Encrypt(m)) ≃ m` (homotopy equivalent)
- The "error" is absorbed into the equivalence class
- Decryption finds ANY representative of the harmonic class

This means:
- We don't need exact bit-matching
- The invariants (β₀, λ₁) determine the EQUIVALENCE CLASS
- Validation becomes: "is this in the same homotopy class?"

---

## Concrete Design

```python
# ============================================================================
# LAYER 1: Type-Level Invariants (by construction)
# ============================================================================

@dataclass(frozen=True)  # Immutable = can't become invalid
class ConnectedTopology:
    """A topology that is GUARANTEED connected (β₀ = 1)."""
    nerve: Dict[int, List[Tuple]]
    
    def __post_init__(self):
        if not self._is_connected():
            raise ValueError("Topology must be connected")
    
    @classmethod
    def complete_graph(cls, n: int) -> 'ConnectedTopology':
        """Complete graphs are always connected."""
        ...  # Can't fail


@dataclass(frozen=True)
class PositiveSpectralGap:
    """A Laplacian guaranteed to have λ₁ > 0."""
    laplacian: np.ndarray
    spectral_gap: float  # Computed at construction
    
    def __post_init__(self):
        if self.spectral_gap <= 0:
            raise ValueError("Spectral gap must be positive")


# ============================================================================
# LAYER 2: Smart Constructors (can fail, but output always valid)
# ============================================================================

def generate_credential(
    parties: List[str],
    connections: List[Tuple[str, str]],
    security_parameter: int
) -> Result[FibrationCredential, GenerationError]:
    """
    Generate credential. Returns Err if requirements can't be met.
    Returns Ok(credential) only if ALL invariants satisfied.
    """
    # Build topology
    topology = ConnectedTopology.from_parties(parties, connections)
    if topology is None:
        return Err(DisconnectedTopology())
    
    # Generate fibration with spectral gap
    fibration = generate_fibration_with_gap(topology, security_parameter)
    if fibration is None:
        return Err(NoSpectralGap())
    
    # If we get here, EVERYTHING is valid
    return Ok(FibrationCredential(topology, fibration))


# ============================================================================
# LAYER 3: Verification (for external inputs)
# ============================================================================

def verify_ciphertext(
    ct: bytes,
    expected_topology: ConnectedTopology
) -> Result[ValidCiphertext, VerificationError]:
    """Verify incoming ciphertext from network."""
    ...

def verify_proof(
    proof: HomotopyProof,
    statement: HomotopyStatement
) -> bool:
    """ZK verification - this IS the security."""
    ...
```

---

## Summary

| Layer | Purpose | Pattern |
|-------|---------|---------|
| Type-level | Impossible to represent invalid | Newtype + validation in constructor |
| Generation | Create valid outputs | Smart constructors returning Result |
| Verification | Check external inputs | Explicit validation returning Result |
| ZK Proofs | This IS the protocol | Verification algorithm |

**The chloe_protocol InvariantValidator pattern is RIGHT for:**
- Checking agent proposals (external, untrusted)
- Validating received messages
- ZK proof verification

**But we also need by-construction guarantees for:**
- Internal type safety
- Key generation (can't create invalid key)
- Ensuring our code is correct

---

## Philosophical Note

In homotopy type theory, this is the distinction between:
- **Propositions** (things that are true/false) → Validation
- **Types** (things that exist or don't) → By-construction

A `ConnectedTopology` isn't a topology that we check for connectedness.
It's a TYPE that only contains connected topologies.
If you have one, it's connected BY DEFINITION.

This is the "propositions as types" philosophy applied to crypto.
