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
  (ppx_inline_test
   (>= 0.15)))
 (tags
  (blockchain cryptocurrency)))
