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
dnl TODO: Improve help generation - make it docopt-compiant + use printf's %s to print them default values. Currently, having | in default value breaks Argbash. Yes, args with arrays as values will have to be handled differently.
dnl
dnl vvvvvvvvvvvvvvv
dnl TODO: Optimize the _CHECK_PASSED_VALUE_AGAINST_BLACKLIST calls
dnl TODO: Support custom error messages
dnl TODO: Make positional args check optional - make it a function(n_positionals, n_expected, what is expected, msg[when less args], [msg when more args])
dnl TODO: Introduce alternative REPEATED/INCREMENTAL version of macros (add and replace mode with respect to defaults)
dnl TODO: Fix docopt and completion for cases when there is only the '=' separator.
dnl TODO: Enable (at least) docopt generation even if we don't know the basename.
dnl TODO: Make the m4_lists_foreach_optional etc. accept second batch of lists.
dnl
dnl WIP vvvvvvvvvvvvvvv
dnl
dnl TODO: Unify the _COMMENT, _COMMENTED_BLOCK etc. macros.
dnl TODO: Evaluate need for _HANDLE_OCCURENCE_OF_DOUBLEDASH_ARG_POSIX
dnl TODO: Ensure that we don't check for max pos args if we accept up to infinity args (test)
dnl TODO: Don't generate and/or call functions if we don't check for counts. (test DIY)
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


dnl We include the version-defining macro
m4_define([_ARGBASH_VERSION], m4_default_quoted(m4_normalize(m4_sinclude([version])), [unknown]))


m4_define([_DISTINCT_OPTIONAL_ARGS_COUNT], 0)
dnl How many values of positional arguments is the generated script required to receive when called.
m4_define([_MINIMAL_POSITIONAL_VALUES_COUNT], 0)
dnl Greatest number of positional args the script can accept (infinite number of args is handled in parallel)
m4_define([_HIGHEST_POSITIONAL_VALUES_COUNT], 0)
dnl We expect infinitely many args (keep in mind that we still need _HIGHEST_POSITIONAL_VALUES_COUNT)
m4_define([_POSITIONALS_INF], 0)

dnl btw no double dash if there are no positional arguments.
m4_define([_IF_HAVE_DOUBLEDASH], [m4_if(
	m4_quote(HAVE_DOUBLEDASH), 1, [_IF_HAVE_POSITIONAL_ARGS([$1], [$2])],
	[$2])])

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
		m4_expand([[. "$]m4_default_quoted([$2], _DEFAULT_SCRIPTDIR)[/$1]"  [# '.' means 'source'
]]))],
)])


dnl
dnl $1: Name of the holding variable
dnl Taken from: http://stackoverflow.com/a/246128/592892
argbash_api([DEFINE_SCRIPT_DIR], [m4_do(
	[[$0($@)]],
	[dnl Taken from: http://stackoverflow.com/a/246128/592892
],
	[_DEFINE_SCRIPT_DIR([$1], [cd "$(dirname "${BASH_SOURCE[0]}")" && pwd])],
)])


dnl
dnl Does the same as DEFINE_SCRIPT_DIR, but uses 'readlink -e' to follow symlinks.
dnl Works only on GNU systems.
dnl
dnl $1: Name of the holding variable
dnl Taken from: http://stackoverflow.com/a/246128/592892
argbash_api([DEFINE_SCRIPT_DIR_GNU], [m4_do(
	[[$0($@)]],
	[dnl Taken from: http://stackoverflow.com/a/246128/592892
],
	[_DEFINE_SCRIPT_DIR([$1], [cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd])],
)])


dnl
dnl $1: Name of the holding variable
dnl $2: Command to find the script dir
m4_define([_DEFINE_SCRIPT_DIR], [m4_do(
	[m4_define([SCRIPT_DIR_DEFINED])],
	[m4_pushdef([_sciptdir], m4_ifnblank([$1], [[$1]], _DEFAULT_SCRIPTDIR))],
	[m4_list_append([_OTHER],
		m4_quote(_sciptdir[="$($2)" || die "Couldn't determine the script's running directory, which probably matters, bailing out" 2]))],
	[m4_popdef([_sciptdir])],
)])


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
			[m4_if([$3], 0, [[ @{:@default: '$4'@:}@]])],
		[more], [_FORMAT_DEFAULTS_FOR_MULTIVALUED_ARGUMENTS([$1], [$2], [$3], [$4])],
		[inf], [_FORMAT_DEFAULTS_FOR_MULTIVALUED_ARGUMENTS([$1], [$2], [$3], [$4])],
	[m4_fatal([$0: Unhandled arg type: '$2'])])],
)])


dnl
dnl $1: _argname
dnl $2: short arg
dnl $3: value string (optional, empty by default)
dnl $4: short-long separator (optional, | by default)
dnl
dnl Returns either --long or -l|--long if there is that -l.
dnl If you supply a value, it will be included after both long and short option like
dnl --width <int> or -w <int>|--width <int>. The delimiter is respected.
m4_define([_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS], [m4_do(
	[m4_ifnblank([$2],
		[[-$2]m4_ifnblank([$3], [[ $3]])m4_default_quoted([$4], [|])])],
	[[--$1]m4_ifnblank([$3], [_DELIM_IN_HELP[$3]])],
)])


dnl
dnl $1: _argname
dnl $2: short arg
dnl $3: value string (optional, empty by default)
dnl $4: short-long separator (optional, | by default)
dnl
dnl Returns either --long or -l|--long if there is that -l.
dnl If you supply a value, it will be included after both long and short option like
dnl --width <int> or -w <int>|--width <int>. The delimiter is respected.
m4_define([_FORMAT_OPTIONAL_ARGUMENT_FOR_POSIX_HELP_SYNOPSIS], [m4_do(
	[m4_ifblank([$2], [m4_fatal([Argument '$1': Blank short option!])],
		[[-$2]m4_ifnblank([$3], [[ $3]])])],
)])


dnl
dnl $1: Formatter of opt arg synopsis FORMATTER(_argname,_arg_short,value string,short-long separator)
m4_define([_SYNOPSIS_OF_OPTIONAL_ARGS], [m4_lists_foreach_optional([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH], [_argname,_arg_short,_arg_type], [m4_do(
	[ @<:@],
	[m4_case(_arg_type,
		[bool], [$1([(no-)]_argname, _arg_short)],
		[arg], [$1(_argname, _arg_short)[]_DELIM_IN_HELP[<]_GET_VALUE_STR(_argname)>],
		[repeated], [$1(_argname, _arg_short)[]_DELIM_IN_HELP[<]_GET_VALUE_STR(_argname)>],
		[$1(_argname, _arg_short)])],
	[@:>@],
)])])


m4_define([_SYNOPSIS_OF_POSITIONAL_ARGS], [m4_do(
	[m4_lists_foreach_positional([_ARGS_LONG,_POSITIONALS_MINS,_POSITIONALS_MAXES,_ARGS_CATH], [argname,_min_argn,_max_argn,_arg_type],
		[_POS_ARG_HELP_LINE(argname, _arg_type, _min_argn, _max_argn)])],
	[ m4_expand(m4_join([ ], m4_list_contents([_POSITIONALS_LIST])))],
)])


dnl
dnl $1: Formatter of opt arg synopsis, see _SYNOPSIS_OF_OPTIONAL_ARGS
m4_define([_MAKE_HELP_SYNOPSIS], [m4_do(
	[_IF_HAVE_OPTIONAL_ARGS([_SYNOPSIS_OF_OPTIONAL_ARGS([$1])])],
	[_IF_HAVE_DOUBLEDASH([[ [--]]])],
	[dnl If we have positionals, display them like <pos1> <pos2> ...
],
	[_IF_HAVE_POSITIONAL_ARGS([_SYNOPSIS_OF_POSITIONAL_ARGS])],
)])


dnl
dnl $1: Argname
dnl $2: Prelude
m4_define([GET_SET_ARG_HELP_MESSAGE],
	[[$2]m4_list_join(LIST_OF_VALUES_OF_ARGNAME([$1]), [, ], ', ', [ and ])])


m4_define([_MAKE_HELP_FUNCTION_POSITIONAL_PART], [m4_lists_foreach_positional(
	[_ARGS_LONG,_ARGS_CATH,_POSITIONALS_MINS,_POSITIONALS_DEFAULTS,_ARGS_HELP],
	[argname0,_arg_type,_min_argn,_defaults,_msg], [m4_ifnblank(_msg, [m4_do(
	[dnl We would like something else for argname if the arg type is 'inf' and _INF_VARNAME is not empty
],
	[m4_pushdef([argname1], <m4_dquote(argname0)[[]m4_ifnblank(m4_quote($][1), m4_quote(-$][1))]>)],
	[m4_pushdef([argname], m4_if(_arg_type, [inf], [m4_default(_INF_REPR, argname1)], [[argname1($][@)]]))],
	[_IF_ARG_IS_OF_SET_TYPE(argname0, [m4_define([_msg], m4_dquote(_msg[]GET_SET_ARG_HELP_MESSAGE(argname0, [. Can be one of: ])))])],
	[_INDENT_()[printf '\t%s\n' "]argname[: ]_SUBSTITUTE_LF_FOR_NEWLINE_WITH_DISPLAY_INDENT_AND_ESCAPE_DOUBLEQUOTES(_msg)],
	[_POS_ARG_HELP_DEFAULTS([argname], _arg_type, _min_argn, _defaults)],
	["_ENDL_()],
	[m4_popdef([argname])],
	[m4_popdef([argname1])],
)])])])


dnl
dnl $1: argname
dnl $2: short
dnl $3: type
dnl $4: default
dnl $5: help msg
dnl $6: Option formatter: FORMATTER(argname, short, type)
m4_define([_MAKE_PRINTF_OPTARG_HELP_STATEMENTS], [m4_do(
	[m4_pushdef([_type_spec],
		[m4_expand([m4_case(_GET_VALUE_TYPE([$1]),
			[generic], [],
			[string], [],
			[_GET_VALUE_DESC([$1])])])])],
	[m4_pushdef([_options], [$6([$1], [$2], [$3])])],
	[m4_pushdef([_help_msg], [_SUBSTITUTE_LF_FOR_NEWLINE_WITH_DISPLAY_INDENT_AND_ESCAPE_DOUBLEQUOTES([$5])])],
	[_IF_ARG_IS_OF_SET_TYPE([$1], [m4_pushdef([_help_msg], m4_quote(_help_msg[]GET_SET_ARG_HELP_MESSAGE([$1], [. Can be one of: ])))])],
	[m4_case([$3],
		[action],
		[_INDENT_()[printf '\t%s\n'] "_options: _help_msg"],
		[incr],
		[_INDENT_()[printf '\t%s\n'] "_options: _help_msg"],
		[bool],
		[_INDENT_()[printf '\t%s\n'] "_options: _help_msg[ ($4 by default)]"],
		[repeated], [m4_ifblank([$4],
			[_INDENT_()[printf '\t%s\n'] "_options: _help_msg[ (empty by default)]"],
			[_INDENT_()[printf '\t%s'] "_options: _help_msg[ @{:@default array elements:]"
_INDENT_()[printf " '%s'" $4]
_INDENT_()[printf '@:}@\n']])],
		[_INDENT_()[printf '\t%s\n'] "_options: _help_msg[]m4_ifblank(_default, [[ (no default)]], [ ([default: ]'_default')])"])],
	[_IF_ARG_IS_OF_SET_TYPE([$1], [m4_popdef([_help_msg])])],
	[m4_popdef([_help_msg])],
	[m4_popdef([_options])],
	[m4_popdef([_type_spec])],
)])


dnl
dnl Option formatter supporting long options
dnl $1: argname
dnl $2: short
dnl $3: type
m4_define([_GNU_HELP_OPTION_COMPOSER], [m4_do(
	[m4_ifnblank([$2], [[-$2, ]])],
	[[--$1]],
	[m4_case([$3], [bool], [[, --no-$1]])],
)])


dnl
dnl Option formatter supporting only short options
dnl $1: argname
dnl $2: short
dnl $3: type
m4_define([_POSIX_HELP_OPTION_COMPOSER], [m4_do(
	[m4_ifblank([$2], [m4_fatal([Argument '$1': Blank short option!])], [[-$2]])],
)])


dnl $1: Option formatter (see _MAKE_PRINTF_OPTARG_HELP_STATEMENTS): FORMATTER(argname, short, type)
m4_define([_MAKE_HELP_FUNCTION_OPTIONAL_PART], [m4_lists_foreach_optional(
	[_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH,_ARGS_DEFAULT,_ARGS_HELP],
	[_argname,_arg_short,_arg_type,_default,_arg_help],
	[m4_ifnblank(_arg_help, [_MAKE_PRINTF_OPTARG_HELP_STATEMENTS(_argname, _arg_short, _arg_type, _default, _arg_help, [$1])]
)])])


dnl
dnl $1: list name
dnl $2: name
dnl $3: default
dnl $4: help
m4_define([_MAKE_ENV_HELP_MESSAGE], [m4_do(
	[m4_ifnblank([$4], [m4_list_append([$1], m4_do(
		[[$2: $4.]],
		[m4_ifnblank([$3], [[ (default: '$3')]])],
	))])],
)])


dnl
dnl $1: The name of list for help messages
m4_define([_MAKE_ENV_HELP_MESSAGES], [m4_do(
	[m4_lists_foreach([ENV_NAMES,ENV_DEFAULTS,ENV_HELPS], [_name,_default,_help], 
		[_MAKE_ENV_HELP_MESSAGE([$1], _name, _default, _help)])],
)])


m4_define([_MAKE_HELP_FUNCTION_ENVVARS_PART], [m4_do(
	[_MAKE_ENV_HELP_MESSAGES([LIST_ENV_HELP])],
	[_INDENT_()printf '\nEnvironment variables that are supported:\n'
],
	[m4_list_foreach([LIST_ENV_HELP], [_msg], [_INDENT_()printf '\t%s\n' "[]_msg"
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


dnl
dnl $1: Synopsis option formatter (see _MAKE_HELP_SYNOPSIS)
dnl $2: List option formatter (see _MAKE_HELP_FUNCTION_OPTIONAL_PART)
m4_define([_MAKE_HELP], [MAKE_FUNCTION(
	[[Function that prints general usage of the script.],
		[This is useful if users asks for it, or if there is an argument parsing error (unexpected / spurious arguments)],
		[and it makes sense to remind the user how the script is supposed to be called.]],
	[print_help], [m4_do(
		[m4_ifnblank(m4_expand([_HELP_MSG]),
			m4_dquote(_INDENT_()[printf] '%s\n' "SUBSTITUTE_LF_FOR_NEWLINE_WITH_INDENT_AND_ESCAPE_DOUBLEQUOTES(_HELP_MSG, [])"_ENDL_()))],
		[_INDENT_()[]printf 'Usage: %s],
		[dnl If we have optionals, display them like [--opt1 arg] [--(no-)opt2] ... according to their type. @<:@ becomes square bracket at the end of processing
],
		[_MAKE_HELP_SYNOPSIS([$1])],
		[\n' "@S|@0"_ENDL_()],
		[_IF_HAVE_POSITIONAL_ARGS([_MAKE_HELP_FUNCTION_POSITIONAL_PART])],
		[dnl If we have 0 optional args, don't do anything (FOR loop would assert, 0 < 1)
],
		[dnl Plus, don't display extended help for an arg if it doesn't have a description
],
		[m4_if(_DISTINCT_OPTIONAL_ARGS_COUNT, 0, , [_MAKE_HELP_FUNCTION_OPTIONAL_PART([$2])])],
		[dnl Print a more verbose help message to the end of the help (if requested)
],
		[m4_list_ifempty([ENV_NAMES], ,[_MAKE_HELP_FUNCTION_ENVVARS_PART()_ENDL_()])],
		[_MAKE_ARGS_STACKING_HELP_PRINT_IF_NEEDED],
		[m4_ifnblank(m4_quote(_HELP_MSG_EX),
			m4_dquote(_INDENT_()[printf] '\n%s\n' "SUBSTITUTE_LF_FOR_NEWLINE_WITH_INDENT_AND_ESCAPE_DOUBLEQUOTES(_HELP_MSG_EX, [])"_ENDL_()))],
	)],
)])


dnl
dnl $1: Arg name
dnl $2: Short arg name (not used here)
dnl $3: Name of the value-to-variable macro
dnl $4: The name of the argument-holding variable
dnl $5: Where to get the last value (optional)
m4_define([_VAL_OPT_ADD_SPACE_WITHOUT_GETOPT_OR_SHORT_OPT], [_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
	[test $[]# -lt 2 && die "Missing value for the optional argument '$_key'." 1],
	[$3([$1], ["@S|@2"], [$4])],
	[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE([$4], [m4_default_quoted([$5], [@S|@2])])],
	[shift],
)])


dnl
dnl $1: Arg name
dnl $2: Short arg name (not used here)
dnl $3: Name of the value-to-variable macro
dnl $4: The name of the argument-holding variable
dnl $5: Where to get the last value (optional)
m4_define([_VAL_OPT_ADD_GETOPTS], [_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
	[test "x$OPTARG" = x && die "Missing value for the optional argument '-$_key'." 1],
	[$3([$1], ["$OPTARG"], [$4])],
	[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE([$4], [m4_default_quoted([$5], [$OPTARG])])],
)])


dnl
dnl $1: Arg name
dnl $2: Action - the variable containing the value to assign is '_val'
dnl $3: Name of the value-to-variable macro
dnl $4: The name of the argument-holding variable
dnl $5: Where to get the last value (optional)
m4_define([_VAL_OPT_ADD_EQUALS_WITH_LONG_OPT], [_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
	[$3([$1], ["${_key##--$1=}"], [$4])],
	[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS([$4])],
)])


dnl
dnl $1: Arg name
dnl $2: Short arg name
dnl $3: Name of the value-to-variable macro
dnl $4: The name of the argument-holding variable
dnl $5: Where to get the last value (optional)
m4_define([_VAL_OPT_ADD_ONLY_WITH_SHORT_OPT_GETOPT], [_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
	[$3([$1], ["${_key##-$2}"], [$4])],
	[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_GETOPT([$4])],
)])


dnl
dnl $1: The name of the option arg
dnl $2: What to do if wrapping
dnl $2: What to do if not wrapping
m4_define([_IF_WRAPPING_OPTION], [m4_ifdef([_COLLECT_$1], [$2], [$3])])


dnl
dnl $1: The name of the option arg
dnl $2: The value of the option arg
dnl Uses:
dnl _key - the run-time shell variable
dnl _key - the run-time shell variable
m4_define([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS_OR_BOTH], [m4_do(
	[_IF_WRAPPING_OPTION([$1], [_COLLECT_$1+=("${_key%%=*}"m4_ifnblank([$2], [ "$2"]))])],
)])


dnl see _APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS_OR_BOTH for docs
m4_define([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE], [m4_do(
	[_IF_WRAPPING_OPTION([$1], [_COLLECT_$1+=("${_key}"m4_ifnblank([$2], [ "$2"]))])],
)])


dnl see _APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS_OR_BOTH for docs
m4_define([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_GETOPT], [m4_do(
	[_IF_WRAPPING_OPTION([$1], [_COLLECT_$1+=("$_key")])],
)])


dnl see _APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS_OR_BOTH for docs
m4_define([_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_EQUALS], [m4_do(
	[_IF_WRAPPING_OPTION([$1], [_COLLECT_$1+=("$_key")])],
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
			[m4_define([_DELIMITER], [[BOTH]])],
			[dnl We won't try to show that = and ' ' are possible in the help message
],
			[m4_define([_DELIM_IN_HELP], [ ])],
		)], [m4_do(
			[dnl SPACE only
],
			[m4_define([_IF_SPACE_IS_A_DELIMITER], m4_quote($[]1))],
			[m4_define([_IF_EQUALS_IS_A_DELIMITER], m4_quote($[]2))],
			[m4_define([_DELIMITER], [[SPACE]])],
			[m4_define([_DELIM_IN_HELP], [ ])],
		)])],
		[m4_bmatch([$1], [=], [m4_do(
			[dnl EQUALS only
],
			[m4_define([_IF_SPACE_IS_A_DELIMITER], m4_quote($[]2))],
			[m4_define([_IF_EQUALS_IS_A_DELIMITER], m4_quote($[]1))],
			[m4_define([_DELIMITER], [[EQUALS]])],
			[m4_define([_DELIM_IN_HELP], [=])],
		)], [m4_fatal([We expect at least '=' or ' ' in the expression. Got: '$1'.])])])])


dnl
dnl Sets the option--value separator (i.e. --option=val or --option val)
dnl $1: The directive (' ', '=', or ' =' or '= ')
argbash_api([ARGBASH_SET_DELIM], _CHECK_PASSED_ARGS_COUNT(1, 1)[m4_do(
	[_IF_W_FLAGS_DONT_CONTAIN([S], [[$0($@)]_SET_OPTION_VALUE_DELIMITER([$1])])],
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
		[repeated], [_VAL_OPT_ADD_SPACE_WITHOUT_GETOPT_OR_SHORT_OPT([$1], [$2], [_APPEND_VALUE_TO_ARRAY], [$5], [${$5[-1]}])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [${$5[-1]}])],
		[bool],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5="on"]],
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE([$5])],
			[[test "${1:0:5}" = "--no-" && $5="off"]],
		)],
		[incr],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5=$(($5 + 1))]],
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE([$5])],
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
dnl TODO: We have to restrict case match for long options only if those long opts accept value.
dnl We always match for --help - even if delim is = only.
dnl And we also match for --no-that
dnl And for -h*, since this is an action and argbash then ends (but maybe not, what if one has passed -hx, while -x is invalid?)
m4_define([_MAKE_OPTARG_GETOPTS_CASE_SECTION], [m4_do(
	[_INDENT_AND_END_CASE_MATCH([[$2]])],
	[m4_case([$3],
		[arg], [_VAL_OPT_ADD_GETOPTS([$1], [$2], [_ASSIGN_VALUE_TO_VAR], [$5])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [$$5])],
		[repeated], [m4_fatal([Repeated arguments are not supported in the POSIX mode])],
		[bool],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5="on"]],
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE([$5])],
		)],
		[incr],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5=$(($5 + 1))]],
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE([$5])],
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


dnl
dnl $1: Argname
dnl $2: Short option
dnl $3: Argument type
dnl $4: Argument default
dnl $5: Value-holding variable name
m4_define([_MAKE_OPTARG_LONGOPT_EQUALS_CASE_SECTION], [m4_do(
	[_INDENT_AND_END_CASE_MATCH(
		[[--$1=*]])],
	[m4_case([$3],
		[arg], [_VAL_OPT_ADD_EQUALS_WITH_LONG_OPT([$1], [], [_ASSIGN_VALUE_TO_VAR], [$5])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [$$5])],
		[repeated], [_VAL_OPT_ADD_EQUALS_WITH_LONG_OPT([$1], [], [_APPEND_VALUE_TO_ARRAY], [$5], [${$5[-1]}])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [${$5[-1]}])],
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
		[repeated], [_VAL_OPT_ADD_ONLY_WITH_SHORT_OPT_GETOPT([$1], [$2], [_APPEND_VALUE_TO_ARRAY], [$5], [${$5[-1]}])_CHECK_PASSED_VALUE_AGAINST_BLACKLIST([$_key], [${$5[-1]}])],
		[bool],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5="on"]],
			_PASS_WHEN_GETOPT([$2]),
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE([$5])],
		)],
		[incr],
		[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
			[[$5=$(($5 + 1))]],
			_PASS_WHEN_GETOPT([$2]),
			[_APPEND_WRAPPED_ARGUMENT_TO_ARRAY_SPACE([$5])],
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


dnl
dnl $1: Argname
dnl $2: Short option
dnl $3: Argument type
dnl $4: Argument default
dnl $5: Value-holding variable name
m4_define([_MAKE_OPTARG_CASE_SECTIONS], [m4_do(
	[_MAKE_OPTARG_SIMPLE_CASE_SECTION_IF_IT_MAKES_SENSE($@)],
	[_MAKE_OPTARG_LONGOPT_EQUALS_CASE_SECTION_IF_IT_MAKES_SENSE($@)],
	[_MAKE_OPTARG_GETOPT_CASE_SECTION_IF_IT_MAKES_SENSE($@)],
)])


m4_define([_HANDLE_OCCURENCE_OF_DOUBLEDASH_ARG], [m4_do(
	[_COMM_BLOCK(_INDENT_LEVEL_IN_ARGV_WHILE,
		[# If two dashes (i.e. '--') were passed on the command-line,],
		[# assign the rest of arguments as positional arguments and bail out.],
	)],
	[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_WHILE,
		[if test "$_key" = '--'],
		[then],
		_INDENT_MORE(
			[shift],
			_IF_COMMENTED_OUTPUT([# Handle the case when the double dash is the last argument.]),
			[test @S|@# -gt 0 || break],
			[_positionals+=("@S|@@")],
			[_positionals_count=$((_positionals_count + @S|@#))],
			[shift $((@S|@# - 1))],
			[_last_positional="@S|@1"],
			[break]),
		[fi])],
)])


m4_define([_HANDLE_OCCURENCE_OF_DOUBLEDASH_ARG_POSIX], [m4_do(
	[_COMM_BLOCK(_INDENT_LEVEL_IN_ARGV_WHILE,
		[# If two dashes (i.e. '--') were passed on the command-line,],
		[# mark the first positional argument the one right after this one.],
	)],
	[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_WHILE,
		[if test "$_key" = '--'],
		[then],
		_INDENT_MORE(
			[_positionals_index=$((_positionals_index + 1))],
			[shift $((@S|@# - 1))],
			[_last_positional="@S|@1"],
			[break]),
		[fi])],
)])


m4_define([_EVAL_OPTIONALS_AND_POSITIONALS], [m4_do(
	[m4_n([_INDENT_(2)_key="$[]1"])],
	[_IF_HAVE_DOUBLEDASH([_HANDLE_OCCURENCE_OF_DOUBLEDASH_ARG])],
	[_MAKE_CASE_STATEMENT()],
)])


m4_define([_EVAL_OPTIONALS_AND_POSITIONALS_POSIX], [m4_do(
	[m4_n([_INDENT_(2)_key="$[]1"])],
	[_IF_HAVE_DOUBLEDASH([_HANDLE_OCCURENCE_OF_DOUBLEDASH_ARG_POSIX])],
	[_MAKE_CASE_STATEMENT()],
	[m4_n([_INDENT_(2)_positionals_index=$((_positionals_index + 1))])],
)])


m4_define([_MAKE_CASE_STATEMENT], [m4_do(
	[_INDENT_(2)[case "$_key" in
]],
	[m4_lists_foreach_optional([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH,_ARGS_DEFAULT,_ARGS_VARNAME], [_argname,_arg_short,_arg_type,_default,_arg_varname],
		[_MAKE_OPTARG_CASE_SECTIONS(_argname, _arg_short, _arg_type, _default, _arg_varname)])],
	[_HANDLE_NON_OPTION_MATCH],
	[_INDENT_(2)[esac
]],
)])


m4_define([_EVAL_OPTIONALS_GETOPTS], [m4_do(
	[_MAKE_POSIX_CASE_STATEMENT],
)])


m4_define([_MAKE_POSIX_CASE_STATEMENT], [m4_do(
	[_INDENT_(2)[case "$_key" in
]],
	[m4_lists_foreach_optional([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH,_ARGS_DEFAULT,_ARGS_VARNAME], [_argname,_arg_short,_arg_type,_default,_arg_varname],
		[_MAKE_OPTARG_GETOPTS_CASE_SECTION(_argname, _arg_short, _arg_type, _default, _arg_varname)])],
	[_HANDLE_NON_OPTION_MATCH_POSIX],
	[_INDENT_(2)[esac
]],
)])


m4_define([_HANDLE_NON_OPTION_MATCH], [m4_do(
	[_INDENT_(_INDENT_LEVEL_IN_ARGV_CASE)],
	[*@:}@
],
	[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
		_IF_HAVE_POSITIONAL_ARGS(
			[_STORE_CURRENT_ARG_AS_POSITIONAL_BODY],
			[[_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$[]1'" 1]]),
		[;;],
	)],
)])


m4_define([_HANDLE_NON_OPTION_MATCH_POSIX], [m4_do(
	[_INDENT_(_INDENT_LEVEL_IN_ARGV_CASE)],
	[*@:}@
],
	[_COMM_BLOCK(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
		[# This is clearly an error, getopts get here iff an option has been detected,],
		[# which is not the case.],
		[# In any case, raise an error here.],
	)],
	[_JOIN_INDENTED(_INDENT_LEVEL_IN_ARGV_CASE_BODY,
		[[_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected option '-${_key}'" 1]],
		[;;],
	)],
)])


m4_define([_STORE_CURRENT_ARG_AS_POSITIONAL_BODY],
	[[_last_positional="@S|@1"],
	[_positionals+=("$_last_positional")],
	[_positionals_count=$((_positionals_count + 1))]])


m4_define([_STORE_CURRENT_ARG_AS_POSITIONAL], [_JOIN_INDENTED(2,
	_STORE_CURRENT_ARG_AS_POSITIONAL_BODY)])


m4_define([_MAKE_LIST_OF_POSITIONAL_ASSIGNMENT_TARGETS], [m4_do(
	[m4_pushdef([_indentation_level], 1)],
	[_COMM_BLOCK(_indentation_level,
		[# We have an array of variables to which we want to save positional args values.],
		[# This array is able to hold array elements as targets.],
		[# As variables don't contain spaces, they may be held in space-separated string.],
	)],
	[_INDENT_(_indentation_level)[_positional_names="]],
	[m4_define([_pos_names_count], 0)],
	[m4_lists_foreach_positional([_ARGS_LONG,_POSITIONALS_MAXES], [_pos_name,_max_argn], [m4_do(
		[dnl If we accept inf args, it may be that _max_argn == 0 although we HAVE_POSITIONAL, so we really need the check.
],
		[m4_if(_max_argn, 0, , [m4_do(
			[m4_for([_arg_index], 1, _max_argn, 1, [m4_do(
				[_varname(_pos_name)],
				[dnl If we handle a multi-value arg, we assign to an array => we add '[_arg_index - 1]' (i.e. zero-based argument index) to LHS.
],
				[m4_if(_max_argn, 1, , [@<:@m4_eval(_arg_index - 1)@:>@])],
				[ ],
				[m4_define([_pos_names_count], m4_incr(_pos_names_count))],
			)])],
		)])],
	)])],
	["_ENDL_],
	[IF_POSITIONALS_INF([m4_do(
		[_COMM_BLOCK(_indentation_level,
			[# If we allow up to infinitely many args, we calculate how many of values],
			[# were actually passed, and we extend the target array accordingly.],
			[# We also know that we have _pos_names_count known positional arguments.],
		)],
		[_JOIN_INDENTED(_indentation_level,
			[_our_args=$(([${#_positionals[@]} - ]_pos_names_count))],
			[[for ((ii = 0; ii < _our_args; ii++))]],
			[do],
			[_INDENT_()_positional_names="$_positional_names _INF_VARNAME@<:@$((ii + _INF_ARGN))@:>@"],
			[done],
		)],
	)])],
	[m4_undefine([_pos_names_count])],
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
	[_ENDL_()_MAKE_ARGV_PARSING_FUNCTION()_ENDL_(2)],
	[_IF_HAVE_POSITIONAL_ARGS([m4_do(
		[_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([_ENDL_()_MAKE_CHECK_POSITIONAL_COUNT_FUNCTION()_ENDL_(2)])],
		[_ENDL_()_MAKE_ASSIGN_POSITIONAL_ARGS_FUNCTION()_ENDL_(2)],
	)])],
	[$1([parse_commandline "@S|@@"], [handle_passed_args_count], [assign_positional_args 1 "${_positionals[@]}"])],
)])


dnl
dnl Generates functions and outputs either hints or function calls
dnl
dnl $1: Callback --- how to deal with actual function calls
m4_define([_MAKE_VALUES_ASSIGNMENTS_BASE_POSIX], [m4_do(
	[_ENDL_()_IF_HAVE_OPTIONAL_ARGS([_MAKE_ARGV_PARSING_FUNCTION_POSIX()_ENDL_(2)])],
	[_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([_ENDL_()_MAKE_CHECK_POSITIONAL_COUNT_FUNCTION()_ENDL_(2)])],
	[_IF_HAVE_POSITIONAL_ARGS([m4_do(
		[_ENDL_()_MAKE_ASSIGN_POSITIONAL_ARGS_FUNCTION()_ENDL_(2)],
	)])],
	[$1([parse_commandline "@S|@@"], [_positionals_count=$((@S|@# - OPTIND + 1)); _last_positional=$(eval "printf '%s' \"\@S|@@S|@#\""); handle_passed_args_count], [assign_positional_args "$OPTIND" "@S|@@"])],
)])


dnl
dnl $1: The parse_commandline function call
dnl $2: The handle_passed_args_count function call
dnl $3: The assign_positional_args function call
m4_define([_ASSIGN_GO], [m4_do(
	[_COMM_BLOCK(0,
		[# Now call all the functions defined above that are needed to get the job done],
	)],
	[m4_n([[$1]])],
	[_IF_HAVE_POSITIONAL_ARGS([m4_do(
		[_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([m4_n([[$2]])])],
		[m4_n([[$3]])],
	)])],
)])


dnl
dnl $1: The parse_commandline function call
dnl $2: The handle_passed_args_count function call
dnl $3: The assign_positional_args function call
m4_define([_ASSIGN_GO_POSIX], [m4_do(
	[_COMM_BLOCK(0,
		[# Now call all the functions defined above that are needed to get the job done],
	)],
	[m4_n([[$1]])],
	[_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED([m4_n([[$2]])])],
	[_IF_HAVE_POSITIONAL_ARGS(
		[m4_do(
			[m4_n([[$3]])],
		[m4_do(
			[_COMM_BLOCK(0,
				[# Even if we don't accept any positional arguments, we may get some,],
				[# and we can't handle them in the while loop.],
			)],
			[[$2]],
	)],
	)])],
)])


dnl
dnl $1: The parse_commandline function call
dnl $2: The handle_passed_args_count function call
dnl $3: The assign_positional_args function call
dnl
dnl Convention:
dnl The commented-out calls are supposed to be preceded by regexp '^# '
m4_define([_ASSIGN_PREPARE], [m4_do(
	[_COMM_BLOCK(0,
		[# Call the function that assigns passed optional arguments to variables:],
		[#  $1])],
	[_IF_HAVE_POSITIONAL_ARGS([_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED(
		[_COMM_BLOCK(0,
			[# Then, call the function that checks that the amount of passed arguments is correct],
			[# followed by the function that assigns passed positional arguments to variables:],
			[#  $2],
			[#  $3],
		)],
		[_COMM_BLOCK(0,
			[# Then, call the function that assigns passed positional arguments to variables:],
			[# $3],
		)])],
	)],
)])


dnl
dnl $1: The parse_commandline function call
dnl $2: The handle_passed_args_count function call
dnl $3: The assign_positional_args function call
dnl
dnl Convention:
dnl The commented-out calls are supposed to be preceded by regexp '^# '
m4_define([_ASSIGN_PREPARE_POSIX], [m4_do(
	[_COMM_BLOCK(0,
		[# Call the function that assigns passed optional arguments to variables:],
		[#  $1])],
	[_IF_HAVE_POSITIONAL_ARGS([_IF_POSITIONAL_ARGS_COUNT_CHECK_NEEDED(
		[_COMM_BLOCK(0,
			[# Then, call the function that checks that the amount of passed arguments is correct],
			[# followed by the function that assigns passed positional arguments to variables:],
			[#  $2],
			[#  $3],
		)],
		[_COMM_BLOCK(0,
			[# Then, call the function that assigns passed positional arguments to variables:],
			[# $3],
		)])],
		[_COMM_BLOCK(0,
			[# Then, call the function that checks that the amount of passed arguments is correct],
			[# We may get positional args even if we don't explicitly accept them.],
			[#  $2],
		)],
	)],
)])


dnl
dnl $1: argname macro
dnl $2: _arg_type
dnl $3: _min_argn
dnl $4: _defaults
dnl TODO: The changed doublequote-escape behavior may have ugly side-effects.
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
			[single], [_sh_quote([$4])],
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


m4_define([_MAKE_DEFAULTS_POSITIONAL], [m4_do(
	[[# THE DEFAULTS INITIALIZATION - POSITIONALS]_ENDL_],
	[_COMM_BLOCK(0,
		[# The positional args array has to be reset before the parsing, because it may already be defined],
		[# - for example if this script is sourced by an argbash-powered script.])],
	[[_positionals=()]_ENDL_],
	[m4_lists_foreach_positional([_ARGS_LONG,_POSITIONALS_MINS,_POSITIONALS_DEFAULTS,_ARGS_CATH], [_argname,_min_argn,_defaults,_arg_type],
		[_MAKE_DEFAULTS_POSITIONALS_LOOP(_argname, _arg_type, _min_argn, _defaults)])],
)])


m4_define([_MAKE_DEFAULTS_POSITIONAL_POSIX], [m4_do(
	[[# THE DEFAULTS INITIALIZATION - POSITIONALS]_ENDL_],
	[_COMM_BLOCK(0,
		[# TBD],
		[# TBD])],
	[m4_lists_foreach_positional([_ARGS_LONG,_POSITIONALS_MINS,_POSITIONALS_DEFAULTS,_ARGS_CATH], [_argname,_min_argn,_defaults,_arg_type],
		[_MAKE_DEFAULTS_POSITIONALS_LOOP(_argname, _arg_type, _min_argn, _defaults)])],
)])


m4_define([_MAKE_DEFAULTS_OPTIONAL], [m4_do(
	[[# THE DEFAULTS INITIALIZATION - OPTIONALS]_ENDL_],
	[m4_lists_foreach_optional([_ARGS_LONG,_ARGS_CATH,_ARGS_DEFAULT,_ARGS_VARNAME], [_argname,_arg_type,_default,_arg_varname], [m4_do(
		[dnl We have to handle 'incr' as a special case, there is a m4_default(..., 0)
],
		[m4_case(_arg_type,
			[action], [],
			[incr], [_arg_varname=m4_expand(_default)_ENDL_],
			[repeated], [_arg_varname=(_default)_ENDL_],
			[_arg_varname=_sh_quote(_default)_ENDL_])],
	)])],
)])


dnl
dnl Make basic utility stuff.
dnl Those include the die function as well as optional validators
m4_define([_MAKE_UTILS_POSIX], [m4_do(
	[_ENDL_()_MAKE_DIE_FUNCTION()_ENDL_(2)],
	[_IF_RESTRICT_VALUES([_ENDL_()_MAKE_RESTRICT_VALUES_FUNCTION()_ENDL_(2)])],
	[_PUT_VALIDATORS],
)])


dnl
dnl Make additional stuff.
dnl Those include the die function as well as optional validators
m4_define([_MAKE_UTILS], [m4_do(
	[_MAKE_UTILS_POSIX()],
	[_IF_HAVE_OPTIONAL_ARGS([_IF_OPT_GROUPING_GETOPT([_ENDL_()_MAKE_NEXT_OPTARG_FUNCTION()_ENDL_()])])],
)])


m4_define([_MAKE_OTHER], [m4_do(
	[[# OTHER STUFF GENERATED BY Argbash]_ENDL_],
	[dnl Put the stuff below into some condition block
],
	[dnl _ARGS_GROUPS is a set of arguments lists where all args inherited from a wrapped script are
],
	[m4_set_foreach([_ARGS_GROUPS], [agroup], [agroup=("${agroup[]_opt_suffix@<:@@@:>@}" "${agroup[]_pos_suffix@<:@@@:>@}")_ENDL_])],
	[m4_list_foreach([_OTHER], [item], [item[]_ENDL_])],
	[_VALIDATE_POSITIONAL_ARGUMENTS],
	[_MAYBE_ASSIGN_INDICES_TO_TYPED_SINGLE_VALUED_ARGS],
)])


dnl
dnl $1: What to do if they are defined
dnl $2: What to do if not
m4_define([_IF_SOME_ARGS_ARE_DEFINED],
	[_IF_HAVE_POSITIONAL_ARGS([$1], [_IF_HAVE_OPTIONAL_ARGS([$1], [$2])])])


argbash_api([ARGBASH_GO], [m4_do(
	[m4_ifndef([WRAPPED_FILE_STEM], [_ARGBASH_GO([$0()])])],
)])


argbash_api([ARGBASH_PREPARE], [m4_do(
	[m4_ifndef([WRAPPED_FILE_STEM], [m4_do(
		[_SET_DIY_MODE()],
		[_ARGBASH_GO([$0()])],
	)])],
)])


dnl Empty the FLAGS macro (so it isn't F,L,A,G,S)
m4_define([_W_FLAGS], [])

m4_define([_IF_W_FLAGS_DONT_CONTAIN],
	[m4_bmatch(m4_expand([_W_FLAGS]), [$1], [$3], [$2])])


dnl If I am wrapped:
dnl It may be that the wrapped script contains args that we already have.
dnl TODO: In this case: Raise an error (with a good advice)


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
		[_INDENT_()[{ begins_with_short_option "$_next" && shift && set -- "-$1" "-${_next}" "@S|@@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."]],
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

