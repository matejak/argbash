ADD_RULE([$(TESTDIR)/test-getopt-equals.sh], [$(TESTDIR)/test-onlyopt.m4 $(ARGBASH_BIN)],
	[[printf "%s\n%s\n%s\n" "#!/bin/bash" "# ARGBASH_SET_DELIM([=])" "# ARG_OPTION_STACKING([getopt])" | cat - $< | $(ARGBASH_BIN) -o $(@) -]])

ADD_RULE([$(TESTDIR)/test-getopt-both.sh], [$(TESTDIR)/test-onlyopt.m4 $(ARGBASH_BIN)],
	[[printf "%s\n%s\n%s\n" "#!/bin/bash" "# ARGBASH_SET_DELIM([ =])" "# ARG_OPTION_STACKING([getopt])" | cat - $< | $(ARGBASH_BIN) -o $(@) -]])

ADD_RULE([$(TESTDIR)/test-getopt-space.sh], [$(TESTDIR)/test-onlyopt.m4 $(ARGBASH_BIN)],
	[[printf "%s\n%s\n%s\n" "#!/bin/bash" "# ARGBASH_SET_DELIM([ ])" "# ARG_OPTION_STACKING([getopt])" | cat - $< | $(ARGBASH_BIN) -o $(@) -]])

dnl We have to pass a positional argument, so sometimes we pass 'pos-arg', sometimes stuff that looks like a option
ADD_TEST_BASH([test-getopt-both], [[
	$< -ii | grep -q 'OPT_INCR=4,'
	$< --incrx -ii | grep -q 'OPT_INCR=5,'
	$< -Bi | grep 'OPT_INCR=3,' | grep -q 'BOOL=on,'
	$< -Bio bu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Biobu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Boibu | grep 'BOOL=on,' | grep 'OPT_INCR=2,' | grep -q 'OPT_S=ibu,'
	ERROR="'-Bfoo' can't be decomposed to -B and -foo, because -B doesn't accept value and '-f' doesn't correspond to a short option" $(REVERSE) $< -Bfoo
]])

ADD_TEST_BASH([test-getopt-space], [[
	$< -ii | grep -q 'OPT_INCR=4,'
	$< --incrx -ii | grep -q 'OPT_INCR=5,'
	$< -Bi | grep 'OPT_INCR=3,' | grep -q 'BOOL=on,'
	$< -Bio bu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Biobu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Boibu | grep 'BOOL=on,' | grep 'OPT_INCR=2,' | grep -q 'OPT_S=ibu,'
	ERROR="'-Bfoo' can't be decomposed to -B and -foo, because -B doesn't accept value and '-f' doesn't correspond to a short option" $(REVERSE) $< -Bfoo
]])

ADD_TEST_BASH([test-getopt-equals], [[
	$< -ii | grep -q 'OPT_INCR=4,'
	$< --incrx -ii | grep -q 'OPT_INCR=5,'
	$< -Bi | grep 'OPT_INCR=3,' | grep -q 'BOOL=on,'
	$< -Bio bu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Biobu | grep 'OPT_INCR=3,' | grep 'BOOL=on,' | grep -q 'OPT_S=bu,'
	$< -Boibu | grep 'BOOL=on,' | grep 'OPT_INCR=2,' | grep -q 'OPT_S=ibu,'
	ERROR="'-Bfoo' can't be decomposed to -B and -foo, because -B doesn't accept value and '-f' doesn't correspond to a short option" $(REVERSE) $< -Bfoo
]])
