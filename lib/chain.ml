type chain = {
  genesis : Block.t;
  blocks : Block.t list;
  transactions : Transaction.Signed.t list;
  difficulty : int;
  reward : int;
}

and t = chain

let create ?(difficulty = 1) ?(reward = 1000) () =
  {
    genesis = Block.genesis;
    blocks = [];
    transactions = [];
    difficulty;
    reward;
  }

let last_block chain =
  match List.nth_opt chain.blocks 0 with Some b -> b | None -> chain.genesis

let add_block block chain =
  {
    chain with
    blocks = block :: chain.blocks;
    transactions =
      (* TODO: improve performance here *)
      List.filter
        (fun t1 -> not (List.exists (fun t2 -> t1 = t2) block.transactions))
        chain.transactions;
  }

type mine_error = Reward_transaction_sign_err

let mine reward_addr chain =
  let reward_trx = Transaction.Signed.mint reward_addr chain.reward in
  match reward_trx with
  | Some reward_trx ->
      let rec pow block =
        if Block.obeys_difficulty chain.difficulty block then block
        else pow { block with nonce = block.nonce + 1 }
      in
      let lb = last_block chain in
      let block =
        pow
          {
            previous_hash = Block.hash lb;
            transactions = reward_trx :: chain.transactions;
            nonce = 0;
          }
      in
      add_block block chain |> Result.ok
  | None -> Result.error Reward_transaction_sign_err

let balance_from_transaction (addr : Key.Public.t)
    (trx : Transaction.Transaction.t) =
  match (trx.source = addr, trx.receiver = addr) with
  | true, false -> trx.amount * -1
  | false, true -> trx.amount
  | _ -> 0

let balance_from_block (addr : Key.Public.t) (block : Block.t) =
  let trxs = block.transactions in
  List.fold_left
    (fun balance (trx : Transaction.Signed.t) ->
      balance + balance_from_transaction addr trx.transaction)
    0 trxs

let balance (addr : Key.Public.t) (chain : chain) =
  let balance =
    List.fold_left
      (fun balance block -> balance + balance_from_block addr block)
      0 chain.blocks
  in
  balance + balance_from_block addr chain.genesis

type add_transaction_error = Invalid_signature | Not_enought_funds

let add_transaction trx chain =
  if not (Transaction.Signed.verify trx) then Result.error Invalid_signature
  else
    let balance = balance trx.transaction.source chain in
    if balance < trx.transaction.amount then Result.error Not_enought_funds
    else Result.ok { chain with transactions = trx :: chain.transactions }
