ADD_DOCOPT_TEST([basic], [[
	grep -q "\[<pos-opt>\]" $<
	grep -q "\[--opt_arg OPT_ARG\]" $<
	grep -q "\s-o OPT_ARG, --opt_arg OPT_ARG\s" $<
	! test -x $<
]])

ADD_DOCOPT_TEST([test-onlyopt], [[
	grep -q "\[--opt-repeated OPT-REPEATED\]\.\.\." $<
	grep -q "\[--incrx\]\.\.\." $<
]])
