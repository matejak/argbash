#!/usr/bin/env bash

# User code before the first Argbash macro has to be preserved verbatim, square brackets included.
# ARGUMENTS: none expected here - this comment line must not be mistaken for an Argbash macro.
_before=("[one]" "[two]")
if [[ "${_before[1]}" = "[two]" ]]
then
	_brackets=preserved
else
	_brackets=mangled
fi
_array=(one two)

# ARG_OPTIONAL_SINGLE([opt-arg], [o], [An optional argument], [default])
# ARG_HELP([Test that user code before Argbash macros survives untouched])
# ARGBASH_GO

# [ <-- needed because of Argbash

echo "BRACKETS=$_brackets,ARRAY=${_array[*]},OPT_S=$_arg_opt_arg,"

# ] <-- needed because of Argbash
