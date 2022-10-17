open Alcotest
open Camelochain

let b58_test_str = "4FsZFKpcvjEFhRc9bwFHw"
let check_b58 = testable B58.pp B58.equal

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
      ( "to_string",
        [
          ( "extracts the string",
            `Quick,
            fun _ ->
              (check string) "" b58_test_str
                (B58.B58 b58_test_str |> B58.to_string) );
        ] );
      ( "equal",
        [
          ( "is equal when inner string is equal",
            `Quick,
            fun _ -> (check check_b58) "" (B58.B58 "a") (B58.B58 "a") );
          ( "is not equal when inner string is not equal",
            `Quick,
            fun _ -> (check @@ neg @@ check_b58) "" (B58.B58 "a") (B58.B58 "b")
          );
        ] );
      ( "show",
        [
          ( "shows a B58",
            `Quick,
            fun _ ->
              (check string) "" "(B58.B58 \"4FsZFKpcvjEFhRc9bwFHw\")"
                (B58.B58 b58_test_str |> B58.show) );
        ] );
    ]
