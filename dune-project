(lang dune 3.4)

(name camelochain)

(generate_opam_files true)

(source
 (github vieiralucas/camelochain))

(authors "Lucas Vieira")

(maintainers "Lucas Vieira")

(license "MIT")

(package
 (name camelochain)
 (synopsis "Camel chaining")
 (description "A blockchain written in OCaml")
 (depends
  (alcotest
   (>= 1.6))
  (bigstring
   (>= 0.3))
  (bisect_ppx
   (>= 2.8))
  (cstruct
   (>= 6.0))
  (hex
   (>= 1.5))
  (mirage-crypto
   (>= 0.10))
  (mirage-crypto-rng
   (>= 0.10))
  (secp256k1
   (>= 0.4))
  (tezos-base58
   (>= 1.0))
  (ppx_deriving
   (>= 5.2))
  (qcheck-alcotest
   (>= 0.19))
  dune
  ocamlformat)
 (tags
  (blockchain cryptocurrency)))
