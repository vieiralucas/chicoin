open Alcotest
open Camelochain
open Camelochain.Chain

let () =
  run "Chain"
    [
      ( "empty",
        [
          ( "contains only genesis",
            `Quick,
            fun _ ->
              (check int) "" 0 (List.length empty.blocks);
              (check int) "" 0 (List.length empty.transactions);
              (check bool) "" true (Block.genesis = empty.genesis) );
          ( "has difficulty 1",
            `Quick,
            fun _ -> (check int) "" 1 empty.difficulty );
        ] );
      ( "add_block",
        [
          ( "adds block to end of chain",
            `Quick,
            fun _ ->
              let block : Block.t =
                {
                  previous_hash = Block.hash Block.genesis;
                  transactions = [];
                  nonce = 0;
                }
              in
              let chain = add_block block empty in

              (check int) "" 1 (List.length chain.blocks);
              (check bool) "" true (block = last_block chain) );
          ( "remove block transactions from chain transactions",
            `Quick,
            fun _ ->
              let source = Key.Public.of_secret Key.Secret.generate in
              let receiver = Key.Public.of_secret Key.Secret.generate in
              let t1 : Transaction.t = { source; receiver; amount = 10 } in
              let t2 : Transaction.t = { source; receiver; amount = 20 } in
              let block : Block.t =
                {
                  previous_hash = Block.hash Block.genesis;
                  transactions = [ t1 ];
                  nonce = 0;
                }
              in
              let chain =
                empty |> add_transaction t1 |> add_transaction t2
                |> add_block block
              in

              (check int) "" 1 (List.length chain.transactions);
              (check bool) "" true (t2 = List.hd chain.transactions) );
          ( "chain remains valid",
            `Quick,
            fun _ ->
              let chain = empty in
              (check bool) "" true (is_valid chain);
              let block : Block.t =
                {
                  previous_hash = Block.hash Block.genesis;
                  transactions = [];
                  nonce = 0;
                }
              in
              let chain = add_block block chain in
              (check bool) "" true (is_valid chain) );
        ] );
      ( "last_block",
        [
          ( "returns genesis for empty chain",
            `Quick,
            fun _ -> (check bool) "" true (Block.genesis = last_block empty) );
          ( "returns last block of the chain",
            `Quick,
            fun _ ->
              let block : Block.t =
                {
                  previous_hash = Block.hash Block.genesis;
                  transactions = [];
                  nonce = 0;
                }
              in
              let chain = add_block block empty in
              (check bool) "" true (block = last_block chain) );
        ] );
      ( "is_valid",
        [
          ( "returns true when empty",
            `Quick,
            fun _ -> (check bool) "" true (is_valid empty) );
          ( "returns true when last block points to genesis",
            `Quick,
            fun _ ->
              let chain : Chain.t =
                {
                  genesis = Block.genesis;
                  blocks =
                    [
                      {
                        previous_hash = Block.hash Block.genesis;
                        transactions = [];
                        nonce = 0;
                      };
                    ];
                  transactions = [];
                  difficulty = 0;
                }
              in
              (check bool) "" true (is_valid chain) );
          ( "returns true when all blocks point to previous",
            `Quick,
            fun _ ->
              let b1 : Block.t =
                {
                  previous_hash = Block.hash Block.genesis;
                  transactions = [];
                  nonce = 0;
                }
              in
              let b2 : Block.t =
                { previous_hash = Block.hash b1; transactions = []; nonce = 0 }
              in
              let b3 : Block.t =
                { previous_hash = Block.hash b2; transactions = []; nonce = 0 }
              in
              (check bool) "" true
                (is_valid
                   {
                     genesis = Block.genesis;
                     blocks = [ b3; b2; b1 ];
                     transactions = [];
                     difficulty = 0;
                   }) );
          ( "returns false when content of a block changes",
            `Quick,
            fun _ ->
              let b1 : Block.t =
                {
                  previous_hash = Block.hash Block.genesis;
                  transactions = [];
                  nonce = 0;
                }
              in
              let b2 : Block.t =
                { previous_hash = Block.hash b1; transactions = []; nonce = 0 }
              in
              let b3 : Block.t =
                { previous_hash = Block.hash b2; transactions = []; nonce = 0 }
              in
              let b2 = { b2 with nonce = 1 } in
              let chain =
                {
                  genesis = Block.genesis;
                  blocks = [ b3; b2; b1 ];
                  transactions = [];
                  difficulty = 0;
                }
              in
              (check bool) "" false (is_valid chain) );
        ] );
      ( "mine",
        [
          ( "adds a new block to the end of the chain",
            `Quick,
            fun _ ->
              let chain = mine empty in
              (check int) "" 1 (List.length chain.blocks) );
          ( "new block obeys difficulty",
            `Quick,
            fun _ ->
              let chain = mine { empty with difficulty = 2 } in
              let block = last_block chain in
              (check bool) "" true (Block.obeys_difficulty 2 block) );
          ( "new chain is valid",
            `Quick,
            fun _ ->
              let chain = mine empty in
              (check bool) "" true (is_valid chain) );
        ] );
    ]
