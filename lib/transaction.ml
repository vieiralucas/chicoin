let () = Mirage_crypto_rng_unix.initialize ()
let context = Secp256k1.Context.create []

module Secret = struct
  type secret = Secp256k1.Key.secret Secp256k1.Key.t
  type t = secret

  let generate =
    Mirage_crypto_rng.generate 32
    |> Cstruct.to_bytes |> Bigstring.of_bytes
    |> Secp256k1.Key.read_sk_exn context

  let to_b58 secret =
    let (Tezos_base58.Base58 str) =
      secret
      |> Secp256k1.Key.to_bytes context
      |> Bigstring.to_string
      |> Tezos_base58.encode ~prefix:""
    in
    str

  let of_b58 str =
    Tezos_base58.Base58 str
    |> Tezos_base58.decode ~prefix:""
    |> Option.get |> Bigstring.of_string
    |> Secp256k1.Key.read_sk context
    |> Result.to_option
end

module Key = struct
  type key = Secp256k1.Key.public Secp256k1.Key.t
  type t = key

  let of_secret = Secp256k1.Key.neuterize_exn context
end

let mint_secret =
  Secret.of_b58 "GaZLS8x4bsTkvd2zgBeusQ8B2G6iJ3xpz2JnjDqm8psnbFCrh"
  |> Option.get

type transaction = unit
