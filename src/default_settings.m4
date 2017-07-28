dnl Sets the default (literal tab) indent
_SET_INDENT([	])

_SET_OPTION_VALUE_DELIMITER([ =])
ARG_OPTION_GROUPING([getopt])

dnl Define STDOUT as m4sugar diversion 1
dnl From now on, we can write 'm4_divert_push([STDOUT])' without getting a warnings.
m4_define([_m4_divert(STDOUT)], 1)
