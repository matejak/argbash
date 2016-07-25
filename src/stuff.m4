dnl We don't like the # comments
m4_changecom()


m4_define([_SET_INDENT], [m4_define([_INDENT_], 
	[m4_for(_, 1, m4_default($][1, 1), 1,
		[[$1]])])])

_SET_INDENT([	])


dnl We include the version-defining macro
m4_define([_ARGBASH_VERSION], m4_default_quoted(m4_normalize(m4_sinclude([version])), [unknown]))


m4_define([DEFINE_VERSION], [m4_do(
	[m4_define([USER_VERSION], m4_expand([m4_esyscmd_s([$1])]))],
	[m4_expand([USER_VERSION])],
)])


dnl Contains implementation of m4_list_...
m4_include([list.m4])


m4_define([_HELP_MSG])

dnl
dnl The operation on command names that makes stem of variable names
m4_define([_translit], [m4_translit(m4_translit([$1], [a-z], [A-Z]), [-], [_])])


dnl
dnl The operation on command names that converts them to variable names (where command values are stored)
m4_define([_varname], [_ARG_[]_translit([$1])])


dnl
dnl Encloses string into "" if its first char is not ' or "
dnl The string si also []-quoted
dnl Property: Quoting a blank input results in non-blank result
dnl to AVOID it, pass string like ""ls -l or "ls" -l
m4_define([_sh_quote], [m4_do(
	[m4_if(
		m4_index(['], [$1]), 0, [[$1]],
		m4_index(["], [$1]), 0, [[$1]],
		[["$1"]])],
)])


dnl
dnl $1: Argument name
dnl $2: Argument type (OPT or POS)
dnl
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
	[m4_ifblank(m4_list_contains([BLACKLIST], [$1]), [__some_opt($@)])],
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
		[m4_set_add([_ARGS_GROUPS], m4_expand([[_ARGS_]_translit(WRAPPED)]))],
		[m4_define([_COLLECT_]_varname([$1]),  [_ARGS_]_translit(WRAPPED)_OPT)],
	)])],
	[m4_list_add([_ARGS_LONG], [$1])],
	[dnl Check whether we didn't already use the arg, if not, add its tranliteration to the list of used ones
],
	[_CHECK_ARGNAME_FREE([$1], [OPT])],
	[m4_list_add([_ARGS_SHORT], [$2])],
	[m4_set_contains([_ARGS_SHORT], [$2],
		[m4_ifnblank([$2], [m4_fatal([The short option '$2' is already used.])])],
		[m4_set_add([_ARGS_SHORT], [$2])])],
	[m4_list_add([_ARGS_HELP], [$3])],
	[m4_list_add([_ARGS_DEFAULT], [$4])],
	[m4_list_add([_ARGS_TYPE], [$5])],
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

dnl To be able to use _POSITIONALS_NAMES_FOREACH etc.
m4_list_declare([_POSITIONALS_NAMES])
m4_list_declare([_POSITIONALS_MINS])


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


m4_define([_A_OPTIONAL], [m4_do(
	[m4_define([HAVE_OPTIONAL], 1)],
)])


dnl Do something depending on whether there is already infinitely many args possible or not
m4_define([IF_POSITIONALS_INF],
	[m4_if(m4_quote(_POSITIONALS_INF), 1, [$1], [$2])])


dnl Do something depending on whether there have been optional positional args declared beforehand or not
m4_define([IF_POSITIONALS_VARNUM],
	[m4_ifdef([HAVE_POSITIONAL_VARNUM], [$1], [$2])])


dnl
dnl Declare one positional argument with default
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: Default (opt.)
m4_define([ARG_POSITIONAL_SINGLE], [m4_do(
	[m4_ifblank(m4_list_contains([BLACKLIST], [$1]), [[$0($@)]_ARG_POSITIONAL_SINGLE($@)])],
)])


m4_define([_ARG_POSITIONAL_SINGLE], [m4_do(
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([The number of expected positional arguments before '$1' is unknown. This is not supported, define arguments that accept fixed number of values first.])], [])],
	[m4_ifdef([WRAPPED], [m4_do(
		[m4_set_add([_ARGS_GROUPS], m4_expand([[_ARGS_]_translit(WRAPPED)]))],
		[m4_set_add([_POS_VARNAMES], m4_expand([[_ARGS_]_translit(WRAPPED)_POS]))],
		[m4_list_add([_WRAPPED_ADD_SINGLE], m4_expand([[_ARGS_]_translit(WRAPPED)_POS+=@{:@"${_varname([$1])}"@:}@]))],
	)])],
	[dnl Number of possibly supplied positional arguments just went up
],
	[m4_define([_POSITIONALS_MAX], m4_incr(_POSITIONALS_MAX))],
	[dnl If we don't have default, also a number of positional args that are needed went up
],
	[m4_ifblank([$3], [m4_do(
			[_A_POSITIONAL],
			[m4_list_add([_POSITIONALS_MINS], 1)],
			[m4_list_add([_POSITIONALS_DEFAULTS], [])],
		)], [m4_do(
			[_A_POSITIONAL_VARNUM],
			[m4_list_add([_POSITIONALS_MINS], 0)],
			[m4_list_add([_POSITIONALS_DEFAULTS], _sh_quote([$3]))],
		)])],
	[m4_list_add([_POSITIONALS_MAXES], 1)],
	[m4_list_add([_POSITIONALS_NAMES], [$1])],
	[m4_list_add([_POSITIONALS_TYPES], [single])],
	[m4_list_add([_POSITIONALS_MSGS], [$2])],
	[dnl Here, the _sh_quote actually ensures that the default is NOT BLANK!
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
	[m4_ifblank(m4_list_contains([BLACKLIST], [$1]), [[$0($@)]_ARG_POSITIONAL_INF([$1], [$2], [$3], [],  m4_shiftn(3, $@))])],
)])


m4_define([_CHECK_INTEGER_TYPE], [m4_do(
	[m4_ifnblank([$1],
		[m4_if(0, 1,
			[m4_fatal([$2])],
			[])])],
)])


dnl TODO: Have an option to show in the help message
dnl
dnl $4: Representation of arg on command-line
dnl $5, ...: Defaults
m4_define([_ARG_POSITIONAL_INF], [m4_do(
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([The number of expected positional arguments before '$1' is unknown. This is not supported, define arguments that accept fixed number of values first.])], [])],
	[m4_define([_POSITIONALS_INF], 1)],
	[dnl We won't have to use stuff s.a. m4_quote(_INF_REPR), but _INF_REPR directly
],
	[m4_define([_INF_REPR], [[$4]])],
	[m4_list_add([_POSITIONALS_NAMES], [$1])],
	[m4_list_add([_POSITIONALS_TYPES], [inf])],
	[m4_list_add([_POSITIONALS_MSGS], [$2])],
	[_A_POSITIONAL_VARNUM],
	[_CHECK_INTEGER_TYPE([$3], [The third argument to ARG_POSITIONAL_INF (if supplied) is supposed to be minimal number of arguments (i.e. an integer), got '$3' instead.])],
	[m4_pushdef([_min_argn], m4_default([$3], 0))],
	[m4_define([_INF_ARGN], _min_argn)],
	[m4_define([_INF_VARNAME], _varname([$1]))],
	[m4_list_add([_POSITIONALS_MINS], _min_argn)],
	[m4_list_add([_POSITIONALS_DEFAULTS], [_$1_DEFAULTS])],
	[dnl If there are more than 3 args to this macro, add more stuff to defaults
],
	[m4_if(m4_cmp($#, 4), 1, [m4_list_add([_$1_DEFAULTS], m4_shiftn(4, $@))])],
	[dnl vvv This has to be like this, additional args that are not required are handled differently
],
	[m4_list_add([_POSITIONALS_MAXES], _min_argn)],
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
dnl TODO:
dnl  - handle defaults - now only one global default is allowed per script
dnl   - store them
dnl   - display them in the help
dnl   - use them to extend _positionals
dnl  - use constructs s.a. _positionals+=("${defaults[@]:0:$needed}")
m4_define([ARG_POSITIONAL_MULTI], [m4_do(
	[m4_ifblank(m4_list_contains([BLACKLIST], [$1]), [[$0($@)]_ARG_POSITIONAL_MULTI($@)])],
)])


m4_define([_ARG_POSITIONAL_MULTI], [m4_do(
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([The number of expected positional arguments before '$1' is unknown. This is not supported, define arguments that accept fixed number of values first.])], [])],
	[m4_ifdef([WRAPPED], [m4_do(
		[m4_set_add([_ARGS_GROUPS], m4_expand([[_ARGS_]_translit(WRAPPED)]))],
		[m4_set_add([_POS_VARNAMES], m4_expand([[_ARGS_]_translit(WRAPPED)_POS]))],
		[m4_list_add([_WRAPPED_ADD_SINGLE], m4_expand([[_ARGS_]_translit(WRAPPED)_POS+=@{:@${_varname([$1])@<:@@@:>@}@:}@]))]
	)])],
	[m4_define([_POSITIONALS_MAX], m4_eval(_POSITIONALS_MAX + [$3]))],
	[m4_list_add([_POSITIONALS_NAMES], [$1])],
	[m4_list_add([_POSITIONALS_TYPES], [more])],
	[m4_list_add([_POSITIONALS_MSGS], [$2])],
	[dnl Minimal number of args is number of accepted - number of defaults (= $3 - ($# - 3))
],
	[m4_pushdef([_min_argn], m4_eval([$3] - ($# - 3) ))],
	[dnl If we have defaults, we actually accept unknown number of arguments
],
	[m4_if(_min_argn, [$3], , [_A_POSITIONAL_VARNUM])],
	[m4_list_add([_POSITIONALS_MINS], _min_argn)],
	[m4_list_add([_POSITIONALS_MAXES], [$3])],
	[dnl Here, the _sh_quote actually ensures that the default is NOT BLANK!
],
	[m4_list_add([_POSITIONALS_DEFAULTS], [_$1_DEFAULTS])],
	[m4_if(m4_cmp($#, 3), 1, [m4_list_add([_$1_DEFAULTS], m4_shiftn(3, $@))])],
	[m4_popdef([_min_argn])],
	[_CHECK_ARGNAME_FREE([$1], [POS])],
)])


m4_define([ARG_OPTIONAL_SINGLE], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_some_opt([$1], [$2], [$3], _sh_quote([$4]), [arg])],
)])


m4_define([ARG_POSITIONAL_DOUBLEDASH], [m4_do(
	[m4_ifblank(m4_list_contains([BLACKLIST], [--]), [[$0($@)]_ARG_POSITIONAL_DOUBLEDASH($@)])],
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
	[m4_bmatch(m4_expand([FLAGS]), [V], ,[_ARG_VERSIONx([$1])])],
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
	[m4_bmatch(m4_expand([FLAGS]), [H], ,[_ARG_HELPx([$1])])],
)])


dnl If the name is _ARG_HELP and not _ARG_HELPx, it doesn't work. WTF!?
m4_define([_ARG_HELPx], [m4_do(
	[m4_define([_HELP_MSG], m4_escape([$1]))],
	[_ARG_OPTIONAL_ACTION(
		[help],
		[h],
		[Prints help],
		[print_help],
	)],
)])


m4_define([_DEFAULT_SCRIPTDIR], [[SCRIPT_DIR]])


dnl
dnl In your script, include just this directive (and DEFINE_SCRIPT_DIR before) to include the parsing stuff from a standalone file.
dnl The argbash script generator will pick it up and (re)generate that one as well
dnl
dnl $1 = the filename (assuming that it is in the same directory as the script)
dnl $2 = what has been passed to DEFINE_SCRIPT_DIR as the first param
m4_define([INCLUDE_PARSING_CODE], [m4_do(
	[[$0($@)]],
	[m4_ifndef([SCRIPT_DIR_DEFINED], [m4_fatal([You have to use 'DEFINE_SCRIPT_DIR' before '$0'.])])],
	[m4_list_add([_OTHER],
		m4_expand([[source "$]m4_default([$2], _DEFAULT_SCRIPTDIR)[/$1]"
]))],
)])


m4_define([DEFINE_SCRIPT_DIR], [m4_do(
	[[$0($@)]],
	[m4_define([SCRIPT_DIR_DEFINED])],
	[m4_pushdef([_sciptdir], m4_ifnblank([$1], [[$1]], _DEFAULT_SCRIPTDIR))],
	[m4_list_add([_OTHER],
		m4_quote(_sciptdir[="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || { echo "Couldn't determine the script's running directory, which probably matters, bailing out" >&2; exit 2; }]))],
	[m4_popdef([_sciptdir])],
)])


dnl Precedence is important, _CALL_SOME_OPT has to be defined early on
m4_define([_CALL_SOME_OPT], [[_some_opt([$1], [$2], [$3], [$4], [$5])]])

m4_define([_ARG_OPTIONAL_INCREMENTAL_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, $[]4, [incr])])
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

m4_define([_ARG_OPTIONAL_REPEATED_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, @{:@$[]4@:}@, [repeated])])

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


dnl In case of 'inf': If _INF_REPR is not blank, use it, otherwise compose the command-line yourself
m4_define([_POS_ARG_HELP_LINE], [m4_do(
	[m4_pushdef([_arg_type], m4_list_nth([_POSITIONALS_TYPES], idx))],
	[m4_case(m4_expand([_arg_type]),
		[single], [m4_list_add([_POSITIONALS_LIST], m4_if(_min_argn, 0,
			m4_expand([@<:@<argname>@:>@]), m4_expand([<argname>])))],
		[more], [m4_do(
			[m4_if(_min_argn, 0, ,
				[m4_for([idx2], 1, _min_argn, 1,
					[m4_list_add([_POSITIONALS_LIST], m4_expand([<argname-idx2>]))])])],
			[m4_if(_min_argn, _max_argn, ,
				[m4_for([idx2], m4_incr(_min_argn), _max_argn, 1,
					[m4_list_add([_POSITIONALS_LIST], m4_expand([@<:@<argname-idx2>@:>@]))])])])],
		[inf], [m4_ifnblank(_INF_REPR, [m4_list_add([_POSITIONALS_LIST], _INF_REPR)], [m4_do(
			[m4_if(_min_argn, 0, ,
				[m4_for([idx2], 1, _min_argn, 1,
					[m4_list_add([_POSITIONALS_LIST], m4_expand([<argname-idx2>]))])])],
			[m4_list_add([_POSITIONALS_LIST],
				m4_expand([@<:@<argname[-]m4_incr(_min_argn)>@:>@]),
				[...],
				m4_expand([@<:@<argname[-]n>@:>@]),
				[...])])])],
	[m4_fatal([$0: Unhandled arg type: ]'_arg_type')])],
	[m4_popdef([_arg_type])],
)])


m4_define([_MAKE_USAGE_MORE], [m4_do(
	[m4_list_ifempty(_defaults, , [m4_do(
		[[ @{:@defaults for ]argname[-]m4_incr(_min_argn)],
		[m4_if(m4_list_len(_defaults), 1, ,
			[[ to ]argname[-]m4_eval(_min_argn + m4_list_len(_defaults))[ respectively]])],
		[: ],
		[m4_list_join(_defaults, [, ], ', ', [ and ])@:}@],
	)])],
)])


m4_define([_POS_ARG_HELP_USAGE], [m4_do(
	[m4_pushdef([_arg_type], m4_list_nth([_POSITIONALS_TYPES], idx))],
	[m4_case(m4_expand([_arg_type]),
		[single],
			[m4_if(_min_argn, 0, [m4_do(
				[ @{:@],
				[default: '\n"],
				[_defaults],
				[\n"'],
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
	m4_ifnblank(m4_expand([_HELP_MSG]), m4_expand([_INDENT_[echo] "_HELP_MSG"
])),
	[_INDENT_[]printf 'Usage: %s],
	[dnl If we have optionals, display them like [--opt1 arg] [--(no-)opt2] ... according to their type. @<:@ becomes square bracket at the end of processing
],
	[m4_if(HAVE_OPTIONAL, 1,
		[m4_for([idx], 1, _NARGS, 1, [m4_do(
			[ @<:@],
			[m4_case(m4_list_nth([_ARGS_TYPE], idx),
				[bool], [--(no-)]m4_list_nth([_ARGS_LONG], idx),
				[arg], [_ARG_FORMAT(idx) <arg>],
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
			[m4_pushdef([argname], <m4_expand([m4_list_nth([_POSITIONALS_NAMES], idx)])>)],
			[m4_pushdef([argname], m4_if(m4_list_nth(_POSITIONALS_TYPES, idx), [inf], [m4_default(_INF_REPR, argname)], [argname]))],
			[m4_pushdef([_min_argn], m4_expand([m4_list_nth([_POSITIONALS_MINS], idx)]))],
			[m4_pushdef([_defaults], m4_expand([m4_list_nth([_POSITIONALS_DEFAULTS], idx)]))],
			[_INDENT_[printf "\t]argname[: ]],
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
		[m4_pushdef([_VARNAME], _varname(m4_list_nth([_ARGS_LONG], idx)))],
		[_INDENT_[]printf "\t],
		[dnl Display a short one if it is not blank
],
		[m4_ifnblank(m4_list_nth([_ARGS_SHORT], idx), -m4_list_nth([_ARGS_SHORT], idx)[,])],
		[dnl Long one is never blank
],
		[--m4_list_nth([_ARGS_LONG], idx)],
		[dnl Bool have a long beginning with --no-
],
		[m4_case(m4_list_nth([_ARGS_TYPE], idx), [bool], [,--no-]m4_list_nth([_ARGS_LONG], idx))],
		[: m4_list_nth([_ARGS_HELP], idx)],
		[dnl Actions don't have defaults
],
		[dnl WAS: We format defaults help by print-quoting them with ' and stopping the help echo quotes " before the store value is subsittuted, so the message should really match the real default.
],
		[dnl Now the default is expanded since it is between double quotes
],
		[dnl TODO: We already have defaults stored in vars, so let's use $_ARG_FOO for defaults
],
		[dnl TODO: Arrays: Do something like (IFS=$','; echo "${default[*]}")
dnl [repeated], [ "$(IFS=$','; echo "${_VARNAME@<:@*@:>@}" | cat)"], or maybe not...
],
		[m4_case(m4_list_nth([_ARGS_TYPE], idx),
			[action], [],
			[bool], [ (%s by default)],
			[repeated], [ (default array: (%s) )],
			[ @{:@m4_ifnblank(m4_list_nth([_ARGS_DEFAULT], idx), [default: '%s'], [no default])@:}@])],
		[\n"],
		[m4_case(m4_list_nth([_ARGS_TYPE], idx),
			[action], [],
			[bool], [ "${_VARNAME}"],
			[repeated], [ "${_VARNAME@<:@*@:>@}"],
			[ m4_ifnblank(m4_list_nth([_ARGS_DEFAULT], idx), ["${_VARNAME}"])])],
		[
],
		[m4_popdef([_VARNAME])],
	)])])])],
	[}
],
)])


m4_define([_ADD_OPTS_VALS], [m4_do(
	[dnl If the arg comes from wrapped script/template, save it in an array
],
	[m4_ifdef([_COLLECT_$1], [_COLLECT_$1+=("$[]1"m4_if($2, 2, [ "$[]2"]))])],
)])


m4_define([_EVAL_OPTIONALS], [m4_do(
	[_INDENT_[]_key="$[]1"
],
	[m4_if(HAVE_DOUBLEDASH, 1, 
[_INDENT_()if test "$_key" = '--'
_INDENT_()then
_INDENT_(2)shift
_INDENT_(2)_positionals+=("$][@")
_INDENT_(2)break
_INDENT_()fi
])],
	[_INDENT_[]case "$_key" in],
	[dnl We don't do this if _NARGS == 0
],
	[m4_for([idx], 1, _NARGS, 1, [m4_do(
		[
_INDENT_(2,	)],
		[dnl Output short option (if we have it), then |
],
		[m4_ifblank(m4_list_nth([_ARGS_SHORT], idx), [], [-m4_list_nth([_ARGS_SHORT], idx)|])],
		[dnl If we are dealing with bool, also look for --no-...
],
		[m4_if(m4_list_nth([_ARGS_TYPE], idx), [bool], [--no-m4_list_nth([_ARGS_LONG], idx)|])],
		[dnl and then long option for the case.
],
		[--m4_list_nth([_ARGS_LONG], idx)],
		[@:}@
_INDENT_(3,		)],
		[dnl: TODO: Below is a problem with quoting
],
		[m4_pushdef([_ARGVAR], _varname(m4_list_nth([_ARGS_LONG], idx)))],
		[dnl Output the body of the case
],
		[dnl _ADD_OPTS_VALS: If the arg comes from wrapped script/template, save it in an array
],
		[m4_case(m4_list_nth([_ARGS_TYPE], idx),
			[arg], [test $[]# -lt 2 && { echo "Missing value for the optional argument '$_key'." >&2; exit 1; }]
_INDENT_(3, 		)_ARGVAR[="$[]2"
_INDENT_(3, 		)_ADD_OPTS_VALS(m4_expand([_ARGVAR]), 2)
_INDENT_(3, 		)shift],
			[repeated], [test $[]# -lt 2 && { echo "Missing value for the optional argument '$_key'." >&2; exit 1; }]
_INDENT_(3, 		)_ARGVAR[+=("$[]2")
_INDENT_(3, 		)_ADD_OPTS_VALS(m4_expand([_ARGVAR]), 2)
_INDENT_(3, 		)shift],
			[bool], _ARGVAR[="on"
_INDENT_(3, 		)_ADD_OPTS_VALS(m4_expand([_ARGVAR]))
_INDENT_(3, 		)test "$[]{1:0:5}" = "--no-" && ]_ARGVAR[="off"],
			[incr], m4_quote(_ARGVAR=$(($_ARGVAR + 1)))
_INDENT_(3, 		)_ADD_OPTS_VALS(m4_expand([_ARGVAR])),
			[action], [m4_list_nth([_ARGS_DEFAULT], idx)
_INDENT_(3, 		)exit 0],
		)],
		[
_INDENT_(3, 		);;],
		[m4_popdef([_ARGVAR])],
	)])],
	[m4_if(HAVE_POSITIONAL, 1,
		[m4_expand([_EVAL_POSITIONALS_CASE])],
		[m4_expand([_EXCEPT_OPTIONALS_CASE])])],
	[
_INDENT_()[esac]],
)])


dnl Store positional args inside a 'case' statement (that is inside a 'for' statement)
m4_define([_EVAL_POSITIONALS_CASE], [m4_do(
	[
_INDENT_(2,	)],
	[*@:}@
_INDENT_(3, 		)],
	[_positionals+=("$[]1")
],
_INDENT_(3, 		)[;;],
)])


dnl If we expect only optional arguments and we get an intruder, fail noisily.
m4_define([_EXCEPT_OPTIONALS_CASE], [m4_do(
	[
_INDENT_(2,	)],
	[*@:}@
_INDENT_(3, 		)],
	[{ (echo "FATAL ERROR: Got an unexpected argument '$[]1'"; print_help) >&2; exit 1; }
_INDENT_(3, 		)],
_INDENT_(3, 		)[;;],
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
	[dnl We assume that we have either optional args (with possibility of positionals), or that we have only positional args.
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
dnl TODO: We need to handle inf number of args here
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
		[[ && { ( echo "FATAL ERROR: Not enough positional arguments --- we require ]_NARGS_SPEC[, but got only ${#_positionals[@]}."; print_help ) >&2; exit 1; }
]],
		[IF_POSITIONALS_INF(
			[m4_do(
				[dnl If we allow up to infinitely many args, we prepare the array for it.
],
				[_OUR_ARGS=$((${#_positionals@<:@@@:>@} - ${#_positional_names@<:@@@:>@}))
],
				[for (( ii = 0; ii < $_OUR_ARGS; ii++))
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
				[[ && { ( echo "FATAL ERROR: There were spurious positional arguments --- we expect ]],
				[_NARGS_SPEC],
				[dnl The last element of _positionals (even) for bash < 4.3 according to http://unix.stackexchange.com/a/198790
],
				[[, but got ${#_positionals[@]} (the last one was: '${_positionals[*]: -1}')."; print_help ) >&2; exit 1; }
]],
			)])],
		[m4_popdef([_NARGS_SPEC])],
		[[for (( ii = 0; ii < ${#_positionals[@]}; ii++))
do
]_INDENT_()[eval "${_positional_names[$ii]}=\"${_positionals[$ii]}\"" || { echo "Error during argument parsing, possibly an Argbash bug." >&2; exit 1; }
done]],
		[
],
		[m4_list_ifempty([_WRAPPED_ADD_SINGLE], [], [m4_set_foreach([_POS_VARNAMES], [varname], [varname=@{:@@:}@
])])],
		[m4_join([
], m4_unquote(m4_list_contents([_WRAPPED_ADD_SINGLE])))],
	)])],
)])


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


m4_define([_MAKE_DEFAULTS_POSITIONALS_LOOP], [m4_do(
	[m4_pushdef([_DEFAULT], m4_list_nth([_POSITIONALS_DEFAULTS], idx))],
	[m4_ifnblank(m4_quote(_DEFAULT), [m4_do(
		[_varname(m4_list_nth([_POSITIONALS_NAMES], idx))=],
		[m4_case(m4_list_nth([_POSITIONALS_TYPES], idx),
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
		[# THE DEFAULTS INITIALIZATION --- POSITIONALS
],
		[m4_for([idx], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [_MAKE_DEFAULTS_POSITIONALS_LOOP])],
	)])],
	[m4_if(HAVE_OPTIONAL, 1, [m4_do(
		[# THE DEFAULTS INITIALIZATION --- OPTIONALS
],
		[m4_for([idx], 1, _NARGS, 1, [m4_do(
			[m4_pushdef([_ARGVAR], _varname(m4_list_nth([_ARGS_LONG], idx)))],
			[m4_case(m4_list_nth([_ARGS_TYPE], idx),
				[action], [],
				m4_expand([_ARGVAR=m4_list_nth([_ARGS_DEFAULT], idx)
]))],
			[m4_popdef([_ARGVAR])],
		)])],
	)])],
)])


m4_define([_MAKE_OTHER], [m4_do(
	[[# OTHER STUFF GENERATED BY Argbash
]],
	dnl Put the stuff below into some condition block
,	[m4_set_foreach([_ARGS_GROUPS], [agroup], [agroup=@{:@"${agroup[_OPT]@<:@@@:>@}" "${agroup[_POS]@<:@@@:>@}"@:}@
])],
	[],
	[m4_list_declare([_OTHER])],
	[_OTHER_FOREACH([item
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


dnl $1: The macro call (the caller is supposed to pass [$0($@)])
m4_define([ARGBASH_GO_BASE], [m4_do(
	[[$1
]],
	[m4_if(m4_cmp(0, m4_list_len([_POSITIONALS_MINS])), 1,
		m4_define([_POSITIONALS_MIN], [m4_list_sum(_POSITIONALS_MINS)]))],
	[[# needed because of Argbash --> m4_ignore@{:@@<:@
### START OF CODE GENERATED BY ARGBASH v]_ARGBASH_VERSION[ one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, know your rights: https://github.com/matejak/argbash

]],
	[m4_if(_NO_ARGS_WHATSOEVER, 1, [], [m4_do(
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


dnl $1: Stem of file are we wrapping. We expect macro _SCRIPT_$1 to be defined and to contain the full filefilename
dnl $2: Names of blacklisted args (list)
dnl $3: Codes of blacklisted args (string, default is HV for help + version)
dnl IDEA: Include the wrapped script and read the argbash stuff
dnl However, define some macros beforehand that will act as global variables and ensure the following:
dnl  - the defns from wrapped script won't be repeated in the wrapper (DONE, using m4_ignore, TODO: Remove ifdef WRAPPED that is used somewhere)
dnl  - options blacklisted by name won't appear (e.g. 'outfile', 'do-this', ...)
dnl  - blacklisted classes of options won't appear (e.g. help, version)
m4_define([ARGBASH_WRAP], [m4_do(
	[[$0($@)]],
	[m4_pushdef([WRAPPED], [[$1]])],
	[m4_list_add([BLACKLIST], $2)],
	[m4_pushdef([FLAGS], [m4_default([$3], [HV])])],
	[m4_ifndef([_SCRIPT_$1], [m4_fatal([The calling script was supposed to find location of the file with stem '$1' and define it as a macro, but the latter didn't happen.])])],
	[m4_ignore(m4_include(m4_indir([_SCRIPT_$1])))],
	[m4_popdef([FLAGS])],
	[m4_list_destroy([BLACKLIST])],
	[m4_popdef([WRAPPED])],
)])


m4_define([ARG_LEFTOVERS],
	[m4_ifblank(m4_list_contains([BLACKLIST], [leftovers]), [[$0($@)]_ARG_POSITIONAL_INF([leftovers], [$1], [0], [... ])])])

dnl If I am wrapped:
dnl defns are applied, but not recorded
dnl some are not even recorded
dnl It may be that the wrapped script contains args that we already have.
dnl In this case: Raise an error (with a good advice)
dnl

dnl Positional args wrapped:
dnl - we keep a list POS_WRAPPED, where we store names of positional args that we want record.
dnl - OR: When we encounter a wrapped positional arg, we store a code block <ARGS_ARRAY>+=pos_arg
dnl   - and at the end, we just expand this block after pos_arg vars are filled.
dnl - after positional args are assigned, we go through this list and append to the array of passed wrapped args
dnl
dnl TODO: Implement leftover args
