use clap::Parser;
use std::sync::{mpsc, RwLock};
use std::thread;
use std::{net::SocketAddr, sync::Arc};

use chicoin::block::Block;
use chicoin::chain::Chain;
use chicoin::key::{Pair, SK};
use chicoin::p2p::P2P;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
enum Message {
    ExchangeChain(Chain),
}

struct State {
    chain: Chain,
    nonce: u64,
}

#[derive(Parser, Debug)]
struct Args {
    #[clap(long, value_parser)]
    local: SocketAddr,
    #[clap(long, value_parser)]
    public: SocketAddr,
    #[clap(long, value_parser)]
    peer: SocketAddr,
}

fn main() -> anyhow::Result<()> {
    env_logger::try_init()?;

    let args = Args::parse();
    let local_addr: SocketAddr = args.local;
    let public_addr: SocketAddr = args.public;
    let firs_peer_addr: SocketAddr = args.peer;
    let (tx, rx) = mpsc::channel::<Vec<u8>>();

    let p2p = P2P::spawn(local_addr, public_addr, firs_peer_addr, tx)?;

    let genesis = Block {
        previous_hash: [0; 32],
        transactions: Vec::new(),
        nonce: 0,
    };
    let chain = Chain::new(genesis, 2, 1000);
    let state = Arc::new(RwLock::new(State { chain, nonce: 0 }));

    p2p.send(&bincode::serialize(&Message::ExchangeChain(
        state.read().expect("lock state for reading").chain.clone(),
    ))?)?;

    let miner_state = Arc::clone(&state);
    thread::spawn(move || -> anyhow::Result<()> {
        let mint_pair = Pair::from_secret(SK::from_slice(&[
            243, 176, 162, 251, 227, 120, 131, 198, 87, 234, 42, 145, 72, 10, 156, 39, 80, 100,
            213, 44, 139, 116, 38, 131, 121, 249, 34, 80, 53, 109, 118, 150,
        ])?);

        let pair = Pair::create();
        loop {
            loop {
                let curr_nonce = miner_state.read().expect("lock state for reading").nonce;
                let new_chain = miner_state
                    .read()
                    .expect("lock state for reading")
                    .chain
                    .mine(curr_nonce, &mint_pair, pair.public())?;
                if let Some(new_chain) = new_chain {
                    log::info!("New block mined");
                    let mut state = miner_state.write().expect("lock state for writting");
                    state.chain = new_chain.clone();
                    state.nonce = 0;
                    p2p.send(&bincode::serialize(&Message::ExchangeChain(new_chain))?)?;
                    break;
                }
                if miner_state.read().expect("lock state for reading").nonce == curr_nonce {
                    miner_state.write().expect("lock state for writting").nonce += 1;
                }
            }
        }
    });

    loop {
        let msg: Message = bincode::deserialize(&rx.recv()?)?;
        match msg {
            Message::ExchangeChain(ref new_chain) => {
                let current_size = state.read().expect("lock state for reading").chain.size();
                if new_chain.size() > current_size {
                    log::info!("got a bigger chain {} < {}", current_size, new_chain.size());
                    state.write().expect("lock state for writting").chain = new_chain.clone();
                }
            }
        }
    }
}
