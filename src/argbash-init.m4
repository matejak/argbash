#!/bin/bash

# shellcheck disable=SC2001,SC2016
# SC2001: See if you can use ${variable//search/replace} instead.
# SC2016: Expressions don't expand in single quotes, use double quotes for that.

version=_ARGBASH_VERSION
# ARG_POSITIONAL_SINGLE([output], [Name of the output template], [-])
# ARG_OPTIONAL_INCREMENTAL([separate], s, [Separate the parsing logic (specify two times for complete separation)])
# ARG_OPTIONAL_BOOLEAN([hints], ,[Whether to write hints to the script template])
# ARG_OPTIONAL_REPEATED([pos], , [Add a single-valued positional argument])
# ARG_OPTIONAL_REPEATED([opt], , [Add an single-valued optional argument])
# ARG_OPTIONAL_REPEATED([opt-bool], ,[Add an optional boolean argument])
# ARG_OPTIONAL_REPEATED([wrap], ,[What script(s) to wrap])
# ARG_OPTIONAL_SINGLE([mode], m, [The slider between feature-rich and simple script.], [default])
# ARG_TYPE_GROUP_SET([mode], [MODE], [mode], [default,full,minimal])
# ARG_VERSION([echo "argbash-init v$version"])
# ARG_HELP([Make a template for scripts.])

# ARGBASH_GO[


_variables=()
HAVE_POSITIONAL_ARG=no


# This should be in sync with _translit_var in stuff.m4
_translit_var()
{
	printf "\$_arg_%s" "$1" | tr '[:upper:]' '[:lower:]' | tr '-' '_'
}


optional_argument_without_hints()
{
	echo "# ARG_OPTIONAL_SINGLE([$1])"
}


optional_argument_with_hints()
{
	echo "# ARG_OPTIONAL_SINGLE([$1], [<short option character (optional)>], [<help message (optional)>], [<default (optional)>])"
}


optional_argument()
{
	"${FUNCNAME[0]}_$2" "$1"
	_variables+=("printf 'Value of --%s: %s\\n' '$1' \"$(_translit_var "$1")\"")
}


boolean_argument_with_hints()
{
	echo "# ARG_OPTIONAL_BOOLEAN([$1], [<short option character (optional)>], [<help message (optional)>], [<default (optional), off by default>])"
}


boolean_argument_without_hints()
{
	echo "# ARG_OPTIONAL_BOOLEAN([$1])"
}


boolean_argument()
{
	"${FUNCNAME[0]}_$2" "$1"
	_variables+=("printf \"'%s' is %s\\\\n\" '$1' \"$(_translit_var "$1")\"")
}


positional_argument_with_hints()
{
	echo "# ARG_POSITIONAL_SINGLE([$1], [<help message (optional)>], [<default (optional)])"
}


positional_argument_without_hints()
{
	echo "# ARG_POSITIONAL_SINGLE([$1])"
}


positional_argument()
{
	HAVE_POSITIONAL_ARG=yes
	"${FUNCNAME[0]}_$2" "$1"
	_variables+=("printf \"Value of '%s': %s\\\\n\" '$1' \"$(_translit_var "$1")\"")
}


do_header()
{
	echo "#!/bin/bash"
	echo
	# We if separate == 2, we don't want to pass this to argbash at all
	test "$_arg_separate" = 2 && test "$1" = "script" && echo "# Created by argbash-init v$version" && return
	echo "# m4_ignore("
	if test "$1" = "lib"
	then
		echo "echo \"This is just a parsing library template, not the library - pass the parent script '$outfname' to 'argbash' to fix this.\" >&2"
	elif test "$1" = "standalone_lib"
	then
		echo "echo \"This is just a parsing library template, not the library - pass this file to 'argbash' to fix this.\" >&2"
	else
		echo "echo \"This is just a script template, not the script (yet) - pass it to 'argbash' to fix this.\" >&2"
	fi
	echo "exit 11  #)Created by argbash-init v$version"
}


do_args()
{
	local _mode="without_hints"
	if test "$_arg_hints" = on
	then
		echo "# Rearrange the order of options below according to what you would like to see in the help message."
		_mode="with_hints"
	fi
	for name in "${_arg_opt[@]}"
	do optional_argument "$name" "$_mode"; done
	for name in "${_arg_opt_bool[@]}"
	do boolean_argument "$name" "$_mode"; done
	for name in "${_arg_pos[@]}"
	do positional_argument "$name" "$_mode"; done
}


do_args_footer()
{
	if test "$_arg_mode" = "full"
	then
		echo '# ARGBASH_SET_DELIM([ =])'
		echo '# ARG_OPTION_STACKING([getopt])'
		echo '# ARG_RESTRICT_VALUES([no-local-options])'
	elif test "$_arg_mode" = "minimal"
	then
		echo '# ARGBASH_SET_DELIM([ ])'
		echo '# ARG_OPTION_STACKING([none])'
		echo '# ARG_RESTRICT_VALUES([none])'
	fi
	test "$HAVE_POSITIONAL_ARG" = yes && echo '# ARG_DEFAULTS_POS'
	echo "# ARG_HELP([<The general help message of my script>])"
	echo "# ARGBASH_GO"
}


do_script_assisted()
{
	do_header script

	echo "# DEFINE_SCRIPT_DIR()"
	echo "# INCLUDE_PARSING_CODE([$(basename "${parse_fname_stem}.sh")])"
	echo "# ARGBASH_GO"

	do_body_protected
}


#
# $1: The filename of the parsing library
do_script_separate()
{
	do_header script
	parse_fname=${parse_fname_stem}.sh

	echo "# Run 'argbash --strip user-content \"$1\" -o \"$parse_fname\"' to generate the '$parse_fname' file."
	echo "# If you need to make changes later, edit '$parse_fname' directly, and regenerate by running"
	echo "# 'argbash --strip user-content \"$parse_fname\" -o \"$parse_fname\"'"
	echo 'script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"'
	echo '. "${script_dir}/'"$(basename "$parse_fname")\" || { echo \"Couldn't find '$(basename "$parse_fname")' parsing library in the '"'$script_dir'"' directory\"; exit 1; }"
	echo

	do_body
}


do_body()
{
	for stat in "${_variables[@]}"
	do
		echo "$stat"
	done
}


do_body_protected()
{
	echo
	echo "# [ <-- needed because of Argbash"
	echo
	do_body
	echo
	echo "# ] <-- needed because of Argbash"
}


do_stuff()
{
	do_header "$1"
	do_args
	do_args_footer

	test "$_arg_separate" = 0 && do_body_protected
}

outfname="$_arg_output"
test "$outfname" = "-" -a "$_arg_separate" -gt 0 && die "If you want to separate parsing and script body, you have to specify the outname, stdout doesn't work."

if test "$outfname" = '-'
then
	do_stuff 'script'
else
	if test "$_arg_separate" = 0
	then
		do_stuff 'script' > "$outfname"
	else
		parse_fname_stem="$(echo "${outfname}" | sed -e 's/\.\(sh\|m4\)$//')-parsing"

		# IMPORTANT NOTION:
		# do_stuff has to be called FIRST, because it sets the _variables array content as its side-effect
		if test "$_arg_separate" = 1
		then
			do_stuff 'lib' > "${parse_fname_stem}.m4"
			do_script_assisted > "$outfname"
		else
			test "$_arg_separate" = 2 || echo "The greatest separation value is 2, got $_arg_separate" >&2
			parsing_library_file="${parse_fname_stem}.m4"
			do_stuff 'standalone_lib'  > "${parsing_library_file}"
			do_script_separate "$parsing_library_file" > "$outfname"
		fi
	fi
	chmod a+x "$outfname"
fi

# ]dnl

dnl vim: filetype=sh
