type chain = private {
  genesis : Block.t;
  blocks : Block.t list;
  difficulty : int;
}

and t = chain

val is_valid : chain -> bool
val mine : chain -> chain
