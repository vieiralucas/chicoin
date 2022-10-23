use chicoin::block::Block;
use chicoin::chain::Chain;
use chicoin::key::Pair;
use chicoin::transaction::Transaction;

#[test]
fn test_chain() -> anyhow::Result<()> {
    let genesis = Block {
        previous_hash: [0; 32],
        transactions: Vec::new(),
        nonce: 0,
    };
    let mut chain = Chain::new(genesis, 1, 1000);

    let miner = Pair::create();
    let r1 = Pair::create();
    let r2 = Pair::create();

    chain.mine(miner.public())?;
    let t1 = Transaction::create(miner.public(), r1.public(), 10, miner.secret())?;
    chain.add_transaction(t1);

    let t2 = Transaction::create(miner.public(), r2.public(), 20, miner.secret())?;
    chain.add_transaction(t2);

    chain.mine(miner.public())?;

    assert_eq!(0, chain.transactions().len());
    assert_eq!(10, chain.balance(r1.public()));
    assert_eq!(20, chain.balance(r2.public()));
    assert_eq!(
        (chain.reward() - 30 + chain.reward()) as i64,
        chain.balance(miner.public())
    );

    Ok(())
}
