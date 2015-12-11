#!/bin/bash

VERSION=_ARGBASH_VERSION
# DEFINE_SCRIPT_DIR
# ARG_POSITIONAL_SINGLE([input], [The input template file])
# ARG_OPTIONAL_SINGLE([output], o, [Name of the output file (pass '-' for stdout)], -)
# ARG_OPTIONAL_BOOLEAN([standalone],, [Whether the parsing code is in a standalone file.])
# ARG_VERSION([echo "argbash v$VERSION"])
# ARG_HELP([Argbash is an argument parser generator for Bash.])

# ARGBASH_GO

# [

# MS Windows compatibility fix
DISCARD=/dev/null
test -e $DISCARD || DISCARD=NUL

set -o pipefail

INFILE="$_ARG_INPUT"

M4DIR="$SCRIPT_DIR/../src"

OUTPUT_M4="$M4DIR/output.m4"
test "$_ARG_STANDALONE" = "on" && OUTPUT_M4="$M4DIR/output-standalone.m4"

function do_stuff
{
	cat $M4DIR/stuff.m4 "$OUTPUT_M4" "$INFILE" > temp
	# cat $M4DIR/stuff.m4 "$OUTPUT_M4" "$INFILE" \
	#	| autom4te -l m4sugar -I "$M4DIR" \
		autom4te -l m4sugar -I "$M4DIR" temp \
		| grep -v '^#\s*needed because of Argbash -->\s*$' \
		| grep -v '^#\s*<-- needed because of Argbash\s*$'
	_ret=$?
	test $_ret = 0 || {  echo "Error during autom4te run, aborting!" >&2; exit $_ret; }
}

test -f "$INFILE" || { echo "'$INFILE' is supposed to be a file!"; exit 1; }
test -n "$_ARG_OUTPUT" || { echo "The output can't be blank - it is not a legal filename!"; exit 1; }
OUTFILE="$_ARG_OUTPUT"
autom4te --version > $DISCARD 2>&1 || { echo "You need the 'autom4te' utility (it comes with 'autoconf'), if you have bash, that one is an easy one to get." 2>&1; exit 1; }

function get_parsing_code
{
	_srcfile="$(echo 'm4_changecom()m4_define([INCLUDE_PARSING_CODE])' $(cat "$INFILE") \
			| autom4te -l m4sugar -t 'INCLUDE_PARSING_CODE:$1' \
			| tail -n 1)"
	test -n "$_srcfile" || return 1
	_thatfile="$(dirname "$INFILE")/$_srcfile"
	test -f "$_thatfile" && echo $_thatfile && return
	# Take out everything after last dot (http://stackoverflow.com/questions/125281/how-do-i-remove-the-file-suffix-and-path-portion-from-a-path-string-in-bash)
	_thatfile="${_thatfile%.*}.m4"
	test -f "$_thatfile" && echo $_thatfile && return
	# if we are here, we are out of luck
	test -n "$_srcfile" && echo "Strange, we think that there was a source file '$_srcfile' that should be included, but we haven't found it in directory '$(dirname "$_thatfile")'" >&2 && return 1
}

# So let's settle the parsing code first. Hopefully we won't create a loop.
parsing_code="$(get_parsing_code)"
# Just if the original was m4, we replace .m4 with .sh
test -n "$parsing_code" && parsing_code_out="${parsing_code:0:-2}sh"
test "$_ARG_STANDALONE" = off && test -n "$parsing_code" && ($0 --standalone "$parsing_code" -o "$parsing_code_out")

if test "$OUTFILE" = '-'
then
	do_stuff
else
	# vvv This should catch most of the cases when we want to overwrite the source file vvv
	if test "$OUTFILE" = "$INFILE"
	then
		TEMP_OUTFILE=temp_$$
		trap "rm -f $TEMP_OUTFILE" EXIT
		do_stuff > "$TEMP_OUTFILE"
		mv "$TEMP_OUTFILE" "$OUTFILE"
	else
		do_stuff > "$OUTFILE"
	fi
	chmod a+x "$OUTFILE"
fi

# ]
