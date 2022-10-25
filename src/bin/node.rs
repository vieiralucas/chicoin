use clap::{arg, Parser};
use std::net::SocketAddr;

use chicoin::p2p::P2P;
use serde::{Deserialize, Serialize};

#[derive(Parser, Debug)]
struct Args {
    #[arg(short, long)]
    local: String,

    #[arg(long)]
    public: String,

    #[arg(long)]
    peer: String,
}

#[derive(Serialize, Deserialize, Debug)]
enum MessageContent {
    Ping(u32),
    Pong(u32),
}

fn main() -> anyhow::Result<()> {
    env_logger::try_init()?;

    let args = Args::parse();
    let local_addr: SocketAddr = args.local.parse()?;
    let public_addr: SocketAddr = args.public.parse()?;
    let first_peer_addr: SocketAddr = args.peer.parse()?;

    let mut p2p = P2P::new(local_addr, public_addr);
    p2p.run(first_peer_addr)?;

    Ok(())
}
