dnl And stop those annoying diversion warnings
m4_for([idx], 1, 4, 1,
	[m4_define([_m4_divert(STDOUT]idx[)], idx)])


m4_define([TEST_BODY], [m4_foreach([arg], [$@], [	arg
])])


dnl
dnl Use in the case that some test produce scripts as side-effect
dnl $1: The script stem (preppend $(TESTDIR)/), append suffix (.$2)
dnl $2: The suffix, (optional, by default 'sh')
m4_define([ADD_SCRIPT],
	[m4_set_add([_TEST_SCRIPTS], [$(TESTDIR)/$1.]m4_default([$2], [sh]))])


dnl
dnl Use in the case that you need a rule without registering a test
dnl $1: What
dnl $2: deps
dnl $3: body
m4_define([ADD_RULE], [m4_do(
	[m4_set_add([_TEST_SCRIPTS], [$1])]
	[m4_divert_text([STDOUT3], [m4_do(
		[$1: $2],
		[
	],
		[$3],
	)])],
)])

dnl
dnl Use in the case that you need a rule without registering a test
dnl We assume that the input is .m4, output .sh and argbash is used to create it.
dnl $1: Target basename (without the .sh extension that is assumed)
dnl $2: deps (without the .m4 template that is deduced from the basename)
dnl $3: body
m4_define([ADD_ARGBASH_RULE], [ADD_RULE(
	[$1.sh], [$1.m4 $2 $(ARGBASH_BIN)], [$3])])


dnl
dnl $1: The test name
dnl $2: The test body (see also: TEST_BODY)
dnl $3: The other deps (literal, feel free to use the | delimiter)
dnl $4: The first dep (default: $(TESTDIR)/<name>.txt)
dnl
dnl Remarks:
dnl No leading/trailing newlines, around the test body as it already has those.
m4_define([ADD_DOCOPT_TEST], [m4_do(
	[m4_pushdef([_script], m4_default_quoted([$4], [$(TESTDIR)/$1.txt]))],
	[m4_pushdef([_testname], [[$1-docopt]])],
	[m4_set_add([DOCOPT_TESTS], _testname)],
	[m4_set_add([_TEST_DOCOPT_SCRIPTS], m4_quote(_script))],
	[m4_divert_text([STDOUT3], [m4_do(
		_testname[: _script[]m4_ifnblank([$3], [ $3])],
		[$2],
	)])],
	[m4_popdef([_testname])],
	[m4_popdef([_script])],
)])


dnl
dnl $1: The test name
dnl $2: The test body (see also: TEST_BODY)
dnl $3: The other deps (literal, feel free to use the | delimiter)
dnl $4: The first dep (default: $(TESTDIR)/<name>.sh)
dnl $5: The suffix of the test script basename
dnl $6: Prefix of the _TESTS make variable and _TEST_..._SCRIPTS
dnl
dnl Remarks:
dnl No leading/trailing newlines, around the test body as it already has those.
m4_define([ADD_TEST], [m4_do(
	[m4_pushdef([_script], m4_default_quoted([$4], [$(TESTDIR)/$1$5.sh]))],
	[m4_set_add([$6_TESTS], [$1])],
	[m4_set_add([_TEST_$6_SCRIPTS], m4_quote(_script))],
	[m4_divert_text([STDOUT3], [m4_do(
		[$1: _script[]m4_ifnblank([$3], [ $3])],
		[$2],
		[	test -z "$(SHELLCHECK)" || $(SHELLCHECK) "_script"],
	)])],
	[m4_popdef([_script])],
)])


dnl
dnl $1: The test name
dnl $2: The test body (see also: TEST_BODY)
dnl $3: The other deps (literal, feel free to use the | delimiter)
dnl $4: The first dep (default: $(TESTDIR)/<name>.sh)
m4_define([ADD_TEST_BASH], [ADD_TEST([$1], [$2], [$3], [$4], [], [BASH])])


dnl
dnl $1: The test name
dnl $2: The test body (see also: TEST_BODY)
dnl $3: The other deps (literal, feel free to use the | delimiter)
dnl $4: The first dep (default: $(TESTDIR)/<name>.sh)
m4_define([ADD_TEST_DASH], [ADD_TEST([$1-dash], [$2], [$3], [$4], [], [DASH])])


dnl
dnl $1: The test stem (gen-test-<stem>.m4)
dnl $2: The script suffix
dnl $3: The output type
dnl $4: The gentest type
dnl $5, $6, ...: The test error (optional, if the test is not supposed to throw errors, pass just $1 and leave others blank)
m4_define([ADD_GENTEST], [m4_do(
	[m4_pushdef([_tname], [[gen-test-$1]]m4_ifnblank([$2], [[[-$2]]]))],
	[m4_divert_text([STDOUT3], [m4_do(
		[_tname: $(TESTDIR)/gen-test-$1.m4 $(ARGBASH_BIN)
],
		[m4_ifblank([$5], [	$(ARGBASH_EXEC) m4_ifnblank([$3], [--type $3 ])$< > /dev/null
],
			[m4_foreach([_errmsg], [m4_shiftn(4, $@)],
				[	ERROR="_errmsg" $(REVERSE) $(ARGBASH_EXEC) m4_ifnblank([$3], [--type $3 ])$< > /dev/null
])])],
	)])],
	[m4_set_add([_TEST_GEN_$4], _tname)],
)])


m4_define([ADD_GENTEST_BASH],
	[ADD_GENTEST([$1], [], [],
		[BASH], m4_shift($@))])

m4_define([ADD_GENTEST_DASH],
	[ADD_GENTEST([$1], [dash], [posix-script],
		[DASH], m4_shift($@))])
