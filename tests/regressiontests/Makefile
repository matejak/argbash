check: stability args

stability: test.sh test2.sh
	diff -q $< $(word 2,$^)

args: test.sh
	./test.sh LOO | grep -q POS_S=LOO,
	./test.sh LOO | grep -q BOOL=off,
	./test.sh LOO --boo_l | grep -q BOOL=on,
	./test.sh LOO --no-boo_l | grep -q BOOL=off,
