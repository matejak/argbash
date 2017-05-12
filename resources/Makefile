NUL =

M4_SRC = \
	../src/output.m4 \
	../src/output-standalone.m4 \
	../src/argbash-lib.m4 \
	../src/version \
	$(NUL)

# generate using
# grep '^m4_include' ../src/*.m4 | sed -e 's/.*m4_include(\[\(.*\)\])\s*/\t..\/src\/\1 \\/' | sort | uniq
# which outputs all files that are included using m4_include in .m4 files
M4_SRC += \
	../src/argument_value_types.m4 \
	../src/default_settings.m4 \
	../src/env_vars.m4 \
	../src/function_generators.m4 \
	../src/list.m4 \
	../src/progs.m4 \
	../src/stuff.m4 \
	../src/utilities.m4 \
	../src/value_validators.m4 \
	$(NUL)

PREFIX ?= $(HOME)/.local
PREFIXED_LIBDIR ?= $(PREFIX)/lib
ROOT ?= /

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


# We include the source dir because there is m4_include in argbash-lib.m4
bootstrap:
	cat ../src/argbash-lib.m4 ../src/output.m4 ../src/argbash.m4 | autom4te -I ../src -l m4sugar -o $(GENPARSE)
	chmod a+x $(GENPARSE)
	touch ../src/argbash.m4

examples: $(EXAMPLES)

check: $(TESTDIR)/Makefile $(GENPARSE) $(A_INIT) $(ARGBASH_TO)
	$(MAKE) unittests
	$(MAKE) regressiontests
	$(MAKE) tests-clean
	@echo "*** All is OK ***"

# TODO: Think out how to make a multiline foreach
unittests:
	$(foreach testfile,$(wildcard ../tests/unittests/check-*.m4),autom4te -l m4sugar -I ../src/ -I ../tests/unittests $(testfile) &&) true

develop: $(ARGBASH_TO)
	@echo Installing to prefix "'/$(PREFIX)' of root $(ROOT)"
	mkdir -p "$(ROOT)/$(PREFIX)/bin"
	touch "$(ROOT)/$(PREFIX)/bin/argbash" && rm "$(ROOT)/$(PREFIX)/bin/argbash"
	echo '#!/bin/bash' > "$(ROOT)/$(PREFIX)/bin/argbash"
	echo '$(abspath $(ROOT_DIR)/$(GENPARSE)) "$$@"' >> "$(ROOT)/$(PREFIX)/bin/argbash"
	chmod a+x "$(ROOT)/$(PREFIX)/bin/argbash"
	test -z "$(ARGBASH_TO)" || ln -s -r $(ARGBASH_TO) "$(ROOT)/$(PREFIX)/bin"
	ln -s -r $(A_INIT) "$(ROOT)/$(PREFIX)/bin"

# Parse the version file and expose version numbers as variables
# that are available in targets that have this target as prerequisite
define-version:
	$(eval VERSION_PATCH := $(shell cut -f 3 -d . ../src/version))
	$(eval VERSION_MINOR := $(shell cut -f 2 -d . ../src/version))
	$(eval VERSION_MAJOR := $(shell cut -f 1 -d . ../src/version))
	$(eval VERSION_SUFFIX := -$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH))

install: $(GENPARSE) $(A_INIT) $(ARGBASH_TO)
	@echo Installing to prefix "'/$(PREFIX)' of root $(ROOT)"
	mkdir -p "$(ROOT)/$(PREFIX)/bin"
	touch "$(ROOT)/$(PREFIX)/bin/argbash$(VERSION_SUFFIX)"
	mkdir -p "$(ROOT)/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)"
	touch "$(ROOT)/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)/argbash-lib.m4"
	cp $(M4_SRC) "$(ROOT)/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)/"
	grep -q 'm4dir=' $(GENPARSE) && sed -e 's|m4dir=.*|m4dir=/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)|' $(GENPARSE) > "$(ROOT)/$(PREFIX)/bin/argbash$(VERSION_SUFFIX)"
	test -n "$(VERSION_SUFFIX)" || test -z "$(ARGBASH_TO)" || { cp $(ARGBASH_TO) "$(ROOT)/$(PREFIX)/bin" && chmod a+x "$(ROOT)/$(PREFIX)"/bin/argbash-*; }
	cp $(A_INIT) "$(ROOT)/$(PREFIX)/bin/argbash-init$(VERSION_SUFFIX)" && chmod a+x "$(ROOT)/$(PREFIX)"/bin/argbash-init$(VERSION_SUFFIX)
	chmod a+x "$(ROOT)/$(PREFIX)/bin/argbash$(VERSION_SUFFIX)"

altpreclean: define-version
	$(RM) "$(ROOT)/$(PREFIX)/bin/argbash-$(VERSION_MAJOR).$(VERSION_MINOR)"
	$(RM) "$(ROOT)/$(PREFIX)/bin/argbash-$(VERSION_MAJOR)"
	$(RM) "$(ROOT)/$(PREFIX)/bin/argbash"

altinstall: altpreclean install
	ln -s "$(ROOT)/$(PREFIX)/bin/argbash$(VERSION_SUFFIX)" "$(ROOT)/$(PREFIX)/bin/argbash-$(VERSION_MAJOR).$(VERSION_MINOR)"
	ln -s "$(ROOT)/$(PREFIX)/bin/argbash-$(VERSION_MAJOR).$(VERSION_MINOR)" "$(ROOT)/$(PREFIX)/bin/argbash-$(VERSION_MAJOR)"
	ln -s "$(ROOT)/$(PREFIX)/bin/argbash-$(VERSION_MAJOR)" "$(ROOT)/$(PREFIX)/bin/argbash"

uninstall:
	$(RM) "$(ROOT)/$(PREFIX)/bin/argbash"
	$(RM) "$(ROOT)/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)/"*.m4
	$(RM) "$(ROOT)/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)/version"
	$(RM) "$(ROOT)/$(PREFIX)"/bin/argbash-*
	rmdir "$(ROOT)/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)"

altuninstall: define-version uninstall

version:
	@test -n '$(VERSION)' || { echo "You have to specify a version string, for example 'make version VERSION=1.0.0'"; exit 1; }
	echo '$(VERSION)' > ../src/version
	sed -i "1s/.*/$(VERSION) ($$(date -I))/" $(CHANGELOG)
	touch $(M4_SRC)

release: version $(GENPARSE) $(ARGBASH_TO) examples check
	sed -i "1s/([-0-9]+)/($$(date -I))/" $(CHANGELOG)
	cd ../doc && make clean && make html && make clean-tmp

tag:
	git tag $(shell cat ../src/version) -s -m 'Version release' master
	git push --follow-tags

# Update using
# grep '^[-a-z]*:' Makefile | cut -f 1 -d ':' | sort | tr '\n' ' '
.PHONY: altinstall altpreclean bootstrap check define-version develop examples install release tag uninstall unittests version
