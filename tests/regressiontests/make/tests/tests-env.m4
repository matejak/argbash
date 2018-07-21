
ADD_TEST_BASH([test-env-base], [[
	$< | grep -q 'ENVI_FOO=def,ault,'
	$< | grep -q 'ENVI_BAR=,'
	ENVI_FOO=something $< | grep -q 'ENVI_FOO=something'
	$< -h | grep -q "ENVI_FOO: A sample env, variable. (default: 'def,ault')"
	$< -h | grep -q "ENVI_BAR: A sample env, variable."
]])

ADD_TEST_BASH([test-env-simple], [[
	$< | grep -q 'ENVI_FOO=def,ault,'
	! $< -h | grep -q 'ENVI_FOO'
]])
