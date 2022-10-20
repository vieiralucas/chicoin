type chain = private {
  genesis : Block.t;
  blocks : Block.t list;
  transactions : Transaction.Signed.t list;
  difficulty : int;
  reward : int;
}

and t = chain

val create : ?difficulty:int -> ?reward:int -> unit -> chain
val balance : Key.Public.t -> chain -> int

type mine_error = Reward_transaction_sign_err

val mine : Key.Public.t -> chain -> (chain, mine_error) result

type add_transaction_error = Invalid_signature | Not_enought_funds

val add_transaction :
  Transaction.Signed.t -> chain -> (chain, add_transaction_error) result
