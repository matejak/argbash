#!/bin/bash

# shellcheck disable=SC2016
# SC2016: Expressions don't expand in single quotes, use double quotes for that.

version=_ARGBASH_VERSION
# ARG_POSITIONAL_INF([input], [The input file to transform], 1)
# ARG_OPTIONAL_SINGLE([output], o, [Name of the output file (pass '-' for stdout and empty string for the same as input file)], "")
# ARG_VERSION([echo "argbash-1to2 v$version"])
# ARG_HELP([Convert a template for argbash>=1,<2 to argbash>=2,<3])

# ARGBASH_GO

# [

_files_to_clean=()
cleanup()
{
	test "${#_files_to_clean[*]}" != 0 && rm -f "${_files_to_clean[@]}"
}

do_stuff ()
{
	# SCRIPT_DIR is likely also a default, but maybe not - it may have been set explicitly
	grep -q '\${\?SCRIPT_DIR' -- "$infname" && echo "You probably use a variable 'SCRIPT_DIR' in your script. It may be that you should rename it to 'script_dir', but this is not certain :-(" >&2
	# We match $_ARG_FOO as well as ${ARG_FOO...
	# and _ARGS_FOO
	sed 's/\(\${\?_ARGS\?_\w\+\)/\L\1\l/g' "$infname"
}

outfname="$_arg_output"
test "${#infname[@]}" -gt 1 && test -n "$outfname" && die "You have specified more than one (${#infname[@]}) input filenames, so you probably want to modify the corresponding files in-place. In order to do so, you can't specify an output filename, even '-' does make no sense (currently: '$outfname')"

trap cleanup EXIT
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
		_files_to_clean+=("$temp_outfile")
		do_stuff > "$temp_outfile"
		mv "$temp_outfile" "$outfname"
		# So we don't make .m4 scripts executable
		chmod --reference "$infname" "$outfname"
	fi
done

# ]dnl

dnl vim: filetype=sh
