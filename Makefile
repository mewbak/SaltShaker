.PHONY: compare clean stoke rocksalt

compare: src/racket/* src/racket/x86sem.rkt stoke
	cp `opam config var coq:lib`/user-contrib/SpaceSearch/*.rkt src/racket/
	raco make src/racket/compare.rkt
	chmod +x src/racket/compare.rkt 

src/racket/x86sem.rkt: src/coq/*.v src/racket/header.rkt rocksalt
	cd src/coq; find . -name '*.v' -exec coq_makefile \
	                   -R . Main \
	                   -R ../../lib/CPUmodels/x86model/Model X86Model \
	                   -o Makefile {} +
	make -C src/coq
	cp src/racket/header.rkt src/racket/x86sem.rkt
	tail -n +4 src/coq/x86sem.scm >> src/racket/x86sem.rkt
	sed -i.bak "s/(define __ (lambda (_) __))/(define __ 'underscore)/g" src/racket/x86sem.rkt
	sed -i.bak 's/(error "AXIOM TO BE REALIZED")/void/g' src/racket/x86sem.rkt
	rm src/racket/x86sem.rkt.bak

stoke:
	cd lib/stoke && ./configure.sh && make

rocksalt:
	cd lib/CPUmodels/x86model/Model; make

clean:
	make -C src/coq clean || true
	rm -f src/coq/Makefile
	rm -f src/coq/x86sem.scm src/racket/x86sem.rkt
	rm -rf src/racket/compiled 

cleaner: clean
	make -C lib/stoke clean || true
	make -C lib/CPUmodels/x86model/Model clean
