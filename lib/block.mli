type block = { previous_hash : Sha256.t; nonce : int }
and t = block

val hash : block -> Sha256.t
val genesis : block
