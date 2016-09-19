
ADD_TEST([test-env-base], [[
	$< | grep -q 'ENVI_FOO=default,'
	$< | grep -q 'ENVI_BAR=,'
	ENVI_FOO=something $< | grep -q 'ENVI_FOO=something'
	$< -h | grep -q "ENVI_FOO: A sample env, variable. (default: 'something')"
	$< -h | grep -q "ENVI_BAR: A sample env, variable."
]])

ADD_TEST([test-env-simple], [[
	$< | grep -q 'ENVI_FOO=something,'
	$(REVERSE) $< -h | grep -q 'ENVI_FOO'
]])
