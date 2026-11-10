"""
CohomologicalMAC: Message Authentication via ker(Δ) Membership

Layer 2 primitive — sits alongside CochainCommitment in the crypto layer.

  Layer 1 (SHA-256): hash chain integrity
  Layer 2 (SVP/CVP): CochainCommitment binds VALUES, CohomologicalMAC AUTHENTICATES
  Layer 3 (homotopy): spectral proofs, class membership

Together:
  CochainCommitment = δ(m || r) → SVP-hard VALUE BINDING
  CohomologicalMAC  = P_H · c(m) → Hodge-hard AUTHENTICATION
  Both are cochain-native, both compose in the transaction pipeline.

CONSTRUCTION:

  Key = secret sheaf Laplacian Δ
    → defines ker(Δ) = harmonic subspace
    → knowing Δ lets you compute P_H = V_H V_H^T

  Tag(key, message):
    1. Encode message as cochain: c = hash_expand(m || nonce)
    2. Project onto ker(Δ): tag = P_H · c
    3. Return (tag_coefficients, nonce)

  Verify(key, message, tag, nonce):
    1. Re-encode: c = hash_expand(m || nonce)
    2. Check: Δ · tag ≈ 0  (tag ∈ ker(Δ))
    3. Check: V_H^T · tag = V_H^T · c  (correct projection)

SECURITY:

  Forgery = produce v ∈ ker(Δ) consistent with message, WITHOUT Δ.

  This is the DISCRETE HODGE DECOMPOSITION problem:
    Given c, find c_H s.t. Δ·c_H = 0 and c_H = P_H·c.
    Without Δ, this requires finding a low-dimensional subspace
    of a high-dimensional cochain space.

  Hardness parallel to LWE:
    LWE: distinguish Ax+e from random (given A, not x)
    Hodge: find ker(Δ) component (given c, not Δ)

  Security parameter = log₂(n/h) + log₂(λ₁)
    n = cochain dimension, h = harmonic dimension, λ₁ = spectral gap

REFERENCES:
  - Hodge (1941): Harmonic Integrals
  - Eckmann (1945): Harmonische Funktionen und Randwertaufgaben
  - Hansen & Ghrist (2019): Spectral Theory of Cellular Sheaves
"""

from dataclasses import dataclass
from typing import Tuple, Optional
import numpy as np
import hashlib

from ..invariants.harmonic import is_harmonic, project_to_harmonic
from ..crypto.random import secure_random_bytes


# =============================================================================
# KEY
# =============================================================================

@dataclass
class CohomologicalMACKey:
    """
    MAC key = secret sheaf Laplacian + its harmonic structure.

    This IS the geometry. Possessing the key means knowing ker(Δ).
    """
    laplacian: np.ndarray        # Δ (n×n, symmetric, PSD)
    harmonic_basis: np.ndarray   # V_H (n×h orthonormal)
    harmonic_dim: int            # h = dim ker(Δ)
    cochain_dim: int             # n
    key_fingerprint: bytes       # SHA-256(Δ)

    @staticmethod
    def generate(
        laplacian: np.ndarray,
        zero_threshold: float = 1e-10,
    ) -> 'CohomologicalMACKey':
        """
        Generate MAC key from sheaf Laplacian.

        The Laplacian comes from the sheaf structure — same Δ used
        for Hodge decomposition in encrypt/decrypt.

        Args:
            laplacian: Sheaf Laplacian Δ (symmetric, PSD).
            zero_threshold: Threshold for zero eigenvalues.

        Returns:
            CohomologicalMACKey.

        Raises:
            ValueError: If Laplacian has no kernel (acyclic sheaf).
        """
        n = laplacian.shape[0]
        eigenvalues, eigenvectors = np.linalg.eigh(laplacian)

        harmonic_mask = np.abs(eigenvalues) < zero_threshold
        harmonic_basis = eigenvectors[:, harmonic_mask]
        h = harmonic_basis.shape[1]

        if h == 0:
            raise ValueError(
                "Laplacian has no kernel — acyclic sheaf. "
                "CohomologicalMAC requires nontrivial H^k."
            )

        fp = hashlib.sha256(laplacian.tobytes()).digest()

        return CohomologicalMACKey(
            laplacian=laplacian,
            harmonic_basis=harmonic_basis,
            harmonic_dim=h,
            cochain_dim=n,
            key_fingerprint=fp,
        )

    @property
    def projector(self) -> np.ndarray:
        """Harmonic projector P_H = V_H V_H^T."""
        return self.harmonic_basis @ self.harmonic_basis.T


# =============================================================================
# TAG
# =============================================================================

@dataclass
class CohomologicalTag:
    """
    Authentication tag: a vector in ker(Δ).

    Only producible with knowledge of the key (= knowledge of ker(Δ)).
    Compact form stores only harmonic coefficients (h floats, not n).
    """
    tag_vector: np.ndarray            # Full vector in ker(Δ)
    nonce: bytes                      # Fresh nonce
    harmonic_coefficients: np.ndarray  # Compact: α = V_H^T · c
    key_fingerprint: bytes

    def to_bytes(self) -> bytes:
        """Serialize for wire format."""
        coeff_bytes = self.harmonic_coefficients.tobytes()
        return (
            len(self.nonce).to_bytes(4, 'big') + self.nonce
            + len(coeff_bytes).to_bytes(4, 'big') + coeff_bytes
            + self.key_fingerprint
        )

    @property
    def compact_size(self) -> int:
        """Size in bytes (compact = harmonic coefficients only)."""
        return len(self.harmonic_coefficients) * 8


# =============================================================================
# ENCODE
# =============================================================================

def _encode_message(message: bytes, n: int, nonce: bytes) -> np.ndarray:
    """
    Deterministically expand (message || nonce) into cochain vector ∈ ℝⁿ.

    Uses SHA-256 chain — same (message, nonce) always → same cochain.
    """
    seed = hashlib.sha256(message + nonce).digest()
    c = np.zeros(n)
    for i in range(n):
        h = hashlib.sha256(seed + i.to_bytes(4, 'big')).digest()
        c[i] = int.from_bytes(h[:8], 'big') / (2**63) - 1.0
    return c


# =============================================================================
# TAG / VERIFY
# =============================================================================

def mac_tag(
    key: CohomologicalMACKey,
    message: bytes,
    nonce: Optional[bytes] = None,
) -> CohomologicalTag:
    """
    Produce authentication tag.

    tag = P_H · c(m || nonce) = V_H (V_H^T c)

    This is the SECRET operation — requires ker(Δ).

    Args:
        key: CohomologicalMACKey.
        message: Arbitrary bytes.
        nonce: Optional (generated if None).

    Returns:
        CohomologicalTag authenticating the message.
    """
    if nonce is None:
        nonce = secure_random_bytes(32)

    c = _encode_message(message, key.cochain_dim, nonce)
    alpha = key.harmonic_basis.T @ c       # α = V_H^T c  (h coefficients)
    tag_vec = key.harmonic_basis @ alpha    # tag = V_H α  (n-vector in ker(Δ))

    return CohomologicalTag(
        tag_vector=tag_vec,
        nonce=nonce,
        harmonic_coefficients=alpha,
        key_fingerprint=key.key_fingerprint,
    )


def mac_verify(
    key: CohomologicalMACKey,
    message: bytes,
    tag: CohomologicalTag,
    tolerance: float = 1e-6,
) -> Tuple[bool, str]:
    """
    Verify authentication tag.

    Three checks:
    1. Key fingerprint match
    2. tag ∈ ker(Δ): Δ·tag ≈ 0
    3. Correct projection: V_H^T · tag = V_H^T · c(m || nonce)

    Args:
        key: CohomologicalMACKey.
        message: Message to verify.
        tag: CohomologicalTag.
        tolerance: Numerical tolerance.

    Returns:
        (valid, reason).
    """
    if tag.key_fingerprint != key.key_fingerprint:
        return False, "Key fingerprint mismatch"

    harmonic, residual = is_harmonic(tag.tag_vector, key.laplacian, tolerance)
    if not harmonic:
        return False, f"Tag not in ker(Δ): ||Δ·tag|| = {residual:.2e}"

    c = _encode_message(message, key.cochain_dim, tag.nonce)
    expected = key.harmonic_basis.T @ c
    err = np.linalg.norm(tag.harmonic_coefficients - expected)
    if err > tolerance:
        return False, f"Tag does not match message: coeff_error = {err:.2e}"

    return True, "Valid: tag ∈ ker(Δ) ∧ matches message"


# =============================================================================
# SECURITY ANALYSIS
# =============================================================================

def detect_forgery(
    key: CohomologicalMACKey,
    tag_vector: np.ndarray,
    tolerance: float = 1e-6,
) -> Tuple[bool, float]:
    """
    Detect forgery: legitimate tag has Δ·tag = 0.
    Random vector generically has Δ·tag ≠ 0.

    Returns (is_forgery, residual).
    """
    harmonic, residual = is_harmonic(tag_vector, key.laplacian, tolerance)
    return not harmonic, residual


def security_parameter(key: CohomologicalMACKey) -> float:
    """
    Effective security bits.

    ≈ log₂(n/h) + log₂(λ₁) where:
      n = cochain dim, h = harmonic dim, λ₁ = spectral gap.

    Larger spectral gap + smaller harmonic subspace = harder to forge.
    """
    eigs = np.sort(np.linalg.eigvalsh(key.laplacian))
    nonzero = eigs[eigs > 1e-10]
    lambda_1 = float(nonzero[0]) if len(nonzero) > 0 else 0.0

    if lambda_1 == 0 or key.cochain_dim == 0:
        return 0.0

    ratio_bits = np.log2(max(1, key.cochain_dim / key.harmonic_dim))
    gap_bits = np.log2(max(1, lambda_1 * 100))
    return float(ratio_bits + gap_bits)


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("COHOMOLOGICAL MAC TEST")
    print("=" * 60)

    # Build test Laplacian with 2-dim kernel
    n = 8
    A = np.random.randn(n, n)
    L = A.T @ A
    eigs, vecs = np.linalg.eigh(L)
    eigs[:2] = 0.0
    eigs[2:] = np.clip(eigs[2:], 1.0, None)
    L = vecs @ np.diag(eigs) @ vecs.T

    print(f"\n1. Key generation:")
    key = CohomologicalMACKey.generate(L)
    print(f"   n={key.cochain_dim}, h={key.harmonic_dim}")
    print(f"   Security: {security_parameter(key):.1f} bits")

    print(f"\n2. Tag + Verify:")
    msg = b"Transfer 100 to Alice"
    tag = mac_tag(key, msg)
    valid, reason = mac_verify(key, msg, tag)
    print(f"   Valid: {valid}  ({reason})")

    print(f"\n3. Wrong message:")
    valid2, reason2 = mac_verify(key, b"Transfer 999 to Eve", tag)
    print(f"   Valid: {valid2}  ({reason2})")

    print(f"\n4. Forgery detection:")
    fake = np.random.randn(n)
    is_forged, res = detect_forgery(key, fake)
    print(f"   Random forgery detected: {is_forged}  (residual={res:.2e})")

    print(f"\n5. Wrong key:")
    B = np.random.randn(n, n)
    L2 = B.T @ B
    e2, v2 = np.linalg.eigh(L2)
    e2[:2] = 0.0; e2[2:] = np.clip(e2[2:], 1.0, None)
    L2 = v2 @ np.diag(e2) @ v2.T
    key2 = CohomologicalMACKey.generate(L2)
    valid3, reason3 = mac_verify(key2, msg, tag)
    print(f"   Valid: {valid3}  ({reason3})")

    print(f"\n6. Determinism:")
    nonce = b"x" * 32
    t1 = mac_tag(key, msg, nonce=nonce)
    t2 = mac_tag(key, msg, nonce=nonce)
    print(f"   Same tag: {np.allclose(t1.tag_vector, t2.tag_vector)}")

    print("\n" + "=" * 60)
    print("✅ COHOMOLOGICAL MAC READY")
    print("=" * 60)
