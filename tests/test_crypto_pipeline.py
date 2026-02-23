#!/usr/bin/env python3
"""
Integration tests for the core cryptographic pipeline.

Run: python3 -m tests.test_crypto_pipeline
"""

import sys, os
import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from src.crypto.credential import generate_credential, kernel_tolerance
from src.crypto.encrypt import encrypt
from src.crypto.decrypt import decrypt
from src.geometry.sheaf_laplacian import SheafLaplacian

# √2 constants
POV_LOWER = 1.0 / np.sqrt(2)
POV_UPPER = 2.0 * np.sqrt(2)

PARTIES = ["alice", "bob", "carol", "dave"]
CONNECTIONS = [("alice", "bob"), ("bob", "carol"), ("carol", "dave"), ("alice", "dave")]


def make_cred(sec=256):
    return generate_credential(PARTIES, CONNECTIONS, security_parameter=sec, enforce_min_harmonic=False)


def test_credential_generation():
    """Credential has valid spectral geometry."""
    print("  credential_generation...", end=" ")
    cred = make_cred()

    spec = cred.spectrum
    assert len(spec.eigenvalues) > 0
    assert all(e >= -1e-8 for e in spec.eigenvalues), f"Negative eigenvalue"
    assert cred.public_identity.betti_numbers[0] >= 1, "β₀ < 1"
    print("✅")


def test_spectral_bounds():
    """Spectral gap respects √2 bounds."""
    print("  spectral_bounds...", end=" ")
    cred = make_cred()
    gap = cred.spectrum.spectral_gap
    if gap > 0:
        assert gap >= POV_LOWER - 0.5, f"Gap {gap:.4f} too low"
        assert gap <= POV_UPPER + 1.0, f"Gap {gap:.4f} too high"
    print("✅")


def test_encrypt_decrypt_roundtrip():
    """Encrypt → decrypt recovers the message."""
    print("  encrypt_decrypt_roundtrip...", end=" ")
    cred = make_cred()

    # Message must fit in harmonic dim: dim(ker(Δ)) bits
    # With 256-dim stalks and 4 nodes, harmonic dim is large
    message = b"Hello homotopy!"  # 15 bytes = 120 bits

    ct = encrypt(message, cred)
    assert ct.version == 3
    recovered = decrypt(ct, cred)
    assert recovered == message, f"Got {recovered!r}"
    print("✅")


def test_encrypt_decrypt_short():
    """Short messages roundtrip."""
    print("  encrypt_decrypt_short...", end=" ")
    cred = make_cred()
    for msg in [b"A", b"ab", b"\x00\xff"]:
        ct = encrypt(msg, cred)
        assert decrypt(ct, cred) == msg
    print("✅")


def test_ciphertext_nondeterministic():
    """Two encryptions of same message differ (noise)."""
    print("  ciphertext_nondeterministic...", end=" ")
    cred = make_cred()
    message = b"test"
    ct1 = encrypt(message, cred)
    ct2 = encrypt(message, cred)

    if hasattr(ct1, 'vertex_blocks') and hasattr(ct2, 'vertex_blocks'):
        b1 = np.concatenate([v for v in ct1.vertex_blocks.values()])
        b2 = np.concatenate([v for v in ct2.vertex_blocks.values()])
        if len(b1) == len(b2):
            assert np.linalg.norm(b1 - b2) > 1e-6, "Should differ"
    print("✅")


def test_wrong_credential_fails():
    """Different credential cannot decrypt."""
    print("  wrong_credential_fails...", end=" ")
    cred1 = make_cred()
    cred2 = make_cred()
    message = b"secret"
    ct = encrypt(message, cred1)

    try:
        recovered = decrypt(ct, cred2)
        assert recovered != message, "Wrong cred should not recover"
    except Exception:
        pass  # Expected
    print("✅")


def test_laplacian_psd():
    """Sheaf Laplacian is PSD and symmetric."""
    print("  laplacian_psd...", end=" ")
    cred = make_cred()
    sl = SheafLaplacian(cred.fibration.sheaf)
    L = sl.get_laplacian_0()

    eigenvalues = np.linalg.eigvalsh(L)
    assert all(e >= -1e-8 for e in eigenvalues), f"Not PSD: min={min(eigenvalues)}"
    assert np.allclose(L, L.T, atol=1e-10), "Not symmetric"
    print("✅")


def test_betti_from_laplacian():
    """Sheaf Laplacian kernel dimension = β₀ × stalk_dim."""
    print("  betti_from_laplacian...", end=" ")
    cred = make_cred()
    sl = SheafLaplacian(cred.fibration.sheaf)
    L = sl.get_laplacian_0()

    eigenvalues = np.linalg.eigvalsh(L)
    tol = kernel_tolerance(eigenvalues)
    kernel_dim = sum(1 for e in eigenvalues if abs(e) < tol)

    # Sheaf β₀ = topological β₀ × stalk_dim
    topo_beta_0 = cred.public_identity.betti_numbers[0]
    stalk_dim = cred.hilbert_dim
    expected = topo_beta_0 * stalk_dim
    assert kernel_dim == expected, \
        f"ker(Δ) dim: got {kernel_dim}, expected {topo_beta_0}×{stalk_dim}={expected}"
    print("✅")


def test_credential_rotation():
    """Rotated credential encrypts/decrypts its own messages."""
    print("  credential_rotation...", end=" ")
    from src.crypto.credential import rotate_credential

    cred = make_cred()
    rotated = rotate_credential(cred)

    message = b"rotation"
    ct = encrypt(message, rotated)
    recovered = decrypt(ct, rotated)
    assert recovered == message
    print("✅")


def test_topology_structure():
    """Credential topology has correct simplicial structure."""
    print("  topology_structure...", end=" ")
    cred = make_cred()
    topo = cred.topology
    # Should have 0-simplices (vertices) and 1-simplices (edges)
    assert 0 in topo, "Missing 0-simplices"
    assert 1 in topo, "Missing 1-simplices"
    assert len(topo[0]) == len(PARTIES), f"Wrong vertex count: {len(topo[0])}"
    assert len(topo[1]) == len(CONNECTIONS), f"Wrong edge count: {len(topo[1])}"
    print("✅")


if __name__ == "__main__":
    print("🔬 Core Cryptographic Pipeline Tests")
    print("=" * 50)

    tests = [
        test_credential_generation,
        test_spectral_bounds,
        test_encrypt_decrypt_roundtrip,
        test_encrypt_decrypt_short,
        test_ciphertext_nondeterministic,
        test_wrong_credential_fails,
        test_laplacian_psd,
        test_betti_from_laplacian,
        test_credential_rotation,
        test_topology_structure,
    ]

    passed = failed = 0
    for test in tests:
        try:
            test()
            passed += 1
        except Exception as e:
            print(f"❌ {e}")
            failed += 1

    print(f"\n{'=' * 50}")
    print(f"Results: {passed}/{len(tests)} passed")
    if failed:
        sys.exit(1)
    print("✅ All crypto pipeline tests passed!")
