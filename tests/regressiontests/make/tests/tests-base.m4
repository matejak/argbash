ADD_SCRIPT([basic2])
ADD_TEST_BASH([stability], [[
	diff -q $< $(word 2,$^)
]], [$(TESTDIR)/basic2.sh], [$(TESTDIR)/basic.sh])

ADD_TEST_BASH([basic], [[
	$(generic_regression_posix)
	$(generic_regression_gnu_only)
	$< -h | grep -q 'P percent: %'
	$< -h | grep -q 'O percent: %'
	! $< -h | grep -qe '\[--\]'
]])


ADD_TEST_DASH([basic], [[
	$(generic_regression_posix)
	$< LOO -b | grep -q BOOL=off,
	$< -h | grep -q 'P percent: %'
	$< -h | grep -q 'O percent: %'
	$< -h | grep -qe '\[--\]'
]])


ADD_TEST_BASH([test-void], [[
	! grep -q 'die' $<
]])

ADD_SCRIPT([test-salone])
#  the dependency $(TESTDIR)/test-standalone.sh should be assumed
ADD_TEST_BASH([call-salone], [[
	$(generic_regression_posix)
	$(generic_regression_gnu_only)
]])

ADD_TEST_BASH([test-most], [[
	$< -h | grep -q '<pos-more1-1> <pos-more1-2> \[<pos-more2-1>\] \[<pos-more2-2>\]'
	$< xx yy | grep -q "POS_MORE1=xx yy,POS_MORE2=hu lu,"
	$< xx yy zz aa | grep -q "POS_MORE1=xx yy,POS_MORE2=zz aa,"
	$< -h | grep -q '<pos-more1-1> <pos-more1-2> \[<pos-more2-1>\] \[<pos-more2-2>\]'
	$< -h | grep -q '<pos-more1>: @pos-more1-arg@'
	$< -h | grep -q "<pos-more2>: @pos-more2-arg@ (defaults for <pos-more2-1> to <pos-more2-2> respectively: 'hu' and 'lu')"
]])

ADD_TEST_BASH([test-more], [[
	$< LOO x | grep -q "POS_S=LOO,POS_MORE=x f\[o\]o ba,r,"
	$< LOO lul laa | grep -q "POS_S=LOO,POS_MORE=lul laa ba,r,"
	$< LOO laa bus kus | grep -q "POS_S=LOO,POS_MORE=laa bus kus",
	ERROR="namely: 'pos-arg' and 'pos-more'" $(REVERSE) $<
	grep -q '^		_positionals' $<
]])


ADD_TEST_BASH([test-onlypos], [[
	$(_test_onlypos)
	! grep -q '^_arg_pos_arg=$$' $<
]])


ADD_TEST_BASH([test-onlypos-declared], [[
	$(_test_onlypos)
	grep -q '^_arg_pos_arg=$$' $<
]])


m4_define([test_onlyopt_posix_body], [[
	grep -q '^    esac$$' $<
	@# ! negates the return code
	! grep -q '^	' $<
	$(REVERSE) grep -q POSITION $<
	$< -o "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< -B | grep -q 'BOOL=on'
	$< -i | grep -q 'OPT_INCR=3,'
	$< -i -i | grep -q 'OPT_INCR=4,'
	! $< -h | grep -q -e '-B,'
	$(REVERSE) $< LOO 2> /dev/null]])


ADD_TEST_BASH([test-onlyopt], [test_onlyopt_posix_body
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
])

dnl TODO: The error that occurs when supplied with positional arg needs fixing.
ADD_TEST_DASH([test-onlyopt], [test_onlyopt_posix_body
	$< -h | grep -q -e '-B'
	$< -h | grep -q -e '-i'
	$< -h | grep -q -e '-o <arg>'
	$< -h | grep -q -e '-o: @opt-arg@'
	! $< -h | grep -q -e '-r'
	ERROR=cosi $(REVERSE) $< -o lala cosi
])

ADD_SCRIPT([test-standalone2])
ADD_TEST_BASH([stability-salone], [[
	diff -q $< $(word 2,$^)
]],
	[$(TESTDIR)/test-standalone2.sh], [$(TESTDIR)/test-standalone.sh])

ADD_RULE([$(TESTDIR)/test-ddash.m4], [$(TESTDIR)/test-ddash-old.m4 $(ARGBASH_1TO2)],
	[$(ARGBASH_1TO2) $< -o $@
])

ADD_TEST_BASH([test-ddash], [[
	$< --boo_l | grep -q 'BOOL=on,'
	$< -- --boo_l | grep -q 'BOOL=off,'
	$< -- --boo_l | grep -q 'POS_OPT=--boo_l,'
	$< -- --help | grep -q 'POS_OPT=--help,'
	$< -- | grep -q 'POS_OPT=pos-default,'
	$< -- --| grep -q 'POS_OPT=--,'
	ERROR=spurious 	$(REVERSE) $< -- foo bar
	ERROR=bar 	$(REVERSE) $< -- foo bar
]])


m4_define([test_simple_body], [[
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
	grep -q '^			\*@:}@' $<
	ERROR=spurious 	$(REVERSE) $< -- one two
	ERROR="last one was: 'two'" 	$(REVERSE) $< one two
	ERROR="expect exactly 1" 	$(REVERSE) $< one two
	ERROR="[Nn]ot enough" 	$(REVERSE) $<
	ERROR="require exactly 1" 	$(REVERSE) $<]])


ADD_TEST_BASH([test-simple], [test_simple_body
	$< pos -o 'uf ta' | grep -q 'OPT_S=uf ta,POS_S=pos,'
])

ADD_TEST_DASH([test-simple], [test_simple_body
	ERROR="got 3" $(REVERSE) $< -- -o 'uf ta' pos
	ERROR="got 3" $(REVERSE) $< pos -o 'uf ta'
	ERROR="last one was: 'uf ta'" $(REVERSE) $< pos -o 'uf ta'
])

dnl The invocation like this is supposed to trigger complaints
ADD_TEST_BASH([test-diy-noop], [[
	$< LOO --opt_arg > /dev/null
	$< LOO 1 2 3 3 > /dev/null
	$< > /dev/null
]])

ADD_RULE([$(TESTDIR)/test-diy-noop.m4], [$(TESTDIR)/basic.m4],
	[[sed -e 's/ARGBASH_GO/ARGBASH_PREPARE/' $< > $@
]])
ADD_SCRIPT([test-diy-noop], [m4])

ADD_RULE([$(TESTDIR)/test-diy-noop.sh], [$(TESTDIR)/test-diy-noop.m4],
	[[$(ARGBASH_BIN) -c -o "$@" "$<"
]])

dnl This is the body of test-simple
ADD_TEST_BASH([test-diy], [[
	$(generic_regression_posix)
	$(generic_regression_gnu_only)
]])

dnl Use comments in test-diy-noop.sh to generate the actual commands to parse args. .
ADD_RULE([$(TESTDIR)/test-diy.m4], [$(TESTDIR)/test-diy-noop.m4 $(TESTDIR)/test-diy-noop.sh],
	[[sed -e "s/#.*\@<:@$$/&\n$$(grep -e '#  \S' "$(TESTDIR)/test-diy-noop.sh" | sed -e 's/^#  //' | tr '\n' ';')/" $< > $@
]])
ADD_SCRIPT([test-diy], [m4])


m4_define([test_wrapping_body_base], [[[
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
]]])

m4_define([test_wrapping_body], m4_dquote(m4_do(
	[test_wrapping_body_base],
	[[	$< XX LOOL --opt-arg lalala | grep -q 'CMDLINE=--opt-arg lalala LOOL pos-default,'
]],
	[[	$< XX LOOL --opt-repeated w -r x --opt-repeated=y -rz | grep -q 'CMDLINE=--opt-repeated w -r x --opt-repeated=y -rz LOOL pos-default,'
]],
	)))

ADD_TEST_BASH([test-wrapping-second_level], [m4_do(
	test_wrapping_body_base,
	[[	$< XX LOOL --opt-arg lalala | grep -q 'CMDLINE=--opt-arg lalala XX LOOL pos-default,'
]],
	[[	$< XX LOOL --opt-repeated w -r x --opt-repeated=y -rz | grep -q 'CMDLINE=--opt-repeated w -r x --opt-repeated=y -rz XX LOOL pos-default,'
]],
	[[	$< XX LOOL | grep -q 'POS_S1=,'
]],
	)])

ADD_ARGBASH_RULE([$(TESTDIR)/test-wrapping-second_level],
	[$(TESTDIR)/test-wrapping-single_level.sh $(TESTDIR)/test-onlyopt.m4],
	[[$(ARGBASH_EXEC) $< -o $@
]])

ADD_SCRIPT([test-wrapping-single_level])
ADD_ARGBASH_RULE([$(TESTDIR)/test-wrapping-single_level],
	[$(TESTDIR)/test-onlypos.m4],
	[[$(ARGBASH_EXEC) $< -o $@
]])
ADD_SCRIPT([otherdir/test-onlyopt], [m4])

ADD_TEST_BASH([test-wrapping], test_wrapping_body,
[$(TESTDIR)/test-onlyopt.m4 $(TESTDIR)/test-onlypos.m4])

ADD_ARGBASH_RULE([$(TESTDIR)/test-wrapping-otherdir],
	[$(TESTDIR)/otherdir/test-onlyopt.m4 $(TESTDIR)/otherdir/test-onlypos.m4 $(ARGBASH_BIN)],
	[[$(ARGBASH_EXEC) $< -o $@
]])

ADD_TEST_BASH([test-wrapping-otherdir], test_wrapping_body)

ADD_RULE([$(TESTDIR)/otherdir/test-onlyopt.m4], [$(TESTDIR)/test-onlyopt.m4],
	[[mkdir -p $(TESTDIR)/otherdir && cp $< $@
]])
ADD_SCRIPT([otherdir/test-onlyopt], [m4])

ADD_RULE([$(TESTDIR)/otherdir/test-onlypos.m4], [$(TESTDIR)/test-onlypos.m4],
	[[mkdir -p $(TESTDIR)/otherdir && cp $< $@
]])
ADD_SCRIPT([otherdir/test-onlypos], [m4])

ADD_TEST_BASH([test-wrapping-more], [[
	$< -i -i -i | grep -q 'CMDLINE=-i -i -i,'
	$< -i -i | grep -q 'OPT_INCR=4,'
	ERROR="nexpected argument '--opt-arg'" $(REVERSE) $< --opt-arg lalala
]], [$(TESTDIR)/test-onlyopt.m4])

ADD_TEST_BASH([test-wrapping-excl], [[
	$(_test_onlypos)
]], [$(TESTDIR)/test-onlypos.m4])

ADD_SCRIPT([test-wrapping2])
ADD_TEST_BASH([stability-wrapping], [[
	diff -q $< $(word 2,$^)
]],
	[$(TESTDIR)/test-wrapping2.sh], [$(TESTDIR)/test-wrapping.sh])


m4_define([test_body], [[
	$< | grep -q 'POS_S='
	$< 1 | grep -q 'POS_S=1,'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
]])

ADD_TEST_BASH([test-infinity-minimal_call], [test_body])
dnl ADD_TEST_BASH([test-infinity-minimal_call-dash], [test_body])

ADD_TEST_BASH([test-infinity], [[
	$< | grep -q 'POS_S=first,second,third,'
	$< 1 | grep -q 'POS_S=1,second,third,'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
	! grep -q handle_passed_args_count $<
]])

ADD_TEST_BASH([test-infinity-nodefaults], [[
	ERROR="require at least 2" $(REVERSE) $<
	ERROR="namely: 'pos-arg' (2 times)" $(REVERSE) $<
	$< 1 "2 3" | grep -q 'POS_S=1,2 3'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
	grep -q handle_passed_args_count $<
]])

ADD_TEST_BASH([test-infinity-mixed], [[
	$< -h | grep -q '<pos-arg-1> \[<pos-arg-2>\] \.\.\. \[<pos-arg-n>\] \.\.\.$$'
	ERROR="require at least 1" $(REVERSE) $<
	$< 1 | grep -q 'POS_S=1,first,second'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
]])

ADD_TEST_BASH([test-leftovers], [[
	$< -h | grep -q '\[-c|--cosi <arg>\] \[--(no-)fear\] \[-m|--more\] \[-h|--help\] <another> \.\.\. $$'
	$< -c ours -m --more --more --no-fear "ours pos" left "o ver" | grep -q 'MORE=3,OPT_S=ours,FEAR=off,POS_S=ours pos,LEFTOVERS=left,o ver,'
]])

ADD_GENTEST_DASH([infinity], [supported], [infinite])
ADD_GENTEST_DASH([wrap], [supported])
ADD_GENTEST_BASH([pos], [pos-arg])
ADD_GENTEST_BASH([opt], [opt-arg])
ADD_GENTEST_BASH([pos2], [pos_arg])
ADD_GENTEST_BASH([opt2], [opt_arg])
ADD_GENTEST_BASH([infinity-illegal], [number of expected positional arguments before 'pos-arg' is unknown (because of argument 'pos-arg', which has a default)])
ADD_GENTEST_BASH([bool-default], ['on' or 'off' are allowed as boolean defaults])
ADD_GENTEST_BASH([pos-opt], [same-arg])
ADD_GENTEST_BASH([pos-opt2], [same_arg])
ADD_GENTEST_BASH([more], [is unknown])
ADD_GENTEST_BASH([illegal-pos], [contains forbidden characters])
ADD_GENTEST_BASH([illegal-opt], [one character])
ADD_GENTEST_BASH([misspelled], [ARG_FOOBAR], [ARGBASH_GOO])
dnl We have to escape \[ -> \@<:@ for grep
ADD_GENTEST_BASH([unmatched_bracket], [unmatched square bracket on line 3], [[# ARG_OPTIONAL_BOOLEAN(\[long\], l, \@<:@)]])
ADD_GENTEST_BASH([badcall-multi], [3rd argument], [num of args], [actual number of])
