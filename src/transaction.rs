use secp256k1::ecdsa::Signature;
use secp256k1::{Message, PublicKey, SecretKey};
use serde::Serialize;
use sha2::{Digest, Sha256};

#[derive(Debug, Serialize, Clone, Copy)]
pub struct Transaction {
    pub source: PublicKey,
    pub receiver: PublicKey,
    pub amount: u32,
}

impl Transaction {
    pub fn sign(self, secret: SecretKey) -> anyhow::Result<SignedTransaction> {
        let bin = bincode::serialize(&self)?;
        let hash = Sha256::digest(bin);
        let message = Message::from_slice(&hash)?;
        Ok(SignedTransaction {
            trx: self,
            signature: secret.sign_ecdsa(message),
        })
    }
}

#[derive(Debug, Serialize, Clone, Copy)]
pub struct SignedTransaction {
    pub trx: Transaction,
    pub signature: Signature,
}
