ADD_RULE([$(TESTDIR)/test-semi_strict.sh], [$(TESTDIR)/test-onlyopt.m4],
	[[printf "%s\n" "# ARG_STRICT_MODE([semi])" | cat - $< | $(ARGBASH_BIN) --no-check-typos -o $(@) -]])

ADD_RULE([$(TESTDIR)/test-very_strict.sh], [$(TESTDIR)/test-onlyopt.m4],
	[[printf "%s\n" "# ARG_STRICT_MODE([very])" | cat - $< | $(ARGBASH_BIN) --no-check-typos -o $(@) -]])

ADD_TEST([test-semi_strict], [[
	$< -o -x | grep -q 'OPT_S=-x,'
	$< -o --opt-argx | grep -q 'OPT_S=--opt-argx,'
	ERROR="omitted the actual value" $(REVERSE) $< -o -i
	ERROR="omitted the actual value" $(REVERSE) $< -o -ilau
	ERROR="omitted the actual value" $(REVERSE) $< -o --opt-arg
]])

ADD_TEST([test-very_strict], [[
	ERROR="omitted the actual value" $(REVERSE) $< -o -x
	ERROR="omitted the actual value" $(REVERSE) $< -o -i
]])
