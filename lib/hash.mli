type hash = Hash of string [@@deriving eq, show]
and t = hash

val empty : hash
val of_bin : Cstruct.t -> hash
val to_string : hash -> string
val starts_with : string -> hash -> bool
