type chain = { genesis : Block.t; blocks : Block.t list }
and t = chain

let rec is_valid chain =
  match chain.blocks with
  | [] -> true
  | b :: [] -> b.previous_hash == Block.hash chain.genesis
  | b1 :: b2 :: bs ->
      if b1.previous_hash != Block.hash b2 then false
      else is_valid { chain with blocks = b2 :: bs }
