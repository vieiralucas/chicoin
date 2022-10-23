use serde::Serialize;

use crate::key::{PK, SK};

#[derive(Debug, Serialize, Clone, Copy)]
pub struct Transaction {
    source: PK,
    receiver: PK,
    amount: u32,
}

impl Transaction {
    pub fn create(source: PK, receiver: PK, amount: u32, secret: SK) -> anyhow::Result<Self> {
        let transaction = Self {
            source,
            receiver,
            amount,
        };

        secret.sign(transaction)?.verify(&transaction, &source)?;

        Ok(transaction)
    }

    pub fn source(self) -> PK {
        self.source
    }

    pub fn receiver(self) -> PK {
        self.receiver
    }

    pub fn amount(self) -> u32 {
        self.amount
    }
}

#[cfg(test)]
mod test {
    use crate::key::Pair;

    use super::*;

    #[test]
    fn create_verifies_signature() {
        let thiefs_key = Pair::create();
        let victims_key = Pair::create();

        let trx = Transaction::create(
            victims_key.public(),
            thiefs_key.public(),
            1000,
            thiefs_key.secret(),
        );

        assert!(trx.is_err());
    }
}
