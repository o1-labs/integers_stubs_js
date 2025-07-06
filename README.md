js\_of\_ocaml stubs for the OCaml
[integers](https://github.com/ocamllabs/ocaml-integers) library. Install via

```bash
opam install integers_stubs_js
```

## Setup development environment

```shell
opam switch create ./ 4.14.2 --no-install
opam install merlin ocamlformat
```

## Build and run tests

```
opam install . --with-test --deps-only
dune build
dune runtest
dune fmt --auto-promote # to format the code
```
