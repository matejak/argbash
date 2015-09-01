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
	$< LOO | grep -q 'POS_OPT=pos-default,'
	$< -h | grep -- pos-arg | grep -q @pos-arg@
	$< -h | grep -- pos-opt | grep -q @pos-opt-arg@
	$(TESTDIR)/reverse $< LOO --opt-arg 2> /dev/null
endef

args: $(TESTDIR)/test.sh
	$(generic_regression)

#  the dependency $(TESTDIR)/test-standalone.sh should be assumed
args-salone: $(TESTDIR)/call-salone.sh
	$(generic_regression)

stability-salone: $(TESTDIR)/test-standalone.sh $(TESTDIR)/test-standalone2.sh
	diff -q $< $(word 2,$^)
