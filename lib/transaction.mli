val mint_secret : Key.Secret.t
val mint_public : Key.Public.t

type transaction = {
  source : Key.Public.t;
  receiver : Key.Public.t;
  amount : int;
}

and t = transaction [@@deriving eq, show]

val to_bin : transaction -> Cstruct.t
val hash : transaction -> Hash.t

module Signed : sig
  type signed_transaction = {
    signature : Key.Signature.t;
    transaction : transaction;
  }

  and t = signed_transaction [@@deriving eq, show]

  val sign : transaction -> Key.Secret.t -> t option
  val hash : signed_transaction -> Hash.t
  val to_bin : signed_transaction -> Cstruct.t
end
