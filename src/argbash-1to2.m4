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
	# SCRIPT_DIR is likely also a default, but maybe not - it may have been set explicitly
	grep -q '\${\?SCRIPT_DIR' -- "$infname" && echo "You probably use a variable 'SCRIPT_DIR' in your script. It may be that you should rename it to 'script_dir', but this is not certain :-(" >&2
	# We match $_ARG_FOO as well as ${ARG_FOO...
	# and _ARGS_FOO
	sed 's/\(\${\?_ARGS\?_\w\+\)/\L\1\l/g' "$infname"
}

outfname="$_arg_output"
for infname in "${_arg_input[@]}"
do
	test -f "$infname" || { echo "The input parameter has to be a file (got: '$infname')" >&2; exit 1; }

	test -n "$_arg_output" || outfname="$infname"
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
