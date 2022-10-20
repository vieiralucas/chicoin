type block = {
  previous_hash : Hash.t;
  transactions : Transaction.Signed.t list;
  nonce : int;
}

and t = block [@@deriving eq, show]

let genesis = { previous_hash = Hash.empty; transactions = []; nonce = 0 }

let hash block =
  let b = Hash.show block.previous_hash |> Cstruct.string in
  let b =
    Cstruct.concat (List.map Transaction.Signed.to_bin block.transactions)
    |> Cstruct.append b
  in
  (* TODO: convert int to bin instead of int -> str -> bin *)
  let b = Cstruct.string (string_of_int block.nonce) |> Cstruct.append b in
  Hash.of_bin b

let obeys_difficulty difficulty block =
  let h = hash block in
  let prefix = String.make difficulty '0' in
  Hash.starts_with prefix h
