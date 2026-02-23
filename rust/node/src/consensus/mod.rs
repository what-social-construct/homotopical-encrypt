// Proof of Value (PoV) Consensus — Topos-verified block validation
//
// Architecture (matches paper: Lambert 2021, Swan et al. 2025):
//   VRF slot → who proposes (fork prevention)
//   PoV → spectral gap proof (geometric value)
//   Topos → Heyting 3-valued judgment (VALID/UNDETERMINED/INVALID)

pub mod pov;
pub mod topos;
pub mod vrf;
pub mod validator_set;

pub use pov::{PoVProducer, PoVVerifier, OracleCommitment};
pub use topos::ToposVerifier;
pub use validator_set::{ValidatorSet, Validator};
pub use vrf::{
    VRFKey, VRFOutput, SlotAssignment, EquivocationTracker, EquivocationEvidence,
    vrf_evaluate, assign_slot, verify_slot_assignment,
};
