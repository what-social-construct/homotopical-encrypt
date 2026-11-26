module

public import TCB.ProofCarrying
public import VCVio.Algorithms.Sha2

@[expose] public section

/-! # SHA-256 for stored byte objects

The evaluated digest can be reused for index keys and comparisons. The
function-valued view preserves the existing proof interface.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.Sha256

abbrev DigestBytes := { bytes : ByteArray // bytes.size = 32 }

def digestBytes (bytes : List UInt8) : DigestBytes :=
  let input : ByteArray := ⟨bytes.toArray⟩
  ⟨VCVio.Algorithms.Sha2.sha256 input, VCVio.Algorithms.Sha2.sha256_size input⟩

def toHash32 (digest : DigestBytes) : TCB.Hash32 :=
  fun index => digest.val[index.val]'(by simpa only [digest.property] using index.isLt)

def key (digest : DigestBytes) : List UInt8 := List.ofFn (toHash32 digest)

def digest (bytes : List UInt8) : TCB.Hash32 := toHash32 (digestBytes bytes)

end HomotopicalEncryption.Protocol.Storage.Sha256
