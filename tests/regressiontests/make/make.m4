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
dnl $1: The test name
dnl $2: The test body (see also: TEST_BODY)
dnl $3: The other deps (literal, feel free to use the | delimiter)
dnl $4: The first dep (default: $(TESTDIR)/<name>.sh)
m4_define([ADD_TEST], [m4_do(
	[m4_pushdef([_script], m4_default_quoted([$4], [$(TESTDIR)/$1.sh]))],
	[m4_set_add([_TESTS], [$1])],
	[m4_set_add([_TEST_SCRIPTS], m4_quote(_script))],
	[m4_divert_text([STDOUT3], [m4_do(
		[$1: _script[]m4_ifnblank([$3], [ $3])],
		[$2],
	)])],
	[m4_popdef([_script])],
)])
dnl $2:
dnl No leading newline, because the test body definition has one
dnl No trailing newline because the test body already has it


dnl 
dnl $1: The test stem (gen-test-<stem>.m4)
dnl $2: The test error
m4_define([ADD_GENTEST], [m4_do(
	[m4_pushdef([_tname], [gen-test-$1])],
	[m4_divert_text([STDOUT3], [m4_do(
		[_tname: $(TESTDIR)/gen-test-$1.m4 $(ARGBASH_BIN)],
		[
	],
		[m4_ifnblank([$2], [ERROR="$2" $(REVERSE) ])$(ARGBASH_BIN) $< > /dev/null],
		[
],
	)])],
	[m4_set_add([_TEST_GEN], m4_quote(_tname))],
)])
