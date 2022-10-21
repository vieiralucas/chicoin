use secp256k1::ecdsa::Signature;
use secp256k1::rand::thread_rng;
use secp256k1::{KeyPair, Message, PublicKey, Secp256k1, SecretKey};
use serde::Serialize;
use sha2::{Digest, Sha256};

type S256 = [u8; 32];

#[derive(Debug, Serialize, Clone, Copy)]
struct Transaction {
    source: PublicKey,
    receiver: PublicKey,
    amount: u32,
}

impl Transaction {
    fn sign(self, secret: SecretKey) -> anyhow::Result<SignedTransaction> {
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
struct SignedTransaction {
    trx: Transaction,
    signature: Signature,
}

#[derive(Debug, Serialize)]
struct Block {
    previous_hash: S256,
    transactions: Vec<SignedTransaction>,
    nonce: u64,
}

impl Block {
    fn hash(&self) -> Result<S256, anyhow::Error> {
        let bin = bincode::serialize(self)?;
        let hash = Sha256::digest(bin);
        Ok(hash.as_slice().try_into().expect("Wrong length"))
    }

    fn balance(&self, addr: PublicKey) -> i64 {
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

#[derive(Debug)]
struct Chain {
    genesis: Block,
    blocks: Vec<Block>,
    transactions: Vec<SignedTransaction>,
    difficulty: usize,
    reward: u32,
    mint: KeyPair,
}

fn generate_keypair() -> KeyPair {
    let secp = Secp256k1::new();
    KeyPair::new(&secp, &mut thread_rng())
}

impl Chain {
    fn new(genesis: Block, difficulty: usize, reward: u32) -> Self {
        Self {
            genesis,
            blocks: Vec::new(),
            transactions: Vec::new(),
            difficulty,
            reward,
            mint: generate_keypair(),
        }
    }

    fn balance(&self, addr: PublicKey) -> i64 {
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

    fn mine(&mut self, reward_addr: PublicKey) -> anyhow::Result<()> {
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

    fn add_transaction(&mut self, transaction: SignedTransaction) {
        self.transactions.push(transaction);
    }
}

fn main() -> anyhow::Result<()> {
    let genesis = Block {
        previous_hash: [0; 32],
        transactions: Vec::new(),
        nonce: 0,
    };
    let mut chain = Chain::new(genesis, 1, 1000);

    let miner = generate_keypair();
    let r1 = generate_keypair();
    let r2 = generate_keypair();

    chain.mine(miner.public_key())?;
    let t1 = Transaction {
        source: miner.public_key(),
        receiver: r1.public_key(),
        amount: 10,
    }
    .sign(miner.secret_key())?;
    chain.add_transaction(t1);

    let t2 = Transaction {
        source: miner.public_key(),
        receiver: r2.public_key(),
        amount: 20,
    }
    .sign(miner.secret_key())?;
    chain.add_transaction(t2);

    chain.mine(miner.public_key())?;

    println!("{:?}", chain);

    assert_eq!(0, chain.transactions.len());
    assert_eq!(10, chain.balance(r1.public_key()));
    assert_eq!(20, chain.balance(r2.public_key()));
    assert_eq!(
        (chain.reward - 30 + chain.reward) as i64,
        chain.balance(miner.public_key())
    );

    Ok(())
}
