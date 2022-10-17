open Alcotest
open Camelochain
open Camelochain.Block

let check_block = testable Block.pp_block Block.equal_block
let check_hash = testable Hash.pp_hash Hash.equal_hash

let genesis_hash =
  Hash.Hash "8b19385e5be86166f9b19c9aa29cd505a327c9d9dd4a11ac9a3e2183c3991c62"

let () =
  run "Block"
    [
      ( "equal",
        [
          ( "genesis is equal to genesis",
            `Quick,
            fun _ -> (check check_block) "" genesis genesis );
          ( "blocks with different nonce are not equal",
            `Quick,
            fun _ ->
              (check @@ neg @@ check_block)
                "" { genesis with nonce = 0 } { genesis with nonce = 1 } );
          ( "blocks with different transactions are not equal",
            `Quick,
            fun _ ->
              let secret = Key.Secret.generate () in
              let t1 : Transaction.Signed.t =
                Transaction.Signed.sign
                  {
                    source = Key.Public.of_secret secret;
                    receiver = Key.Public.of_secret secret;
                    amount = 1;
                  }
                  secret
                |> Option.get
              in
              let t2 : Transaction.Signed.t =
                Transaction.Signed.sign
                  {
                    source = Key.Public.of_secret secret;
                    receiver = Key.Public.of_secret secret;
                    amount = 2;
                  }
                  secret
                |> Option.get
              in
              (check @@ neg @@ check_block)
                ""
                { genesis with transactions = [] }
                { genesis with transactions = [ t1 ] };
              (check @@ neg @@ check_block)
                ""
                { genesis with transactions = [ t1 ] }
                { genesis with transactions = [ t2 ] } );
          ( "blocks with different nonce are not equal",
            `Quick,
            fun _ ->
              (check @@ neg @@ check_block)
                "" { genesis with nonce = 1 } { genesis with nonce = 2 } );
        ] );
      ( "show",
        [
          ( "has a show function",
            `Quick,
            fun _ ->
              let str =
                "{ Block.previous_hash =\n\
                \  (Hash.Hash\n\
                \     \
                 \"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\");\n\
                \  transactions = []; nonce = 0 }"
              in
              (check string) "" str (show genesis) );
        ] );
      ( "genesis",
        [
          ( "has a known hash",
            `Quick,
            fun _ -> (check check_hash) "" genesis_hash (hash genesis) );
        ] );
      ( "hash",
        [
          ( "depends on nonce",
            `Quick,
            fun _ ->
              let h1 =
                hash
                  { previous_hash = Hash.empty; transactions = []; nonce = 0 }
              in
              let h2 =
                hash
                  { previous_hash = Hash.empty; transactions = []; nonce = 1 }
              in
              (check @@ neg @@ check_hash) "" h1 h2 );
          ( "depends on previous_hash",
            `Quick,
            fun _ ->
              let h1 =
                hash { previous_hash = Hash "h1"; transactions = []; nonce = 0 }
              in
              let h2 =
                hash { previous_hash = Hash "h2"; transactions = []; nonce = 0 }
              in
              (check @@ neg @@ check_hash) "" h1 h2 );
          ( "depends on transactions",
            `Quick,
            fun _ ->
              let b1 =
                { previous_hash = Hash.empty; transactions = []; nonce = 0 }
              in
              let h1 = hash b1 in

              let secret = Key.Secret.generate () in
              let source = Key.Public.of_secret secret in
              let receiver = Key.Public.of_secret secret in
              let transaction : Transaction.Signed.t =
                Transaction.Signed.sign { source; receiver; amount = 1 } secret
                |> Option.get
              in
              let b2 =
                {
                  previous_hash = Hash.empty;
                  transactions = [ transaction ];
                  nonce = 0;
                }
              in
              let h2 = hash b2 in

              (check @@ neg @@ check_hash) "" h1 h2 );
        ] );
      ( "obeys_difficulty",
        [
          ( "returns true when hash starts with right amount of zeros",
            `Quick,
            fun _ ->
              let b1 =
                { previous_hash = genesis_hash; transactions = []; nonce = 15 }
              in
              (check bool) "" true (obeys_difficulty 1 b1);

              let b2 =
                { previous_hash = genesis_hash; transactions = []; nonce = 50 }
              in
              (check bool) "" true (obeys_difficulty 2 b2) );
          ( "returns false when hash does not start with the right amount of \
             zeros",
            `Quick,
            fun _ ->
              let b =
                { previous_hash = genesis_hash; transactions = []; nonce = 0 }
              in
              (check bool) "" false (obeys_difficulty 1 b) );
        ] );
    ]
