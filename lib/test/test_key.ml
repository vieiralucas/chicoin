open Alcotest
open Camelochain
open Camelochain.Key

let check_b58 = testable B58.pp B58.equal
let b58_secret_str = "2r8ZDcw8CtkCfVR2r95cQzAZJAVgWeVyUqoZeGffEavWveQzyw"
let b58_secret = B58.of_string b58_secret_str |> Option.get
let secret = Secret.of_b58 b58_secret
let check_secret = testable Secret.pp Secret.equal

let secret_qcheck_suite =
  List.map QCheck_alcotest.to_alcotest
    [
      QCheck.Test.make ~count:10000
        ~name:"all B58 are valid secrets, of_b58 never throws exception"
        QCheck.(string)
        (fun s ->
          B58.of_string s
          |> Option.map (fun b58 ->
                 let _ = Secret.of_b58 b58 in
                 true)
          |> Option.value ~default:true);
    ]

let secret_suite =
  [
    ("Secret.QCheck", secret_qcheck_suite);
    ( "Secret.generate",
      [
        ( "generates random Secret",
          `Quick,
          fun _ ->
            let s1 = Secret.generate () in
            let s2 = Secret.generate () in
            (check @@ neg @@ check_secret) "" s1 s2 );
      ] );
    ( "Secret.to_b58",
      [
        ( "converts secret to b58",
          `Quick,
          fun _ -> (check check_b58) "" b58_secret (Secret.to_b58 secret) );
      ] );
    ( "Secret.to_b58_s",
      [
        ( "converts secret to a b58 string",
          `Quick,
          fun _ -> (check string) "" b58_secret_str (Secret.to_b58_s secret) );
      ] );
    ( "Secret.of_b58",
      [
        ( "makes a secret from a b58",
          `Quick,
          fun _ -> (check check_secret) "" secret (Secret.of_b58 b58_secret) );
      ] );
    ( "Secret.of_b58_s",
      [
        ( "makes a secret from a b58 string",
          `Quick,
          fun _ ->
            (check check_secret) "" secret
              (Secret.of_b58_s b58_secret_str |> Option.get) );
        ( "returns none if str is not a valid b58",
          `Quick,
          fun _ ->
            (check bool) "" true (Secret.of_b58_s "!@#$" |> Option.is_none) );
        ( "returns none if b58 str is not a valid secret",
          `Quick,
          fun _ ->
            (check bool) "" true (Secret.of_b58_s "abcde" |> Option.is_none) );
      ] );
    ( "Secret.show",
      [
        ( "shows a Secret",
          `Quick,
          fun _ ->
            (check string) ""
              "2r8ZDcw8CtkCfVR2r95cQzAZJAVgWeVyUqoZeGffEavWveQzyw"
              (Secret.show secret) );
      ] );
    ( "Secret.equal",
      [
        ( "same secret is equal",
          `Quick,
          fun _ -> (check check_secret) "" secret secret );
        ( "different secret is not equal",
          `Quick,
          fun _ ->
            (check @@ neg @@ check_secret)
              "" (Secret.generate ()) (Secret.generate ()) );
      ] );
    ( "Secret.pp",
      [
        ( "delegates to B58",
          `Quick,
          fun _ ->
            let buffer = Buffer.create 0 in
            let formatter = Format.formatter_of_buffer buffer in
            Secret.pp formatter secret;
            Format.pp_print_flush formatter ();
            let str = Buffer.to_bytes buffer |> String.of_bytes in
            (check string) ""
              (Printf.sprintf "(B58.B58 \"%s\")" b58_secret_str)
              str );
      ] );
  ]

let b58_public_str = "5ckKEzgDBAq2y6TaggQowQLjmjsnzwX4dxHYZg1SjhkxkMFFuD"
let b58_public = B58.of_string b58_public_str |> Option.get
let public = Public.of_b58 b58_public
let check_public = testable Public.pp Public.equal

let public_qcheck_suite =
  List.map QCheck_alcotest.to_alcotest
    [
      QCheck.Test.make ~count:10000
        ~name:"all B58 are valid publics, of_b58 never throws exception"
        QCheck.(string)
        (fun s ->
          B58.of_string s
          |> Option.map (fun b58 ->
                 let _ = Public.of_b58 b58 in
                 true)
          |> Option.value ~default:true);
    ]

let public_suite =
  [
    ("Public.QCheck", public_qcheck_suite);
    ( "Public.to_b58",
      [
        ( "converts public to b58",
          `Quick,
          fun _ -> (check check_b58) "" b58_public (Public.to_b58 public) );
      ] );
    ( "Public.to_b58_s",
      [
        ( "converts public to a b58 string",
          `Quick,
          fun _ -> (check string) "" b58_public_str (Public.to_b58_s public) );
      ] );
    ( "Public.of_b58",
      [
        ( "makes a public from a b58",
          `Quick,
          fun _ -> (check check_public) "" public (Public.of_b58 b58_public) );
      ] );
    ( "Public.of_b58_s",
      [
        ( "makes a public from a b58 string",
          `Quick,
          fun _ ->
            (check check_public) "" public
              (Public.of_b58_s b58_public_str |> Option.get) );
        ( "returns none if str is not a valid b58",
          `Quick,
          fun _ ->
            (check bool) "" true (Public.of_b58_s "!@#$" |> Option.is_none) );
        ( "returns none if b58 str is not a valid public",
          `Quick,
          fun _ ->
            (check bool) "" true (Public.of_b58_s "abcde" |> Option.is_none) );
      ] );
    ( "Public.show",
      [
        ( "shows a Public",
          `Quick,
          fun _ -> (check string) "" b58_public_str (Public.show public) );
      ] );
    ( "Public.equal",
      [
        ( "same public is equal",
          `Quick,
          fun _ -> (check check_public) "" public public );
        ( "different public is not equal",
          `Quick,
          fun _ ->
            (check @@ neg @@ check_public)
              ""
              (Secret.generate () |> Public.of_secret)
              (Secret.generate () |> Public.of_secret) );
      ] );
    ( "Public.pp",
      [
        ( "delegates to B58",
          `Quick,
          fun _ ->
            let buffer = Buffer.create 0 in
            let formatter = Format.formatter_of_buffer buffer in
            Public.pp formatter public;
            Format.pp_print_flush formatter ();
            let str = Buffer.to_bytes buffer |> String.of_bytes in
            (check string) ""
              (Printf.sprintf "(B58.B58 \"%s\")" b58_public_str)
              str );
      ] );
  ]

let signature =
  Signature.sign secret (Hash.of_bin (Cstruct.string "some content"))
  |> Option.get

let b58_signature =
  B58.of_string
    "Ea8ZnnAxcy6FpTsTs8WHtJ1pi1GQqGyNoXMe9BLB1o4o4UfCWGGw9ySAt2tT4ymA4x7vpQpv7aucbwRobdYM9RGG3E4Kh"
  |> Option.get

let check_signature = testable Signature.pp Signature.equal

let signature_qcheck_suite =
  List.map QCheck_alcotest.to_alcotest
    [
      QCheck.Test.make ~count:10000
        ~name:"verify a signature using pk from sk always returns true"
        QCheck.string (fun s ->
          let sk = Key.Secret.generate () in
          let pk = Key.Public.of_secret sk in
          let hash = Cstruct.string s |> Hash.of_bin in
          let signature = Signature.sign sk hash |> Option.get in
          Signature.verify pk signature hash);
    ]

let signature_suite =
  [
    ("Signature.QCheck", signature_qcheck_suite);
    ( "Signature.to_b58",
      [
        ( "encodes signature in B58",
          `Quick,
          fun _ ->
            (check check_b58) "" b58_signature (Signature.to_b58 signature) );
      ] );
    ( "Signature.verify",
      [
        ( "returns true when used right public pair",
          `Quick,
          fun _ ->
            let sk = Key.Secret.generate () in
            let pk = Key.Public.of_secret sk in
            let hash = Hash.of_bin (Cstruct.string "content to verify") in
            let sign = Signature.sign sk hash |> Option.get in
            (check bool) "" true (Signature.verify pk sign hash) );
      ] );
    ( "Signature.equal",
      [
        ( "same signature is equal",
          `Quick,
          fun _ -> (check check_signature) "" signature signature );
        ( "different signatures are not equal",
          `Quick,
          fun _ ->
            let s1 =
              Signature.sign secret (Hash.of_bin (Cstruct.string "s1"))
              |> Option.get
            in
            let s2 =
              Signature.sign secret (Hash.of_bin (Cstruct.string "s2"))
              |> Option.get
            in
            (check @@ neg @@ check_signature) "" s1 s2 );
      ] );
  ]

let suite = List.concat [ secret_suite; public_suite; signature_suite ]
let () = run "Key" suite
