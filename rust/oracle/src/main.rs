// Oracle Interface
// Communication layer between Python workers and Rust node
//
// Implements natural transformation η: F_full → F_hash
// - Receives full stalks from Python via HTTP
// - Computes geometric commitment (harmonic projection)
// - Forwards commitments to Rust chain

use hcrypt_oracle::http;

use anyhow::Result;
use clap::Parser;
use tracing::{info, Level};

#[derive(Parser)]
#[command(name = "hcrypt-oracle")]
#[command(about = "Oracle interface for homotopical encryption")]
struct Args {
    /// Address to bind HTTP server
    #[arg(short, long, default_value = "127.0.0.1:9090")]
    bind: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_max_level(Level::INFO)
        .init();

    let args = Args::parse();

    info!("🔮 Starting Oracle Interface");
    info!("   Orchestrates η: F_full → F_hash");
    info!("   - Receives: Full stalks from Python");
    info!("   - Computes: Harmonic projection (geometric commitment)");
    info!("   - Verifies: Naturality conditions");
    info!("   - Forwards: Hash stalks to Rust chain");
    info!("");
    info!("   Storage commitment: Harmonic projection to ker(Δ)");
    info!("   Verification: Naturality + H^1 = 0");

    // Run HTTP server
    http::run_server(&args.bind).await?;

    info!("🔮 Oracle shutting down");
    Ok(())
}
