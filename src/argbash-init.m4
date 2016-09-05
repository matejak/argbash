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
	_variables+=('echo "Value of --'$1': $_arg_'$1'"')
}


do_opt_bool()
{
	do_hits_opt "$1"
	echo "# ARG_OPTIONAL_BOOLEAN([$1], $_short_opt, $_help)"
	_variables+=('echo "'$1' is $_arg_'$1'"')
}


do_pos()
{
	do_hints_pos "$1"
	echo "# ARG_POSITIONAL_SINGLE([$1], $_help, $_default)"
	_variables+=('echo "Value of '$1': $_arg_'$1'"')
}


do_header()
{
	echo "#!/bin/bash"
	echo
}


do_args()
{
	for name in "${_arg_pos[@]}"
	do do_pos "$name"; done
	for name in "${_arg_opt[@]}"
	do do_opt "$name"; done
	for name in "${_arg_opt_bool[@]}"
	do do_opt_bool "$name"; done
}


do_args_footer()
{
	echo "# ARG_HELP([<The general help message of my script>])"
	echo "# ARGBASH_GO"
}


do_script_assisted()
{
	do_header
	
	echo "# DEFINE_SCRIPT_DIR()"
	echo "# INCLUDE_PARSING_CODE([${_arg_output%.sh}-parsing.sh])"
	echo "# ARGBASH_GO"

	do_body_protected
}


do_script_bare()
{
	do_header
	
	echo "scipt_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)""
	echo '. "${script_dir}'"${_arg_output%.sh}-parsing.sh\""
	echo "# ARGBASH_GO"

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
	do_header
	do_args
	do_args_footer

	test "$_arg_separate" = 0 && do_body_protected
}

outfname="$_arg_output"
test "$outfname" = "-" -a "$_arg_separate" -gt 0 && die "If you want to separate parsing and script body, you have to specify the outname, stdout doesn't work."

if test "$outfname" = '-'
then
	do_stuff
else
	test "$_arg_separate" = 0 && do_stuff > "$outfname" || parse_fname="${outfname%.sh}-parsing.sh"
	test "$_arg_separate" = 1 && {
		do_script_assisted > "$outfname"
		do_stuff > "$parse_fname"
	}
	test "$_arg_separate" = 2 && {
		do_script_bare > "$outfname"
		do_stuff > "$parse_fname"
	}
	chmod a+x "$outfname"
fi

# ]dnl

dnl vim: filetype=sh
