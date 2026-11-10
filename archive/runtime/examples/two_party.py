#!/usr/bin/env python3
"""
Example: Two-party encryption using Homotopical Encrypt

This demonstrates basic encryption between Alice and Bob using
fibration credentials and the Lindblad decryption flow.
"""

import sys
sys.path.insert(0, '..')

from src.crypto.credential import generate_credential
from src.crypto.encrypt import encrypt
from src.crypto.decrypt import decrypt


def main():
    print("=" * 60)
    print("Homotopical Quantum Encryption - Two Party Example")
    print("=" * 60)
    
    # Generate shared credential for Alice <-> Bob
    print("\n[1] Generating fibration credential...")
    cred = generate_credential(
        parties=['alice', 'bob'],
        connections=[('alice', 'bob')],
        security_parameter=64,  # Small for demo (use 256 in production)
        modulus=12289
    )
    
    print(f"    Topology: {len(cred.topology[0])} vertices, {len(cred.topology[1])} edges")
    print(f"    Hilbert dim: {cred.hilbert_dim}")
    print(f"    Spectral gap: {cred.spectrum.spectral_gap:.4f}")
    print(f"    Betti numbers: β₀={cred.spectrum.betti_numbers[0]}, β₁={cred.spectrum.betti_numbers[1]}")
    
    # Alice encrypts a message to Bob
    message = b"Hello Bob! This is encrypted via homotopical sheaf theory."
    print(f"\n[2] Original message: {message.decode()}")
    
    print("\n[3] Encrypting...")
    ciphertext = encrypt(message, cred, noise_stddev=2.0)
    
    print(f"    Version: {ciphertext.version}")
    print(f"    Topology hash: {ciphertext.topology_hash[:8].hex()}...")
    print(f"    Vertex blocks: {len(ciphertext.vertex_blocks)}")
    print(f"    Edge syndromes: {len(ciphertext.edge_syndromes)}")
    
    # Serialize and show size
    wire_data = ciphertext.serialize()
    print(f"    Wire format size: {len(wire_data)} bytes")
    
    # Bob decrypts
    print("\n[4] Decrypting via Lindblad flow...")
    decrypted = decrypt(ciphertext, cred, n_iterations=50, step_size=0.05)
    
    print(f"    Decrypted: {decrypted}")
    
    # Verify
    if decrypted[:len(message)] == message:
        print("\n✓ SUCCESS: Message decrypted correctly!")
    else:
        print("\n✗ MISMATCH: Decryption produced different result")
        print(f"    Expected: {message}")
        print(f"    Got:      {decrypted}")
    
    print("\n" + "=" * 60)


if __name__ == "__main__":
    main()
