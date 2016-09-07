NUL =

M4_SRC = \
	../src/output.m4 \
	../src/output-standalone.m4 \
	../src/stuff.m4 \
	../src/version \
	$(NUL)

PREFIX = $(HOME)/.local
ROOT = /

A_INIT = ../bin/argbash-init
GENPARSE = ../bin/argbash
EXAMPLES = \
	examples/minimal.sh \
	examples/simple.sh \
	examples/simple-wrapper.sh \
	$(NUL)

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

$(GENPARSE): ../src/argbash.m4 $(M4_SRC)
	bash $(GENPARSE) $< -o argbash.temp && mv argbash.temp $@

$(A_INIT): ../src/argbash-init.m4 $(GENPARSE)
	bash $(GENPARSE) $< -o $@

major_version ?= $(shell cat ../src/version | sed -e 's/\..*//')

../bin/argbash-%to$(major_version): ../src/argbash-%to$(major_version).m4 $(GENPARSE)
	bash $(GENPARSE) $< -o $@

lesser_versions = $(shell seq 1 $$(($(major_version) - 1)))
ARGBASH_TO = $(foreach ver,$(lesser_versions),../bin/argbash-$(ver)to$(major_version))

CHANGELOG = ../ChangeLog

%-standalone.sh: %-standalone.m4 $(GENPARSE)
	$(GENPARSE) $< -o $@ --library

# argbash-init uses the -parsing suffix to denote standalone parsing sections of scripts
%-parsing.sh: %-parsing.m4 $(GENPARSE)
	$(GENPARSE) $< -o $@ --library

%-standalone2.sh: %-standalone.sh $(GENPARSE)
	$(GENPARSE) $< -o $@ --library

%.sh: %.m4 $(GENPARSE)
	$(GENPARSE) $< -o $@

%2.sh: %.sh $(GENPARSE)
	$(GENPARSE) $< -o $@

%3.sh: %2.sh $(GENPARSE)
	$(GENPARSE) $< -o $@

# Must be included AFTER we have rules for .sh stuff
TESTDIR = ../tests/regressiontests

include ../tests/regressiontests/Makefile


# We include the source dir because there is m4_include in stuff.m4
bootstrap:
	cat ../src/stuff.m4 ../src/output.m4 ../src/argbash.m4 | autom4te -I ../src -l m4sugar -o $(GENPARSE)
	chmod a+x $(GENPARSE)
	touch ../src/argbash.m4

examples: $(EXAMPLES)

check: $(TESTDIR)/Makefile $(GENPARSE) $(A_INIT) $(ARGBASH_TO)
	$(MAKE) unittests
	$(MAKE) regressiontests
	$(MAKE) tests-clean
	@echo "*** All is OK ***"

unittests:
	autom4te -l m4sugar -I ../src/ ../tests/unittests/list.m4

develop: $(ARGBASH_TO)
	@echo Installing to prefix "'/$(PREFIX)' of root $(ROOT)"
	mkdir -p "$(ROOT)/$(PREFIX)/bin"
	touch "$(ROOT)/$(PREFIX)/bin/argbash" && rm "$(ROOT)/$(PREFIX)/bin/argbash"
	echo '#!/bin/bash' > "$(ROOT)/$(PREFIX)/bin/argbash"
	echo '$(abspath $(ROOT_DIR)/$(GENPARSE)) "$$@"' >> "$(ROOT)/$(PREFIX)/bin/argbash"
	test -z "$(ARGBASH_TO)" || ln -s -r $(ARGBASH_TO) "$(ROOT)/$(PREFIX)/bin"
	ln -s -r $(A_INIT) "$(ROOT)/$(PREFIX)/bin"
	chmod a+x "$(ROOT)/$(PREFIX)/bin/argbash"

install: $(GENPARSE) $(A_INIT) $(ARGBASH_TO)
	@echo Installing to prefix "'/$(PREFIX)' of root $(ROOT)"
	mkdir -p "$(ROOT)/$(PREFIX)/bin"
	touch "$(ROOT)/$(PREFIX)/bin/argbash"
	mkdir -p "$(ROOT)/$(PREFIX)/lib/argbash"
	touch "$(ROOT)/$(PREFIX)/lib/argbash/stuff.m4"
	cp $(M4_SRC) "$(ROOT)/$(PREFIX)/lib/argbash/"
	grep -q 'm4dir=' $(GENPARSE) && sed -e 's|m4dir=.*|m4dir=/$(PREFIX)/lib/argbash|' $(GENPARSE) > "$(ROOT)/$(PREFIX)/bin/argbash"
	test -z "$(ARGBASH_TO)" || { cp $(ARGBASH_TO) "$(ROOT)/$(PREFIX)/bin" && chmod a+x "$(ROOT)/$(PREFIX)"/bin/argbash-*; }
	cp $(A_INIT) "$(ROOT)/$(PREFIX)/bin" && chmod a+x "$(ROOT)/$(PREFIX)"/bin/argbash-init
	chmod a+x "$(ROOT)/$(PREFIX)/bin/argbash"

uninstall:
	$(RM) "$(ROOT)/$(PREFIX)/bin/argbash"
	$(RM) "$(ROOT)/$(PREFIX)/lib/argbash/"*.m4
	$(RM) "$(ROOT)/$(PREFIX)/lib/argbash/version"
	$(RM) "$(ROOT)/$(PREFIX)"/bin/argbash-*
	rmdir "$(ROOT)/$(PREFIX)/lib/argbash"

version:
	@test -n '$(VERSION)' || { echo "You have to specify a version string, for example 'make version VERSION=1.0.0'"; exit 1; }
	echo '$(VERSION)' > ../src/version
	sed -i "1s/.*/$(VERSION) ($$(date -I))/" $(CHANGELOG)
	touch $(M4_SRC)

release: version $(GENPARSE) $(ARGBASH_TO) examples check
	sed -i "1s/([-0-9]+)/($$(date -I))/" $(CHANGELOG)
	cd ../doc && make clean && make html

tag:
	git tag $(shell cat ../src/version) -s -m 'Version release' master
	git push --follow-tags
