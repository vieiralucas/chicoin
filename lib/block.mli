type block = { previous_hash : Sha256.t; nonce : int }
and t = block

val genesis : block
val hash : block -> Sha256.t
val equal : block -> block -> bool
val obeys_difficulty : int -> block -> bool
