"""
Constant-Size Padding for Metadata Hiding

All ciphertexts padded to fixed size to prevent size-based traffic analysis.

This is critical for panopticon resilience:
- All packets same size → no size correlation
- Decoy traffic indistinguishable from real
- Network observer sees uniform noise
"""

import os
from typing import Tuple

# Fixed ciphertext size (all packets padded to this)
CIPHERTEXT_SIZE = 4096  # 4KB packets


def pad_to_constant(data: bytes, target_size: int = CIPHERTEXT_SIZE) -> bytes:
    """
    Pad data to constant size.
    
    Args:
        data: Data to pad
        target_size: Target size in bytes (default 4096)
        
    Returns:
        Padded data of exactly target_size bytes
        
    Padding format:
    - Original data
    - Padding marker (4 bytes): length of original data
    - Random padding to fill remaining space
    
    Raises:
        ValueError: If data is larger than target_size - 4
    """
    if len(data) > target_size - 4:
        raise ValueError(
            f"Data too large: {len(data)} bytes > {target_size - 4} max "
            f"(need 4 bytes for length marker)"
        )
    
    # Calculate padding needed
    data_len = len(data)
    padding_needed = target_size - data_len - 4  # -4 for length marker
    
    # Create padded message:
    # [data] [random_padding] [data_length (4 bytes)]
    random_padding = os.urandom(padding_needed)
    length_marker = data_len.to_bytes(4, byteorder='big')
    
    padded = data + random_padding + length_marker
    
    assert len(padded) == target_size, f"Padding error: {len(padded)} != {target_size}"
    
    return padded


def unpad_from_constant(padded: bytes) -> bytes:
    """
    Remove padding from constant-size packet.
    
    Args:
        padded: Padded data
        
    Returns:
        Original unpadded data
        
    Raises:
        ValueError: If padding is invalid
    """
    if len(padded) < 4:
        raise ValueError("Padded data too short")
    
    # Extract length marker (last 4 bytes)
    length_marker = padded[-4:]
    data_len = int.from_bytes(length_marker, byteorder='big')
    
    # Validate length
    if data_len < 0 or data_len > len(padded) - 4:
        raise ValueError(f"Invalid padding: data_len={data_len}, total={len(padded)}")
    
    # Extract original data
    data = padded[:data_len]
    
    return data


def generate_decoy_packet(target_size: int = CIPHERTEXT_SIZE) -> bytes:
    """
    Generate decoy packet indistinguishable from real traffic.
    
    Args:
        target_size: Packet size (default 4096)
        
    Returns:
        Random packet of target_size bytes with valid padding structure
    """
    # Generate random "data"
    decoy_data_len = int.from_bytes(os.urandom(2), byteorder='big') % (target_size - 4)
    decoy_data = os.urandom(decoy_data_len)
    
    # Pad like real packet
    return pad_to_constant(decoy_data, target_size)


def validate_padding(padded: bytes, target_size: int = CIPHERTEXT_SIZE) -> Tuple[bool, str]:
    """
    Validate padding structure.
    
    Args:
        padded: Padded data to validate
        target_size: Expected size
        
    Returns:
        (is_valid, error_message)
    """
    if len(padded) != target_size:
        return (False, f"Wrong size: {len(padded)} != {target_size}")
    
    try:
        # Try to unpad
        data = unpad_from_constant(padded)
        
        # Check data length is reasonable
        if len(data) > target_size - 4:
            return (False, f"Data too large: {len(data)}")
        
        return (True, "Valid padding")
    
    except Exception as e:
        return (False, f"Invalid padding: {str(e)}")


class PaddedPacket:
    """
    Wrapper for constant-size padded packets.
    
    Provides clean interface for padding/unpadding.
    """
    
    def __init__(self, data: bytes = None, padded: bytes = None):
        """
        Create padded packet.
        
        Args:
            data: Original data (will be padded)
            padded: Already-padded data (will be validated)
            
        Must provide exactly one of data or padded.
        """
        if data is not None and padded is not None:
            raise ValueError("Provide either data or padded, not both")
        
        if data is None and padded is None:
            raise ValueError("Must provide either data or padded")
        
        if data is not None:
            self._padded = pad_to_constant(data)
            self._data = data
        else:
            # Validate padding
            is_valid, error = validate_padding(padded)
            if not is_valid:
                raise ValueError(f"Invalid padding: {error}")
            self._padded = padded
            self._data = None  # Lazy load
    
    @property
    def padded(self) -> bytes:
        """Get padded data."""
        return self._padded
    
    @property
    def data(self) -> bytes:
        """Get original data (unpadded)."""
        if self._data is None:
            self._data = unpad_from_constant(self._padded)
        return self._data
    
    @property
    def size(self) -> int:
        """Get packet size."""
        return len(self._padded)
    
    def is_decoy(self) -> bool:
        """
        Check if this might be a decoy packet.
        
        Returns True if the unpadded data looks random (high entropy).
        This is heuristic - cannot definitively identify decoys.
        """
        data = self.data
        
        # Check entropy (simple check: count unique bytes)
        if len(data) == 0:
            return True
        
        unique_bytes = len(set(data))
        entropy_ratio = unique_bytes / min(len(data), 256)
        
        # High entropy suggests random data (decoy)
        return entropy_ratio > 0.8
    
    def __len__(self) -> int:
        return len(self._padded)
    
    def __bytes__(self) -> bytes:
        return self._padded


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    import secrets
    
    print("=" * 60)
    print("CONSTANT-SIZE PADDING TEST")
    print("=" * 60)
    
    # Test 1: Basic padding
    print("\n1. Basic padding test:")
    original = b"Hello, panopticon! You see traffic, but learn nothing."
    print(f"   Original size: {len(original)} bytes")
    
    padded = pad_to_constant(original)
    print(f"   Padded size: {len(padded)} bytes")
    assert len(padded) == CIPHERTEXT_SIZE
    
    unpadded = unpad_from_constant(padded)
    print(f"   Unpadded size: {len(unpadded)} bytes")
    assert unpadded == original
    print(f"   ✅ Roundtrip successful")
    
    # Test 2: Various sizes
    print("\n2. Testing various sizes:")
    for size in [1, 10, 100, 1000, CIPHERTEXT_SIZE - 100, CIPHERTEXT_SIZE - 4]:
        data = secrets.token_bytes(size)
        padded = pad_to_constant(data)
        unpadded = unpad_from_constant(padded)
        assert unpadded == data
        print(f"   ✅ Size {size}: OK")
    
    # Test 3: Decoy packet
    print("\n3. Decoy packet test:")
    decoy = generate_decoy_packet()
    print(f"   Decoy size: {len(decoy)} bytes")
    
    is_valid, msg = validate_padding(decoy)
    print(f"   Valid padding: {is_valid} - {msg}")
    assert is_valid
    
    # Test 4: PaddedPacket wrapper
    print("\n4. PaddedPacket wrapper test:")
    packet1 = PaddedPacket(data=b"Test message")
    print(f"   Packet size: {packet1.size} bytes")
    print(f"   Data: {packet1.data}")
    
    packet2 = PaddedPacket(padded=packet1.padded)
    print(f"   Reconstructed: {packet2.data}")
    assert packet1.data == packet2.data
    print(f"   ✅ Wrapper working")
    
    # Test 5: Traffic analysis resistance
    print("\n5. Traffic analysis test:")
    packets = []
    for size in [50, 200, 1000, 3000]:
        data = secrets.token_bytes(size)
        packet = PaddedPacket(data=data)
        packets.append(packet)
    
    sizes = [len(p) for p in packets]
    print(f"   All packet sizes: {sizes}")
    assert all(s == CIPHERTEXT_SIZE for s in sizes)
    print(f"   ✅ All packets identical size - traffic analysis defeated!")
    
    print("\n" + "=" * 60)
    print("✅ CONSTANT-SIZE PADDING WORKING")
    print("=" * 60)
