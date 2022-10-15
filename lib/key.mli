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
  type pub = Secp256k1.Key.public Secp256k1.Key.t
  type t = pub

  val of_secret : Secret.t -> pub
  val to_b58 : pub -> B58.t
  val to_b58_s : pub -> string
  val of_b58 : B58.t -> pub option
  val of_b58_s : string -> pub option
end
