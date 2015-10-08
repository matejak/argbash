dnl We don't like the # comments
m4_changecom()

dnl We include the version-defining macro
m4_define([_ARGBASH_VERSION], m4_default_quoted(m4_normalize(m4_sinclude([version])), [unknown]))

m4_define([DEFINE_VERSION], [m4_do(
	[m4_define([USER_VERSION], m4_expand([m4_esyscmd_s([$1])]))],
	[m4_expand([USER_VERSION])],
)])

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

m4_define([m4_list_len], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_count(m4_unquote(_LIST_NAME))],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([m4_list_contents], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_ifndef(_LIST_NAME, [], m4_quote(_LIST_NAME))],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([m4_list_nth], [m4_argn([$2], m4_list_contents([$1]))])

m4_define([m4_list_pop_front], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_car(m4_unquote(_LIST_NAME))],
	[m4_define(_LIST_NAME, m4_cdr(m4_unquote(_LIST_NAME)))],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([m4_list_pop_back], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_define(_LIST_NAME, m4_dquote(m4_reverse(m4_unquote(_LIST_NAME))))],
	[m4_list_pop_front([$1])],
	[m4_define(_LIST_NAME, m4_dquote(m4_reverse(m4_unquote(_LIST_NAME))))],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([_translit], [m4_translit(m4_translit([$1], [a-z], [A-Z]), [-], [_])])
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
dnl $1: Long option
dnl $2: Short option (opt)
dnl $3: Help string
dnl $4: Default, pass it through _sh_quote if needed beforehand (opt)
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

dnl Number of distinct args the script can accept
m4_define([_NARGS], 0)
m4_define([_POSITIONALS_MIN], 0)
m4_define([_POSITIONALS_MORE], 0)

dnl To be able to use _POSITIONALS_NAMES_FOREACH
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
	[m4_if([_POSITIONALS_MORE], -1, [$1], [$2])])

dnl Do something depending on whether there have been optional positional args declared beforehand or not
m4_define([IF_POSITIONALS_VARNUM],
	[m4_ifdef([HAVE_POSITIONAL_VARNUM], [$1], [$2])])

dnl
dnl Declare one positional argument
dnl $1: Name of the arg
dnl $2: Help for the arg
m4_define([ARG_POSITIONAL_SINGLE], [m4_do(
	[[$0($@)]],
	[IF_POSITIONALS_VARNUM([m4_fatal([There are some potional args before this one ('$1', that is not optional). We don't support that yet, sorry.]])],
	[_A_POSITIONAL],
	[m4_list_add([_POSITIONALS_NAMES], [$1])],
	[m4_list_add([_POSITIONALS_MSGS], [$2])],
	[m4_list_add([_POSITIONALS_MINS], 1)],
	[m4_list_add([_POSITIONALS_DEFAULTS], [])],
	[m4_set_contains([_POSITIONALS], [$1], [m4_fatal([The positional option name '$1' is already used.])], [m4_set_add([_POSITIONALS], [$1])])],
	[m4_define([_POSITIONALS_MIN], m4_incr(_POSITIONALS_MIN))],
)])

dnl
dnl Declare one positional argument with default
dnl $1: Name of the arg
dnl $2: Default
dnl $3: Help for the arg
m4_define([ARG_POSITIONAL_SINGLE_OPT], [m4_do(
	[[$0($@)]],
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[_A_POSITIONAL_VARNUM],
	[m4_define([_POSITIONALS_MORE], m4_incr(_POSITIONALS_MORE))],
	[m4_list_add([_POSITIONALS_NAMES], [$1])],
	[m4_list_add([_POSITIONALS_MSGS], [$3])],
	[m4_list_add([_POSITIONALS_MINS], 0)],
	[dnl Here, the _sh_quote actually ensures that the default is NOT BLANK!
],
	[m4_list_add([_POSITIONALS_DEFAULTS], _sh_quote([$2]))],
	[m4_set_contains([_POSITIONALS], [$1], [m4_fatal([The positional option name '$1' is already used.])], [m4_set_add([_POSITIONALS], [$1])])],
)])

m4_define([ARG_OPTIONAL_SINGLE], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_some_opt([$1], [$2], [$3], _sh_quote([$4]), [arg])],
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
		m4_quote(_sciptdir[="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"]))],
	[m4_popdef([_sciptdir])],
)])

m4_define([_ARG_OPTIONAL_INCR_BODY], [[_some_opt(m4_quote(]]$[[]]1[[), m4_quote($]][[2), m4_quote($]][[3), 0, [incr])]])

m4_define([_ARG_OPTIONAL_INCR], _A_OPTIONAL[]_ARG_OPTIONAL_INCR_BODY)

dnl $1 = long name
dnl $2 = short name (opt)
dnl $3 = help
m4_define([ARG_OPTIONAL_INCR], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	]m4_dquote(_ARG_OPTIONAL_INCR_BODY)[,
)])

dnl $1 = short name (opt)
m4_define([ARG_VERBOSE], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_ARG_OPTIONAL_INCR([verbose], [$1], [Set verbose output (can be specified multiple times to increase the effect)])],
)])

dnl $1 = long name, var suffix (translit of [-] -> _)
dnl $2 = short name (opt)
dnl $3 = help
dnl $4 = default (=off)
m4_define([ARG_OPTIONAL_BOOLEAN], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_some_opt([$1], [$2], [$3],
		m4_ifnblank([$4], [$4], [off]), [bool])],
)])

m4_define([_ARG_OPTIONAL_ACTION_BODY], [[_some_opt(m4_quote(]]$[[]]1[[), m4_quote($]][[2), m4_quote($]][[3), m4_quote($]][[4), [action])]])

m4_define([ARG_OPTIONAL_ACTION], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[dnl Just call _ARG_OPTIONAL_ACTION with same args
],
	]m4_dquote(_ARG_OPTIONAL_ACTION_BODY)[,
)])

m4_define([_ARG_OPTIONAL_ACTION], _A_OPTIONAL[]_ARG_OPTIONAL_ACTION_BODY)


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
	[m4_for([idx], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [m4_do(
		[m4_pushdef([argname], <m4_expand(m4_list_nth([_POSITIONALS_NAMES], idx))>)],
		[ m4_if(m4_list_nth([_POSITIONALS_MINS], idx), 0,
			[m4_expand([@<:@argname@:>@])], [m4_expand([argname])])],
		[m4_popdef([argname])],
)])],
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
	[m4_for([idx], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [m4_do(
		[[	echo -e "\t<]m4_list_nth([_POSITIONALS_NAMES], idx)[>: ]],
		[m4_list_nth([_POSITIONALS_MSGS], idx)],
		[m4_if(m4_list_nth([_POSITIONALS_MINS], idx), 0,
			[[ (default: '"]m4_list_nth([_POSITIONALS_DEFAULTS], idx)"')])],
		[["
]],
)])],
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
		[dnl We format defaults help by print-quoting them with ' and stopping the help echo quotes " before the store value is subsittuted, so the message should really match the real default.
],
		[m4_case(m4_list_nth([_ARGS_TYPE], idx), [action], [], [ (default: '"m4_list_nth([_ARGS_DEFAULT], idx)"')])],
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
			;;
	esac
	shift
done]],
	[

],
	[dnl Now we look what positional args we got and we say if they were too little or too many. We also do the assignment to variables using eval.
],
	[[POSITIONAL_NAMES=(]],
	[_POSITIONALS_NAMES_FOREACH([['_varname(item)' ]])],
	[[)
test ${#POSITIONALS[@]} -lt ]],
	[_POSITIONALS_MIN],
	[[ && { ( echo "FATAL ERROR: Not enough positional arguments."; print_help ) >&2; exit 1; }
test ${#POSITIONALS[@]} -gt ]],
	[m4_pushdef([_POSITIONALS_TOTAL], m4_eval(_POSITIONALS_MIN + _POSITIONALS_MORE))],
	[_POSITIONALS_TOTAL],
	[[ && { ( echo "FATAL ERROR: There were spurious positional arguments --- we expect at most ]],
	[_POSITIONALS_TOTAL],
	[m4_popdef([_POSITIONALS_TOTAL])],
	[[."; print_help ) >&2; exit 1; }
for (( ii = 0; ii <  ${#POSITIONALS[@]}; ii++))
do
	eval "${POSITIONAL_NAMES[$ii]}=\"${POSITIONALS[$ii]}\""
done]],
)])

m4_define([_MAKE_DEFAULTS], [m4_do(
	[# THE DEFAULTS INITIALIZATION --- POSITIONALS
],
	[m4_for([idx], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [m4_do(
		[m4_pushdef([_DEFAULT], m4_list_nth([_POSITIONALS_DEFAULTS], idx))],
		[m4_ifnblank(m4_quote(_DEFAULT),
			[_varname(m4_list_nth([_POSITIONALS_NAMES], idx))=_DEFAULT
])],
		[m4_popdef([_DEFAULT])],
	)])],
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
)])

m4_define([_MAKE_OTHER], [m4_do(
	[[# OTHER STUFF GENERATED BY Argbash
]],
	[m4_list_declare([_OTHER])],
	[_OTHER_FOREACH([item
])],
)])
