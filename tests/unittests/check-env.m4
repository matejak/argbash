m4_include([utilities.m4])
m4_include_once([argbash-lib.m4])
m4_include_once([test-support.m4])

ARG_USE_ENV([OS_CLOUD], , [my blah help text])
ARG_USE_ENV([BOMB], [default BOMB], [a, BOMB])

assert_equals_list_element([ENV_NAMES], , [OS_CLOUD])
assert_equals_list_next([BOMB])
assert_equals_list_element([ENV_DEFAULTS], [])
assert_equals_list_next([default BOMB])
assert_equals_list_element([ENV_HELPS], , [my blah help text])
assert_equals_list_next([a, BOMB])
assert_equals_list_element([ENV_ARGNAMES], , [])
assert_equals_list_next([])

_MAKE_ENV_HELP_MESSAGES([_MSGS])

assert_equals_list_element([_MSGS], , [OS_CLOUD: my blah help text.])
assert_equals_list_next([BOMB: a, BOMB. (default: 'default BOMB')])
