use serde::Serialize;
use sha2::{Digest, Sha256};

use crate::key::PK;
use crate::transaction::Transaction;

pub type S256 = [u8; 32];

#[derive(Debug, Serialize)]
pub struct Block {
    pub previous_hash: S256,
    pub transactions: Vec<Transaction>,
    pub nonce: u64,
}

impl Block {
    pub fn hash(&self) -> Result<S256, anyhow::Error> {
        let bin = bincode::serialize(self)?;
        let hash = Sha256::digest(bin);
        Ok(hash.as_slice().try_into().expect("Wrong length"))
    }

    pub fn balance(&self, addr: PK) -> i64 {
        self.transactions
            .iter()
            .map(|trx| match (trx.source() == addr, trx.receiver() == addr) {
                (true, false) => -(trx.amount() as i64),
                (false, true) => trx.amount().into(),
                _ => 0,
            })
            .sum()
    }
}
