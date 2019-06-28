m4_include([argument_value_types.m4])
m4_include([value_validators.m4])

dnl
dnl $1: Argname
m4_define([_REPRESENT_VALUE_VERBOSE], [_IF_ARG_IS_OF_SET_TYPE([$1],
	[m4_list_join(LIST_OF_VALUES_OF_ARGNAME([$1]), [|])],
	[_CAPITALIZE([$1])])])


dnl
dnl $1: Argname
m4_define([_REPRESENT_VALUE_SYNOPSIS], [m4_set_contains([TYPED_ARGS], [$1],
	[m4_indir([$1_VAL_GROUP])],
	[_CAPITALIZE([$1])])])


m4_define([_SYNOPSIS_OF_OPTIONAL_ARGS], [m4_lists_foreach_optional([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH], [_argname,_arg_short,_arg_type], [m4_do(
	[ @<:@],
	[m4_case(_arg_type,
		[bool], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, )],
		[arg], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, , _REPRESENT_VALUE_SYNOPSIS(_argname))],
		[repeated], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, , _REPRESENT_VALUE_SYNOPSIS(_argname))],
		[_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, )])],
	[@:>@],
	[m4_case(_arg_type,
		[repeated], [...],
		[incr], [...],
		[])],
)])])

dnl
dnl $1: Argname
dnl $2: Long + short
dnl $3: Padding of $2
dnl $4: Help (optional)
dnl $5: Default (optional)
dnl
dnl 2 + 2 in the substitute function: 2 leading spaces + 2 spaces between options and text.
m4_define([_FORMAT_DOCOPT_OPTION], [m4_do(
	[m4_format([[  %-$3s]]m4_ifnblank([$4$5], [[[  %s]]])m4_ifnblank([$5], [[[ [default: %s]]]])._ENDL_(), [$2], _SUBSTITUTE_LF_FOR_NEWLINE_WITH_SPACE_INDENT_AND_ESCAPE_DOUBLEQUOTES([$4], m4_eval([$3] + 2 + 2)), [$5])],
)])


dnl
dnl $1: argname
dnl $2: short
dnl $3: cathegory
dnl $4: defaults
dnl $5: help
m4_define([APPEND_TO_LISTS_WITH_HELP_ELEMENTS], [m4_do(
	[m4_list_append([_LIST_LOCAL_HELP], [$5])],
	[m4_list_append([_LIST_ARGNAMES], [$1])],
	[m4_list_append([_LIST_DOCOPT_OPTIONALS_SPECS], m4_case(_arg_type,
		[bool], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS([$1], [$2], , [, ])],
		[action], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS([$1], [$2], , [, ])],
		[_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS([$1], [$2], _REPRESENT_VALUE_VERBOSE([$1]), [, ])]))],
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
	[m4_lists_foreach([_LIST_ARGNAMES,_LIST_DOCOPT_OPTIONALS_SPECS,_LIST_LOCAL_HELP,_LIST_LOCAL_DEFAULTS], [_argname,spec,_arg_help,_arg_default], [m4_quote($1(_argname, spec, _LIST_LONGEST_TEXT_LENGTH([_LIST_DOCOPT_OPTIONALS_SPECS]), _arg_help, _arg_default))])],
)])


dnl
dnl $1: Basename
m4_define([CREATE_DOCOPT_MESSAGE], [m4_do(
	[_IF_SOME_ARGS_ARE_DEFINED([m4_do(
		[m4_list_destroy([_LIST_ARGNAMES])],
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
