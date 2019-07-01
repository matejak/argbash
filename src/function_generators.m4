m4_define([_FORMAT_LOCALS_BASH], [m4_ifnblank($1, [[local ]m4_join([ ], m4_dquote_elt($@))])])
m4_define([_FORMAT_LOCALS_POSIX], [m4_do(
	[m4_list_destroy([_posix_locals])],
	[m4_foreach([el], [$@], [m4_if(m4_bregexp(m4_quote(el), =), -1, , [m4_list_append([_posix_locals], m4_quote(el))])])],
	[m4_dquote_elt(m4_list_contents([_posix_locals]))],
	[m4_list_destroy([_posix_locals])],
)])


dnl
dnl $1: Local variables formatting function
dnl $2: Comment lines list (optional)
dnl $3: Function name.
dnl $4: Function body - will be expanded
dnl $5, $6, ...: Local variable initializations
m4_define([MAKE_SHELL_FUNCTION], [m4_do(
	m4_ifnblank([$2], [_COMM_BLOCK_HASH(0, m4_dquote_elt($2))]),
	[m4_n([$3()])],
	[m4_n({)],
	_JOIN_INDENTED(1, $1(m4_shiftn(4, m4_dquote_elt($@)))),
	[$4],
	[}],
)])


m4_define([MAKE_BASH_FUNCTION],  [MAKE_SHELL_FUNCTION([_FORMAT_LOCALS_BASH], $@)])
m4_define([MAKE_POSIX_FUNCTION], [MAKE_SHELL_FUNCTION([_FORMAT_LOCALS_POSIX], $@)])

dnl TODO: Maybe make use of m4_map?
m4_define([_MAKE_DIE_FUNCTION], [MAKE_FUNCTION(
	[[# When called, the process ends.],
		[Args:],
		_INDENT_()[@S|@1: The exit message (print to stderr)],
		_INDENT_()[@S|@2: The exit code (default is 1)],
		[if env var _PRINT_HELP is set to 'yes', the usage is print to stderr (prior to @S|@1)],
		[Example:],
		_INDENT_()[test -f "$_arg_infile" || _PRINT_HELP=yes die "Can't continue, have to supply file as an argument, got '$_arg_infile'" 4]],
	[die],
	[_JOIN_INDENTED(1,
		[[test "${_PRINT_HELP:-no}" = yes && print_help >&2]],
		[[echo "@S|@1" >&2]],
		[[exit "${_ret}"]])],
	[_ret="${2:-1}"],
)])


m4_define([_MAKE_NEXT_OPTARG_FUNCTION], [MAKE_FUNCTION(
	[[Function that evaluates whether a value passed to it begins by a character],
		[that is a short option of an argument the script knows about.],
		[This is required in order to support getopts-like short options grouping.]],
	[begins_with_short_option],
	[_JOIN_INDENTED(1,
		[[first_option="${1:0:1}"]],
		[[test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0]])],
	[first_option], m4_expand([all_short_options='m4_list_join([_ARGS_SHORT], [])']),
)])


m4_define([_MAKE_RESTRICT_VALUES_FUNCTION], [MAKE_FUNCTION(
	[[Function that evaluates whether a value passed to an argument],
		[does not violate the global rule imposed by the ARG_RESTRICT_VALUES macro:],
		_CASE_RESTRICT_VALUES([],
			[The value must not match any long or short option this script uses],
			[The value must not match anything that looks like any long or short option.]),
		[Args:],
		_INDENT_()[@S|@1: The name of the option],
		_INDENT_()[@S|@2: The passed value]],
	[evaluate_strictness],
	[_INDENT_()_CASE_RESTRICT_VALUES([],
		[@<:@@<:@ "@S|@2" =~ ^-(-(m4_list_join([_ARGS_LONG], [|]))$|m4_dquote(m4_list_join([_ARGS_SHORT], []))) @:>@@:>@ && die "You have passed '@S|@2' as a value of argument '@S|@1', which makes it look like that you have omitted the actual value, since '@S|@2' is an option accepted by this script. This is considered a fatal error."],
		[@<:@@<:@ "@S|@2" =~ ^--?@<:@a-zA-Z@:>@ @:>@@:>@ && die "You have passed '@S|@2' as a value of argument '@S|@1'. It looks like that you are trying to pass an option instead of the actual value, which is considered a fatal error."])_ENDL_()],
)])


m4_define([_DECLARE_REQUIRED_ARGS_STRING], [[_required_args_string]="m4_list_join([_POSITIONALS_REQUIRED], [, ], , , [ and ])"])


m4_define([_CHECK_FOR_TOO_LITTLE_ARGS], [m4_do(
	[_INDENT_(1)[test "${_positionals_count}" -ge ]],
	[_MINIMAL_POSITIONAL_VALUES_COUNT],
	[[ || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require ]],
	[_SPECIFICATION_OF_ACCEPTED_VALUES_COUNT],
	[ (namely: $_required_args_string)],
	[[, but got only ${_positionals_count}." 1
]],
)])


m4_define([_CHECK_FOR_TOO_MANY_ARGS], [m4_if(_HIGHEST_POSITIONAL_VALUES_COUNT,
	0, [_CHECK_FOR_AT_MOST_NONE_ARGS()],
	[__CHECK_FOR_TOO_MANY_ARGS()])])


m4_define([__CHECK_FOR_TOO_MANY_ARGS], [m4_do(
	[_INDENT_(1)[test "${_positionals_count}" -le ]_HIGHEST_POSITIONAL_VALUES_COUNT],
	[[ || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect ]],
	[_SPECIFICATION_OF_ACCEPTED_VALUES_COUNT],
	[_IF_SOME_POSITIONAL_VALUES_ARE_EXPECTED([ (namely: $_required_args_string)])],
	[[, but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
]],
)])


m4_define([_CHECK_FOR_AT_MOST_NONE_ARGS], [m4_do(
	[_INDENT_(1)[test "${_positionals_count}" -eq 0]],
	[[ || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we don't expect any]],
	[[, but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
]],
)])


dnl TODO: Make sure that if the function is not needed (inf arguments, zero required), it is not generated nor called
m4_define([_MAKE_CHECK_POSITIONAL_COUNT_FUNCTION], [m4_do(
	[m4_pushdef([_SPECIFICATION_OF_ACCEPTED_VALUES_COUNT], IF_POSITIONALS_INF(
		[[at least ]_MINIMAL_POSITIONAL_VALUES_COUNT], m4_if(_MINIMAL_POSITIONAL_VALUES_COUNT, _HIGHEST_POSITIONAL_VALUES_COUNT,
		[[exactly _MINIMAL_POSITIONAL_VALUES_COUNT]],
		[[between _MINIMAL_POSITIONAL_VALUES_COUNT and _HIGHEST_POSITIONAL_VALUES_COUNT]])))],
	[MAKE_FUNCTION(
		[[Check that we receive expected amount positional arguments.],
			[Return 0 if everything is OK, 1 if we have too little arguments],
			[and 2 if we have too much arguments]],
		[handle_passed_args_count], [m4_do(
		[_IF_SOME_POSITIONAL_VALUES_ARE_EXPECTED([_CHECK_FOR_TOO_LITTLE_ARGS])],
		[IF_POSITIONALS_INF([m4_do(
			[_COMM_BLOCK(0,
				[# We accept up to inifinitely many positional values, so],
				[# there is no need to check for spurious positional arguments.],
			)],
		)],
			[_CHECK_FOR_TOO_MANY_ARGS])])],
		_IF_SOME_POSITIONAL_VALUES_ARE_EXPECTED([_DECLARE_REQUIRED_ARGS_STRING]))],
	[m4_popdef([_SPECIFICATION_OF_ACCEPTED_VALUES_COUNT])],
)])

m4_define([_MAKE_ASSIGN_POSITIONAL_ARGS_FUNCTION], [MAKE_FUNCTION(
	[[Take arguments that we have received, and save them in variables of given names.],
		[The 'eval' command is needed as the name of target variable is saved into another variable.]],
	[assign_positional_args], [m4_do(
	[m4_n([_MAKE_LIST_OF_POSITIONAL_ASSIGNMENT_TARGETS])],
	[_JOIN_INDENTED(1,
		[[shift "$_shift_for"]],
		[[for _positional_name in ${_positional_names}]],
		[[do]],
		_INDENT_MORE(
			[[test @S|@# -gt 0 || break]],
			[[eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1]],
			_CASE_RESTRICT_VALUES([], [],
				[_COMM_BLOCK(0, [# It has been requested that all positional arguments that look like options are rejected]),
				[[evaluate_strictness "$_positional_name" "${1##_arg}"]],
			]),
			[[shift]],
		),
		[[done]],
	)],
	[m4_list_ifempty([_WRAPPED_ADD_SINGLE], [], [m4_do(
		[m4_set_foreach([_POS_VARNAMES], [varname], [m4_n([_INDENT_()varname=()])])],
		[_INDENT_()m4_list_join([_WRAPPED_ADD_SINGLE], m4_newline([_INDENT_()]))],
		[
],
	)])],
)],
	[_positional_name], [_shift_for=@S|@1])])


dnl TODO: Remove code duplication
m4_define([_MAKE_ARGV_PARSING_FUNCTION], [MAKE_FUNCTION(
	[[The parsing of the command-line]],
	[parse_commandline], [m4_do(
		[_JOIN_INDENTED(1,
			_IF_HAVE_POSITIONAL_ARGS([[_positionals_count=0],]),
			[while test $[]# -gt 0],
			[do],
		)],
		[_IF_HAVE_OPTIONAL_ARGS(
			[_EVAL_OPTIONALS_AND_POSITIONALS],
			[_STORE_CURRENT_ARG_AS_POSITIONAL])],
		[_JOIN_INDENTED(1,
			[_INDENT_()[shift]],
			[done])],
	)],
)])


m4_define([_GET_GETOPTS_STRING], [m4_do(
	[m4_lists_foreach_optional([_ARGS_SHORT,_ARGS_CATH], [_arg_short,_arg_type], [m4_case(_arg_type,
		[arg], [_arg_short:],
		[_arg_short])])],
)])


dnl TODO: Don't make this if having only positional args.
m4_define([_MAKE_ARGV_PARSING_FUNCTION_POSIX], [MAKE_FUNCTION(
	[[The parsing of the command-line]],
	[parse_commandline], [m4_do(
		[_JOIN_INDENTED(1,
			[while getopts '_GET_GETOPTS_STRING()' _key],
			[do],
		)],
		[_EVAL_OPTIONALS_GETOPTS],
		[_INDENT_()done[]_ENDL_()],
	)],
)])
