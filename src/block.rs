use secp256k1::PublicKey;
use serde::Serialize;
use sha2::{Digest, Sha256};

use crate::transaction::SignedTransaction;

pub type S256 = [u8; 32];

#[derive(Debug, Serialize)]
pub struct Block {
    pub previous_hash: S256,
    pub transactions: Vec<SignedTransaction>,
    pub nonce: u64,
}

impl Block {
    pub fn hash(&self) -> Result<S256, anyhow::Error> {
        let bin = bincode::serialize(self)?;
        let hash = Sha256::digest(bin);
        Ok(hash.as_slice().try_into().expect("Wrong length"))
    }

    pub fn balance(&self, addr: PublicKey) -> i64 {
        self.transactions
            .iter()
            .map(|signed| {
                let trx = signed.trx;
                match (trx.source == addr, trx.receiver == addr) {
                    (true, false) => -(trx.amount as i64),
                    (false, true) => trx.amount.into(),
                    _ => 0,
                }
            })
            .sum()
    }
}
