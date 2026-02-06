// Sheaf Onion Network Layer
// 
// Uses geometry-based routing (NOT standard blockchain gossip!)
//
// Architecture:
// - libp2p for transport (TCP, peer discovery)
// - Sheaf onion protocol for transaction routing
// - Each node is a RelayNode with FiberBundle
// - Mixing delays for timing obfuscation
// - Constant-size packets (from padding.py)

pub mod onion;
pub mod relay;
pub mod transport;

pub use onion::{OnionRouter, OnionPacket};
pub use relay::{RelayNode, RelayNetwork};
pub use transport::P2PTransport;

// Network Protocol:
//
// 1. TOPOLOGY LAYER (libp2p)
//    - TCP transport
//    - Peer discovery (mDNS, Kad-DHT)
//    - Connection management
//
// 2. ROUTING LAYER (Sheaf Onion)
//    - Each node has FiberBundle (topology + connection)
//    - Transactions wrapped in onion layers
//    - Each relay peels one layer (parallel transport)
//    - Forward secrecy (ephemeral fibers per message)
//
// 3. MIXING LAYER
//    - Pool packets for random delays
//    - Release in shuffled order
//    - Break timing correlation
//
// 4. PADDING LAYER (constant size)
//    - All packets 4KB (from crypto/padding.py)
//    - Network observer sees uniform traffic

// TODO: Implement
// - [ ] P2P transport (libp2p)
// - [ ] Relay node management
// - [ ] Onion packet routing
// - [ ] Mixing delays
// - [ ] Integration with Python RelayNetwork

// NOTE: Python already implements the math!
// src/chain/routing.py has:
// - TransactionRouter
// - RelayNode
// - RelayNetwork
//
// src/geometry/fiber_bundle.py has:
// - FiberBundle
// - EphemeralFiber
// - OnionRouter
// - MixingNode
//
// Rust network layer should:
// 1. Use libp2p for actual network I/O
// 2. Call into Python for onion routing logic (via FFI or RPC)
// 3. OR port the onion logic to Rust later
//
// For MVP: Keep onion logic in Python, Rust does transport only
