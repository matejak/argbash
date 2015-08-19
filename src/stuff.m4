dnl We don't like the # comments
m4_changecom()

dnl We include the version-defining macro
m4_define([_ARGBASH_VERSION], m4_default_quoted(m4_normalize(m4_sinclude([version])), [unknown]))

m4_define([m4_list_declare], [m4_do(
	[m4_define([$1_GET], [m4_expand([m4_list_nth([$1], $][1)])])],
	[m4_define([$1_FOREACH], [m4_foreach([item], [m4_dquote_elt(m4_list_contents([$1]))], m4_quote($][1))])],
)])

m4_define([m4_list_add], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_ifndef(_LIST_NAME,
		[m4_define(_LIST_NAME, m4_dquote(m4_escape([$2])))],
		[m4_define(_LIST_NAME, m4_dquote(m4_list_contents([$1]), m4_escape([$2])))],
	)],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([m4_list_contents], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_ifndef(_LIST_NAME, [], m4_quote(_LIST_NAME))],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([m4_list_nth], [m4_argn([$2], m4_list_contents([$1]))])

m4_define([_translit], [m4_translit(m4_translit([$1], [a-z], [A-Z]), [-], [_])])
m4_define([_varname], [_ARG_[]_translit([$1])])

dnl
dnl $1: Long option
dnl $2: Short option (opt)
dnl $3: Help string
dnl $4: Default (opt)
dnl $5: Type
m4_define([_some_opt], [m4_do(
	[m4_list_add([_ARGS_LONG], [$1])],
	[dnl Check whether we didn't already use the arg, if not, add its tranliteration to the list of used ones
],
	[m4_set_contains(_translit([_ARGS_LONG]),  [$1],
		[m4_ifnblank([$1], [m4_fatal([The long option '$1' is already used.])])],
		[m4_set_add(_translit([_ARGS_LONG]), [$1])])],
	[m4_list_add([_ARGS_SHORT], [$2])],
	[m4_set_contains([_ARGS_SHORT], [$2],
		[m4_ifnblank([$2], [m4_fatal([The short option '$2' is already used.])])],
		[m4_set_add([_ARGS_SHORT], [$2])])],
	[m4_list_add([_ARGS_HELP], [$3])],
	[m4_list_add([_ARGS_DEFAULT], [$4])],
	[m4_list_add([_ARGS_TYPE], [$5])],
	[m4_define([_NARGS], m4_eval(_NARGS + 1))],
)])

m4_define([_NARGS], 0)
m4_define([_POSITIONALS], 0)

dnl To be able to use _POSITIONALS_FOREACH
m4_list_declare([_POSITIONALS])

m4_define([ARG_POSITIONAL_SINGLE], [m4_do(
	[[$0($@)]],
	[m4_list_add([_POSITIONALS], [$1])],
	[m4_set_contains([_POSITIONALS], [$1], [m4_fatal([The positional option name '$1' is already used.])], [m4_set_add([_POSITIONALS], [$1])])],
	[m4_define([_POSITIONALS], m4_eval(_POSITIONALS + 1))],
)])

m4_define([ARG_OPTIONAL_SINGLE], [m4_do(
	[[$0($@)]],
	[_some_opt([$1], [$2], [$3], [$4], [arg])],
)])

dnl
dnl $1 The function to call to get the version
m4_define([ARG_VERSION], [m4_do(
	[dnl Just record how have we called ourselves
],
	[[$0($@)]],
	[dnl The function with underscore doesn't record what we have just recorded
],
	_ARG_OPTIONAL_ACTION(
		[version],
		[v],
		[Prints version],
		[$1],
	),
)])

m4_define([ARG_HELP], [m4_do(
	[[$0($@)]],
	[m4_define([_HELP_MSG], m4_escape([$1]))],
	_ARG_OPTIONAL_ACTION(
		[help],
		[h],
		[Prints help],
		[print_help],
	),
)])


m4_define([DEFINE_SCRIPT_DIR], [m4_do(
	[[$0($@)]],
	[m4_pushdef([_sciptdir], m4_ifnblank([$1], [[$1]], [[SCRIPT_DIR]]))],
	[m4_list_add([_OTHER],
		m4_quote(_sciptdir[="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"]))],
	[m4_popdef([_sciptdir])]
)])

dnl $1 = long name, var suffix (translit of [-] -> _)
dnl $2 = short name (opt)
dnl $3 = help
dnl $4 = default (=off)
m4_define([ARG_OPTIONAL_BOOLEAN], [m4_do(
	[[$0($@)]],
	[_some_opt([$1], [$2], [$3],
		m4_ifnblank([$4], [$4], [off]), [bool])],
)])

m4_define([_ARG_OPTIONAL_ACTION_BODY], [[_some_opt(m4_quote(]]$[[]]1[[), m4_quote($]][[2), m4_quote($]][[3), m4_quote($]][[4), [action])]])

m4_define([ARG_OPTIONAL_ACTION], [m4_do(
	[[$0($@)]],
	[dnl Just call _ARG_OPTIONAL_ACTION with same args
],
	]m4_dquote(_ARG_OPTIONAL_ACTION_BODY)[,
)])

m4_define([_ARG_OPTIONAL_ACTION], _ARG_OPTIONAL_ACTION_BODY)


m4_define([_MAKE_HELP], [m4_do(
	[# THE PRINT HELP FUNCION
],
	[function print_help
{
],
	m4_ifnblank(m4_quote(_HELP_MSG), m4_expand([[	echo] "_HELP_MSG"
])),
	[	echo "Usage: $[]0],
	[dnl If we have positionals, display them like <pos1> <pos2> ...
],
	[m4_set_empty([_POSITIONALS], [], [ <])m4_set_contents([_POSITIONALS], [>, <])m4_set_empty([_POSITIONALS], [], [>])],
	[dnl If we have optionals, display them like [--opt1 arg] [--(no-)opt2] ... according to their type. @<:@ becomes square bracket at the end of processing
],
	[m4_for([idx], 1, _NARGS, 1, [m4_do(
		[ @<:@--],
		[m4_case(m4_list_nth([_ARGS_TYPE], idx),
			[bool], [(no-)]m4_list_nth([_ARGS_LONG], idx),
			[arg], m4_list_nth([_ARGS_LONG], idx)[ <arg>],
			[m4_list_nth([_ARGS_LONG], idx)])],
		[@:>@],
	)])],
	["
],
	[_POSITIONALS_FOREACH([[	echo -e "\t<item>: Positional arg"
]])],
	[m4_for([idx], 1, _NARGS, 1, [m4_do(
		[	echo -e "\t],
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
		[m4_case(m4_list_nth([_ARGS_TYPE], idx), [action], [], [ (default: 'm4_list_nth([_ARGS_DEFAULT], idx)')])],
		["
],
	)])],
	[}],
)])

m4_define([_MAKE_EVAL], [m4_do(
	[# THE PARSING ITSELF
],
	[while test $[]# -gt 0
do],
	[
	_key="$[]1"
],
	[	case "$_key" in],
	[m4_for([idx], 1, _NARGS, 1, [m4_do(
		[
		],
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
			],
		[dnl: TODO: Below is a problem with quoting
],
		[dnl Output the body of the case
],
		[m4_pushdef([_ARGVAR], _varname(m4_list_nth([_ARGS_LONG], idx)))],
		[m4_case(m4_list_nth([_ARGS_TYPE], idx),
			[arg], [test $[]# -lt 2 && { echo "Missing value for the positional argument." >&2; exit 1; }]
			_ARGVAR[="$[]2"
			shift],
			[bool], _ARGVAR[="on"
			test "$[]{1:0:5}" = "--no-" && ]_ARGVAR[="off"],
			[action], [m4_list_nth([_ARGS_DEFAULT], idx)
			exit 0],
		)],
		[
			;;],
		[m4_popdef([_ARGVAR])],
	)])],
	[[
		*@:}@
		    	POSITIONALS+=("$][1")
		    	# unknown option
			;;
	esac
	shift
done]],
	[

],
	[dnl Now we look what positional args we got and we say if they were too little or too many. We also do the assignment to variables using eval.
],
	[[POSITIONAL_NAMES=(]_POSITIONALS_FOREACH([['_varname(item)' ]])[)
test ${#POSITIONALS[@]} -lt ]_POSITIONALS[ && { ( echo "FATAL ERROR: Not enough positional arguments."; print_help ) >&2; exit 1; }
test ${#POSITIONALS[@]} -gt ]_POSITIONALS[ && { ( echo "FATAL ERROR: There were spurious positional arguments."; print_help ) >&2; exit 1; }
for (( ii = 0; ii <  ${#POSITIONALS[@]}; ii++))
do
	eval "${POSITIONAL_NAMES[$ii]}=\"${POSITIONALS[$ii]}\""
done]],
)])

m4_define([_MAKE_DEFAULTS], [m4_do(
	[# THE DEFAULTS INITIALIZATION
],
	[m4_for([idx], 1, _NARGS, 1, [m4_do(
		[m4_pushdef([_ARGVAR], _varname(m4_list_nth([_ARGS_LONG], idx)))],
		[m4_case(m4_list_nth([_ARGS_TYPE], idx),
			[action], [],
			m4_expand([_ARGVAR=m4_list_nth([_ARGS_DEFAULT], idx)
]))],
		[m4_popdef([_ARGVAR])],
	)])],
)])

m4_define([_MAKE_OTHER], [m4_do(
	[[# OTHER STUFF GENERATED BY Argbash
]],
	[m4_list_declare([_OTHER])],
	[_OTHER_FOREACH([item
])],
)])
