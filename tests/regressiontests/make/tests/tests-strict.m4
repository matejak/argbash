ADD_RULE([$(TESTDIR)/test-semi_strict.sh], [$(TESTDIR)/test-simple.m4 $(ARGBASH_BIN)],
	[[printf "%s\n%s\n" "#!/bin/bash" "# ARG_RESTRICT_VALUES([no-local-options])" | cat - $< | $(ARGBASH_BIN) -o $(@) -]])

ADD_RULE([$(TESTDIR)/test-very_strict.sh], [$(TESTDIR)/test-simple.m4 $(ARGBASH_BIN)],
	[[printf "%s\n%s\n" "#!/bin/bash" "# ARG_RESTRICT_VALUES([no-any-options])" | cat - $< | $(ARGBASH_BIN) -o $(@) -]])


dnl We have to pass a positional argument, so sometimes we pass 'pos-arg', sometimes stuff that looks like a option
ADD_TEST_BASH([test-semi_strict], [[
	$< -o -x pos-arg | grep -q 'OPT_S=-x,'
	$< -o --opt-argx pos-arg | grep -q 'OPT_S=--opt-argx,'
	ERROR="omitted the actual value" $(REVERSE) $< -o -o pos-arg
	ERROR="omitted the actual value" $(REVERSE) $< -o -ofoo pos-arg
	ERROR="omitted the actual value" $(REVERSE) $< -o --prefix
]])

ADD_TEST_BASH([test-very_strict], [[
	ERROR="are trying to pass an option" $(REVERSE) $< -o -x pos-arg
	ERROR="are trying to pass an option" $(REVERSE) $< -o -o pos-arg
	ERROR="are trying to pass an option" $(REVERSE) $< -x
	ERROR="are trying to pass an option" $(REVERSE) $< --foobar
]])
