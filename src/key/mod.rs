use secp256k1::rand::thread_rng;
use secp256k1::{ecdsa, Message, Secp256k1};
use serde::Serialize;
use sha2::{Digest, Sha256};

#[derive(Debug)]
pub struct Pair(secp256k1::KeyPair);

impl Pair {
    pub fn create() -> Self {
        let secp = Secp256k1::new();
        Self(secp256k1::KeyPair::new(&secp, &mut thread_rng()))
    }

    pub fn public(&self) -> PK {
        PK(self.0.public_key())
    }

    pub fn secret(&self) -> SK {
        SK(self.0.secret_key())
    }
}

#[derive(Serialize, Debug, Clone, Copy, PartialEq, Eq)]
pub struct PK(secp256k1::PublicKey);

#[derive(Serialize, Debug, Clone, Copy)]
pub struct SK(secp256k1::SecretKey);

impl SK {
    pub fn sign<T: Serialize>(self, value: T) -> anyhow::Result<Signature> {
        let bin = bincode::serialize(&value)?;
        let hash = Sha256::digest(bin);
        let message = Message::from_slice(&hash)?;
        let signature = self.0.sign_ecdsa(message);

        Ok(Signature(signature))
    }
}

pub struct Signature(ecdsa::Signature);

impl Signature {
    pub fn verify<T: Serialize>(self, value: &T, pk: &PK) -> anyhow::Result<()> {
        let bin = bincode::serialize(value)?;
        let hash = Sha256::digest(bin);
        let message = Message::from_slice(&hash)?;
        self.0.verify(&message, &pk.0)?;
        Ok(())
    }
}
