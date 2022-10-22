use secp256k1::{KeyPair, Message, PublicKey};
use sha2::{Digest, Sha256};

use crate::block::Block;
use crate::key::generate_keypair;
use crate::transaction::{SignedTransaction, Transaction};

#[derive(Debug)]
pub struct Chain {
    genesis: Block,
    blocks: Vec<Block>,
    transactions: Vec<SignedTransaction>,
    difficulty: usize,
    reward: u32,
    mint: KeyPair,
}

impl Chain {
    pub fn new(genesis: Block, difficulty: usize, reward: u32) -> Self {
        Self {
            genesis,
            blocks: Vec::new(),
            transactions: Vec::new(),
            difficulty,
            reward,
            mint: generate_keypair(),
        }
    }

    pub fn reward(&self) -> u32 {
        self.reward
    }

    pub fn transactions(&self) -> &Vec<SignedTransaction> {
        &self.transactions
    }

    pub fn balance(&self, addr: PublicKey) -> i64 {
        self.blocks.iter().map(|b| b.balance(addr)).sum()
    }

    fn mint(&self, reward_addr: PublicKey) -> anyhow::Result<SignedTransaction> {
        Transaction {
            source: self.mint.public_key(),
            receiver: reward_addr,
            amount: self.reward,
        }
        .sign(self.mint.secret_key())
    }

    fn last_block(&self) -> &Block {
        self.blocks.first().unwrap_or(&self.genesis)
    }

    pub fn mine(&mut self, reward_addr: PublicKey) -> anyhow::Result<()> {
        let reward_tx = self.mint(reward_addr)?;
        let mut transactions = self.transactions.clone();
        transactions.push(reward_tx);

        let nonce: u64 = 0;
        let mut block = Block {
            previous_hash: self.last_block().hash()?,
            transactions,
            nonce,
        };
        let block = loop {
            if block.hash()?.iter().take(self.difficulty).all(|b| *b == 0) {
                break block;
            }

            block.nonce += 1;
        };

        self.transactions = Vec::new();
        self.blocks.push(block);

        Ok(())
    }

    pub fn add_transaction(&mut self, transaction: SignedTransaction) -> anyhow::Result<()> {
        let bin = bincode::serialize(&transaction.trx)?;
        let hash = Sha256::digest(bin);
        let message = Message::from_slice(&hash)?;

        transaction
            .signature
            .verify(&message, &transaction.trx.source)?;

        self.transactions.push(transaction);

        Ok(())
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn add_transaction_verifies_signature() -> anyhow::Result<()> {
        let thiefs_key = generate_keypair();
        let victims_key = generate_keypair();

        let trx = Transaction {
            source: victims_key.public_key(),
            receiver: thiefs_key.public_key(),
            amount: 10000,
        }
        .sign(thiefs_key.secret_key())?;

        let genesis = Block {
            previous_hash: [0; 32],
            transactions: Vec::new(),
            nonce: 0,
        };
        let mut chain = Chain::new(genesis, 1, 1000);
        let result = chain.add_transaction(trx);

        // TODO: how to improve this assertion?
        assert!(result.is_err());

        Ok(())
    }
}
