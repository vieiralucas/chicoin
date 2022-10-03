(lang dune 2.9)
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
 (depends ocaml dune)
 (tags
  (blockchain cryptocurrency)))


