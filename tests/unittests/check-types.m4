m4_include([utilities.m4])
m4_include([test-support.m4])

m4_define([CHECK], _CHECK_PASSED_ARGS_COUNT(2, 3, [[one], [two (opt.)]]))

m4_define([_CHECK_PASSED_ARGS_COUNT_TOO_FEW], [TOO LOW:$1,WANT:$2.DO:$3])
m4_define([_CHECK_PASSED_ARGS_COUNT_TOO_MANY], [TOO HIGH:$1,WANT:$2])

assert_equals(CHECK(a, a, a), [])
assert_equals(CHECK(a, a), [])
assert_equals(m4_quote(CHECK(a)), [TOO LOW:1,WANT:2.DO:CHECK([one], [two (opt.)])])
assert_equals(m4_quote(CHECK(a, a, a, a)), [TOO HIGH:4,WANT:3])

m4_define([CHECK], _CHECK_PASSED_ARGS_COUNT(1, 2))

assert_equals(CHECK(a, a), [])
assert_equals(CHECK(a), [])
assert_equals(m4_quote(CHECK(a, a, a)), [TOO HIGH:3,WANT:2])

m4_define([CHECK], _CHECK_PASSED_ARGS_COUNT(2))

assert_equals(m4_quote(CHECK(a)), [TOO LOW:1,WANT:2.DO:])
assert_equals(CHECK(a, a, a, a, a, a), [])
