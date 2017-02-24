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
dnl
dnl vvvvvvvvvvvvvvv
dnl TODO: Define parsing code as a function so one can call it on its hown
dnl TODO: (maybe a bad idea altogether): Support for -czf foo (now only -c -z -f foo) --- use `set -- "-$rest" "$@"`
dnl TODO: Support for -ffoo (alternative to -f foo, i.e. the null separator for short opts)
dnl TODO: Support custom error messages
dnl TODO: Make positional args check optional
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

m4_define([_COMM_BLOCK], [m4_ifdef([COMMENT_OUTPUT], [_JOIN_INDENTED([$1], m4_shift($@))])])

dnl
dnl Define a macro that is part of the public API
dnl Ensure the replication and also add the macro name to a list of allowed macros
m4_define([argbash_api], [_argbash_persistent([$1], [$2])])
m4_define([_argbash_persistent], [m4_set_add([_KNOWN_MACROS],[$1])m4_define([$1], [$2])])
dnl IDEA: Assemble a whitelist of macros used in the script, then grep the source and report all suspicious strings that resemble misspelled argbash macros


dnl
dnl Checks that the n-th argument is an integer.
dnl Should be called upon the macro definition outside of quotes, e.g. m4_define([FOO], _CHECK_INTEGER_TYPE(1)[m4_eval(2 + $1)])
dnl $1: The argument number
dnl $2: The error message (optional)
m4_define([_CHECK_INTEGER_TYPE],
	__CHECK_INTEGER_TYPE([[$][0]], m4_quote($[]$1), [$1], m4_quote($[]2)))


m4_define([_ARG_DEFAULTS_POS], [[no]])


dnl
dnl Checks that the an argument is a correct short option arg
dnl $1: The short option "string"
dnl $2: The argument name
m4_define([_CHECK_SHORT_OPT_TYPE], [m4_do(
	[m4_ifnblank([$1], [m4_bmatch([$1], [^[a-zA-z]$], ,
		[m4_fatal([Short option '$1' for argument '--$2' is not valid - it has to be exactly one character.])])])],
)])


dnl
dnl Checks that the first argument (long option) doesn't contain illegal characters
dnl $1: The long option string
m4_define([_CHECK_OPTION_NAME], [m4_do(
	[m4_pushdef([_forbidden], [= /])],
	[dnl Should produce the [= etc.] regexp
],
	[m4_bmatch([$1], [^-],
		[m4_fatal([The option name '$1' is illegal, because it begins with a dash ('-'). Names can contain dashes, but not at the beginning.])])],
	[m4_bmatch([$1], m4_dquote(_forbidden),
		[m4_fatal([The option name '$1' is illegal, because it contains forbidden characters (one of: ']_forbidden[').])])],
	[m4_popdef([_forbidden])],
)])


dnl
dnl Factory macro - makes _FLAGS_D_IF etc. macros
m4_define([_FLAGS_WHATEVER_IF_FACTORY],
	[m4_define([_FLAGS_$1_IF], [m4_bmatch(m4_quote($][1), [$1], m4_dquote($][2), m4_dquote($][3))])])
_FLAGS_WHATEVER_IF_FACTORY(D)
_FLAGS_WHATEVER_IF_FACTORY(R)
_FLAGS_WHATEVER_IF_FACTORY(W)
_FLAGS_WHATEVER_IF_FACTORY(X)


dnl
dnl $1: FLAGS: Any of RWXD, default is nothing (= an existing file)
m4_define([_MK_VALIDATE_FNAME_FUNCTION], [m4_do(
	[m4_pushdef([_fname], [[validate_file_$1]])],
	[dnl Maybe we already have requested this function
],
	[m4_list_contains([_VALIDATE_FILE], _fname, , [m4_do(
		[m4_list_append([_VALIDATE_FILE], _fname)],
		[_fname[]()
],
		[{
],
		[_JOIN_INDENTED(1,
			[_FLAGS_D_IF([$1], [m4_do(
				[m4_pushdef([_what], [[directory]])],
				[m4_pushdef([_xperm], [[browsable directory]])],
				[[test -d "@S|@1" || die "Argument '@S|@2' has to be a directory, got '@S|@1'" 4]],
				)], [m4_do(
				[m4_pushdef([_what], [[file]])],
				[m4_pushdef([_xperm], [[executable file]])],
				[[test -f "@S|@1" || die "Argument '@S|@2' has to be a file, got '@S|@1'" 4]],
			)])],
			[_FLAGS_R_IF([$1], [[test -r "@S|@1" || { echo "Argument '@S|@2' has to be a readable ]_what[, '@S|@1' isn't."; return 4; }]])],
			[_FLAGS_W_IF([$1], [[test -w "@S|@1" || { echo "Argument '@S|@2' has to be a writable ]_what[, '@S|@1' isn't."; return 4; }]])],
			[_FLAGS_X_IF([$1], [[test -x "@S|@1" || { echo "Argument '@S|@2' has to be a ]_xperm[, '@S|@1' isn't."; return 4; }]])],
		)],
		[}
],
	)])],
	[m4_popdef([_fname])],
)])


dnl
dnl Given a arg type ID, it treats as a group type and creates a function to examine whether the value is in the list.
dnl $1: The group stem
dnl $2: If blank, don't bother with the index recording functionality
dnl
dnl The bash function accepts:
dnl $1: The value to check
dnl $2: What was the option that was associated with the value
m4_define([_MK_VALIDATE_GROUP_FUNCTION], [m4_do(
	[$1()
],
	[{
],
	[_JOIN_INDENTED(1,
		[local _allowed=(m4_list_join([_LIST_$1_QUOTED], [ ]))],
		[local _seeking="@S|@1"],
		m4_ifnblank([$2], [[local _idx=0],],[[dnl nothing
],])
		[for element in "${_allowed@<:@@@:>@}"],
		[do],
		m4_ifnblank([$2],
			[[_INDENT_()test "$element" = "$_seeking" && { test "@S|@3" = "idx" && echo "$_idx" || echo "$element"; } && return 0],
			 [_INDENT_()_idx=$((_idx + 1))],],
			[[_INDENT_()test "$element" = "$_seeking" && echo "$element" && return 0],])
		[done],
		[die "Value '$_seeking' (of argument '@S|@2') doesn't match the list of allowed values: m4_list_join([_LIST_$1], [, ], ', ', [ and ])" 4],
	)],
	[}],
)])


dnl
dnl Given an optional argument name, it queries whether the value can be validated and emits a line if so.
m4_define([_MAYBE_VALIDATE_VALUE_OPT], [m4_do(
	[],
)])


dnl
dnl The helper macro for _CHECK_INTEGER_TYPE
dnl $1: The caller name
dnl $2: The arg position
dnl $3: The arg value
dnl $4: The error message (optional)
m4_define([__CHECK_INTEGER_TYPE], [[m4_do(
	[m4_bmatch([$2], [^[0-9]+$], ,
		[m4_fatal([The ]m4_if([$3], 1, 1st, 2, 2nd, 3, 3rd, $3th)[ argument of '$1' has to be a number]m4_ifnblank([$4], [[ ($4)]])[, got '$2'])])],
)]])


dnl
dnl Blank args to this macro are totally ignored, use @&t@ to get over that --- @&t@ is a quadrigraph that expands to nothing in the later phase
dnl $1: How many indents
dnl $2, $3, ...: What to put there
m4_define([_JOIN_INDENTED], _CHECK_INTEGER_TYPE(1, [depth of indentation])[m4_do(
	[m4_foreach([line], [m4_shift($@)], [m4_ifnblank(m4_quote(line), _INDENT_([$1])[]m4_dquote(line)
)])],
)])

dnl
dnl $1, $2, ...: What to put there
dnl
dnl Takes arguments, returns them, but there is an extra _INDENT_() in the beginning of them
m4_define([_INDENT_MORE], [m4_do(
	[m4_list_ifempty([_TLIST], , [m4_fatal([Internal error: List '_TLIST' should be empty, contains ]m4_list_join([_TLIST])[ instead])])],
	[m4_foreach([line], [$@], [m4_list_append([_TLIST], m4_expand([_INDENT_()line]))])],
	[m4_unquote(m4_list_contents([_TLIST]))],
	[m4_list_destroy([_TLIST])],
)])


dnl Take precaution that if the indentation depth is 0, nothing happens
m4_define([_SET_INDENT], [m4_define([_INDENT_],
	[m4_for(_, 1, m4_default($][1, 1), 1,
		[[$1]])])])

m4_define([_SET_INDENT], [__SET_INDENT([$1], $[]1)])

m4_define([__SET_INDENT], [m4_define([_INDENT_], [m4_if([$2], 0, ,
	[m4_for(_, 1, m4_default([$2], 1), 1,
		[[$1]])])])])

dnl
dnl defines _INDENT_
dnl $1: How many times to indent (default 1)
dnl $2, ...: Ignored, but you can use those to make the code look somewhat better.

dnl Sets the default (tab) indent
_SET_INDENT([	])


dnl
dnl Sets the indentation character(s) in the parsing code
dnl $1: The indentation character(s)
argbash_api([ARGBASH_SET_INDENT],
	[m4_bmatch(m4_expand([_W_FLAGS]), [I], ,[[$0($@)]_SET_INDENT([$1])])])


dnl We include the version-defining macro
m4_define([_ARGBASH_VERSION], m4_default_quoted(m4_normalize(m4_sinclude([version])), [unknown]))


dnl Contains implementation of m4_list_...
m4_include([list.m4])


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
dnl The string si also []-quoted
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
dnl $1: Argument name
dnl $2: Argument type (OPT or POS)
dnl Check whether an argument has not (long or short) options that conflict with already defined args.
dnl Also writes the argname to the right set
m4_define([_CHECK_ARGNAME_FREE], [m4_do(
	[m4_pushdef([_TLIT], m4_dquote(_translit_var([$1])))],
	[m4_set_contains([_ARGS_LONG], _TLIT,
		[m4_ifnblank([$1], [m4_fatal([Argument name '$1' conflicts with a long option used earlier.])])])],
	[m4_set_contains([_POSITIONALS], _TLIT,
		[m4_ifnblank([$1], [m4_fatal([Argument name '$1' conflicts with a positional argument name used earlier.])])])],
	[m4_set_add(m4_case([$2],
			[OPT], [[_ARGS_LONG]],
			[POS], [_POSITIONALS],
			[m4_fatal([Unknown argument type '$2'])]),
		_TLIT)],
	[m4_popdef([_TLIT])],
)])


m4_define([_some_opt], [m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[_CHECK_SHORT_OPT_TYPE([$2], [$1])],
	[m4_list_contains([BLACKLIST], [$1], , [__some_opt($@)])],
)])


dnl
dnl Registers a command, recording its name, type etc.
dnl $1: Long option
dnl $2: Short option (opt)
dnl $3: Help string
dnl $4: Default, pass it through _sh_quote if needed beforehand (opt)
dnl $5: Type
m4_define([__some_opt], [m4_do(
	[m4_ifdef([WRAPPED], [m4_do(
		[m4_set_add([_ARGS_GROUPS], m4_expand([_args_prefix[]_translit_var(WRAPPED)]))],
		[m4_define([_COLLECT_]_varname([$1]),  _args_prefix[]_translit_var(WRAPPED)[]_opt_suffix)],
	)])],
	[m4_list_append([_ARGS_LONG], [$1])],
	[dnl Check whether we didn't already use the arg, if not, add its tranliteration to the list of used ones
],
	[_CHECK_ARGNAME_FREE([$1], [OPT])],
	[m4_list_append([_ARGS_SHORT], [$2])],
	[m4_set_contains([_ARGS_SHORT], [$2],
		[m4_ifnblank([$2], [m4_fatal([The short option '$2' is already used.])])],
		[m4_set_add([_ARGS_SHORT], [$2])])],
	[m4_list_append([_ARGS_HELP], [$3])],
	[m4_list_append([_ARGS_DEFAULT], [$4])],
	[m4_list_append([_ARGS_CATH], [$5])],
	[m4_define([_NARGS], m4_eval(_NARGS + 1))],
)])

dnl Number of distinct optional args the script can accept
m4_define([_NARGS], 0)
dnl Minimal number of positional args the script accepts
m4_define([_POSITIONALS_MIN], 0)
dnl Greatest number of positional args the script can accept (infinite number of args is handled in parallel)
m4_define([_POSITIONALS_MAX], 0)
dnl We expect infinitely many args (keep in mind that we still need _POSITIONALS_MAX)
m4_define([_POSITIONALS_INF], 0)


dnl
dnl Use using processing an argument that is positional
m4_define([_A_POSITIONAL], [m4_do(
	[m4_define([HAVE_POSITIONAL], 1)],
)])


dnl
dnl Call in cases when it is not clear how many positional args to expect.
dnl This is determined by:
dnl  - the nature of the positional argument itself
dnl  - the positional arg has a default (?)
m4_define([_A_POSITIONAL_VARNUM], [m4_do(
	[_A_POSITIONAL],
	[m4_define([HAVE_POSITIONAL_VARNUM], 1)],
)])


dnl
dnl Use using processing an argument that is optional
m4_define([_A_OPTIONAL], [m4_do(
	[m4_define([HAVE_OPTIONAL], 1)],
)])


dnl Do something depending on whether there is already infinitely many args possible or not
m4_define([IF_POSITIONALS_INF],
	[m4_if(m4_quote(_POSITIONALS_INF), 1, [$1], [$2])])


dnl Do something depending on whether there have been optional positional args declared beforehand or not
m4_define([IF_POSITIONALS_VARNUM],
	[m4_ifdef([HAVE_POSITIONAL_VARNUM], [$1], [$2])])


dnl $1 is not quoted on purpose - it is already handled (i.e. quoted) by the caller
m4_define([_POS_WRAPPED], [m4_ifdef([WRAPPED], [m4_do(
		[m4_set_add([_ARGS_GROUPS], m4_expand([_args_prefix[]_translit_var(WRAPPED)]))],
		[m4_set_add([_POS_VARNAMES], m4_expand([_args_prefix[]_translit_var(WRAPPED)[]_pos_suffix]))],
		[m4_list_append([_WRAPPED_ADD_SINGLE], m4_expand([_args_prefix[]_translit_var(WRAPPED)[]_pos_suffix+=([$1])]))],
)])])

dnl
dnl Declare one positional argument with default
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: Default (opt.)
argbash_api([ARG_POSITIONAL_SINGLE], [m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [[$0($@)]_ARG_POSITIONAL_SINGLE($@)])],
)])


m4_define([_ARG_POSITIONAL_SINGLE], [m4_do(
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([The number of expected positional arguments before '$1' is unknown. This is not supported, define arguments that accept fixed number of values first.])], [])],
	[_POS_WRAPPED("${_varname([$1])}")],
	[dnl Number of possibly supplied positional arguments just went up
],
	[m4_define([_POSITIONALS_MAX], m4_incr(_POSITIONALS_MAX))],
	[dnl If we don't have default, also a number of positional args that are needed went up
],
	[m4_ifblank([$3], [m4_do(
			[_A_POSITIONAL],
			[_REGISTER_REQUIRED_POSITIONAL_ARGUMENTS([$1], 1)],
			[m4_list_append([_POSITIONALS_MINS], 1)],
			[m4_list_append([_POSITIONALS_DEFAULTS], [])],
		)], [m4_do(
			[_A_POSITIONAL_VARNUM],
			[m4_list_append([_POSITIONALS_MINS], 0)],
			[m4_list_append([_POSITIONALS_DEFAULTS], _sh_quote([$3]))],
		)])],
	[m4_list_append([_POSITIONALS_MAXES], 1)],
	[m4_list_append([_POSITIONALS_NAMES], [$1])],
	[m4_list_append([_POSITIONAL_CATHS], [single])],
	[m4_list_append([_POSITIONALS_MSGS], [$2])],
	[dnl Here, the _sh_quote actually does not ensure that the default is NOT BLANK!
],
	[_CHECK_ARGNAME_FREE([$1], [POS])],
)])


dnl
dnl Declare sequence of possibly infinitely many positional arguments
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: How many args at least (opt., default=0)
dnl $4, $5, ...: Defaults (opt., defaults for the 1st, 2nd, ... value past the required minimum)
argbash_api([ARG_POSITIONAL_INF], [m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [m4_do(
		[[$0($@)]],
		[m4_if($#, 3,
			[_ARG_POSITIONAL_INF($@)],
			[_ARG_POSITIONAL_INF([$1], [$2], [$3], [], m4_shiftn(3, $@))])],
	)])],
)])


dnl
dnl $1 ... $3: Same as ARG_POSITIONAL_INF
dnl $4: Representation of arg on command-line
dnl $5, ...: Defaults
m4_define([_ARG_POSITIONAL_INF], _CHECK_INTEGER_TYPE(3, [minimal number of arguments])[m4_do(
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([The number of expected positional arguments before '$1' is unknown. This is not supported, define arguments that accept fixed number of values first.])], [])],
	[_POS_WRAPPED(${_varname([$1])@<:@@@:>@})],
	[m4_define([_POSITIONALS_INF], 1)],
	[dnl We won't have to use stuff s.a. m4_quote(_INF_REPR), but _INF_REPR directly
],
	[m4_define([_INF_REPR], [[$4]])],
	[m4_list_append([_POSITIONALS_NAMES], [$1])],
	[m4_list_append([_POSITIONAL_CATHS], [inf])],
	[m4_list_append([_POSITIONALS_MSGS], [$2])],
	[_A_POSITIONAL_VARNUM],
	[m4_pushdef([_min_argn], m4_default([$3], 0))],
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
	[m4_define([_POSITIONALS_MAX], m4_eval(_POSITIONALS_MAX + _min_argn))],
	[m4_popdef([_min_argn])],
	[_CHECK_ARGNAME_FREE([$1], [POS])],
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
argbash_api([ARG_POSITIONAL_MULTI], [m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [[$0($@)]_ARG_POSITIONAL_MULTI($@)])],
)])


m4_define([_ARG_POSITIONAL_MULTI], [m4_do(
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([The number of expected positional arguments before '$1' is unknown. This is not supported, define arguments that accept fixed number of values first.])], [])],
	[_POS_WRAPPED(${_varname([$1])@<:@@@:>@})],
	[m4_define([_POSITIONALS_MAX], m4_eval(_POSITIONALS_MAX + [$3]))],
	[m4_list_append([_POSITIONALS_NAMES], [$1])],
	[m4_list_append([_POSITIONAL_CATHS], [more])],
	[m4_list_append([_POSITIONALS_MSGS], [$2])],
	[dnl Minimal number of args is number of accepted - number of defaults (= $3 - ($# - 3))
],
	[m4_pushdef([_min_argn], m4_eval([$3] - ($# - 3) ))],
	[dnl If we have defaults, we actually accept unknown number of arguments
],
	[m4_if(_min_argn, [$3], , [_A_POSITIONAL_VARNUM])],
	[m4_list_append([_POSITIONALS_MINS], _min_argn)],
	[_REGISTER_REQUIRED_POSITIONAL_ARGUMENTS([$1], _min_argn)],
	[m4_list_append([_POSITIONALS_MAXES], [$3])],
	[dnl Here, the _sh_quote actually ensures that the default is NOT BLANK!
],
	[m4_list_append([_POSITIONALS_DEFAULTS], [_$1_DEFAULTS])],
	[m4_if(m4_cmp($#, 3), 1, [m4_list_append([_$1_DEFAULTS], m4_shiftn(3, $@))])],
	[m4_popdef([_min_argn])],
	[_CHECK_ARGNAME_FREE([$1], [POS])],
)])


argbash_api([ARG_OPTIONAL_SINGLE], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
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
argbash_api([ARG_VERSION], [m4_do(
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
argbash_api([ARG_HELP], [m4_do(
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
argbash_api([INCLUDE_PARSING_CODE], [m4_do(
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
m4_define([_ARG_OPTIONAL_INCREMENTAL], [_A_OPTIONAL[]]_ARG_OPTIONAL_INCREMENTAL_BODY)


dnl $1: long name
dnl $2: short name (opt)
dnl $3: help
dnl $4: default (=0)
argbash_api([ARG_OPTIONAL_INCREMENTAL], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	]m4_dquote(_ARG_OPTIONAL_INCREMENTAL_BODY)[,
)])

m4_define([_ARG_OPTIONAL_REPEATED_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, ($[]4), [repeated])])

dnl $1: long name
dnl $2: short name (opt)
dnl $3: help
dnl $4: default (empty array)
argbash_api([ARG_OPTIONAL_REPEATED], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	]m4_dquote(_ARG_OPTIONAL_REPEATED_BODY)[,
)])


dnl $1: short name (opt)
argbash_api([ARG_VERBOSE], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_ARG_OPTIONAL_INCREMENTAL([verbose], [$1], [Set verbose output (can be specified multiple times to increase the effect)], 0)],
)])


dnl $1: long name, var suffix (translit of [-] -> _)
dnl $2: short name (opt)
dnl $3: help
dnl $4: default (=off)
argbash_api([ARG_OPTIONAL_BOOLEAN], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_some_opt([$1], [$2], [$3],
		m4_default([$4], [off]), [bool])],
)])


m4_define([_ARG_OPTIONAL_ACTION_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, $[]4, [action])])


argbash_api([ARG_OPTIONAL_ACTION], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[dnl Just call _ARG_OPTIONAL_ACTION with same args
],
	]m4_dquote(_ARG_OPTIONAL_ACTION_BODY)[,
)])


m4_define([_ARG_OPTIONAL_ACTION], [_A_OPTIONAL[]]_ARG_OPTIONAL_ACTION_BODY)


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
m4_define([_MAKE_DEFAULTS_MORE_MSG], [m4_do(
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
			[m4_if([$3], 0, [m4_do(
				[ @{:@],
				[default: '"],
				[[$4]],
				["'],
				[@:}@],
			)])],
		[more], [_MAKE_DEFAULTS_MORE_MSG([$1], [$2], [$3], [$4])],
		[inf], [_MAKE_DEFAULTS_MORE_MSG([$1], [$2], [$3], [$4])],
	[m4_fatal([$0: Unhandled arg type: '$2'])])],
)])


dnl
dnl $1: _argname
dnl $2: short arg
dnl Returns either --long or -l|--long if there is that -l
m4_define([_ARG_FORMAT], [m4_do(
	[m4_ifnblank([$2],
		[-$2|])],
	[[--$1]],
)])


m4_define([_MAKE_HELP_SYNOPSIS], [m4_do(
	[m4_if(HAVE_OPTIONAL, 1,
		[m4_lists_foreach([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH], [_argname,_arg_short,_arg_type], [m4_do(
			[ @<:@],
			[m4_case(_arg_type,
				[bool], [--(no-)]_argname,
				[arg], [_ARG_FORMAT(_argname, _arg_short)[]_DELIM_IN_HELP[<]_GET_VALUE_STR(_argname)>],
				[repeated], [_ARG_FORMAT(_argname, _arg_short)[]_DELIM_IN_HELP[<]_GET_VALUE_STR(_argname)>],
				[_ARG_FORMAT(_argname, _arg_short)])],
			[@:>@],
		)])],
	)],
	[m4_if(HAVE_DOUBLEDASH, 1, [[ @<:@--@:>@]])],
	[dnl If we have positionals, display them like <pos1> <pos2> ...
],
	[m4_if(HAVE_POSITIONAL, 1, [m4_do(
		[m4_lists_foreach([_POSITIONALS_NAMES,_POSITIONALS_MINS,_POSITIONALS_MAXES,_POSITIONAL_CATHS], [argname,_min_argn,_max_argn,_arg_type],
			[_POS_ARG_HELP_LINE(argname, _arg_type, _min_argn, _max_argn)])],
		[ m4_expand(m4_join([ ], m4_list_contents([_POSITIONALS_LIST])))],
	)])],
)])

dnl
dnl $1: The command short description
m4_define([_MAKE_HELP], [m4_do(
	[_COMM_BLOCK(0,
		[# Function that prints general usage of the script.],
		[# This is useful if users asks for it, or if there is an argument parsing error (unexpected / spurious arguments)],
		[# and it makes sense to remind the user how the script is supposed to be called.],
	)],
	[print_help ()
{
],
	[m4_ifnblank(m4_expand([_HELP_MSG]), m4_dquote(_INDENT_()[echo] "_HELP_MSG"
))],
	[_INDENT_()[]printf 'Usage: %s],
	[dnl If we have optionals, display them like [--opt1 arg] [--(no-)opt2] ... according to their type. @<:@ becomes square bracket at the end of processing
],
	[_MAKE_HELP_SYNOPSIS],
	[\n' "@S|@0"
],
	[dnl Don't display extended help for an arg if it doesn't have a description
],
	[m4_if(HAVE_POSITIONAL, 1,
		[m4_lists_foreach(
			[_POSITIONALS_NAMES,_POSITIONAL_CATHS,_POSITIONALS_MINS,_POSITIONALS_DEFAULTS,_POSITIONALS_MSGS],
			[argname0,_arg_type,_min_argn,_defaults,_msg], [m4_ifnblank(_msg, [m4_do(
			[dnl We would like something else for argname if the arg type is 'inf' and _INF_VARNAME is not empty
],
			[m4_pushdef([argname1], <m4_dquote(argname0)[[]m4_ifnblank(m4_quote($][1), m4_quote(-$][1))]>)],
			[m4_pushdef([argname], m4_if(_arg_type, [inf], [m4_default(_INF_REPR, argname1)], [[argname1($][@)]]))],
			[_INDENT_()[printf "\t%s\n" "]argname[: ]_msg],
			[_POS_ARG_HELP_DEFAULTS([argname], _arg_type, _min_argn, _defaults)],
			[m4_popdef([argname])],
			[m4_popdef([argname1])],
			[["
]],
			)])])],
	)],
	[dnl If we have 0 optional args, don't do anything (FOR loop would assert, 0 < 1)
],
	[dnl Plus, don't display extended help for an arg if it doesn't have a description
],
	[m4_if(_NARGS, 0, [], [m4_lists_foreach(
		[_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH,_ARGS_DEFAULT,_ARGS_HELP],
		[_argname,_arg_short,_arg_type,_default,_arg_help],
		[m4_ifnblank(_arg_help, [m4_do(
			[m4_pushdef([_VARNAME], [_varname(_argname)])],
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
			[: _arg_help],
			[dnl Actions don't have defaults
],
			[dnl WAS: We format defaults help by print-quoting them with ' and stopping the help echo quotes " before the store value is subsittuted, so the message should really match the real default.
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
			[m4_popdef([_VARNAME])],
	)])])])],
	[dnl Print a more verbose help message to the end of the help (if requested)
],
	[_ENV_HELP()],
	[m4_list_ifempty([LIST_ENV_HELP], ,[m4_do(
		[printf '\nEnvironment variables that are supported:\n'
],
		[m4_list_foreach([LIST_ENV_HELP], [_msg], [printf "\t%s\n" "[]_msg"
])],
	)])],
	[m4_ifnblank(m4_quote(_HELP_MSG_EX), m4_dquote(_INDENT_()[printf "\n%s\n" "]_HELP_MSG_EX"
))],
	[}
],
)])



dnl
dnl $1: Arg name
dnl $2: Short arg name (if applicable)
dnl $3: Action
dnl $4: The name of the option arg
dnl
dnl .. note::
dnl    If the equal-delimited option has a short version, we allow space-delimited short option and value
m4_define([_VAL_OPT_ADD_EQUALS], [_JOIN_INDENTED(3,
	[_val="${_key##--[$1]=}"],
	m4_ifnblank([$2],
		[[if test "$_key" = "-$2"],
		[then],
		_INDENT_MORE(
			[test $[]# -lt 2 && die "Missing value for the optional argument '$_key'." 1],
			[_val="@S|@2"],
			[shift]),
		[fi],]),
	[$3],
	[_ADD_OPTS_VALS([$4], $[$4])],
)])


dnl
dnl $1: Arg name
dnl $2: Short arg name (if applicable)
dnl $3: Action
dnl $4: The name of the option arg
m4_define([_VAL_OPT_ADD_SPACE], [_JOIN_INDENTED(3,
	[test @S|@# -lt 2 && die "Missing value for the optional argument '$_key'." 1],
	[_val="@S|@2"],
	[shift],
	[$3],
	[_ADD_OPTS_VALS([$4], $[$4])],
)])


dnl
dnl $1: Arg name
dnl $2: Short arg name (if applicable)
dnl $3: Action - the variable containing the value to assign is '_val'
dnl $4: The name of the option arg
m4_define([_VAL_OPT_ADD_BOTH], [_JOIN_INDENTED(3,
	[_val="${_key##--[$1]=}"],
	m4_ifnblank([$2], [_IF_CLUSTERING_GETOPT([[[_val2="${_key##-$2}"]]])]),
	[if test "$_val" = "$_key"],
	[then],
	_INDENT_MORE(
		[test $[]# -lt 2 && die "Missing value for the optional argument '$_key'." 1],
		[_val="@S|@2"],
		[shift]),
	m4_ifnblank([$2], [_IF_CLUSTERING_GETOPT(
	[[[elif test "$_val2" != "$_key" -a -n "$_val2"]],
	 [[then]],
	 [_INDENT_()[_val="$_val2"]]])]),
	[fi],
	[$3],
	[_ADD_OPTS_VALS([$4], $[$4])],
)])


dnl
dnl Macro factory, define _MAYBE_EQUALS_MATCH depending on what delimiters are effective.
dnl
dnl $1: What to do. Typically one of [], =*, |--$[]2=*
m4_define([_MAYBE_EQUALS_MATCH_FACTORY], [m4_define([_MAYBE_EQUALS_MATCH],
	[m4_case(m4_quote($][1),
		[arg], [$1],
		[repeated], [$1], [])])])
dnl
dnl Defines macro _MAYBE_EQUALS_MATCH:
dnl
dnl $1: Option type (be effective only for 'arg' and 'repeated')
dnl $2: Option name
dnl
dnl Before this macros is called, we output e.g. '--option' in the case match statement.
dnl If delimiter is
dnl  - space only: Do nothing,
dnl  - equals only: Add '=*',
dnl  - both: Add '|--option=*'.


dnl m4_ifblank([$1], [m4_fatal([The assignment is void, use '_val' variable to do wat you want (s.a. '_ARGVAR="$_val"')])])
dnl
dnl Globally set the option-value delimiter according to a directive.
dnl $1: The directive
m4_define([_SET_OPTION_DELIMITER],
	[m4_bmatch([$1], [ ],
		[m4_bmatch([$1], [=], [m4_do(
			[dnl BOTH
],
			[_MAYBE_EQUALS_MATCH_FACTORY(m4_dquote(|--$[]2=*))],
			[m4_define([_DELIMITER], [[BOTH]])],
			[m4_define([_VAL_OPT_ADD], m4_defn([_VAL_OPT_ADD_BOTH]))],
			[dnl We won't try to show that = and ' ' are possible in the help message
],
			[m4_define([_DELIM_IN_HELP], [ ])],
		)], [m4_do(
			[dnl SPACE
],
			[_MAYBE_EQUALS_MATCH_FACTORY([])],
			[m4_define([_DELIMITER], [[SPACE]])],
			[m4_define([_VAL_OPT_ADD], m4_defn([_VAL_OPT_ADD_SPACE]))],
			[m4_define([_DELIM_IN_HELP], [ ])],
		)])],
		[m4_bmatch([$1], [=], [m4_do(
			[dnl EQUALS
],
			[_MAYBE_EQUALS_MATCH_FACTORY([=*])],
			[m4_define([_DELIMITER], [[EQUALS]])],
			[m4_define([_VAL_OPT_ADD], m4_defn([_VAL_OPT_ADD_EQUALS]))],
			[m4_define([_DELIM_IN_HELP], [=])],
		)], [m4_fatal([We expect at least '=' or ' ' in the expression. Got: '$1'.])])])])



dnl
dnl Sets the option--value separator (i.e. --option=val or --option val
dnl $1: The directive (' ', '=', or ' =' or '= ')
argbash_api([ARGBASH_SET_DELIM], [m4_do(
	[m4_bmatch(m4_expand([_W_FLAGS]), [S], ,[[$0($@)]_SET_OPTION_DELIMITER([$1])])],
)])


dnl The default is both ' ' and '='
_SET_OPTION_DELIMITER([ =])


dnl
dnl $1: _argname
dnl $2: short opt.
dnl $3: _arg_type
dnl $4: _default
dnl $5: _varname(_argname)
m4_define([_OPTS_VALS_LOOP_BODY], [m4_do(
	[
_INDENT_(2,	)],
	[dnl Output short option (if we have it), then |
],
	[m4_ifblank([$2], [], [[-$2]_IF_CLUSTERING_GETOPT([*])|])],
	[dnl If we are dealing with bool, also look for --no-...
],
	[m4_if([$3], [bool], [[--no-$1|]])],
	[dnl and then long option for the case.
],
	[[--$1]],
	[_MAYBE_EQUALS_MATCH([$3], [$1])],
	[@:}@
],
	[dnl Output the body of the case
],
	[dnl _ADD_OPTS_VALS: If the arg comes from wrapped script/template, save it in an array
],
	[m4_case([$3],
		[arg], [_VAL_OPT_ADD([$1], [$2], [[$5="$_val"]], [$5])ADD_OPT_VALUE_VALIDATION([$_key], [$_val])],
		[repeated], [_VAL_OPT_ADD([$1], [$2], [[$5+=("$_val")]], [$5])ADD_OPT_VALUE_VALIDATION([$_key], [$_val])],
		[bool],
		[_JOIN_INDENTED(3,
			[[$5="on"]],
			[_ADD_OPTS_VALS([$5])],
			_PASS_WHEN_GETOPT([$2]),
			[[test "${1:0:5}" = "--no-" && $5="off"]],
		)],
		[incr],
		[_JOIN_INDENTED(3,
			[[$5=$(($5 + 1))]],
			_PASS_WHEN_GETOPT([$2]),
			[_ADD_OPTS_VALS([$5])],
		)],
		[action],
		[_JOIN_INDENTED(3,
			[[$4]],
			[exit 0],
		)],
	)],
	[_INDENT_(3);;],
)])


dnl
dnl $1: The name of the option arg
dnl $2: The value of the option arg
dnl Uses:
dnl _key - the run-time shell variable
m4_define([_ADD_OPTS_VALS], [m4_do(
	[dnl If the arg comes from wrapped script/template, save it in an array
],
	[dnl Strip everything after the first = sign (= the optionwithout value)
],
	[m4_ifdef([_COLLECT_$1], [_COLLECT_$1+=("${_key%%=*}"m4_ifnblank([$2], [ "$2"]))])],
)])


m4_define([_EVAL_OPTIONALS], [m4_do(
	[_INDENT_()_key="$[]1"
],
	[m4_if(HAVE_DOUBLEDASH, 1,
		[_JOIN_INDENTED(1,
			[if test "$_key" = '--'],
			[then],
			_INDENT_MORE(
				[shift],
				[_positionals+=("@S|@@")],
				[break]),
			[fi])
])],
	[_COMM_BLOCK(1,
		[# We now iterate through all passed arguments.],
		[# When dealing with optional arguments:],
		m4_case(_DELIMITER, [EQUALS], [m4_ignore(
		)[# We support only the = as a delimiter between option argument and its value.],
		[# Therefore, we expect --opt=value or -o value],
		[# so we watch for --opt=* and -o],
		[# For whatever we get, we strip '--opt=' using the ${var##...} notation.],
		[# if nothing got stripped, we know that we got the short option],
		[# so we reach out for the next argument.],
		[# At the end, either of what was successful is stored as the result.],
		], [SPACE], [m4_ignore(
		)[# We support only whitespace as a delimiter between option argument and its value.],
		[# Therefore, we expect --opt value or -o value],
		[# so we watch for --opt and -o],
		[# Since we know that we got the long or short option],
		[# we just reach out for the next argument.],
		], [BOTH], [m4_ignore(
		)[# We support both whitespace or = as a delimiter between option argument and its value.],
		[# Therefore, we expect --opt=value, --opt value or -o value],
		[# so we watch for --opt=*, --opt and -o],
		[# For whatever we get, we strip '--opt=' using the ${var##...} notation.],
		[# if nothing got stripped, we know that we got the long or short option],
		[# so we reach out for the next argument.],
		[# At the end, either of what was successful is stored as the result.],
		], [m4_fatal([Unknown case when handling delimiters])]),
	)],
	[_INDENT_()[case "$_key" in]],
	[dnl We don't do this if _NARGS == 0
],
	[m4_lists_foreach([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH,_ARGS_DEFAULT], [_argname,_arg_short,_arg_type,_default],
		[_OPTS_VALS_LOOP_BODY(_argname, _arg_short, _arg_type, _default, _varname(_argname))])],
	[m4_if(HAVE_POSITIONAL, 1,
		[m4_expand([_EVAL_POSITIONALS_CASE])],
		[m4_expand([_EXCEPT_OPTIONALS_CASE])])],
	[_INDENT_()[esac]],
)])


dnl Store positional args inside a 'case' statement (that is inside a 'for' statement)
m4_define([_EVAL_POSITIONALS_CASE], [m4_do(
	[
_INDENT_(2)],
	[*@:}@
],
	[_JOIN_INDENTED(3,
		[_positionals+=("$[]1")],
		[;;])],
)])


dnl If we expect only optional arguments and we get an intruder, fail noisily.
m4_define([_EXCEPT_OPTIONALS_CASE], [m4_do(
	[
_INDENT_(2)],
	[*@:}@
],
	[_JOIN_INDENTED(3,
		[_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$[]1'" 1],
		[;;])],
)])


dnl Store positional args inside a 'for' statement
m4_define([_EVAL_POSITIONALS_FOR],
	[_INDENT_()[_positionals+=("$][1")]])


m4_define([_MAKE_EVAL], [m4_do(
	[# THE PARSING ITSELF
],
	[while test $[]# -gt 0
do
],
	[m4_if(HAVE_OPTIONAL, 1,
		[m4_expand([_EVAL_OPTIONALS])],
		[m4_expand([_EVAL_POSITIONALS_FOR])])
],
	[_INDENT_()[shift
done]],
	[
],
	[m4_if(HAVE_POSITIONAL, 1, [m4_do(
		[dnl Now we look what positional args we got and we say if they were too little or too many. We also do the assignment to variables using eval.
],
		[
],
		[_COMM_BLOCK(0,
			[# We have an array of variables to which we want to save positional args values.],
			[# This array is able to hold array elements as targets.],
		)],
		[[_positional_names=@{:@]],
		[m4_lists_foreach([_POSITIONALS_NAMES,_POSITIONALS_MAXES], [_pos_name,_max_argn], [m4_do(
			[dnl Go through all positionals names ...
],
			[dnl If we accept inf args, it may be that _max_argn == 0 although we HAVE_POSITIONAL
],
			[m4_if(_max_argn, 0, , [m4_do(
				[m4_for([jj], 1, _max_argn, 1, [m4_do(
					[dnl And repeat each of them POSITIONALS_MAXES-times
],
					['],
					[_varname(_pos_name)],
					[dnl If we handle a multi-value arg, we assign to an array => we add '[ii - 1]' to LHS
],
					[m4_if(_max_argn, 1, , [@<:@m4_eval(jj - 1)@:>@])],
					[' ],
				)])],
			)])],
		)])],
		[_COMM_BLOCK(0,
			[# Now check that we didn't receive more or less of positional arguments than we require.],
		)],
		[m4_pushdef([_NARGS_SPEC], IF_POSITIONALS_INF([[at least ]_POSITIONALS_MIN], m4_if(_POSITIONALS_MIN, _POSITIONALS_MAX, [[exactly _POSITIONALS_MIN]], [[between _POSITIONALS_MIN and _POSITIONALS_MAX]])))],
		[dnl TODO: Determine mandatory positional args since they are useful as error messages
],
		[@:}@
],
		[_required_args_string="m4_list_join([_POSITIONALS_REQUIRED], [, ], , , [ and ])"
],
		[[test ${#_positionals[@]} -lt ]],
		[_POSITIONALS_MIN],
		[[ && _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require ]],
		[_NARGS_SPEC],
		[ (namely: $_required_args_string)],
		[[, but got only ${#_positionals[@]}." 1
]],
		[IF_POSITIONALS_INF(
			[m4_do(
				[dnl If we allow up to infinitely many args, we prepare the array for it.
],
				[_our_args=$((${#_positionals@<:@@@:>@} - ${#_positional_names@<:@@@:>@}))
],
				[for (( ii = 0; ii < _our_args; ii++))
do
_INDENT_()_positional_names+=("_INF_VARNAME@<:@(($ii + _INF_ARGN))@:>@")
done

],
			)],
			[m4_do(
				[dnl If we allow up to infinitely many args, there is no point in warning about too many args.
],
				[[test ${#_positionals[@]} -gt ]],
				[_POSITIONALS_MAX],
				[[ && _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect ]],
				[_NARGS_SPEC],
				[ (namely: $_required_args_string)],
				[dnl The last element of _positionals (even) for bash < 4.3 according to http://unix.stackexchange.com/a/198790
],
				[[, but got ${#_positionals[@]} (the last one was: '${_positionals[*]: -1}')." 1
]],
			)])],
		[m4_popdef([_NARGS_SPEC])],
		[_COMM_BLOCK(0,
			[# Take arguments that we have received, and save them in variables of given names.],
			[# The 'eval' command is needed as the name of target variable is saved into another variable.],
		)],
		[[for (( ii = 0; ii < ${#_positionals[@]}; ii++))
do
]_INDENT_()[eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during argument parsing, possibly an Argbash bug." 1]_CASE_RESTRICT_VALUES(
	[], [], [_COMM_BLOCK([
_INDENT_()# It has been requested that all positional arguments that look like options are rejected])
_INDENT_()[evaluate_strictness "${_positional_names[ii]}" "${_positionals[ii]##_arg}"]])
[done]],
		[
],
		[m4_list_ifempty([_WRAPPED_ADD_SINGLE], [], [m4_set_foreach([_POS_VARNAMES], [varname], [varname=()
])])],
		[m4_join([
], m4_unquote(m4_list_contents([_WRAPPED_ADD_SINGLE])))],
	)])],
)])


dnl
dnl $1: argname macro
dnl $2: _arg_type
dnl $3: _min_argn
dnl $4: _defaults
dnl
dnl Make defaults for arguments that possibly accept more than one value
m4_define([_MAKE_DEFAULTS_MORE_VALS], [m4_do(
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
			[more], [_MAKE_DEFAULTS_MORE_VALS([$1], [$2], [$3], [$4])],
			[inf], [_MAKE_DEFAULTS_MORE_VALS([$1], [$2], [$3], [$4])],
		)],
		[
],
	)], [m4_do(
		[dnl Just initialize the variable with blank value
],
		[m4_if(_ARG_DEFAULTS_POS, [yes], [_varname([$1])=
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
	[m4_if(HAVE_OPTIONAL, 1, [m4_do(
		[# THE DEFAULTS INITIALIZATION - OPTIONALS
],
		[m4_lists_foreach([_ARGS_LONG,_ARGS_CATH,_ARGS_DEFAULT], [_argname,_arg_type,_default], [m4_do(
			[m4_pushdef([_ARGVAR], [_varname(_argname)])],
			[dnl We have to handle 'incr' as a special case, there is a m4_default(..., 0)
],
			[m4_case(_arg_type,
				[action], [],
				[incr], [_ARGVAR=m4_expand(_default)
],
				[_ARGVAR=_default
])],
			[m4_popdef([_ARGVAR])],
		)])],
	)])],
)])


dnl
dnl Make some utility stuff.
dnl Those include the die function as well as optional validators
m4_define([_MAKE_UTILS], [m4_do(
	[_COMM_BLOCK(0,
		[# When called, the process ends.],
		[# Args:],
		[# _INDENT_()@S|@1: The exit message (print to stderr)],
		[# _INDENT_()@S|@2: The exit code (default is 1)],
		[# if env var _PRINT_HELP is set to 'yes', the usage is print to stderr (prior to $1)],
		[# Example:],
		[# _INDENT_()test -f "$_arg_infile" || _PRINT_HELP=yes die "Can't continue, have to supply file as an argument, got '$_arg_infile'" 4],
	)],
	[[die()
{
]],
	[_JOIN_INDENTED(1,
		[local _ret=$[]2],
		[test -n "$_ret" || _ret=1],
		[test "$_PRINT_HELP" = yes && print_help >&2],
		[echo "$[]1" >&2],
		[exit ${_ret}])],
	[}
],
	[_IF_RESTRICT_VALUES([_MAKE_RESTRICT_VALUES_FUNCTION])],
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
	[_VALIDATE_VALUES],
)])


dnl And stop those annoying diversion warnings
m4_define([_m4_divert(STDOUT)], 1)


dnl Expand to 1 if we don't have positional nor optional args
m4_define([_NO_ARGS_WHATSOEVER],
	[m4_if(HAVE_POSITIONAL, 1, 0,
		m4_if(HAVE_OPTIONAL, 1, 0, 1))])


argbash_api([ARGBASH_GO], [m4_do(
	[m4_ifndef([WRAPPED], [_ARGBASH_GO([$0()])])],
)])


dnl
dnl Identify the Argbash version (this is part of the API)
m4_define([_ARGBASH_ID],
	[### START OF CODE GENERATED BY Argbash v]_ARGBASH_VERSION[ one line above ###])


dnl $1: The macro call (the caller is supposed to pass [$0($@)])
dnl What is also part of the API: The line
dnl ### START OF CODE GENERATED BY Argbash vx.y.z one line above ###
m4_define([ARGBASH_GO_BASE], [m4_do(
	[[$1
]],
	[m4_if(m4_cmp(0, m4_list_len([_POSITIONALS_MINS])), 1,
		m4_define([_POSITIONALS_MIN], [m4_list_sum(_POSITIONALS_MINS)]))],
	[[# needed because of Argbash --> m4_ignore@{:@@<:@
]],
	[_ARGBASH_ID
],
	[[# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info

]],
	[_SETTLE_ENV],
	[m4_if(_NO_ARGS_WHATSOEVER, 1, [], [m4_do(
		[_MAKE_UTILS
],
		[_MAKE_DEFAULTS
],
		[_MAKE_HELP
],
		[_MAKE_EVAL
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
argbash_api([ARGBASH_WRAP], [m4_do(
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


dnl
dnl Macro:
dnl no args
dnl Function:
dnl $1: Name of the env var
dnl $2: The program name
dnl $3: The error message
m4_define([_CHECK_PROG_FACTORY_INDIR], [m4_do(
	[check_prog
],
	[{
],
	[_JOIN_INDENTED(1,
		[local _msg="@S|@3"],
		[test -n "$_msg" || _msg="Unable to find a reachable executable '@S|@2'"],
		[eval "test -n \"@S|@@S|@1\" || @S|@1=\"@S|@2\""],
		[eval "test -x \"$(which \"@S|@2\")\" && @S|@1=\"$(which \"@S|@2\")\" || die \"$_msg\" 1"],
	)],
	[}
],
)])


dnl
dnl Macro:
dnl $1: The env var name
dnl $2: The prog name
dnl $3: The msg
dnl Function:
dnl no args
m4_define([_CHECK_PROG_FACTORY_SINGLE], [m4_do(
	[check_prog
],
	[{
],
	[_JOIN_INDENTED(1,
		[test -n "@S|@$1" || $1="$2"],
		[test -x "$(which "@S|@$1")" && $1="$(which "@S|@$1")" || die "m4_default([$3], [Unable to find a reachable executable '$2'])" 1],
	)],
	[}
],
)])


dnl
dnl Given a program name, error messages and variable name, do this:
dnl  - if a var name is not empty, test the prog (find the file with rx permissions), if not OK, die with our msg
dnl  - else try: progname until RC == 0
dnl  - if nothing is found, die with provided msg
dnl  - if successful, save the form that works in a variable (i.e. don't try to make it an absolute path at all costs)
dnl
dnl $1 - env var (default: argbash translit of prog name)
dnl $2 - prog name
dnl $3 - msg if not OK
dnl $4 - help message (if you want to mention existence of this in the help)
dnl $5 - args (if you want to check args)
dnl
dnl  In case of path issues (i.e. script is in a crontab), update the PATH variable yourself above the argbash code.
dnl
dnl  internally:
dnl  PROG_NAMES, PROG_VARS, PROG_MSGS, PROG_HELPS, PROG_ARGS, PROG_HAVE_ARGS
argbash_api([ARG_USE_PROG], [m4_ifndef([WRAPPED], [m4_do(
	[m4_list_append([PROG_VARS], m4_default([$1], _translit_prog([$2])))],
	[m4_list_append([PROG_NAMES], [$2])],
	[m4_list_append([PROG_MSGS], [$3])],
	[m4_list_append([PROG_HELPS], [$4])],
	[m4_list_append([PROG_ARGS], [$5])],
	[dnl Even if $# == 5, $5 can be blank, which we support.
],
	[m4_list_append([PROG_HAVE_ARGS], m4_if([$#], 5, 1, 0))],
)])])


dnl
dnl $1: A prologue message
m4_define([_HELP_PROGS], [m4_list_ifempty([PROG_VARS], ,
	[$1
m4_for([idx], 1, m4_list_len([PROG_VARS]), 1, [m4_do(
		[],
)])])])


dnl
dnl Given an env variable name, assign a default value to it (if it is empty)
dnl  $1 - env var
dnl  $2 - default value (optional, but maybe it shouldn't be blank unless we have $# >=4)
dnl  $3 - help message (optional)
dnl  $4 - (don't implement now) arg name the env var can default to (none by default, the env default's priority is higher than default's priority, but lower than actual argument value)
dnl
dnl  internally:
dnl  ENV_NAMES, ENV_DEFAULTS, ENV_HELPS, ENV_ARGNAMES
dnl TODO: Hanlde the case of wrapping correctly
dnl TODO: Find out a proper name for this
argbash_api([ARG_USE_ENV], [m4_ifndef([WRAPPED], [m4_do(
	[[$0($@)]],
	[m4_list_append([ENV_NAMES], [$1])],
	[m4_list_append([ENV_DEFAULTS], [$2])],
	[m4_list_append([ENV_HELPS], [$3])],
	[m4_list_append([ENV_ARGNAMES], [$4])],
)])])


m4_define([_SETTLE_ENV], [m4_list_ifempty([ENV_NAMES], , [m4_lists_foreach([ENV_NAMES,ENV_DEFAULTS], [_name,_default], [m4_do(
	[# Setting environmental variables
],
	[m4_ifnblank(m4_quote(_default), [m4_list_append([_OTHER],
		m4_expand([__SETTLE_ENV(m4_expand([_name]), m4_expand([_default]))]))])],
)])]
)])


m4_define([_ENV_HELP], [m4_lists_foreach([ENV_NAMES,ENV_DEFAULTS,ENV_HELPS], [_name,_default,_help], [m4_do(
	[m4_ifnblank(m4_quote(_help), [m4_list_append([LIST_ENV_HELP], m4_expand([m4_do(
		[m4_expand([_name: _help.])],
		[m4_ifnblank(m4_quote(_default), m4_expand([[ (default: ']_default')]))],
	)]))])],
)])])


dnl
dnl $1: name
dnl $2: default
dnl TODO: Try to use the 'declare' builtin to see whether the variable is even defined
m4_define([__SETTLE_ENV], [m4_do(
	[test -n "@S|@$1" || $1="$2"
],
)])


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
dnl Define a validator for a particular type. Instead of using m4_define, use this:
dnl $1: The type ID
dnl $2: The validator body (a shell function accepting $1 - the value, $2 - the argument name)
dnl $3: The type description
m4_define([_define_validator], [m4_do(
	[m4_set_contains([VALUE_TYPES], [$1], [m4_fatal([We already have the validator for '$1'.])])],
	[m4_set_add([VALUE_TYPES], [$1])],
	[m4_define([_validator_$1], [$2
])],
	[m4_define(__type_str([$1]), [[$3]])],
)])


dnl
dnl Put definitions of validating functions if they are needed
m4_define([_PUT_VALIDATORS], [m4_do(
	[m4_set_empty([VALUE_TYPES_USED], , [# validators
])],
	[m4_set_foreach([VALUE_TYPES], [_val_type], [m4_do(
		[m4_set_empty(m4_expand([[VALUE_GROUP_]_val_type]), ,
			m4_expand([[_validator_]_val_type]))],
	)])],
)])


dnl
dnl Define an int validator
dnl double quoting is important because of the [] group inside
_define_validator([int],
[[function int
{
	printf "%s" "@S|@1" | grep -q '^\s*[+-]\?[0-9]\+\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not an integer."
	printf "%d" @S|@1  # it is a number, so we can relax the quoting
}
]], [integer])


dnl Define a positive int validator
_define_validator([pint],
[[function pint
{
	printf "%s" "@S|@1" | grep -q '^\s*[+]\?0*[1-9][0-9]*\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not a positive integer."
	printf "%d" @S|@1  # it is a number, so we can relax the quoting
}
]], [positive integer])


dnl Define a non-negative int validator
_define_validator([nnint],
[[function nnint
{
	printf "%s" "@S|@1" | grep -q '^\s*+\?[0-9]\+\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not a non-negative integer."
	printf "%d" @S|@1  # it is a number, so we can relax the quoting
}
]], [positive integer or zero])


dnl Define a float number validator
_define_validator([float],
[[function float
{
	printf "%s" "@S|@1" | grep -q '^\s*[+-]\?[0-9]\+(\.[0-9]\+(e[0-9]\+)?)?\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not a floating-point number."
	printf "%d" @S|@1  # it is a number, so we can relax the quoting
}
]], [floating-point number])


dnl Define a decimal number validator
_define_validator([decimal],
[[function decimal
{
	printf "%s" "@S|@1" | grep -q '^\s*[+-]\?[0-9]\+(\.[0-9]\+)?\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not a plain-old decimal number."
	printf "%d" @S|@1  # it is a number, so we can relax the quoting
}
]], [decimal number])


dnl The string validator is a null validator
_define_validator([string])


dnl
dnl For all arguments we know that are typed, re-assign their values using the validator function, e.g.
dnl arg_val=$(validate $arg_val argument-name) || exit 1
dnl Remarks:
dnl  - The argument name misses -- if it is an optional argument, because we don't know what type of arg this is
dnl  - The subshell won't propagate the die call, so that's why we have to exit "manually"
dnl  - Validator is not only a validator - it is a cannonizer.
dnl  - The type 'string' does not undergo validation
m4_define([_VALIDATE_VALUES], [m4_do(
	[m4_set_empty([TYPED_ARGS], , [# Validation of values
])],
	[dnl Don't do anything if we are string
],
	[m4_set_foreach([TYPED_ARGS], [_arg], [m4_if(_GET_VALUE_TYPE(_arg, 1), [string], , [m4_do(
		[_varname(_arg)="@S|@@{:@],
		[_GET_VALUE_TYPE(_arg, 1)],
		[ "$_varname(_arg)" "_arg"@:}@"],
		[ || exit 1],
		[
],
	)])])],
	[m4_set_foreach([GROUP_ARGS], [_arg], [m4_do(
		[_VALIDATE_VALUES_IDX(_arg, m4_expand([_]_arg[_SUFFIX]))],
	)])],
)])


dnl
dnl $1: argname
dnl $2: suffix
m4_define([_VALIDATE_VALUES_IDX], [m4_ifnblank([$2], [m4_do(
	[_varname([$1])[_$2="@S|@@{:@]],
	[_GET_VALUE_TYPE([$1], 1)],
	[ "$_varname([$1])" "[$1]" idx@:}@"],
	[
],
)])])


dnl
dnl The common stuff to perform when adding a typed group
dnl Registers the argument-type pair to be retreived by _GET_VALUE_TYPE or _GET_VALUE_STR
dnl $1: The value type
dnl $2: The type group name (NOT optional)
dnl $3: Concerned arguments (as a list)
m4_define([_TYPED_GROUP_STUFF], [m4_do(
	[m4_set_contains([VALUE_TYPES], [$1], , [m4_fatal([The type '$1' is unknown.])])],
	[m4_set_add([VALUE_TYPES_USED], [$1])],
	[m4_set_contains([VALUE_GROUPS], [$2], [m4_fatal([Value group $2 already exists!])])],
	[m4_set_add([VALUE_GROUPS], [$2])],
	[m4_foreach([_argname], m4_dquote($3), [m4_do(
		[dnl TODO: Test that vvv this check vvv works
],
		[m4_set_contains([TYPED_ARGS], _argname,
			[m4_fatal([Argument ]_argname[ already has a type ](_GET_VALUE_TYPE(_argname, 1))!)])],
		[m4_set_add([VALUE_GROUP_$1], _argname)],
		[m4_set_add([TYPED_ARGS], _argname)],
		[m4_define(_argname[_VAL_TYPE], [[$1]])],
		[m4_define(_argname[_VAL_GROUP], [[$2]])],
	)])],
	[m4_define([$2_VALIDATOR], [[_validator_$1]])],
)])


dnl
dnl $1: The value type string (code)
dnl $2: The type group name (optional, try to infer from value type)
dnl $3: Concerned arguments (as a list)
dnl TODO: Integrate with help (and not only with the help synopsis)
dnl TODO: Validate the type value (code) string
argbash_api([ARG_TYPE_GROUP], [m4_do(
	[[$0($@)]],
	[m4_ifblank([$2], [m4_fatal([Name inference not implemented yet])])],
	[_TYPED_GROUP_STUFF([$1], m4_dquote(m4_default([$2], [???])), [$3])],
)])


dnl
dnl $1: The value type string (code)
dnl $2: The type group name
dnl $3: Concerned arguments (as a list)
dnl $4: The set of possible values (as a list)
dnl $5: The index variable suffix
dnl TODO: Integrate with help (and not only with the help synopsis)
argbash_api([ARG_TYPE_GROUP_SET], [m4_do(
	[[$0($@)]],
	[m4_foreach([_val], [$4], [m4_do(
		[m4_list_append([_LIST_$1_QUOTED], m4_quote(_sh_quote(m4_quote(_val))))],
		[m4_list_append([_LIST_$1], m4_quote(_val))],
	)])],
	[_define_validator([$1], m4_expand([_MK_VALIDATE_GROUP_FUNCTION([$1], [$5])]),
		m4_expand([[one of ]m4_list_join([_LIST_$1], [, ], ', ', [ and ])]))],
	[m4_foreach([_argname], [$3], [m4_do(
		[m4_set_add([GROUP_ARGS], m4_quote(_argname))],
		[m4_define([_]m4_quote(_argname)[_SUFFIX], [[$5]])],
	)])],
	[_TYPED_GROUP_STUFF([$1], [$2], [$3])],
)])


dnl
dnl Given an argname, return the argument group name (i.e. type string) or 'arg'
dnl
dnl $1: argname
m4_define([_GET_VALUE_STR], [m4_do(
	[m4_ifdef([$1_VAL_GROUP], [m4_indir([$1_VAL_GROUP])], [arg])],
)])

dnl
dnl Given an argname, return the argument type code or 'generic'
dnl If strict is not blank, raise an error if there is not a type code stored
dnl
dnl $1: argname
dnl $2: strict
m4_define([_GET_VALUE_TYPE], [m4_do(
	[m4_ifdef([$1_VAL_TYPE], [m4_indir([$1_VAL_TYPE])],
		[m4_ifnblank([$2], [m4_fatal([There is no type defined for argument '$1'.])], [generic])])],
)])



dnl
dnl If specified, request to initialize positional arguments to empty values (if they don't have defaults)
argbash_api([ARG_DEFAULTS_POS], [m4_do(
	[m4_define([_ARG_DEFAULTS_POS], [[yes]])],
)])


m4_set_add([_S_RESTRICT_VALUES_MODES], [none])
m4_set_add([_S_RESTRICT_VALUES_MODES], [no-local-options])
m4_set_add([_S_RESTRICT_VALUES_MODES], [no-any-options])
dnl
dnl Sets the strict mode global
dnl When the strict mode is on, some argument values are blacklisted
argbash_api([ARG_RESTRICT_VALUES], [m4_do(
	[[$0($@)]],
	[m4_set_contains([_S_RESTRICT_VALUES_MODES], [$1], ,
		[m4_fatal([Invalid strict mode - used '$1', but you have to use one of: ]m4_set_contents([_S_RESTRICT_VALUES_MODES], [, ]).)])],
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


m4_define([_MAKE_RESTRICT_VALUES_FUNCTION], [m4_do(
	[_COMM_BLOCK(0,
		[# Function that evaluates whether a value passed to an argument],
		[# does not violate the global rule imposed by the ARG_RESTRICT_VALUES macro:],
		[# _CASE_RESTRICT_VALUES([],
		[The value must not match any long or short option this script uses],
		[The value must not match anything that looks like any long or short option.])],
		[# _INDENT_()@S|@1: The name of the option],
		[# _INDENT_()@S|@2: The passed value],
	)],
	[[evaluate_strictness()
{
]],
	[_INDENT_()_CASE_RESTRICT_VALUES([],
		[@<:@@<:@ "@S|@2" =~ ^-(-(m4_list_join([_ARGS_LONG], [|]))$|m4_dquote(m4_list_join([_ARGS_SHORT], []))) @:>@@:>@ && die "You have passed '@S|@2' as a value of argument '@S|@1', which makes it look like that you have omitted the actual value, since '@S|@2' is an option accepted by this script. This is considered a fatal error."],
		[@<:@@<:@ "@S|@2" =~ ^--?@<:@a-zA-Z@:>@ @:>@@:>@ && die "You have passed '@S|@2' as a value of argument '@S|@1'. It looks like that you are trying to pass an option instead of the actual value, which is considered a fatal error."])],
	[
}],
)])


dnl
dnl Adds the code to ensure that the variable that contains the freshly passed value from the command-line is not blacklisted
dnl $1: Name of the run-time variable that contains the value
dnl $2: Name of the run-time variable that contains the option or argument name
m4_define([ADD_OPT_VALUE_VALIDATION], [m4_do(
	[_IF_RESTRICT_VALUES(
		[_INDENT_(3)evaluate_strictness "$1" "$2"
],
		[])],
)])


dnl
dnl $1: The mode of argument clustering: One of 'none', 'getopts'
argbash_api([ARG_CLUSTERING], [m4_do(
	[[$0($@)]],
	[m4_define([_CLUSTERING_MODE], [[$1]])],
)])


m4_define([_IF_CLUSTERING_GETOPT], [m4_if(_CLUSTERING_MODE, [getopt], [$1], [$2])])
dnl Set the default value
ARG_CLUSTERING([getopt])


dnl
dnl Normally, we would just wait for the shift.
dnl However, we now transform '-xyz' to '-x' '-yz', so '-x' disappears during the shift
dnl and the rest is processed the next time.
dnl
dnl $1: The short option
m4_define([_PASS_WHEN_GETOPT], [m4_ifnblank([$1], [m4_do(
	[_IF_CLUSTERING_GETOPT([[[_next="${_key##-$1}"]], [[test -n "$_next" && test "$_next" != "$_key" && shift && set -- "-$1" "-${_next}" "@S|@@"]]])],
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
dnl
dnl defauls handling:
dnl - X -> _MAKE_DEFAULTS -> _MAKE_DEFAULTS_POSITIONALS_LOOP -> _MAKE_DEFAULTS_MORE_VALS
dnl - X -> _MAKE_HELP -> _POS_ARG_HELP_DEFAULTS -> _MAKE_DEFAULTS_MORE_MSG

dnl These macros are not needed and they present a security threat when exposed during Argbash run
m4_undefine([m4_esyscmd])
m4_undefine([m4_syscmd])
