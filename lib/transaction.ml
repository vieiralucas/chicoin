let mint_secret =
  Key.Secret.of_b58_s "GaZLS8x4bsTkvd2zgBeusQ8B2G6iJ3xpz2JnjDqm8psnbFCrh"
  |> Option.get

let mint_public = Key.Public.of_secret mint_secret

module Transaction = struct
  type transaction = {
    source : Key.Public.t;
    receiver : Key.Public.t;
    amount : int;
    fee : int;
  }

  and t = transaction [@@deriving eq, show]

  let to_bin transaction =
    let s = Cstruct.string (Key.Public.to_b58_s transaction.source) in
    let r = Cstruct.string (Key.Public.to_b58_s transaction.receiver) in
    let a = Cstruct.string (string_of_int transaction.amount) in
    let f = Cstruct.string (string_of_int transaction.fee) in
    Cstruct.concat [ s; r; a; f ]

  let hash trx = to_bin trx |> Hash.of_bin
end

module Signed = struct
  type signed_transaction = {
    signature : Key.Signature.t;
    transaction : Transaction.t;
  }

  and t = signed_transaction [@@deriving eq, show]

  let sign transaction secret =
    Transaction.hash transaction
    |> Key.Signature.sign secret
    |> Option.map (fun signature -> { signature; transaction })

  let hash trx =
    (Transaction.hash trx.transaction |> Hash.to_string)
    ^ (Key.Signature.to_b58 trx.signature |> B58.to_string)
    |> Cstruct.string |> Hash.of_bin

  let to_bin trx = hash trx |> Hash.to_string |> Cstruct.string

  let verify trx =
    let pk = trx.transaction.source in
    let hash = Transaction.hash trx.transaction in
    Key.Signature.verify pk trx.signature hash

  let mint addr reward =
    sign
      { source = mint_public; receiver = addr; amount = reward; fee = 0 }
      mint_secret
end
