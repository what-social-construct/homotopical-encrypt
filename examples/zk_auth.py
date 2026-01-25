#!/usr/bin/env python3
"""
Example: Zero-Knowledge Authentication via Homotopy Equivalence

Demonstrates proving you have a valid key WITHOUT revealing it.

Scenario:
- Alice has a credential
- She wants to prove to Bob that her credential is "valid"
  (homotopy-equivalent to a public reference)
- She does NOT want to reveal her fibration structure

The magic: Betti numbers and spectral gap are homotopy invariants!
Proving they match proves homotopy equivalence without revealing the path.
"""

import sys
sys.path.insert(0, '..')

from src.crypto.credential import generate_credential
from src.zkp.homotopy_proof import (
    HomotopyStatement,
    prove_homotopy_equivalence,
    verify_homotopy_proof
)
from src.zkp.spectral_proof import (
    prove_spectral_match,
    verify_spectral_match,
    prove_ring_spectral,
    verify_ring_spectral
)


def demo_homotopy_proof():
    """Demonstrate basic homotopy equivalence proof."""
    print("=" * 60)
    print("DEMO 1: Homotopy Equivalence Proof")
    print("=" * 60)
    
    # Alice generates her credential
    print("\n[1] Alice generates her fibration credential...")
    alice_cred = generate_credential(
        parties=['alice', 'server'],
        connections=[('alice', 'server')],
        security_parameter=32
    )
    
    print(f"    Topology: {len(alice_cred.topology[0])} vertices, {len(alice_cred.topology[1])} edges")
    print(f"    Betti numbers: {alice_cred.spectrum.betti_numbers}")
    print(f"    Spectral gap: {alice_cred.spectrum.spectral_gap:.6f}")
    
    # The server publishes a reference (what Alice needs to match)
    print("\n[2] Server publishes reference statement...")
    statement = HomotopyStatement.from_credential(alice_cred)
    
    print(f"    Public topology hash: {statement.public_topology_hash[:8].hex()}...")
    print(f"    Public Betti numbers: {statement.public_betti_numbers}")
    print(f"    Public spectral gap: {statement.public_spectral_gap:.6f}")
    
    # Alice generates proof WITHOUT revealing her fibration
    print("\n[3] Alice generates ZK proof of homotopy equivalence...")
    proof = prove_homotopy_equivalence(alice_cred, statement)
    
    print(f"    Commitment: {proof.commitment[:8].hex()}...")
    print(f"    Betti response: {proof.betti_response}")
    print(f"    Spectral gap response: {proof.spectral_gap_response:.6f}")
    print(f"    Eigenvalue commitments: {len(proof.eigenvalue_commitments)}")
    
    # Server verifies proof
    print("\n[4] Server verifies proof...")
    is_valid, reason = verify_homotopy_proof(proof, statement)
    
    if is_valid:
        print(f"    ✓ VERIFIED: {reason}")
    else:
        print(f"    ✗ REJECTED: {reason}")
    
    # Show what information was revealed
    print("\n[5] Information revealed to server:")
    print("    ✓ Betti numbers (topological invariants)")
    print("    ✓ Spectral gap (geometric invariant)")
    print("    ✓ That Alice knows a valid fibration")
    print("    ✗ The actual fibration structure")
    print("    ✗ The quantum channel parameters")
    print("    ✗ Any path of equivalence")


def demo_spectral_proof():
    """Demonstrate spectral matching proof."""
    print("\n" + "=" * 60)
    print("DEMO 2: Spectral Matching Proof")
    print("=" * 60)
    
    # Alice has a credential
    print("\n[1] Alice generates credential...")
    alice_cred = generate_credential(
        parties=['alice', 'bob'],
        connections=[('alice', 'bob')],
        security_parameter=32
    )
    
    # Public reference spectrum
    public_spectrum = alice_cred.spectrum.eigenvalues
    prover_spectrum = alice_cred.spectrum.eigenvalues  # Same for this demo
    
    print(f"    Alice's spectrum: {len(prover_spectrum)} eigenvalues")
    print(f"    First few: {prover_spectrum[:5]}")
    
    # Generate spectral proof
    print("\n[2] Generating spectral matching proof...")
    proof = prove_spectral_match(prover_spectrum, public_spectrum, n_buckets=5)
    
    print(f"    Bucket counts: {proof.bucket_counts}")
    print(f"    Range commitments: {len(proof.range_commitments)}")
    
    # Verify
    print("\n[3] Verifying spectral proof...")
    is_valid, reason = verify_spectral_match(proof, public_spectrum, n_buckets=5)
    
    if is_valid:
        print(f"    ✓ VERIFIED: {reason}")
    else:
        print(f"    ✗ REJECTED: {reason}")


def demo_ring_signature():
    """Demonstrate ring signature style proof."""
    print("\n" + "=" * 60)
    print("DEMO 3: Ring Spectral Proof (Anonymous Authentication)")
    print("=" * 60)
    
    # Create a ring of credentials (a "group")
    print("\n[1] Creating ring of 5 members...")
    ring_creds = []
    for i in range(5):
        cred = generate_credential(
            parties=[f'member_{i}', 'server'],
            connections=[(f'member_{i}', 'server')],
            security_parameter=32
        )
        ring_creds.append(cred)
    
    ring_spectra = [c.spectrum.eigenvalues for c in ring_creds]
    print(f"    Ring size: {len(ring_spectra)}")
    
    # Alice is member 2 (but this is secret!)
    my_index = 2
    my_spectrum = ring_spectra[my_index]
    
    print(f"\n[2] Alice (secretly member {my_index}) generates ring proof...")
    ring_proof = prove_ring_spectral(my_spectrum, ring_spectra, my_index)
    
    print(f"    Key image: {ring_proof.key_image[:8].hex()}...")
    print(f"    Commitments: {len(ring_proof.commitments)}")
    
    # Verify
    print("\n[3] Verifying ring proof...")
    is_valid, reason = verify_ring_spectral(ring_proof, ring_spectra)
    
    if is_valid:
        print(f"    ✓ VERIFIED: {reason}")
        print("\n    Server knows: One of the 5 members authenticated")
        print("    Server does NOT know: Which member (Alice at index 2)")
    else:
        print(f"    ✗ REJECTED: {reason}")


def main():
    print("=" * 60)
    print("Homotopical Zero-Knowledge Authentication Demo")
    print("=" * 60)
    print("\nThis demonstrates the novel ZK proofs based on:")
    print("- Helfer's first-order homotopical logic")
    print("- Hansen-Ghrist spectral sheaf theory")
    print("- Homotopy invariants as ZK-friendly witnesses")
    
    demo_homotopy_proof()
    demo_spectral_proof()
    demo_ring_signature()
    
    print("\n" + "=" * 60)
    print("Summary: Homotopical ZK enables proving key validity")
    print("without revealing key structure - a novel contribution!")
    print("=" * 60)


if __name__ == "__main__":
    main()
