m4_include([make.m4])

m4_include([tests/tests-base.m4])

m4_divert_push(STDOUT1)dnl
TESTS = 
SCRIPTS =
TESTS_GEN =

TESTDIR ?= ../regressiontests
PHONIES ?=

NUL =

ARGBASH_BIN = $(TESTDIR)/../../bin/argbash
ARGBASH_1TO2 = $(TESTDIR)/../../bin/argbash-1to2
REVERSE = $(TESTDIR)/reverse

%.sh: %.m4 $(ARGBASH_BIN)
	$(word 2,$^) $< -o $@
m4_divert_pop(STDOUT1)

m4_divert_push(STDOUT2)dnl
TESTS += \
	m4_join([ \
	], m4_set_list([_TESTS])) \
	$(NUL)
TESTS += tests-gen

SCRIPTS += \
	m4_join([ \
	], m4_set_list([_TEST_SCRIPTS])) \
	$(NUL)

TESTS_GEN += \
	m4_join([ \
	], m4_set_list([_TEST_GEN])) \
	$(NUL)

define generic_regression
	$< LOO | grep -q POS_S=LOO,
	$< "LOO BAR" | grep -q 'POS_S=LOO BAR,'
	$< LOO | grep -q BOOL=off,
	$< LOO --boo_l | grep -q BOOL=on,
	$< LOO --no-boo_l | grep -q BOOL=off,
	$< LOO | grep -q OPT_S=x,
	$< LOO --opt-arg PoS | grep -q OPT_S=PoS,
	$< LOO --opt-arg "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< LOO --opt-arg="PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< LOO UFTA | grep -q 'POS_OPT=UFTA,'
	$< LOO --boo_l --boo_l | grep -q 'POS_OPT=pos-default,'
	$< LOO | grep -q 'OPT_INCR=2,'
	$< LOO --opt-incr | grep -q 'OPT_INCR=3,'
	$< LOO --opt-incr -i | grep -q 'OPT_INCR=4,'
	$< -h | grep -- pos-arg | grep -q @pos-arg@
	$< -h | grep -- pos-opt | grep -q @pos-opt-arg@
	$(REVERSE) $< LOO --opt-arg 2> /dev/null
endef

define _test_onlypos
	$(REVERSE) grep -q case $<
	$< LOO | grep -q POS_S=LOO,POS_OPT=pos-default,
	$< LOO ar,guma | grep -q POS_S=LOO,POS_OPT=ar,guma,
	ERROR=spurious $(REVERSE) $< one two three
	ERROR='between 1 and 2' $(REVERSE) $< one two three
	ERROR='Not enough' $(REVERSE) $<
endef

regressiontests: $(TESTDIR)/Makefile $(TESTS)

$(TESTDIR)/Makefile: $(TESTDIR)/make/defns.m4 $(TESTDIR)/make/make.m4 $(wildcard $(TESTDIR)/make/tests/*)
	autom4te -l m4sugar -I $(TESTDIR)/make $< -o $@

m4_divert_pop(STDOUT2)

m4_divert_push(STDOUT4)dnl
tests-gen: $(TESTS_GEN)

tests-clean:
	$(RM) $(SCRIPTS)

.PHONY: $(PHONIES)

m4_divert_pop(STDOUT4)
