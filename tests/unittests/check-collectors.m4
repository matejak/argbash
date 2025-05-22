m4_include([collectors.m4])

m4_include([test-support.m4])


m4_define([SAVE], [m4_define([SAVED], [$1])])

GET_NEGATION_PREFIX([BOMB], [SAVE])
assert_equals(SAVED, _FORMAT_MISSING_PREFIX([BOMB]))

STORE_NEGATION_PREFIX([lol], [BOMB])
assert_equals(GET_NEGATION_PREFIX([lol]), [BOMB])
