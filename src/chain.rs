use crate::block::Block;
use crate::key::{Pair, PK};
use crate::transaction::Transaction;

#[derive(Debug)]
pub struct Chain {
    genesis: Block,
    blocks: Vec<Block>,
    transactions: Vec<Transaction>,
    difficulty: usize,
    reward: u32,
    mint: Pair,
}

impl Chain {
    pub fn new(genesis: Block, difficulty: usize, reward: u32) -> Self {
        Self {
            genesis,
            blocks: Vec::new(),
            transactions: Vec::new(),
            difficulty,
            reward,
            mint: Pair::create(),
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

    fn mint(&self, reward_addr: PK) -> anyhow::Result<Transaction> {
        Transaction::create(
            self.mint.public(),
            reward_addr,
            self.reward,
            self.mint.secret(),
        )
    }

    fn last_block(&self) -> &Block {
        self.blocks.first().unwrap_or(&self.genesis)
    }

    pub fn mine(&mut self, reward_addr: PK) -> anyhow::Result<()> {
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

    pub fn add_transaction(&mut self, transaction: Transaction) {
        self.transactions.push(transaction);
    }
}
