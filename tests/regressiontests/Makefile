TESTDIR ?= ../regressiontests
PHONIES ?= 

NUL =

ARGBASH_BIN = $(TESTDIR)/../../bin/argbash.sh
REVERSE = $(TESTDIR)/reverse

%.sh: %.m5 $(ARGBASH_BIN)
	$(word 2,$^) $< -o $@

TESTS = \
	stability \
	args \
	stability-salone \
	args-salone \
	test-onlyopt \
	test-onlypos \
	test-ddash \
	test-gen \
	$(NUL)

PHONIES += $(TESTS)

# test-salone is side-effect of call-salone
SCRIPTS = \
	$(TESTDIR)/test.sh \
	$(TESTDIR)/test2.sh \
	$(TESTDIR)/test-standalone.sh \
	$(TESTDIR)/test-standalone2.sh \
	$(TESTDIR)/call-salone.sh \
	$(TESTDIR)/test-salone.sh \
	$(TESTDIR)/test-onlyopt.sh \
	$(TESTDIR)/test-onlypos.sh \
	$(TESTDIR)/test-ddash.sh \
	$(NUL)

regressiontests: $(TESTS)
phony: $(PHONIES)

stability: $(TESTDIR)/test.sh $(TESTDIR)/test2.sh
	diff -q $< $(word 2,$^)

define generic_regression
	$< LOO | grep -q POS_S=LOO,
	$< "LOO BAR" | grep -q 'POS_S=LOO BAR,'
	$< LOO | grep -q BOOL=off,
	$< LOO --boo_l | grep -q BOOL=on,
	$< LOO --no-boo_l | grep -q BOOL=off,
	$< LOO | grep -q OPT_S=x,
	$< LOO --opt-arg PoS | grep -q OPT_S=PoS,
	$< LOO --opt-arg "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< LOO UFTA | grep -q 'POS_OPT=UFTA,'
	$< LOO --boo_l --boo_l | grep -q 'POS_OPT=pos-default,'
	$< LOO | grep -q 'OPT_INCR=2,'
	$< LOO --opt-incr | grep -q 'OPT_INCR=3,'
	$< LOO --opt-incr -i | grep -q 'OPT_INCR=4,'
	$< -h | grep -- pos-arg | grep -q @pos-arg@
	$< -h | grep -- pos-opt | grep -q @pos-opt-arg@
	$(REVERSE) $< LOO --opt-arg 2> /dev/null
endef

args: $(TESTDIR)/test.sh
	$(generic_regression)

GENTESTS = $(foreach tname,pos opt pos2 opt2 pos-opt pos-opt2,$(TESTDIR)/gen-test-$(tname).m4)

test-gen: $(ARGBASH_BIN) $(GENTESTS)
	ERROR=pos-arg $(REVERSE) $< $(word 2,$+) > /dev/null
	ERROR=opt-arg $(REVERSE) $< $(word 3,$+) > /dev/null
	ERROR=pos_arg $(REVERSE) $< $(word 4,$+) > /dev/null
	ERROR=opt_arg $(REVERSE) $< $(word 5,$+) > /dev/null
	ERROR=same-arg $(REVERSE) $< $(word 6,$+) > /dev/null
	ERROR=same_arg $(REVERSE) $< $(word 7,$+) > /dev/null

#  the dependency $(TESTDIR)/test-standalone.sh should be assumed
args-salone: $(TESTDIR)/call-salone.sh
	$(generic_regression)

test-onlypos: $(TESTDIR)/test-onlypos.sh
	$(REVERSE) grep -q case $<
	$< LOO | grep -q POS_S=LOO,POS_OPT=pos-default,
	$< LOO ar,guma | grep -q POS_S=LOO,POS_OPT=ar,guma,

test-onlyopt: $(TESTDIR)/test-onlyopt.sh
	$(REVERSE) grep -q POSITION $<
	$< --opt-arg PoS | grep -q OPT_S=PoS,
	$< --opt-arg "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$(REVERSE) $< LOO 2> /dev/null

stability-salone: $(TESTDIR)/test-standalone.sh $(TESTDIR)/test-standalone2.sh
	diff -q $< $(word 2,$^)

test-ddash: $(TESTDIR)/test-ddash.sh
	$< --boo_l | grep -q 'BOOL=on,'
	$< -- --boo_l | grep -q 'BOOL=off,'
	$< -- --boo_l | grep -q 'POS_OPT=--boo_l,'
	$< -- --help | grep -q 'POS_OPT=--help,'
	$< -- | grep -q 'POS_OPT=pos-default,'
	$< -- --| grep -q 'POS_OPT=--,'
	ERROR=spurious 	$(REVERSE) $< -- foo bar
	ERROR=bar 	$(REVERSE) $< -- foo bar

tests-clean:
	$(RM) $(SCRIPTS)
