open Mirage_crypto.Hash

type hash = Hash of string [@@deriving eq, show]
and t = hash

let empty = Hash (SHA256.get SHA256.empty |> Hex.of_cstruct |> Hex.show)
let of_bin bin = Hash (SHA256.digest bin |> Hex.of_cstruct |> Hex.show)
let to_string (Hash str) = str
let starts_with prefix (Hash str) = String.starts_with ~prefix str
