TESTS =
SCRIPTS =
TESTS_GEN =

TESTDIR ?= ../regressiontests
PHONIES ?=

NUL =

ARGBASH_BIN = $(TESTDIR)/../../bin/argbash
ARGBASH_1TO2 = $(TESTDIR)/../../bin/argbash-1to2
ARGBASH_INIT = $(TESTDIR)/../../bin/argbash-init
REVERSE = $(TESTDIR)/reverse

%.sh: %.m4 $(ARGBASH_BIN)
	$(word 2,$^) $< -o $@
TESTS += \
	stability \
	basic \
	call-salone \
	test-most \
	test-more \
	test-onlypos \
	test-onlyopt \
	stability-salone \
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
	test-delim-space \
	test-delim-equals \
	test-delim-both \
	test-init_simple \
	test-init_simple-s \
	test-init_simple-ss \
	test-env-base \
	test-env-simple \
	test-int \
	$(NUL)
TESTS += tests-gen

SCRIPTS += \
	$(TESTDIR)/basic2.sh \
	$(TESTDIR)/basic.sh \
	$(TESTDIR)/test-salone.sh \
	$(TESTDIR)/call-salone.sh \
	$(TESTDIR)/test-most.sh \
	$(TESTDIR)/test-more.sh \
	$(TESTDIR)/test-onlypos.sh \
	$(TESTDIR)/test-onlyopt.sh \
	$(TESTDIR)/test-standalone2.sh \
	$(TESTDIR)/test-standalone.sh \
	$(TESTDIR)/test-ddash.m4 \
	$(TESTDIR)/test-ddash.sh \
	$(TESTDIR)/test-simple.sh \
	$(TESTDIR)/test-wrapping.sh \
	$(TESTDIR)/test-wrapping-more.sh \
	$(TESTDIR)/test-wrapping-excl.sh \
	$(TESTDIR)/test-wrapping2.sh \
	$(TESTDIR)/test-infinity.sh \
	$(TESTDIR)/test-infinity-nodefaults.sh \
	$(TESTDIR)/test-infinity-mixed.sh \
	$(TESTDIR)/test-leftovers.sh \
	$(TESTDIR)/test-delim-space.sh \
	$(TESTDIR)/test-delim-equals.sh \
	$(TESTDIR)/test-delim-both.sh \
	$(TESTDIR)/test-init_simple.sh \
	$(TESTDIR)/test-init_simple-s.sh \
	$(TESTDIR)/test-init_simple-ss.sh \
	$(TESTDIR)/test-init_simple.m4 \
	$(TESTDIR)/test-init_simple-s-parsing.sh \
	$(TESTDIR)/test-init_simple-s-parsing.m4 \
	$(TESTDIR)/test-init_simple-s.m4 \
	$(TESTDIR)/test-init_simple-ss-parsing.sh \
	$(TESTDIR)/test-init_simple-ss-parsing.m4 \
	$(TESTDIR)/gen-test-init_name_char.m4 \
	$(TESTDIR)/gen-test-init_name_dash.m4 \
	$(TESTDIR)/test-env-base.sh \
	$(TESTDIR)/test-env-simple.sh \
	$(TESTDIR)/test-int.sh \
	$(NUL)

TESTS_GEN += \
	gen-test-pos \
	gen-test-opt \
	gen-test-pos2 \
	gen-test-opt2 \
	gen-test-pos-opt \
	gen-test-pos-opt2 \
	gen-test-more \
	gen-test-illegal-pos \
	gen-test-illegal-opt \
	gen-test-init_name_dash \
	gen-test-init_name_char \
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

stability: $(TESTDIR)/basic.sh $(TESTDIR)/basic2.sh
	diff -q $< $(word 2,$^)

basic: $(TESTDIR)/basic.sh
	$(generic_regression)

call-salone: $(TESTDIR)/call-salone.sh
	$(generic_regression)

test-most: $(TESTDIR)/test-most.sh
	$< -h | grep -q '<pos-more1-1> <pos-more1-2> \[<pos-more2-1>\] \[<pos-more2-2>\]'
	$< xx yy | grep -q "POS_MORE1=xx yy,POS_MORE2=hu lu,"
	$< xx yy zz aa | grep -q "POS_MORE1=xx yy,POS_MORE2=zz aa,"
	$< -h | grep -q '<pos-more1-1> <pos-more1-2> \[<pos-more2-1>\] \[<pos-more2-2>\]'
	$< -h | grep -q '<pos-more1>: @pos-more1-arg@'
	$< -h | grep -q "<pos-more2>: @pos-more2-arg@ (defaults for <pos-more2-1> to <pos-more2-2> respectively: 'hu' and 'lu')"

test-more: $(TESTDIR)/test-more.sh
	$< LOO x | grep -q "POS_S=LOO,POS_MORE=x f\[o\]o ba,r,"
	$< LOO lul laa | grep -q "POS_S=LOO,POS_MORE=lul laa ba,r,"
	$< LOO laa bus kus | grep -q "POS_S=LOO,POS_MORE=laa bus kus",

test-onlypos: $(TESTDIR)/test-onlypos.sh
	$(_test_onlypos)

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

gen-test-pos: $(TESTDIR)/gen-test-pos.m4 $(ARGBASH_BIN)
	ERROR="pos-arg" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

gen-test-opt: $(TESTDIR)/gen-test-opt.m4 $(ARGBASH_BIN)
	ERROR="opt-arg" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

gen-test-pos2: $(TESTDIR)/gen-test-pos2.m4 $(ARGBASH_BIN)
	ERROR="pos_arg" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

gen-test-opt2: $(TESTDIR)/gen-test-opt2.m4 $(ARGBASH_BIN)
	ERROR="opt_arg" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

gen-test-pos-opt: $(TESTDIR)/gen-test-pos-opt.m4 $(ARGBASH_BIN)
	ERROR="same-arg" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

gen-test-pos-opt2: $(TESTDIR)/gen-test-pos-opt2.m4 $(ARGBASH_BIN)
	ERROR="same_arg" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

gen-test-more: $(TESTDIR)/gen-test-more.m4 $(ARGBASH_BIN)
	ERROR="is unknown" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

gen-test-illegal-pos: $(TESTDIR)/gen-test-illegal-pos.m4 $(ARGBASH_BIN)
	ERROR="contains forbidden characters" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

gen-test-illegal-opt: $(TESTDIR)/gen-test-illegal-opt.m4 $(ARGBASH_BIN)
	ERROR="one character" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

test-delim-space: $(TESTDIR)/test-delim-space.sh
	ERROR="unexpected argument '--opt=something'" $(REVERSE) $< --opt=something
	$< --opt something | grep -q 'OPT_S=something,'
	ERROR="unexpected argument '--add=three'" $(REVERSE) $< -a one --add two --add=three
	$< -a one --add two | grep -q 'OPT_REP=one two,'

test-delim-equals: $(TESTDIR)/test-delim-equals.sh
	ERROR="unexpected argument '--opt'" $(REVERSE) $< --opt something
	$< --opt=something | grep -q 'OPT_S=something,'
	ERROR="unexpected argument '--add'" $(REVERSE) $< -a one --add two --add=three
	$< -a one --add=two | grep -q 'OPT_REP=one two,'

test-delim-both: $(TESTDIR)/test-delim-both.sh
	$< --opt something | grep -q 'OPT_S=something,'
	$< --opt=something | grep -q 'OPT_S=something,'
	$< -a one --add two --add=three | grep -q 'OPT_REP=one two three'

test-init_simple: $(TESTDIR)/test-init_simple.sh
	ERROR="[Nn]ot enough" $(REVERSE) $<
	$< foo | grep -q "pos: foo"
	$< foo --opt bar | grep -q " --opt: bar"
	$< foo --opt bar | grep -q "boo is off"
	$< foo --opt bar --opt2 baz | grep -q " --opt: bar"
	$< foo --opt bar --opt2 baz | grep -q " --opt2: baz"
	$< foo --opt bar --opt2 baz --boo | grep -q "boo is on"

test-init_simple-s: $(TESTDIR)/test-init_simple-s.sh
	ERROR="[Nn]ot enough" $(REVERSE) $<
	$< foo | grep -q "pos: foo"
	$< foo --opt bar | grep -q " --opt: bar"
	$< foo --opt bar | grep -q "boo is off"
	$< foo --opt bar --opt2 baz | grep -q " --opt: bar"
	$< foo --opt bar --opt2 baz | grep -q " --opt2: baz"
	$< foo --opt bar --opt2 baz --boo | grep -q "boo is on"

test-init_simple-ss: $(TESTDIR)/test-init_simple-ss.sh $(TESTDIR)/test-init_simple-ss-parsing.sh
	ERROR="[Nn]ot enough" $(REVERSE) $<
	$< foo | grep -q "pos: foo"
	$< foo --opt bar | grep -q " --opt: bar"
	$< foo --opt bar | grep -q "boo is off"
	$< foo --opt bar --opt2 baz | grep -q " --opt: bar"
	$< foo --opt bar --opt2 baz | grep -q " --opt2: baz"
	$< foo --opt bar --opt2 baz --boo | grep -q "boo is on"

$(TESTDIR)/test-init_simple.m4: $(ARGBASH_INIT)
	$< --pos pos --opt opt2 --opt opt --opt-bool boo $@

$(TESTDIR)/test-init_simple-s.m4: $(ARGBASH_INIT)
	$< --pos pos --opt opt2 --opt opt --opt-bool boo $@ -s

$(TESTDIR)/test-init_simple-ss.sh: $(ARGBASH_INIT)
	$< --pos pos --opt opt2 --opt opt --opt-bool boo $@ -s -s

$(TESTDIR)/test-init_simple-ss-parsing.m4: $(TESTDIR)/test-init_simple-ss.sh
	@

$(TESTDIR)/gen-test-init_name_char.m4: $(ARGBASH_INIT)
	$< --opt-bool foo/bar-baz $@

$(TESTDIR)/gen-test-init_name_dash.m4: $(ARGBASH_INIT)
	$< --pos -bool $@

gen-test-init_name_dash: $(TESTDIR)/gen-test-init_name_dash.m4 $(ARGBASH_BIN)
	ERROR="'-bool' .* begins with a dash" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

gen-test-init_name_char: $(TESTDIR)/gen-test-init_name_char.m4 $(ARGBASH_BIN)
	ERROR="'foo/bar-baz' .* contains forbidden characters" $(REVERSE) $(ARGBASH_BIN) $< > /dev/null

test-env-base: $(TESTDIR)/test-env-base.sh
	$< | grep -q 'ENVI_FOO=def,ault,'
	$< | grep -q 'ENVI_BAR=,'
	ENVI_FOO=something $< | grep -q 'ENVI_FOO=something'
	$< -h | grep -q "ENVI_FOO: A sample env, variable. (default: 'def,ault')"
	$< -h | grep -q "ENVI_BAR: A sample env, variable."

test-env-simple: $(TESTDIR)/test-env-simple.sh
	$< | grep -q 'ENVI_FOO=def,ault,'
	! $< -h | grep -q 'ENVI_FOO'

test-int: $(TESTDIR)/test-int.sh
	$< 1 | grep -q "POS_S=1,"
	ERROR="integer" $(REVERSE) $< a
	ERROR="integer" $(REVERSE) $< 1.5
	$< 1 --num 2 | grep -q "OPT_S=2,"
	ERROR="integer" $(REVERSE) $< 1 --num b
	$< 01 | grep -q "POS_S=1,"
	$< +1 | grep -q "POS_S=1,"
	$< -1 | grep -q "POS_S=-1,"
	$< -1776 | grep -q "POS_S=1776,"
	$< -h | grep -q "INT"

tests-gen: $(TESTS_GEN)

tests-clean:
	$(RM) $(SCRIPTS)

.PHONY: $(PHONIES)
