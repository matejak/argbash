dnl We don't like the # comments
m4_changecom()

dnl TODO: Produce command-line completition
dnl TODO: Add manpage generator
dnl TODO: Add app finder wrappers
dnl TODO: Test arg names against m4 builtins etc. for all arg types (and env stuff and prog stuff too)
dnl TODO: Sort out quoting of defaults and inside help strings (proposal for help msgs: terminate the double quoting just before, but make sure that the help msg element is quoted at least in some way).
dnl TODO: Add support for non-standard targets (i.e. variable names)
dnl TODO: Add a guide how to contribute to the documentation
dnl TODO: Sort out the argbash_api macro
dnl TODO: Test for parsing library hidden in a subdirectory / having an absolute path(?)
dnl  - check out the INCLUDE_PARSING_CODE macro
dnl  - check out argbash script that has to be able to find it
dnl TODO: Add normalize-args utility --- given described script's command-line, simplify it.
dnl
dnl vvvvvvvvvvvvvvv
dnl TODO: Optimize the _CHECK_PASSED_VALUE_AGAINST_BLACKLIST calls
dnl TODO: Support custom error messages
dnl TODO: Make positional args check optional - make it a function(n_positionals, n_expected, what is expected, msg[when less args], [msg when more args])
dnl TODO: Introduce alternative REPEATED/INCREMENTAL version of macros (add and replace mode with respect to defaults)
dnl
dnl WIP vvvvvvvvvvvvvvv
dnl
dnl Redesign intermediate layer: Arguments have long, short options, positional/optional, help msg, default, varname, type, ???
dnl
dnl Arg groups:
dnl name is used both in help and internally as an ID
dnl two arguments of different types may not have same type (e.g. choices and file).
dnl if two different choices type have the same name, behavior is undefined.
dnl ARGS_TYPE_CHOICES([list of args], [name], [value1], [value2], ...)
dnl
dnl flags: R, W, X, D --- search only for existing files (dirs)
dnl ARGS_TYPE_FILE([list of args], [fname], [flags])
dnl
dnl ARGS_TYPE_OUTFILE([list of args], [fname])
dnl Filename that may exist (file must be W) or may not exist (then the dirname of the file must be W)
dnl
dnl flags: -+0, defautlt is exactly -+0
dnl ARGS_TYPE_INTEGER([list of args], [flags])
dnl ARGS_TYPE_FLOAT([list of args])
dnl typeid: int for integer, uint for non-negative integer, float for whatever
dnl ARGS_TYPE_CUSTOM([list of args], [name], [shell function name - optional])


m4_define([_MAKE_DEFAULTS_TO_ALL_POSITIONAL_ARGUMENTS], [[no]])
m4_define([_IF_MAKE_DEFAULTS_TO_ALL_POSITIONAL_ARGUMENTS], [m4_if(_MAKE_DEFAULTS_TO_ALL_POSITIONAL_ARGUMENTS,
	[yes], [$1],
	[$2])])


dnl
dnl Checks that the an argument is a correct short option arg
dnl $1: The short option "string"
dnl $2: The argument name
m4_define([_CHECK_SHORT_OPT_TYPE], [m4_do(
	[m4_ifnblank([$1], [m4_bmatch([$1], [^[0-9a-zA-z]$], ,
		[m4_fatal([The value of short option '$1' for argument '--$2' is not valid - it has to be either left blank, or exactly one character.]m4_ifnblank([$1], [[ (Yours has ]m4_len([$1])[ characters).]]))])])],
)])


dnl
dnl Checks that the first argument (long option) doesn't contain illegal characters
dnl $1: The long option string
m4_define([_CHECK_OPTION_NAME], [m4_do(
	[m4_pushdef([_allowed], [-a-zA-Z0-9_])],
	[dnl Should produce the [= etc.] regexp
],
	[m4_bmatch([$1], [^-],
		[m4_fatal([The option name '$1' is illegal, because it begins with a dash ('-'). Names can contain dashes, but not at the beginning.])])],
	[m4_bmatch([$1], m4_dquote(^_allowed),
		[m4_fatal([The option name '$1' is illegal, because it contains forbidden characters (i.e. other than: ']m4_dquote(_allowed)[').])])],
	[m4_popdef([_allowed])],
)])


dnl We include the version-defining macro
m4_define([_ARGBASH_VERSION], m4_default_quoted(m4_normalize(m4_sinclude([version])), [unknown]))



dnl
dnl The operation on command names that makes stem of variable names
dnl Since each call of _translit_var etc. strips one level of quoting, we have to quote $1 more than usually
m4_define([_translit_var], [m4_translit(m4_translit([[[$1]]], [A-Z], [a-z]), [-], [_])])
m4_define([_translit_prog], [m4_translit(m4_translit([[[$1]]], [a-z], [A-Z]), [-], [_])])


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
dnl Encloses string into "" if its first char is not ' or "
dnl The string is also []-quoted
dnl Property: Quoting a blank input results in blank result
dnl to AVOID it, pass string like ""ls -l or "ls" -l
dnl $1: String to quote
m4_define([_sh_quote], [m4_do(
	[m4_if(
		[$1], , ,
		m4_index([$1], [']), 0, [[$1]],
		m4_index([$1], ["]), 0, [[$1]],
		[["$1"]])],
)])


dnl
dnl Same as _sh_quote, except Quoting a blank input results in pair of quotes
dnl $1: String to quote
m4_define([_sh_quote_also_blanks], [m4_do(
	[m4_if(
		m4_index([$1], [']), 0, [[$1]],
		m4_index([$1], ["]), 0, [[$1]],
		[["$1"]])],
)])


dnl
dnl $1: Argument name
dnl $2: The variable name that would hold the argument value
dnl Check whether an argument has not (long or short) options that conflict with already defined args.
dnl Also writes the argname to the right set
m4_define([_CHECK_ARGNAME_FREE], [m4_do(
	[m4_set_contains([_ARGS_LONG], [$2],
		[m4_ifnblank([$1], [m4_fatal([Argument name '$1' conflicts with a long option used earlier.])])])],
	[m4_set_contains([_POSITIONALS], [$2],
		[m4_ifnblank([$1], [m4_fatal([Argument name '$1' conflicts with a positional argument name used earlier.])])])],
)])


m4_define([_CHECK_POSITIONAL_ARGNAME_IS_FREE], [m4_do(
	[m4_pushdef([_ARG_VAR_NAME], m4_dquote(_translit_var([$1])))],
	[_CHECK_ARGNAME_FREE([$1], _ARG_VAR_NAME)],
	[m4_set_add([_POSITIONALS], _ARG_VAR_NAME)],
	[m4_popdef([_ARG_VAR_NAME])],
)])


m4_define([_CHECK_OPTIONAL_ARGNAME_IS_FREE], [m4_do(
	[m4_pushdef([_ARG_VAR_NAME], m4_dquote(_translit_var([$1])))],
	[_CHECK_ARGNAME_FREE([$1], _ARG_VAR_NAME)],
	[m4_set_add([_ARGS_LONG], _ARG_VAR_NAME)],
	[m4_popdef([_ARG_VAR_NAME])],
)])


m4_define([_some_opt], [m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[_CHECK_SHORT_OPT_TYPE([$2], [$1])],
	[m4_list_contains([BLACKLIST], [$1], , [__ADD_OPTIONAL_ARGUMENT($@)])],
)])


dnl
dnl Registers a command, recording its name, type etc.
dnl $1: Long option
dnl $2: Short option (opt)
dnl $3: Help string
dnl $4: Default, pass it through _sh_quote if needed beforehand (opt)
dnl $5: Type
dnl $6: Bash variable name
m4_define([__ADD_OPTIONAL_ARGUMENT], [m4_do(
	[_CHECK_OPTIONAL_ARGNAME_IS_FREE([$1])],
	[m4_pushdef([_arg_varname], [m4_default([$6], [_varname([$1]]))])],
	[_OPT_WRAPPED(_arg_varname)],
	[m4_ifdef([WRAPPED], [m4_do(
		[m4_set_add([_ARGS_GROUPS], m4_expand([_args_prefix[]_translit_var(WRAPPED)]))],
		[m4_define([_COLLECT_]_varname([$1]),  _args_prefix[]_translit_var(WRAPPED)[]_opt_suffix)],
	)])],
	[m4_list_append([_ARGS_LONG], [$1])],
	[m4_list_append([_ARGS_SHORT], [$2])],
	[m4_set_contains([_ARGS_SHORT], [$2],
		[m4_ifnblank([$2], [m4_fatal([The short option '$2' (in definition of '--$1') is already used.])])],
		[m4_set_add([_ARGS_SHORT], [$2])])],
	[m4_list_append([_ARGS_HELP], [$3])],
	[m4_list_append([_ARGS_DEFAULT], [$4])],
	[m4_list_append([_ARGS_CATH], [$5])],
	[m4_list_append([_ARGS_VARNAME], _arg_varname)],
	[m4_popdef([_arg_varname])],
	[m4_define([_DISTINCT_OPTIONAL_ARGS_COUNT], m4_incr(_DISTINCT_OPTIONAL_ARGS_COUNT))],
)])


m4_define([_DISTINCT_OPTIONAL_ARGS_COUNT], 0)
dnl How many values of positional arguments is the generated script required to receive when called.
m4_define([_MINIMAL_POSITIONAL_VALUES_COUNT], 0)
dnl Greatest number of positional args the script can accept (infinite number of args is handled in parallel)
m4_define([_HIGHEST_POSITIONAL_VALUES_COUNT], 0)
dnl We expect infinitely many args (keep in mind that we still need _HIGHEST_POSITIONAL_VALUES_COUNT)
m4_define([_POSITIONALS_INF], 0)


dnl
dnl Use using processing an argument that is positional
m4_define([_DECLARE_THAT_SCRIPT_ACCEPTS_POSITIONAL_ARGUMENTS], [m4_do(
	[m4_define([HAVE_POSITIONAL], 1)],
)])


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


dnl
dnl Use using processing an argument that is optional
m4_define([THIS_ARGUMENT_IS_OPTIONAL], [m4_do(
	[m4_define([HAVE_OPTIONAL], 1)],
)])


dnl Do something depending on whether there is already infinitely many args possible or not
m4_define([IF_POSITIONALS_INF],
	[m4_if(m4_quote(_POSITIONALS_INF), 1, [$1], [$2])])


dnl Do something depending on whether there have been optional positional args declared beforehand or not
m4_define([IF_POSITIONALS_VARNUM],
	[m4_ifdef([HAVE_POSITIONAL_VARNUM], [$1], [$2])])


dnl
dnl $1: The name of the current argument
m4_define([_CHECK_THAT_NUMBER_OF_PRECEDING_ARGUMENTS_IS_KNOWN], [m4_do(
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([The number of expected positional arguments before '$1' is unknown (because of argument ']_LAST_POSITIONAL_ARGUMENT_WITH_DEFAULT[', which has a default). This is not supported, define arguments that accept fixed number of values first.])], [])],
)])

dnl
dnl $1 - the variable where the argument value is collected
m4_define([_POS_WRAPPED], [m4_ifdef([WRAPPED],
	[__POS_WRAPPED([$1], m4_expand([_args_prefix[]_translit_var(WRAPPED)]))],
)])

m4_define([__POS_WRAPPED], [m4_do(
	[m4_set_add([_POS_VARNAMES], m4_expand([[$2]_pos_suffix]))],
	[m4_list_append([_WRAPPED_ADD_SINGLE], m4_expand([[$2]_pos_suffix+=([$1])]))],
	[__ANY_WRAPPED([$2])],
)])

m4_define([_OPT_WRAPPED], [m4_ifdef([WRAPPED],
	[__OPT_WRAPPED([$1], m4_expand([_args_prefix[]_translit_var(WRAPPED)]))],
)])

m4_define([__OPT_WRAPPED], [m4_do(
	[m4_define([_COLLECT_$1],  [$2]_opt_suffix)],
	[__ANY_WRAPPED([$2])],
)])

m4_define([__ANY_WRAPPED], [m4_do(
	[m4_set_add([_ARGS_GROUPS], [$1])],
)])

dnl
dnl Declare one positional argument with default
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: Default (opt.)
argbash_api([ARG_POSITIONAL_SINGLE], _CHECK_PASSED_ARGS_COUNT(1, 3)[m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [[$0($@)]_ARG_POSITIONAL_SINGLE($@)])],
)])


m4_define([_ARG_POSITIONAL_SINGLE], [m4_do(
	[_CHECK_THAT_NUMBER_OF_PRECEDING_ARGUMENTS_IS_KNOWN([$1])],
	[_CHECK_POSITIONAL_ARGNAME_IS_FREE([$1])],
	[_POS_WRAPPED("${_varname([$1])}")],
	[dnl Number of possibly supplied positional arguments just went up
],
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
			[m4_list_append([_POSITIONALS_DEFAULTS], _sh_quote([$3]))],
		)])],
	[m4_list_append([_POSITIONALS_MAXES], 1)],
	[m4_list_append([_POSITIONALS_NAMES], [$1])],
	[m4_list_append([_POSITIONAL_CATHS], [single])],
	[m4_list_append([_POSITIONALS_MSGS], [$2])],
	[dnl Here, the _sh_quote actually does not ensure that the default is NOT BLANK!
],
)])


dnl
dnl Declare sequence of possibly infinitely many positional arguments
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: How many args at least (opt., default=0)
dnl $4, $5, ...: Defaults (opt., defaults for the 1st, 2nd, ... value past the required minimum)
argbash_api([ARG_POSITIONAL_INF], _CHECK_PASSED_ARGS_COUNT(1)[m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [m4_do(
		[[$0($@)]],
		[m4_case(m4_eval($# > 3),
			0, [_ARG_POSITIONAL_INF([$1], [$2], m4_default([$3], 0))],
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
	[_POS_WRAPPED(${_varname([$1])@<:@@@:>@})],
	[m4_define([_POSITIONALS_INF], 1)],
	[dnl We won't have to use stuff s.a. m4_quote(_INF_REPR), but _INF_REPR directly
],
	[m4_define([_INF_REPR], [[$4]])],
	[m4_list_append([_POSITIONALS_NAMES], [$1])],
	[m4_list_append([_POSITIONAL_CATHS], [inf])],
	[m4_list_append([_POSITIONALS_MSGS], [$2])],
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
dnl $1: The name
dnl $2: How many times has the argument be repeated
m4_define([_REGISTER_REQUIRED_POSITIONAL_ARGUMENTS], _CHECK_INTEGER_TYPE(2, [the repetition amount])[m4_case([$2],
	0, [], 1, [m4_list_append([_POSITIONALS_REQUIRED], ['$1'])],
	[m4_list_append([_POSITIONALS_REQUIRED], ['$1' ($2 times)])])])


dnl
dnl Declare sequence of multiple positional arguments
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: How many args
dnl $4, $5, ...: Defaults (opt.)
argbash_api([ARG_POSITIONAL_MULTI], _CHECK_PASSED_ARGS_COUNT(3)_CHECK_INTEGER_TYPE(3, [actual number of arguments])[m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [[$0($@)]_ARG_POSITIONAL_MULTI($@)])],
)])


m4_define([_ARG_POSITIONAL_MULTI], [m4_do(
	[_CHECK_THAT_NUMBER_OF_PRECEDING_ARGUMENTS_IS_KNOWN([$1])],
	[_CHECK_POSITIONAL_ARGNAME_IS_FREE([$1])],
	[_POS_WRAPPED(${_varname([$1])@<:@@@:>@})],
	[m4_define([_HIGHEST_POSITIONAL_VALUES_COUNT], m4_eval(_HIGHEST_POSITIONAL_VALUES_COUNT + [$3]))],
	[m4_list_append([_POSITIONALS_NAMES], [$1])],
	[m4_list_append([_POSITIONAL_CATHS], [more])],
	[m4_list_append([_POSITIONALS_MSGS], [$2])],
	[dnl Minimal number of args is number of accepted - number of defaults (= $3 - ($# - 3))
],
	[m4_pushdef([_min_argn], m4_eval([$3] - ($# - 3) ))],
	[dnl If we have defaults, we actually accept unknown number of arguments
],
	[m4_if(_min_argn, [$3], , [_DECLARE_THAT_RANGE_OF_POSITIONAL_ARGUMENTS_IS_ACCEPTED([$1])])],
	[m4_list_append([_POSITIONALS_MINS], _min_argn)],
	[_REGISTER_REQUIRED_POSITIONAL_ARGUMENTS([$1], _min_argn)],
	[m4_list_append([_POSITIONALS_MAXES], [$3])],
	[dnl Here, the _sh_quote actually ensures that the default is NOT BLANK!
],
	[m4_list_append([_POSITIONALS_DEFAULTS], [_$1_DEFAULTS])],
	[m4_if(m4_cmp($#, 3), 1, [m4_list_append([_$1_DEFAULTS], m4_shiftn(3, $@))])],
	[m4_popdef([_min_argn])],
)])


argbash_api([ARG_OPTIONAL_SINGLE], _CHECK_PASSED_ARGS_COUNT(1, 4)[m4_do(
	[[$0($@)]],
	[THIS_ARGUMENT_IS_OPTIONAL],
	[_some_opt([$1], [$2], [$3], _sh_quote([$4]), [arg])],
)])


argbash_api([ARG_POSITIONAL_DOUBLEDASH], [m4_do(
	[m4_list_contains([BLACKLIST], [--], , [[$0($@)]_ARG_POSITIONAL_DOUBLEDASH($@)])],
)])


m4_define([_ARG_POSITIONAL_DOUBLEDASH], [m4_do(
	[m4_define([HAVE_DOUBLEDASH], 1)],
)])


dnl
dnl $1 The function to call to get the version
argbash_api([ARG_VERSION], _CHECK_PASSED_ARGS_COUNT(1)[m4_do(
	[dnl Just record how have we called ourselves
],
	[[$0($@)]],
	[m4_bmatch(m4_expand([_W_FLAGS]), [V], ,[_ARG_VERSIONx([$1])])],
)])


m4_define([_ARG_VERSIONx], [m4_do(
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
	[m4_bmatch(m4_expand([_W_FLAGS]), [H], ,[_ARG_HELPx([$1], [$2])])],
)])


m4_define([_HELP_MSG])
m4_define([_HELP_MSG_EX])
dnl TODO: If the name is _ARG_HELP and not _ARG_HELPx, it doesn't work. WTF!?
m4_define([_ARG_HELPx], [m4_do(
	[m4_define([_HELP_MSG], [m4_escape([$1])])],
	[m4_define([_HELP_MSG_EX], [m4_escape([$2])])],
	[_ARG_OPTIONAL_ACTION(
		[help],
		[h],
		[Prints help],
		[print_help],
	)],
)])


dnl
dnl Just define name of the script dir variable
m4_define([_DEFAULT_SCRIPTDIR], [[script_dir]])


dnl
dnl In your script, include just this directive (and DEFINE_SCRIPT_DIR before) to include the parsing stuff from a standalone file.
dnl The argbash script generator will pick it up and (re)generate that one as well
dnl
dnl $1: the filename (assuming that it is in the same directory as the script)
dnl $2: what has been passed to DEFINE_SCRIPT_DIR as the first param
argbash_api([INCLUDE_PARSING_CODE], _CHECK_PASSED_ARGS_COUNT(1, 2)[m4_do(
	[[$0($@)]],
	[m4_ifndef([SCRIPT_DIR_DEFINED], [m4_fatal([You have to use 'DEFINE_SCRIPT_DIR' before '$0'.])])],
	[m4_list_append([_OTHER],
		m4_expand([[. "$]m4_default([$2], _DEFAULT_SCRIPTDIR)[/$1]"  [# '.' means 'source'
]]))],
)])


dnl
dnl $1: Name of the holding variable
dnl Taken from: http://stackoverflow.com/a/246128/592892
argbash_api([DEFINE_SCRIPT_DIR], [m4_do(
	[[$0($@)]],
	[m4_define([SCRIPT_DIR_DEFINED])],
	[m4_pushdef([_sciptdir], m4_ifnblank([$1], [[$1]], _DEFAULT_SCRIPTDIR))],
	[m4_list_append([_OTHER],
		m4_quote(_sciptdir[="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || die "Couldn't determine the script's running directory, which probably matters, bailing out" 2]))],
	[m4_popdef([_sciptdir])],
)])


dnl TODO: This looks a bit like a nightmare
dnl Precedence is important, _CALL_SOME_OPT has to be defined early on
m4_define([_CALL_SOME_OPT], [[_some_opt([$1], [$2], [$3], [$4], [$5])]])

m4_define([_ARG_OPTIONAL_INCREMENTAL_BODY],
	[_CALL_SOME_OPT($[]1, $[]2, $[]3, [m4_default($][4, 0)], [incr])])
m4_define([_ARG_OPTIONAL_INCREMENTAL], [THIS_ARGUMENT_IS_OPTIONAL[]]_ARG_OPTIONAL_INCREMENTAL_BODY)


dnl $1: long name
dnl $2: short name (opt)
dnl $3: help
dnl $4: default (=0)
argbash_api([ARG_OPTIONAL_INCREMENTAL], _CHECK_PASSED_ARGS_COUNT(1, 4)[m4_do(
	[[$0($@)]],
	[THIS_ARGUMENT_IS_OPTIONAL],
	]m4_dquote(_ARG_OPTIONAL_INCREMENTAL_BODY)[,
)])

m4_define([_ARG_OPTIONAL_REPEATED_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, ($[]4), [repeated])])

dnl $1: long name
dnl $2: short name (opt)
dnl $3: help
dnl $4: default (empty array)
argbash_api([ARG_OPTIONAL_REPEATED], _CHECK_PASSED_ARGS_COUNT(1, 4)[m4_do(
	[[$0($@)]],
	[THIS_ARGUMENT_IS_OPTIONAL],
	]m4_dquote(_ARG_OPTIONAL_REPEATED_BODY)[,
)])


dnl $1: short name (opt)
argbash_api([ARG_VERBOSE], [m4_do(
	[[$0($@)]],
	[THIS_ARGUMENT_IS_OPTIONAL],
	[_ARG_OPTIONAL_INCREMENTAL([verbose], [$1], [Set verbose output (can be specified multiple times to increase the effect)], 0)],
)])


dnl $1: long name, var suffix (translit of [-] -> _)
dnl $2: short name (opt)
dnl $3: help
dnl $4: default (=off)
argbash_api([ARG_OPTIONAL_BOOLEAN], _CHECK_PASSED_ARGS_COUNT(1, 4)[m4_do(
	[[$0($@)]],
	[THIS_ARGUMENT_IS_OPTIONAL],
	[_some_opt([$1], [$2], [$3],
		m4_default([$4], [off]), [bool])],
)])


m4_define([_ARG_OPTIONAL_ACTION_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, $[]4, [action])])


argbash_api([ARG_OPTIONAL_ACTION], [m4_do(
	[[$0($@)]],
	[THIS_ARGUMENT_IS_OPTIONAL],
	[dnl Just call _ARG_OPTIONAL_ACTION with same args
],
	]m4_dquote(_ARG_OPTIONAL_ACTION_BODY)[,
)])


m4_define([_ARG_OPTIONAL_ACTION], [THIS_ARGUMENT_IS_OPTIONAL[]]_ARG_OPTIONAL_ACTION_BODY)


dnl
dnl $1: argname
dnl $2: _arg_type
dnl $3: _min_argn
dnl $4: _max_argn
dnl In case of 'inf': If _INF_REPR is not blank, use it, otherwise compose the command-line yourself
m4_define([_POS_ARG_HELP_LINE], [m4_do(
	[m4_case([$2],
		[single], [m4_list_append([_POSITIONALS_LIST], m4_if([$3], 0,
			[[@<:@<$1>@:>@]], [[<$1>]]))],
		[more], [m4_do(
			[m4_if([$3], 0, ,
				[m4_for([idx2], 1, [$3], 1,
					[m4_list_append([_POSITIONALS_LIST], m4_expand([[<$1-]idx2>]))])])],
			[m4_if([$3], [$4], ,
				[m4_for([idx2], m4_incr([$3]), [$4], 1,
					[m4_list_append([_POSITIONALS_LIST], m4_expand([[@<:@<$1-]idx2>@:>@]))])])])],
		[inf], [m4_ifnblank(_INF_REPR, [m4_list_append([_POSITIONALS_LIST], _INF_REPR)], [m4_do(
			[m4_if([$3], 0, ,
				[m4_for([idx2], 1, [$3], 1,
					[m4_list_append([_POSITIONALS_LIST], m4_expand([[<$1-]idx2>]))])])],
			[m4_list_append([_POSITIONALS_LIST],
				m4_expand([[@<:@<$1-]m4_incr($3)>@:>@]),
				[...],
				[@<:@<$1-n>@:>@],
				[...])])])],
	[m4_fatal([$0: Unhandled arg type '$2' of arg '$1'])])],
)])


dnl
dnl $1: argname macro
dnl $2: _arg_type
dnl $3: _min_argn
dnl $4: _defaults
m4_define([_FORMAT_DEFAULTS_FOR_MULTIVALUED_ARGUMENTS], [m4_do(
	[m4_list_ifempty([$4], , [m4_do(
		[[ @{:@defaults for ]$1(m4_incr([$3]))],
		[m4_if(m4_list_len([$4]), 1, ,
			[[ to ]$1(m4_eval([$3] + m4_list_len([$4])))[ respectively]])],
		[: ],
		[m4_list_join([$4], [, ], ', ', [ and ])@:}@],
	)])],
)])


dnl
dnl $1: argname macro
dnl $2: _arg_type
dnl $3: _min_argn
dnl $4: _defaults
m4_define([_POS_ARG_HELP_DEFAULTS], [m4_do(
	[dnl We have to double-quote $4 (and underlying stuff) since they are expanded by two macros, so two quotes get stripped.
],
	[m4_case([$2],
		[single],
			[m4_if([$3], 0, [[ @{:@default: '"$4"'@:}@]])],
		[more], [_FORMAT_DEFAULTS_FOR_MULTIVALUED_ARGUMENTS([$1], [$2], [$3], [$4])],
		[inf], [_FORMAT_DEFAULTS_FOR_MULTIVALUED_ARGUMENTS([$1], [$2], [$3], [$4])],
	[m4_fatal([$0: Unhandled arg type: '$2'])])],
)])


dnl
dnl $1: _argname
dnl $2: short arg
dnl
dnl Returns either --long or -l|--long if there is that -l
m4_define([_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE], [m4_do(
	[m4_ifnblank([$2],
		[-$2|])],
	[[--$1]],
)])


m4_define([_IF_HAVE_OPTIONAL],
	[m4_if(HAVE_OPTIONAL, 1, [$1], [$2])])


m4_define([_IF_DIY_MODE],
	[m4_if(_DIY_MODE, 1, [$1], [$2])])

m4_define([_SET_DIY_MODE],
	[m4_define([_DIY_MODE], 1)])

m4_define([_UNSET_DIY_MODE],
	[m4_define([_DIY_MODE], 0)])

m4_define([_IF_HAVE_POSITIONAL],
	[m4_if(HAVE_POSITIONAL, 1, [$1], [$2])])


m4_define([_IF_SOME_POSITIONAL_VALUES_ARE_EXPECTED],
	[m4_if(_MINIMAL_POSITIONAL_VALUES_COUNT, 0, [$2], [$1])])


m4_define([_MAKE_HELP_SYNOPSIS], [m4_do(
	[_IF_HAVE_OPTIONAL([m4_lists_foreach([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH], [_argname,_arg_short,_arg_type], [m4_do(
		[ @<:@],
		[m4_case(_arg_type,
			[bool], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE([(no-)]_argname, _arg_short)],
			[arg], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE(_argname, _arg_short)[]_DELIM_IN_HELP[<]_GET_VALUE_STR(_argname)>],
			[repeated], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE(_argname, _arg_short)[]_DELIM_IN_HELP[<]_GET_VALUE_STR(_argname)>],
			[_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_MESSAGE(_argname, _arg_short)])],
		[@:>@],
	)])])],
	[m4_if(HAVE_DOUBLEDASH, 1, [[ @<:@--@:>@]])],
	[dnl If we have positionals, display them like <pos1> <pos2> ...
],
	[m4_if(HAVE_POSITIONAL, 1, [m4_do(
		[m4_lists_foreach([_POSITIONALS_NAMES,_POSITIONALS_MINS,_POSITIONALS_MAXES,_POSITIONAL_CATHS], [argname,_min_argn,_max_argn,_arg_type],
			[_POS_ARG_HELP_LINE(argname, _arg_type, _min_argn, _max_argn)])],
		[ m4_expand(m4_join([ ], m4_list_contents([_POSITIONALS_LIST])))],
	)])],
)])


m4_define([_MAKE_HELP_FUNCTION_POSITIONAL_PART], [m4_lists_foreach(
	[_POSITIONALS_NAMES,_POSITIONAL_CATHS,_POSITIONALS_MINS,_POSITIONALS_DEFAULTS,_POSITIONALS_MSGS],
	[argname0,_arg_type,_min_argn,_defaults,_msg], [m4_ifnblank(_msg, [m4_do(
	[dnl We would like something else for argname if the arg type is 'inf' and _INF_VARNAME is not empty
],
	[m4_pushdef([argname1], <m4_dquote(argname0)[[]m4_ifnblank(m4_quote($][1), m4_quote(-$][1))]>)],
	[m4_pushdef([argname], m4_if(_arg_type, [inf], [m4_default(_INF_REPR, argname1)], [[argname1($][@)]]))],
	[_INDENT_()[printf "\t%s\n" "]argname[: ]_SUBSTITUTE_LF_FOR_NEWLINE_AND_INDENT(_msg)],
	[_POS_ARG_HELP_DEFAULTS([argname], _arg_type, _min_argn, _defaults)],
	[m4_popdef([argname])],
	[m4_popdef([argname1])],
	["
],
)])])])


m4_define([_MAKE_HELP_FUNCTION_OPTIONAL_PART], [m4_lists_foreach(
	[_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH,_ARGS_DEFAULT,_ARGS_VARNAME,_ARGS_HELP],
	[_argname,_arg_short,_arg_type,_default,_arg_varname,_arg_help],
	[m4_ifnblank(_arg_help, [m4_do(
		[_INDENT_()printf "\t%s\n" "],
		[dnl Display a short one if it is not blank
],
		[m4_ifnblank(_arg_short, -_arg_short[,])],
		[dnl Long one is never blank
],
		[--_argname],
		[dnl Bool have a long beginning with --no-
],
		[m4_case(_arg_type, [bool], [,--no-]_argname)],
		[: _SUBSTITUTE_LF_FOR_NEWLINE_AND_INDENT(_arg_help)],
		[dnl Actions don't have defaults
],
		[dnl We save the default to a temp var whichwe expand later.
],
		[m4_pushdef([_default_val],
			[m4_expand([m4_case(_arg_type,
				[action], [],
				[incr], [],
				[bool], [_default[ by default]],
				[repeated], [m4_if(_default, [()], [[empty by default]], [[default array: ]m4_bpatsubst(_default, ", \\") ])],
				[m4_ifblank(_default, [[no default]], [[default: ]'_default'])])])])],
		[m4_pushdef([_type_spec],
			[m4_expand([m4_case(_GET_VALUE_TYPE(_argname),
				[generic], [],
				[string], [],
				[_GET_VALUE_DESC(_argname)])])])],
		[m4_ifnblank(m4_quote(_default_val _type_spec), [m4_do(
			[[ @{:@]],
			[m4_ifnblank(m4_quote(_type_spec), m4_expand([_type_spec])m4_ifnblank(m4_quote(_default_val), [; ]))],
			[m4_expand([_default_val])],
			[[@:}@]],
		)])],
		[m4_popdef([_type_spec])],
		[m4_popdef([_default_val])],
		["
],
		[dnl Single: We are already quoted
],
)])])])


m4_define([_MAKE_HELP_FUNCTION_ENVVARS_PART], [m4_do(
	[m4_lists_foreach([ENV_NAMES,ENV_DEFAULTS,ENV_HELPS], [_name,_default,_help], [m4_do(
		[m4_ifnblank(_help, [m4_list_append([LIST_ENV_HELP], m4_expand([m4_do(
			[m4_expand([_name: _help.])],
			[m4_ifnblank(_default, [ (default: ']_default'))],
		)]))])],
	)])],
	[printf '\nEnvironment variables that are supported:\n'
],
	[m4_list_foreach([LIST_ENV_HELP], [_msg], [printf "\t%s\n" "[]_msg"
])],
)])


m4_define([_MAKE_ARGS_STACKING_HELP_PRINT_IF_NEEDED], [m4_do(
	[m4_pushdef([message], m4_dquote(_MAKE_ARGS_STACKING_HELP_MESSAGE))],
	[m4_ifnblank(message, [_JOIN_INDENTED(1,
		[echo],
		[echo 'message'],
	)])],
	[m4_popdef([message])],
)])


m4_define([_MAKE_ARGS_STACKING_HELP_MESSAGE], [m4_do(
	[m4_case(_OPT_GROUPING_MODE,
		[none], [[Short options stacking mode is not supported.]],
		[getopt], [[]],
	)],
)])


m4_define([_MAKE_HELP], [m4_do(
	[_COMM_BLOCK(0,
		[# Function that prints general usage of the script.],
		[# This is useful if users asks for it, or if there is an argument parsing error (unexpected / spurious arguments)],
		[# and it makes sense to remind the user how the script is supposed to be called.],
	)],
	[print_help ()
{
],
	[m4_ifnblank(m4_expand([_HELP_MSG]), m4_dquote(_INDENT_()[printf] "%s\n" "_SUBSTITUTE_LF_FOR_NEWLINE_AND_INDENT(_HELP_MSG)"
))],
	[_INDENT_()[]printf 'Usage: %s],
	[dnl If we have optionals, display them like [--opt1 arg] [--(no-)opt2] ... according to their type. @<:@ becomes square bracket at the end of processing
],
	[_MAKE_HELP_SYNOPSIS],
	[\n' "@S|@0"
],
	[m4_if(HAVE_POSITIONAL, 1, [_MAKE_HELP_FUNCTION_POSITIONAL_PART])],
	[dnl If we have 0 optional args, don't do anything (FOR loop would assert, 0 < 1)
],
	[dnl Plus, don't display extended help for an arg if it doesn't have a description
],
	[m4_if(_DISTINCT_OPTIONAL_ARGS_COUNT, 0, , [_MAKE_HELP_FUNCTION_OPTIONAL_PART])],
	[dnl Print a more verbose help message to the end of the help (if requested)
],
	[m4_list_ifempty([ENV_NAMES], ,[_MAKE_HELP_FUNCTION_ENVVARS_PART
])],
	[_MAKE_ARGS_STACKING_HELP_PRINT_IF_NEEDED],
	[m4_ifnblank(m4_quote(_HELP_MSG_EX), m4_dquote(_INDENT_()[printf "\n%s\n" "]_HELP_MSG_EX"
))],
	[}
],
)])


dnl
dnl $1: Arg name
dnl $2: Short arg name (not used here)
dnl $3: Name of the value-to-variable macro
dnl $4: The name of the argument-holding variable
m4_define([_VAL_OPT_ADD_SPACE_WITHOUT_GETOPT_OR_SHORT_OPT], [_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
	[test $[]# -lt 2 && die "Missing value for the optional argument '$_key'." 1],
	[$3([$1], ["@S|@2"], [$4])],
	[shift],
	[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY([$4], $[$4])],
)])


dnl
dnl $1: Arg name
dnl $2: Action - the variable containing the value to assign is '_val'
dnl $3: Name of the value-to-variable macro
dnl $4: The name of the argument-holding variable
m4_define([_VAL_OPT_ADD_EQUALS_WITH_LONG_OPT], [_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
	[$3([$1], ["${_key##--$1=}"], [$4])],
	[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY([$4], $[$4])],
)])


dnl
dnl $1: Arg name
dnl $2: Short arg name
dnl $3: Name of the value-to-variable macro
dnl $4: The name of the argument-holding variable
m4_define([_VAL_OPT_ADD_ONLY_WITH_SHORT_OPT_GETOPT], [_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
	[$3([$1], ["${_key##-$2}"], [$4])],
	[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY([$4], $[$4])],
)])


dnl
dnl $1: The name of the option arg
dnl $2: The value of the option arg
dnl Uses:
dnl _key - the run-time shell variable
dnl _key - the run-time shell variable
m4_define([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS_OR_BOTH], [m4_do(
	[m4_ifdef([_COLLECT_$1], [_COLLECT_$1+=("${_key%%=*}"m4_ifnblank([$2], [ "$2"]))])],
)])


dnl see _APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS_OR_BOTH for docs
m4_define([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE], [m4_do(
	[m4_ifdef([_COLLECT_$1], [_COLLECT_$1+=("${_key}"m4_ifnblank([$2], [ "$2"]))])],
)])


m4_define([_MAKE_SEE_ALSO_OPTION_PHRASE], [m4_do(
	[[See the comment of option '$1' to see what's going on here - principle is the same.]],
)])


m4_define([_PICK_SIMPLE_CASE_STATEMENT_COMMENT], [m4_do(
	[_IF_ARG_ACCEPTS_VALUE([$3],
		[_POSSIBLY_REPEATED_COMMENT_BLOCK([simple_case_value], _MAKE_SEE_ALSO_OPTION_PHRASE([--$1]),
			_INDENT_LEVEL_IN_ARGV_CASE, _COMMENT_OPT_SPACE_VALUE_NEW($@))],
		[_POSSIBLY_REPEATED_COMMENT_BLOCK([simple_case_novalue], _MAKE_SEE_ALSO_OPTION_PHRASE([--$1]),
			_INDENT_LEVEL_IN_ARGV_CASE, _COMMENT_OPT_SPACE_NOVALUE_NEW($@))],
	)],
)])


m4_define([_PICK_GETOPT_CASE_STATEMENT_COMMENT], [m4_do(
	[_IF_ARG_ACCEPTS_VALUE([$3],
		[_POSSIBLY_REPEATED_COMMENT_BLOCK([getopt_case_value], _MAKE_SEE_ALSO_OPTION_PHRASE([-$2]),
			_INDENT_LEVEL_IN_ARGV_CASE, _COMMENT_OPT_GETOPT_WITH_VALUE($@))],
		[_POSSIBLY_REPEATED_COMMENT_BLOCK([getopt_case_novalue], _MAKE_SEE_ALSO_OPTION_PHRASE([-$2]),
			_INDENT_LEVEL_IN_ARGV_CASE, _COMMENT_OPT_GETOPT_WITHOUT_VALUE($@))],
	)],
)])


m4_define([_COMMENT_OPT_SPACE_NOVALUE_NEW_NOSHORT], [,
	[# The $1 argurment doesn't accept a value,],
	[# we expect the --$1, so we watch for it.],
])


m4_define([_COMMENT_OPT_SPACE_NOVALUE_NEW_WITH_SHORT], [,
	[# The $1 argurment doesn't accept a value,],
	[# we expect the --$1 or -$2, so we watch for them.],
])


m4_define([_COMMENT_OPT_SPACE_NOVALUE_NEW], [m4_ifblank([$2],
	m4_dquote(_COMMENT_OPT_SPACE_NOVALUE_NEW_NOSHORT($@)),
	m4_dquote(_COMMENT_OPT_SPACE_NOVALUE_NEW_WITH_SHORT($@)))])


m4_define([_COMMENT_OPT_SPACE_VALUE_NEW_NOSHORT], [,
	[# We support whitespace as a delimiter between option argument and its value.],
	[# Therefore, we expect the --$1 value, so we watch for --$1.],
	[# Since we know that we got the long option,],
	[# we just reach out for the next argument to get the value.],
])


m4_define([_COMMENT_OPT_SPACE_VALUE_NEW_WITH_SHORT], [,
	[# We support whitespace as a delimiter between option argument and its value.],
	[# Therefore, we expect the --$1 or -$2 value.],
	[# so we watch for --$1 and -$2.],
	[# Since we know that we got the long or short option,],
	[# we just reach out for the next argument to get the value.],
])


m4_define([_COMMENT_OPT_SPACE_VALUE_NEW], [m4_ifblank([$2],
	m4_dquote(_COMMENT_OPT_SPACE_VALUE_NEW_NOSHORT($@)),
	m4_dquote(_COMMENT_OPT_SPACE_VALUE_NEW_WITH_SHORT($@)))])


m4_define([_COMMENT_OPT_EQUALS_NEW], [,
	[# We support the = as a delimiter between option argument and its value.],
	[# Therefore, we expect --$1=value, so we watch for --$1=*],
	[# For whatever we get, we strip '--$1=' using the ${var##--$1=} notation],
	[# to get the argument value],
])


m4_define([_COMMENT_OPT_EQUALS_SHORT_NEW], [,
	[# We don't support whitespace as a delimiter between option argument and its value.],
	[# Therefore, we expect only for the -$2 value, so we watch for -$2],
	[# Since we know that we got the short option],
	[# we just reach out for the next argument to get the value.],
])


m4_define([_COMMENT_OPT_GETOPT], [,
	[# We don't support whitespace as a delimiter between option argument and its value.],
	[# Therefore, we expect only for the -$2 value, so we watch for -$2],
	[# Since we know that we got the short option],
	[# we just reach out for the next argument to get the value.],
])


m4_define([_COMMENT_OPT_GETOPT_WITH_VALUE], [,
	[# We support getopts-style short arguments grouping,],
	[# so as -$2 accepts value, we allow it to be appended to it, so we watch for -$2*],
	[# and we strip the leading -$2 from the argument string using the ${var##-$2} notation.],
])


m4_define([_COMMENT_OPT_GETOPT_WITHOUT_VALUE], [,
	[# We support getopts-style short arguments clustering,],
	[# so as -$2 doesn't accept value, other short options may be appended to it, so we watch for -$2*.],
	[# After stripping the leading -$2 from the argument, we have to make sure],
	[# that the first character that follows coresponds to a short option.],
])


m4_define([LONG_ARG_TO_INDEX], [m4_do(
	[m4_list_indices([_ARGS_LONG], [$1])],
)])

m4_define([LONG_ARG_TO_ARGS_SOMETHING],
	[m4_list_nth([_ARGS_$2], LONG_ARG_TO_INDEX([$1]))])

dnl m4_ifblank([$1], [m4_fatal([The assignment is void, use '_val' variable to do wat you want (s.a. '_arg_varname="$_val"')])])
dnl
dnl Globally set the option-value delimiter according to a directive.
dnl $1: The directive
m4_define([_SET_OPTION_VALUE_DELIMITER],
	[m4_bmatch([$1], [ ],
		[m4_bmatch([$1], [=], [m4_do(
			[dnl BOTH delimiters
],
			[m4_define([_IF_SPACE_IS_A_DELIMITER], m4_quote($[]1))],
			[m4_define([_IF_EQUALS_IS_A_DELIMITER], m4_quote($[]1))],
			[m4_define([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY],
				m4_defn([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS_OR_BOTH]))],
			[m4_define([_DELIMITER], [[BOTH]])],
			[dnl We won't try to show that = and ' ' are possible in the help message
],
			[m4_define([_DELIM_IN_HELP], [ ])],
		)], [m4_do(
			[dnl SPACE only
],
			[m4_define([_IF_SPACE_IS_A_DELIMITER], m4_quote($[]1))],
			[m4_define([_IF_EQUALS_IS_A_DELIMITER], m4_quote($[]2))],
			[m4_define([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY],
				m4_defn([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE]))],
			[m4_define([_DELIMITER], [[SPACE]])],
			[m4_define([_DELIM_IN_HELP], [ ])],
		)])],
		[m4_bmatch([$1], [=], [m4_do(
			[dnl EQUALS only
],
			[m4_define([_IF_SPACE_IS_A_DELIMITER], m4_quote($[]2))],
			[m4_define([_IF_EQUALS_IS_A_DELIMITER], m4_quote($[]1))],
			[m4_define([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY],
				m4_defn([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS_OR_BOTH]))],
			[m4_define([_DELIMITER], [[EQUALS]])],
			[m4_define([_DELIM_IN_HELP], [=])],
		)], [m4_fatal([We expect at least '=' or ' ' in the expression. Got: '$1'.])])])])


dnl
dnl Sets the option--value separator (i.e. --option=val or --option val)
dnl $1: The directive (' ', '=', or ' =' or '= ')
argbash_api([ARGBASH_SET_DELIM], _CHECK_PASSED_ARGS_COUNT(1, 1)[m4_do(
	[m4_bmatch(m4_expand([_W_FLAGS]), [S], ,[[$0($@)]_SET_OPTION_VALUE_DELIMITER([$1])])],
)])


m4_define([_COMPOSE_CASE_MATCH_STATEMENT], [m4_do(
	[m4_foreach([_arg], [$@], [m4_ifnblank(m4_quote(_arg),
		[m4_list_append([_CASE_MATCHES], m4_quote(_arg))])])],
	[m4_list_join([_CASE_MATCHES], [|])],
	[m4_list_destroy([_CASE_MATCHES])],
)])


dnl
dnl Given multiple matches, join them with |
m4_define([_INDENT_AND_END_CASE_MATCH], [m4_do(
	[_INDENT_(3,	)],
	[_COMPOSE_CASE_MATCH_STATEMENT($@)],
	[@:}@
],
)])


m4_define([_IF_ARG_IS_BOOLEAN],
	[m4_if([$1], [bool], [$2], [$3])])


m4_define([_IF_ARG_ACCEPTS_VALUE],
	[m4_case([$1], [arg], [$2], [repeated], [$2], [$3])])


dnl
dnl Call the _MAKE_OPTARG_SIMPLE_CASE_SECTION only if we
dnl - have space as a delimiter, OR
dnl - argument has a short option.
m4_define([_MAKE_OPTARG_SIMPLE_CASE_SECTION_IF_IT_MAKES_SENSE],
	[_IF_SPACE_IS_A_DELIMITER([_PICK_SIMPLE_CASE_STATEMENT_COMMENT($@)_MAKE_OPTARG_SIMPLE_CASE_SECTION($@)],
		[m4_ifnblank([$2], [_PICK_SIMPLE_CASE_STATEMENT_COMMENT($@)_MAKE_OPTARG_SIMPLE_CASE_SECTION($@)],
			[_IF_ARG_ACCEPTS_VALUE([$3], , [_PICK_SIMPLE_CASE_STATEMENT_COMMENT($@)_MAKE_OPTARG_SIMPLE_CASE_SECTION($@)])])])])


dnl TODO: We have to restrict case match for long options only if those long opts accept value.
dnl We always match for --help - even if delim is = only.
dnl And we also match for --no-that
dnl And for -h*, since this is an action and argbash then ends (but maybe not, what if one has passed -hx, while -x is invalid?)
m4_define([_MAKE_OPTARG_SIMPLE_CASE_SECTION], [m4_do(
	[_INDENT_AND_END_CASE_MATCH(
		[m4_ifblank([$2], [], [[-$2]])],
		[_IF_ARG_IS_BOOLEAN([$3], [[--no-$1]])],
		[_IF_ARG_ACCEPTS_VALUE([$3], [_IF_SPACE_IS_A_DELIMITER([[--$1]])], [[--$1]])])],
	[m4_case([$3],
		[arg], [_VAL_OPT_ADD_SPACE_WITHOUT_GETOPT_OR_SHORT_OPT([$1], [$2], [_ASSIGN_VALUE_TO_VAR], [$5])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [$$5])],
		[repeated], [_VAL_OPT_ADD_SPACE_WITHOUT_GETOPT_OR_SHORT_OPT([$1], [$2], [_APPEND_VALUE_TO_ARRAY], [$5])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [${$5[-1]}])],
		[bool],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5="on"]],
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY([$5])],
			[[test "${1:0:5}" = "--no-" && $5="off"]],
		)],
		[incr],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5=$(($5 + 1))]],
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY([$5])],
		)],
		[action],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$4]],
			[exit 0],
		)],
	)],
	[_INDENT_(_INDENT_LEVEL_IN_ARGV_CASE_BODY);;
],
)])


dnl
dnl Call the _MAKE_OPTARG_SIMPLE_CASE_SECTION only if we
dnl - have eqals as a delimiter
m4_define([_MAKE_OPTARG_LONGOPT_EQUALS_CASE_SECTION_IF_IT_MAKES_SENSE],
	[_IF_EQUALS_IS_A_DELIMITER([m4_case([$3],
		[arg], [_POSSIBLY_REPEATED_COMMENT_BLOCK([equals_case], _MAKE_SEE_ALSO_OPTION_PHRASE([--$1=]),
			_INDENT_LEVEL_IN_ARGV_CASE, _COMMENT_OPT_EQUALS_NEW($@))_MAKE_OPTARG_LONGOPT_EQUALS_CASE_SECTION($@)],
		[repeated], [_POSSIBLY_REPEATED_COMMENT_BLOCK([equals_case], _MAKE_SEE_ALSO_OPTION_PHRASE([--$1=]),
			_INDENT_LEVEL_IN_ARGV_CASE, _COMMENT_OPT_EQUALS_NEW($@))_MAKE_OPTARG_LONGOPT_EQUALS_CASE_SECTION($@)],
		[])])])


m4_define([_MAKE_OPTARG_LONGOPT_EQUALS_CASE_SECTION], [m4_do(
	[_INDENT_AND_END_CASE_MATCH(
		[[--$1=*]])],
	[dnl Output the body of the case
],
	[dnl _APPEND_WRAPPED_ARGUMENT_TO_ARRAY: If the arg comes from wrapped script/template, save it in an array
],
	[m4_case([$3],
		[arg], [_VAL_OPT_ADD_EQUALS_WITH_LONG_OPT([$1], [], [_ASSIGN_VALUE_TO_VAR], [$5])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [$$5])],
		[repeated], [_VAL_OPT_ADD_EQUALS_WITH_LONG_OPT([$1], [], [_APPEND_VALUE_TO_ARRAY], [$5])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [${$5[-1]}])],
		[m4_fatal([Internal error: Argument of type '$3' is other than 'arg' or 'repeated' and shouldn't make it to the '$0' macro.])]
	)],
	[_INDENT_(_INDENT_LEVEL_IN_ARGV_CASE_BODY);;
],
)])


m4_define([_MAKE_OPTARG_GETOPT_CASE_SECTION], [m4_do(
	[_INDENT_AND_END_CASE_MATCH(
		[[-$2*]])],
	[dnl Search for occurences of e.g. -ujohn and make sure that either -u accepts a value, or -j is a short option
],
	[m4_case([$3],
		[arg], [_VAL_OPT_ADD_ONLY_WITH_SHORT_OPT_GETOPT([$1], [$2], [_ASSIGN_VALUE_TO_VAR], [$5])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [$$5])],
		[repeated], [_VAL_OPT_ADD_ONLY_WITH_SHORT_OPT_GETOPT([$1], [$2], [_APPEND_VALUE_TO_ARRAY], [$5])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [${$5[-1]}])],
		[bool],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5="on"]],
			_PASS_WHEN_GETOPT([$2]),
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY([$5])],
		)],
		[incr],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5=$(($5 + 1))]],
			_PASS_WHEN_GETOPT([$2]),
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY([$5])],
		)],
		[action],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$4]],
			[exit 0],
		)],
	)],
	[_INDENT_(_INDENT_LEVEL_IN_ARGV_CASE_BODY);;
],
)])


m4_define([_MAKE_OPTARG_GETOPT_CASE_SECTION_IF_IT_MAKES_SENSE],
	[_IF_OPT_GROUPING_GETOPT([m4_ifnblank([$2], [_PICK_GETOPT_CASE_STATEMENT_COMMENT($@)_MAKE_OPTARG_GETOPT_CASE_SECTION($@)])])])


m4_define([_MAKE_OPTARG_CASE_SECTIONS], [m4_do(
	[_MAKE_OPTARG_SIMPLE_CASE_SECTION_IF_IT_MAKES_SENSE([$1], [$2], [$3], [$4], [$5])],
	[_MAKE_OPTARG_LONGOPT_EQUALS_CASE_SECTION_IF_IT_MAKES_SENSE([$1], [$2], [$3], [$4], [$5])],
	[_MAKE_OPTARG_GETOPT_CASE_SECTION_IF_IT_MAKES_SENSE([$1], [$2], [$3], [$4], [$5])],
)])


m4_define([_HANDLE_OCCURENCE_OF_DOUBLEDASH_ARG], [m4_do(
	[_COMM_BLOCK(1,
		[# If two dashes (i.e. '--') were passed on the command-line,],
		[# assign the rest of arguments as positional arguments and bail out.],
	)],
	[_JOIN_INDENTED(1,
		[if test "$_key" = '--'],
		[then],
		_INDENT_MORE(
			[shift],
			[_positionals+=("@S|@@")],
			[break]),
		[fi])],
)])


m4_define([_EVAL_OPTIONALS], [m4_do(
	[_INDENT_(2)_key="$[]1"
],
	[m4_if(HAVE_DOUBLEDASH, 1, [_HANDLE_OCCURENCE_OF_DOUBLEDASH_ARG])],
	[_MAKE_CASE_STATEMENT],
)])


m4_define([_MAKE_CASE_STATEMENT], [m4_do(
	[_INDENT_(2)[case "$_key" in
]],
	[m4_lists_foreach([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH,_ARGS_DEFAULT,_ARGS_VARNAME], [_argname,_arg_short,_arg_type,_default,_arg_varname],
		[_MAKE_OPTARG_CASE_SECTIONS(_argname, _arg_short, _arg_type, _default, _arg_varname)])],
	[_HANDLE_POSITIONAL_ARG],
	[_INDENT_(2)[esac
]],
)])


m4_define([_HANDLE_POSITIONAL_ARG], [m4_do(
	[_INDENT_(3)],
	[*@:}@
],
	[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
		[m4_if(HAVE_POSITIONAL, 1,
			[_positionals+=("$[]1")],
			[_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$[]1'" 1])],
		[;;],
	)],
)])


m4_define([_STORE_CURRENT_ARG_AS_POSITIONAL],
	[_INDENT_(2)[_positionals+=("$][1")]
])


m4_define([_MAKE_LIST_OF_POSITIONAL_ASSIGNMENT_TARGETS], [m4_do(
	[m4_pushdef([_indentation_level], 1)],
	[_COMM_BLOCK(_indentation_level,
		[# We have an array of variables to which we want to save positional args values.],
		[# This array is able to hold array elements as targets.],
	)],
	[_INDENT_(_indentation_level)[_positional_names=@{:@]],
	[m4_lists_foreach([_POSITIONALS_NAMES,_POSITIONALS_MAXES], [_pos_name,_max_argn], [m4_do(
		[dnl If we accept inf args, it may be that _max_argn == 0 although we HAVE_POSITIONAL, so we really need the check.
],
		[m4_if(_max_argn, 0, , [m4_do(
			[m4_for([_arg_index], 1, _max_argn, 1, [m4_do(
				['],
				[_varname(_pos_name)],
				[dnl If we handle a multi-value arg, we assign to an array => we add '[_arg_index - 1]' (i.e. zero-based argument index) to LHS.
],
				[m4_if(_max_argn, 1, , [@<:@m4_eval(_arg_index - 1)@:>@])],
				[' ],
			)])],
		)])],
	)])],
	[@:}@
],
	[IF_POSITIONALS_INF([m4_do(
		[_COMM_BLOCK(_indentation_level,
			[If we allow up to infinitely many args, we calculate how many of values],
			[were actually passed, and we extend the target array accordingly.],
		)],
		[_JOIN_INDENTED(_indentation_level,
			[[_our_args=$((${#_positionals[@]} - ${#_positional_names[@]}))]],
			[[for ((ii = 0; ii < _our_args; ii++))]],
			[do],
			[_INDENT_()_positional_names+=("_INF_VARNAME@<:@$((ii + _INF_ARGN))@:>@")],
			[done],
		)],
	)])],
	[m4_popdef([_indentation_level])],
)])


m4_define([_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED], [IF_POSITIONALS_INF(
	[m4_if(_MINIMAL_POSITIONAL_VALUES_COUNT, 0, [$2], [$1])],
	[$1])])


dnl
dnl Generates functions and outputs either hints or function calls
dnl
dnl $1: Callback --- how to deal with actual function calls
m4_define([_MAKE_VALUES_ASSIGNMENTS_BASE], [m4_do(
	[_MAKE_ARGV_PARSING_FUNCTION
],
	[_IF_HAVE_POSITIONAL([m4_do(
		[
],
		[_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([_MAKE_CHECK_POSITIONAL_COUNT_FUNCTION
])],
		[_MAKE_ASSIGN_POSITIONAL_ARGS_FUNCTION
],
	)])],
	[$1([parse_commandline "@S|@@"], [handle_passed_args_count], [assign_positional_args])],
)])


m4_define([_ASSIGN_GO], [m4_do(
	[_COMM_BLOCK(0,
		[# Now call all the functions defined above that are needed to get the job done],
	)],
	[$1
],
	[_IF_HAVE_POSITIONAL([m4_do(
		[_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([$2
])],
		[$3
],
	)])],
)])


dnl
dnl Convention:
dnl The commented-out calls are supposed to be preceded by regexp '^# '
m4_define([_ASSIGN_PREPARE], [m4_do(
	[_COMM_BLOCK(0,
		[# Call the function that assigns passed optional arguments to variables:],
		[#  $1],)
	],
	[_IF_HAVE_POSITIONAL([_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED(
		[_COMM_BLOCK(0,
			[# Then, call the function that checks that the amount of passed arguments is correct],
			[# followed by the function that assigns passed positional arguments to variables:],
			[#  $2],
			[#  $3],
		)])],
		[_COMM_BLOCK(0,
			[# Then, call the function that assigns passed positional arguments to variables:],
			[# $3],
		)],
	)],
)])


dnl
dnl $1: argname macro
dnl $2: _arg_type
dnl $3: _min_argn
dnl $4: _defaults
dnl
m4_define([_MAKE_DEFAULTS_FOR_MULTIVALUED_ARGUMENTS], [m4_do(
	[@{:@],
	[dnl m4_for([foo], 1, 0) doesn't work
],
	[m4_if([$3], 0, ,
		[m4_for([foo], 1, [$3], 1, ['' ])])],
	[m4_join([ ],
		m4_map_sep(
			[_sh_quote],
			[,],
			m4_dquote(m4_list_contents([$4]))))],
	[@:}@],
)])


dnl
dnl $1: _argname
dnl $2: _arg_type
dnl $3: _min_argn
dnl $4: _defaults
dnl
dnl If the corresponding arg has a default, save it according to its type.
dnl If it doesn't have one, do nothing (TODO: to be reconsidered)
m4_define([_MAKE_DEFAULTS_POSITIONALS_LOOP], [m4_do(
	[m4_ifnblank([$4], [m4_do(
		[_varname([$1])=],
		[dnl We have to double-quote $4 (and underlying stuff) since they are expanded by two macros, so two quotes get stripped.
],
		[m4_case([$2],
			[single], [[$4]],
			[more], [_MAKE_DEFAULTS_FOR_MULTIVALUED_ARGUMENTS([$1], [$2], [$3], [$4])],
			[inf], [_MAKE_DEFAULTS_FOR_MULTIVALUED_ARGUMENTS([$1], [$2], [$3], [$4])],
		)],
		[
],
	)], [m4_do(
		[dnl Just initialize the variable with blank value
],
		[_IF_MAKE_DEFAULTS_TO_ALL_POSITIONAL_ARGUMENTS([_varname([$1])=
])],
)])],
)])


dnl
dnl Create the part of the script where default values for arguments are assigned.
m4_define([_MAKE_DEFAULTS], [m4_do(
	[m4_if(HAVE_POSITIONAL, 1, [m4_do(
		[# THE DEFAULTS INITIALIZATION - POSITIONALS
],
		[_COMM_BLOCK(0,
			[# The positional args array has to be reset before the parsing, because it may already be defined],
			[# - for example if this script is sourced by an argbash-powered script.])],
		[[_positionals=()
]],
		[m4_lists_foreach([_POSITIONALS_NAMES,_POSITIONALS_MINS,_POSITIONALS_DEFAULTS,_POSITIONAL_CATHS], [_argname,_min_argn,_defaults,_arg_type],
			[_MAKE_DEFAULTS_POSITIONALS_LOOP(_argname, _arg_type, _min_argn, _defaults)])],
	)])],
	[_IF_HAVE_OPTIONAL([m4_do(
		[# THE DEFAULTS INITIALIZATION - OPTIONALS
],
		[m4_lists_foreach([_ARGS_LONG,_ARGS_CATH,_ARGS_DEFAULT,_ARGS_VARNAME], [_argname,_arg_type,_default,_arg_varname], [m4_do(
			[dnl We have to handle 'incr' as a special case, there is a m4_default(..., 0)
],
			[m4_case(_arg_type,
				[action], [],
				[incr], [_arg_varname=m4_expand(_default)
],
				[_arg_varname=_default
])],
		)])],
	)])],
)])


dnl
dnl Make some utility stuff.
dnl Those include the die function as well as optional validators
m4_define([_MAKE_UTILS], [m4_do(
	[_MAKE_DIE_FUNCTION

],
	[_IF_RESTRICT_VALUES([_MAKE_RESTRICT_VALUES_FUNCTION]

)],
	[_IF_HAVE_OPTIONAL([_IF_OPT_GROUPING_GETOPT([_MAKE_NEXT_OPTARG_FUNCTION]

)])],
	[_PUT_VALIDATORS],
)])


m4_define([_MAKE_OTHER], [m4_do(
	[[# OTHER STUFF GENERATED BY Argbash
]],
	[dnl Put the stuff below into some condition block
],
	[dnl _ARGS_GROUPS is a set of arguments lists where all args inherited from a wrapped script are
],
	[m4_set_foreach([_ARGS_GROUPS], [agroup], [agroup=("${agroup[]_opt_suffix@<:@@@:>@}" "${agroup[]_pos_suffix@<:@@@:>@}")
])],
	[m4_list_foreach([_OTHER], [item], [item
])],
	[_VALIDATE_POSITIONAL_ARGUMENTS],
	[_MAYBE_ASSIGN_INDICES_TO_TYPED_SINGLE_VALUED_ARGS],
)])


dnl Expand to 1 if we don't have positional nor optional args
m4_define([_IF_SOME_ARGS_ARE_DEFINED],
	[m4_if(m4_if(HAVE_POSITIONAL, 1, 1, [_IF_HAVE_OPTIONAL(1, 0)]),
		1, [$1], [$2])])


argbash_api([ARGBASH_GO], [m4_do(
	[m4_ifndef([WRAPPED], [_ARGBASH_GO([$0()])])],
)])


argbash_api([ARGBASH_PREPARE], [m4_do(
	[m4_ifndef([WRAPPED], [m4_do(
		[_SET_DIY_MODE()],
		[_ARGBASH_GO([$0()])],
	)])],
)])


dnl
dnl Identify the Argbash version (this is part of the API)
m4_define([_ARGBASH_ID],
	[### START OF CODE GENERATED BY Argbash v]_ARGBASH_VERSION[ one line above ###])


m4_define([DEFINE_MINIMAL_POSITIONAL_VALUES_COUNT],
	[m4_if(m4_cmp(0, m4_list_len([_POSITIONALS_MINS])), 1,
		m4_define([_MINIMAL_POSITIONAL_VALUES_COUNT], [m4_list_sum(_POSITIONALS_MINS)]))])


dnl $1: The macro call (the caller is supposed to pass [$0($@)])
dnl What is also part of the API: The line
dnl ### START OF CODE GENERATED BY Argbash vx.y.z one line above ###
m4_define([ARGBASH_GO_BASE], [m4_do(
	[[$1
]],
	[DEFINE_MINIMAL_POSITIONAL_VALUES_COUNT],
	[[# needed because of Argbash --> m4_ignore@{:@@<:@
]],
	[_ARGBASH_ID
],
	[[# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info

]],
	[_SETTLE_ENV],
	[_IF_SOME_ARGS_ARE_DEFINED([m4_do(
		[_MAKE_UTILS
],
		[_MAKE_DEFAULTS
],
		[_MAKE_HELP
],
		[_MAKE_VALUES_ASSIGNMENTS_BASE(
			[_IF_DIY_MODE([_ASSIGN_PREPARE], [_ASSIGN_GO])])
],
	)])],
	[_MAKE_OTHER
],
	[[### END OF CODE GENERATED BY Argbash (sortof) ### @:>@@:}@]],
)])


dnl
dnl Wrap an Argbash-aware script.
dnl In the wrapping script, just point to the location of the wrapping script (template) and specify what options of the script NOT to "inherit".
dnl You can wrap multiple scripts using multiple ARGBASH_WRAP statements.
dnl $1: Stem of file are we wrapping. We expect macro _SCRIPT_$1 to be defined and to contain the full filefilename
dnl $2: Names of blacklisted args (list)
dnl $3: Codes of blacklisted args (string, default is HVI for help + version)
argbash_api([ARGBASH_WRAP], _CHECK_PASSED_ARGS_COUNT(1, 3)[m4_do(
	[[$0($@)]],
	[m4_pushdef([WRAPPED], [[$1]])],
	[m4_list_append([BLACKLIST], $2)],
	[m4_pushdef([_W_FLAGS], [m4_default([$3], [HVI])])],
	[m4_ifndef([_SCRIPT_$1], [m4_fatal([The calling script was supposed to find location of the file with stem '$1' and define it as a macro, but the latter didn't happen.])])],
	[m4_ignore(m4_include(m4_indir([_SCRIPT_$1])))],
	[m4_popdef([_W_FLAGS])],
	[m4_list_destroy([BLACKLIST])],
	[m4_popdef([WRAPPED])],
)])

dnl Empty the FLAGS macro (so it isn't F,L,A,G,S)
m4_define([_W_FLAGS], [])


argbash_api([ARG_LEFTOVERS],
	[m4_list_contains([BLACKLIST], [leftovers], , [[$0($@)]_ARG_POSITIONAL_INF([leftovers], [$1], [0], [... ])])])


dnl If I am wrapped:
dnl It may be that the wrapped script contains args that we already have.
dnl TODO: In this case: Raise an error (with a good advice)


dnl
dnl A very private macro --- return name of the macro containing description for the given type ID
dnl $1: Type ID
m4_define([__type_str], [[_type_str_$1]])

dnl
dnl Return type description for the given argname
dnl $1: Argument ID
m4_define([_GET_VALUE_DESC], [m4_expand(__type_str(_GET_VALUE_TYPE([$1])))])

dnl
dnl Given an argname, return the argument group name (i.e. type string) or 'arg'
dnl
dnl $1: argname
m4_define([_GET_VALUE_STR], [m4_do(
	[m4_ifdef([$1_VAL_GROUP], [m4_indir([$1_VAL_GROUP])], [arg])],
)])


dnl
dnl If specified, request to initialize positional arguments to empty values (if they don't have defaults)
argbash_api([ARG_DEFAULTS_POS], [m4_do(
	[m4_define([_MAKE_DEFAULTS_TO_ALL_POSITIONAL_ARGUMENTS], [[yes]])],
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
		[m4_fatal([Invalid strict mode - used '$1', but you have to use one of: ]m4_set_contents([_SET_OF_RESTRICT_VALUES_MODES], [, ]).)])],
	[m4_define([_RESTRICT_VALUES], [[$1]])],
)])


dnl
dnl Output some text depending on what strict mode we find ourselves in
m4_define([_CASE_RESTRICT_VALUES], [m4_case(_RESTRICT_VALUES,
	[none], [$1],
	[no-local-options], [$2],
	[no-any-options], [$3])])

dnl
dnl Output some text depending on what strict mode we find ourselves in
m4_define([_IF_RESTRICT_VALUES], [_CASE_RESTRICT_VALUES([$2], [$1], [$1])])


dnl
dnl Adds the code to ensure that the variable that contains the freshly passed value from the command-line is not blacklisted
dnl $1: Name of the run-time variable that contains the value
dnl $2: Name of the run-time variable that contains the option or argument name
m4_define([_CHECK_PASSED_VALUE_AGAINST_BLACKLIST], [m4_do(
	[_IF_RESTRICT_VALUES(
		[_INDENT_(_INDENT_LEVEL_IN_ARGV_CASE_BODY)[evaluate_strictness "$1" "$2"]
],
		[])],
)])


dnl
dnl $1: The mode of argument clustering: One of 'none', 'getopts'
argbash_api([ARG_OPTION_STACKING], _CHECK_PASSED_ARGS_COUNT(1)[m4_do(
	[[$0($@)]],
	[m4_define([_OPT_GROUPING_MODE], [[$1]])],
)])


m4_define([_IF_OPT_GROUPING_GETOPT], [m4_if(_OPT_GROUPING_MODE, [getopt], [$1], [$2])])


dnl
dnl Normally, we would just wait for the shift.
dnl However, we now transform '-xyz' to '-x' '-yz', so '-x' disappears during the shift
dnl and the rest is processed the next time.
dnl
dnl $1: The short option
m4_define([_PASS_WHEN_GETOPT], [m4_ifnblank([$1], [m4_do(
	[_IF_OPT_GROUPING_GETOPT(
		[[[_next="${_key##-$1}"]],
		[[if test -n "$_next" -a "$_next" != "$_key"]],
		[[then]],
		[_INDENT_()[begins_with_short_option "$_next" && shift && set -- "-$1" "-${_next}" "@S|@@" || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."]],
		[[fi]]])],
)])])


dnl Types:
dnl #. Register group name, assert uniquness
dnl #. Assign the validator to the name.
dnl #. Assign the name to args.
dnl #. Add the validator to the list of validators to be generated
dnl #. Group name is used in help, the type is used in val assignment (i.e. validated)
dnl #. Pos args: In the eval section, we use an array of names. Let's use an array of validators, too. Arrays can be sparse
dnl
dnl Introduce _VALIDATE_FOO functions. As they are used, make sure that the prerequisities are met
dnl
dnl * Upon arg encounter, validate the value. Die in case of no compliance.
dnl * Help: optional args - value should take the name.
dnl       : positional args - value should have the arg name, but the type should be mentioned on the help line.

dnl These macros that are being undefined are not needed and they present a security threat when exposed during Argbash run
m4_undefine([m4_esyscmd])
m4_undefine([m4_syscmd])
