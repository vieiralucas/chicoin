module Transaction : sig
  type transaction = {
    source : Key.Public.t;
    receiver : Key.Public.t;
    amount : int;
  }

  and t = transaction [@@deriving eq, show]

  val to_bin : transaction -> Cstruct.t
  val hash : transaction -> Hash.t
end

module Signed : sig
  type signed_transaction = private {
    signature : Key.Signature.t;
    transaction : Transaction.t;
  }

  and t = signed_transaction [@@deriving eq, show]

  val sign : Transaction.t -> Key.Secret.t -> t option
  val hash : signed_transaction -> Hash.t
  val to_bin : signed_transaction -> Cstruct.t
  val verify : signed_transaction -> bool
  val mint : Key.Public.t -> int -> signed_transaction option
end
