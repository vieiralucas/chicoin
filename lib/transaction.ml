type transaction = {
  source : Key.Public.t;
  receiver : Key.Public.t;
  amount : int;
}

and t = transaction [@@deriving eq, show]

let mint_secret =
  Key.Secret.of_b58_s "GaZLS8x4bsTkvd2zgBeusQ8B2G6iJ3xpz2JnjDqm8psnbFCrh"
  |> Option.get

let mint_public = Key.Public.of_secret mint_secret

let to_bin trx =
  let s = Cstruct.string (Key.Public.to_b58_s trx.source) in
  let r = Cstruct.string (Key.Public.to_b58_s trx.receiver) in
  let a = Cstruct.string (string_of_int trx.amount) in
  Cstruct.concat [ s; r; a ]

let hash trx = to_bin trx |> Hash.of_bin
