#!/usr/bin/env bash

# ARG_OPTIONAL_SINGLE([opt-arg], [o], [An optional argument], [default])
# ARG_HELP([Test that the script body survives untouched even if its square brackets do not match])
# ARGBASH_GO

# [ <-- needed because of Argbash

# The regular expression has more closing square brackets than opening ones.
_value="$(echo 'Max : [42]' | sed -n 's/.*Max : \[\([^]]*\)\].*/\1/p')"
_items=("[one]" "[two]")
if [ "${#_items[@]}" -gt 1 ] && [[ "${_items[1]}" = "[two]" ]]
then
	_brackets=preserved
else
	_brackets=mangled
fi

echo "VALUE=$_value,BRACKETS=$_brackets,OPT_S=$_arg_opt_arg,"

# ] <-- needed because of Argbash
