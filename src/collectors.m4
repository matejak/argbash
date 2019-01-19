m4_define([_COLLECTOR_FEEDBACK], [m4_fatal($@)])


dnl
dnl $1: The argument name
dnl $2: The help message
dnl $3: The variable name
dnl $4: The argument cathegory
m4_define([_FILL_IN_VALUES_FOR_ANY_ARGUMENT], _CHECK_PASSED_ARGS_COUNT(3)[m4_do(
	[m4_list_append([_ARGS_LONG], [$1])],
	[m4_list_append([_ARGS_HELP], [$2])],
	[m4_list_append([_ARGS_VARNAME], [$3])],
	[m4_list_append([_ARGS_CATH], [$4])],
)])


dnl
dnl $1: The argument name
dnl $2: The help message
dnl $3: The variable name
dnl $4: The argument cathegory
dnl $5: The short option
dnl $6: The default value
m4_define([_FILL_IN_VALUES_FOR_AN_OPTIONAL_ARGUMENT], _CHECK_PASSED_ARGS_COUNT(3)[m4_do(
	[_FILL_IN_VALUES_FOR_ANY_ARGUMENT([$1], [$2], [$3], [$4])],
	[m4_list_append([_ARGS_POS_OR_OPT], [optional])],

	[m4_list_append([_POSITIONALS_MINS], 0)],
	[m4_list_append([_POSITIONALS_MAXES], 0)],
	[m4_list_append([_POSITIONALS_DEFAULTS], [])],

	[m4_list_append([_ARGS_SHORT], [$5])],
	[m4_set_add([_ARGS_SHORT], [$5])],

	[m4_list_append([_ARGS_DEFAULT], [$6])],
)])


dnl
dnl $1: The argument name
dnl $2: The help message
dnl $3: The variable name
dnl $4: The argument cathegory
m4_define([_FILL_IN_VALUES_FOR_A_POSITIONAL_ARGUMENT], _CHECK_PASSED_ARGS_COUNT(3)[m4_do(
	[_FILL_IN_VALUES_FOR_ANY_ARGUMENT([$1], [$2], [$3], [$4])],
	[m4_list_append([_ARGS_POS_OR_OPT], [positional])],

	[m4_list_append([_ARGS_DEFAULT], [])],
	[m4_list_append([_ARGS_SHORT], [])],
)])


dnl
dnl The operation on command names that converts them to variable names (where command values are stored)
m4_define([_opt_suffix], [[_opt]])
m4_define([_pos_suffix], [[_pos]])
m4_define([_arg_prefix], [[_arg_]])
m4_define([_args_prefix], [[_args_]])
m4_define([_varname], [m4_do(
	[m4_quote(_arg_prefix[]_translit_var([$1]))],
)])


dnl
dnl The operation on command names that makes stem of variable names
dnl Since each call of _translit_var etc. strips one level of quoting, we have to quote $1 more than usually
m4_define([_translit_var], [m4_translit(m4_translit([[[$1]]], [A-Z], [a-z]), [-/], [__])])
m4_define([_translit_prog], [m4_translit(m4_translit([[[$1]]], [a-z], [A-Z]), [-], [_])])


dnl
dnl Checks that the an argument is a correct short option arg
dnl $1: The short option "string"
dnl $2: The argument name
m4_define([_CHECK_SHORT_OPTION_NAME_IS_OK], [m4_ifnblank([$1], [m4_do(
		[m4_bmatch([$1], [^[0-9a-zA-z]$], ,
			[_COLLECTOR_FEEDBACK([The value of short option '$1' for argument '--$2' is not valid - it has to be either left blank, or exactly one character.]m4_ifnblank([$1], [[ (Yours has ]m4_len([$1])[ characters).]]))])],
		[m4_set_contains([_ARGS_SHORT], [$1],
			[_COLLECTOR_FEEDBACK([The short option '$1' (in definition of '--$2') is already used.])],
		)],
	)],
)])



dnl
dnl Checks that the first argument (long option) doesn't contain illegal characters
dnl $1: The long option string (= argument name)
m4_define([_CHECK_ARGUMENT_NAME_IS_VALID], [m4_do(
	[m4_pushdef([_allowed], [-a-zA-Z0-9_])],
	[dnl Should produce the [= etc.] regexp
],
	[m4_bmatch([$1], [^-],
		[_COLLECTOR_FEEDBACK([The option name '$1' is illegal, because it begins with a dash ('-'). Names can contain dashes, but not at the beginning.])])],
	[m4_bmatch([$1], m4_dquote(^_allowed),
		[_COLLECTOR_FEEDBACK([The option name '$1' is illegal, because it contains forbidden characters (i.e. other than: ']m4_dquote(_allowed)[').])])],
	[m4_popdef([_allowed])],
)])


m4_define([_CHECK_ARGNAME_FREE_FATAL],
	[_CHECK_ARGNAME_FREE([$1], [$2], [_COLLECTOR_FEEDBACK])])


dnl
dnl $1: Argument name
dnl $2: The variable name that would hold the argument value
dnl Check whether an argument has not (long or short) options that conflict with already defined args.
dnl Also writes the argname to the right set
m4_define([_CHECK_ARGNAME_FREE], [m4_do(
	[m4_set_contains([_ARGS_LONG], [$2],
		[m4_ifnblank([$1], [$3([Argument name '$1' conflicts with a long option used earlier.])])])],
	[m4_set_contains([_POSITIONALS], [$2],
		[m4_ifnblank([$1], [$3([Argument name '$1' conflicts with a positional argument name used earlier.])])])],
)])


m4_define([_CHECK_POSITIONAL_ARGNAME_IS_FREE], [m4_do(
	[m4_pushdef([_ARG_VAR_NAME], m4_dquote(_translit_var([$1])))],
	[_CHECK_ARGNAME_FREE_FATAL([$1], _ARG_VAR_NAME)],
	[m4_set_add([_POSITIONALS], _ARG_VAR_NAME)],
	[m4_popdef([_ARG_VAR_NAME])],
)])


m4_define([_ENSURE_UNIQUENESS_OF_ARGUMENT_IDENTIFIER], [m4_do(
	[m4_pushdef([_ARG_VAR_NAME], m4_dquote(_translit_var([$1])))],
	[_CHECK_ARGNAME_FREE_FATAL([$1], _ARG_VAR_NAME)],
	[m4_set_add([_ARGS_LONG], _ARG_VAR_NAME)],
	[m4_popdef([_ARG_VAR_NAME])],
)])


dnl
dnl Use using processing an argument that is optional
m4_define([THIS_ARGUMENT_IS_OPTIONAL], [m4_do(
	[m4_define([HAVE_OPTIONAL], 1)],
)])


dnl TODO: Enable error reaction as a callback.
dnl See __ADD_OPTIONAL_ARGUMENT for description of arguments
m4_define([_ADD_OPTIONAL_ARGUMENT_IF_POSSIBLE], [m4_do(
	[_CHECK_ARGUMENT_NAME_IS_VALID([$1])],
	[_CHECK_SHORT_OPTION_NAME_IS_OK([$2], [$1])],
	[m4_list_contains([BLACKLIST], [$1], , [__ADD_OPTIONAL_ARGUMENT($@)])],
)])


dnl
dnl Registers a command, recording its name, type etc.
dnl $1: Long option
dnl $2: Short option (opt)
dnl $3: Help string
dnl $4: Default, pass it through _sh_quote if needed beforehand (opt)
dnl $5: Type (e.g. repeated, incremental, ...)
dnl $6: Bash variable name
m4_define([__ADD_OPTIONAL_ARGUMENT], [m4_do(
	[_ENSURE_UNIQUENESS_OF_ARGUMENT_IDENTIFIER([$1])],
	[m4_pushdef([_arg_varname], [m4_default([$6], [_varname([$1]]))])],
	[_OPT_WRAPPED(_arg_varname)],
	[THIS_ARGUMENT_IS_OPTIONAL],
	[_FILL_IN_VALUES_FOR_AN_OPTIONAL_ARGUMENT([$1], [$3], _arg_varname, [$5], [$2], [$4])],
	[m4_popdef([_arg_varname])],
	[m4_define([_DISTINCT_OPTIONAL_ARGS_COUNT], m4_incr(_DISTINCT_OPTIONAL_ARGS_COUNT))],
)])


dnl TODO: Take the _WRAPPED code and move it one level up

dnl
dnl $1 - the variable where the argument value is collected
m4_define([_POS_WRAPPED], [m4_ifdef([WRAPPED_FILE_STEM],
	[__POS_WRAPPED([$1], m4_expand([_args_prefix[]_translit_var(_GET_BASENAME(WRAPPED_FILE_STEM))]))],
)])

m4_define([__POS_WRAPPED], [m4_do(
	[m4_set_add([_POS_VARNAMES], m4_expand([[$2]_pos_suffix]))],
	[m4_list_append([_WRAPPED_ADD_SINGLE], m4_expand([[$2]_pos_suffix+=([$1])]))],
	[__ANY_WRAPPED([$2])],
)])

m4_define([_OPT_WRAPPED], [m4_ifdef([WRAPPED_FILE_STEM],
	[__OPT_WRAPPED([$1], m4_expand([_args_prefix[]_translit_var(_GET_BASENAME(WRAPPED_FILE_STEM))]))],
)])

m4_define([__OPT_WRAPPED], [m4_do(
	[m4_define([_COLLECT_$1],  [$2]_opt_suffix)],
	[__ANY_WRAPPED([$2])],
)])

m4_define([__ANY_WRAPPED], [m4_do(
	[m4_set_add([_ARGS_GROUPS], [$1])],
)])


argbash_api([ARG_OPTIONAL_SINGLE], _CHECK_PASSED_ARGS_COUNT(1, 4)[m4_do(
	[[$0($@)]],
	[_ADD_OPTIONAL_ARGUMENT_IF_POSSIBLE([$1], [$2], [$3], [$4], [arg])],
)])


dnl
dnl $1 The function to call to get the version
argbash_api([ARG_VERSION], _CHECK_PASSED_ARGS_COUNT(1)[m4_do(
	[dnl Just record how have we called ourselves
],
	[[$0($@)]],
	[m4_bmatch(m4_expand([_W_FLAGS]), [V], ,
		[_ARG_VERSION([$1])])],
)])


dnl
dnl $1: The possibly blank additional message
m4_define([_VERSION_PRINTF_FORMAT], [m4_do(
	[['%s %s\n]],
	[m4_ifnblank([_HELP_MSG], [[\n%s\n]])],
	[m4_ifnblank([$1], [[%s\n]])],
	['],
)])


dnl
dnl $1: The complete version string
dnl $2: The possibly blank additional message
m4_define([_VERSION_PRINTF_ARGS], [m4_do(
	[[$1]],
	[m4_ifnblank([_HELP_MSG], [ 'm4_quote(_HELP_MSG)'])],
	[m4_ifnblank([$2], [[ $2]])],
)])


dnl
dnl $1: The possibly blank additional message
m4_define([_VERSION_PRINTF_COMMAND],
	[[printf] _VERSION_PRINTF_FORMAT([$1]) _VERSION_PRINTF_ARGS(m4_quote("INFERRED_BASENAME" "PROVIDED_VERSION_STRING"), [$1])])


dnl
dnl Try to guess the program name
dnl $1 The version string.
dnl $2 The version message (incl. quotes) to printf past the simple <program> <version> display. (optional), UNDOCUMENTED NON-FEATURE
argbash_api([ARG_VERSION_AUTO], _CHECK_PASSED_ARGS_COUNT(1)[m4_do(
	[[$0($@)]],
	[m4_define([PROVIDED_VERSION_STRING], [m4_expand([$1])])],
	[m4_bmatch(m4_expand([_W_FLAGS]), [V], ,
		[_ARG_VERSION(_VERSION_PRINTF_COMMAND([$2]))])],
)])


m4_define([_ARG_VERSION], [m4_do(
	[dnl The function with underscore doesn't record what we have just recorded
],
	[_ARG_OPTIONAL_ACTION(
		[version],
		[v],
		[Prints version],
		[$1],
	)],
)])


dnl
dnl $1: The main help message
dnl $2: The bottom help message
argbash_api([ARG_HELP], _CHECK_PASSED_ARGS_COUNT(1, 2)[m4_do(
	[dnl Skip help if we declare we don't want it
],
	[[$0($@)]],
	[_IF_W_FLAGS_DONT_CONTAIN([H], [_ARG_HELP([$1], [$2])])],
)])


m4_define([_HELP_MSG])
m4_define([_HELP_MSG_EX])

m4_define([_ARG_HELP], [m4_do(
	[m4_define([_HELP_MSG], [m4_escape([$1])])],
	[m4_define([_HELP_MSG_EX], [m4_escape([$2])])],
	[_ARG_OPTIONAL_ACTION(
		[help],
		[h],
		[Prints help],
		[print_help],
	)],
)])


m4_define([_ARG_OPTIONAL_INCREMENTAL], [_ADD_OPTIONAL_ARGUMENT_IF_POSSIBLE([$1], [$2], [$3], m4_default_quoted([$4], 0), [incr])])


dnl $1: long name
dnl $2: short name (opt)
dnl $3: help
dnl $4: default (=0)
argbash_api([ARG_OPTIONAL_INCREMENTAL], _CHECK_PASSED_ARGS_COUNT(1, 4)[m4_do(
	[[$0($@)]],
	[_ARG_OPTIONAL_INCREMENTAL($@)],
)])


dnl
dnl $1: long name
dnl $2: short name (opt)
dnl $3: help
dnl $4: default (empty array)
argbash_api([ARG_OPTIONAL_REPEATED], _CHECK_PASSED_ARGS_COUNT(1, 4)[m4_do(
	[[$0($@)]],
	[_ADD_OPTIONAL_ARGUMENT_IF_POSSIBLE([$1], [$2], [$3], [$4], [repeated])],
)])


dnl $1: short name (opt)
argbash_api([ARG_VERBOSE], [m4_do(
	[[$0($@)]],
	[_ARG_OPTIONAL_INCREMENTAL([verbose], [$1], [Set verbose output (can be specified multiple times to increase the effect)], 0)],
)])


dnl $1: long name, var suffix (translit of [-] -> _)
dnl $2: short name (opt)
dnl $3: help
dnl $4: default (=off)
argbash_api([ARG_OPTIONAL_BOOLEAN], _CHECK_PASSED_ARGS_COUNT(1, 4)[m4_do(
	[[$0($@)]],
	[m4_ifnblank([$4], [m4_case([$4], [on], , [off], ,
		[_COLLECTOR_FEEDBACK([Problem with argument '$1': Only 'on' or 'off' are allowed as boolean defaults, you have specified '$4'.])])])],
	[_ADD_OPTIONAL_ARGUMENT_IF_POSSIBLE([$1], [$2], [$3],
		m4_default_quoted([$4], [off]), [bool])],
)])


m4_define([_ARG_OPTIONAL_ACTION],
	[_ADD_OPTIONAL_ARGUMENT_IF_POSSIBLE([$1], [$2], [$3], [$4], [action])])


argbash_api([ARG_OPTIONAL_ACTION], [m4_do(
	[[$0($@)]],
	[_ARG_OPTIONAL_ACTION($@)],
)])


dnl
dnl $1: The name of the current argument
m4_define([_CHECK_THAT_NUMBER_OF_PRECEDING_ARGUMENTS_IS_KNOWN], [m4_do(
	[IF_POSITIONALS_INF([_COLLECTOR_FEEDBACK([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_VARIABLE_NUMBER_OF_ARGUMENTS_BEFOREHAND([_COLLECTOR_FEEDBACK([The number of expected positional arguments before '$1' is unknown (because of argument ']_LAST_POSITIONAL_ARGUMENT_WITH_DEFAULT[', which has a default). This is not supported, define arguments that accept fixed number of values first.])], [])],
)])


dnl
dnl Declare one positional argument with default
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: Default (opt.)
argbash_api([ARG_POSITIONAL_SINGLE], _CHECK_PASSED_ARGS_COUNT(1, 3)[m4_do(
	[_CHECK_ARGUMENT_NAME_IS_VALID([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [[$0($@)]_ARG_POSITIONAL_SINGLE($@)])],
)])


m4_define([_DISCARD_VALUES_FOR_ALL_ARGUMENTS], [m4_do(
	[m4_list_destroy([_ARGS_LONG])],
	[m4_list_destroy([_ARGS_HELP])],
	[m4_list_destroy([_ARGS_VARNAME])],
	[m4_list_destroy([_ARGS_POS_OR_OPT])],

	[m4_list_destroy([_ARGS_CATH])],

	[m4_list_destroy([_POSITIONALS_MINS])],
	[m4_list_destroy([_POSITIONALS_MAXES])],
	[m4_list_destroy([_POSITIONALS_DEFAULTS])],

	[m4_list_destroy([_ARGS_SHORT])],
	[m4_list_destroy([_ARGS_DEFAULT])],

	[m4_set_delete([_ARGS_SHORT])],
	[m4_set_delete([_ARGS_LONG])],
	[m4_set_delete([_POSITIONALS])],

	[m4_define([_POSITIONALS_INF], 0)],
	[m4_define([HAVE_POSITIONAL_VARNUM], 0)],
	[m4_define([HAVE_DOUBLEDASH], 0)],
)])


m4_define([_ARG_POSITIONAL_SINGLE], [m4_do(
	[_CHECK_THAT_NUMBER_OF_PRECEDING_ARGUMENTS_IS_KNOWN([$1])],
	[_CHECK_POSITIONAL_ARGNAME_IS_FREE([$1])],
	[_POS_WRAPPED("${_varname([$1])}")],
	[m4_define([_HIGHEST_POSITIONAL_VALUES_COUNT], m4_incr(_HIGHEST_POSITIONAL_VALUES_COUNT))],
	[dnl If we don't have default, also a number of positional args that are needed went up
],
	[m4_ifblank([$3], [m4_do(
			[_DECLARE_THAT_SCRIPT_ACCEPTS_POSITIONAL_ARGUMENTS],
			[_REGISTER_REQUIRED_POSITIONAL_ARGUMENTS([$1], 1)],
			[m4_list_append([_POSITIONALS_MINS], 1)],
			[m4_list_append([_POSITIONALS_DEFAULTS], [])],
		)], [m4_do(
			[_DECLARE_THAT_RANGE_OF_POSITIONAL_ARGUMENTS_IS_ACCEPTED([$1])],
			[m4_list_append([_POSITIONALS_MINS], 0)],
			[m4_list_append([_POSITIONALS_DEFAULTS], [$3])],
		)])],
	[_FILL_IN_VALUES_FOR_A_POSITIONAL_ARGUMENT([$1], [$2], _varname([$1]), [single])],
	[m4_list_append([_POSITIONALS_MAXES], 1)],
)])


dnl
dnl Declare sequence of possibly infinitely many positional arguments
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: How many args at least (opt., default=0)
dnl $4, $5, ...: Defaults (opt., defaults for the 1st, 2nd, ... value past the required minimum)
argbash_api([ARG_POSITIONAL_INF], _CHECK_PASSED_ARGS_COUNT(1)[m4_do(
	[_CHECK_ARGUMENT_NAME_IS_VALID([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [m4_do(
		[[$0($@)]],
		[m4_case(m4_eval($# > 3),
			0, [_ARG_POSITIONAL_INF([$1], [$2], m4_default_quoted([$3], 0))],
			[_ARG_POSITIONAL_INF([$1], [$2], [$3], [], m4_shiftn(3, $@))])],
	)])],
)])


dnl
dnl $1 ... $3: Same as ARG_POSITIONAL_INF
dnl $4: Representation of arg on command-line
dnl $5, ...: Defaults
m4_define([_ARG_POSITIONAL_INF], _CHECK_INTEGER_TYPE(3, [minimal number of arguments])[m4_do(
	[_CHECK_THAT_NUMBER_OF_PRECEDING_ARGUMENTS_IS_KNOWN([$1])],
	[_CHECK_POSITIONAL_ARGNAME_IS_FREE([$1])],
	[_POS_WRAPPED(${_varname([$1])[@]})],
	[m4_define([_POSITIONALS_INF], 1)],
	[dnl We won't have to use stuff s.a. m4_quote(_INF_REPR), but _INF_REPR directly
],
	[m4_define([_INF_REPR], [[$4]])],
	[_FILL_IN_VALUES_FOR_A_POSITIONAL_ARGUMENT([$1], [$2], _varname([$1]), [inf])],
	[_DECLARE_THAT_RANGE_OF_POSITIONAL_ARGUMENTS_IS_ACCEPTED([$1])],
	[m4_pushdef([_min_argn], [[$3]])],
	[m4_define([_INF_ARGN], _min_argn)],
	[m4_define([_INF_VARNAME], [_varname([$1])])],
	[_REGISTER_REQUIRED_POSITIONAL_ARGUMENTS([$1], _min_argn)],
	[m4_list_append([_POSITIONALS_MINS], _min_argn)],
	[m4_list_append([_POSITIONALS_DEFAULTS], [_$1_DEFAULTS])],
	[dnl If there are more than 3 args to this macro, add more stuff to defaults
],
	[m4_if(m4_cmp($#, 4), 1, [m4_list_append([_$1_DEFAULTS], m4_shiftn(4, $@))])],
	[dnl vvv This has to be like this, additional args that are not required are handled differently
],
	[m4_list_append([_POSITIONALS_MAXES], _min_argn)],
	[m4_define([_HIGHEST_POSITIONAL_VALUES_COUNT], m4_eval(_HIGHEST_POSITIONAL_VALUES_COUNT + _min_argn))],
	[m4_popdef([_min_argn])],
)])


dnl
dnl Declare sequence of multiple positional arguments
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: How many args
dnl $4, $5, ...: Defaults (opt.)
argbash_api([ARG_POSITIONAL_MULTI], _CHECK_PASSED_ARGS_COUNT(3)_CHECK_INTEGER_TYPE(3, [actual number of arguments])[m4_do(
	[_CHECK_ARGUMENT_NAME_IS_VALID([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [[$0($@)]_ARG_POSITIONAL_MULTI($@)])],
)])


m4_define([_ARG_POSITIONAL_MULTI], [m4_do(
	[_CHECK_THAT_NUMBER_OF_PRECEDING_ARGUMENTS_IS_KNOWN([$1])],
	[_CHECK_POSITIONAL_ARGNAME_IS_FREE([$1])],
	[_POS_WRAPPED(${_varname([$1])[@]})],
	[m4_define([_HIGHEST_POSITIONAL_VALUES_COUNT], m4_eval(_HIGHEST_POSITIONAL_VALUES_COUNT + [$3]))],
	[_FILL_IN_VALUES_FOR_A_POSITIONAL_ARGUMENT([$1], [$2], _varname([$1]), [more])],
	[dnl Minimal number of args is number of accepted - number of defaults (= $3 - ($# - 3))
],
	[m4_pushdef([_min_argn], m4_eval([$3] - ($# - 3) ))],
	[dnl If we have defaults, we actually accept unknown number of arguments
],
	[m4_if(_min_argn, [$3], , [_DECLARE_THAT_RANGE_OF_POSITIONAL_ARGUMENTS_IS_ACCEPTED([$1])])],
	[m4_list_append([_POSITIONALS_MINS], _min_argn)],
	[_REGISTER_REQUIRED_POSITIONAL_ARGUMENTS([$1], _min_argn)],
	[m4_list_append([_POSITIONALS_MAXES], [$3])],
	[m4_list_append([_POSITIONALS_DEFAULTS], [_$1_DEFAULTS])],
	[m4_if(m4_cmp($#, 3), 1, [m4_list_append([_$1_DEFAULTS], m4_shiftn(3, $@))])],
	[m4_popdef([_min_argn])],
)])


argbash_api([ARG_POSITIONAL_DOUBLEDASH], [m4_do(
	[m4_list_contains([BLACKLIST], [--], , [[$0($@)]_ARG_POSITIONAL_DOUBLEDASH($@)])],
)])


m4_define([_ARG_POSITIONAL_DOUBLEDASH], [m4_do(
	[m4_define([HAVE_DOUBLEDASH], 1)],
)])


dnl
dnl $1: The mode of argument grouping: One of 'none', 'getopts'
argbash_api([ARG_OPTION_STACKING], _CHECK_PASSED_ARGS_COUNT(1)[m4_do(
	[[$0($@)]],
	[m4_define([_OPT_GROUPING_MODE], [[$1]])],
)])


m4_define([_IF_OPT_GROUPING_GETOPT], [m4_if(_OPT_GROUPING_MODE, [getopt], [$1], [$2])])


m4_define([_SET_DIY_MODE],
	[m4_define([_DIY_MODE], 1)])

m4_define([_UNSET_DIY_MODE],
	[m4_define([_DIY_MODE], 0)])


m4_define([_DECLARE_THAT_SCRIPT_ACCEPTS_POSITIONAL_ARGUMENTS], [m4_do(
	[m4_define([HAVE_POSITIONAL], 1)],
)])


dnl
dnl $1: The name
dnl $2: How many times has the argument be repeated
m4_define([_REGISTER_REQUIRED_POSITIONAL_ARGUMENTS], _CHECK_INTEGER_TYPE(2, [the repetition amount])[m4_case([$2],
	0, [], 1, [m4_list_append([_POSITIONALS_REQUIRED], ['$1'])],
	[m4_list_append([_POSITIONALS_REQUIRED], ['$1' ($2 times)])])])


dnl
dnl Call in cases when it is not clear how many positional args to expect.
dnl This is determined by:
dnl  - the nature of the positional argument itself
dnl  - the positional arg has a default (?)
dnl
dnl $1: The argument name of the argument that declares this
m4_define([_DECLARE_THAT_RANGE_OF_POSITIONAL_ARGUMENTS_IS_ACCEPTED], [m4_do(
	[_DECLARE_THAT_SCRIPT_ACCEPTS_POSITIONAL_ARGUMENTS],
	[m4_define([HAVE_POSITIONAL_VARNUM], 1)],
	[m4_define([_LAST_POSITIONAL_ARGUMENT_WITH_DEFAULT], [[$1]])],
)])


m4_set_add([_SET_OF_RESTRICT_VALUES_MODES], [none])
m4_set_add([_SET_OF_RESTRICT_VALUES_MODES], [no-local-options])
m4_set_add([_SET_OF_RESTRICT_VALUES_MODES], [no-any-options])
dnl
dnl Sets the strict mode global
dnl When the strict mode is on, some argument values are blacklisted
argbash_api([ARG_RESTRICT_VALUES], _CHECK_PASSED_ARGS_COUNT(1)[m4_do(
	[[$0($@)]],
	[m4_set_contains([_SET_OF_RESTRICT_VALUES_MODES], [$1], ,
		[_COLLECTOR_FEEDBACK([Invalid strict mode - used '$1', but you have to use one of: ]m4_set_contents([_SET_OF_RESTRICT_VALUES_MODES], [, ]).)])],
	[m4_define([_RESTRICT_VALUES], [[$1]])],
)])


dnl
dnl If specified, request to initialize positional arguments to empty values (if they don't have defaults)
argbash_api([ARG_DEFAULTS_POS], [m4_do(
	[[$0($@)]],
	[m4_define([_MAKE_DEFAULTS_TO_ALL_POSITIONAL_ARGUMENTS], [[yes]])],
)])


argbash_api([ARG_LEFTOVERS],
	[m4_list_contains([BLACKLIST], [leftovers], , [[$0($@)]_ARG_POSITIONAL_INF([leftovers], [$1], [0], [... ])])])


dnl
dnl $1: Stem of file we are wrapping. We expect macro _SCRIPT_$1 to be defined and to contain the full filefilename
dnl $2: What to do if the argument of the ARGBASH_WRAP macro has surprised us - it has not been processed by argbash script.
m4_define([_IF_WRAPPING_FILE_UNEXPECTEDLY],
	[m4_ifndef([_SCRIPT_$1], [$2])])


dnl
dnl Wrap an Argbash-aware script.
dnl In the wrapping script, just point to the location of the wrapping script (template) and specify what options of the script NOT to "inherit".
dnl You can wrap multiple scripts using multiple ARGBASH_WRAP statements.
dnl $1: Stem of file are we wrapping. We expect macro _SCRIPT_$1 to be defined and to contain the full filefilename
dnl $2: Names of blacklisted args (list)
dnl $3: Codes of blacklisted args (string, default is HVI for help + version)
argbash_api([ARGBASH_WRAP], _CHECK_PASSED_ARGS_COUNT(1, 3)[m4_do(
	[[$0($@)]],
	[m4_pushdef([WRAPPED_FILE_STEM], m4_indir([_GROUP_OF_$1]))],
	[m4_pushdef([WRAPPED_SCRIPT_FILENAME], m4_dquote(m4_indir([_SCRIPT_$1])))],
	[m4_list_append([LIST_OF_FILES_WRAPPED], WRAPPED_SCRIPT_FILENAME)],
	[m4_list_append([BLACKLIST], $2)],
	[m4_pushdef([_W_FLAGS], [m4_default_quoted([$3], _DEFAULT_WRAP_FLAGS)])],
	[_IF_WRAPPING_FILE_UNEXPECTEDLY([$1],
		[_COLLECTOR_FEEDBACK([The calling script was supposed to find location of the file with stem '$1' and define it as a macro, but the latter didn't happen.])])],
	[m4_ignore(m4_include(WRAPPED_SCRIPT_FILENAME))],
	[m4_popdef([_W_FLAGS])],
	[m4_list_destroy([BLACKLIST])],
	[m4_popdef([WRAPPED_SCRIPT_FILENAME])],
	[m4_popdef([WRAPPED_FILE_STEM])],
)])


m4_define([MAKE_ARGBASH_WRAP_IMPOSSIBLE], [argbash_api([ARGBASH_WRAP], [_COLLECTOR_FEEDBACK([Argbash wrapping is not supported: $1])])])
