open Alcotest
open Camelochain

let b58_test_str = "4FsZFKpcvjEFhRc9bwFHw"

let () =
  run "B58"
    [
      ( "encode",
        [
          ( "encode",
            `Quick,
            fun _ ->
              (check string) "" b58_test_str
                (B58.encode "testing b58" |> B58.to_string) );
        ] );
      ( "decode",
        [
          ( "decode",
            `Quick,
            fun _ ->
              (check string) "" "testing b58" (B58.decode (B58 b58_test_str)) );
        ] );
      ( "of_string",
        [
          ( "some when valid b58",
            `Quick,
            fun _ ->
              (check bool) "" true (B58.of_string b58_test_str |> Option.is_some)
          );
          ( "none when invalid b58",
            `Quick,
            fun _ ->
              (check bool) "" true (B58.of_string "1234" |> Option.is_none) );
        ] );
      ( "show",
        [
          ( "extracts the string",
            `Quick,
            fun _ ->
              (check string) "" b58_test_str
                (B58.B58 b58_test_str |> B58.to_string) );
        ] );
    ]
