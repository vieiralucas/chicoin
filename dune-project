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
  (ppx_deriving
   (>= 5.2))
  (ppx_import
   (>= 1.10))
  (alcotest
   (>= 1.6)))
 (tags
  (blockchain cryptocurrency)))
