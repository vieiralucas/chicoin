use chicoin::block::Block;
use chicoin::chain::Chain;
use chicoin::key::generate_keypair;
use chicoin::transaction::Transaction;

#[test]
fn test_chain() -> anyhow::Result<()> {
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
    chain.add_transaction(t1)?;

    let t2 = Transaction {
        source: miner.public_key(),
        receiver: r2.public_key(),
        amount: 20,
    }
    .sign(miner.secret_key())?;
    chain.add_transaction(t2)?;

    chain.mine(miner.public_key())?;

    assert_eq!(0, chain.transactions().len());
    assert_eq!(10, chain.balance(r1.public_key()));
    assert_eq!(20, chain.balance(r2.public_key()));
    assert_eq!(
        (chain.reward() - 30 + chain.reward()) as i64,
        chain.balance(miner.public_key())
    );

    Ok(())
}
