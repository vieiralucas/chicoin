type chain = { genesis : Block.t; blocks : Block.t list }
and t = chain

let is_hash_equal h1 h2 = Sha256.to_hex h1 = Sha256.to_hex h2

let rec is_valid chain =
  match chain.blocks with
  | [] -> true
  | b :: [] -> is_hash_equal b.previous_hash (Block.hash chain.genesis)
  | b1 :: b2 :: bs ->
      if not (is_hash_equal b1.previous_hash (Block.hash b2)) then false
      else is_valid { chain with blocks = b2 :: bs }

let%test "is valid when empty" =
  is_valid { genesis = Block.genesis; blocks = [] }

let%test "is valid when last block points to genesis" =
  is_valid
    {
      genesis = Block.genesis;
      blocks = [ { previous_hash = Block.hash Block.genesis; nonce = 0 } ];
    }

let%test "is valid when all blocks point to previous" =
  let b1 : Block.t = { previous_hash = Block.hash Block.genesis; nonce = 0 } in
  let b2 : Block.t = { previous_hash = Block.hash b1; nonce = 0 } in
  let b3 : Block.t = { previous_hash = Block.hash b2; nonce = 0 } in
  is_valid { genesis = Block.genesis; blocks = [ b3; b2; b1 ] }

let%test "is invalid when content of a block changes" =
  let b1 : Block.t = { previous_hash = Block.hash Block.genesis; nonce = 0 } in
  let b2 : Block.t = { previous_hash = Block.hash b1; nonce = 0 } in
  let b3 : Block.t = { previous_hash = Block.hash b2; nonce = 0 } in
  let b2 = { b2 with nonce = 1 } in
  let chain = { genesis = Block.genesis; blocks = [ b3; b2; b1 ] } in
  not (is_valid chain)
