type chain = { genesis : Block.t; blocks : Block.t list; difficulty : int }
and t = chain

let is_hash_equal h1 h2 = Sha256.to_hex h1 = Sha256.to_hex h2

let last_block chain =
  match List.nth_opt chain.blocks 0 with Some b -> b | None -> chain.genesis

let add_block block chain = { chain with blocks = block :: chain.blocks }

let rec is_valid chain =
  match chain.blocks with
  | [] -> true
  | b :: [] -> is_hash_equal b.previous_hash (Block.hash chain.genesis)
  | b1 :: b2 :: bs ->
      if not (is_hash_equal b1.previous_hash (Block.hash b2)) then false
      else is_valid { chain with blocks = b2 :: bs }

let mine chain =
  let rec pow block =
    let h = Block.hash block |> Sha256.to_hex in
    let prefix = String.make chain.difficulty '0' in
    if String.starts_with ~prefix h then block
    else pow { block with nonce = block.nonce + 1 }
  in
  let lb = last_block chain in
  let block = pow { previous_hash = Block.hash lb; nonce = 0 } in
  add_block block chain

let%test "is valid when empty" =
  is_valid { genesis = Block.genesis; blocks = []; difficulty = 0 }

let%test "is valid when last block points to genesis" =
  is_valid
    {
      genesis = Block.genesis;
      blocks = [ { previous_hash = Block.hash Block.genesis; nonce = 0 } ];
      difficulty = 0;
    }

let%test "is valid when all blocks point to previous" =
  let b1 : Block.t = { previous_hash = Block.hash Block.genesis; nonce = 0 } in
  let b2 : Block.t = { previous_hash = Block.hash b1; nonce = 0 } in
  let b3 : Block.t = { previous_hash = Block.hash b2; nonce = 0 } in
  is_valid { genesis = Block.genesis; blocks = [ b3; b2; b1 ]; difficulty = 0 }

let%test "is invalid when content of a block changes" =
  let b1 : Block.t = { previous_hash = Block.hash Block.genesis; nonce = 0 } in
  let b2 : Block.t = { previous_hash = Block.hash b1; nonce = 0 } in
  let b3 : Block.t = { previous_hash = Block.hash b2; nonce = 0 } in
  let b2 = { b2 with nonce = 1 } in
  let chain =
    { genesis = Block.genesis; blocks = [ b3; b2; b1 ]; difficulty = 0 }
  in
  not (is_valid chain)
