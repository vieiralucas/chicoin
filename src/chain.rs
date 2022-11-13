use serde::{Deserialize, Serialize};

use crate::block::Block;
use crate::key::{Pair, PK};
use crate::transaction::Transaction;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Chain {
    genesis: Block,
    blocks: Vec<Block>,
    transactions: Vec<Transaction>,
    difficulty: usize,
    reward: u32,
}

impl Chain {
    pub fn new(genesis: Block, difficulty: usize, reward: u32) -> Self {
        Self {
            genesis,
            blocks: Vec::new(),
            transactions: Vec::new(),
            difficulty,
            reward,
        }
    }

    pub fn reward(&self) -> u32 {
        self.reward
    }

    pub fn transactions(&self) -> &Vec<Transaction> {
        &self.transactions
    }

    pub fn balance(&self, addr: PK) -> i64 {
        self.blocks.iter().map(|b| b.balance(addr)).sum()
    }

    fn mint(&self, mint: &Pair, reward_addr: PK) -> anyhow::Result<Transaction> {
        Transaction::create(mint.public(), reward_addr, self.reward, mint.secret())
    }

    fn last_block(&self) -> &Block {
        self.blocks.first().unwrap_or(&self.genesis)
    }

    pub fn mine(&self, nonce: u64, mint: &Pair, reward_addr: PK) -> anyhow::Result<Option<Chain>> {
        let reward_tx = self.mint(mint, reward_addr)?;
        let mut transactions = self.transactions.clone();
        transactions.push(reward_tx);

        let block = Block {
            previous_hash: self.last_block().hash()?,
            transactions,
            nonce,
        };

        if block.hash()?.iter().take(self.difficulty).all(|b| *b == 0) {
            let mut next_chain = self.clone();
            next_chain.transactions = Vec::new();
            next_chain.blocks.push(block);
            Ok(Some(next_chain))
        } else {
            Ok(None)
        }

        // self.transactions = Vec::new();
        // self.blocks.push(block);
        // Ok(())
    }

    pub fn add_transaction(&mut self, transaction: Transaction) {
        self.transactions.push(transaction);
    }

    pub fn size(&self) -> usize {
        self.blocks.len()
    }
}
