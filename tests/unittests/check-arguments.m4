m4_include([utilities.m4])
m4_include_once([argbash-lib.m4])
m4_include_once([test-support.m4])

dnl TODO PROBLEMS:
dnl - defaults are quoted.

ARG_OPTIONAL_SINGLE([foo], [f], [Help,BOMB], [Default])
ARG_OPTIONAL_SINGLE([BOMB], [B], [BOMB], [BOMB])
ARG_POSITIONAL_SINGLE([defaultless], [xhelp])
ARG_OPTIONAL_BOOLEAN([b-BOMB], [X], [BOMB], [on])
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

m4_pushdef([_POSITIONALS_INF], 1)

m4_pushdef([_MINIMAL_POSITIONAL_VALUES_COUNT], 0)
assert_equals(_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([needed], [not needed]), [not needed])
m4_popdef([_MINIMAL_POSITIONAL_VALUES_COUNT])

m4_pushdef([_MINIMAL_POSITIONAL_VALUES_COUNT], 2)
assert_equals(_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([needed], [not needed]), [needed])
m4_popdef([_MINIMAL_POSITIONAL_VALUES_COUNT])

m4_popdef([_POSITIONALS_INF])

m4_pushdef([_POSITIONALS_INF], 0)

m4_pushdef([_MINIMAL_POSITIONAL_VALUES_COUNT], 0)
assert_equals(_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([needed], [not needed]), [needed])
m4_popdef([_MINIMAL_POSITIONAL_VALUES_COUNT])

m4_pushdef([_MINIMAL_POSITIONAL_VALUES_COUNT], 2)
assert_equals(_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([needed], [not needed]), [needed])
m4_popdef([_MINIMAL_POSITIONAL_VALUES_COUNT])

m4_popdef([_POSITIONALS_INF])

_DISCARD_VALUES_FOR_ALL_ARGUMENTS()

m4_pushdef([_COLLECTOR_FEEDBACK], [m4_list_append([_ERRORS_], [[$1]])])
ARG_OPTIONAL_SINGLE([foo], [f])
assert_equals(m4_list_len([_ERRORS_]), 0)
ARG_OPTIONAL_SINGLE([bar], [f])
assert_equals(m4_list_len([_ERRORS_]), 1)
m4_bmatch(m4_list_nth([_ERRORS_], 1), ['f'.*already used], [], [m4_fatal([Expected error reflecting duplicate short option, got] 'm4_list_nth([_ERRORS_], 1)' instead.)])
m4_popdef([_COLLECTOR_FEEDBACK])
