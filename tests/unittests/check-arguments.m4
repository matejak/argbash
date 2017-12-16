m4_include([argbash-lib.m4])
m4_include([test-support.m4])

dnl TODO PROBLEMS:
dnl - defaults are quoted.

ARG_OPTIONAL_SINGLE([foo], [f], [Help,BOMB], [Default])
ARG_OPTIONAL_SINGLE([BOMB], [B], [BOMB], [BOMB])
ARG_POSITIONAL_SINGLE([p-BOMB], [BOMB], [BOMB])
ARG_OPTIONAL_BOOLEAN([b-BOMB], [X], [BOMB], [BOMB])


assert_equals_list_element([_ARGS_LONG], 1, [foo])
assert_equals_list_next([BOMB])
assert_equals_list_next([p-BOMB])
assert_equals_list_next([b-BOMB])

assert_equals_list_element([_ARGS_LONG], 1, [foo])
assert_equals_list_next([BOMB])

assert_equals_list_element([_ARGS_SHORT], , [f])
assert_equals_list_next([B])

assert_equals_list_element([_ARGS_HELP], 1, [Help,BOMB])
assert_equals_list_element([_ARGS_HELP], 2, [BOMB])

assert_equals_list_element([_ARGS_DEFAULT], , ["Default"])
assert_equals_list_next(["BOMB"])

assert_equals_list_element([_ARGS_VARNAME], 1, [_arg_foo])
assert_equals_list_next([_arg_bomb])

assert_equals(m4_lists_foreach_optional([_ARGS_LONG,_ARGS_SHORT],[_arg_long,_arg_short],[_arg_long:_arg_short;]),
	      [foo:f;BOMB:B;two-BOMB:X;])

assert_equals(m4_lists_foreach_optional([_ARGS_LONG,_ARGS_HELP],[_arg_long,_arg_help],[_arg_long:_arg_help;]),
	      [p-BOMB:BOMB;])
