type b58 = B58 of string
type t = b58 [@@deriving eq]

val encode : string -> b58
val decode : b58 -> string
val of_string : string -> b58 option
val to_string : b58 -> string
