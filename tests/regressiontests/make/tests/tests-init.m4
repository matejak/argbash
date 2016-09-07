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
	[$< --pos pos --opt opt2 --opt opt --opt-bool boo $@ -s
])

ADD_SCRIPT([test-init_simple-ss-parsing])
ADD_SCRIPT([test-init_simple-ss-parsing], [m4])
ADD_RULE([$(TESTDIR)/test-init_simple-ss.sh], [$(ARGBASH_INIT)],
	[$< --pos pos --opt opt2 --opt opt --opt-bool boo $@ -s -s
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
