NUL =

# SC2015: Note that A && B || C is not if-then-else. C may run when A is true.
SHELLCHECK_EXCLUDE_CHECKS_ARGUMENT = -e 2015

SHELLCHECK = $(shell shellcheck -V > /dev/null && echo "shellcheck -x $(SHELLCHECK_EXCLUDE_CHECKS_ARGUMENT)")

DEFINE_SCRIPT_DIR_FORM ?= DEFINE_SCRIPT_DIR$(shell readlink -e /dev/null > /dev/null && echo "_GNU")

M4_SRC = \
	../src/output-strip-none.m4 \
	../src/output-strip-user-content.m4 \
	../src/output-strip-all.m4 \
	../src/argbash-lib.m4 \
	../src/version \
	$(NUL)

M4_SRC += \
	../src/output-bash-script.m4 \
	../src/output-completion.m4 \
	../src/output-docopt.m4 \
	../src/output-manpage.m4 \
	../src/output-manpage-defs.m4 \
	../src/output-posix-script.m4 \
	$(NUL)

# generate using
# grep '^m4_include' ../src/*.m4 | sed -e 's/.*m4_include(\[\(.*\)\])\s*/\t..\/src\/\1 \\/' | sort | uniq
# which outputs all files that are included using m4_include in .m4 files
M4_SRC += \
	../src/argument_value_types.m4 \
	../src/collectors.m4 \
	../src/constants.m4 \
	../src/default_settings.m4 \
	../src/docopt.m4 \
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
SYSCONFDIR ?= /etc
BASH_COMPLETION_DIRECTORY ?= $(SYSCONFDIR)/bash_completion.d
ROOT ?= /

A_INIT = ../bin/argbash-init
GENPARSE = ../bin/argbash
COMPLETION = argbash
INSTALL_COMPLETION ?= no
ARGBASH_EXEC ?= $(GENPARSE)
ARGBASH_INIT_EXEC ?= $(A_INIT)
EXAMPLES = \
	examples/minimal.sh \
	examples/simple.sh \
	examples/simple-wrapper.sh \
	$(NUL)

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
MANPAGE = argbash.1.gz

$(GENPARSE): ../src/argbash.m4 $(M4_SRC)
	ARGBASH_INTENDED_DESTINATION="$@" bash $(GENPARSE) $< -o argbash.temp && mv argbash.temp $@

# TODO: Figure out how to use the GNU version of DEFINE_SCRIPT_DIR based on autodetection.
../src/argbash.m4.script-dir: ../src/argbash.m4
	sed "s/\\bDEFINE_SCRIPT_DIR\\b/$(DEFINE_SCRIPT_DIR_FORM)/" $< > $@

$(A_INIT): ../src/argbash-init.m4 $(GENPARSE)
	$(GENPARSE) $< -o $@

$(COMPLETION): ../src/argbash.m4 $(GENPARSE)
	$(GENPARSE) $< --type completion --strip all -o $@

major_version ?= $(shell cat ../src/version | sed -e 's/\..*//')

../bin/argbash-%to$(major_version): ../src/argbash-%to$(major_version).m4 $(GENPARSE)
	$(ARGBASH_EXEC) $< -o $@

lesser_versions = $(shell seq 1 $$(($(major_version) - 1)))
ARGBASH_TO = $(foreach ver,$(lesser_versions),../bin/argbash-$(ver)to$(major_version))

CHANGELOG = ../ChangeLog

%-standalone.sh: %-standalone.m4 $(GENPARSE)
	$(ARGBASH_EXEC) $< -o $@ --strip user-content

# argbash-init uses the -parsing suffix to denote standalone parsing sections of scripts
%-parsing.sh: %-parsing.m4 $(GENPARSE)
	$(ARGBASH_EXEC) $< -o $@ --strip user-content

%-standalone2.sh: %-standalone.sh $(GENPARSE)
	$(ARGBASH_EXEC) $< -o $@ --strip user-content

%.sh: %.m4 $(GENPARSE)
	$(ARGBASH_EXEC) $< -o $@

%2.sh: %.sh $(GENPARSE)
	$(ARGBASH_EXEC) $< -o $@

%3.sh: %2.sh $(GENPARSE)
	$(ARGBASH_EXEC) $< -o $@

examples/minimal.sh: examples/minimal.m4
	$(ARGBASH_EXEC) $< -c -o $@

# Must be included AFTER we have rules for .sh stuff
TESTDIR = ../tests/regressiontests

include ../tests/regressiontests/Makefile


# We include the source dir because there is m4_include in argbash-lib.m4
bootstrap:
	cat ../src/argbash-lib.m4 ../src/output-strip-none.m4 ../src/argbash.m4 | autom4te -I ../src -l m4sugar -o $(GENPARSE)
	chmod a+x $(GENPARSE)
	touch ../src/argbash.m4

examples: $(EXAMPLES)

check: $(TESTDIR)/Makefile $(GENPARSE) $(A_INIT) $(ARGBASH_TO)
	$(MAKE) unittests
	$(MAKE) regressiontests
	$(MAKE) tests-clean
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) $(ARGBASH_BIN)
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) $(ARGBASH_INIT)
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) $(ARGBASH_TO)
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
	test -z "$(ARGBASH_TO)" || ln -s $(abspath $(ARGBASH_TO)) "$(ROOT)/$(PREFIX)/bin"
	ln -s $(abspath $(A_INIT)) "$(ROOT)/$(PREFIX)/bin"

# Parse the version file and expose version numbers as variables
# that are available in targets that have this target as prerequisite
define-version:
	$(eval VERSION_PATCH := $(shell cut -f 3 -d . ../src/version))
	$(eval VERSION_MINOR := $(shell cut -f 2 -d . ../src/version))
	$(eval VERSION_MAJOR := $(shell cut -f 1 -d . ../src/version))
	$(eval VERSION_SUFFIX := -$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH))

argbash.rst: ../src/argbash.m4 $(ARGBASH_EXEC)
	$(ARGBASH_EXEC) --type manpage --strip all -o $@ $<

man: $(MANPAGE)

$(MANPAGE): argbash.rst argbash-defs.rst
	rst2man $< | gzip > $@

install: $(GENPARSE) $(A_INIT) $(ARGBASH_TO) $(COMPLETION) $(MANPAGE)
	@echo Installing to prefix "'/$(PREFIX)' of root $(ROOT)"
	mkdir -p "$(ROOT)/$(PREFIX)/bin"
	touch "$(ROOT)/$(PREFIX)/bin/argbash$(VERSION_SUFFIX)"
	mkdir -p "$(ROOT)/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)"
	touch "$(ROOT)/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)/argbash-lib.m4"
	cp -p $(M4_SRC) "$(ROOT)/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)/"
	grep -q 'm4dir=' $(GENPARSE) && sed -e 's|m4dir=.*|m4dir=/$(PREFIXED_LIBDIR)/argbash$(VERSION_SUFFIX)|' $(GENPARSE) > "$(ROOT)/$(PREFIX)/bin/argbash$(VERSION_SUFFIX)"
	test -n "$(VERSION_SUFFIX)" || test -z "$(ARGBASH_TO)" || { cp -p $(ARGBASH_TO) "$(ROOT)/$(PREFIX)/bin" && chmod a+x "$(ROOT)/$(PREFIX)"/bin/argbash-*; }
	cp -p $(A_INIT) "$(ROOT)/$(PREFIX)/bin/argbash-init$(VERSION_SUFFIX)" && chmod a+x "$(ROOT)/$(PREFIX)"/bin/argbash-init$(VERSION_SUFFIX)
	chmod a+x "$(ROOT)/$(PREFIX)/bin/argbash$(VERSION_SUFFIX)"
	test "$(INSTALL_COMPLETION)" = "no" || (mkdir -p "$(ROOT)/$(BASH_COMPLETION_DIRECTORY)" && mv "$(COMPLETION)" "$(ROOT)/$(BASH_COMPLETION_DIRECTORY)/")
	mkdir -p "$(ROOT)/$(PREFIX)/share/man/man1/"
	cp -p $(MANPAGE) "$(ROOT)/$(PREFIX)/share/man/man1/"

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
	$(RM) "$(ROOT)/$(BASH_COMPLETION_DIRECTORY)/$(COMPLETION)"
	$(RM) "$(ROOT)/$(PREFIX)/share/man/man1/$(MANPAGE)"

altuninstall: define-version uninstall

version:
	@test -n '$(VERSION)' || { echo "You have to specify a version string, for example 'make version VERSION=1.0.0'"; exit 1; }
	echo '$(VERSION)' > ../src/version
	sed -i "1s/.*/$(VERSION) ($$(date -I))/" $(CHANGELOG)
	touch $(M4_SRC)

../docker/Dockerfile: ../docker/Dockerfile.in
	cat "$<" | sed -e "s/@VERSION@/$(shell cat ../src/version)/g; s/@NOW@/$(shell date -Iseconds)/" > "$@"

release: version $(GENPARSE) $(ARGBASH_TO) examples check
	sed -i "1s/([-0-9]+)/($$(date -I))/" $(CHANGELOG)
	cd ../doc && $(MAKE) clean && $(MAKE) html && $(MAKE) clean-tmp
	$(MAKE) ../docker/Dockerfile

tag:
	git tag $(shell cat ../src/version) -s -m 'Version release' master
	git push --follow-tags

# Update using
# grep '^[-a-z]*:' Makefile | cut -f 1 -d ':' | sort | tr '\n' ' '
.PHONY: altinstall altpreclean bootstrap check check-shellcheck define-version develop examples install man release tag uninstall unittests version
