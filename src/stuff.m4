dnl We don't like the # comments
m4_changecom()


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


dnl
dnl Registers a command, recording its name, type etc.
dnl $1: Long option
dnl $2: Short option (opt)
dnl $3: Help string
dnl $4: Default, pass it through _sh_quote if needed beforehand (opt)
dnl $5: Type
m4_define([_some_opt], [m4_do(
	[m4_errprintn([$1 $2])],
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
dnl Greatest number of positional args the script can accept (-1 for infinity)
m4_define([_POSITIONALS_MAX], 0)

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
	[m4_if([_POSITIONALS_MAX], -1, [$1], [$2])])


dnl Do something depending on whether there have been optional positional args declared beforehand or not
m4_define([IF_POSITIONALS_VARNUM],
	[m4_ifdef([HAVE_POSITIONAL_VARNUM], [$1], [$2])])


dnl
dnl Declare one positional argument with default
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: Default (opt.)
m4_define([ARG_POSITIONAL_SINGLE], [m4_do(
	[[$0($@)]],
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
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
dnl Declare sequence of multiple positional arguments
dnl $1: Name of the arg
dnl $2: Help for the arg
dnl $3: How many args (-1 == infinitely many)
dnl $4, $5, ...: Defaults (opt.)
dnl TODO:
dnl  - handle defaults - now only one global default is allowed per script
dnl   - store them
dnl   - display them in the help
dnl   - use them to extend POSITIONALS
dnl  - use constructs s.a. POSITIONALS+=("${defaults[@]:0:$needed}")
dnl  More:
dnl   - infinitely many args = probably drop the -1 notation, inf. args can be handled in a parallel manner.
m4_define([ARG_POSITIONAL_MORE], [m4_do(
	[[$0($@)]],
	[IF_POSITIONALS_INF([m4_fatal([We already expect arbitrary number of arguments before '$1'. This is not supported])], [])],
	[IF_POSITIONALS_VARNUM([m4_fatal([We already expect unknown number of arguments before '$1'. This is not supported])], [])],
	[m4_define([_POSITIONALS_MAX], m4_if([$3], -1, -1, m4_eval(_POSITIONALS_MAX + [$3])))],
	[m4_list_add([_POSITIONALS_NAMES], [$1])],
	[m4_list_add([_POSITIONALS_TYPES], [more])],
	[m4_list_add([_POSITIONALS_MSGS], [$2])],
	[dnl Minimal number of args is number of accepted - number of defaults (= $3 - ($# - 3))
],
	[m4_pushdef([_min_argn], m4_eval([$3] - ($# - 3) ))],
	[dnl If we have defaults, we actually accept unknown number of arguments
],
	[m4_if(_min_argn, [$3], , [_A_POSITIONAL_VARNUM])],
	[m4_list_add([_POSITIONALS_MINS], m4_if([$3], -1, -1, _min_argn))],
	[m4_list_add([_POSITIONALS_MAXES], [$3])],
	[dnl Here, the _sh_quote actually ensures that the default is NOT BLANK!
],
	[m4_list_add([_POSITIONALS_DEFAULTS], [_$1_DEFAULTS])],
	[m4_list_add([_$1_DEFAULTS], m4_shiftn(3, $@))],
	[m4_popdef([_min_argn])],
	[_CHECK_ARGNAME_FREE([$1], [POS])],
)])


m4_define([ARG_OPTIONAL_SINGLE], [m4_do(
	[m4_ifndef([WRAPPED], [[$0($@)]])],
	[_ARG_OPTIONAL_SINGLE([$1], [$2], [$3], [$4])],
)])


m4_define([_ARG_OPTIONAL_SINGLE], [m4_do(
	[_A_OPTIONAL],
	[_some_opt([$1], [$2], [$3], _sh_quote([$4]), [arg])],
)])


m4_define([ARG_POSITIONAL_DOUBLEDASH], [m4_do(
	[[$0($@)]],
	[m4_define([HAVE_DOUBLEDASH], 1)],
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
	[m4_ifndef([WRAPPED], [[$0($@)]])],
	[m4_errprintn(helping - pre)],
	[dnl Skip help if we declare we don't want it
],
	[m4_bmatch(m4_expand([FLAGS]), [H], ,[_ARG_HELP([$1])])],
)])


m4_define([_ARG_HELP], [m4_do(
	[m4_errprintn(helping)],
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


dnl Precedence is important, _CALL_SOME_OPT has to be defined early on
m4_define([_CALL_SOME_OPT], [[_some_opt([$1], [$2], [$3], [$4], [$5])]])

m4_define([_ARG_OPTIONAL_REPEATED_BODY], [_CALL_SOME_OPT($[]1, $[]2, $[]3, $[]4, [incr])])
m4_define([_ARG_OPTIONAL_REPEATED], [_A_OPTIONAL[]]_ARG_OPTIONAL_REPEATED_BODY)


dnl $1 = long name
dnl $2 = short name (opt)
dnl $3 = help
dnl $4 = default (=0)
m4_define([ARG_OPTIONAL_REPEATED], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	]m4_dquote(_ARG_OPTIONAL_REPEATED_BODY)[,
)])


dnl $1 = short name (opt)
m4_define([ARG_VERBOSE], [m4_do(
	[[$0($@)]],
	[_A_OPTIONAL],
	[_ARG_OPTIONAL_REPEATED([verbose], [$1], [Set verbose output (can be specified multiple times to increase the effect)])],
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
dnl $1: The command short description
m4_define([_MAKE_HELP], [m4_do(
	[# THE PRINT HELP FUNCION
],
	[function print_help
{
],
	m4_ifnblank(m4_expand([_HELP_MSG]), m4_expand([[	echo] "_HELP_MSG"
])),
	[	echo "Usage: $[]0],
	[dnl If we have optionals, display them like [--opt1 arg] [--(no-)opt2] ... according to their type. @<:@ becomes square bracket at the end of processing
],
	[m4_if(HAVE_OPTIONAL, 1,
		[m4_for([idx], 1, _NARGS, 1, [m4_do(
			[ @<:@--],
			[m4_case(m4_list_nth([_ARGS_TYPE], idx),
				[bool], [(no-)]m4_list_nth([_ARGS_LONG], idx),
				[arg], m4_list_nth([_ARGS_LONG], idx)[ <arg>],
				[m4_list_nth([_ARGS_LONG], idx)])],
			[@:>@],
		)])],
	)],
	[m4_if(HAVE_DOUBLEDASH, 1, [[ @<:@--@:>@]])],
	[dnl If we have positionals, display them like <pos1> <pos2> ...
],
	[m4_if(HAVE_POSITIONAL, 1,
		[m4_for([idx], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [m4_do(
			[m4_pushdef([argname], [ <]m4_expand(m4_list_nth([_POSITIONALS_NAMES], idx))>)],
			[m4_if(m4_list_nth([_POSITIONALS_MINS], idx), 0,
				[m4_expand([@<:@argname@:>@])], [m4_expand([argname])])],
			[m4_popdef([argname])],
		)])],
	)],
	["
],
	[m4_if(HAVE_POSITIONAL, 1,
		[m4_for([idx], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [m4_do(
			[[	echo -e "\t<]m4_list_nth([_POSITIONALS_NAMES], idx)[>: ]],
			[m4_list_nth([_POSITIONALS_MSGS], idx)],
			[m4_if(m4_list_nth([_POSITIONALS_MINS], idx), 0, [m4_do(
					[ @{:@],
					[default: '"],
					[m4_list_nth([_POSITIONALS_DEFAULTS], idx)],
					["'],
					[@:}@],
				)])],
			[["
]],
		)])],
	)],
	[dnl If we have 0 optional args, don't do anything (FOR loop would assert, 0 < 1)
],
	[m4_if(_NARGS, 0, [], [m4_for([idx], 1, _NARGS, 1, [m4_do(
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
	)])])],
	[}],
)])


m4_define([_EVAL_OPTIONALS], [m4_do(
	[	_key="$[]1"
],
	[m4_if(HAVE_DOUBLEDASH, 1, [[	if test "$_key" = '--'
	then
		shift
		POSITIONALS+=("$][@")
		break
	fi
]])],
	[	case "$_key" in],
	[dnl We don't do this if _NARGS == 0
],
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
			[arg], [test $[]# -lt 2 && { echo "Missing value for the optional argument '$_key'." >&2; exit 1; }]
			_ARGVAR[="$[]2"
			shift],
			[bool], _ARGVAR[="on"
			test "$[]{1:0:5}" = "--no-" && ]_ARGVAR[="off"],
			[incr], m4_quote((( _ARGVAR++ ))),
			[action], [m4_list_nth([_ARGS_DEFAULT], idx)
			exit 0],
		)],
		[
			;;],
		[m4_popdef([_ARGVAR])],
	)])],
	[m4_if(HAVE_POSITIONAL, 1,
		[m4_expand([_EVAL_POSITIONALS_CASE])],
		[m4_expand([_EXCEPT_OPTIONALS_CASE])])],
	[[
	esac]],
)])


dnl Store positional args inside a 'case' statement (that is inside a 'for' statement)
m4_define([_EVAL_POSITIONALS_CASE], [[
		*@:}@
		    	POSITIONALS+=("$][1")
			;;]])


dnl If we expect only optional arguments and we get an intruder, fail noisily.
m4_define([_EXCEPT_OPTIONALS_CASE], [[
		*@:}@
			{ (echo "FATAL ERROR: Got an unexpected argument '$][1'"; print_help) >&2; exit 1; }
			;;]])


dnl Store positional args inside a 'for' statement
m4_define([_EVAL_POSITIONALS_FOR],
	[[	POSITIONALS+=("$][1")]])


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
	[[	shift
done]],
	[
],
	[m4_if(HAVE_POSITIONAL, 1, [m4_do(
		[dnl Now we look what positional args we got and we say if they were too little or too many. We also do the assignment to variables using eval.
],
		[
],
		[[POSITIONAL_NAMES=@{:@]],
		[m4_for([ii], 1, m4_list_len([_POSITIONALS_NAMES]), 1, [m4_do(
			[dnl Go through all positionals names ...
],
			[m4_pushdef([_POS_MAX], m4_list_nth([_POSITIONALS_MAXES], ii))],
			[m4_for([jj], 1, _POS_MAX, 1, [m4_do(
				[dnl And repeat each of them POSITIONALS_MAXES-times
],
				['],
				[_varname(m4_list_nth([_POSITIONALS_NAMES], ii))],
				[dnl If we handle a multi-value arg, we assign to an array => we add '[ii - 1]' to LHS
],
				[m4_if(_POS_MAX, 1, , [@<:@m4_eval(jj - 1)@:>@])],
				[' ],
			)])],
			[m4_popdef([_POS_MAX])],
		)])],
		[m4_pushdef([_NARGS_SPEC], m4_if(_POSITIONALS_MIN, _POSITIONALS_MAX, [exactly _POSITIONALS_MIN], [between _POSITIONALS_MIN and _POSITIONALS_MAX]))],
		[[@:}@
test ${#POSITIONALS[@]} -lt ]],
		[_POSITIONALS_MIN],
		[[ && { ( echo "FATAL ERROR: Not enough positional arguments --- we require ]_NARGS_SPEC[, but got only ${#POSITIONALS[@]}."; print_help ) >&2; exit 1; }
test ${#POSITIONALS[@]} -gt ]],
		[_POSITIONALS_MAX],
		[[ && { ( echo "FATAL ERROR: There were spurious positional arguments --- we expect ]],
		[_NARGS_SPEC],
		[dnl The last element of POSITIONALS (even) for bash < 4.3 according to http://unix.stackexchange.com/a/198790
],
		[[, but got ${#POSITIONALS[@]} (the last one was: '${POSITIONALS[@]: -1}')."; print_help ) >&2; exit 1; }
for (( ii = 0; ii <  ${#POSITIONALS[@]}; ii++))
do
	eval "${POSITIONAL_NAMES[$ii]}=\"${POSITIONALS[$ii]}\"" || { echo "Error during argument parsing, possibly an argbash bug." >&2; exit 1; }
done]],
		[m4_popdef([_NARGS_SPEC])],
	)])],
)])


m4_define([_MAKE_DEFAULTS_POSITIONALS_LOOP], [m4_do(
	[m4_pushdef([_DEFAULT], m4_dquote(m4_list_nth([_POSITIONALS_DEFAULTS], idx)))],
	[m4_ifnblank(m4_quote(_DEFAULT), [m4_do(
		[_varname(m4_list_nth([_POSITIONALS_NAMES], idx))=],
		[m4_case(m4_list_nth([_POSITIONALS_TYPES], idx),
			[single], [_DEFAULT],
			[more], [m4_do(
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
						m4_dquote(m4_dquote_elt(m4_list_contents(_DEFAULT)))))],
				[@:}@],
				[m4_popdef([_min_argn])],
		)])],
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
	[m4_ifndef([WRAPPED], [_ARGBASH_GO([$0($@)])])],
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


dnl $1: Which file are we wrapping
dnl $2: Names of blacklisted args (list)
dnl $3: Codes of blacklisted args (string, default is HV for help + version)
dnl IDEA: Include the wrapped script and read the argbash stuff
dnl However, define some macros beforehand that will act as global variables and ensure the following:
dnl  - the defns from wrapped script won't be repeated in the wrapper
dnl  - options blacklisted by name won't appear (e.g. 'outfile', 'do-this', ...)
dnl  - blacklisted classes of options won't appear (e.g. help, version)
m4_define([ARGBASH_WRAP], [m4_do(
	[[$0($@)]],
	[m4_pushdef([WRAPPED], [yes])],
	[m4_pushdef([BLACKLIST], [$2])],
	[m4_pushdef([FLAGS], [m4_default([$3], [HV])])],
	[m4_ignore(m4_include([$1]))],
	[m4_popdef([FLAGS])],
	[m4_popdef([BLACKLIST])],
	[m4_popdef([WRAPPED])],
)])

dnl If I am wrapped:
dnl defns are applied, but not recorded
dnl some are not even recorded
dnl It may be that the wrapped script contains args that we already have.
dnl In this case: Raise an error (with a good advice)
