m4_include([argbash-lib.m4])
m4_include([test-support.m4])

dnl TODO PROBLEMS:
dnl - defaults are quoted.

ARG_OPTIONAL_SINGLE([foo], [f], [Help,BOMB], [Default])
ARG_OPTIONAL_SINGLE([BOMB], [B], [BOMB], [BOMB])
ARG_POSITIONAL_SINGLE([defaultless], [xhelp])
ARG_OPTIONAL_BOOLEAN([b-BOMB], [X], [BOMB], [BOMB])
ARG_POSITIONAL_SINGLE([p-BOMB], [BOMB], [BOMB])

assert_equals_list_element([_ARGS_LONG], 1, [foo])
assert_equals_list_next([BOMB])
assert_equals_list_next([defaultless])
assert_equals_list_next([b-BOMB])
assert_equals_list_next([p-BOMB])

assert_equals_list_element([_ARGS_LONG], 1, [foo])
assert_equals_list_next([BOMB])

assert_equals_list_element([_ARGS_SHORT], , [f])
assert_equals_list_next([B])

assert_equals_list_element([_ARGS_HELP], 1, [Help,BOMB])
assert_equals_list_element([_ARGS_HELP], 2, [BOMB])

assert_equals_list_element([_ARGS_DEFAULT], , [Default])
assert_equals_list_next([BOMB])

assert_equals_list_element([_ARGS_VARNAME], 1, [_arg_foo])
assert_equals_list_next([_arg_bomb])

assert_equals(m4_lists_foreach_optional([_ARGS_LONG,_ARGS_SHORT],[_arg_long,_arg_short],[_arg_long:_arg_short;]),
	      [foo:f;BOMB:B;b-BOMB:X;])

assert_equals(m4_lists_foreach_positional([_ARGS_LONG,_ARGS_HELP,_POSITIONALS_MINS,_POSITIONALS_MAXES],[_arg_long,_arg_help,_pmin,_pmax],[_arg_long:_arg_help:_pmin-_pmax;]),
	      [defaultless:xhelp:1-1;p-BOMB:BOMB:0-1;])

assert_equals([single], _CATH_IS_SINGLE_VALUED(m4_list_nth([_ARGS_CATH], 2), [single], [not single]))
assert_equals([single], _CATH_IS_SINGLE_VALUED(m4_list_nth([_ARGS_CATH], 3), [single], [not single]))
assert_equals([not single], _CATH_IS_SINGLE_VALUED(m4_list_nth([_ARGS_CATH], 4), [single], [not single]))

_DISCARD_VALUES_FOR_ALL_ARGUMENTS()

ARG_OPTIONAL_SINGLE([foo], [f], [Help,BOMB], [Default])
ARG_POSITIONAL_SINGLE([defaultless], [xhelp])
ARG_POSITIONAL_MULTI([multi-BOMB], [help-BOMB], 3, [one], [two])


assert_equals_list_element([_ARGS_LONG], 1, [foo])
assert_equals_list_next([defaultless])
assert_equals_list_next([multi-BOMB])

assert_equals_list_element([_ARGS_SHORT], , [f])

assert_equals_list_element([_ARGS_HELP], 1, [Help,BOMB])
assert_equals_list_next([xhelp])
assert_equals_list_next([help-BOMB])

assert_equals_list_element([_ARGS_DEFAULT], , [Default])
assert_equals_list_next([])
assert_equals_list_next([])

assert_equals_list_element([_ARGS_VARNAME], 1, [_arg_foo])
assert_equals_list_next([_arg_defaultless])
assert_equals_list_next([_arg_multi_bomb])

assert_equals(m4_lists_foreach_positional([_ARGS_LONG,_ARGS_HELP,_POSITIONALS_MINS,_POSITIONALS_MAXES],[_arg_long,_arg_help,_pmin,_pmax],[_arg_long:_arg_help:_pmin-_pmax;]),
	      [defaultless:xhelp:1-1;multi-BOMB:help-BOMB:1-3;])
