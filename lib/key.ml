let () = Mirage_crypto_rng_unix.initialize ()
let context = Secp256k1.Context.create []

module Secret = struct
  type secret = Secp256k1.Key.secret Secp256k1.Key.t
  and t = secret

  let generate =
    Mirage_crypto_rng.generate 32
    |> Cstruct.to_bytes |> Bigstring.of_bytes
    |> Secp256k1.Key.read_sk_exn context

  let to_b58 secret =
    secret
    |> Secp256k1.Key.to_bytes context
    |> Bigstring.to_string |> B58.encode

  let to_b58_s secret = to_b58 secret |> B58.to_string

  let of_b58 b58 =
    B58.decode b58 |> Bigstring.of_string
    |> Secp256k1.Key.read_sk context
    |> Result.to_option

  let of_b58_s str = Option.bind (B58.of_string str) of_b58
  let equal = Secp256k1.Key.equal
end

module Public = struct
  type pub = Secp256k1.Key.public Secp256k1.Key.t
  and t = pub

  let of_secret = Secp256k1.Key.neuterize_exn context

  let to_b58 pub =
    pub |> Secp256k1.Key.to_bytes context |> Bigstring.to_string |> B58.encode

  let to_b58_s pub = to_b58 pub |> B58.to_string

  let of_b58 b58 =
    B58.decode b58 |> Bigstring.of_string
    |> Secp256k1.Key.read_pk context
    |> Result.to_option

  let of_b58_s str = Option.bind (B58.of_string str) of_b58
  let equal = Secp256k1.Key.equal
  let pp fmt pub = Format.fprintf fmt "%s" (to_b58_s pub)
  let show = to_b58_s
end
