ADD_TEST_BASH([test-delim-space], [[
	ERROR="unexpected argument '--opt=something'" $(REVERSE) $< --opt=something
	$< --opt something | grep -q 'OPT_S=something,'
	ERROR="unexpected argument '--add=three'" $(REVERSE) $< -a one --add two --add=three
	$< -a one --add two | grep -q 'OPT_REP=one two,'
]])

ADD_TEST_BASH([test-delim-equals], [[
	ERROR="unexpected argument '--opt'" $(REVERSE) $< --opt something
	$< --opt=something | grep -q 'OPT_S=something,'
	$< --xxx | grep -q 'XXX=on,'
	ERROR="unexpected argument '--add'" $(REVERSE) $< -a one --add two --add=three
	$< -a one --add=two | grep -q 'OPT_REP=one two,'
]])

ADD_TEST_BASH([test-delim-both], [[
	$< --opt something | grep -q 'OPT_S=something,'
	$< --opt=something | grep -q 'OPT_S=something,'
	$< -a one --add two --add=three | grep -q 'OPT_REP=one two three'
]])
