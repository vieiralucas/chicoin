val mint_secret : Key.Secret.t
val mint_public : Key.Public.t

type transaction = {
  source : Key.Public.t;
  receiver : Key.Public.t;
  amount : int;
}

type t = transaction

val to_bin : transaction -> Cstruct.t
