open Alcotest
open Camelochain
open Camelochain.Chain

let check_block = testable Block.pp_block Block.equal_block

let () =
  run "Chain"
    [
      ( "create",
        [
          ( "contains only genesis",
            `Quick,
            fun _ ->
              let empty = create () in
              (check int) "" 0 (List.length empty.blocks);
              (check int) "" 0 (List.length empty.transactions);
              (check check_block) "" Block.genesis empty.genesis );
          ( "accepts difficulty",
            `Quick,
            fun _ -> (check int) "" 2 (create ~difficulty:2 ()).difficulty );
          ( "defaults difficulty to 1",
            `Quick,
            fun _ -> (check int) "" 1 (create ()).difficulty );
          ( "accepts reward",
            `Quick,
            fun _ -> (check int) "" 2000 (create ~reward:2000 ()).reward );
          ( "defaults reward to 1000",
            `Quick,
            fun _ -> (check int) "" 1000 (create ()).reward );
        ] );
      ( "mine",
        [
          ( "rewards miner",
            `Quick,
            fun _ ->
              let empty = create () in
              let miner_sk = Key.Secret.generate () in
              let miner_pk = Key.Public.of_secret miner_sk in

              let chain = mine miner_pk empty |> Result.get_ok in

              (check int) "" 1000 (balance miner_pk chain) );
          ( "consumes transactions",
            `Quick,
            fun _ ->
              let empty = create () in
              let miner_sk = Key.Secret.generate () in
              let miner_pk = Key.Public.of_secret miner_sk in

              let receiver_1 = Key.Public.of_secret (Key.Secret.generate ()) in
              let receiver_2 = Key.Public.of_secret (Key.Secret.generate ()) in

              let chain = mine miner_pk empty |> Result.get_ok in

              let t1 =
                Transaction.Signed.sign
                  { source = miner_pk; receiver = receiver_1; amount = 10 }
                  miner_sk
                |> Option.get
              in
              let t2 =
                Transaction.Signed.sign
                  { source = miner_pk; receiver = receiver_2; amount = 20 }
                  miner_sk
                |> Option.get
              in
              let chain = add_transaction t1 chain |> Result.get_ok in
              let chain = add_transaction t2 chain |> Result.get_ok in
              let chain = mine miner_pk chain |> Result.get_ok in

              (check int) "" 0 (List.length chain.transactions);
              (check int) "" 10 (balance receiver_1 chain);
              (check int) "" 20 (balance receiver_2 chain);
              (check int) "" (chain.reward - 30 + 1000) (balance miner_pk chain)
          );
          ( "adds a new block",
            `Quick,
            fun _ ->
              let addr = Key.Public.of_secret (Key.Secret.generate ()) in
              let chain = mine addr (create ()) |> Result.get_ok in
              (check int) "" 1 (List.length chain.blocks) );
          ( "new block obeys difficulty",
            `Quick,
            fun _ ->
              let addr = Key.Public.of_secret (Key.Secret.generate ()) in
              let chain =
                mine addr (create ~difficulty:2 ()) |> Result.get_ok
              in
              let block = List.hd chain.blocks in
              (check bool) "" true (Block.obeys_difficulty 2 block) );
        ] );
    ]
