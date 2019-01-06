
m4_define([_SYNOPSIS_OF_OPTIONAL_ARGS], [m4_lists_foreach_optional([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH], [_argname,_arg_short,_arg_type], [m4_do(
	[ @<:@],
	[m4_case(_arg_type,
		[bool], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, )],
		[arg], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, , _CAPITALIZE(_argname))],
		[repeated], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, , _CAPITALIZE(_argname))],
		[_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, )])],
	[@:>@],
	[m4_case(_arg_type,
		[repeated], [...],
		[incr], [...],
		[])],
)])])

dnl
dnl $1: Long + short
dnl $2: Padding of $1
dnl $3: Help (optional)
dnl $4: Default (optional)
m4_define([_FORMAT_DOCOPT_OPTION], [m4_do(
	[m4_format([[  %-$2s]]m4_ifnblank([$3$4], [[[  %s]]])m4_ifnblank([$4], [[[ [default: %s]]]])._ENDL_(), [$1], [$3], [$4])],
)])


dnl
dnl $1: argname
dnl $2: short
dnl $3: cathegory
dnl $4: defaults
dnl $5: help
m4_define([APPEND_TO_LISTS_WITH_HELP_ELEMENTS], [m4_do(
	[m4_list_append([_LIST_LOCAL_HELP], [$5])],
	[m4_list_append([_LIST_DOCOPT_OPTIONALS_SPECS], m4_case(_arg_type,
		[bool], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS([$1], [$2], , [, ])],
		[action], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS([$1], [$2], , [, ])],
		[_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS([$1], [$2], _CAPITALIZE([$1]), [, ])]))],
	[m4_list_append([_LIST_LOCAL_DEFAULTS], m4_case(_arg_type,
		[bool], [[$4]],
		[action], [],
		[[$4]]))],
)])


dnl
dnl $1: Option formatter - check out _FORMAT_DOCOPT_OPTION for reference
m4_define([MAKE_OPTIONS_SUMMARY], [m4_do(
	[m4_lists_foreach_optional([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH,_ARGS_DEFAULT,_ARGS_HELP], [_argname,_arg_short,_arg_type,_arg_default,_arg_help],
		[APPEND_TO_LISTS_WITH_HELP_ELEMENTS(_argname,_arg_short,_arg_type,_arg_default,_arg_help)])],
	[m4_lists_foreach([_LIST_DOCOPT_OPTIONALS_SPECS,_LIST_LOCAL_HELP,_LIST_LOCAL_DEFAULTS], [spec,_arg_help,_arg_default], [m4_quote($1(spec, _LIST_LONGEST_TEXT_LENGTH([_LIST_DOCOPT_OPTIONALS_SPECS]), _arg_help, _arg_default))])],
)])


dnl
dnl $1: Basename
m4_define([CREATE_DOCOPT_MESSAGE], [m4_do(
	[_IF_SOME_ARGS_ARE_DEFINED([m4_do(
		[m4_list_destroy([_LIST_LOCAL_HELP])],
		[m4_list_destroy([_LIST_DOCOPT_OPTIONALS_SPECS])],
		[m4_list_destroy([_LIST_LOCAL_DEFAULTS])],

		[Usage: $1],
		[_MAKE_HELP_SYNOPSIS
],
		_IF_HAVE_OPTIONAL_ARGS([m4_do(
			[_ENDL_()],
			[Options:],
			[_ENDL_()],
			[m4_dquote(MAKE_OPTIONS_SUMMARY([_FORMAT_DOCOPT_OPTION]))],
		)])
	)])],
)])
