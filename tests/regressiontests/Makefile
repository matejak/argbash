TESTDIR ?= ../regressiontests
PHONIES ?=

NUL =

ARGBASH_BIN = $(TESTDIR)/../../bin/argbash
ARGBASH_1TO2 = $(TESTDIR)/../../bin/argbash-1to2
REVERSE = $(TESTDIR)/reverse

%.sh: %.m4 $(ARGBASH_BIN)
	$(word 2,$^) $< -o $@

# Let test-gen be last - those tests take the longest time to complete
TESTS = \
	test-most \
	test-more \
	stability \
	args \
	stability-salone \
	args-salone \
	test-onlyopt \
	test-onlypos \
	test-ddash \
	test-simple \
	test-wrapping \
	test-wrapping-more \
	test-wrapping-excl \
	stability-wrapping \
	test-infinity \
	test-infinity-nodefaults \
	test-infinity-mixed \
	test-leftovers \
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
	$(TESTDIR)/test-more.sh \
	$(TESTDIR)/test-most.sh \
	$(TESTDIR)/test-simple.sh \
	$(TESTDIR)/test-wrapping.sh \
	$(TESTDIR)/test-wrapping-more.sh \
	$(TESTDIR)/test-wrapping-excl.sh \
	$(TESTDIR)/test-infinity.sh \
	$(TESTDIR)/test-infinity-nodefaults.sh \
	$(TESTDIR)/test-infinity-mixed.sh \
	$(TESTDIR)/test-leftovers.sh \
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

args: $(TESTDIR)/test.sh
	$(generic_regression)

GENTESTS = $(foreach tname,pos opt pos2 opt2 pos-opt pos-opt2 more,$(TESTDIR)/gen-test-$(tname).m4)

test-gen: $(ARGBASH_BIN) $(GENTESTS)
	ERROR=pos-arg $(REVERSE) $< $(word 2,$+) > /dev/null
	ERROR=opt-arg $(REVERSE) $< $(word 3,$+) > /dev/null
	ERROR=pos_arg $(REVERSE) $< $(word 4,$+) > /dev/null
	ERROR=opt_arg $(REVERSE) $< $(word 5,$+) > /dev/null
	ERROR=same-arg $(REVERSE) $< $(word 6,$+) > /dev/null
	ERROR=same_arg $(REVERSE) $< $(word 7,$+) > /dev/null
	ERROR="is unknown" $(REVERSE) $< $(word 8,$+) > /dev/null

#  the dependency $(TESTDIR)/test-standalone.sh should be assumed
args-salone: $(TESTDIR)/call-salone.sh
	$(generic_regression)

test-most: $(TESTDIR)/test-most.sh
	$< -h | grep -q '<pos-more1-1> <pos-more1-2> \[<pos-more2-1>\] \[<pos-more2-2>\]'
	$< xx yy | grep -q "POS_MORE1=xx yy,POS_MORE2=hu lu,"
	$< xx yy zz aa | grep -q "POS_MORE1=xx yy,POS_MORE2=zz aa,"

test-more: $(TESTDIR)/test-more.sh
	$< LOO x | grep -q "POS_S=LOO,POS_MORE=x f\[o\]o ba,r,"
	$< LOO lul laa | grep -q "POS_S=LOO,POS_MORE=lul laa ba,r,"
	$< LOO laa bus kus | grep -q "POS_S=LOO,POS_MORE=laa bus kus",

test-onlypos: $(TESTDIR)/test-onlypos.sh
	$(_test_onlypos)

# Also check the 2-spaces indentation
test-onlyopt: $(TESTDIR)/test-onlyopt.sh
	grep -q '^  esac$$' $<
	@# ! negates the return code
	! grep -q '^	' $<
	$(REVERSE) grep -q POSITION $<
	$< --opt-arg PoS | grep -q OPT_S=PoS,
	$< --opt-arg "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< -r /usr/lib --opt-repeated /usr/local/lib | grep -q 'ARG_REPEATED=/usr/lib /usr/local/lib,'
	$(REVERSE) $< LOO 2> /dev/null

stability-salone: $(TESTDIR)/test-standalone.sh $(TESTDIR)/test-standalone2.sh
	diff -q $< $(word 2,$^)

$(TESTDIR)/test-ddash.m4: $(TESTDIR)/test-ddash-old.m4 $(ARGBASH_1TO2)
	$(ARGBASH_1TO2) $< -o $@

test-ddash: $(TESTDIR)/test-ddash.sh
	$< --boo_l | grep -q 'BOOL=on,'
	$< -- --boo_l | grep -q 'BOOL=off,'
	$< -- --boo_l | grep -q 'POS_OPT=--boo_l,'
	$< -- --help | grep -q 'POS_OPT=--help,'
	$< -- | grep -q 'POS_OPT=pos-default,'
	$< -- --| grep -q 'POS_OPT=--,'
	ERROR=spurious 	$(REVERSE) $< -- foo bar
	ERROR=bar 	$(REVERSE) $< -- foo bar

test-simple: $(TESTDIR)/test-simple.sh
	$< pos | grep -q 'OPT_S=x,POS_S=pos,'
	$< pos -o 'uf ta' | grep -q 'OPT_S=uf ta,POS_S=pos,'
	ERROR=spurious 	$(REVERSE) $< -- one two
	ERROR="last one was: 'two'" 	$(REVERSE) $< one two
	ERROR="expect exactly 1" 	$(REVERSE) $< one two
	ERROR="[Nn]ot enough" 	$(REVERSE) $<
	ERROR="require exactly 1" 	$(REVERSE) $<

test-wrapping: $(TESTDIR)/test-wrapping.sh $(TESTDIR)/test-onlyopt.m4 $(TESTDIR)/test-onlypos.m4
	$< -h | grep -q opt-arg
	$< -h | grep -q pos-arg
	@# ! negates the return code
	! $< -h | grep -q boo_l
	@# no spaces as indentation (that test-onlyopt uses)
	! grep -q '^  ' $<
	grep -q '^	esac' $<
	$< XX LOOL | grep -q 'POS_S0=XX,POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL | grep -q 'POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL --opt-arg lalala | grep -q OPT_S=lalala,
	$< XX LOOL --opt-arg lalala | grep -q 'CMDLINE=--opt-arg lalala LOOL pos-default,'

test-wrapping-more: $(TESTDIR)/test-wrapping-more.sh $(TESTDIR)/test-onlyopt.m4
	$< -i -i -i | grep -q 'CMDLINE=-i -i -i,'
	$< -i -i | grep -q 'OPT_INCR=4,'
	ERROR="nexpected argument '--opt-arg'" $(REVERSE) $< --opt-arg lalala

test-wrapping-excl: $(TESTDIR)/test-wrapping-excl.sh $(TESTDIR)/test-onlypos.m4
	$(_test_onlypos)

stability-wrapping: $(TESTDIR)/test-wrapping.sh $(TESTDIR)/test-wrapping2.sh
	diff -q $< $(word 2,$^)

test-infinity: $(TESTDIR)/test-infinity.sh
	$< | grep -q 'POS_S=first,second,third,'
	$< 1 | grep -q 'POS_S=1,second,third,'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'

test-infinity-nodefaults: $(TESTDIR)/test-infinity-nodefaults.sh
	ERROR="require at least 2" $(REVERSE) $<
	$< 1 "2 3" | grep -q 'POS_S=1,2 3'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'

test-infinity-mixed: $(TESTDIR)/test-infinity-mixed.sh
	$< -h | grep -q '<pos-arg-1> \[<pos-arg-2>\] \.\.\. \[<pos-arg-n>\] \.\.\.$$'
	ERROR="require at least 1" $(REVERSE) $<
	$< 1 | grep -q 'POS_S=1,first,second'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'

test-leftovers: $(TESTDIR)/test-leftovers.sh
	$< -h | grep -q '\[-c|--cosi <arg>\] \[--(no-)fear\] \[-m|--more\] \[-h|--help\] <another> \.\.\. $$'
	$< -c ours -m --more --more --no-fear "ours pos" left "o ver" | grep -q 'MORE=3,OPT_S=ours,FEAR=off,POS_S=ours pos,LEFTOVERS=left,o ver,'

tests-clean:
	$(RM) $(SCRIPTS)

.PHONY: $(PHONIES)
