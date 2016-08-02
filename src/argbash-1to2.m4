#!/bin/bash

version=_ARGBASH_VERSION
# DEFINE_SCRIPT_DIR
# ARG_POSITIONAL_INF([input], [The input file to transform], 1)
# ARG_OPTIONAL_SINGLE([output], o, [Name of the output file (pass '-' for stdout and empty string for the same as input file)], "")
# ARG_HELP([Convert a template for argbash<2 to argbash>=2,<3])

# ARGBASH_GO

# [

do_stuff ()
{
	sed 's/\(_ARG_\w\+\)/\L\1\l/g' "$_ARG_INPUT"
}

outfname="$_ARG_OUTPUT"
for infname in "${_ARG_INPUT[@]}"
do
	test -f "$infname" || die "The input parameter has to be a file (got: '$infname')"

	test -n "$_ARG_OUTPUT" || outfname="$infname"
	if test "$outfname" = '-'
	then
		do_stuff
	else
		# vvv This should catch most of the cases when we want to overwrite the source file
		# vvv and we don't want to leave a file (not even an empty one) when something goes wrong.
		temp_outfile="temp_$$"
		trap "rm -f $temp_outfile" EXIT
		do_stuff > "$temp_outfile"
		mv "$temp_outfile" "$outfname"
		chmod a+x "$outfname"
	fi
done

# ]dnl

dnl vim: filetype=sh
