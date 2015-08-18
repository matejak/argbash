NUL =
M4_SRC = \
	../src/output.m4 \
	../src/output-standalone.m4 \
	../src/stuff.m4 \
	$(NUL)

PREFIX = $(HOME)/.local

GENPARSE = ../bin/argbash.sh
EXAMPLES = \
	examples/simple.sh \
	examples/simple-standalone.sh \
	$(NUL)

%-standalone.sh: %-standalone.m4s $(GENPARSE)
	$(GENPARSE) $< -o $@ --standalone

%-standalone2.sh: %-standalone.sh $(GENPARSE)
	$(GENPARSE) $< -o $@ --standalone

%.sh: %.m4s $(GENPARSE)
	$(GENPARSE) $< -o $@

%2.sh: %.sh $(GENPARSE)
	$(GENPARSE) $< -o $@

%3.sh: %2.sh $(GENPARSE)
	$(GENPARSE) $< -o $@

$(GENPARSE): bin/argbash.m4s $(M4_SRC)
	bash $(GENPARSE) $< -o argbash.temp
	mv argbash.temp $@

bootstrap:
	cat ../src/stuff.m4 ../src/output.m4 bin/argbash.m4s | autom4te -l m4sugar > $(GENPARSE)
	chmod a+x $(GENPARSE)

examples: $(EXAMPLES)

check: unittests regressiontests

unittests:
	autom4te -l m4sugar -I ../src/ ../tests/unittests/list.m4

regressiontests: ../tests/regressiontests/test.sh ../tests/regressiontests/test2.sh
	cd ../tests/regressiontests && make check

develop:
	@echo Installing to prefix "'$(PREFIX)'"
	mkdir -p "$(PREFIX)/bin"
	touch "$(PREFIX)/bin/argbash" && rm "$(PREFIX)/bin/argbash"
	ln -s $(PWD)/$(GENPARSE) "$(PREFIX)/bin/argbash"

install: $(GENPARSE)
	@echo Installing to prefix "'$(PREFIX)'"
	mkdir -p "$(PREFIX)/bin"
	touch "$(PREFIX)/bin/argbash"
	mkdir -p "$(PREFIX)/lib/argbash"
	touch "$(PREFIX)/lib/argbash/stuff.m4"
	cp $(M4_SRC) "$(PREFIX)/lib/argbash/"
	sed -e 's|M4DIR=.*|M4DIR=$(PREFIX)/lib/argbash|' $(GENPARSE) > "$(PREFIX)/bin/argbash"
	chmod a+x "$(PREFIX)/bin/argbash"

uninstall:
	rm "$(PREFIX)/bin/argbash"
	rm "$(PREFIX)/lib/argbash/"*.m4
	rmdir "$(PREFIX)/lib/argbash"
