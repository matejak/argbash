
m4_set_delete([__FILES_ALREADY_INCLUDED__])
m4_set_add([__FILES_ALREADY_INCLUDED__], __file__)
dnl
dnl $1: The filename to include
m4_define([m4_include_once], [m4_do(
	[m4_set_contains([__FILES_ALREADY_INCLUDED__], [$1], [], 
		[m4_set_add([__FILES_ALREADY_INCLUDED__], [$1])m4_include([$1])])],
)])


m4_include_once([list.m4])


m4_define([_ENDL_],
	[m4_for(_, 1, m4_default([$1], 1), 1, [
])])

m4_define([_IF_DIY_MODE],
	[m4_if(_DIY_MODE, 1, [$1], [$2])])


m4_define([_IF_HAVE_POSITIONAL_ARGS],
	[m4_if(HAVE_POSITIONAL, 1, [$1], [$2])])


m4_define([_IF_SOME_POSITIONAL_VALUES_ARE_EXPECTED],
	[m4_if(_MINIMAL_POSITIONAL_VALUES_COUNT, 0, [$2], [$1])])


m4_define([_IF_HAVE_OPTIONAL_ARGS],
	[m4_if(HAVE_OPTIONAL, 1, [$1], [$2])])


dnl
dnl Get the last component of a filename
m4_define([_GET_BASENAME],
	[m4_bpatsubst([$1], [.*/\([^/]+\)], [\1])])


dnl
dnl The helper macro for _CHECK_INTEGER_TYPE
dnl $1: The caller name
dnl $2: The arg position
dnl $3: The arg value
dnl $4: The error message (optional)
m4_define([__CHECK_INTEGER_TYPE], [[m4_do(
	[m4_bmatch([$2], [^[0-9]+$], ,
		[m4_fatal([The ]m4_case([$3], 1, 1st, 2, 2nd, 3, 3rd, $3th)[ argument of '$1' has to be a number]m4_ifnblank([$4], [[ ($4)]])[, got '$2'])])],
)]])


dnl
dnl Checks that the n-th argument is an integer.
dnl Should be called upon the macro definition outside of quotes, e.g. m4_define([FOO], _CHECK_INTEGER_TYPE(1)[m4_eval(2 + $1)])
dnl $1: The argument number
dnl $2: The error message (optional)
m4_define([_CHECK_INTEGER_TYPE],
	[__CHECK_INTEGER_TYPE([$][0], m4_quote($][$1), [$1], m4_quote($][2))])


dnl
dnl If first char of string is not ' or " enclose it into ""
dnl and escape " with \".
dnl
dnl The string is also []-quoted
dnl Property: Quoting a blank input results in blank result
dnl to AVOID it, pass string like ""ls -l or "ls" -l
dnl
dnl $1: String to quote
m4_define([_sh_quote], [m4_do(
	[m4_if(
		[$1], , ,
		m4_dquote(_sh_quote_also_blanks([$1])))],
)])


dnl
dnl Same as _sh_quote, except quoting a blank input results in pair of quotes
dnl $1: String to quote
m4_define([_sh_quote_also_blanks], [m4_do(
	[m4_if(
		m4_index([$1], [']), 0, [[$1]],
		m4_index([$1], ["]), 0, [[$1]],
		[["$1"]])],
)])

dnl
dnl Define a macro that is part of the public API
dnl Ensure the replication and also add the macro name to a list of allowed macros
m4_define([argbash_api], [_argbash_persistent([$1], [$2])])
m4_define([_argbash_persistent], [m4_set_add([_KNOWN_MACROS],[$1])m4_define([$1], [$2])])

m4_define([argbash_arg_api], [m4_do(
	[_argbash_api([$1], [_CHECK_PASSED_ARGS_COUNT([$2], [$3])[[m4_do(
		[_CHECK_ARGUMENT_NAME_IS_VALID([$1])],
		[m4_list_contains([BLACKLIST], m4_quote($][1), , m4_dquote([$1($][@)])$4)],
	)]])]],
)])

dnl
dnl $1: this comm block ID
dnl $2: where it is defined
dnl $3: indentation
dnl $4, ....: comment lines
dnl
dnl If the comment ID has been defined earlier, don't display the comment, but point to the definition.
dnl Otherwise, act like _COMM_BLOCK
m4_define([_POSSIBLY_REPEATED_COMMENT_BLOCK], [m4_ifndef([_COMMENT_$1_LOCATION], [m4_do(
	[m4_define([_COMMENT_$1_LOCATION], [[$2]])],
	[_COMM_BLOCK($3, m4_shiftn(3, $@))],
)], [m4_do(m4_ifblank([$2], ,
		[_COMM_BLOCK([$3], m4_quote([# ]m4_indir([_COMMENT_$1_LOCATION])))]),
)])])


m4_define([_COMMENT_PREFIX_NOTHING], [[$1],])
m4_define([_COMMENT_PREFIX_HASH], [[# $1],])


m4_define([_COMM_BLOCK], [__COMM_BLOCK([_COMMENT_PREFIX_NOTHING], $@)])
m4_define([_COMM_BLOCK_HASH], [__COMM_BLOCK([_COMMENT_PREFIX_HASH], $@)])

m4_define([_IF_COMMENTED_OUTPUT], [m4_ifdef([COMMENT_OUTPUT], [[$1]], [[$2]])])
m4_define([__COMM_BLOCK], _CHECK_INTEGER_TYPE(2, [depth of indentation])[m4_ifdef([COMMENT_OUTPUT], [_JOIN_INDENTED([$2], m4_map_args([$1], m4_shiftn(2, m4_dquote_elt($@))))])])
m4_define([_COMMENT_CHAIN], [m4_ifdef([COMMENT_OUTPUT], [$@])])
m4_define([_COMMENT], [m4_ifdef([COMMENT_OUTPUT], [$1])])


dnl
dnl $1: The text to substitute
dnl The indentation is a display indentation - not source code one.
m4_define([_SUBSTITUTE_LF_FOR_NEWLINE_WITH_DISPLAY_INDENT_AND_ESCAPE_DOUBLEQUOTES],
	[SUBSTITUTE_LF_FOR_NEWLINE_WITH_INDENT_AND_ESCAPE_DOUBLEQUOTES([$1], [		])])


dnl
dnl $1: The text to substitute
dnl $2: The width of space indentation
dnl The indentation is a display indentation - not source code one.
m4_define([_SUBSTITUTE_LF_FOR_NEWLINE_WITH_SPACE_INDENT_AND_ESCAPE_DOUBLEQUOTES],
	[SUBSTITUTE_LF_FOR_NEWLINE_WITH_INDENT_AND_ESCAPE_DOUBLEQUOTES([$1], m4_if([$2], 0, [], [m4_for(_, 1, [$2], 1, [ ])]))])


dnl
dnl $1: The text to substitute
dnl $2: The indent for the new line.
dnl Regexp: Find beginning of backslashes, match for pairs, and if \\n is left, then substitute it for literal newline.
dnl The indentation is a display indentation - not source code one.
m4_define([SUBSTITUTE_LF_FOR_NEWLINE_WITH_INDENT_AND_ESCAPE_DOUBLEQUOTES],
	[m4_bpatsubsts([[$1]], 
		[\([^\\]\)\(\\\\\)*\\n], m4_expand([[\1\2]_ENDL_()$2]),
		[\([^\]\)"], [\1\\"])])


m4_define([_CHECK_PASSED_ARGS_COUNT_TOO_FEW],
	[m4_fatal([You have passed $2 arguments to macro $1, while it requires at least $3.]m4_ifnblank([$4], [ Call it like: $4]))])


m4_define([_CHECK_PASSED_ARGS_COUNT_TOO_MANY],
	[m4_fatal([You have passed $2 arguments to macro $1, while it accepts at most $3.]m4_ifnblank([$4], [ Call it like: $4]))])

dnl
dnl $1: Name of the macro
dnl $2: The actual argc
dnl $3: argc lower bound
dnl $4: argc upper bound
dnl $5: The calling signature
m4_define([__CHECK_PASSED_ARGS_COUNT], [[m4_do(
	[m4_pushdef([_maybe_signature_$1], [m4_ifnblank([$5], [[$1($5)]])])],
	[m4_if(
		m4_eval($2 < $3), 1, [_CHECK_PASSED_ARGS_COUNT_TOO_FEW([$1], [$2], [$3], m4_quote(m4_indir([_maybe_signature_$1])))],
		m4_eval($2 > $4), 1, [_CHECK_PASSED_ARGS_COUNT_TOO_MANY([$1], [$2], [$4], m4_quote(m4_indir([_maybe_signature_$1])))],
	)],
	[m4_popdef([_maybe_signature_$1])],
)]])


dnl Check thath the correct number of arguments has been passed, and display the calling signature if it is not the case
dnl $1: The minimal amount of args > 0 (due to m4's $# behaior)
dnl $2: The highest possible arguments count (optional, defaults to no upper bound behavior)
dnl $3: The arguments part of the calling signature (optional)
m4_define([_CHECK_PASSED_ARGS_COUNT], m4_if([$1], 0, [m4_fatal([The minimal amount of args must be non-negative.])])[__CHECK_PASSED_ARGS_COUNT([$]0, $[#], [$1], m4_default([$2], [$[#]]), [$3])])


dnl
dnl
dnl Blank args to this macro are totally ignored, use @&t@ to get over that --- @&t@ is a quadrigraph that expands to nothing in the later phase
dnl $1: How many indents
dnl $2, $3, ...: What to put there
m4_define([_JOIN_INDENTED], _CHECK_INTEGER_TYPE(1, [depth of indentation])[m4_do(
	[m4_pushdef([_current_indentation_level], [$1])],
	[m4_foreach([line], [m4_shift($@)], [m4_ifnblank(m4_quote(line), _INDENT_([$1])[]m4_dquote(line)
)])],
	[m4_popdef([_current_indentation_level])],
)])


dnl
dnl $1, $2, ...: What to put there
dnl
dnl Takes arguments, returns them, but there is an extra _INDENT_() in the beginning of them
m4_define([_INDENT_MORE], [m4_do(
	[m4_list_ifempty([_TLIST], , [m4_fatal([Internal error: List '_TLIST' should be empty, contains ]m4_list_contents([_TLIST])[ instead])])],
	[m4_foreach([line], [$@], [m4_list_append([_TLIST], m4_expand([_INDENT_()line]))])],
	[m4_list_contents([_TLIST])],
	[m4_list_destroy([_TLIST])],
)])


m4_define([_SET_INDENT], [__SET_INDENT([$1], $[]1)])


dnl
dnl defines _INDENT_
dnl $1: How many times to indent (default 1)
dnl $2, ...: Ignored, but you can use those to make the code look somewhat better.
m4_define([__SET_INDENT], [m4_define([_INDENT_], [m4_if([$2], 0, ,
	[m4_for(_, 1, m4_default([$2], 1), 1,
		[[$1]])])])])


dnl
dnl Sets the indentation character(s) in the parsing code
dnl $1: The indentation character(s)
argbash_api([ARGBASH_SET_INDENT],
	[m4_bmatch(m4_expand([_W_FLAGS]), [I], ,[[$0($@)]_SET_INDENT([$1])])])


m4_define([m4_lists_foreach_optional], [m4_lists_foreach([$1][,_ARGS_POS_OR_OPT], [$2][,_arg_pos_or_opt], [m4_if(_arg_pos_or_opt, optional, [$3])])])
m4_define([m4_lists_foreach_positional], [m4_lists_foreach([$1][,_ARGS_POS_OR_OPT], [$2][,_arg_pos_or_opt], [m4_if(_arg_pos_or_opt, positional, [$3])])])


m4_define([_ASSIGN_VALUE_TO_VAR], [[$3=]_MAYBE_VALIDATE_VALUE([$1], [$2])_IF_ARG_IS_TYPED([$1], [ || exit 1])])
m4_define([_APPEND_VALUE_TO_ARRAY], [[$3+=](_MAYBE_VALIDATE_VALUE([$1], [$2]))_IF_ARG_IS_TYPED([$1], [ || exit 1])])
dnl m4_define([_ASSIGN_VALUE_TO_VAR], [[$2="$1"]])
dnl m4_define([_APPEND_VALUE_TO_ARRAY], [[$2+=("$1")]])


dnl Do something depending on whether there is already infinitely many args possible or not
m4_define([IF_POSITIONALS_INF],
	[m4_if(m4_quote(_POSITIONALS_INF), 1, [$1], [$2])])


dnl Do something depending on whether there have been optional positional args declared beforehand or not
m4_define([IF_VARIABLE_NUMBER_OF_ARGUMENTS_BEFOREHAND],
	[m4_if(m4_quote(HAVE_POSITIONAL_VARNUM), 1, [$1], [$2])])


dnl
dnl Output some text depending on what strict mode we find ourselves in
m4_define([_CASE_RESTRICT_VALUES], [m4_case(_RESTRICT_VALUES,
	[none], [$1],
	[no-local-options], [$2],
	[no-any-options], [$3])])


dnl
dnl A very private macro --- return name of the macro containing description for the given type ID
dnl $1: Type ID
m4_define([__type_str], [[_type_str_$1]])

dnl
dnl Return type description for the given argname
dnl $1: Argument ID
m4_define([_GET_VALUE_DESC], [m4_expand(__type_str(_GET_VALUE_TYPE([$1])))])

dnl
dnl Given an argname, return the argument group name (i.e. type string) or 'arg'
dnl
dnl $1: argname
m4_define([_GET_VALUE_STR], [m4_do(
	[m4_ifdef([$1_VAL_GROUP], [m4_indir([$1_VAL_GROUP])], [arg])],
)])


m4_define([DEFINE_MINIMAL_POSITIONAL_VALUES_COUNT],
	[m4_if(m4_cmp(0, m4_list_len([_POSITIONALS_MINS])), 1,
		m4_define([_MINIMAL_POSITIONAL_VALUES_COUNT], [m4_list_sum(_POSITIONALS_MINS)]))])


dnl $1: Error
m4_define([INFERRED_BASENAME],
	[m4_ifdef([OUTPUT_BASENAME], [_STRIP_SUFFIX(OUTPUT_BASENAME)],
		[m4_ifdef([INPUT_BASENAME], [[_STRIP_SUFFIX(INPUT_BASENAME)]], [$1])])])


m4_define([INFERRED_BASENAME_NOERROR],
	[INFERRED_BASENAME([m4_errprintn([We need to know the basename, and we couldn't infer it, so we resort to generic 'script'. It is likely that you read from stdin and write to stdout, please prefer to use at least one filename either for input or for output.])[[script]]])])


dnl
dnl \1: The name and leading [
dnl \2: The ending ] (group regexp is complicated because square brackets have to match. For reference, [][]* matches for zero or more [ or ])
m4_define([_STRIP_SUFFIX], [m4_bpatsubst([[$1]], [\(.*\)\.m4\([][]*\)$], [\1\2])])


dnl
dnl $1: List name
m4_define([_LIST_LONGEST_TEXT_LENGTH], [m4_do(
	[m4_pushdef([_longest_label_len], 0)],
	[m4_list_foreach([$1], [_item], [m4_if(m4_eval(_longest_label_len < m4_len(_item)), 1, [m4_define([_longest_label_len], m4_len(_item))])])],
	[_longest_label_len],
	[m4_popdef([_longest_label_len])],
)])


m4_define([_CAPITALIZE], [m4_translit([[$1]], [a-z], [A-Z])])


dnl
dnl $1: What to underline
dnl $2: By what to underline
dnl $3: By what to overline (optional)
m4_define([UNDERLINE], [m4_do(
	[m4_if(m4_len([$1]), 0, , [m4_if([$3], , , [m4_do(
		[m4_for(idx, 1, m4_len([$1]), 1, [$3])],
		[_ENDL_()],
	)])])],
	[[$1]],
	[_ENDL_()],
	[m4_if(m4_len([$1]), 0, ,
		[m4_for(idx, 1, m4_len([$1]), 1, [$2])])],
)])
