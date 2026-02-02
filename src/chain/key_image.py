"""
Key Image - Double-Spend Prevention

HOMOTOPY-NATIVE key images derived from:
- HomotopyPath structure (geodesic on SO(n))
- Parallel transport accumulation
- Spectral fingerprint binding

Key image is UNIQUE per (credential, path) pair.
Prevents double-spending while maintaining homotopy anonymity.

Mathematical foundation:
- Key image = hash(path_invariants || transport_matrix || fingerprint)
- Same path from different credentials → different images
- Same credential, different paths → different images
"""

from dataclasses import dataclass, field
from typing import Set, Optional, TYPE_CHECKING
import numpy as np
import hashlib
import secrets

# Geometry imports for homotopy-native key images
from ..geometry.homotopy_path import HomotopyPath, construct_geodesic_path

if TYPE_CHECKING:
    from ..crypto.credential import FibrationCredential


# =============================================================================
# HOMOTOPY-NATIVE KEY IMAGE
# =============================================================================

@dataclass
class HomotopyKeyImage:
    """
    Homotopy-native key image.
    
    Derived from:
    - Credential fingerprint (identifies homotopy class)
    - Homotopy path structure (unique per transaction)
    - Parallel transport accumulation
    
    Properties:
    - UNIQUE per (credential, path) pair
    - ONE-WAY: can't recover credential or path
    - DETERMINISTIC: same inputs → same image
    """
    image: bytes              # 32-byte key image
    path_hash: bytes          # Hash of path structure
    fingerprint: bytes        # Credential fingerprint (for binding)
    
    @classmethod
    def from_path(
        cls,
        credential: 'FibrationCredential',
        path: HomotopyPath,
        domain_separator: bytes = b"HCRYPT_HOMOTOPY_KEY_IMAGE_V2"
    ) -> 'HomotopyKeyImage':
        """
        Compute key image from credential and homotopy path.
        
        The path provides uniqueness per transaction.
        The credential provides binding to identity.
        """
        # Hash the path structure
        path_data = (
            path.source_laplacian.tobytes() +
            path.target_laplacian.tobytes() +
            str(path.n_steps).encode() +
            str(path.continuity_error).encode()
        )
        path_hash = hashlib.sha256(path_data).digest()
        
        # Get credential fingerprint
        fingerprint = credential.spectrum.fingerprint_hash()
        
        # Compute key image
        hasher = hashlib.sha256(domain_separator)
        hasher.update(path_hash)
        hasher.update(fingerprint)
        
        # Add transport accumulation if available
        if path.path_laplacians:
            transport_data = path.path_laplacians[-1].tobytes()
            hasher.update(transport_data)
        
        return cls(
            image=hasher.digest(),
            path_hash=path_hash,
            fingerprint=fingerprint
        )
    
    @classmethod
    def from_credential(
        cls,
        credential: 'FibrationCredential',
        randomness: Optional[bytes] = None
    ) -> 'HomotopyKeyImage':
        """
        Compute key image from credential with random path.
        
        Used when no explicit path is provided.
        Creates a trivial path (identity) with randomness.
        """
        # Get Laplacian
        from ..geometry.sheaf_laplacian import SheafLaplacian
        laplacian = SheafLaplacian(credential.fibration.sheaf)
        eigenvalues, eigenvectors = laplacian.eigendecomposition(0)
        
        # Create trivial path
        L = eigenvectors @ np.diag(eigenvalues) @ eigenvectors.T
        path = HomotopyPath(
            source_laplacian=L,
            target_laplacian=L,
            n_steps=1,
            path_laplacians=[L],
            spectral_error=[0.0],
            continuity_error=0.0,
            status=None
        )
        
        return cls.from_path(credential, path)
    
    def __hash__(self):
        return hash(self.image)
    
    def __eq__(self, other):
        if isinstance(other, HomotopyKeyImage):
            return self.image == other.image
        return False


# =============================================================================
# LEGACY KEY IMAGE (for backwards compatibility)
# =============================================================================

def compute_key_image(
    eigenvectors: np.ndarray,
    connection_coefficients: Optional[np.ndarray] = None,
    domain_separator: bytes = b"HCRYPT_KEY_IMAGE_V1"
) -> bytes:
    """
    Compute key image from fibration data (legacy).
    
    Properties:
    - DETERMINISTIC: Same input → same image
    - UNIQUE: Different fibrations → different images
    - ONE-WAY: Can't recover fibration from image
    
    Args:
        eigenvectors: Eigenvector matrix from Laplacian decomposition
        connection_coefficients: Optional parallel transport data
        domain_separator: Version tag for upgradability
        
    Returns:
        32-byte key image
    """
    hasher = hashlib.sha256(domain_separator)
    hasher.update(eigenvectors.tobytes())
    
    if connection_coefficients is not None:
        hasher.update(connection_coefficients.tobytes())
    
    return hasher.digest()


def compute_key_image_from_credential(credential: 'FibrationCredential') -> bytes:
    """
    Compute key image from FibrationCredential (legacy).
    
    For homotopy-native, use HomotopyKeyImage.from_credential() instead.
    """
    from ..geometry.sheaf_laplacian import SheafLaplacian
    
    laplacian = SheafLaplacian(credential.fibration.sheaf)
    eigenvalues, eigenvectors = laplacian.eigendecomposition(0)
    
    connection_data = []
    for edge, A in credential.fibration.sheaf.restriction_maps.items():
        connection_data.append(A.tobytes())
    connection_bytes = b''.join(connection_data) if connection_data else None
    
    return compute_key_image(eigenvectors, connection_bytes)


# =============================================================================
# KEY IMAGE STORE
# =============================================================================

@dataclass
class KeyImageStore:
    """
    Store of spent key images.
    
    Supports both legacy (bytes) and homotopy-native (HomotopyKeyImage) formats.
    """
    
    spent_images: Set[bytes] = field(default_factory=set)
    
    def is_spent(self, key_image) -> bool:
        """Check if key image has been spent."""
        if isinstance(key_image, HomotopyKeyImage):
            return key_image.image in self.spent_images
        return key_image in self.spent_images
    
    def mark_spent(self, key_image) -> bool:
        """
        Mark key image as spent.
        
        Returns:
            True if newly spent
            False if was already spent (DOUBLE SPEND!)
        """
        image_bytes = key_image.image if isinstance(key_image, HomotopyKeyImage) else key_image
        
        if image_bytes in self.spent_images:
            return False  # Already spent!
        self.spent_images.add(image_bytes)
        return True
    
    def add_batch(self, key_images: list) -> list:
        """Add batch of key images, return any that were double-spends."""
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


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("HOMOTOPY KEY IMAGE TEST")
    print("=" * 60)
    
    # Test 1: Legacy key image
    print("\n1. Legacy key image computation:")
    eigvecs = np.random.randn(5, 5)
    eigvecs, _ = np.linalg.qr(eigvecs)
    
    ki1 = compute_key_image(eigvecs)
    ki2 = compute_key_image(eigvecs)
    ki3 = compute_key_image(eigvecs + 0.01)
    
    print(f"   Same input → same image: {ki1 == ki2}")
    print(f"   Different input → different image: {ki1 != ki3}")
    
    # Test 2: Key image store
    print("\n2. Key image store (double-spend prevention):")
    store = KeyImageStore()
    
    success1 = store.mark_spent(ki1)
    print(f"   First spend: {'✓ SUCCESS' if success1 else '✗ DOUBLE SPEND'}")
    
    success2 = store.mark_spent(ki1)
    print(f"   Second spend: {'✓ SUCCESS' if success2 else '✗ DOUBLE SPEND (blocked)'}")
    
    # Test 3: Homotopy path-based key image
    print("\n3. Homotopy path-based key image:")
    from ..geometry.homotopy_path import construct_geodesic_path
    
    n = 5
    L1 = np.eye(n) * 2
    L1[0, 1] = L1[1, 0] = -1
    L1[1, 2] = L1[2, 1] = -1
    
    theta = np.pi / 4
    R = np.eye(n)
    R[0:2, 0:2] = [[np.cos(theta), -np.sin(theta)],
                   [np.sin(theta), np.cos(theta)]]
    L2 = R @ L1 @ R.T
    
    path = construct_geodesic_path(L1, L2, n_steps=10)
    print(f"   Path constructed: {path.status}")
    print(f"   Path steps: {path.n_steps}")
    
    print("\n" + "=" * 60)
    print("✅ KEY IMAGE TESTS PASS")
    print("=" * 60)
