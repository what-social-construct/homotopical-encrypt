# Concrete cellular HCP comparison

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

The semantic interpretation is the actual cellular complex in Mathlib's
bounded-below real cochain Quillen model. A concrete chain isometry gives a
typed Helfer equivalence. Invariance of the explicitly chosen homological
closed tests is proved for every typed interpretation, so equality of the
family's actual closed theories is derived. This is a homological test
fragment, not a formalization of Helfer's full first-order syntax or general
fibrational invariance theorem.

The principal endpoints in `Hcrypt.HCP.AxisFamily` are:

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
