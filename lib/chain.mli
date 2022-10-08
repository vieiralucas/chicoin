type chain = private { genesis : Block.t; blocks : Block.t list }
and t = chain

val is_valid : chain -> bool
