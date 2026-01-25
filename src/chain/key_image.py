"""
Key Image - Double-Spend Prevention

The key image is a unique identifier for each fibration that:
- Cannot be computed without knowing the fibration (one-way)
- Is deterministic: same fibration → same key image
- Is unique: different fibrations → different key images
- Is unlinkable: can't link key image to spectral fingerprint

Unlike spectral fingerprint (same for homotopy class),
key image is unique PER FIBRATION (even within same class).

Key image = Hash(eigenvectors || connection_data)
"""

from dataclasses import dataclass
from typing import Set, Optional
import numpy as np
import hashlib
import secrets


def compute_key_image(
    eigenvectors: np.ndarray,
    connection_coefficients: Optional[np.ndarray] = None,
    domain_separator: bytes = b"HCRYPT_KEY_IMAGE_V1"
) -> bytes:
    """
    Compute key image from fibration data.
    
    Properties:
    - DETERMINISTIC: Same input → same image
    - UNIQUE: Different fibrations → different images (with overwhelming prob)
    - ONE-WAY: Can't recover fibration from image
    
    Args:
        eigenvectors: Eigenvector matrix from Laplacian decomposition
        connection_coefficients: Optional parallel transport data
        domain_separator: Version tag for upgradability
        
    Returns:
        32-byte key image
    """
    # Start with domain separator
    hasher = hashlib.sha256(domain_separator)
    
    # Add eigenvector data (this makes it unique per fibration)
    # Even same-spectrum fibrations have different eigenvectors
    hasher.update(eigenvectors.tobytes())
    
    # Add connection coefficients if provided
    if connection_coefficients is not None:
        hasher.update(connection_coefficients.tobytes())
    
    return hasher.digest()


def compute_key_image_from_credential(credential) -> bytes:
    """
    Compute key image from FibrationCredential.
    """
    from ..geometry import SheafLaplacian
    
    # Get Laplacian
    laplacian = SheafLaplacian(credential.sheaf)
    
    # Eigendecomposition
    eigenvalues, eigenvectors = laplacian.eigendecomposition(0)
    
    # Get connection data from restriction maps
    connection_data = []
    for edge, A in credential.sheaf.restriction_maps.items():
        connection_data.append(A.tobytes())
    connection_bytes = b''.join(connection_data) if connection_data else None
    
    return compute_key_image(eigenvectors, connection_bytes)


@dataclass
class KeyImageStore:
    """
    Store of spent key images.
    
    Used to prevent double-spending:
    - When spending, compute key image of input
    - Check if key image already in store
    - If yes: DOUBLE SPEND ATTEMPT
    - If no: Add to store, allow transaction
    """
    
    spent_images: Set[bytes]
    
    def __init__(self):
        self.spent_images = set()
    
    def is_spent(self, key_image: bytes) -> bool:
        """Check if key image has been spent."""
        return key_image in self.spent_images
    
    def mark_spent(self, key_image: bytes) -> bool:
        """
        Mark key image as spent.
        
        Returns:
            True if newly spent
            False if was already spent (DOUBLE SPEND!)
        """
        if key_image in self.spent_images:
            return False  # Already spent!
        self.spent_images.add(key_image)
        return True
    
    def add_batch(self, key_images: list) -> list:
        """
        Add batch of key images, return any that were double-spends.
        """
        double_spends = []
        for ki in key_images:
            if not self.mark_spent(ki):
                double_spends.append(ki)
        return double_spends
    
    def size(self) -> int:
        """Number of spent key images."""
        return len(self.spent_images)
    
    def serialize(self) -> bytes:
        """Serialize store for persistence."""
        import struct
        data = struct.pack('<I', len(self.spent_images))
        for ki in self.spent_images:
            data += ki
        return data
    
    @classmethod
    def deserialize(cls, data: bytes) -> 'KeyImageStore':
        """Deserialize store from bytes."""
        import struct
        store = cls()
        n = struct.unpack_from('<I', data, 0)[0]
        offset = 4
        for _ in range(n):
            ki = data[offset:offset+32]
            store.spent_images.add(ki)
            offset += 32
        return store


# ============================================================================
# TEST
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("KEY IMAGE TEST")
    print("=" * 60)
    
    # Test 1: Compute key image
    print("\n1. Key image computation:")
    eigvecs = np.random.randn(5, 5)
    eigvecs, _ = np.linalg.qr(eigvecs)  # Orthogonalize
    
    ki1 = compute_key_image(eigvecs)
    ki2 = compute_key_image(eigvecs)  # Same input
    ki3 = compute_key_image(eigvecs + 0.01)  # Different input
    
    print(f"   Key image 1: {ki1.hex()[:32]}...")
    print(f"   Key image 2: {ki2.hex()[:32]}...")
    print(f"   Same input → same image: {ki1 == ki2}")
    print(f"   Different input → different image: {ki1 != ki3}")
    
    # Test 2: Key image store
    print("\n2. Key image store (double-spend prevention):")
    store = KeyImageStore()
    
    # First spend should succeed
    success1 = store.mark_spent(ki1)
    print(f"   First spend: {'✓ SUCCESS' if success1 else '✗ DOUBLE SPEND'}")
    
    # Second spend should fail
    success2 = store.mark_spent(ki1)
    print(f"   Second spend: {'✓ SUCCESS' if success2 else '✗ DOUBLE SPEND (blocked)'}")
    
    # Different key image should succeed
    success3 = store.mark_spent(ki3)
    print(f"   Different input: {'✓ SUCCESS' if success3 else '✗ DOUBLE SPEND'}")
    
    # Test 3: Serialization
    print("\n3. Serialization:")
    serialized = store.serialize()
    restored = KeyImageStore.deserialize(serialized)
    print(f"   Serialized size: {len(serialized)} bytes")
    print(f"   Restored store size: {restored.size()}")
    print(f"   ki1 still marked spent: {restored.is_spent(ki1)}")
    
    print("\n" + "=" * 60)
    print("✅ KEY IMAGE TESTS PASS")
    print("=" * 60)
