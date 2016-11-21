#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.2.1a
# ARG_OPTIONAL_SINGLE([option], , [<option's help message goes here>])
# ARG_OPTIONAL_BOOLEAN([print], , [<print's help message goes here>])
# ARG_POSITIONAL_SINGLE([positional-arg], [<positional-arg's help message goes here>], )
# ARG_HELP([<The general help message of my script>])
# ARGBASH_GO

# [ <-- needed because of Argbash

echo "Value of --option: $_arg_option"
echo "print is $_arg_print"
echo "Value of positional-arg: $_arg_positional_arg"

# ] <-- needed because of Argbash
