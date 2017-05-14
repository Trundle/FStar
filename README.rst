=====================================================
F*: An ML-like language aimed at program verification
=====================================================

A JavaScript runtime for `F* code <https://www.fstar-lang.org/>`_. Takes the
generated OCaml code and translates it to JavaScript using `js_of_ocaml`_.

Installation
==============

Assumes that you have js_of_ocaml as well as all the F* dependencies (batteries
sqlite3 fileutils stdint zarith yojson pprint) installed.

Then::

  make -C src/ocaml-output -j 6

To translate and run the `example <https://github.com/Trundle/js_of_fstar/tree/js_of_ocaml/examples/hello_js>`_::

  make -C examples/hello_js


.. _js_of_ocaml: http://ocsigen.org/js_of_ocaml/
