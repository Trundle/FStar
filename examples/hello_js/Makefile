# For simplified Makefiles, define FSTAR_HOME, then include the file below.
FSTAR_HOME=../..
include ../Makefile.include

all: hello.uver

include $(FSTAR_HOME)/ulib/ml/Makefile.include

# This target is very concise and re-uses the variables defined in
# Makefile.include. You shouldn't need to call `cp` ever.
ocaml: out hello.fst
	$(MAKE) -C $(ULIB_ML)
	ocamlfind c -package js_of_ocaml -g -linkpkg -c v8.mli
	ocamlfind c -package js_of_ocaml -g -linkpkg -c v8.ml
	$(FSTAR) $(FSTAR_DEFAULT_ARGS) --odir out --codegen-lib V8 --codegen OCaml hello.fst
	$(OCAMLC) v8.cmo out/Hello.ml -o hello.byte
	js_of_ocaml +nat.js hello.byte
	node ./hello.js

LIB=../../ulib
BIN=../../bin
FSTAR=../../bin/fstar.exe

ifeq ($(OS),Windows_NT)
FSC     = fsc --mlcompatibility $(addprefix -r , $(FS_LIBS))
else
FSC     = fsharpc --mlcompatibility $(addprefix -r , $(FS_LIBS))
endif

out:
	mkdir -p out

clean:
	make -C $(ULIB_ML) clean
	rm -rf out
	rm -f *~ *.cmo *.cmi
