(lang dune 3.0)
(name integers_stubs_js)

(generate_opam_files true)

(source (github o1-labs/integers_stubs_js))
(license MIT)
(authors "O(1) Labs, LLC <opensource@o1labs.org>")
(maintainers "O(1) Labs, LLC <opensource@o1labs.org>")
(bug_reports "https://github.com/o1-labs/integers_stubs_js/issues")
(homepage "https://github.com/o1-labs/integers_stubs_js/")

(package
 (name integers_stubs_js)
 (synopsis "Javascript stubs for the integers library in js_of_ocaml")
 (description "Javascript stubs for the integers library in js_of_ocaml")
 (depends
  dune
  (ocaml (and (>= 4.14) (<= 5.3)))
  zarith_stubs_js
  (integers (and :with-test (>= 0.6.0)))
))

