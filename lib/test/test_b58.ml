open Alcotest
open Camelochain

let b58_test_str = "4FsZFKpcvjEFhRc9bwFHw"
let check_b58 = testable B58.pp B58.equal

let qcheck_suite =
  List.map QCheck_alcotest.to_alcotest
    [
      QCheck.Test.make ~name:"encode |> decode gives back original string"
        QCheck.(string)
        (fun s -> B58.encode s |> B58.decode = s);
    ]

let () =
  run "B58"
    [
      ("QCheck", qcheck_suite);
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
              (check string) "" "testing b58"
                (B58.decode (B58.of_string b58_test_str |> Option.get)) );
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
                (B58.of_string b58_test_str |> Option.get |> B58.to_string) );
        ] );
      ( "equal",
        [
          ( "is equal when inner string is equal",
            `Quick,
            fun _ -> (check check_b58) "" (B58.encode "a") (B58.encode "a") );
          ( "is not equal when inner string is not equal",
            `Quick,
            fun _ ->
              (check @@ neg @@ check_b58) "" (B58.encode "a") (B58.encode "b")
          );
        ] );
      ( "show",
        [
          ( "shows a B58",
            `Quick,
            fun _ ->
              (check string) ""
                (Format.sprintf "(B58.B58 \"%s\")" "4FsZFKpcvjEFhRc9bwFHw")
                (B58.of_string b58_test_str |> Option.get |> B58.show) );
        ] );
    ]
