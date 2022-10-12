open Mirage_crypto.Hash

type block = { previous_hash : string; nonce : int } [@@deriving eq]
and t = block

let sha_s s = SHA256.get s |> Hex.of_cstruct |> Hex.show
let genesis = { previous_hash = sha_s SHA256.empty; nonce = 0 }

let hash block =
  let h = SHA256.empty in
  let h = Cstruct.string block.previous_hash |> SHA256.feed h in
  let h = Cstruct.string (string_of_int block.nonce) |> SHA256.feed h in
  sha_s h

let obeys_difficulty difficulty block =
  let h = hash block in
  let prefix = String.make difficulty '0' in
  String.starts_with ~prefix h
