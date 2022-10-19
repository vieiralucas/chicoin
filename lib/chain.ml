type chain = {
  genesis : Block.t;
  blocks : Block.t list;
  transactions : Transaction.Signed.t list;
  difficulty : int;
}

and t = chain

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

let empty =
  { genesis = Block.genesis; blocks = []; transactions = []; difficulty = 1 }

let rec is_valid chain =
  match chain.blocks with
  | [] -> true
  | b :: [] -> b.previous_hash = Block.hash chain.genesis
  | b1 :: b2 :: bs ->
      if b1.previous_hash <> Block.hash b2 then false
      else is_valid { chain with blocks = b2 :: bs }

let mine chain =
  let rec pow block =
    if Block.obeys_difficulty chain.difficulty block then block
    else pow { block with nonce = block.nonce + 1 }
  in
  let lb = last_block chain in
  let block =
    pow
      {
        previous_hash = Block.hash lb;
        transactions = chain.transactions;
        nonce = 0;
      }
  in
  add_block block chain

let funds_from_transaction (pk : Key.Public.t) (trx : Transaction.Transaction.t)
    =
  match (trx.source = pk, trx.receiver = pk) with
  | true, false -> trx.amount * -1
  | false, true -> trx.amount
  | _ -> 0

let funds_from_block (pk : Key.Public.t) (block : Block.t) =
  let trxs = block.transactions in
  List.fold_left
    (fun amount (trx : Transaction.Signed.t) ->
      amount + funds_from_transaction pk trx.transaction)
    0 trxs

let funds_from_chain (pk : Key.Public.t) (chain : chain) =
  let amount =
    List.fold_left
      (fun amount block -> amount + funds_from_block pk block)
      0 chain.blocks
  in
  amount + funds_from_block pk chain.genesis

type add_transaction_error = Invalid_signature | Not_enought_funds

let add_transaction trx chain =
  if not (Transaction.Signed.verify trx) then Result.error Invalid_signature
  else
    let funds = funds_from_chain trx.transaction.source chain in
    if funds < trx.transaction.amount then Result.error Not_enought_funds
    else Result.ok { chain with transactions = trx :: chain.transactions }
