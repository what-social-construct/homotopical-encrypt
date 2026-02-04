// HTTP Server - Axum-based REST/JSON-RPC interface
//
// Routes:
//   POST /rpc     - JSON-RPC endpoint
//   GET  /health  - Health check

use anyhow::Result;
use axum::{
    extract::State,
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::{info, error};

use crate::rpc::{OracleRpc, RpcRequest, RpcResponse};

/// Shared application state
pub struct AppState {
    pub rpc: OracleRpc,
}

/// Health check response
#[derive(Serialize)]
pub struct HealthResponse {
    pub status: String,
    pub version: String,
    pub service: String,
}

/// JSON-RPC wrapper
#[derive(Deserialize)]
pub struct JsonRpcRequest {
    pub jsonrpc: String,
    pub id: u64,
    #[serde(flatten)]
    pub request: RpcRequest,
}

#[derive(Serialize)]
pub struct JsonRpcResponse {
    pub jsonrpc: String,
    pub id: u64,
    pub result: RpcResponse,
}

/// Health check endpoint
async fn health() -> Json<HealthResponse> {
    Json(HealthResponse {
        status: "healthy".to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
        service: "hcrypt-oracle".to_string(),
    })
}

/// JSON-RPC endpoint
async fn rpc_handler(
    State(state): State<Arc<Mutex<AppState>>>,
    Json(payload): Json<JsonRpcRequest>,
) -> Result<Json<JsonRpcResponse>, (StatusCode, String)> {
    let state = state.lock().await;
    
    info!("RPC request: {:?}", payload.request);
    
    let result = state.rpc.handle_request(payload.request).await;
    
    Ok(Json(JsonRpcResponse {
        jsonrpc: "2.0".to_string(),
        id: payload.id,
        result,
    }))
}

/// Simple RPC endpoint (no JSON-RPC wrapper)
async fn simple_rpc(
    State(state): State<Arc<Mutex<AppState>>>,
    Json(request): Json<RpcRequest>,
) -> Json<RpcResponse> {
    let state = state.lock().await;
    
    info!("Simple RPC request: {:?}", request);
    
    let result = state.rpc.handle_request(request).await;
    Json(result)
}

/// Build the router
pub fn build_router(state: Arc<Mutex<AppState>>) -> Router {
    Router::new()
        .route("/health", get(health))
        .route("/rpc", post(simple_rpc))
        .route("/jsonrpc", post(rpc_handler))
        .with_state(state)
}

/// Run the HTTP server
pub async fn run_server(addr: &str) -> Result<()> {
    let state = Arc::new(Mutex::new(AppState {
        rpc: OracleRpc::new(),
    }));
    
    let app = build_router(state);
    
    let listener = tokio::net::TcpListener::bind(addr).await?;
    
    info!("🌐 HTTP server listening on {}", addr);
    info!("   Endpoints:");
    info!("   - GET  /health  - Health check");
    info!("   - POST /rpc     - Simple RPC");
    info!("   - POST /jsonrpc - JSON-RPC 2.0");
    
    axum::serve(listener, app).await?;
    
    Ok(())
}
