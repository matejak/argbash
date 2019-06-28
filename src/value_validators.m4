m4_include_once([function_generators.m4])

dnl
dnl Define a validator for a particular type. Instead of using m4_define, use this:
dnl $1: The type ID
dnl $2: The validator body (a shell function accepting $1 - the value, $2 - the argument name)
dnl $3: The type description
m4_define([_define_validator], [m4_do(
	[m4_set_contains([VALUE_TYPES], [$1], [m4_fatal([We already have the validator for '$1'.])])],
	[m4_set_add([VALUE_TYPES], [$1])],
	[m4_define([_validator_$1], [$2])],
	[m4_define(__type_str([$1]), [[$3]])],
)])


dnl
dnl Put definitions of validating functions if they are needed
m4_define([_PUT_VALIDATORS], [m4_do(
	[m4_set_empty([VALUE_TYPES_USED], , [m4_n([# validators])])],
	[m4_set_foreach([VALUE_TYPES], [_val_type], [m4_do(
		[m4_set_empty(m4_expand([[VALUE_GROUP_]_val_type]), ,
			m4_expand([_ENDL_()[_validator_]_val_type[]_ENDL_(2)]))],
	)])],
)])


dnl
dnl Define an int validator
dnl double quoting is important because of the [] group inside
_define_validator([int],
[[int()
{
	printf "%s" "@S|@1" | grep -q '^\s*[+-]\?[0-9]\+\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not an integer."
	printf "%d" "@S|@1"
}]], [integer])


dnl Define a positive int validator
_define_validator([pint],
[[pint()
{
	printf "%s" "@S|@1" | grep -q '^\s*[+]\?0*[1-9][0-9]*\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not a positive integer."
	printf "%d" "@S|@1"
}]], [positive integer])


dnl Define a non-negative int validator
_define_validator([nnint],
[[nnint()
{
	printf "%s" "@S|@1" | grep -q '^\s*+\?[0-9]\+\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not a non-negative integer."
	printf "%d" "@S|@1"
}]], [positive integer or zero])


dnl Define a float number validator
_define_validator([float],
[[float()
{
	printf "%s" "@S|@1" | grep -q '^\s*[+-]\?[0-9]\+(\.[0-9]\+(e[0-9]\+)?)?\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not a floating-point number."
	printf "%d" "@S|@1"
}]], [floating-point number])


dnl Define a decimal number validator
_define_validator([decimal],
[[decimal()
{
	printf "%s" "@S|@1" | grep -q '^\s*[+-]\?[0-9]\+(\.[0-9]\+)?\s*$' || die "The value of argument '@S|@2' is '@S|@1', which is not a plain-old decimal number."
	printf "%d" "@S|@1"
}]], [decimal number])


dnl The string validator is a null validator
_define_validator([string])


dnl
dnl Factory macro - makes _FLAGS_D_IF etc. macros
m4_define([_FLAGS_WHATEVER_IF_FACTORY],
	[m4_define([_FLAGS_$1_IF], [m4_bmatch(m4_quote($][1), [$1], m4_dquote($][2), m4_dquote($][3))])])
_FLAGS_WHATEVER_IF_FACTORY(D)
_FLAGS_WHATEVER_IF_FACTORY(R)
_FLAGS_WHATEVER_IF_FACTORY(W)
_FLAGS_WHATEVER_IF_FACTORY(X)


dnl
dnl $1: FLAGS: Any of RWXD, default is nothing (= an existing file)
m4_define([_MK_VALIDATE_FNAME_FUNCTION], [m4_do(
	[m4_pushdef([_fname], [[validate_file_$1]])],
	[dnl Maybe we already have requested this function
],
	[m4_list_contains([_VALIDATE_FILE], _fname, , [m4_do(
		[m4_list_append([_VALIDATE_FILE], _fname)],
		[MAKE_BASH_FUNCTION(,
			[_fname],
			[_JOIN_INDENTED(1,
				[_FLAGS_D_IF([$1], [m4_do(
					[m4_pushdef([_what], [[directory]])],
					[m4_pushdef([_xperm], [[browsable directory]])],
					[[test -d "@S|@1" || die "Argument '@S|@2' has to be a directory, got '@S|@1'" 4]],
					)], [m4_do(
					[m4_pushdef([_what], [[file]])],
					[m4_pushdef([_xperm], [[executable file]])],
					[[test -f "@S|@1" || die "Argument '@S|@2' has to be a file, got '@S|@1'" 4]],
				)])],
				[_FLAGS_R_IF([$1], [[test -r "@S|@1" || { echo "Argument '@S|@2' has to be a readable ]_what[, '@S|@1' isn't."; return 4; }]])],
				[_FLAGS_W_IF([$1], [[test -w "@S|@1" || { echo "Argument '@S|@2' has to be a writable ]_what[, '@S|@1' isn't."; return 4; }]])],
				[_FLAGS_X_IF([$1], [[test -x "@S|@1" || { echo "Argument '@S|@2' has to be a ]_xperm[, '@S|@1' isn't."; return 4; }]])],
			)])],
	)])],
	[m4_popdef([_fname])],
)])


dnl
dnl TODO: What about defaults? We want defaults to be valid values, but maybe the blank argument is an exception --- if an optional argument has blank default, its propagated value should be OK even if it is still blank, but maybe we don't want users to be told to supply blank values...
dnl Given a arg type ID, it treats as a group type and creates a function to examine whether the value is in the list.
dnl $1: The group stem
dnl $2: If blank, don't bother with the index recording functionality
dnl
dnl The bash function accepts:
dnl $1: The value to check
dnl $2: What was the option that was associated with the value
m4_define([_MK_VALIDATE_GROUP_FUNCTION], [MAKE_BASH_FUNCTION(,
	[$1],
	[_JOIN_INDENTED(1,
		[for element in "${_allowed@<:@@@:>@}"],
		[do],
		m4_ifnblank([$2],
			[[_INDENT_()test "$element" = "$_seeking" && { test "@S|@3" = "idx" && echo "$_idx" || echo "$element"; } && return 0],
			 [_INDENT_()_idx=$((_idx + 1))],],
			[[_INDENT_()test "$element" = "$_seeking" && echo "$element" && return 0],])
		[done],
		[die "Value '$_seeking' (of argument '@S|@2') doesn't match the list of allowed values: m4_list_join([_LIST_$1], [, ], ', ', [ and ])" 4],
	)],
	[_allowed=(m4_list_join([_LIST_$1_QUOTED], [ ]))],
	[_seeking="@S|@1"],
	m4_ifnblank([$2], [[_idx=0],],),
)])


dnl
dnl Given an optional argument name, it queries whether the value can be validated and emits a line if so.
m4_define([_MAYBE_VALIDATE_VALUE_OPT], [m4_do(
	[],
)])
