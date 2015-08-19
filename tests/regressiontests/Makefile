check: stability args

stability: test.sh test2.sh
	diff -q $< $(word 2,$^)

args: test.sh
	./test.sh LOO | grep -q POS_S=LOO,
	./test.sh "LOO BAR" | grep -q 'POS_S=LOO BAR,'
	./test.sh LOO | grep -q BOOL=off,
	./test.sh LOO --boo_l | grep -q BOOL=on,
	./test.sh LOO --no-boo_l | grep -q BOOL=off,
	./test.sh LOO | grep -q OPT_S=x,
	./test.sh LOO --opt-arg PoS | grep -q OPT_S=PoS,
	./test.sh LOO --opt-arg "PoS sob" | grep -q 'OPT_S=PoS sob,'
	./reverse ./test.sh LOO --opt-arg 2> /dev/null
