#!/bin/bash

# shellcheck disable=SC2016,SC2059
# SC2016: Expressions don't expand in single quotes, use double quotes for that.
# SC2059 Don't use variables in the printf format string.


# DEFINE_SCRIPT_DIR
# ARG_POSITIONAL_SINGLE([input], [The input template file (pass '-' for stdin)])
# ARG_OPTIONAL_SINGLE([output], o, [Name of the output file (pass '-' for stdout)], -)
# ARG_OPTIONAL_BOOLEAN([in-place], [i], [Update a bash script in-place], [off])
# ARG_OPTIONAL_SINGLE([type], t, [Output type to generate], [bash-script])
# ARG_OPTIONAL_BOOLEAN([library],, [Whether the input file if the pure parsing library])
# ARG_OPTIONAL_SINGLE([strip],, [Determines what to have in the output], [none])
# ARG_OPTIONAL_BOOLEAN([check-typos],, [Whether to check for possible argbash macro typos], [on])
# ARG_OPTIONAL_BOOLEAN([commented], c, [Commented mode - include explanatory comments with the parsing code], [off])
# ARG_OPTIONAL_REPEATED([search], I, [Directories to search for the wrapped scripts (directory of the template will be added to the end of the list)], ["."])
# ARG_OPTIONAL_SINGLE([debug],, [(developer option) Tell autom4te to trace a macro])
# ARG_TYPE_GROUP_SET([content], [content], [strip], [none,user-content,all])
# ARG_TYPE_GROUP_SET([type], [type], [type], [bash-script,posix-script,manpage,manpage-defs,completion,docopt])
# ARG_DEFAULTS_POS()
# ARG_HELP([Argbash is an argument parser generator for Bash.])
# ARG_VERSION_AUTO([_ARGBASH_VERSION])

# ARGBASH_GO

# [

_files_to_clean=()
cleanup()
{
	test "${#_files_to_clean[*]}" != 0 && rm -f "${_files_to_clean[@]}"
}

# $1: What (string) to pipe to autom4te
run_autom4te()
{
	printf '%s\n' "$1" \
		| autom4te "${DEBUG[@]}" -l m4sugar -I "$m4dir"
	return $?
}


# TODO: Refactor to associative arrays as soon as the argbash online is sufficiently reliable
# We don't use associative arrays due to old bash compatibility reasons
autom4te_error_messages=(
	'end of file in string'
	'end of file in argument list'
)
# the %.s means "null format"
argbash_error_response_stem=(
	'You seem to have an unmatched square bracket on line %d:\n\t%s\n'
	"You seem to have a '(' open parenthesis unmatched by a closing one somewhere above the line %d (%s)\\n"
)

# $1: The error string
# $2: The input (that caused the error)
# $3: The number of the first line of the actual file input by the user
interpret_error()
{
	# print the error, smart stuff may follow
	printf '%s\n' "$1"
	local eof_lineno line_mentioned
	for idx in "${!autom4te_error_messages[@]}"
	do
		eof_lineno="$(printf "%s" "$1" | grep -e "${autom4te_error_messages[$idx]}" | sed -e 's/.*:\([0-9]\+\).*/\1/')"
		if test -n "$eof_lineno"
		then
			line_mentioned="$(printf '%s' "$2" | sed -n "$eof_lineno"p | tr -d '\n\r')"
			printf "${argbash_error_response_stem[$idx]}" "$((eof_lineno - $3))" "$line_mentioned"
		fi
		eof_lineno=''
	done
}

# $1: The input file
# $2: The original intended output file
define_file_metadata()
{
	local _defines='' _intended_destination="$ARGBASH_INTENDED_DESTINATION" _input_dirname _output_dirname
	test -n "$_intended_destination" || _intended_destination="$2"

	_input_dirname="$(dirname "$1")"
	test "$1" != '-' && _defines="${_defines}m4_define([INPUT_BASENAME], [[$(basename "$1")]])"
	_defines="${_defines}m4_define([INPUT_ABS_DIRNAME], [[$(cd "$_input_dirname" && pwd)]])"

	_output_dirname="$(dirname "$_intended_destination")"
	test "$_intended_destination" != '-' && _defines="${_defines}m4_define([OUTPUT_BASENAME], [[$(basename "$_intended_destination" "$SPURIONS_OUTPUT_SUFFIX")]])"
	_defines="${_defines}m4_define([OUTPUT_ABS_DIRNAME], [[$(cd "$_output_dirname" && pwd)]])"
	printf "%s" "$_defines"
}


assert_m4_files_are_readable()
{
	local _argbash_lib="$m4dir/argbash-lib.m4"
	test -d "$m4dir" && test -x "$m4dir" || die "The directory '$m4dir' with files needed by Argbash is not browsable. Check whether it exists and review it's permissions."
	test -r "$_argbash_lib" && test -f "$_argbash_lib" || die "The '$_argbash_lib' file needed by Argbash is not readable. Check whether it exists and review it's permissions."
	test -r "$output_m4" && test -f "$output_m4" || die "The '$output_m4' file needed by Argbash is not readable. Check whether it exists and review it's permissions."
}


# The main function that generates the parsing script body
# $1: The input file
# $2: The output file
# $3: The argument type
do_stuff()
{
	local _pass_also="$_wrapped_defns" input prefix_len _ret
	test "$_arg_commented" = on && _pass_also="${_pass_also}m4_define([COMMENT_OUTPUT])"
	_pass_also="${_pass_also}m4_define([_OUTPUT_TYPE], [[$3]])"
	_pass_also="${_pass_also}$(define_file_metadata "$_arg_input" "$2")"
	input="$(printf '%s\n' "$_pass_also" | cat - "$m4dir/argbash-lib.m4" "$output_m4")"
	prefix_len=$(printf '%s\n' "$input" | wc -l)
	input="$(printf '%s\n' "$input" | cat - "$1")"
	run_autom4te "$input" 2> "$discard" \
		| grep -v '^#\s*needed because of Argbash -->\s*$' \
		| grep -v '^#\s*<-- needed because of Argbash\s*$'
	_ret=$?
	if test $_ret != 0
	then
		local errstr
		errstr="$(run_autom4te "$input" 2>&1 > "$discard")"
		interpret_error "$errstr" "$input" "$prefix_len" >&2
		echo "Error during autom4te run, aborting!" >&2;
		exit $_ret;
	fi
	return "$_ret"
}

# Fills content to variable _wrapped_defns --- where are scripts of given stems
# $1: Infile
# $2: Stem - what should be the umbrella of the args
settle_wrapped_fname()
{
	# Get arguments to ARGBASH_WRAP
	# Based on http://stackoverflow.com/a/19772067/592892
	local _srcfiles=() _file_found _found ext srcstem searchdir line stem="$2"
	while read -r line; do
		_srcfiles+=("$line")
	done < <(echo 'm4_changecom()m4_define([ARGBASH_WRAP])' "$(cat "$1")" \
			| autom4te -l m4sugar -t 'ARGBASH_WRAP:$1' 2> "$discard")

	test "${#_srcfiles[@]}" -gt 0 || return
	for srcstem in "${_srcfiles[@]}"
	do
		_found=no
		for searchdir in "${_arg_search[@]}"
		do
			test -f "$searchdir/$srcstem.m4" && { _found=yes; ext='.m4'; break; }
			test -f "$searchdir/$srcstem.sh" && { _found=yes; ext='.sh'; break; }
			test -f "$searchdir/$srcstem" && { _found=yes; ext=''; break; }
		done
		# The last searchdir is a correct one
		test $_found = yes || die "Couldn't find wrapped file of stem '$srcstem' in any of directories: ${_arg_search[*]}" 2
		_file_found="$searchdir/${srcstem}${ext}"
		stem=${2:-$srcstem}
		settle_wrapped_fname "$_file_found" "$stem"
		_wrapped_defns="${_wrapped_defns}m4_define([_GROUP_OF_$srcstem], [[$stem]])m4_define([_SCRIPT_$srcstem], [[$_file_found]])"
	done
}

# If we want to have the parsing code in a separate file,
# 1. Find out the (possible) filename
# 2. If the file exists, finish (OK).
# 3. If the .m4 file exists, finish (OK)
# 4. Something is wrong
get_parsing_code()
{
	local _shfile _m4file _newerfile
	# Get the argument of INCLUDE_PARSING_CODE
	_srcfile="$(echo 'm4_changecom()m4_define([INCLUDE_PARSING_CODE])' "$(cat "$infile")" \
			| autom4te -l m4sugar -t 'INCLUDE_PARSING_CODE:$1' 2> "$discard" \
			| tail -n 1)"
	test -n "$_srcfile" || return 1
	_thatfile="$(dirname "$infile")/$_srcfile"
	test -f "$_thatfile" && _shfile="$_thatfile"
	# Take out everything after last dot (http://stackoverflow.com/questions/125281/how-do-i-remove-the-file-suffix-and-path-portion-from-a-path-string-in-bash)
	_thatfile="${_thatfile%.*}.m4"
	test -f "$_thatfile" && _m4file="$_thatfile"

	# if have neither of files
	test -z "$_shfile" && test -z "$_m4file" && echo "Strange, we think that there was a source file '$_srcfile' that should be included, but we haven't found it in directory '$(dirname "$_thatfile")'" >&2 && return 1
	# We have one file, but not the other one => decision of what to pick is easy.
	test -z "$_shfile" && test -n "$_m4file" && echo "$_m4file" && return
	test -n "$_shfile" && test -z "$_m4file" && echo "$_shfile" && return

	# We have both, so we pick up the newer one
	_newerfile="$_shfile"
	test "$_m4file" -nt "$_shfile" && _newerfile="$_m4file"
	echo "$_newerfile"
}


# $1: The output file
# $2: The output type string
set_output_permission()
{
	if grep -q '\<script\>' <<< "$2"
	then
		chmod a+x "$1"
	fi
}


# MS Windows compatibility fix
discard=/dev/null
test -e $discard || discard=NUL

set -o pipefail

infile="$_arg_input"

trap cleanup EXIT
# If we are reading from stdout, then create a temp file
if test "$infile" = '-'
then
	if test "$_arg_in_place" = 'on'
	then
		echo "Cannot use stdin input with --in-place option!" >&2
		exit 1;
	fi
	infile=temp_in_$$
	_files_to_clean+=("$infile")
	cat > "$infile"
fi

m4dir="$script_dir/../src"
test -n "$_arg_debug" && DEBUG=('-t' "$_arg_debug")

output_m4="$m4dir/output-strip-none.m4"
test "$_arg_library" = "on" && { echo "The --library option is deprecated, use --strip user-content" next time >&2; _arg_strip="user-content"; }
if test "$_arg_strip" = "user-content"
then
	output_m4="$m4dir/output-strip-user-content.m4"
elif test "$_arg_strip" = "all"
then
	output_m4="$m4dir/output-strip-all.m4"
fi

test -f "$infile" || _PRINT_HELP=yes die "argument '$infile' is supposed to be a file!" 1
if test "$_arg_in_place" = on
then
	_arg_output="$infile"
fi
test -n "$_arg_output" || { echo "The output can't be blank - it is not a legal filename!" >&2; exit 1; }
outfname="$_arg_output"
autom4te --version > "$discard" 2>&1 || { echo "You need the 'autom4te' utility (it comes with 'autoconf'), if you have bash, that one is an easy one to get." 2>&1; exit 1; }
_arg_search+=("$(dirname "$infile")")
_wrapped_defns=""

# So let's settle the parsing code first. Hopefully we won't create a loop.
parsing_code="$(get_parsing_code)"
# Just if the original was m4, we replace .m4 with .sh
test -n "$parsing_code" && parsing_code_out="${parsing_code:0:-2}sh"
test "$_arg_library" = off && test -n "$parsing_code" && ($0 --strip user-content "$parsing_code" -o "$parsing_code_out")

# We may use some of the wrapping stuff, so let's fill the _wrapped_defns
settle_wrapped_fname "$infile"

assert_m4_files_are_readable
output="$(do_stuff "$infile" "$outfname" "$_arg_type")" || die "" "$?"
if test "$_arg_check_typos" = on
then
	# match against suspicious, then inverse match against correct stuff:
	# #<optional whitespace>\(allowed\|another allowed\|...\)<optional whitespace><opening bracket <or> end of line>
	# Then, extract all matches (assumed to be alnum chars + '_') from grep and put them in the error msg.
	grep_output="$(printf "%s" "$output" | grep '^#\s*\(ARG_\|ARGBASH\)' | grep -v '^#\s*\(]m4_set_contents([_KNOWN_MACROS], [\|])[\)\s*\((\|$\)' | sed -e 's/#\s*\([[:alnum:]_]*\).*/\1 /' | tr -d '\n\r')"
	test -n "$grep_output" && die "Your script contains possible misspelled Argbash macros: $grep_output" 1
fi
if test "$outfname" != '-'
then
	printf "%s\\n" "$output" > "$outfname"
	set_output_permission "$outfname" "$_arg_type"
else
	printf "%s\\n" "$output"
fi

# ]dnl
dnl vim: filetype=sh
