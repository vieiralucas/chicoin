use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::io::Write;
use std::net::{SocketAddr, TcpListener, TcpStream};
use std::sync::{Arc, RwLock};
use std::thread;

#[derive(Serialize, Deserialize, Debug)]
enum Message {
    HandshakeSyn(SocketAddr, Vec<SocketAddr>),
    HandshakeAck(Vec<SocketAddr>),
}

type Peers = Arc<RwLock<HashMap<SocketAddr, TcpStream>>>;

fn handle_peer(
    our_public_addr: SocketAddr,
    peers: &mut Peers,
    addr: SocketAddr,
    stream: TcpStream,
) -> anyhow::Result<()> {
    log::info!("listening to peer: {:?}", addr);

    let mut peers = Arc::clone(peers);
    thread::spawn(move || -> anyhow::Result<()> {
        loop {
            let message: Message = bincode::deserialize_from(stream.try_clone()?)?;
            handle_message(our_public_addr, &mut peers, stream.try_clone()?, message)?;
        }
    });

    Ok(())
}

fn handle_message(
    our_public_addr: SocketAddr,
    peers: &mut Peers,
    mut origin: TcpStream,
    message: Message,
) -> anyhow::Result<()> {
    log::info!("Got message: {:?}", message);
    match message {
        Message::HandshakeSyn(sender, sender_peers) => {
            peers
                .write()
                .expect("acquire write lock of peers map")
                .insert(sender, origin.try_clone()?);

            let mut current_peers = Vec::new();
            for peer in peers.read().expect("acquire read lock of peers map").keys() {
                current_peers.push(*peer);
            }

            // connect to each receving peer we don't know yet and send a syn
            for addr in sender_peers.iter() {
                if *addr == our_public_addr {
                    log::info!("skipping ourselves");
                    continue;
                }

                if peers
                    .read()
                    .expect("acquire read lock of peers map")
                    .contains_key(addr)
                {
                    log::info!("already know addr {:?}", addr);
                    continue;
                }

                let mut stream = TcpStream::connect(addr)?;
                peers
                    .write()
                    .expect("acquire write lock of peers map")
                    .insert(*addr, stream.try_clone()?);
                handle_peer(
                    our_public_addr,
                    &mut Arc::clone(peers),
                    *addr,
                    stream.try_clone()?,
                )?;
                let syn = bincode::serialize(&Message::HandshakeSyn(
                    our_public_addr,
                    current_peers.clone(),
                ))?;
                stream.write_all(&syn)?;
            }

            // send an ack back with all of our current peers
            let ack = bincode::serialize(&Message::HandshakeAck(current_peers))?;
            origin.write_all(&ack)?;
        }
        Message::HandshakeAck(addrs) => {
            // connect to each receving peer we don't know yet and send a syn
            for addr in addrs.iter() {
                if *addr == our_public_addr {
                    log::info!("skipping ourselves");
                    continue;
                }

                if peers
                    .read()
                    .expect("acquire read lock of peers map")
                    .contains_key(addr)
                {
                    log::info!("already know addr {:?}", addr);
                    continue;
                }

                let mut current_peers = Vec::new();
                for peer in peers.read().expect("acquire read lock of peers map").keys() {
                    current_peers.push(*peer);
                }

                log::info!("connecting to peer: {:?}", addr);
                let mut stream = TcpStream::connect(addr)?;
                peers
                    .write()
                    .expect("acquire write lock of peers map")
                    .insert(*addr, stream.try_clone()?);
                handle_peer(
                    our_public_addr,
                    &mut Arc::clone(peers),
                    *addr,
                    stream.try_clone()?,
                )?;
                let syn =
                    bincode::serialize(&Message::HandshakeSyn(our_public_addr, current_peers))?;
                stream.write_all(&syn)?;
            }
        }
    }

    Ok(())
}

pub struct P2P {
    peers: Peers,
    local_addr: SocketAddr,
    public_addr: SocketAddr,
}

impl P2P {
    pub fn new(local_addr: SocketAddr, public_addr: SocketAddr) -> Self {
        Self {
            peers: Default::default(),
            public_addr,
            local_addr,
        }
    }

    pub fn run(&mut self, first_peer_addr: SocketAddr) -> anyhow::Result<()> {
        let listener = TcpListener::bind(self.local_addr)?;
        log::info!(
            "listening at {:?}. public addr is: {:?}",
            self.local_addr,
            self.public_addr
        );

        // connect to first node and send HandshakeSyn
        if self.local_addr != first_peer_addr {
            log::info!("connecting to first peer at: {:?}", first_peer_addr);
            let mut stream = TcpStream::connect(first_peer_addr)?;
            log::info!("connected to first peer");
            let addr = stream.peer_addr()?;
            self.peers
                .write()
                .expect("acquire write lock of peers map")
                .insert(first_peer_addr, stream.try_clone()?);
            let handshake_syn = Message::HandshakeSyn(self.public_addr, Vec::new());
            stream.write_all(&bincode::serialize(&handshake_syn)?)?;
            handle_peer(self.public_addr, &mut Arc::clone(&self.peers), addr, stream)?;
        }

        loop {
            let (stream, addr) = listener.accept()?;
            handle_peer(self.public_addr, &mut Arc::clone(&self.peers), addr, stream)?;
        }
    }
}
