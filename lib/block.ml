type block = { previous_hash : Sha256.t; nonce : int }
and t = block

let genesis = { previous_hash = Sha256.zero; nonce = 0 }

let hash block =
  Sha256.to_hex block.previous_hash ^ string_of_int block.nonce |> Sha256.string

let equal b1 b2 = Sha256.to_hex (hash b1) = Sha256.to_hex (hash b2)

let obeys_difficulty difficulty block =
  let h = hash block |> Sha256.to_hex in
  let prefix = String.make difficulty '0' in
  String.starts_with ~prefix h
