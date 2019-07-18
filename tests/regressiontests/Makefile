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
	sed -i "s|#!/bin/bash|#!$(shell which dash)|" $@

%.sh: %.m4 $(ARGBASH_BIN)
	$(word 2,$^) $< -o $@

%.txt: %.m4 $(ARGBASH_BIN)
	$(word 2,$^) $< -t docopt --strip all -o $@
TESTS =
TESTS_GEN =

# presumably always-executed and created scripts
SCRIPTS = \
	$(TESTDIR)/basic2.sh \
	$(TESTDIR)/test-salone.sh \
	$(TESTDIR)/test-standalone2.sh \
	$(TESTDIR)/test-ddash.m4 \
	$(TESTDIR)/test-diy-noop.m4 \
	$(TESTDIR)/test-diy-noop.sh \
	$(TESTDIR)/test-diy.m4 \
	$(TESTDIR)/test-wrapping-second_level.sh \
	$(TESTDIR)/test-wrapping-single_level.sh \
	$(TESTDIR)/otherdir/test-onlyopt.m4 \
	$(TESTDIR)/test-wrapping-otherdir.sh \
	$(TESTDIR)/otherdir/test-onlypos.m4 \
	$(TESTDIR)/test-wrapping2.sh \
	$(TESTDIR)/test-init_simple.sh \
	$(TESTDIR)/test-init_simple.m4 \
	$(TESTDIR)/test-init_simple-parsing.m4 \
	$(TESTDIR)/test-init_simple-s.sh \
	$(TESTDIR)/test-init_simple-s-parsing.sh \
	$(TESTDIR)/test-init_simple-s-parsing.m4 \
	$(TESTDIR)/test-init_simple-s.m4 \
	$(TESTDIR)/regenerate-test-init-simple-s-update.m4 \
	$(TESTDIR)/test-init_simple-s-update-parsing.sh \
	$(TESTDIR)/test-init_simple-s-update-parsing.m4 \
	$(TESTDIR)/regenerate-test-init_simple-s-update.m4 \
	$(TESTDIR)/test-init_simple-s-update.m4 \
	$(TESTDIR)/test-init_simple-ss-parsing.sh \
	$(TESTDIR)/test-init_simple-ss-parsing.m4 \
	$(TESTDIR)/test-init_simple-ss.sh \
	$(TESTDIR)/gen-test-init_name_char.m4 \
	$(TESTDIR)/gen-test-init_name_dash.m4 \
	$(TESTDIR)/gen-test-group-wrong.m4 \
	$(TESTDIR)/test-semi_strict.sh \
	$(TESTDIR)/test-very_strict.sh \
	$(TESTDIR)/test-getopt-equals.sh \
	$(TESTDIR)/test-getopt-both.sh \
	$(TESTDIR)/test-getopt-space.sh \
	$(NUL)

# bash tests
TESTS += \
	stability \
	basic \
	test-void \
	call-salone \
	test-most \
	test-more \
	test-onlypos \
	test-onlypos-declared \
	test-onlyopt \
	stability-salone \
	test-ddash \
	test-simple \
	test-diy-noop \
	test-diy \
	test-wrapping-second_level \
	test-wrapping \
	test-wrapping-otherdir \
	test-wrapping-more \
	test-wrapping-excl \
	stability-wrapping \
	test-infinity-minimal_call \
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
	test-init_simple-s-update \
	test-env-base \
	test-env-simple \
	test-int \
	test-group \
	test-group-idx \
	test-semi_strict \
	test-very_strict \
	test-getopt-both \
	test-getopt-space \
	test-getopt-equals \
	$(NUL)

# docopt tests
TESTS += \
	basic-docopt \
	test-onlyopt-docopt \
	$(NUL)

TESTS_GEN += \
	gen-test-pos \
	gen-test-opt \
	gen-test-pos2 \
	gen-test-opt2 \
	gen-test-infinity-illegal \
	gen-test-bool-default \
	gen-test-pos-opt \
	gen-test-pos-opt2 \
	gen-test-more \
	gen-test-illegal-pos \
	gen-test-illegal-opt \
	gen-test-misspelled \
	gen-test-unmatched_bracket \
	gen-test-badcall-multi \
	gen-test-init_name_dash \
	gen-test-init_name_char \
	gen-test-group-wrong \
	$(NUL)

SCRIPTS += \
	$(TESTDIR)/basic.sh \
	$(TESTDIR)/test-void.sh \
	$(TESTDIR)/call-salone.sh \
	$(TESTDIR)/test-most.sh \
	$(TESTDIR)/test-more.sh \
	$(TESTDIR)/test-onlypos.sh \
	$(TESTDIR)/test-onlypos-declared.sh \
	$(TESTDIR)/test-onlyopt.sh \
	$(TESTDIR)/test-standalone.sh \
	$(TESTDIR)/test-ddash.sh \
	$(TESTDIR)/test-simple.sh \
	$(TESTDIR)/test-diy-noop.sh \
	$(TESTDIR)/test-diy.sh \
	$(TESTDIR)/test-wrapping-second_level.sh \
	$(TESTDIR)/test-wrapping.sh \
	$(TESTDIR)/test-wrapping-otherdir.sh \
	$(TESTDIR)/test-wrapping-more.sh \
	$(TESTDIR)/test-wrapping-excl.sh \
	$(TESTDIR)/test-infinity-minimal_call.sh \
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
	$(TESTDIR)/test-init_simple-s-update.sh \
	$(TESTDIR)/test-env-base.sh \
	$(TESTDIR)/test-env-simple.sh \
	$(TESTDIR)/test-int.sh \
	$(TESTDIR)/test-group.sh \
	$(TESTDIR)/test-group-idx.sh \
	$(TESTDIR)/test-semi_strict.sh \
	$(TESTDIR)/test-very_strict.sh \
	$(TESTDIR)/test-getopt-both.sh \
	$(TESTDIR)/test-getopt-space.sh \
	$(TESTDIR)/test-getopt-equals.sh \
	$(TESTDIR)/basic.txt \
	$(TESTDIR)/test-onlyopt.txt \
	$(NUL)

ifneq "$(shell which dash 2> /dev/null)" ""

TESTS += \
	basic-dash \
	test-onlyopt-dash \
	test-simple-dash \
	$(NUL)

TESTS_GEN += \
	gen-test-infinity-dash \
	gen-test-wrap-dash \
	$(NUL)

SCRIPTS += \
	$(TESTDIR)/basic-dash.sh \
	$(TESTDIR)/test-onlyopt-dash.sh \
	$(TESTDIR)/test-simple-dash.sh \
	$(NUL)

endif

TESTS += tests-gen

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

stability: $(TESTDIR)/basic.sh $(TESTDIR)/basic2.sh
	diff -q $< $(word 2,$^)
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/basic.sh"
basic: $(TESTDIR)/basic.sh
	$(generic_regression_posix)
	$(generic_regression_gnu_only)
	$< -h | grep -q 'P percent: %'
	$< -h | grep -q 'O percent: %'
	! $< -h | grep -qe '\[--\]'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/basic.sh"
basic-dash: $(TESTDIR)/basic-dash.sh
	$(generic_regression_posix)
	$< LOO -b | grep -q BOOL=off,
	$< -h | grep -q 'P percent: %'
	$< -h | grep -q 'O percent: %'
	$< -h | grep -qe '\[--\]'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/basic-dash.sh"
test-void: $(TESTDIR)/test-void.sh
	! grep -q 'die' $<
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-void.sh"
call-salone: $(TESTDIR)/call-salone.sh
	$(generic_regression_posix)
	$(generic_regression_gnu_only)
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/call-salone.sh"
test-most: $(TESTDIR)/test-most.sh
	$< -h | grep -q '<pos-more1-1> <pos-more1-2> \[<pos-more2-1>\] \[<pos-more2-2>\]'
	$< xx yy | grep -q "POS_MORE1=xx yy,POS_MORE2=hu lu,"
	$< xx yy zz aa | grep -q "POS_MORE1=xx yy,POS_MORE2=zz aa,"
	$< -h | grep -q '<pos-more1-1> <pos-more1-2> \[<pos-more2-1>\] \[<pos-more2-2>\]'
	$< -h | grep -q '<pos-more1>: @pos-more1-arg@'
	$< -h | grep -q "<pos-more2>: @pos-more2-arg@ (defaults for <pos-more2-1> to <pos-more2-2> respectively: 'hu' and 'lu')"
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-most.sh"
test-more: $(TESTDIR)/test-more.sh
	$< LOO x | grep -q "POS_S=LOO,POS_MORE=x f\[o\]o ba,r,"
	$< LOO lul laa | grep -q "POS_S=LOO,POS_MORE=lul laa ba,r,"
	$< LOO laa bus kus | grep -q "POS_S=LOO,POS_MORE=laa bus kus",
	ERROR="namely: 'pos-arg' and 'pos-more'" $(REVERSE) $<
	grep -q '^		_positionals' $<
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-more.sh"
test-onlypos: $(TESTDIR)/test-onlypos.sh
	$(_test_onlypos)
	! grep -q '^_arg_pos_arg=$$' $<
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-onlypos.sh"
test-onlypos-declared: $(TESTDIR)/test-onlypos-declared.sh
	$(_test_onlypos)
	grep -q '^_arg_pos_arg=$$' $<
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-onlypos-declared.sh"
test-onlyopt: $(TESTDIR)/test-onlyopt.sh
	grep -q '^    esac$$' $<
	@# ! negates the return code
	! grep -q '^	' $<
	$(REVERSE) grep -q POSITION $<
	$< -o "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< -B | grep -q 'BOOL=on'
	$< -i | grep -q 'OPT_INCR=3,'
	$< -i -i | grep -q 'OPT_INCR=4,'
	! $< -h | grep -q -e '-B,'
	$(REVERSE) $< LOO 2> /dev/null
	$< --opt-arg PoS | grep -q OPT_S=PoS,
	$< --opt-arg "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< --boo_l | grep -q 'BOOL=on'
	$< --no-boo_l | grep -q 'BOOL=off'
	$< -r /usr/lib --opt-repeated /usr/local/lib | grep -q 'ARG_REPEATED=/usr/lib /usr/local/lib,'
	$< -h | grep -q -e '-B|--(no-)boo_l'
	$< -h | grep -q -e '-i|--incrx'
	$< -h | grep -q -e '-i, --incrx'
	$< -h | grep -q -e '-o|--opt-arg <arg>'
	$< -h | grep -q -e '-o, --opt-arg: @opt-arg@'
	$< -h | grep -q -e '-r|--opt-repeated'
	$< -h | grep -q -e '-r, --opt-repeated:'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-onlyopt.sh"
test-onlyopt-dash: $(TESTDIR)/test-onlyopt-dash.sh
	grep -q '^    esac$$' $<
	@# ! negates the return code
	! grep -q '^	' $<
	$(REVERSE) grep -q POSITION $<
	$< -o "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< -B | grep -q 'BOOL=on'
	$< -i | grep -q 'OPT_INCR=3,'
	$< -i -i | grep -q 'OPT_INCR=4,'
	! $< -h | grep -q -e '-B,'
	$(REVERSE) $< LOO 2> /dev/null
	$< -h | grep -q -e '-B'
	$< -h | grep -q -e '-i'
	$< -h | grep -q -e '-o <arg>'
	$< -h | grep -q -e '-o: @opt-arg@'
	! $< -h | grep -q -e '-r'
	ERROR=cosi $(REVERSE) $< -o lala cosi
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-onlyopt-dash.sh"
stability-salone: $(TESTDIR)/test-standalone.sh $(TESTDIR)/test-standalone2.sh
	diff -q $< $(word 2,$^)
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-standalone.sh"
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
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-ddash.sh"
test-simple: $(TESTDIR)/test-simple.sh
	$< pos | grep -q 'OPT_S=x,POS_S=pos,'
	$< -o 'uf ta' pos | grep -q 'OPT_S=uf ta,POS_S=pos,'
	$< -h | grep -q 'END-$$'
	$< -h | grep -q '^\s*-BEGIN'
	$< -h | grep -q '^		-BEGIN'
	$< -h | grep -q -v '^\s*-BEGIN2'
	$< -h | grep -q -v 'END2-$$'
	$< -h | grep -q '"line 2" END-\\n'
	$< -h | grep -q '^		-PBEGIN'
	$< -h | grep -q 'PEND-$$'
	grep -q '^		esac' $<
	grep -q '^			\*)' $<
	ERROR=spurious 	$(REVERSE) $< -- one two
	ERROR="last one was: 'two'" 	$(REVERSE) $< one two
	ERROR="expect exactly 1" 	$(REVERSE) $< one two
	ERROR="[Nn]ot enough" 	$(REVERSE) $<
	ERROR="require exactly 1" 	$(REVERSE) $<
	$< pos -o 'uf ta' | grep -q 'OPT_S=uf ta,POS_S=pos,'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-simple.sh"
test-simple-dash: $(TESTDIR)/test-simple-dash.sh
	$< pos | grep -q 'OPT_S=x,POS_S=pos,'
	$< -o 'uf ta' pos | grep -q 'OPT_S=uf ta,POS_S=pos,'
	$< -h | grep -q 'END-$$'
	$< -h | grep -q '^\s*-BEGIN'
	$< -h | grep -q '^		-BEGIN'
	$< -h | grep -q -v '^\s*-BEGIN2'
	$< -h | grep -q -v 'END2-$$'
	$< -h | grep -q '"line 2" END-\\n'
	$< -h | grep -q '^		-PBEGIN'
	$< -h | grep -q 'PEND-$$'
	grep -q '^		esac' $<
	grep -q '^			\*)' $<
	ERROR=spurious 	$(REVERSE) $< -- one two
	ERROR="last one was: 'two'" 	$(REVERSE) $< one two
	ERROR="expect exactly 1" 	$(REVERSE) $< one two
	ERROR="[Nn]ot enough" 	$(REVERSE) $<
	ERROR="require exactly 1" 	$(REVERSE) $<
	ERROR="got 3" $(REVERSE) $< -- -o 'uf ta' pos
	ERROR="got 3" $(REVERSE) $< pos -o 'uf ta'
	ERROR="last one was: 'uf ta'" $(REVERSE) $< pos -o 'uf ta'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-simple-dash.sh"
test-diy-noop: $(TESTDIR)/test-diy-noop.sh
	$< LOO --opt_arg > /dev/null
	$< LOO 1 2 3 3 > /dev/null
	$< > /dev/null
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-diy-noop.sh"
$(TESTDIR)/test-diy-noop.m4: $(TESTDIR)/basic.m4
	sed -e 's/ARGBASH_GO/ARGBASH_PREPARE/' $< > $@

$(TESTDIR)/test-diy-noop.sh: $(TESTDIR)/test-diy-noop.m4
	$(ARGBASH_BIN) -c -o "$@" "$<"

test-diy: $(TESTDIR)/test-diy.sh
	$(generic_regression_posix)
	$(generic_regression_gnu_only)
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-diy.sh"
$(TESTDIR)/test-diy.m4: $(TESTDIR)/test-diy-noop.m4 $(TESTDIR)/test-diy-noop.sh
	sed -e "s/#.*\[$$/&\n$$(grep -e '#  \S' "$(TESTDIR)/test-diy-noop.sh" | sed -e 's/^#  //' | tr '\n' ';')/" $< > $@

test-wrapping-second_level: $(TESTDIR)/test-wrapping-second_level.sh
	$< -h | grep -q opt-arg
	$< -h | grep -q pos-arg
	@# ! negates the return code
	! $< -h | grep -q boo_l
	@# no spaces as indentation (that test-onlyopt uses)
	! grep -q '^  ' $<
	grep -q '^		esac' $<
	$< XX LOOL | grep -q 'POS_S0=XX,POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL | grep -q 'POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL --opt-arg lalala | grep -q OPT_S=lalala,
	$< XX LOOL --opt-arg lalala | grep -q 'CMDLINE=--opt-arg lalala XX LOOL pos-default,'
	$< XX LOOL --opt-repeated w -r x --opt-repeated=y -rz | grep -q 'CMDLINE=--opt-repeated w -r x --opt-repeated=y -rz XX LOOL pos-default,'
	$< XX LOOL | grep -q 'POS_S1=,'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-wrapping-second_level.sh"
$(TESTDIR)/test-wrapping-second_level.sh: $(TESTDIR)/test-wrapping-second_level.m4 $(TESTDIR)/test-wrapping-single_level.sh $(TESTDIR)/test-onlyopt.m4 $(ARGBASH_BIN)
	$(ARGBASH_EXEC) $< -o $@

$(TESTDIR)/test-wrapping-single_level.sh: $(TESTDIR)/test-wrapping-single_level.m4 $(TESTDIR)/test-onlypos.m4 $(ARGBASH_BIN)
	$(ARGBASH_EXEC) $< -o $@

test-wrapping: $(TESTDIR)/test-wrapping.sh $(TESTDIR)/test-onlyopt.m4 $(TESTDIR)/test-onlypos.m4
	$< -h | grep -q opt-arg
	$< -h | grep -q pos-arg
	@# ! negates the return code
	! $< -h | grep -q boo_l
	@# no spaces as indentation (that test-onlyopt uses)
	! grep -q '^  ' $<
	grep -q '^		esac' $<
	$< XX LOOL | grep -q 'POS_S0=XX,POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL | grep -q 'POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL --opt-arg lalala | grep -q OPT_S=lalala,
	$< XX LOOL --opt-arg lalala | grep -q 'CMDLINE=--opt-arg lalala LOOL pos-default,'
	$< XX LOOL --opt-repeated w -r x --opt-repeated=y -rz | grep -q 'CMDLINE=--opt-repeated w -r x --opt-repeated=y -rz LOOL pos-default,'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-wrapping.sh"
$(TESTDIR)/test-wrapping-otherdir.sh: $(TESTDIR)/test-wrapping-otherdir.m4 $(TESTDIR)/otherdir/test-onlyopt.m4 $(TESTDIR)/otherdir/test-onlypos.m4 $(ARGBASH_BIN) $(ARGBASH_BIN)
	$(ARGBASH_EXEC) $< -o $@

test-wrapping-otherdir: $(TESTDIR)/test-wrapping-otherdir.sh
	$< -h | grep -q opt-arg
	$< -h | grep -q pos-arg
	@# ! negates the return code
	! $< -h | grep -q boo_l
	@# no spaces as indentation (that test-onlyopt uses)
	! grep -q '^  ' $<
	grep -q '^		esac' $<
	$< XX LOOL | grep -q 'POS_S0=XX,POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL | grep -q 'POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL --opt-arg lalala | grep -q OPT_S=lalala,
	$< XX LOOL --opt-arg lalala | grep -q 'CMDLINE=--opt-arg lalala LOOL pos-default,'
	$< XX LOOL --opt-repeated w -r x --opt-repeated=y -rz | grep -q 'CMDLINE=--opt-repeated w -r x --opt-repeated=y -rz LOOL pos-default,'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-wrapping-otherdir.sh"
$(TESTDIR)/otherdir/test-onlyopt.m4: $(TESTDIR)/test-onlyopt.m4
	mkdir -p $(TESTDIR)/otherdir && cp $< $@

$(TESTDIR)/otherdir/test-onlypos.m4: $(TESTDIR)/test-onlypos.m4
	mkdir -p $(TESTDIR)/otherdir && cp $< $@

test-wrapping-more: $(TESTDIR)/test-wrapping-more.sh $(TESTDIR)/test-onlyopt.m4
	$< -i -i -i | grep -q 'CMDLINE=-i -i -i,'
	$< -i -i | grep -q 'OPT_INCR=4,'
	ERROR="nexpected argument '--opt-arg'" $(REVERSE) $< --opt-arg lalala
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-wrapping-more.sh"
test-wrapping-excl: $(TESTDIR)/test-wrapping-excl.sh $(TESTDIR)/test-onlypos.m4
	$(_test_onlypos)
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-wrapping-excl.sh"
stability-wrapping: $(TESTDIR)/test-wrapping.sh $(TESTDIR)/test-wrapping2.sh
	diff -q $< $(word 2,$^)
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-wrapping.sh"
test-infinity-minimal_call: $(TESTDIR)/test-infinity-minimal_call.sh
	$< | grep -q 'POS_S='
	$< 1 | grep -q 'POS_S=1,'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-infinity-minimal_call.sh"
test-infinity: $(TESTDIR)/test-infinity.sh
	$< | grep -q 'POS_S=first,second,third,'
	$< 1 | grep -q 'POS_S=1,second,third,'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
	! grep -q handle_passed_args_count $<
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-infinity.sh"
test-infinity-nodefaults: $(TESTDIR)/test-infinity-nodefaults.sh
	ERROR="require at least 2" $(REVERSE) $<
	ERROR="namely: 'pos-arg' (2 times)" $(REVERSE) $<
	$< 1 "2 3" | grep -q 'POS_S=1,2 3'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
	grep -q handle_passed_args_count $<
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-infinity-nodefaults.sh"
test-infinity-mixed: $(TESTDIR)/test-infinity-mixed.sh
	$< -h | grep -q '<pos-arg-1> \[<pos-arg-2>\] \.\.\. \[<pos-arg-n>\] \.\.\.$$'
	ERROR="require at least 1" $(REVERSE) $<
	$< 1 | grep -q 'POS_S=1,first,second'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-infinity-mixed.sh"
test-leftovers: $(TESTDIR)/test-leftovers.sh
	$< -h | grep -q '\[-c|--cosi <arg>\] \[--(no-)fear\] \[-m|--more\] \[-h|--help\] <another> \.\.\. $$'
	$< -c ours -m --more --more --no-fear "ours pos" left "o ver" | grep -q 'MORE=3,OPT_S=ours,FEAR=off,POS_S=ours pos,LEFTOVERS=left,o ver,'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-leftovers.sh"
gen-test-infinity-dash: $(TESTDIR)/gen-test-infinity.m4 $(ARGBASH_BIN)
	ERROR="supported" $(REVERSE) $(ARGBASH_EXEC) --type posix-script $< > /dev/null
	ERROR="infinite" $(REVERSE) $(ARGBASH_EXEC) --type posix-script $< > /dev/null

gen-test-wrap-dash: $(TESTDIR)/gen-test-wrap.m4 $(ARGBASH_BIN)
	ERROR="supported" $(REVERSE) $(ARGBASH_EXEC) --type posix-script $< > /dev/null

gen-test-pos: $(TESTDIR)/gen-test-pos.m4 $(ARGBASH_BIN)
	ERROR="pos-arg" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-opt: $(TESTDIR)/gen-test-opt.m4 $(ARGBASH_BIN)
	ERROR="opt-arg" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-pos2: $(TESTDIR)/gen-test-pos2.m4 $(ARGBASH_BIN)
	ERROR="pos_arg" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-opt2: $(TESTDIR)/gen-test-opt2.m4 $(ARGBASH_BIN)
	ERROR="opt_arg" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-infinity-illegal: $(TESTDIR)/gen-test-infinity-illegal.m4 $(ARGBASH_BIN)
	ERROR="number of expected positional arguments before 'pos-arg' is unknown (because of argument 'pos-arg', which has a default)" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-bool-default: $(TESTDIR)/gen-test-bool-default.m4 $(ARGBASH_BIN)
	ERROR="'on' or 'off' are allowed as boolean defaults" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-pos-opt: $(TESTDIR)/gen-test-pos-opt.m4 $(ARGBASH_BIN)
	ERROR="same-arg" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-pos-opt2: $(TESTDIR)/gen-test-pos-opt2.m4 $(ARGBASH_BIN)
	ERROR="same_arg" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-more: $(TESTDIR)/gen-test-more.m4 $(ARGBASH_BIN)
	ERROR="is unknown" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-illegal-pos: $(TESTDIR)/gen-test-illegal-pos.m4 $(ARGBASH_BIN)
	ERROR="contains forbidden characters" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-illegal-opt: $(TESTDIR)/gen-test-illegal-opt.m4 $(ARGBASH_BIN)
	ERROR="one character" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-misspelled: $(TESTDIR)/gen-test-misspelled.m4 $(ARGBASH_BIN)
	ERROR="ARG_FOOBAR" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null
	ERROR="ARGBASH_GOO" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-unmatched_bracket: $(TESTDIR)/gen-test-unmatched_bracket.m4 $(ARGBASH_BIN)
	ERROR="unmatched square bracket on line 3" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null
	ERROR="# ARG_OPTIONAL_BOOLEAN(\[long\], l, \[)" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-badcall-multi: $(TESTDIR)/gen-test-badcall-multi.m4 $(ARGBASH_BIN)
	ERROR="3rd argument" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null
	ERROR="num of args" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null
	ERROR="actual number of" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

basic-docopt: $(TESTDIR)/basic.txt
	grep -q "\[<pos-opt>\]" $<
	grep -q "\[--opt_arg OPT_ARG\]" $<
	grep -q "\s-o OPT_ARG, --opt_arg OPT_ARG\s" $<
	! test -x $<

test-onlyopt-docopt: $(TESTDIR)/test-onlyopt.txt
	grep -q "\[--opt-repeated OPT-REPEATED\]\.\.\." $<
	grep -q "\[--incrx\]\.\.\." $<

test-delim-space: $(TESTDIR)/test-delim-space.sh
	ERROR="unexpected argument '--opt=something'" $(REVERSE) $< --opt=something
	$< --opt something | grep -q 'OPT_S=something,'
	ERROR="unexpected argument '--add=three'" $(REVERSE) $< -a one --add two --add=three
	$< -a one --add two | grep -q 'OPT_REP=one two,'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-delim-space.sh"
test-delim-equals: $(TESTDIR)/test-delim-equals.sh
	ERROR="unexpected argument '--opt'" $(REVERSE) $< --opt something
	$< --opt=something | grep -q 'OPT_S=something,'
	$< --xxx | grep -q 'XXX=on,'
	ERROR="unexpected argument '--add'" $(REVERSE) $< -a one --add two --add=three
	$< -a one --add=two | grep -q 'OPT_REP=one two,'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-delim-equals.sh"
test-delim-both: $(TESTDIR)/test-delim-both.sh
	$< --opt something | grep -q 'OPT_S=something,'
	$< --opt=something | grep -q 'OPT_S=something,'
	$< -a one --add two --add=three | grep -q 'OPT_REP=one two three'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-delim-both.sh"
test-init_simple: $(TESTDIR)/test-init_simple.sh
	ERROR="[Nn]ot enough" $(REVERSE) $<
	$< foo | grep -q "'pos': foo"
	$< foo --opt bar | grep -q " --opt: bar"
	$< foo --opt bar | grep -q "'boo' is off"
	$< foo --opt bar --opt2 baz | grep -q " --opt: bar"
	$< foo --opt bar --opt2 baz | grep -q " --opt2: baz"
	$< foo --opt bar --opt2 baz --boo | grep -q "'boo' is on"
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-init_simple.sh"
test-init_simple-s: $(TESTDIR)/test-init_simple-s.sh
	ERROR="[Nn]ot enough" $(REVERSE) $<
	$< foo | grep -q "'pos': foo"
	$< foo --opt bar | grep -q " --opt: bar"
	$< foo --opt bar | grep -q "'boo' is off"
	$< foo --opt bar --opt2 baz | grep -q " --opt: bar"
	$< foo --opt bar --opt2 baz | grep -q " --opt2: baz"
	$< foo --opt bar --opt2 baz --boo | grep -q "'boo' is on"
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-init_simple-s.sh"
test-init_simple-ss: $(TESTDIR)/test-init_simple-ss.sh $(TESTDIR)/test-init_simple-ss-parsing.sh
	ERROR="[Nn]ot enough" $(REVERSE) $<
	$< foo | grep -q "'pos': foo"
	$< foo --opt bar | grep -q " --opt: bar"
	$< foo --opt bar | grep -q "'boo' is off"
	$< foo --opt bar --opt2 baz | grep -q " --opt: bar"
	$< foo --opt bar --opt2 baz | grep -q " --opt2: baz"
	$< foo --opt bar --opt2 baz --boo | grep -q "'boo' is on"
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-init_simple-ss.sh"
$(TESTDIR)/test-init_simple.m4: $(ARGBASH_INIT)
	$(ARGBASH_INIT_EXEC) --pos pos --opt opt2 --opt opt --opt-bool boo $@

$(TESTDIR)/test-init_simple-s.m4: $(ARGBASH_INIT)
	$(ARGBASH_INIT_EXEC) --pos pos --opt opt2 --opt opt --opt-bool boo -s $@
	sed -i '2 s|^|# shellcheck source=$(basename $@)-parsing.sh\n|' $@

$(TESTDIR)/regenerate-test-init_simple-s-update.m4:
	touch $@

$(TESTDIR)/test-init_simple-s-update.m4: $(ARGBASH_INIT) $(TESTDIR)/regenerate-test-init_simple-s-update.m4
	$(ARGBASH_INIT_EXEC) --opt ordnung -s $@ > /dev/null
	sed -i '2 s|^|# shellcheck source=$(basename $@)-parsing.sh\n|' $@
	sed -i 's/^echo .*//' $@
	echo 'test "$$_arg_ordnung" = yes || exit 1' >> $@

test-init_simple-s-update: $(TESTDIR)/test-init_simple-s-update.sh
	@# Regenerate everyting during the next test run
	touch $(TESTDIR)/regenerate-test-init_simple-s-update.m4
	$< --ordnung yes > /dev/null
	$(REVERSE) $< > /dev/null
	ERROR="unexpected argument" $(REVERSE) $< -o yes > /dev/null
	sed -i 's/\[ordnung\]/&,[o]/' $(TESTDIR)/test-init_simple-s-update-parsing.sh
	$(ARGBASH_BIN) $< > /dev/null
	$< --ordnung yes > /dev/null
	$(REVERSE) $< > /dev/null
	$< -o yes > /dev/null
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-init_simple-s-update.sh"
$(TESTDIR)/test-init_simple-ss.sh: $(ARGBASH_INIT)
	$(ARGBASH_INIT_EXEC) --pos pos --opt opt2 --opt opt --opt-bool boo -s -s $@
	sed -i '2 s|^|# shellcheck source=$(basename $@)-parsing.sh\n|' $@

$(TESTDIR)/test-init_simple-ss-parsing.m4: $(TESTDIR)/test-init_simple-ss.sh
	@

$(TESTDIR)/gen-test-init_name_char.m4: $(ARGBASH_INIT)
	$(ARGBASH_INIT_EXEC) --opt-bool foo/bar-baz $@

$(TESTDIR)/gen-test-init_name_dash.m4: $(ARGBASH_INIT)
	$(ARGBASH_INIT_EXEC) --pos -bool $@

gen-test-init_name_dash: $(TESTDIR)/gen-test-init_name_dash.m4 $(ARGBASH_BIN)
	ERROR="'-bool' .* begins with a dash" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

gen-test-init_name_char: $(TESTDIR)/gen-test-init_name_char.m4 $(ARGBASH_BIN)
	ERROR="'foo/bar-baz' .* contains forbidden characters" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

test-env-base: $(TESTDIR)/test-env-base.sh
	$< | grep -q 'ENVI_FOO=def,ault,'
	$< | grep -q 'ENVI_BAR=,'
	ENVI_FOO=something $< | grep -q 'ENVI_FOO=something'
	$< -h | grep -q "ENVI_FOO: A sample env, variable. (default: 'def,ault')"
	$< -h | grep -q "ENVI_BAR: A sample env, variable."
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-env-base.sh"
test-env-simple: $(TESTDIR)/test-env-simple.sh
	$< | grep -q 'ENVI_FOO=def,ault,'
	! $< -h | grep -q 'ENVI_FOO'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-env-simple.sh"
test-int: $(TESTDIR)/test-int.sh
	$< 1 | grep -q "POS_S=1,"
	ERROR="integer" $(REVERSE) $< a
	ERROR="integer" $(REVERSE) $< 1.5
	$< 1 --int 2 | grep -q "OPT_S=2,"
	ERROR="integer" $(REVERSE) $< 1 --int b
	$< 01 | grep -q "POS_S=1,"
	$< +1 | grep -q "POS_S=1,"
	$< -1 | grep -q "POS_S=-1,"
	$< -1776 | grep -q "POS_S=-1776,"
	$< -h | grep -q "INT"
	$< -h | grep -q "INT+0"
	$< -h | grep -q "INT+"
	$< 1 --nnint 2 | grep -q "NN=2,"
	$< 1 --pint 2 | grep -q "P=2,"
	ERROR="positive" $(REVERSE) $< 1 --pint 0
	ERROR="negative" $(REVERSE) $< 1 --nnint -1
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-int.sh"
test-group: $(TESTDIR)/test-group.sh
	$< foo | grep -q "ACT=foo"
	$< '' | grep -q "ACT="
	$< foo,baz | grep -q "ACT=foo,baz,"
	$< "bar bar" | grep -q "ACT=bar bar,"
	ERROR="allowed" $(REVERSE) $< fuuuu
	ERROR="allowed" $(REVERSE) $< bar
	@# Assure that there is not the string '_idx' in the script since we don't want indices support in this test
	! grep -q _idx $<
	$< -h | grep act-ion | grep -q "'foo,baz'"
	$< -h | grep act-ion | grep -q "'bar bar'"
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-group.sh"
test-group-idx: $(TESTDIR)/test-group-idx.sh
	$< foo | grep -q "ACT=foo,IDX=0,"
	$< foo,baz | grep -q "ACT=foo,baz,IDX=3,"
	$< "bar bar" | grep -q "ACT=bar bar,IDX=2,"
	ERROR="allowed" $(REVERSE) $< "bar bar" --repeated bar
	! $< "bar bar" --repeated "bar bar" | grep -q "IDX3=2," > /dev/null
	$< "bar bar" --opt-tion "bar bar" | grep -q "IDX2=2," > /dev/null
	ERROR="allowed" $(REVERSE) $< fuuuu
	ERROR="allowed" $(REVERSE) $< bar
	# $< -h | grep action | grep ACTION | grep -q 'foo,baz'
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-group-idx.sh"
$(TESTDIR)/gen-test-group-wrong.m4: $(TESTDIR)/test-group.m4
	sed -e 's/repeated],/foo,&/' $< > $@

gen-test-group-wrong: $(TESTDIR)/gen-test-group-wrong.m4 $(ARGBASH_BIN)
	ERROR="'foo' is not a script argument" $(REVERSE) $(ARGBASH_EXEC) $< > /dev/null

$(TESTDIR)/test-semi_strict.sh: $(TESTDIR)/test-simple.m4 $(ARGBASH_BIN)
	printf "%s\n%s\n" "#!/bin/bash" "# ARG_RESTRICT_VALUES([no-local-options])" | cat - $< | $(ARGBASH_BIN) -o $(@) -
$(TESTDIR)/test-very_strict.sh: $(TESTDIR)/test-simple.m4 $(ARGBASH_BIN)
	printf "%s\n%s\n" "#!/bin/bash" "# ARG_RESTRICT_VALUES([no-any-options])" | cat - $< | $(ARGBASH_BIN) -o $(@) -
test-semi_strict: $(TESTDIR)/test-semi_strict.sh
	$< -o -x pos-arg | grep -q 'OPT_S=-x,'
	$< -o --opt-argx pos-arg | grep -q 'OPT_S=--opt-argx,'
	ERROR="omitted the actual value" $(REVERSE) $< -o -o pos-arg
	ERROR="omitted the actual value" $(REVERSE) $< -o -ofoo pos-arg
	ERROR="omitted the actual value" $(REVERSE) $< -o --prefix
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-semi_strict.sh"
test-very_strict: $(TESTDIR)/test-very_strict.sh
	ERROR="are trying to pass an option" $(REVERSE) $< -o -x pos-arg
	ERROR="are trying to pass an option" $(REVERSE) $< -o -o pos-arg
	ERROR="are trying to pass an option" $(REVERSE) $< -x
	ERROR="are trying to pass an option" $(REVERSE) $< --foobar
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-very_strict.sh"
$(TESTDIR)/test-getopt-equals.sh: $(TESTDIR)/test-onlyopt.m4 $(ARGBASH_BIN)
	printf "%s\n%s\n%s\n" "#!/bin/bash" "# ARGBASH_SET_DELIM([=])" "# ARG_OPTION_STACKING([getopt])" | cat - $< | $(ARGBASH_BIN) -o $(@) -
$(TESTDIR)/test-getopt-both.sh: $(TESTDIR)/test-onlyopt.m4 $(ARGBASH_BIN)
	printf "%s\n%s\n%s\n" "#!/bin/bash" "# ARGBASH_SET_DELIM([ =])" "# ARG_OPTION_STACKING([getopt])" | cat - $< | $(ARGBASH_BIN) -o $(@) -
$(TESTDIR)/test-getopt-space.sh: $(TESTDIR)/test-onlyopt.m4 $(ARGBASH_BIN)
	printf "%s\n%s\n%s\n" "#!/bin/bash" "# ARGBASH_SET_DELIM([ ])" "# ARG_OPTION_STACKING([getopt])" | cat - $< | $(ARGBASH_BIN) -o $(@) -
test-getopt-both: $(TESTDIR)/test-getopt-both.sh
	$< -ii | grep -q 'OPT_INCR=4,'
	$< --incrx -ii | grep -q 'OPT_INCR=5,'
	$< -Bi | grep 'OPT_INCR=3,' | grep -q 'BOOL=on,'
	$< -Bio bu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Biobu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Boibu | grep 'BOOL=on,' | grep 'OPT_INCR=2,' | grep -q 'OPT_S=ibu,'
	ERROR="'-Bfoo' can't be decomposed to -B and -foo, because -B doesn't accept value and '-f' doesn't correspond to a short option" $(REVERSE) $< -Bfoo
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-getopt-both.sh"
test-getopt-space: $(TESTDIR)/test-getopt-space.sh
	$< -ii | grep -q 'OPT_INCR=4,'
	$< --incrx -ii | grep -q 'OPT_INCR=5,'
	$< -Bi | grep 'OPT_INCR=3,' | grep -q 'BOOL=on,'
	$< -Bio bu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Biobu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Boibu | grep 'BOOL=on,' | grep 'OPT_INCR=2,' | grep -q 'OPT_S=ibu,'
	ERROR="'-Bfoo' can't be decomposed to -B and -foo, because -B doesn't accept value and '-f' doesn't correspond to a short option" $(REVERSE) $< -Bfoo
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-getopt-space.sh"
test-getopt-equals: $(TESTDIR)/test-getopt-equals.sh
	$< -ii | grep -q 'OPT_INCR=4,'
	$< --incrx -ii | grep -q 'OPT_INCR=5,'
	$< -Bi | grep 'OPT_INCR=3,' | grep -q 'BOOL=on,'
	$< -Bio bu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Biobu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Boibu | grep 'BOOL=on,' | grep 'OPT_INCR=2,' | grep -q 'OPT_S=ibu,'
	ERROR="'-Bfoo' can't be decomposed to -B and -foo, because -B doesn't accept value and '-f' doesn't correspond to a short option" $(REVERSE) $< -Bfoo
	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "$(TESTDIR)/test-getopt-equals.sh"
tests-gen: $(TESTS_GEN)

tests-clean:
	$(RM) $(SCRIPTS)
	rmdir $(TESTDIR)/otherdir

.PHONY: $(PHONIES)
