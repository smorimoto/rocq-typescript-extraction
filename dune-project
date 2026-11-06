(lang dune 3.24)

(using rocq 0.14)

(cram enable)

(name rocq-typescript-extraction)

(generate_opam_files true)

(source
 (github smorimoto/rocq-typescript-extraction))

(license ISC)

(authors "Sora Morimoto <sora@morimoto.io>")

(maintainers "Sora Morimoto <sora@morimoto.io>")

(package
 (name rocq-typescript-extraction)
 (synopsis "Extraction of Rocq code to TypeScript")
 (description
  "A Rocq plugin that extracts Rocq definitions to TypeScript, implemented as a new backend over the MiniML intermediate language of the standard extraction plugin.")
 (depends
  (ocaml
   (>= 5.1))
  (base
   (>= v0.17))
  (stdio
   (>= v0.17))
  (ppx_jane
   (>= v0.17))
  (base_quickcheck
   (and
    :with-test
    (>= v0.17)))
  (ppx_js_style
   (>= v0.17))
  (ppx_expect
   (and
    :with-test
    (>= v0.17)))
  zarith
  (rocq-runtime
   (>= 9.3))
  (rocq-core
   (>= 9.3))
  (rocq-stdlib
   (and
    :with-test
    (>= 9.2)))
  (ocamlformat
   (and
    :with-dev-setup
    (= 0.29.0)))
  (ocaml-lsp-server :with-dev-setup)
  (ocaml-index :with-dev-setup)))
