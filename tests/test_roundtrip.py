"""
Test encrypt → decrypt roundtrip with quantum-secure primitives.
"""
import sys
sys.path.insert(0, '/Users/chloevandervlugt/Desktop/homotopical-encrypt')

from src.crypto.credential import generate_credential
from src.crypto.encrypt import encrypt
from src.crypto.decrypt import decrypt, decrypt_with_verification, hash_message


def test_basic_roundtrip():
    """Test basic two-party encryption roundtrip."""
    print("=" * 60)
    print("TEST: Basic Two-Party Encryption Roundtrip")
    print("=" * 60)
    
    # Generate credential
    # Note: security_parameter must be >= message_bits (31 chars * 8 = 248 bits)
    print("\n1. Generating credential...")
    cred = generate_credential(
        parties=['alice', 'bob'],
        connections=[('alice', 'bob')],
        security_parameter=256,  # Must be >= message length in bits
        modulus=12289
    )
    print(f"   ✓ Credential generated")
    print(f"   - Parties: {cred.parties}")
    print(f"   - Hilbert dim: {cred.hilbert_dim}")
    print(f"   - Spectral gap: {cred.spectrum.spectral_gap:.4f}")
    print(f"   - Betti numbers: {cred.spectrum.betti_numbers}")
    
    # Encrypt
    message = b"Hello, quantum-resistant world!"
    print(f"\n2. Encrypting message: {message}")
    ciphertext = encrypt(message, cred, sigma_exact=1.0, sigma_harmonic=0.1)
    print(f"   ✓ Encrypted")
    print(f"   - Vertex blocks: {len(ciphertext.vertex_blocks)}")
    print(f"   - Edge syndromes: {len(ciphertext.edge_syndromes)}")
    
    # Decrypt with verification
    print(f"\n3. Decrypting...")
    expected_hash = hash_message(message)
    decrypted, verified, chain = decrypt_with_verification(ciphertext, cred, expected_hash)
    print(f"   ✓ Decrypted: {decrypted}")
    print(f"   - Hash verified: {verified}")
    print(f"   - Chain length: {len(chain.chain)}")
    
    # Verify
    print(f"\n4. Verification:")
    if decrypted == message:
        print("   ✅ SUCCESS: Roundtrip complete!")
        return True
    else:
        print(f"   ❌ FAILED: Got {decrypted} instead of {message}")
        return False


def test_spectral_fingerprint():
    """Test that spectral fingerprints are consistent."""
    print("\n" + "=" * 60)
    print("TEST: Spectral Fingerprint Consistency")
    print("=" * 60)
    
    # Generate two credentials with same topology
    cred1 = generate_credential(
        parties=['a', 'b'],
        connections=[('a', 'b')],
        security_parameter=128, enforce_min_harmonic=False,
        modulus=12289
    )
    
    cred2 = generate_credential(
        parties=['a', 'b'],
        connections=[('a', 'b')],
        security_parameter=128, enforce_min_harmonic=False,
        modulus=12289
    )
    
    print(f"\n1. Cred1 fingerprint hash: {cred1.spectrum.fingerprint_hash()[:16].hex()}...")
    print(f"2. Cred2 fingerprint hash: {cred2.spectrum.fingerprint_hash()[:16].hex()}...")
    
    # Different fibrations should have different spectra
    # (same topology, different keys)
    match = cred1.spectrum.matches(cred2.spectrum)
    print(f"\n3. Fingerprints match: {match}")
    print("   (Expected: False - different random keys)")
    
    # Same credential should match itself
    self_match = cred1.spectrum.matches(cred1.spectrum)
    print(f"4. Self-match: {self_match}")
    print("   (Expected: True)")
    
    return self_match and not match


def test_lattice_roundtrip():
    """Test lattice-based encryption primitives."""
    print("\n" + "=" * 60)
    print("TEST: Lattice Primitives")
    print("=" * 60)
    
    from src.crypto.lattice import ornstein_uhlenbeck_noise, heat_kernel_sample, secure_random_vector
    from src.primitives.cochain import CochainComplex
    import numpy as np
    
    dim = 64
    q = 12289
    sigma = 3.0
    
    print(f"\n1. Lattice parameters:")
    print(f"   - Dimension: {dim}")
    print(f"   - Modulus: {q}")
    print(f"   - Noise σ: {sigma}")
    
    # Test O-U noise
    noise = ornstein_uhlenbeck_noise(dim, volatility=sigma)
    print(f"\n2. O-U noise:")
    print(f"   - Mean: {np.mean(noise):.4f}")
    print(f"   - Std: {np.std(noise):.4f}")
    print(f"   - Shape: {noise.shape}")
    assert noise.shape == (dim,)
    
    # Test heat kernel sample (spectral noise from Laplacian)
    cc = CochainComplex.complete_graph(5)
    L = cc.laplacian_0()
    spec_noise = heat_kernel_sample(L, time=1.0, temperature=sigma)
    print(f"\n3. Heat kernel noise (from K₅ Laplacian):")
    print(f"   - Shape: {spec_noise.shape}")
    assert spec_noise.shape == (5,)
    
    # Test secure random vector
    rv = secure_random_vector(dim, q)
    print(f"\n4. Secure random vector:")
    print(f"   - Shape: {rv.shape}")
    assert all(0 <= x < q for x in rv)
    
    print("\n   ✅ Lattice primitives working!")


if __name__ == "__main__":
    print("\n🔐 HOMOTOPICAL ENCRYPT - TEST SUITE")
    print("=" * 60)
    
    results = []
    
    # Test lattice primitives
    results.append(("Lattice Primitives", test_lattice_roundtrip()))
    
    # Test spectral fingerprint
    results.append(("Spectral Fingerprint", test_spectral_fingerprint()))
    
    # Test full roundtrip
    results.append(("Basic Roundtrip", test_basic_roundtrip()))
    
    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    for name, passed in results:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"  {name}: {status}")
    
    all_passed = all(r[1] for r in results)
    print("\n" + ("🎉 All tests passed!" if all_passed else "⚠️ Some tests failed"))
