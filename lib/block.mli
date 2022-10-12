type block = { previous_hash : string; nonce : int } [@@deriving eq]
and t = block

val genesis : block
val hash : block -> string
val obeys_difficulty : int -> block -> bool
