m4_include([utilities.m4])
m4_include_once([list.m4])
m4_include_once([argument_value_types.m4])
m4_include_once([test-support.m4])

_SET_INDENT([x-])
assert_equals(_INDENT_(0)y, y)
assert_equals(_INDENT_(1)y, x-y)
assert_equals(_INDENT_(2)y, x-x-y)

_SET_INDENT([[x-]])
assert_equals(_INDENT_(1)y, [[x-]y])

_SET_INDENT([  ])
assert_equals(_JOIN_INDENTED(0, a, b),
[a
b
])
assert_equals(_JOIN_INDENTED(1, a, b),
[  a
  b
])

assert_equals(_JOIN_INDENTED(1, a, _INDENT_MORE([[BOMB]], [ANTIFUSE([_X_])c]), d, e),
[  a
    BOMB
    c
  d
  e
])
ANTIBOMB([_X_])

assert_equals(_COMM_BLOCK(1, x, [BOMB]), [])
assert_equals(m4_quote(_COMMENT_CHAIN([BOMB], [two])), [])

m4_define([COMMENT_OUTPUT])

assert_equals(_JOIN_INDENTED(1, a, _INDENT_MORE(b, _COMMENT([x]), _COMMENT([y]), c), e),
[  a
    b
    x
    y
    c
  e
])

assert_equals(_COMM_BLOCK(1, x, [BOMB]),
[  x
  BOMB
])

assert_equals(_POSSIBLY_REPEATED_COMMENT_BLOCK([comment-topic], [comment at there BOMB], 1, x, [BOMB]),
[  x
  BOMB
])

assert_equals(_POSSIBLY_REPEATED_COMMENT_BLOCK([comment-topic], [here], 1, x, [BOMB]), [  # comment at there BOMB
])

assert_equals(_SUBSTITUTE_LF_FOR_NEWLINE_WITH_DISPLAY_INDENT_AND_ESCAPE_DOUBLEQUOTES([first\nsecond]), [first
		second])
assert_equals(_SUBSTITUTE_LF_FOR_NEWLINE_WITH_DISPLAY_INDENT_AND_ESCAPE_DOUBLEQUOTES([first\nsecond\nthird]), [first
		second
		third])
assert_equals(_SUBSTITUTE_LF_FOR_NEWLINE_WITH_DISPLAY_INDENT_AND_ESCAPE_DOUBLEQUOTES([first\\nsecond]), [first\\nsecond])
assert_equals(_SUBSTITUTE_LF_FOR_NEWLINE_WITH_DISPLAY_INDENT_AND_ESCAPE_DOUBLEQUOTES(x "y z"), [x \"y z\"])
assert_equals(_SUBSTITUTE_LF_FOR_NEWLINE_WITH_DISPLAY_INDENT_AND_ESCAPE_DOUBLEQUOTES([x \"m4_ignore() z"]), [x \"m4_ignore() z\"])

assert_equals(m4_quote(_COMMENT_CHAIN([BOMB], [two])), [BOMB,two])

assert_equals(_ASSIGN_VALUE_TO_VAR(x, ["some, thing BOMB"], [somewhere]), [somewhere="some, thing BOMB"])
assert_equals(_APPEND_VALUE_TO_ARRAY(x, ["some, thing BOMB"], [somewhere]), [somewhere+=("some, thing BOMB")])

assert_equals(@[]_ENDL_()@, [@
@])
assert_equals(@[]_ENDL_(2)@, [@

@])
