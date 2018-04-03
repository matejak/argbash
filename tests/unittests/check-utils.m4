m4_include([list.m4])
m4_include([utilities.m4])
m4_include([function_generators.m4])
m4_include([test-support.m4])

m4_list_append([FOO], [one])
m4_list_append([FOO], [two])

m4_list_append([BAR], [1])
m4_list_append([BAR], [2])

m4_list_append([BAZ], [foo])
m4_list_append([BAZ], [bar])

assert_equals(_lists_same_len([FOO,BAR], [OK], [KO]), OK)
assert_equals(_lists_same_len([FOO,BAR,BAZ], [OK], [KO]), OK)

m4_list_append([FUU], [foo])

_lists_same_len([FOO,BAR,BAZ,FUU], [m4_fatal([Lists don't have the same length])], )

m4_list_append([FUX], [foo])
m4_list_append([FUX], [BOMB])
m4_list_append([FUX], [])

assert_equals(_LIST_LONGEST_TEXT_LENGTH([XXX]), 0)
assert_equals(_LIST_LONGEST_TEXT_LENGTH([FUX]), 4)

assert_equals(_lists_same_len([FOO,BAR,BAZ,FUU], [m4_fatal([Lists don't have the same length])], OK), OK)
assert_equals(_lists_same_len([FUU,BAR,BAZ,FOO], [m4_fatal([Lists don't have the same length])], OK), OK)
assert_equals(_lists_same_len([FUU,BAZ,BAR,FOO], [m4_fatal([Lists don't have the same length])], OK), OK)

assert_equals(m4_lists_foreach([FOO,BAR],[fu,ba],[fu: ba@ ]),
	[one: 1@ two: 2@ ])

assert_equals(m4_lists_foreach([FOO],[fu],[fu:]),
	[one:two:])

assert_equals(m4_lists_foreach([FOO,BAR,BAZ],[fu,ba,za],[fu: ba-za@]),
	[one: 1-foo@two: 2-bar@])

assert_equals(_sh_quote(), [])
assert_equals(_sh_quote(x), ["x"])
assert_equals(_sh_quote("x"), ["x"])
assert_equals(_sh_quote('x'), ['x'])

assert_equals(_sh_quote_also_blanks(), [""])
assert_equals(_sh_quote_also_blanks(x), ["x"])
assert_equals(_sh_quote_also_blanks("x"), ["x"])
assert_equals(_sh_quote_also_blanks('x'), ['x'])

assert_equals(_GET_BASENAME([BOM]), [BOM])
assert_equals(_GET_BASENAME([/BOM]), [BOM])
assert_equals(_GET_BASENAME([/pu/la/BOM]), [BOM])

assert_equals(_STRIP_SUFFIX([BOMB.m4]), [BOMB])

m4_include([stuff.m4])
_SET_OPTION_VALUE_DELIMITER([ ])
assert_equals(_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE([BOMB]), [--BOMB])
assert_equals(_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE([BOMB], [b]), [-b|--BOMB])
assert_equals(_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE([BOMB], [b], [BOMB2]), [-b BOMB2|--BOMB BOMB2])

_SET_OPTION_VALUE_DELIMITER([ =])
assert_equals(_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE([BOMB], [b], [BOMB2]), [-b BOMB2|--BOMB BOMB2])
_SET_OPTION_VALUE_DELIMITER([=])
assert_equals(_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE([BOMB], [b], [BOMB2]), [-b BOMB2|--BOMB=BOMB2])
assert_equals(_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE([BOMB], [b], [BOMB2], [, ]), [-b BOMB2, --BOMB=BOMB2])

_SET_INDENT([  ])
m4_define([COMMENT_OUTPUT])
assert_equals(MAKE_BASH_FUNCTION([# one], [something],
	[[BOMB=$x],
	[echo "$BOMB"]], [x=1], [BOMB]),

[# one
something()
{
  local x=1 BOMB
  BOMB=$x
  echo "$BOMB"
}])

assert_equals(MAKE_POSIX_FUNCTION([[# BOMB], [# o,ne]], [something],
	[[BOMB=$x],
	[echo "$BOMB"]], [x=1], [BOMB], [z=BOMB]),

[# BOMB
# o,ne
something()
{
  x=1
  z=BOMB
  BOMB=$x
  echo "$BOMB"
}])
