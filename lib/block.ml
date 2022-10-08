type block = { previous_hash : Sha256.t; nonce : int }
and t = block

let hash block =
  Sha256.to_bin block.previous_hash ^ string_of_int block.nonce |> Sha256.string

let genesis = { previous_hash = Sha256.zero; nonce = 0 }

let%test "genesis hash" =
  hash genesis |> Sha256.to_hex
  = "38fe84930aa052894b25ca82eddb24583cc33884bb571d1a5e8039288e6975f4"

let%test "hash depends on nonce" =
  let h1 = hash { previous_hash = Sha256.zero; nonce = 0 } in
  let h2 = hash { previous_hash = Sha256.zero; nonce = 1 } in
  Sha256.to_hex h1 <> Sha256.to_hex h2

let%test "hash depends on previous_hash" =
  let h1 = hash { previous_hash = Sha256.string "h1"; nonce = 0 } in
  let h2 = hash { previous_hash = Sha256.string "h2"; nonce = 0 } in
  Sha256.to_hex h1 <> Sha256.to_hex h2
