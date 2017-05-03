m4_define([_MAKE_DIE_FUNCTION], [m4_do(
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
	[}],
)])


m4_define([_MAKE_NEXT_OPTARG_FUNCTION], [m4_do(
	[_COMM_BLOCK(0,
		[# Function that evaluates whether a value passed to it],
		[# begins by a character that is a short option of an argument],
		[# the script knows about],
	)],
	[begins_with_short_option()
{
],
	[_JOIN_INDENTED(1,
		[local first_option all_short_options],
		[all_short_options='m4_list_join([_ARGS_SHORT], [])'],
		[first_option="${1:0:1}"],
		[test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0],
)],
	[}
],
)])


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


m4_define([_MAKE_CHECK_POSITIONAL_COUNT_FUNCTION], [m4_do(
	[],
)])
