type block = { previous_hash : Sha256.t; nonce : int }
and t = block

let hash block =
  Sha256.to_bin block.previous_hash ^ string_of_int block.nonce |> Sha256.string

let genesis = { previous_hash = Sha256.zero; nonce = 0 }
