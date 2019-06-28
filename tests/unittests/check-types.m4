m4_include([utilities.m4])
m4_include_once([test-support.m4])

m4_define([CHECK], _CHECK_PASSED_ARGS_COUNT(2, 3, [[one], [two (opt.)]]))

m4_define([_CHECK_PASSED_ARGS_COUNT_TOO_FEW], [[$1:TOO LOW:$2,WANT:$3.DO:$4]])
m4_define([_CHECK_PASSED_ARGS_COUNT_TOO_MANY], [[$1:TOO HIGH:$2,WANT:$3]])

assert_equals(CHECK(a, a, a), [])
assert_equals(CHECK(a, a), [])
assert_equals(m4_quote(CHECK(a)), [CHECK:TOO LOW:1,WANT:2.DO:CHECK([one], [two (opt.)])])
assert_equals(m4_quote(CHECK(a, a, a, a)), [CHECK:TOO HIGH:4,WANT:3])

m4_define([CHECK], _CHECK_PASSED_ARGS_COUNT(1, 2))

assert_equals(CHECK(a, a), [])
assert_equals(CHECK(a), [])
assert_equals(m4_quote(CHECK(a, a, a)), [CHECK:TOO HIGH:3,WANT:2])

m4_define([CHECK], _CHECK_PASSED_ARGS_COUNT(2))

assert_equals(m4_quote(CHECK(a)), [CHECK:TOO LOW:1,WANT:2.DO:])
assert_equals(CHECK(a, a, a, a, a, a), [])
