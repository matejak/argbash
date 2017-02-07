m4_pushdef([tbody], [[[
	ERROR="[Nn]ot enough" $(REVERSE) $<
	$< foo | grep -q "pos: foo"
	$< foo --opt bar | grep -q " --opt: bar"
	$< foo --opt bar | grep -q "boo is off"
	$< foo --opt bar --opt2 baz | grep -q " --opt: bar"
	$< foo --opt bar --opt2 baz | grep -q " --opt2: baz"
	$< foo --opt bar --opt2 baz --boo | grep -q "boo is on"
]]])


ADD_TEST([test-init_simple], tbody)
ADD_TEST([test-init_simple-s], tbody)
ADD_TEST([test-init_simple-ss], tbody, [$(TESTDIR)/test-init_simple-ss-parsing.sh])


ADD_SCRIPT([test-init_simple])
ADD_RULE([$(TESTDIR)/test-init_simple.m4], [$(ARGBASH_INIT)],
	[$< --pos pos --opt opt2 --opt opt --opt-bool boo $@
])

ADD_SCRIPT([test-init_simple-s])
ADD_SCRIPT([test-init_simple-s-parsing])
ADD_SCRIPT([test-init_simple-s-parsing], [m4])
ADD_RULE([$(TESTDIR)/test-init_simple-s.m4], [$(ARGBASH_INIT)],
	[$< --pos pos --opt opt2 --opt opt --opt-bool boo -s $@
])

dnl
dnl Add a test that checks that updates to the parsing functionality are applied
dnl First, create a script that succeeds if --ordnung yes is passed
dnl Then, add an abbrev in the parsing code and see it again
ADD_SCRIPT([regenerate-test-init-simple-s-update], [m4])
ADD_SCRIPT([test-init_simple-s-update-parsing])
ADD_SCRIPT([test-init_simple-s-update-parsing], [m4])

dnl Take out all echos (argbash-init puts them there) so that we don't have to discard stdout.
ADD_RULE([$(TESTDIR)/regenerate-test-init_simple-s-update.m4], [],
	[touch $@
])

dnl Take out all echos (argbash-init puts them there) so that we don't have to discard stdout.
ADD_RULE([$(TESTDIR)/test-init_simple-s-update.m4], [$(ARGBASH_INIT) $(TESTDIR)/regenerate-test-init_simple-s-update.m4],
	[$< --opt ordnung -s $@
	sed -i 's/^echo .*//' $@
	echo 'test "$$_arg_ordnung" = yes || exit 1' >> $@
])

dnl
dnl 1. The parsing part fails if --ordnung does not receive the "yes" value, but the -o alias doesn't work
dnl 2. The support for -o is injected to the parsing shell script
dnl 3. The script is regenerated and this time, we expect that the parsing stuff got also regenerated, so the -o alias is functional.
ADD_TEST([test-init_simple-s-update], [[
	@# Regenerate everyting during the next test run
	touch $(TESTDIR)/regenerate-test-init_simple-s-update.m4
	$< --ordnung yes
	$(REVERSE) $<
	ERROR="unexpected argument" $(REVERSE) $< -o yes
	sed -i 's/\[ordnung\],\[\]/&[o]/' $(TESTDIR)/test-init_simple-s-update-parsing.sh
	$(ARGBASH_BIN) $< > /dev/null
	$< --ordnung yes
	$(REVERSE) $<
	$< -o yes
]])

ADD_SCRIPT([test-init_simple-ss-parsing])
ADD_SCRIPT([test-init_simple-ss-parsing], [m4])
ADD_RULE([$(TESTDIR)/test-init_simple-ss.sh], [$(ARGBASH_INIT)],
	[$< --pos pos --opt opt2 --opt opt --opt-bool boo -s -s $@
])
dnl Nothing to do, if we have one, we have also the second one.
ADD_RULE([$(TESTDIR)/test-init_simple-ss-parsing.m4], [$(TESTDIR)/test-init_simple-ss.sh],
	[@
])

ADD_RULE([$(TESTDIR)/gen-test-init_name_char.m4], [$(ARGBASH_INIT)],
	[$< --opt-bool foo/bar-baz $@
])

ADD_RULE([$(TESTDIR)/gen-test-init_name_dash.m4], [$(ARGBASH_INIT)],
	[$< --pos -bool $@
])

ADD_GENTEST([init_name_dash], ['-bool' .* begins with a dash])

ADD_GENTEST([init_name_char], ['foo/bar-baz' .* contains forbidden characters])

m4_popdef([tbody])
