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
  dune
  ocamlformat
  (sha
   (>= 1.15))
  (alcotest
   (>= 1.6))
  (bisect_ppx
   (>= 2.8)))
 (tags
  (blockchain cryptocurrency)))
