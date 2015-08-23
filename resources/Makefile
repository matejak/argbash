NUL =

M4_SRC = \
	../src/output.m4 \
	../src/output-standalone.m4 \
	../src/stuff.m4 \
	../src/version \
	$(NUL)

PREFIX = $(HOME)/.local
ROOT = /

GENPARSE = ../bin/argbash.sh
EXAMPLES = \
	examples/simple.sh \
	examples/simple-standalone.sh \
	$(NUL)

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

$(GENPARSE): bin/argbash.m4s $(M4_SRC)
	bash $(GENPARSE) $< -o argbash.temp; mv argbash.temp $@

TESTDIR = ../tests/regressiontests
include ../tests/regressiontests/Makefile

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

bootstrap:
	cat ../src/stuff.m4 ../src/output.m4 bin/argbash.m4s | autom4te -l m4sugar > $(GENPARSE)
	chmod a+x $(GENPARSE)
	touch bin/argbash.m4s

examples: $(EXAMPLES)

check: unittests regressiontests

unittests:
	autom4te -l m4sugar -I ../src/ ../tests/unittests/list.m4

develop:
	@echo Installing to prefix "'/$(PREFIX)' of root $(ROOT)"
	mkdir -p "$(ROOT)/$(PREFIX)/bin"
	touch "$(ROOT)/$(PREFIX)/bin/argbash" && rm "$(ROOT)/$(PREFIX)/bin/argbash"
	echo '#!/bin/bash' > "$(ROOT)/$(PREFIX)/bin/argbash"
	echo '$(ROOT_DIR)/$(GENPARSE) "$$@"' >> "$(ROOT)/$(PREFIX)/bin/argbash"
	chmod a+x "$(ROOT)/$(PREFIX)/bin/argbash"

install: $(GENPARSE)
	@echo Installing to prefix "'/$(PREFIX)' of root $(ROOT)"
	mkdir -p "$(ROOT)/$(PREFIX)/bin"
	touch "$(ROOT)/$(PREFIX)/bin/argbash"
	mkdir -p "$(ROOT)/$(PREFIX)/lib/argbash"
	touch "$(ROOT)/$(PREFIX)/lib/argbash/stuff.m4"
	cp $(M4_SRC) "$(ROOT)/$(PREFIX)/lib/argbash/"
	sed -e 's|M4DIR=.*|M4DIR=/$(PREFIX)/lib/argbash|' $(GENPARSE) > "$(ROOT)/$(PREFIX)/bin/argbash"
	chmod a+x "$(ROOT)/$(PREFIX)/bin/argbash"

uninstall:
	$(RM) "$(ROOT)/$(PREFIX)/bin/argbash"
	$(RM) "$(ROOT)/$(PREFIX)/lib/argbash/"*.m4
	rmdir "$(ROOT)/$(PREFIX)/lib/argbash"

version:
	@test -n '$(VERSION)' || { echo "You have to specify a version string, for example 'make release VERSION=1.0.0'"; exit 1; }
	echo '$(VERSION)' > ../src/version

release: version $(GENPARSE) examples check

tag:
	git tag $(shell cat ../src/version) -s -m 'Version release' master
	git push --tags
