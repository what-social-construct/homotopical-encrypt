"""
Wallet Storage - Private Credential Management

Uses Hodge-hardness encryption (OUR system, not external).
Master key = spectral fingerprint of master fibration.

Security model:
- Master credential = your identity fibration
- Master key = spectral fingerprint (NOT passphrase!)
- Validates ALL invariants on load (fail loudly)
- Uses OUR Hodge encryption (message in ker(Δ))
"""

from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional, Dict, Any
import json
import time
import numpy as np

from ..crypto.encrypt import encrypt
from ..crypto.decrypt import decrypt_v2
from ..crypto.credential import FibrationCredential
from ..invariants.unified import UnifiedInvariantValidator, validate_fibration


@dataclass
class EncryptedCredential:
    """
    Credential encrypted with Hodge noise.
    
    The master key is the spectral fingerprint of the master fibration.
    This is beautiful: your identity (fingerprint) IS your encryption key.
    """
    # Encrypted data
    ciphertext_blob: bytes              # Hodge-encrypted credential bytes
    
    # Public metadata (for verification)
    public_fingerprint: bytes           # Spectral fingerprint (can verify without decrypt)
    topology_hash: bytes                # Nerve structure hash
    
    # Expected invariants (validated on load)
    expected_invariants: Dict[str, Any] = field(default_factory=dict)
    
    # Metadata
    encrypted_at: float = field(default_factory=time.time)
    version: str = "1.0"
    
    def to_dict(self) -> Dict[str, Any]:
        """Serialize for JSON storage."""
        return {
            "ciphertext_blob": self.ciphertext_blob.hex(),
            "public_fingerprint": self.public_fingerprint.hex(),
            "topology_hash": self.topology_hash.hex(),
            "expected_invariants": self.expected_invariants,
            "encrypted_at": self.encrypted_at,
            "version": self.version
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'EncryptedCredential':
        """Deserialize from JSON."""
        return cls(
            ciphertext_blob=bytes.fromhex(data["ciphertext_blob"]),
            public_fingerprint=bytes.fromhex(data["public_fingerprint"]),
            topology_hash=bytes.fromhex(data["topology_hash"]),
            expected_invariants=data.get("expected_invariants", {}),
            encrypted_at=data.get("encrypted_at", time.time()),
            version=data.get("version", "1.0")
        )


class WalletStore:
    """
    Encrypted wallet using spectral fingerprint as master key.
    
    Architecture:
    - Master credential = your main identity fibration
    - Master key = spectral fingerprint of that fibration
    - Wallet stores multiple credentials (all encrypted with master key)
    - Each load validates ALL invariants (fail loudly if violated)
    
    Security guarantees:
    - Hodge-hardness: message in ker(Δ), noise in im(δ)⊕im(δ*)
    - Open source safe: security from lattice hardness, not obscurity
    - By-construction: validation on every load
    - Forward secrecy: ephemeral fibers per message (handled at routing layer)
    """
    
    def __init__(self, wallet_path: Path):
        self.wallet_path = Path(wallet_path)
        self.wallet_path.parent.mkdir(parents=True, exist_ok=True)
    
    def save_credential(
        self,
        credential: FibrationCredential,
        master_credential: FibrationCredential,
        label: str = "default"
    ) -> bool:
        """
        Save credential encrypted with master's fingerprint.
        
        Args:
            credential: The credential to encrypt and save
            master_credential: Master identity (its fingerprint is the key)
            label: Label for this credential in wallet
            
        Returns:
            True if saved successfully
            
        The beautiful part: master_key = master_credential.spectrum.fingerprint_hash()
        Your identity IS your encryption key!
        """
        # Extract master key from spectral fingerprint
        master_key = master_credential.spectrum.fingerprint_hash()
        
        # Serialize credential to bytes
        # TODO: Implement FibrationCredential.serialize()
        # For now, we'll use a simple JSON representation
        cred_data = self._serialize_credential(credential)
        
        # Encrypt using master credential's Hodge system
        # The message goes into ker(Δ), noise in im(δ)⊕im(δ*)
        ciphertext = encrypt(cred_data, master_credential)
        
        # Get public metadata
        public_fingerprint = credential.spectrum.fingerprint_hash()
        topology_hash = self._hash_topology(credential.topology)
        
        # Extract invariants for validation on load
        validator = UnifiedInvariantValidator(
            nerve=credential.topology,
            laplacian=credential.laplacian,
            delta_0=credential.delta_0,
            delta_1=credential.delta_1 if hasattr(credential, 'delta_1') else None
        )
        fingerprint = validator.get_fingerprint()
        
        expected_invariants = {
            "betti_0": fingerprint.cohomology.betti_0,
            "betti_1": fingerprint.cohomology.betti_1,
            "betti_2": fingerprint.cohomology.betti_2,
            "spectral_gap": fingerprint.spectral.spectral_gap,
            "h_level": fingerprint.homotopical.h_level.value,
            "sigma_rank": fingerprint.homotopical.sigma_rank,
            "pi_rank": fingerprint.homotopical.pi_rank
        }
        
        # Create encrypted credential
        enc_cred = EncryptedCredential(
            ciphertext_blob=ciphertext.serialize(),
            public_fingerprint=public_fingerprint,
            topology_hash=topology_hash,
            expected_invariants=expected_invariants
        )
        
        # Load existing wallet or create new
        wallet_data = self._load_wallet_file()
        wallet_data[label] = enc_cred.to_dict()
        
        # Save to disk
        with open(self.wallet_path, 'w') as f:
            json.dump(wallet_data, f, indent=2)
        
        print(f"✅ Credential '{label}' saved to wallet")
        print(f"   Fingerprint: {public_fingerprint.hex()[:16]}...")
        print(f"   Topology: {topology_hash.hex()[:16]}...")
        
        return True
    
    def load_credential(
        self,
        master_credential: FibrationCredential,
        label: str = "default"
    ) -> Optional[FibrationCredential]:
        """
        Load and decrypt credential.
        
        CRITICAL: Validates ALL invariants before returning.
        Uses UnifiedInvariantValidator - FAILS LOUDLY if validation fails.
        
        Args:
            master_credential: Master identity (its fingerprint is the key)
            label: Which credential to load from wallet
            
        Returns:
            Decrypted and validated credential, or None if validation fails
        """
        # Load wallet file
        wallet_data = self._load_wallet_file()
        
        if label not in wallet_data:
            print(f"❌ Credential '{label}' not found in wallet")
            return None
        
        # Deserialize encrypted credential
        enc_cred = EncryptedCredential.from_dict(wallet_data[label])
        
        print(f"🔓 Loading credential '{label}'...")
        print(f"   Fingerprint: {enc_cred.public_fingerprint.hex()[:16]}...")
        
        # Decrypt using master credential
        # TODO: Implement Ciphertext.deserialize()
        # For now, use a placeholder
        ciphertext_bytes = enc_cred.ciphertext_blob
        
        # Decrypt via harmonic projection
        decrypted_data, _ = decrypt_v2(ciphertext_bytes, master_credential)
        
        # Deserialize credential
        credential = self._deserialize_credential(decrypted_data)
        
        # VALIDATE ALL INVARIANTS (fail loudly!)
        print(f"🔍 Validating invariants...")
        
        validator = UnifiedInvariantValidator(
            nerve=credential.topology,
            laplacian=credential.laplacian,
            delta_0=credential.delta_0,
            delta_1=credential.delta_1 if hasattr(credential, 'delta_1') else None
        )
        
        passed, checkpoints = validator.validate_all()
        
        if not passed:
            print(f"❌ VALIDATION FAILED for credential '{label}'")
            print(validator.report())
            return None
        
        # Check invariants match expected
        fingerprint = validator.get_fingerprint()
        expected = enc_cred.expected_invariants
        
        if fingerprint.spectral.spectral_gap != expected["spectral_gap"]:
            print(f"❌ Spectral gap mismatch!")
            print(f"   Expected: {expected['spectral_gap']}")
            print(f"   Actual: {fingerprint.spectral.spectral_gap}")
            return None
        
        if fingerprint.cohomology.betti_0 != expected["betti_0"]:
            print(f"❌ Betti number mismatch!")
            return None
        
        print(f"✅ All invariants validated")
        print(f"   β = ({fingerprint.cohomology.betti_0}, {fingerprint.cohomology.betti_1}, {fingerprint.cohomology.betti_2})")
        print(f"   λ₁ = {fingerprint.spectral.spectral_gap:.4f}")
        print(f"   h-level = {fingerprint.homotopical.h_level.name}")
        
        return credential
    
    def rotate_master_key(
        self,
        old_master: FibrationCredential,
        new_master: FibrationCredential
    ) -> bool:
        """
        Rotate master key while staying in same homotopy class.
        
        This is the POWER of homotopy: you can rotate keys (change fibration)
        while maintaining the same identity (spectral fingerprint).
        
        Args:
            old_master: Current master credential
            new_master: New master credential (must be homotopy equivalent!)
            
        Returns:
            True if rotation successful
            
        Proof of equivalence: fingerprint(old) == fingerprint(new)
        """
        # Verify homotopy equivalence
        old_fp = old_master.spectrum.fingerprint_hash()
        new_fp = new_master.spectrum.fingerprint_hash()
        
        if old_fp != new_fp:
            print(f"❌ Master credentials not homotopy equivalent!")
            print(f"   Old fingerprint: {old_fp.hex()[:16]}...")
            print(f"   New fingerprint: {new_fp.hex()[:16]}...")
            return False
        
        print(f"✅ Master credentials are homotopy equivalent")
        print(f"   Fingerprint: {old_fp.hex()[:16]}...")
        print(f"🔄 Rotating master key...")
        
        # Load all credentials with old master
        wallet_data = self._load_wallet_file()
        rotated = {}
        
        for label in wallet_data.keys():
            print(f"   Re-encrypting '{label}'...")
            
            # Decrypt with old master
            credential = self.load_credential(old_master, label)
            if credential is None:
                print(f"   ❌ Failed to decrypt '{label}'")
                return False
            
            # Re-encrypt with new master
            enc_cred = self._encrypt_credential(credential, new_master)
            rotated[label] = enc_cred.to_dict()
        
        # Save rotated wallet
        with open(self.wallet_path, 'w') as f:
            json.dump(rotated, f, indent=2)
        
        print(f"✅ Master key rotated successfully")
        print(f"   {len(rotated)} credentials re-encrypted")
        
        return True
    
    def list_credentials(self) -> Dict[str, Dict[str, Any]]:
        """List all credentials in wallet with public metadata."""
        wallet_data = self._load_wallet_file()
        
        summary = {}
        for label, data in wallet_data.items():
            enc_cred = EncryptedCredential.from_dict(data)
            summary[label] = {
                "fingerprint": enc_cred.public_fingerprint.hex()[:16] + "...",
                "topology_hash": enc_cred.topology_hash.hex()[:16] + "...",
                "encrypted_at": enc_cred.encrypted_at,
                "expected_spectral_gap": enc_cred.expected_invariants.get("spectral_gap", "N/A")
            }
        
        return summary
    
    # =========================================================================
    # HELPER METHODS
    # =========================================================================
    
    def _load_wallet_file(self) -> Dict[str, Any]:
        """Load wallet file or return empty dict."""
        if not self.wallet_path.exists():
            return {}
        
        with open(self.wallet_path, 'r') as f:
            return json.load(f)
    
    def _serialize_credential(self, credential: FibrationCredential) -> bytes:
        """
        Serialize credential to bytes for encryption.
        
        TODO: Implement proper serialization in FibrationCredential
        """
        # Placeholder: serialize essential data
        import pickle
        data = {
            "topology": credential.topology,
            "laplacian": credential.laplacian,
            "delta_0": credential.delta_0,
            "security_parameter": credential.security_parameter
        }
        return pickle.dumps(data)
    
    def _deserialize_credential(self, data: bytes) -> FibrationCredential:
        """
        Deserialize credential from bytes.
        
        TODO: Implement proper deserialization in FibrationCredential
        """
        import pickle
        cred_dict = pickle.loads(data)
        
        # Reconstruct credential (placeholder)
        from ..crypto.credential import generate_credential
        
        # This is a simplified reconstruction - needs proper implementation
        return FibrationCredential(
            topology=cred_dict["topology"],
            laplacian=cred_dict["laplacian"],
            delta_0=cred_dict["delta_0"],
            security_parameter=cred_dict.get("security_parameter", 256)
        )
    
    def _encrypt_credential(
        self,
        credential: FibrationCredential,
        master_credential: FibrationCredential
    ) -> EncryptedCredential:
        """Helper to encrypt a credential."""
        cred_data = self._serialize_credential(credential)
        ciphertext = encrypt(cred_data, master_credential)
        
        public_fingerprint = credential.spectrum.fingerprint_hash()
        topology_hash = self._hash_topology(credential.topology)
        
        validator = UnifiedInvariantValidator(
            nerve=credential.topology,
            laplacian=credential.laplacian,
            delta_0=credential.delta_0,
            delta_1=credential.delta_1 if hasattr(credential, 'delta_1') else None
        )
        fingerprint = validator.get_fingerprint()
        
        expected_invariants = {
            "betti_0": fingerprint.cohomology.betti_0,
            "spectral_gap": fingerprint.spectral.spectral_gap,
            "h_level": fingerprint.homotopical.h_level.value
        }
        
        return EncryptedCredential(
            ciphertext_blob=ciphertext.serialize(),
            public_fingerprint=public_fingerprint,
            topology_hash=topology_hash,
            expected_invariants=expected_invariants
        )
    
    def _hash_topology(self, topology: Dict) -> bytes:
        """Hash the topology structure."""
        import hashlib
        topology_str = str(sorted(topology.items()))
        return hashlib.sha256(topology_str.encode()).digest()[:16]


# =============================================================================
# TEST
# =============================================================================

if __name__ == "__main__":
    import tempfile
    from ..crypto.credential import generate_credential
    
    print("=" * 60)
    print("WALLET STORE TEST")
    print("=" * 60)
    
    # Generate master credential
    print("\n1. Generating master credential...")
    master_cred = generate_credential(
        parties=['alice'],
        connections=[],
        security_parameter=256
    )
    print(f"   Fingerprint: {master_cred.spectrum.fingerprint_hash().hex()[:16]}...")
    
    # Generate another credential to store
    print("\n2. Generating wallet credential...")
    wallet_cred = generate_credential(
        parties=['alice', 'bob'],
        connections=[('alice', 'bob')],
        security_parameter=256
    )
    print(f"   Fingerprint: {wallet_cred.spectrum.fingerprint_hash().hex()[:16]}...")
    
    # Create wallet and save
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        wallet_path = f.name
    
    print(f"\n3. Creating wallet at {wallet_path}")
    wallet = WalletStore(wallet_path)
    
    print("\n4. Saving credential to wallet...")
    wallet.save_credential(wallet_cred, master_cred, label="alice_bob_channel")
    
    print("\n5. Loading credential from wallet...")
    loaded_cred = wallet.load_credential(master_cred, label="alice_bob_channel")
    
    if loaded_cred:
        print("\n✅ WALLET STORE WORKING")
        print(f"   Loaded fingerprint: {loaded_cred.spectrum.fingerprint_hash().hex()[:16]}...")
    else:
        print("\n❌ Failed to load credential")
    
    print("\n6. Listing wallet contents...")
    contents = wallet.list_credentials()
    for label, info in contents.items():
        print(f"   {label}: {info}")
    
    print("\n" + "=" * 60)
