module

public import Protocol.Transfer.Owned.DemoFixture
meta import Protocol.Transfer.Owned.DemoFixture

@[expose] public section

/-!
# Run the bounded owned-transfer fixture

From `lean/`, run `lake build Protocol.Transfer.Owned.Demo`, then
`lake env lean --run Protocol/Transfer/Owned/Demo.lean`.
-/

def main : IO Unit := HomotopicalEncryption.Protocol.Transfer.Owned.Demo.execute
