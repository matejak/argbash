#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# ARG_OPTIONAL_SINGLE([option])
# ARG_OPTIONAL_BOOLEAN([print])
# ARG_POSITIONAL_SINGLE([positional-arg])
# ARG_DEFAULTS_POS
# ARG_HELP([<The general help message of my script>])
# ARGBASH_GO

# [ <-- needed because of Argbash

# vvv  PLACE YOUR CODE HERE  vvv
# For example:
printf 'Value of --%s: %s\n' 'option' "${_arg_option}"
printf "'%s' is %s\\n" 'print' "${_arg_print}"
printf "Value of '%s': %s\\n" 'positional-arg' "${_arg_positional_arg}"

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
