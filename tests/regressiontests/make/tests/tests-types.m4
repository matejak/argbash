ADD_TEST([test-int], [[
	$< 1 | grep -q "POS_S=1,"
	ERROR="integer" $(REVERSE) $< a
	ERROR="integer" $(REVERSE) $< 1.5
	$< 1 --opt-arg 2 | grep -q "OPT_S=2,"
	ERROR="integer" $(REVERSE) $< 1 --opt-arg b
	$< 01 | grep -q "POS_S=1,"
	$< +1 | grep -q "POS_S=1,"
	$< -1 | grep -q "POS_S=-1,"
	$< -1776 | grep -q "POS_S=-1776,"
	$< -h | grep -q "INT"
]])

