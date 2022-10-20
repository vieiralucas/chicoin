module Secret : sig
  type secret = private Secp256k1.Key.secret Secp256k1.Key.t
  type t = secret [@@deriving eq, show]

  val generate : unit -> secret
  val to_b58 : secret -> B58.t
  val to_b58_s : secret -> string
  val of_b58 : B58.t -> secret
  val of_b58_s : string -> secret option
end

module Public : sig
  type pub = private Secp256k1.Key.public Secp256k1.Key.t
  type t = pub [@@deriving eq, show]

  val of_secret : Secret.t -> pub
  val to_b58 : pub -> B58.t
  val to_b58_s : pub -> string
  val of_b58 : B58.t -> pub
  val of_b58_s : string -> pub option
end

module Signature : sig
  type signature = Secp256k1.Sign.plain Secp256k1.Sign.t
  and t = signature [@@deriving eq, show]

  val to_b58 : signature -> B58.t
  val sign : Secret.t -> Hash.t -> signature option
  val verify : Public.t -> signature -> Hash.t -> bool
end
