type block = {
  previous_hash : string;
  transactions : Transaction.t list;
  nonce : int;
}
[@@deriving eq]

and t = block

val genesis : block
val hash : block -> string
val obeys_difficulty : int -> block -> bool
