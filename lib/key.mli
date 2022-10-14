module Secret : sig
  type secret = Secp256k1.Key.secret Secp256k1.Key.t
  type t = secret

  val generate : secret
  val to_b58 : secret -> B58.t
  val to_b58_s : secret -> string
  val of_b58 : B58.t -> secret option
  val of_b58_s : string -> secret option
end

module Public : sig
  type key = Secp256k1.Key.public Secp256k1.Key.t
  type t = key

  val of_secret : Secret.t -> key
end
