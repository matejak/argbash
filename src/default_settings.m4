dnl Sets the default (literal tab) indent
_SET_INDENT([	])

_SET_OPTION_VALUE_DELIMITER([ =])
ARG_OPTION_STACKING([getopt])


dnl Define STDOUT as m4sugar diversion 1
dnl From now on, we can write 'm4_divert_push([STDOUT])' without getting a warnings.
m4_define([_m4_divert(STDOUT)], 1)
m4_define([_DEFAULT_WRAP_FLAGS], [[HVI]])


dnl
dnl Just define name of the script dir variable
m4_define([_DEFAULT_SCRIPTDIR], [[script_dir]])


m4_define([MAKE_FUNCTION], [MAKE_BASH_FUNCTION($@)])

m4_define([_VERSION_DEFAULT_ARGNAME], [[version]])
m4_define([_VERSION_DEFAULT_SHORT_ARGNAME], [[v]])
m4_define([_VERSION_DEFAULT_HELP_MSG], [[Prints version]])

m4_define([_HELP_DEFAULT_ARGNAME], [[help]])
m4_define([_HELP_DEFAULT_SHORT_ARGNAME], [[h]])
m4_define([_HELP_DEFAULT_HELP_MSG], [[Prints help]])
