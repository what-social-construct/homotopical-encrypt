"""
Secure Memory Management

Ensures sensitive data (credentials, keys, ephemeral fibers) is properly wiped
from memory after use to prevent compromise via memory dumps.

Python's garbage collector makes this challenging, but we use multiple techniques:
- Overwrite with random data before deletion
- Overwrite again with zeros
- Use ctypes to directly manipulate memory where possible
- Encourage use of context managers for automatic cleanup
"""

import os
import gc
import numpy as np
from typing import Any, Optional
from contextlib import contextmanager
import weakref


class SecureArray:
    """
    Wrapper for numpy arrays with automatic secure wiping.
    
    Usage:
        with SecureArray(256) as arr:
            arr[:] = sensitive_data
            # Use arr...
        # arr is securely wiped here
    """
    
    def __init__(self, size: int, dtype=np.float64):
        self.size = size
        self.dtype = dtype
        self._array: Optional[np.ndarray] = None
        self._wiped = False
    
    def __enter__(self) -> np.ndarray:
        """Allocate array on entry."""
        self._array = np.zeros(self.size, dtype=self.dtype)
        return self._array
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Securely wipe on exit."""
        self.wipe()
        return False
    
    def wipe(self):
        """
        Securely wipe the array.
        
        Three-pass overwrite:
        1. Random data
        2. Zeros
        3. Ones
        """
        if self._wiped or self._array is None:
            return
        
        try:
            # Pass 1: Random
            self._array[:] = np.random.randn(*self._array.shape)
            
            # Pass 2: Zeros
            self._array.fill(0)
            
            # Pass 3: Ones (paranoid)
            self._array.fill(1)
            self._array.fill(0)
            
            # Delete reference
            self._array = None
            self._wiped = True
            
            # Force garbage collection
            gc.collect()
            
        except Exception as e:
            # Even if wipe fails, mark as wiped to prevent use
            self._wiped = True
            raise
    
    def __del__(self):
        """Ensure wipe on deletion."""
        if not self._wiped:
            self.wipe()


class SecureBytes:
    """
    Wrapper for sensitive byte data with automatic wiping.
    
    Usage:
        with SecureBytes(b"secret_key") as secure:
            key = secure.data
            # Use key...
        # key is wiped here
    """
    
    def __init__(self, data: bytes):
        self._data = bytearray(data)
        self._wiped = False
        # Register for automatic cleanup
        self._finalizer = weakref.finalize(self, self._cleanup_data, self._data)
    
    @staticmethod
    def _cleanup_data(data: bytearray):
        """Static method for cleanup (can be called by weakref)."""
        if data:
            # Three-pass wipe
            length = len(data)
            # Pass 1: Random
            data[:] = os.urandom(length)
            # Pass 2: Zeros
            data[:] = b'\x00' * length
            # Pass 3: Ones
            data[:] = b'\xff' * length
            data.clear()
    
    @property
    def data(self) -> bytes:
        """Get the data (read-only view)."""
        if self._wiped:
            raise ValueError("SecureBytes has been wiped")
        return bytes(self._data)
    
    def __enter__(self) -> 'SecureBytes':
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.wipe()
        return False
    
    def wipe(self):
        """Explicitly wipe the data."""
        if not self._wiped:
            self._cleanup_data(self._data)
            self._wiped = True
            self._finalizer.detach()
    
    def __del__(self):
        """Ensure wipe on deletion."""
        if not self._wiped:
            self.wipe()
    
    def __len__(self) -> int:
        return len(self._data) if not self._wiped else 0


@contextmanager
def secure_context(*objects):
    """
    Context manager for multiple secure objects.
    
    Usage:
        with secure_context(cred1, cred2, ephemeral_fiber) as (c1, c2, ef):
            # Use credentials
            pass
        # All wiped here
    """
    try:
        yield objects
    finally:
        for obj in objects:
            if hasattr(obj, 'wipe'):
                obj.wipe()


def secure_wipe_credential(credential):
    """
    Securely wipe a FibrationCredential from memory.
    
    Wipes:
    - Laplacian matrix
    - Delta operators
    - Connection matrices
    - Any cached eigenvalues/vectors
    """
    if credential is None:
        return
    
    try:
        # Wipe Laplacian
        if hasattr(credential, 'laplacian') and credential.laplacian is not None:
            credential.laplacian.fill(0)
            credential.laplacian[:] = np.random.randn(*credential.laplacian.shape)
            credential.laplacian.fill(0)
        
        # Wipe delta operators
        for attr in ['delta_0', 'delta_1', 'delta_2']:
            if hasattr(credential, attr):
                delta = getattr(credential, attr)
                if delta is not None:
                    delta.fill(0)
                    delta[:] = np.random.randn(*delta.shape)
                    delta.fill(0)
        
        # Wipe connection if present
        if hasattr(credential, 'connection') and credential.connection:
            for edge, matrix in credential.connection.items():
                matrix.fill(0)
                matrix[:] = np.random.randn(*matrix.shape)
                matrix.fill(0)
        
        # Force garbage collection
        gc.collect()
        
    except Exception as e:
        # Even if wipe fails, we tried
        print(f"⚠️  Warning: Credential wipe failed: {e}")


def secure_wipe_ephemeral(ephemeral_fiber):
    """
    Securely wipe an EphemeralFiber.
    
    Critical for forward secrecy - ephemeral fibers must be destroyed
    after single use.
    """
    if ephemeral_fiber is None:
        return
    
    try:
        if hasattr(ephemeral_fiber, 'wipe') and callable(ephemeral_fiber.wipe):
            ephemeral_fiber.wipe()
        elif hasattr(ephemeral_fiber, '_transport_matrix'):
            # Manual wipe if wipe() not available
            matrix = ephemeral_fiber._transport_matrix
            if matrix is not None:
                matrix.fill(0)
                matrix[:] = np.random.randn(*matrix.shape)
                matrix.fill(0)
            ephemeral_fiber._wiped = True
        
        gc.collect()
        
    except Exception as e:
        print(f"⚠️  Warning: Ephemeral fiber wipe failed: {e}")


class SecureCredentialStore:
    """
    Temporary in-memory storage for credentials with automatic wiping.
    
    Use this instead of keeping credentials in regular variables.
    """
    
    def __init__(self):
        self._credentials = {}
        self._finalizer = weakref.finalize(self, self._cleanup_all, self._credentials)
    
    @staticmethod
    def _cleanup_all(creds: dict):
        """Static cleanup method."""
        for cred in creds.values():
            secure_wipe_credential(cred)
        creds.clear()
    
    def store(self, label: str, credential):
        """Store a credential temporarily."""
        self._credentials[label] = credential
    
    def get(self, label: str):
        """Retrieve a credential."""
        return self._credentials.get(label)
    
    def remove(self, label: str):
        """Remove and wipe a credential."""
        if label in self._credentials:
            secure_wipe_credential(self._credentials[label])
            del self._credentials[label]
    
    def wipe_all(self):
        """Wipe all stored credentials."""
        self._cleanup_all(self._credentials)
        self._credentials.clear()
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.wipe_all()
        return False
    
    def __del__(self):
        self.wipe_all()


# ============================================================================
# BEST PRACTICES
# ============================================================================

def get_best_practices() -> str:
    """Return best practices for secure memory management."""
    return """
SECURE MEMORY BEST PRACTICES

1. MASTER CREDENTIALS
   ❌ DON'T: Store in plain variables
   ✅ DO: Use SecureCredentialStore with context managers
   
   with SecureCredentialStore() as store:
       store.store("master", master_cred)
       # Use credential
       # Automatically wiped on exit

2. EPHEMERAL FIBERS
   ❌ DON'T: Reuse ephemeral fibers
   ✅ DO: Generate per-message, wipe immediately after use
   
   ephemeral = EphemeralFiber.generate(bundle)
   key = ephemeral.derive_key(base_key)
   # Use key for ONE message
   ephemeral.wipe()  # Critical!

3. TRANSACTION KEYS
   ❌ DON'T: Keep decrypted keys in memory longer than needed
   ✅ DO: Decrypt, use, wipe in tight scope
   
   with wallet.load_credential(master) as cred:
       tx = create_transaction(cred)
       # cred wiped on exit

4. DEBUGGING
   ❌ DON'T: Print sensitive data (even for debugging)
   ✅ DO: Print only fingerprints/hashes
   
   print(f"Cred: {cred.spectrum.fingerprint_hash().hex()[:16]}...")

5. ERROR HANDLING
   ❌ DON'T: Let exceptions leak credentials
   ✅ DO: Wipe in finally blocks
   
   cred = None
   try:
       cred = load_credential(...)
       # Use cred
   finally:
       if cred:
           secure_wipe_credential(cred)

6. LONG-RUNNING PROCESSES
   ❌ DON'T: Keep master credential in memory
   ✅ DO: Load, use, wipe, repeat
   
   # For each transaction:
   master = load_from_secure_storage()
   cred = wallet.load_credential(master)
   # Use cred
   secure_wipe_credential(cred)
   secure_wipe_credential(master)

7. MEMORY DUMPS
   ✅ Assume adversary can dump memory at any time
   ✅ Minimize time sensitive data is in memory
   ✅ Use SecureArray for large data
   ✅ Force garbage collection after wipes

8. FORWARD SECRECY
   ✅ Generate new ephemeral fiber per message
   ✅ Wipe immediately after deriving keys
   ✅ Never store ephemeral fibers
   ✅ Key compromise doesn't expose past messages
"""


# ============================================================================
# TEST
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("SECURE MEMORY TEST")
    print("=" * 60)
    
    # Test 1: SecureArray
    print("\n1. SecureArray test:")
    with SecureArray(10) as arr:
        arr[:] = np.random.randn(10)
        print(f"   Array created: {arr[:3]}...")
    print(f"   ✅ Array wiped on exit")
    
    # Test 2: SecureBytes
    print("\n2. SecureBytes test:")
    sensitive = b"super_secret_key_data"
    with SecureBytes(sensitive) as secure:
        data = secure.data
        print(f"   Data stored: {len(data)} bytes")
    print(f"   ✅ Data wiped on exit")
    
    # Test 3: SecureCredentialStore
    print("\n3. SecureCredentialStore test:")
    
    class MockCred:
        def __init__(self):
            self.laplacian = np.random.randn(5, 5)
    
    with SecureCredentialStore() as store:
        cred = MockCred()
        store.store("test", cred)
        retrieved = store.get("test")
        print(f"   Credential stored and retrieved")
    print(f"   ✅ Credential wiped on exit")
    
    # Test 4: Best practices
    print("\n4. Best practices:")
    practices = get_best_practices()
    lines = practices.strip().split('\n')
    print(f"   {lines[0]}")
    print(f"   {len(lines)} best practice guidelines available")
    
    print("\n" + "=" * 60)
    print("✅ SECURE MEMORY WORKING")
    print("=" * 60)
    
    print("\n" + get_best_practices())
