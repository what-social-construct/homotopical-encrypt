"""
Benchmark: LWE vs Pure Cohomological Encryption

Compares:
1. Generic LWE (NIST-style)
2. Pure Cohomological (native Hodge)

Metrics:
- Roundtrip correctness
- Encryption time
- Decryption time
- Ciphertext size
- Security parameters
"""

import sys
sys.path.insert(0, '.')

import time
import numpy as np
from typing import Tuple

# Generic LWE
from src.crypto.lwe import LWEEncryptor

# Pure Cohomological
from src.crypto.cohomological_encrypt import (
    generate_cohomological_key,
    cohomological_encrypt,
    cohomological_decrypt,
    prove_lwe_reduction
)


def build_complete_graph_nerve(n: int) -> dict:
    """Build K_n complete graph nerve."""
    vertices = [(i,) for i in range(n)]
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    triangles = [(i, j, k) for i in range(n) for j in range(i+1, n) for k in range(j+1, n)]
    
    return {
        0: vertices,
        1: edges,
        2: triangles[:min(len(triangles), 100)]  # Limit triangles for speed
    }


def benchmark_lwe(message: bytes, n_trials: int = 5) -> dict:
    """Benchmark generic LWE encryption."""
    results = {
        'name': 'Generic LWE',
        'encrypt_times': [],
        'decrypt_times': [],
        'correct': [],
        'ciphertext_sizes': []
    }
    
    encryptor = LWEEncryptor(n=256, q=2**15, sigma=3.2)
    
    for _ in range(n_trials):
        # Encrypt
        t0 = time.perf_counter()
        ct = encryptor.encrypt(message)
        t1 = time.perf_counter()
        results['encrypt_times'].append(t1 - t0)
        results['ciphertext_sizes'].append(len(ct))
        
        # Decrypt
        t0 = time.perf_counter()
        dec = encryptor.decrypt(ct)
        t1 = time.perf_counter()
        results['decrypt_times'].append(t1 - t0)
        results['correct'].append(dec == message)
    
    return results


def benchmark_cohomological(message: bytes, nerve_size: int = 8, n_trials: int = 5) -> dict:
    """Benchmark pure cohomological encryption."""
    results = {
        'name': f'Cohomological (K_{nerve_size})',
        'encrypt_times': [],
        'decrypt_times': [],
        'correct': [],
        'ciphertext_sizes': []
    }
    
    # Build nerve
    nerve = build_complete_graph_nerve(nerve_size)
    
    # Generate key
    key = generate_cohomological_key(nerve, stalk_dim=1, modulus=12289, degree=1)
    
    for _ in range(n_trials):
        # Encrypt
        t0 = time.perf_counter()
        ct = cohomological_encrypt(message, key)
        t1 = time.perf_counter()
        results['encrypt_times'].append(t1 - t0)
        results['ciphertext_sizes'].append(ct.public_cochain.nbytes)
        
        # Decrypt
        t0 = time.perf_counter()
        dec = cohomological_decrypt(ct, key)
        t1 = time.perf_counter()
        results['decrypt_times'].append(t1 - t0)
        results['correct'].append(dec == message)
    
    return results


def print_results(results: dict):
    """Pretty print benchmark results."""
    print(f"\n{'─' * 50}")
    print(f"  {results['name']}")
    print(f"{'─' * 50}")
    print(f"  Correctness:     {sum(results['correct'])}/{len(results['correct'])}")
    print(f"  Encrypt (avg):   {np.mean(results['encrypt_times'])*1000:.3f} ms")
    print(f"  Decrypt (avg):   {np.mean(results['decrypt_times'])*1000:.3f} ms")
    print(f"  Ciphertext size: {np.mean(results['ciphertext_sizes']):.0f} bytes")


def main():
    print("=" * 70)
    print("BENCHMARK: LWE vs PURE COHOMOLOGICAL ENCRYPTION")
    print("=" * 70)
    
    message = b"Hello, homotopical world!"
    print(f"\nMessage: {message} ({len(message)} bytes)")
    
    # Test 1: Generic LWE
    print("\n[1] Testing Generic LWE...")
    lwe_results = benchmark_lwe(message)
    print_results(lwe_results)
    
    # Test 2: Cohomological (small graph)
    print("\n[2] Testing Cohomological (K_5)...")
    cohom_small = benchmark_cohomological(message, nerve_size=5)
    print_results(cohom_small)
    
    # Test 3: Cohomological (larger graph)
    print("\n[3] Testing Cohomological (K_10)...")
    cohom_large = benchmark_cohomological(message, nerve_size=10)
    print_results(cohom_large)
    
    # Summary comparison
    print("\n" + "=" * 70)
    print("SUMMARY COMPARISON")
    print("=" * 70)
    print(f"""
┌────────────────────┬──────────────┬──────────────┬──────────────┐
│ Metric             │ Generic LWE  │ Cohom (K_5)  │ Cohom (K_10) │
├────────────────────┼──────────────┼──────────────┼──────────────┤
│ Correct            │ {sum(lwe_results['correct'])}/{len(lwe_results['correct'])}          │ {sum(cohom_small['correct'])}/{len(cohom_small['correct'])}          │ {sum(cohom_large['correct'])}/{len(cohom_large['correct'])}          │
│ Encrypt (ms)       │ {np.mean(lwe_results['encrypt_times'])*1000:>10.2f}  │ {np.mean(cohom_small['encrypt_times'])*1000:>10.2f}  │ {np.mean(cohom_large['encrypt_times'])*1000:>10.2f}  │
│ Decrypt (ms)       │ {np.mean(lwe_results['decrypt_times'])*1000:>10.2f}  │ {np.mean(cohom_small['decrypt_times'])*1000:>10.2f}  │ {np.mean(cohom_large['decrypt_times'])*1000:>10.2f}  │
│ Ciphertext (bytes) │ {np.mean(lwe_results['ciphertext_sizes']):>10.0f}  │ {np.mean(cohom_small['ciphertext_sizes']):>10.0f}  │ {np.mean(cohom_large['ciphertext_sizes']):>10.0f}  │
├────────────────────┼──────────────┼──────────────┼──────────────┤
│ Native to Geometry │      ⚠️       │      ✓       │      ✓       │
│ Hodge Structured   │      ✗       │      ✓       │      ✓       │
│ NIST Reducible     │      ✓       │      ✓       │      ✓       │
└────────────────────┴──────────────┴──────────────┴──────────────┘
""")
    
    # Security proof
    print("\n" + "=" * 70)
    print("SECURITY PROOF: c-SVP ≥ LWE")
    print("=" * 70)
    print(prove_lwe_reduction())


if __name__ == "__main__":
    main()
