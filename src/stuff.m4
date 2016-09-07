dnl We don't like the # comments
m4_changecom()

dnl TODO: Add support for opt types via arg groups
dnl TODO: Produce code completition
dnl TODO (maybe a bad idea altogether): Support for -czf foo (now only -c -z -f foo) --- use `set "-$rest" $@`
dnl TODO Support for -ffoo (alternative to -f foo, i.e. the null separator for short opts)
dnl TODO: Test for parsing library hidden in a subdirectory / having an absolute path(?)
dnl TODO: Make argbash-init template builder
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

dnl
dnl Checks that the n-th argument is an integer.
dnl Should be called upon the macro definition outside of quotes, e.g. m4_define([FOO], _CHECK_INTEGER_TYPE(1)[m4_eval(2 + $1)])
dnl $1: The argument number
dnl $2: The error message (optional)
m4_define([_CHECK_INTEGER_TYPE], __CHECK_INTEGER_TYPE([[$][0]], m4_quote($[]$1), [$1], m4_quote($[]2)))


dnl
dnl Checks that the an argument is a correct short option arg
dnl $1: The short option "string"
dnl $2: The argument name
m4_define([_CHECK_SHORT_OPT_TYPE], [m4_do(
	[m4_ifnblank([$1], [m4_bmatch([$1], [[a-zA-z]], , 
		[m4_fatal(['$1' is not a valid short option (for argument '$2') - it has to be one letter.])])])],
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
	[m4_pushdef([_flags], [$1])],
	[m4_pushdef([_fname], [[validate_file_]_flags])],
	[dnl Maybe we already have requested this function
],
	[m4_list_contains([_VALIDATE_FILE], _fname, , [m4_do(
		[m4_list_append([_VALIDATE_FILE], _fname)],
		[_fname[]()
],
		[{
],
		[_JOIN_INDENTED(1,
			[_FLAGS_D_IF([_flags], [m4_do(
				[m4_pushdef([_what], [[directory]])],
				[m4_pushdef([_xperm], [[browsable]])],
				[[test -d "@S|@1" || die "Argument '@S|@2' has to be a directory, got '@S|@1'" 4]],
				)], [m4_do(
				[m4_pushdef([_what], [[file]])],
				[m4_pushdef([_xperm], [[executable]])],
				[[test -f "@S|@1" || die "Argument '@S|@2' has to be a file, got '@S|@1'" 4]],
			)])],
			[_FLAGS_R_IF([_flags], [[test -r "@S|@1" || { echo "Argument '@S|@2' has to be a readable ]_what[, '@S|@1' isn't."; return 4; }]])],
			[_FLAGS_W_IF([_flags], [[test -w "@S|@1" || { echo "Argument '@S|@2' has to be a writable ]_what[, '@S|@1' isn't."; return 4; }]])],
			[_FLAGS_X_IF([_flags], [[test -x "@S|@1" || { echo "Argument '@S|@2' has to be a ]_xperm _what[, '@S|@1' isn't."; return 4; }]])],
		)],
		[}
],
	)])],
	[m4_popdef([_fname])],
	[m4_popdef([_flags])],
)])


dnl
dnl Given a arg type ID, it treats as a group type and creates a function to examine whether the value is in the list.
dnl $1: The group stem
dnl
dnl The bash function accepts:
dnl $1: The value to check
dnl $2: What was the option that was associated with the value
m4_define([_MK_VALIDATE_GROUP_FUNCTION], [m4_do(
	[array_contains ()
],
	[{
],
	[_JOIN_INDENTED(1,
		[local _allowed=(m4_list_contents([_VALUES_VALIDATE_$1]))],
		[local _seeking="@S|@1"],
		[for element in "${_allowed[@]}"],
		[do],
		[_INDENT_()test "$element" = "$_seeking" && return 0],
		[done],
		[echo "Value '$_seeking' (of argument '@S|@2') hasn't doesn't match the list of allowed values: ${_allowed}"],
		[return 4],
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
dnl Blank args are totally ignored, use @&t@ to get over that --- @&t@ is a quadrigraph that expands to nothing in the later phase
dnl $1: How many indents
dnl $2, $3, ...: What to put there
m4_define([_JOIN_INDENTED], _CHECK_INTEGER_TYPE(1, [depth of indentation])[m4_do(
	[m4_foreach([line], [m4_shift($@)], [m4_ifnblank(m4_quote(line), _INDENT_([$1])[]line
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


m4_define([_SET_INDENT], [m4_define([_INDENT_],
	[m4_for(_, 1, m4_default($][1, 1), 1,
		[[$1]])])])

dnl
dnl defines _INDENT_
dnl $1: How many times to indent (default 1)
dnl $2, ...: Ignored, but you can use those to make the code look somewhat better.

dnl Sets the default (tab) indent
_SET_INDENT([	])


dnl
dnl Sets the indentation character(s) in the parsing code
dnl $1: The indentation character(s)
m4_define([ARGBASH_SET_INDENT],
	[m4_bmatch(m4_expand([_W_FLAGS]), [I], ,[[$0($@)]_SET_INDENT([$1])])])


dnl We include the version-defining macro
m4_define([_ARGBASH_VERSION], m4_default_quoted(m4_normalize(m4_sinclude([version])), [unknown]))


dnl Contains implementation of m4_list_...
m4_include([list.m4])


dnl
dnl The operation on command names that makes stem of variable names
m4_define([_translit], [m4_translit(m4_translit([$1], [A-Z], [a-z]), [-], [_])])


dnl
dnl The operation on command names that converts them to variable names (where command values are stored)
m4_define([_opt_suffix], [[_opt]])
m4_define([_pos_suffix], [[_pos]])
m4_define([_arg_prefix], [[_arg_]])
m4_define([_args_prefix], [[_args_]])
m4_define([_varname], [_arg_prefix[]_translit([$1])])


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
	[m4_pushdef([_TLIT], m4_dquote(_translit([$1])))],
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
		[m4_set_add([_ARGS_GROUPS], m4_expand([_args_prefix[]_translit(WRAPPED)]))],
		[m4_define([_COLLECT_]m4_quote(_varname([$1])),  _args_prefix[]_translit(WRAPPED)[]_opt_suffix)],
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


m4_define([_POS_WRAPPED],[m4_ifdef([WRAPPED], [m4_do(
		[m4_set_add([_ARGS_GROUPS], m4_expand([_args_prefix[]_translit(WRAPPED)]))],
		[m4_set_add([_POS_VARNAMES], m4_expand([_args_prefix[]_translit(WRAPPED)[]_pos_suffix]))],
		[m4_list_append([_WRAPPED_ADD_SINGLE], m4_expand([_args_prefix[]_translit(WRAPPED)[]_pos_suffix+=([$1])]))],
)])])

dnl
dnl Declare one positional argument with default
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: Default (opt.)
m4_define([ARG_POSITIONAL_SINGLE], [m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [[$0($@)]_ARG_POSITIONAL_SINGLE($@)])],
)])


m4_define([_ARG_POSITIONAL_SINGLE], [m4_do(
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([The number of expected positional arguments before '$1' is unknown. This is not supported, define arguments that accept fixed number of values first.])], [])],
	[_POS_WRAPPED("${m4_quote(_varname([$1]))}")],
	[dnl Number of possibly supplied positional arguments just went up
],
	[m4_define([_POSITIONALS_MAX], m4_incr(_POSITIONALS_MAX))],
	[dnl If we don't have default, also a number of positional args that are needed went up
],
	[m4_ifblank([$3], [m4_do(
			[_A_POSITIONAL],
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
m4_define([ARG_POSITIONAL_INF], [m4_do(
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
	[_POS_WRAPPED(${m4_quote(_varname([$1]))@<:@@@:>@})],
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
dnl Declare sequence of multiple positional arguments
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: How many args
dnl $4, $5, ...: Defaults (opt.)
m4_define([ARG_POSITIONAL_MULTI], [m4_do(
	[_CHECK_OPTION_NAME([$1])],
	[m4_list_contains([BLACKLIST], [$1], , [[$0($@)]_ARG_POSITIONAL_MULTI($@)])],
)])


m4_define([_ARG_POSITIONAL_MULTI], [m4_do(
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([The number of expected positional arguments before '$1' is unknown. This is not supported, define arguments that accept fixed number of values first.])], [])],
	[_POS_WRAPPED(${m4_quote(_varname([$1]))@<:@@@:>@})],
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
	[m4_list_append([_POSITIONALS_MAXES], [$3])],
	[dnl Here, the _sh_quote actually ensures that the default is NOT BLANK!
],
	[m4_list_append([_POSITIONALS_DEFAULTS], [_$1_DEFAULTS])],
	[m4_if(m4_cmp($#, 3), 1, [m4_list_append([_$1_DEFAULTS], m4_shiftn(3, $@))])],
	[m4_popdef([_min_argn])],
	[_CHECK_ARGNAME_FREE([$1], [POS])],
)])


m4_define([ARG_OPTIONAL_SINGLE], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_some_opt([$1], [$2], [$3], _sh_quote([$4]), [arg])],
)])


m4_define([ARG_POSITIONAL_DOUBLEDASH], [m4_do(
	[m4_list_contains([BLACKLIST], [--], , [[$0($@)]_ARG_POSITIONAL_DOUBLEDASH($@)])],
)])


m4_define([_ARG_POSITIONAL_DOUBLEDASH], [m4_do(
	[m4_define([HAVE_DOUBLEDASH], 1)],
)])


dnl
dnl $1 The function to call to get the version
m4_define([ARG_VERSION], [m4_do(
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


m4_define([ARG_HELP], [m4_do(
	[[$0($@)]],
	[dnl Skip help if we declare we don't want it
],
	[m4_bmatch(m4_expand([_W_FLAGS]), [H], ,[_ARG_HELPx([$1])])],
)])


m4_define([_HELP_MSG])
dnl TODO: If the name is _ARG_HELP and not _ARG_HELPx, it doesn't work. WTF!?
m4_define([_ARG_HELPx], [m4_do(
	[m4_define([_HELP_MSG], m4_escape([$1]))],
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
dnl $1 = the filename (assuming that it is in the same directory as the script)
dnl $2 = what has been passed to DEFINE_SCRIPT_DIR as the first param
m4_define([INCLUDE_PARSING_CODE], [m4_do(
	[[$0($@)]],
	[m4_ifndef([SCRIPT_DIR_DEFINED], [m4_fatal([You have to use 'DEFINE_SCRIPT_DIR' before '$0'.])])],
	[m4_list_append([_OTHER],
		m4_expand([[. "$]m4_default([$2], _DEFAULT_SCRIPTDIR)[/$1]"  [# '.' means 'source'
]]))],
)])


dnl
dnl $1: Name of the holding variable
dnl Taken from: http://stackoverflow.com/a/246128/592892
m4_define([DEFINE_SCRIPT_DIR], [m4_do(
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

m4_define([_ARG_OPTIONAL_INCREMENTAL_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, [m4_default($][4, 0)], [incr])])
m4_define([_ARG_OPTIONAL_INCREMENTAL], [_A_OPTIONAL[]]_ARG_OPTIONAL_INCREMENTAL_BODY)


dnl $1 = long name
dnl $2 = short name (opt)
dnl $3 = help
dnl $4 = default (=0)
m4_define([ARG_OPTIONAL_INCREMENTAL], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	]m4_dquote(_ARG_OPTIONAL_INCREMENTAL_BODY)[,
)])

m4_define([_ARG_OPTIONAL_REPEATED_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, ($[]4), [repeated])])

dnl $1 = long name
dnl $2 = short name (opt)
dnl $3 = help
dnl $4 = default (empty array)
m4_define([ARG_OPTIONAL_REPEATED], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	]m4_dquote(_ARG_OPTIONAL_REPEATED_BODY)[,
)])


dnl $1 = short name (opt)
m4_define([ARG_VERBOSE], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_ARG_OPTIONAL_INCREMENTAL([verbose], [$1], [Set verbose output (can be specified multiple times to increase the effect)], 0)],
)])


dnl $1 = long name, var suffix (translit of [-] -> _)
dnl $2 = short name (opt)
dnl $3 = help
dnl $4 = default (=off)
m4_define([ARG_OPTIONAL_BOOLEAN], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_some_opt([$1], [$2], [$3],
		m4_default([$4], [off]), [bool])],
)])


m4_define([_ARG_OPTIONAL_ACTION_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, $[]4, [action])])


m4_define([ARG_OPTIONAL_ACTION], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[dnl Just call _ARG_OPTIONAL_ACTION with same args
],
	]m4_dquote(_ARG_OPTIONAL_ACTION_BODY)[,
)])


m4_define([_ARG_OPTIONAL_ACTION], [_A_OPTIONAL[]]_ARG_OPTIONAL_ACTION_BODY)


dnl
dnl uses macros argname, _min_argn, _max_argn
dnl In case of 'inf': If _INF_REPR is not blank, use it, otherwise compose the command-line yourself
m4_define([_POS_ARG_HELP_LINE], [m4_do(
	[m4_pushdef([_arg_type], m4_list_nth([_POSITIONAL_CATHS], idx))],
	[m4_case(m4_expand([_arg_type]),
		[single], [m4_list_append([_POSITIONALS_LIST], m4_if(_min_argn, 0,
			m4_expand([@<:@<argname>@:>@]), m4_expand([<argname>])))],
		[more], [m4_do(
			[m4_if(_min_argn, 0, ,
				[m4_for([idx2], 1, _min_argn, 1,
					[m4_list_append([_POSITIONALS_LIST], m4_expand([<argname-idx2>]))])])],
			[m4_if(_min_argn, _max_argn, ,
				[m4_for([idx2], m4_incr(_min_argn), _max_argn, 1,
					[m4_list_append([_POSITIONALS_LIST], m4_expand([@<:@<argname-idx2>@:>@]))])])])],
		[inf], [m4_ifnblank(_INF_REPR, [m4_list_append([_POSITIONALS_LIST], _INF_REPR)], [m4_do(
			[m4_if(_min_argn, 0, ,
				[m4_for([idx2], 1, _min_argn, 1,
					[m4_list_append([_POSITIONALS_LIST], m4_expand([<argname-idx2>]))])])],
			[m4_list_append([_POSITIONALS_LIST],
				m4_expand([@<:@<argname[-]m4_incr(_min_argn)>@:>@]),
				[...],
				m4_expand([@<:@<argname[-]n>@:>@]),
				[...])])])],
	[m4_fatal([$0: Unhandled arg type: ]'_arg_type')])],
	[m4_popdef([_arg_type])],
)])


m4_define([_MAKE_USAGE_MORE], [m4_do(
	[m4_list_ifempty(_defaults, , [m4_do(
		[[ @{:@defaults for ]argname(m4_incr(_min_argn))],
		[m4_if(m4_list_len(_defaults), 1, ,
			[[ to ]argname(m4_eval(_min_argn + m4_list_len(_defaults)))[ respectively]])],
		[: ],
		[m4_list_join(_defaults, [, ], ', ', [ and ])@:}@],
	)])],
)])


m4_define([_POS_ARG_HELP_USAGE], [m4_do(
	[m4_pushdef([_arg_type], m4_list_nth([_POSITIONAL_CATHS], idx))],
	[m4_case(m4_expand([_arg_type]),
		[single],
			[m4_if(_min_argn, 0, [m4_do(
				[ @{:@],
				[default: '"],
				[_defaults],
				["'],
				[@:}@],
			)])],
		[more], [_MAKE_USAGE_MORE],
		[inf], [_MAKE_USAGE_MORE],
	[m4_fatal([$0: Unhandled arg type: ]'_arg_type')])],
	[m4_popdef([_arg_type])],
)])


dnl
dnl $1: arg index
dnl Returns either --long or -l|--long if there is that -l
m4_define([_ARG_FORMAT], [m4_do(
	[m4_ifnblank(m4_list_nth([_ARGS_SHORT], idx),
		[-]m4_list_nth([_ARGS_SHORT], idx)|)],
	[[--]m4_list_nth([_ARGS_LONG], idx)],
)])


dnl
dnl $1: The command short description
m4_define([_MAKE_HELP], [m4_do(
	[# THE PRINT HELP FUNCION
],
	[print_help ()
{
],
	m4_ifnblank(m4_expand([_HELP_MSG]), m4_expand([_INDENT_()[echo] "_HELP_MSG"
])),
	[_INDENT_()[]printf 'Usage: %s],
	[dnl If we have optionals, display them like [--opt1 arg] [--(no-)opt2] ... according to their type. @<:@ becomes square bracket at the end of processing
],
	[m4_if(HAVE_OPTIONAL, 1,
		[m4_for([idx], 1, _NARGS, 1, [m4_do(
			[ @<:@],
			[m4_case(m4_list_nth([_ARGS_CATH], idx),
				[bool], [--(no-)]m4_list_nth([_ARGS_LONG], idx),
				[arg], [_ARG_FORMAT(idx)_DELIM_IN_HELP]m4_case([m4_list_nth([_ARGS_VAL_TYPE], idx)-unquote when _ARGS_VAL_TYPE is avail],
					[<arg>]),
				[repeated], [_ARG_FORMAT(idx)_DELIM_IN_HELP]m4_case([m4_list_nth([_ARGS_VAL_TYPE], idx)-unquote when _ARGS_VAL_TYPE is avail],
					[<arg>]),
				[_ARG_FORMAT(idx)])],
			[@:>@],
		)])],
	)],
	[m4_if(HAVE_DOUBLEDASH, 1, [[ @<:@--@:>@]])],
	[dnl If we have positionals, display them like <pos1> <pos2> ...
],
	[m4_if(HAVE_POSITIONAL, 1, [m4_do(
		[m4_for([idx], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [m4_do(
			[m4_pushdef([argname], m4_expand(m4_list_nth([_POSITIONALS_NAMES], idx)))],
			[m4_pushdef([_min_argn], m4_expand(m4_list_nth([_POSITIONALS_MINS], idx)))],
			[m4_pushdef([_max_argn], m4_expand(m4_list_nth([_POSITIONALS_MAXES], idx)))],
			[_POS_ARG_HELP_LINE],
			[m4_popdef([_max_argn])],
			[m4_popdef([_min_argn])],
			[m4_popdef([argname])],
		)])],
		[ m4_join([ ], m4_unquote(m4_list_contents([_POSITIONALS_LIST])))],
	)])],
	[\n' "$[]0"
],
	[dnl Don't display extended help for an arg if it doesn't have a description
],
	[m4_if(HAVE_POSITIONAL, 1,
		[m4_for([idx], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [m4_ifnblank(m4_list_nth([_POSITIONALS_MSGS], idx), [m4_do(
			[dnl We would like something else for argname if the arg type is 'inf' and _INF_VARNAME is not empty
],
			[m4_pushdef([argname], <m4_expand([m4_list_nth([_POSITIONALS_NAMES], idx)])[[]m4_ifnblank(m4_quote($][1), m4_quote(-$][1))]>)],
			[m4_pushdef([argname], m4_if(m4_list_nth(_POSITIONAL_CATHS, idx), [inf], [m4_default(_INF_REPR, argname)], [argname($][@)]))],
			[m4_pushdef([_min_argn], m4_expand([m4_list_nth([_POSITIONALS_MINS], idx)]))],
			[m4_pushdef([_defaults], m4_expand([m4_list_nth([_POSITIONALS_DEFAULTS], idx)]))],
			[_INDENT_()[printf "\t]argname[: ]],
			[m4_list_nth([_POSITIONALS_MSGS], idx)],
			[dnl Check whether we have defaults
],
			[_POS_ARG_HELP_USAGE],
			[m4_popdef([_defaults])],
			[m4_popdef([_min_argn])],
			[m4_popdef([argname])],
			[m4_popdef([argname])],
			[[\n"
]],
		)])])],
	)],
	[dnl If we have 0 optional args, don't do anything (FOR loop would assert, 0 < 1)
],
	[dnl Plus, don't display extended help for an arg if it doesn't have a description
],
	[m4_if(_NARGS, 0, [], [m4_for([idx], 1, _NARGS, 1, [m4_ifnblank(m4_list_nth([_ARGS_HELP], idx), [m4_do(
		[m4_pushdef([_VARNAME], [_varname(m4_list_nth([_ARGS_LONG], idx))])],
		[_INDENT_()printf "\t],
		[dnl Display a short one if it is not blank
],
		[m4_ifnblank(m4_list_nth([_ARGS_SHORT], idx), -m4_list_nth([_ARGS_SHORT], idx)[,])],
		[dnl Long one is never blank
],
		[--m4_list_nth([_ARGS_LONG], idx)],
		[dnl Bool have a long beginning with --no-
],
		[m4_case(m4_list_nth([_ARGS_CATH], idx), [bool], [,--no-]m4_list_nth([_ARGS_LONG], idx))],
		[: m4_list_nth([_ARGS_HELP], idx)],
		[dnl Actions don't have defaults
],
		[dnl WAS: We format defaults help by print-quoting them with ' and stopping the help echo quotes " before the store value is subsittuted, so the message should really match the real default.
],
		[dnl Now the default is expanded since it is between double quotes
],
		[m4_pushdef([_default], m4_quote(m4_list_nth([_ARGS_DEFAULT], idx)))],
		[m4_case(m4_list_nth([_ARGS_CATH], idx),
			[action], [],
			[incr], [],
			[bool], [ (%s by default)],
			[repeated], [ m4_if(m4_quote(_default), [()], [(empty by default)], [(default array: %s )])],
			[ @{:@m4_ifnblank(m4_quote(_default), [default: '%s'], [no default])@:}@])],
		[\n"],
		[dnl Single: We are already quoted
],
		[m4_case(m4_list_nth([_ARGS_CATH], idx),
			[action], [],
			[incr], [],
			[arg], [m4_ifnblank(m4_quote(_default), [ _default])],
			[repeated], [m4_ifnblank(m4_quote(_default), [ "m4_bpatsubst(m4_quote(_default), ", \\")"])],
			[m4_ifnblank(m4_quote(_default), [ "_default"])])],
		[
],
		[m4_popdef([_default])],
		[m4_popdef([_VARNAME])],
	)])])])],
	[}
],
)])



dnl
dnl $1: Arg name
dnl $2: Short arg name (if applicable)
dnl $3: Action
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
	[_ADD_OPTS_VALS($_ARGVAR)],
)])


dnl
dnl $1: Arg name
dnl $2: Short arg name (if applicable)
dnl $3: Action
m4_define([_VAL_OPT_ADD_SPACE], [_JOIN_INDENTED(3,
	[test $[]# -lt 2 && die "Missing value for the optional argument '$_key'." 1],
	[_val="@S|@2"],
	[shift],
	[$3],
	[_ADD_OPTS_VALS($_ARGVAR)],
)])


dnl
dnl $1: Arg name
dnl $2: Short arg name (if applicable)
dnl $3: Action - the variable containing the value to assign is '_val'
m4_define([_VAL_OPT_ADD_BOTH], [_JOIN_INDENTED(3,
	[_val="${_key##--[$1]=}"],
	[if test "$_val" = "$_key"],
	[then],
	_INDENT_MORE(
		[test $[]# -lt 2 && die "Missing value for the optional argument '$_key'." 1],
		[_val="@S|@2"],
		[shift]),
	[fi],
	[$3],
	[_ADD_OPTS_VALS($_ARGVAR)],
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
dnl Defines macro:
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
			[m4_define([_VAL_OPT_ADD], m4_defn([_VAL_OPT_ADD_BOTH]))],
			[dnl We won't try to show that = and ' ' are possible in the help message
],
			[m4_define([_DELIM_IN_HELP], [ ])],
		)], [m4_do(
			[dnl SPACE
],
			[_MAYBE_EQUALS_MATCH_FACTORY([])],
			[m4_define([_VAL_OPT_ADD], m4_defn([_VAL_OPT_ADD_SPACE]))],
			[m4_define([_DELIM_IN_HELP], [ ])],
		)])],
		[m4_bmatch([$1], [=], [m4_do(
			[dnl EQUALS
],
			[_MAYBE_EQUALS_MATCH_FACTORY([=*])],
			[m4_define([_VAL_OPT_ADD], m4_defn([_VAL_OPT_ADD_EQUALS]))],
			[m4_define([_DELIM_IN_HELP], [=])],
		)], [m4_fatal([We expect at least '=' or ' ' in the expression. Got: '$1'.])])])])

dnl
dnl Sets the option--value separator (i.e. --option=val or --option val
dnl $1: The directive (' ', '=', or ' =' or '= ')
m4_define([ARGBASH_SET_DELIM],
	[m4_bmatch(m4_expand([_W_FLAGS]), [S], ,[[$0($@)]_SET_OPTION_DELIMITER([$1])])])


dnl The default is both ' ' and '='
_SET_OPTION_DELIMITER([ =])


m4_define([_OPTS_VALS_LOOP_BODY], [m4_do(
	[
_INDENT_(2,	)],
	[dnl Output short option (if we have it), then |
],
	[m4_pushdef([_argname], m4_list_nth([_ARGS_LONG], [$1]))],
	[m4_pushdef([_argname_s], m4_list_nth([_ARGS_SHORT], [$1]))],
	[m4_ifblank(_argname_s, [], [-_argname_s|])],
	[dnl If we are dealing with bool, also look for --no-...
],
	[m4_if(m4_list_nth([_ARGS_CATH], [$1]), [bool], [[--no-]_argname|])],
	[dnl and then long option for the case.
],
	[--_argname],
	[_MAYBE_EQUALS_MATCH(m4_list_nth([_ARGS_CATH], [$1]), _argname)],
	[@:}@
],
	[m4_pushdef([_ARGVAR], [_varname(m4_expand([_argname]))])],
	[dnl Output the body of the case
],
	[dnl _ADD_OPTS_VALS: If the arg comes from wrapped script/template, save it in an array
],
	[m4_case(m4_list_nth([_ARGS_CATH], [$1]),
		[arg], [_VAL_OPT_ADD(_argname, _argname_s, _ARGVAR[="$_val"])],
		[repeated], [_VAL_OPT_ADD(_argname, _argname_s, _ARGVAR[+=("$_val")])],
		[bool],
		[_JOIN_INDENTED(3,
			_ARGVAR[="on"],
			[_ADD_OPTS_VALS()],
			[test "$[]{1:0:5}" = "--no-" && ]_ARGVAR[="off"],
		)],
		[incr],
		[_JOIN_INDENTED(3,
			m4_quote(_ARGVAR=$((_ARGVAR + 1))),
			[_ADD_OPTS_VALS()],
		)],
		[action],
		[_JOIN_INDENTED(3,
			[m4_list_nth([_ARGS_DEFAULT], idx)],
			[exit 0],
		)],
	)],
	[_INDENT_(3);;],
	[m4_popdef([_ARGVAR])],
	[m4_popdef([_argname_s])],
	[m4_popdef([_argname])],
)])


dnl
dnl $1: The value of the option arg
dnl Uses:
dnl _ARGVAR - name of the variable
dnl _key - the run-time shell variable
m4_define([_ADD_OPTS_VALS], [m4_do(
	[dnl If the arg comes from wrapped script/template, save it in an array
],
	[dnl Strip everything after the first = sign (= the optionwithout value)
],
	[m4_ifdef([_COLLECT_]_ARGVAR, [[_COLLECT_]_ARGVAR+=("${_key%%=*}"m4_ifnblank([$1], [ "$1"]))])],
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
	[_INDENT_()[case "$_key" in]],
	[dnl We don't do this if _NARGS == 0
],
	[m4_for([idx], 1, _NARGS, 1, [_OPTS_VALS_LOOP_BODY(idx)])],
	[m4_if(HAVE_POSITIONAL, 1,
		[m4_expand([_EVAL_POSITIONALS_CASE])],
		[m4_expand([_EXCEPT_OPTIONALS_CASE])])],
	[
],
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
		[[_positional_names=@{:@]],
		[m4_for([ii], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [m4_do(
			[dnl Go through all positionals names ...
],
			[m4_pushdef([_max_argn], m4_list_nth([_POSITIONALS_MAXES], ii))],
			[dnl If we accept inf args, it may be that _max_argn == 0 although we HAVE_POSITIONAL
],
			[m4_if(_max_argn, 0, , [m4_do(
				[m4_for([jj], 1, _max_argn, 1, [m4_do(
					[dnl And repeat each of them POSITIONALS_MAXES-times
],
					['],
					[_varname(m4_list_nth([_POSITIONALS_NAMES], ii))],
					[dnl If we handle a multi-value arg, we assign to an array => we add '[ii - 1]' to LHS
],
					[m4_if(_max_argn, 1, , [@<:@m4_eval(jj - 1)@:>@])],
					[' ],
				)])],
			)])],
			[m4_popdef([_max_argn])],
		)])],
		[m4_pushdef([_NARGS_SPEC], IF_POSITIONALS_INF([[at least ]_POSITIONALS_MIN], m4_if(_POSITIONALS_MIN, _POSITIONALS_MAX, [[exactly _POSITIONALS_MIN]], [[between _POSITIONALS_MIN and _POSITIONALS_MAX]])))],
		[[@:}@
test ${#_positionals[@]} -lt ]],
		[_POSITIONALS_MIN],
		[[ && _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require ]_NARGS_SPEC[, but got only ${#_positionals[@]}." 1
]],
		[IF_POSITIONALS_INF(
			[m4_do(
				[dnl If we allow up to infinitely many args, we prepare the array for it.
],
				[_OUR_ARGS=$((${#_positionals@<:@@@:>@} - ${#_positional_names@<:@@@:>@}))
],
				[for (( ii = 0; ii < _OUR_ARGS; ii++))
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
				[dnl The last element of _positionals (even) for bash < 4.3 according to http://unix.stackexchange.com/a/198790
],
				[[, but got ${#_positionals[@]} (the last one was: '${_positionals[*]: -1}')." 1
]],
			)])],
		[m4_popdef([_NARGS_SPEC])],
		[[for (( ii = 0; ii < ${#_positionals[@]}; ii++))
do
]_INDENT_()[eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during argument parsing, possibly an Argbash bug." 1
done]],
		[
],
		[m4_list_ifempty([_WRAPPED_ADD_SINGLE], [], [m4_set_foreach([_POS_VARNAMES], [varname], [varname=()
])])],
		[m4_join([
], m4_unquote(m4_list_contents([_WRAPPED_ADD_SINGLE])))],
	)])],
)])


dnl
dnl Make defaults for arguments that possibly accept more than one value
m4_define([_MAKE_DEFAULTS_MORE], [m4_do(
	[m4_pushdef([_min_argn], m4_list_nth([_POSITIONALS_MINS], idx))],
	[@{:@],
	[dnl m4_for([foo], 1, 0) doesn't work
],
	[m4_if(_min_argn, 0, ,
		[m4_for([foo], 1, _min_argn, 1, ['' ])])],
	[m4_join([ ],
		m4_map_sep(
			[_sh_quote],
			[,],
			m4_dquote(m4_list_contents(_DEFAULT))))],
	[@:}@],
	[m4_popdef([_min_argn])],
)])


dnl
dnl $1: The item index
dnl If the corresponding arg has a default, save it according to its type.
dnl If it doesn't have one, do nothing (TODO: to be reconsidered)
m4_define([_MAKE_DEFAULTS_POSITIONALS_LOOP], [m4_do(
	[m4_pushdef([_DEFAULT], m4_list_nth([_POSITIONALS_DEFAULTS], [$1]))],
	[m4_ifnblank(m4_quote(_DEFAULT), [m4_do(
		[_varname(m4_list_nth([_POSITIONALS_NAMES], [$1]))=],
		[m4_case(m4_list_nth([_POSITIONAL_CATHS], [$1]),
			[single], [_DEFAULT],
			[more], [_MAKE_DEFAULTS_MORE],
			[inf], [_MAKE_DEFAULTS_MORE],
		)],
		[
],
	)])],
	[m4_popdef([_DEFAULT])],
)])


dnl
dnl Create the part of the script where default values for arguments are assigned.
m4_define([_MAKE_DEFAULTS], [m4_do(
	[m4_if(HAVE_POSITIONAL, 1, [m4_do(
		[# THE DEFAULTS INITIALIZATION - POSITIONALS
],
		[m4_for([idx], 1, m4_list_len([_POSITIONALS_NAMES]), 1,
			[_MAKE_DEFAULTS_POSITIONALS_LOOP(idx)])],
	)])],
	[m4_if(HAVE_OPTIONAL, 1, [m4_do(
		[# THE DEFAULTS INITIALIZATION - OPTIONALS
],
		[m4_for([idx], 1, _NARGS, 1, [m4_do(
			[m4_pushdef([_ARGVAR], _varname(m4_list_nth([_ARGS_LONG], idx)))],
			[m4_case(m4_list_nth([_ARGS_CATH], idx),
				[action], [],
				m4_expand([_ARGVAR=m4_list_nth([_ARGS_DEFAULT], idx)
]))],
			[m4_popdef([_ARGVAR])],
		)])],
	)])],
)])


dnl
dnl Make some utility stuff.
dnl Those include the die function as well as optional validators
m4_define([_MAKE_UTILS], [m4_do(
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
)])


dnl And stop those annoying diversion warnings
m4_define([_m4_divert(STDOUT)], 1)


dnl Expand to 1 if we don't have positional nor optional args
m4_define([_NO_ARGS_WHATSOEVER],
	[m4_if(HAVE_POSITIONAL, 1, 0,
		m4_if(HAVE_OPTIONAL, 1, 0, 1))])


m4_define([ARGBASH_GO], [m4_do(
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
# Argbash is FREE SOFTWARE, know your rights: https://github.com/matejak/argbash

]],
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
m4_define([ARGBASH_WRAP], [m4_do(
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


m4_define([ARG_LEFTOVERS],
	[m4_list_contains([BLACKLIST], [leftovers], , [[$0($@)]_ARG_POSITIONAL_INF([leftovers], [$1], [0], [... ])])])

dnl If I am wrapped:
dnl It may be that the wrapped script contains args that we already have.
dnl TODO: In this case: Raise an error (with a good advice)


dnl Types:
dnl #. Register group name, assert uniquness
dnl #. Assign the validator to the name.
dnl #. Assign the name to args.
dnl #. Add the validator to the list of validators to be generated
dnl
dnl * Upon arg encounter, validate the value. Die in case of no compliance.
dnl * Help: optional args - value should take the name.
dnl       : positional args - value should have the arg name, but the type should be mentioned on the help line.
