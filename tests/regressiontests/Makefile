TESTDIR ?= ../regressiontests

NUL =

TESTS = \
	stability \
	args \
	stability-salone \
	args-salone \
	$(NUL)

regressiontests: $(TESTS)

stability: $(TESTDIR)/test.sh $(TESTDIR)/test2.sh
	diff -q $< $(word 2,$^)

define generic-regression =
	$< LOO | grep -q POS_S=LOO,
	$< "LOO BAR" | grep -q 'POS_S=LOO BAR,'
	$< LOO | grep -q BOOL=off,
	$< LOO --boo_l | grep -q BOOL=on,
	$< LOO --no-boo_l | grep -q BOOL=off,
	$< LOO | grep -q OPT_S=x,
	$< LOO --opt-arg PoS | grep -q OPT_S=PoS,
	$< LOO --opt-arg "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$(TESTDIR)/reverse $< LOO --opt-arg 2> /dev/null
endef

args: $(TESTDIR)/test.sh
	echo foo
	$(generic-regression)

stability-salone: $(TESTDIR)/test-standalone.sh $(TESTDIR)/test-standalone2.sh
	diff -q $< $(word 2,$^)

args-salone: $(TESTDIR)/call-standalone.sh $(TESTDIR)/test-standalone.sh
	$(generic-regression)
