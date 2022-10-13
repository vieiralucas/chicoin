module Secret : sig
  type secret = Secp256k1.Key.secret Secp256k1.Key.t
  type t = secret

  val generate : secret
  val to_b58 : secret -> string
  val of_b58 : string -> secret option
end

module Key : sig
  type key = Secp256k1.Key.public Secp256k1.Key.t
  type t = key

  val of_secret : Secret.t -> key
end

val mint_secret : Secret.t

type transaction = unit
