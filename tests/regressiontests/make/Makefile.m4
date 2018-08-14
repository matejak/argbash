m4_include([make.m4])

dnl TODO: include tests-*.m4, match it tests-<what>.m4
dnl TODO: Inside, assume that all test templates are in the <what> subdir and the test definitions are in a .m4 file next to them

m4_define([include_test], [m4_do(
	[m4_pushdef([_testname], [[$1]])],
	[m4_include(m4_expand([[../]_testname/[tests.m4]]))],
	[m4_popdef([_testname])],
)])

m4_include([tests/tests-base.m4])
m4_include([tests/tests-docopt.m4])
m4_include([tests/tests-delimiters.m4])
m4_include([tests/tests-init.m4])
m4_include([tests/tests-env.m4])
m4_include([tests/tests-types.m4])
m4_include([tests/tests-strict.m4])
m4_include([tests/tests-getopt.m4])

m4_divert_push(STDOUT1)dnl
TESTDIR ?= ../regressiontests
PHONIES ?=

NUL =

ARGBASH_BIN = $(TESTDIR)/../../bin/argbash
ARGBASH_1TO2 = $(TESTDIR)/../../bin/argbash-1to2
ARGBASH_INIT = $(TESTDIR)/../../bin/argbash-init
REVERSE = $(TESTDIR)/reverse

ARGBASH_EXEC ?= $(ARGBASH_BIN)
ARGBASH_INIT_EXEC ?= $(ARGBASH_INIT)

%-dash.sh: %.m4 $(ARGBASH_BIN)
	$(word 2,$^) --type posix-script -o $@ $<
	[sed -i "s|#!/bin/bash|#!]$(shell which dash)|" $@

%.sh: %.m4 $(ARGBASH_BIN)
	$(word 2,$^) $< -o $@

%.txt: %.m4 $(ARGBASH_BIN)
	$(word 2,$^) $< -t docopt --strip all -o $@
m4_divert_pop(STDOUT1)

m4_divert_push(STDOUT2)dnl
TESTS =
TESTS_GEN =

# presumably always-executed and created scripts
SCRIPTS = \
	m4_join([ \
	], m4_set_list([_TEST_SCRIPTS])) \
	$(NUL)

# bash tests
TESTS += \
	m4_join([ \
	], m4_set_list([BASH_TESTS])) \
	$(NUL)

# docopt tests
TESTS += \
	m4_join([ \
	], m4_set_list([DOCOPT_TESTS])) \
	$(NUL)

TESTS_GEN += \
	m4_join([ \
	], m4_set_list([_TEST_GEN_BASH])) \
	$(NUL)

SCRIPTS += \
	m4_join([ \
	], m4_set_list([_TEST_BASH_SCRIPTS]),m4_set_list([_TEST_DOCOPT_SCRIPTS])) \
	$(NUL)

ifneq "$(shell which dash 2> /dev/null)" ""

TESTS += \
	m4_join([ \
	], m4_set_list([DASH_TESTS])) \
	$(NUL)

TESTS_GEN += \
	m4_join([ \
	], m4_set_list([_TEST_GEN_DASH])) \
	$(NUL)

SCRIPTS += \
	m4_join([ \
	], m4_set_list([_TEST_DASH_SCRIPTS])) \
	$(NUL)

endif

TESTS += tests-gen
[
define generic_regression_posix
	$< LOO | grep -q 'POS_S=LOO',
	$< "LOO BAR" | grep -q 'POS_S=LOO BAR,'
	$< -b LOO | grep -q BOOL=on,
	$< LOO | grep -q BOOL=off,
	$< LOO | grep -q 'OPT_S=opt_arg_default lolo',
	$< LOO UFTA | grep -q 'POS_OPT=UFTA,'
	$< LOO | grep -q 'OPT_INCR=2,'
	$< -ii LOO | grep -q 'OPT_INCR=4,'
	$< -h | grep -- pos_arg | grep -q pos_arg_help
	$< -h | grep -- pos-opt | grep -q @pos-opt-arg@
	$< -h | grep -q ' \[<pos-opt>\]'
endef

define generic_regression_gnu_only
	$< LOO --opt_arg "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< --opt_arg PoS LOO | grep -q OPT_S=PoS,
	$< --opt_arg="PoS sob" LOO | grep -q 'OPT_S=PoS sob,'
	$< LOO -b | grep -q BOOL=on,
	$< LOO --boo_l | grep -q BOOL=on,
	$< LOO --boo_l --boo_l | grep -q 'POS_OPT=pos_opt_default lala,'
	$< --no-boo_l LOO | grep -q BOOL=off,
	$< --opt-incr -i LOO | grep -q 'OPT_INCR=4,'
	$< LOO --opt-incr | grep -q 'OPT_INCR=3,'
	$(REVERSE) $< LOO --opt_arg 2> /dev/null
endef
]
define _test_onlypos
	$(REVERSE) grep -q case $<
	$< LOO | grep -q POS_S=LOO,POS_OPT=pos-default,
	$< LOO ar,guma | grep -q POS_S=LOO,POS_OPT=ar,guma,
	ERROR=spurious $(REVERSE) $< one two three
	ERROR='between 1 and 2' $(REVERSE) $< one two three
	ERROR='Not enough' $(REVERSE) $<
endef

regressiontests: $(TESTDIR)/Makefile $(TESTS)

$(TESTDIR)/Makefile: $(TESTDIR)/make/Makefile.m4 $(TESTDIR)/make/make.m4 $(wildcard $(TESTDIR)/make/tests/*)
	autom4te -l m4sugar -I $(TESTDIR)/make $< -o $@

m4_divert_pop(STDOUT2)

m4_divert_push(STDOUT4)dnl
tests-gen: $(TESTS_GEN)

tests-clean:
	$(RM) $(SCRIPTS)
	rmdir $(TESTDIR)/otherdir

.PHONY: $(PHONIES)
m4_divert_pop(STDOUT4)
