"""
Onion Routing HTTP Service

HTTP endpoints for Rust node to call Python onion routing.
This is the bridge layer until onion logic is ported to Rust.

Endpoints:
  POST /onion/wrap   - Wrap transaction in onion layers
  POST /onion/peel   - Peel one layer (relay processing)
  GET  /onion/relays - Get registered relay fingerprints
"""

import json
import base64
from http.server import HTTPServer, BaseHTTPRequestHandler
from typing import Dict, Any
import numpy as np

from ..geometry.fiber_bundle import (
    FiberBundle,
    OnionRouter,
    OnionPacket,
    create_onion_route,
    peel_onion_layer,
)
from .routing import TransactionRouter, RelayNode, RelayNetwork

# Global relay network (initialized on startup)
_relay_network: RelayNetwork = RelayNetwork()
_router: TransactionRouter = None


def init_relay_network(relays: list = None):
    """Initialize relay network with relays."""
    global _relay_network, _router
    
    if relays:
        for relay in relays:
            _relay_network.register_relay(relay)
    
    if _relay_network.relay_count() > 0:
        _router = _relay_network.get_router()


class OnionServiceHandler(BaseHTTPRequestHandler):
    """HTTP handler for onion routing endpoints."""
    
    def _send_json(self, data: Dict[str, Any], status: int = 200):
        """Send JSON response."""
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def _read_json(self) -> Dict[str, Any]:
        """Read JSON request body."""
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        return json.loads(body.decode())
    
    def do_GET(self):
        """Handle GET requests."""
        if self.path == '/health':
            self._send_json({
                'status': 'healthy',
                'service': 'onion-routing',
                'relay_count': _relay_network.relay_count()
            })
        
        elif self.path == '/onion/relays':
            relays = []
            for relay in _relay_network.relays:
                relays.append({
                    'fingerprint': base64.b64encode(relay.fingerprint).decode(),
                    'address': relay.address
                })
            self._send_json({'relays': relays})
        
        else:
            self._send_json({'error': 'Not found'}, 404)
    
    def do_POST(self):
        """Handle POST requests."""
        try:
            data = self._read_json()
            
            if self.path == '/onion/wrap':
                result = self._handle_wrap(data)
                self._send_json(result)
            
            elif self.path == '/onion/peel':
                result = self._handle_peel(data)
                self._send_json(result)
            
            elif self.path == '/relay/register':
                result = self._handle_register(data)
                self._send_json(result)
            
            else:
                self._send_json({'error': 'Not found'}, 404)
        
        except Exception as e:
            self._send_json({'error': str(e)}, 500)
    
    def _handle_wrap(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Wrap transaction data in onion layers.
        
        Uses ORTHOGONAL parallel transport for encryption.
        Message is encoded as a float64 vector in fiber space.
        
        Request:
            {
                "message": "<base64 encoded bytes>",
                "hop_count": 3  # optional
            }
        
        Response:
            {
                "packet": {
                    "layers": ["<base64>", ...],
                    "path_hints": [[1,2,3], ...],
                    "current_layer": 0
                },
                "entry_relay": "<fingerprint>"
            }
        """
        global _router
        
        if _router is None:
            return {'error': 'No relays registered'}
        
        # Decode message bytes
        message_bytes = base64.b64decode(data['message'])
        
        hop_count = data.get('hop_count', 3)
        
        # Select relay path
        relay_path = _router.select_relay_path("", min(hop_count, len(_router.relays)))
        
        if not relay_path:
            return {'error': 'No relay path available'}
        
        # Get fiber dimension from first relay
        fiber_dim = relay_path[0].bundle.fiber_dim
        
        # Encode message bytes as float64 vector in fiber space
        # Pad or chunk to match fiber_dim
        byte_array = np.frombuffer(message_bytes, dtype=np.uint8)
        message = byte_array.astype(np.float64)
        
        if len(message) < fiber_dim:
            # Pad with zeros
            padded = np.zeros(fiber_dim, dtype=np.float64)
            padded[:len(message)] = message
            message = padded
        elif len(message) > fiber_dim:
            # For now, truncate (proper chunking would be needed for large messages)
            message = message[:fiber_dim]
        
        # Create onion packet (now using orthogonal geometry)
        relay_bundles = [relay.bundle for relay in relay_path]
        relay_keys = [_router._derive_relay_key(relay) for relay in relay_path]
        
        packet = create_onion_route(relay_bundles, message, relay_keys)
        
        # Serialize packet - layers are now float64 arrays
        return {
            'packet': {
                'layers': [base64.b64encode(layer.astype(np.float64).tobytes()).decode() for layer in packet.layers],
                'path_hints': packet.path_hints,
                'current_layer': packet.current_layer,
                'original_length': len(byte_array)  # Store original length for decoding
            },
            'entry_relay': base64.b64encode(relay_path[0].fingerprint).decode()
        }
    
    def _handle_peel(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Peel one onion layer (relay processing).
        
        Uses ORTHOGONAL inverse transport for decryption.
        Layers are float64 vectors in fiber space.
        
        Request:
            {
                "packet": {
                    "layers": [...],
                    "path_hints": [...],
                    "current_layer": N,
                    "original_length": M  # optional, for final decode
                },
                "relay_fingerprint": "<base64>"
            }
        
        Response:
            {
                "data": "<base64 decrypted data>",
                "is_final": true/false,
                "packet": <updated packet>
            }
        """
        # Find relay by fingerprint
        fingerprint = base64.b64decode(data['relay_fingerprint'])
        
        relay = None
        for r in _relay_network.relays:
            if r.fingerprint == fingerprint:
                relay = r
                break
        
        if relay is None:
            return {'error': 'Relay not found'}
        
        # Reconstruct packet - layers are float64 arrays (orthogonal geometry)
        layers = [
            np.frombuffer(base64.b64decode(l), dtype=np.float64)
            for l in data['packet']['layers']
        ]
        packet = OnionPacket(
            layers=layers,
            path_hints=data['packet']['path_hints'],
            current_layer=data['packet']['current_layer']
        )
        
        # Peel layer using orthogonal inverse transport
        bundle = relay.bundle
        key = _router._derive_relay_key(relay) if _router else np.zeros(bundle.fiber_dim)
        
        decrypted, is_final = peel_onion_layer(packet, bundle, key)
        
        # If final layer, convert back to bytes
        if is_final:
            original_length = data['packet'].get('original_length', len(decrypted))
            # Round to nearest integer and clip to byte range
            byte_data = np.clip(np.round(decrypted[:original_length]), 0, 255).astype(np.uint8)
            data_b64 = base64.b64encode(byte_data.tobytes()).decode()
        else:
            # Intermediate layer - keep as float64
            data_b64 = base64.b64encode(decrypted.astype(np.float64).tobytes()).decode()
        
        return {
            'data': data_b64,
            'is_final': is_final,
            'packet': {
                'layers': [base64.b64encode(l.astype(np.float64).tobytes()).decode() for l in packet.layers],
                'path_hints': packet.path_hints,
                'current_layer': packet.current_layer,
                'original_length': data['packet'].get('original_length')
            }
        }
    
    def _handle_register(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Register a relay node.
        
        Request:
            {
                "address": "ip:port",
                "credential": <serialized credential>
            }
        """
        # For now, generate a mock relay with unique ID
        from ..crypto.credential import generate_credential
        import uuid
        
        address = data.get('address', 'localhost:9001')
        
        # Use UUID to ensure unique credentials per registration
        # Use 2-party topology so fiber bundles have edges for random walks
        unique_id = uuid.uuid4().hex[:8]
        party_a = f"relay_{unique_id}_a"
        party_b = f"relay_{unique_id}_b"
        
        cred = generate_credential(
            parties=[party_a, party_b],
            connections=[(party_a, party_b)],  # Need edge for random walk
        )
        
        relay = RelayNode(credential=cred, address=address)
        success = _relay_network.register_relay(relay)
        
        # Update router
        global _router
        _router = _relay_network.get_router()
        
        return {
            'success': success,
            'fingerprint': base64.b64encode(relay.fingerprint).decode(),
            'relay_count': _relay_network.relay_count()
        }
    
    def log_message(self, format, *args):
        """Suppress default logging."""
        pass


def run_onion_service(host: str = '127.0.0.1', port: int = 9934):
    """
    Run the onion routing HTTP service.
    
    Default port 9934 (one above RPC 9933).
    """
    print(f"🧅 Starting Onion Routing Service on http://{host}:{port}")
    print("   Endpoints:")
    print("   - GET  /health       - Service health")
    print("   - GET  /onion/relays - List registered relays")
    print("   - POST /onion/wrap   - Wrap message in onion layers")
    print("   - POST /onion/peel   - Peel one onion layer")
    print("   - POST /relay/register - Register a relay")
    
    server = HTTPServer((host, port), OnionServiceHandler)
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 Onion service shutting down")
        server.shutdown()


if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Onion Routing Service')
    parser.add_argument('--host', default='127.0.0.1', help='Bind host')
    parser.add_argument('--port', type=int, default=9934, help='Bind port')
    
    args = parser.parse_args()
    run_onion_service(args.host, args.port)
