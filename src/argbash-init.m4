#!/bin/bash

version=_ARGBASH_VERSION
# ARG_POSITIONAL_SINGLE([output], [Name of the output template], "-")
# ARG_OPTIONAL_INCREMENTAL([separate], s, [Separate the parsing logic (specify two times for complete separation)])
# ARG_OPTIONAL_BOOLEAN([hints], ,[Whether to write hints to the script template])
# ARG_OPTIONAL_REPEATED([pos], , [Add a single-valued positional argument])
# ARG_OPTIONAL_REPEATED([opt], , [Add an single-valued optional argument])
# ARG_OPTIONAL_REPEATED([opt-bool], ,[Add an optional boolean argument])
# ARG_OPTIONAL_REPEATED([wrap], ,[What script(s) to wrap])
# ARG_VERSION([echo "argbash-init v$version"])
# ARG_HELP([Make a template for scripts.])

# ARGBASH_GO

# [


_variables=()


# This should be in sync with _translit_var in stuff.m4
_translit_var()
{
	printf "\$_arg_%s" "$1" | tr '[:upper:]' '[:lower:]' | tr '-' '_'
}


do_hints_pos()
{
	_help="[<$1's help message goes here>]"
	test "$_arg_hints" = on && _default="[<$1's default goes here (optional)>]"
}


do_hits_opt()
{
	do_hints_pos "$1"
	if test "$_arg_hints" = on
	then
		_short_opt="[<short option character goes here (optional)>]"
	fi
}


do_opt()
{
	do_hits_opt "$1"
	echo "# ARG_OPTIONAL_SINGLE([$1], $_short_opt, $_help)"
	_variables+=('echo "Value of --'$1': '$(_translit_var "$1")'"')
}


do_opt_bool()
{
	do_hits_opt "$1"
	echo "# ARG_OPTIONAL_BOOLEAN([$1], $_short_opt, $_help)"
	_variables+=('echo "'$1' is '$(_translit_var "$1")'"')
}


do_pos()
{
	do_hints_pos "$1"
	echo "# ARG_POSITIONAL_SINGLE([$1], $_help, $_default)"
	_variables+=('echo "Value of '$1': '$(_translit_var "$1")'"')
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
	else
		echo "echo \"This is just a script template, not the script (yet) - pass it to 'argbash' to fix this.\" >&2"
	fi
	echo "exit 11  #)Created by argbash-init v$version"
}


do_args()
{
	test "$_arg_hints" = on && echo "# Rearrange the order of options below according to what you would like to see in the help message."
	for name in "${_arg_opt[@]}"
	do do_opt "$name"; done
	for name in "${_arg_opt_bool[@]}"
	do do_opt_bool "$name"; done
	for name in "${_arg_pos[@]}"
	do do_pos "$name"; done
}


do_args_footer()
{
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


do_script_bare()
{
	do_header script
	parse_fname=${parse_fname_stem}.sh
	
	echo "# Run 'argbash --library \"$parse_fname\" -o \"$parse_fname\""
	echo 'script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"'
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
	test "$_arg_separate" = 0 && do_stuff 'script' > "$outfname" || parse_fname_stem="$(echo "${outfname}" | sed -e 's/\.\(sh\|m4\)$//')-parsing"
	# IMPORTANT NOTION:
	# do_stuff has to be called FIRST, because it sets the _variables array content as its side-effect
	test "$_arg_separate" = 1 && {
		do_stuff 'lib' > "${parse_fname_stem}.m4"
		do_script_assisted > "$outfname"
	}
	test "$_arg_separate" = 2 && {
		do_stuff 'lib'  > "${parse_fname_stem}.m4"
		do_script_bare > "$outfname"
	}
	chmod a+x "$outfname"
fi

# ]dnl

dnl vim: filetype=sh
