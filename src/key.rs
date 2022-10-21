use secp256k1::rand::thread_rng;
use secp256k1::{KeyPair, Secp256k1};

pub fn generate_keypair() -> KeyPair {
    let secp = Secp256k1::new();
    KeyPair::new(&secp, &mut thread_rng())
}
