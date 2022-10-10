open Alcotest
open Camelochain.Block

let () =
  run "Block"
    [
      ( "genesis",
        [
          ( "has a known hash",
            `Quick,
            fun _ ->
              (check string) ""
                "8cb68fe2a0d5762d32bc532e1c224d68cb9f1f93e63f3e1cef15548b8ff8e895"
                (hash genesis |> Sha256.to_hex) );
        ] );
      ( "hash",
        [
          ( "depends on nonce",
            `Quick,
            fun _ ->
              let h1 = hash { previous_hash = Sha256.zero; nonce = 0 } in
              let h2 = hash { previous_hash = Sha256.zero; nonce = 1 } in
              (check @@ neg @@ string) "" (Sha256.to_hex h1) (Sha256.to_hex h2)
          );
          ( "depends on previous_hash",
            `Quick,
            fun _ ->
              let h1 = hash { previous_hash = Sha256.string "h1"; nonce = 0 } in
              let h2 = hash { previous_hash = Sha256.string "h2"; nonce = 0 } in
              (check @@ neg @@ string) "" (Sha256.to_hex h1) (Sha256.to_hex h2)
          );
        ] );
      ( "obeys_difficulty",
        [
          ( "returns true when hash starts with right amount of zeros",
            `Quick,
            fun _ ->
              let h =
                "8cb68fe2a0d5762d32bc532e1c224d68cb9f1f93e63f3e1cef15548b8ff8e895"
              in

              let b1 = { previous_hash = Sha256.of_hex h; nonce = 10 } in
              (check bool) "" true (obeys_difficulty 1 b1);

              let b2 = { previous_hash = Sha256.of_hex h; nonce = 1187 } in
              (check bool) "" true (obeys_difficulty 2 b2) );
          ( "returns false when hash does not start with the right amount of \
             zeros",
            `Quick,
            fun _ ->
              let h =
                "8cb68fe2a0d5762d32bc532e1c224d68cb9f1f93e63f3e1cef15548b8ff8e895"
              in
              let b = { previous_hash = Sha256.of_hex h; nonce = 0 } in
              (check bool) "" false (obeys_difficulty 1 b) );
        ] );
    ]
