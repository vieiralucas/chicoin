type block = {
  previous_hash : Hash.t;
  transactions : Transaction.Signed.t list;
  nonce : int;
}

and t = block [@@deriving eq, show]

val genesis : block
val hash : block -> Hash.t
val obeys_difficulty : int -> block -> bool
