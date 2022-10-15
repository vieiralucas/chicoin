open Alcotest
open Camelochain
open Camelochain.Block

let () =
  run "Block"
    [
      ( "equal",
        [
          ( "genesis is equal to genesis",
            `Quick,
            fun _ -> (check bool) "" true (genesis = genesis) );
          ( "blocks with different nonce are not equal",
            `Quick,
            fun _ ->
              (check bool) "" true
                ({ genesis with nonce = 0 } <> { genesis with nonce = 1 }) );
          ( "blocks with different transactions are not equal",
            `Quick,
            fun _ ->
              let t1 : Transaction.t =
                {
                  source = Key.Public.of_secret Key.Secret.generate;
                  receiver = Key.Public.of_secret Key.Secret.generate;
                  amount = 1;
                }
              in
              let t2 : Transaction.t =
                {
                  source = Key.Public.of_secret Key.Secret.generate;
                  receiver = Key.Public.of_secret Key.Secret.generate;
                  amount = 2;
                }
              in
              (check bool) "" true
                ({ genesis with transactions = [] }
                <> { genesis with transactions = [ t1 ] });
              (check bool) "" true
                ({ genesis with transactions = [ t1 ] }
                <> { genesis with transactions = [ t2 ] }) );
        ] );
      ( "genesis",
        [
          ( "has a known hash",
            `Quick,
            fun _ ->
              (check string) ""
                "8cb68fe2a0d5762d32bc532e1c224d68cb9f1f93e63f3e1cef15548b8ff8e895"
                (hash genesis) );
        ] );
      ( "hash",
        [
          ( "depends on nonce",
            `Quick,
            fun _ ->
              let h1 =
                hash { previous_hash = ""; transactions = []; nonce = 0 }
              in
              let h2 =
                hash { previous_hash = ""; transactions = []; nonce = 1 }
              in
              (check @@ neg @@ string) "" h1 h2 );
          ( "depends on previous_hash",
            `Quick,
            fun _ ->
              let h1 =
                hash { previous_hash = "h1"; transactions = []; nonce = 0 }
              in
              let h2 =
                hash { previous_hash = "h2"; transactions = []; nonce = 0 }
              in
              (check @@ neg @@ string) "" h1 h2 );
          ( "depends on transactions",
            `Quick,
            fun _ ->
              let b1 = { previous_hash = ""; transactions = []; nonce = 0 } in
              let h1 = hash b1 in

              let source = Key.Secret.generate |> Key.Public.of_secret in
              let receiver = Key.Secret.generate |> Key.Public.of_secret in
              let transaction : Transaction.t =
                { source; receiver; amount = 1 }
              in
              let b2 =
                {
                  previous_hash = "";
                  transactions = [ transaction ];
                  nonce = 0;
                }
              in
              let h2 = hash b2 in

              (check @@ neg @@ string) "" h1 h2 );
        ] );
      ( "obeys_difficulty",
        [
          ( "returns true when hash starts with right amount of zeros",
            `Quick,
            fun _ ->
              let h =
                "8cb68fe2a0d5762d32bc532e1c224d68cb9f1f93e63f3e1cef15548b8ff8e895"
              in

              let b1 = { previous_hash = h; transactions = []; nonce = 10 } in
              (check bool) "" true (obeys_difficulty 1 b1);

              let b2 = { previous_hash = h; transactions = []; nonce = 1187 } in
              (check bool) "" true (obeys_difficulty 2 b2) );
          ( "returns false when hash does not start with the right amount of \
             zeros",
            `Quick,
            fun _ ->
              let h =
                "8cb68fe2a0d5762d32bc532e1c224d68cb9f1f93e63f3e1cef15548b8ff8e895"
              in
              let b = { previous_hash = h; transactions = []; nonce = 0 } in
              (check bool) "" false (obeys_difficulty 1 b) );
        ] );
    ]
