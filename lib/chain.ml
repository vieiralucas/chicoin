type chain = { genesis : Block.t; blocks : Block.t list; difficulty : int }
and t = chain

let last_block chain =
  match List.nth_opt chain.blocks 0 with Some b -> b | None -> chain.genesis

let add_block block chain = { chain with blocks = block :: chain.blocks }
let empty = { genesis = Block.genesis; blocks = []; difficulty = 1 }

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
  let block = pow { previous_hash = Block.hash lb; nonce = 0 } in
  add_block block chain
