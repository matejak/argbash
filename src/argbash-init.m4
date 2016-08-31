#!/bin/bash

version=_ARGBASH_VERSION
# ARG_POSITIONAL_SINGLE([output], o, [Name of the output template (pass '-' for stdout and empty string for the same as input file)], "-")
# ARG_OPTIONAL_INCREMENTAL([separate], s, [Separate the parsing logic (specify two times for complete separation).])
# ARG_OPTIONAL_BOOLEAN([hints], [Whether to write hints to the script template])
# ARG_OPTIONAL_REPEATED([pos], [Add a single-valued positional argument])
# ARG_OPTIONAL_REPEATED([opt], [Add an single-valued optional argument])
# ARG_OPTIONAL_REPEATED([opt-bool], [Add an optional boolean argument])
# ARG_OPTIONAL_REPEATED([wrap], [What script(s) to wrap])
# ARG_VERSION([echo "argbash-init v$version"])
# ARG_HELP([Make a template for scripts.])

# ARGBASH_GO

# [


do_hints_pos()
{
	_help="<$1's help message goes here>"
	test "$_arg_hints" = on && _default="<$1's default goes here (opt.)>"
}


do_hits_opt()
{
	do_hints_pos "$1"
	if test "$_arg_hints" = on
	then
		_short_opt="[<short option character goes here (opt.)>]"
	fi
}


do_opt()
{
	do_hits_opt "$1"
	echo "# ARG_OPTIONAL_SINGLE([$1], $_short_opt, $_help)"
}


do_opt_bool()
{
	do_hits_opt "$1"
	echo "# ARG_OPTIONAL_BOOLEAN([$1], $_short_opt, $_help)"
}


do_pos()
{
	do_hints_pos "$1"
	echo "# ARG_POSITIONAL_SINGLE([$1], $_help, $_default)"
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


do_stuff()
{
	do_header
	do_args
	do_args_footer
}

outfname="$_arg_output"
if test "$outfname" = '-'
then
	do_stuff
else
	do_stuff > "$outfname"
	chmod a+x "$outfname"
fi

# ]dnl

dnl vim: filetype=sh
