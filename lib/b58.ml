type b58 = B58 of string
and t = b58 [@@deriving eq, show]

let encode str =
  let (Tezos_base58.Base58 str) = Tezos_base58.encode ~prefix:"" str in
  B58 str

let decode (B58 b58) =
  Tezos_base58.Base58 b58 |> Tezos_base58.decode ~prefix:"" |> Option.get

let of_string str =
  Tezos_base58.Base58 str
  |> Tezos_base58.decode ~prefix:""
  |> Option.map (fun _ -> B58 str)

let to_string (B58 b58) = b58
