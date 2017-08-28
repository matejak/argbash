ADD_TEST([test-int], [[
	$< 1 | grep -q "POS_S=1,"
	ERROR="integer" $(REVERSE) $< a
	ERROR="integer" $(REVERSE) $< 1.5
	$< 1 --int 2 | grep -q "OPT_S=2,"
	ERROR="integer" $(REVERSE) $< 1 --int b
	$< 01 | grep -q "POS_S=1,"
	$< +1 | grep -q "POS_S=1,"
	$< -1 | grep -q "POS_S=-1,"
	$< -1776 | grep -q "POS_S=-1776,"
	$< -h | grep -q "INT"
	$< -h | grep -q "INT+0"
	$< -h | grep -q "INT+"
	$< 1 --nnint 2 | grep -q "NN=2,"
	$< 1 --pint 2 | grep -q "P=2,"
	ERROR="positive" $(REVERSE) $< 1 --pint 0
	ERROR="negative" $(REVERSE) $< 1 --nnint -1
]])

ADD_TEST([test-group], [[
	$< foo | grep -q "ACT=foo"
	$< '' | grep -q "ACT="
	$< foo,baz | grep -q "ACT=foo,baz,"
	$< "bar bar" | grep -q "ACT=bar bar,"
	ERROR="allowed" $(REVERSE) $< fuuuu
	ERROR="allowed" $(REVERSE) $< bar
	@# Assure that there is not the string '_idx' in the script since we don't want indices support in this test
	! grep -q _idx $< 
	# $< -h | grep action | grep ACTION | grep -q 'foo,baz'
]])

ADD_TEST([test-group-idx], [[
	$< foo | grep -q "ACT=foo,IDX=0,"
	$< foo,baz | grep -q "ACT=foo,baz,IDX=3,"
	$< "bar bar" | grep -q "ACT=bar bar,IDX=2,"
	ERROR="allowed" $(REVERSE) $< fuuuu
	ERROR="allowed" $(REVERSE) $< bar
	# $< -h | grep action | grep ACTION | grep -q 'foo,baz'
]])
