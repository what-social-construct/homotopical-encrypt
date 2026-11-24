# Concrete cellular HCP comparison

[CoupledCVP](CoupledCVP.lean) and [CoupledSemantics](CoupledSemantics.lean)
extend the construction to shared integral face equations `y=B x`. The actual
cellular family lives in [Sheaf.HCPCoupledFamily](../Sheaf/HCPCoupledFamily.lean).
Its entire intrinsic harmonic lattice is the integer graph `(0,z,Bz)`; its
explicit basis has Gram `I+BᵀB`. A constructed strict cochain shear proves
typed Helfer equivalence and public homological-theory equality for all
same-size matrices. That shear generally changes the metric, so it does not
instantiate the isometric `PresentedRotation` interface. The existing Hodge
sampler and known-lattice CVP recovery apply, with the generated-target promise
retained. Canonical presentation bytes and original-snapshot checks live in
[Storage.CoupledCodec](../Protocol/Storage/CoupledCodec.lean) and
[CoupledBinding](../Protocol/Storage/CoupledBinding.lean).
The [native integer profile](../Sheaf/HCPCoupledEncoding.lean) is the same
original Hodge encryption; the [full ciphertext codec](../Protocol/Storage/CoupledCiphertext.lean)
reconstructs its complete observation. These are harmonic-lattice messages
and cochains; encrypted query evaluation remains an optional application.

[CoupledTransport](CoupledTransport.lean) separately constructs the native
coordinate map `M_B(a,z,u)=(a,z-Bᵀu,Bz+u)` as a real linear equivalence.
The ciphertext map `M_C M_B⁻¹` preserves the original message and both opening
coordinate vectors for every same-size pair, with identity/inverse/composition.
It is distinct from the cochain shear and does not require an isometry.
Generated integral samples remain integral.
[CoupledGeometry](CoupledGeometry.lean) connects these maps through the same
source presentation. It derives the actual block Hodge operator and proves
that either the degree-one differential or true Hodge matrix determines `B`
in the fixed coordinate/metric profile. Its two assembly/recovery triangles
and central square hold on all real cochains:
`P_C L_(B→C) = S_(B,C) P_B`. The tailored native map carries the harmonic and
noise summands separately, so this square needs no isometry. Native transport
and the semantic shear agree on harmonic vectors and the intrinsic lattice;
an explicit scalar counterexample shows why the shear cannot replace the
ciphertext arrow. This adds no independent geometry record or lifecycle policy.
[CoupledRational](CoupledRational.lean) now executes the inverse and transport
by exact rational adjugate/determinant arithmetic and proves refinement to
the original real map. Its private decoder checks integral message
coordinates and recovers the same original coefficients. This is a finite
reference implementation without a polynomial complexity bound. Secure
delivery/public release remains separate. Transport to the known zero
presentation exposes the message coefficients, so universal public transport
is not a confidentiality contract.

The [protocol execution adapter](../Protocol/Ephemeral/NativeTransport.lean)
serializes the derived rational map in the canonical ciphertext coordinate
ordering and executes with the held token. Retained-base recovery takes the
private source presentation explicitly. The [scope codec](../Protocol/Ephemeral/ScopeCodec.lean)
and [token codec](../Protocol/Ephemeral/TransportToken.lean)
retain the actual recipient/epoch/context scope; [native delivery](../Protocol/Ephemeral/NativeDelivery.lean)
and [retrieval](../Protocol/Storage/Retrieval/Native.lean) reuse the existing
receipt, original storage contexts and full-ciphertext digest. The exact
artifact carrier is unchanged.

The token is a reusable context/profile map capability. Expected-scope checks
do not cryptographically restrict copied matrix data. Its fields omit the
source and target matrices, but the derived operator may reveal them; no
key-hiding guarantee or secure public-token release is proved. Authentication,
protected envelope delivery, shared-secret agreement, key/noise generation and
the complete released-view security experiment remain separate work.

[AxisFamily.lean](AxisFamily.lean) instantiates the existing HCP recovery and
CVP-oracle comparison with two actual integral cellular sheaves. Import
`HCP.AxisFamily` for the mathematical example or
[TCB.HCPAxisFamily](../TCB/HCPAxisFamily.lean) for its application-binding adapters.

The degree-one carrier is two-dimensional. The exact coboundary is zero and
the two coexact coboundaries select opposite coordinates. Their true Hodge
matrices are `diag(1,0)` and `diag(0,1)`, with positive spectral gap one. At the
common observed cochain `b=(1,1)`, the samples have harmonic messages `(0,1)`
and `(1,0)` respectively, allowed coexact noise in the complementary coordinate,
and the same zero exact component. Both messages are nonzero and integral.

A weighted variant fixes `b=(1,2)` and uses the actual integer encoder with
coefficients `2` and `1`. It proves that no function of that shared HCP
observation recovers both encoded coefficients. The original `b=(1,1)` pair
uses coefficient `1` in each transported basis; the weighted variant explicitly
separates encoded integers as well as ambient harmonic vectors. Both results
are finite exact-recovery statements, without a sampling/security game.

[AxisRotation](AxisRotation.lean) separately constructs the actual integral
axis swap and proves same-coefficient encoding for every integer input.
Rotating the weighted source moves `(1,2)` to `(2,1)` and retains coefficient
two; both direct target-key and inverse/base-key recovery return that same
integer. The fixed-input right sample at `(1,2)` instead encodes one.
This distinguishes rotation correctness from the recovery obstruction.
The [protocol fixture](../Protocol/Ephemeral/Examples.lean) uses that actual
rotation with recipient/epoch/context-bound delivery receipts, retaining
authorization and channel proofs as explicit inputs.

The semantic interpretation is the actual cellular complex in Mathlib's
bounded-below real cochain Quillen model. A concrete chain isometry gives a
typed Helfer equivalence. Invariance of the explicitly chosen homological
closed tests is proved for every typed interpretation, so equality of the
family's actual closed theories is derived. This is a homological test
fragment, not a formalization of Helfer's full first-order syntax or general
fibrational invariance theorem.

The principal endpoints in `HomotopicalEncryption.HCP.AxisFamily` are:

- `shared_observation_distinct_nonzero_targets`: the same `(class,b)` has two
  different nonzero operative targets, each the actual sample message.
- `no_exact_encoded_message_decoder`: no exact public coefficient decoder
  for the two weighted samples in the chosen integer encoding.
- `no_exact_public_solver`: the existing no-uniform-recovery theorem applies
  with a constructed semantic and kernel-separation witness.
- `cvp_oracle_insufficient`: a correct explicit known-lattice oracle remains
  insufficient for that uniform public recovery contract, under its explicit
  oracle-existence premise.
- `cvp_solution_iff_message` and `cvp_existsUnique`: for either actual presented
  harmonic lattice, the unique CVP answer is that sample's message.

[Sheaf.HCPAxisFamily](../Sheaf/HCPAxisFamily.lean) owns the actual integral
structures, Hodge samples, operator matrices, spectrum and full-span harmonic
lattice presentations. [Helfer.CochainModel](../Helfer/CochainModel.lean) owns
the actual cochain model and proved homological-test invariance.

[TCB.HCPRealization](../TCB/HCPRealization.lean) derives matrix-kernel,
projector, message and discrete-CVP agreement from an explicit actual-operator
and classifier alignment. Its public-view theorem reuses the recovery
obstruction only when the selected view is proved to factor through the HCP
input. The concrete TCB adapter can retain an original artifact in a sample,
with its acceptance, decoder, snapshot-classifier and envelope bindings kept
as explicit application inputs.

The mathematical public input is `(class,b)`, as selected for this example.
Paper 1 states that observation and the geometric argument. Paper 2 owns the
concrete storage/visibility, selective-opening, rotation and key-delivery
profile. No equality or hiding claim for all storage roots, proof bytes or
full Plucker data is inferred from the class equality. No sender-anonymity,
plaintext-indistinguishability or forward-secrecy game is proved here.
