#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.8.1
# ARG_OPTIONAL_SINGLE([option], o, [A option with short and long flags and default], [boo])
# ARG_OPTIONAL_BOOLEAN([print], , [A boolean option with long flag (and implicit default: off)])
# ARG_POSITIONAL_SINGLE([positional-arg], [Positional arg description], )
# ARG_DEFAULTS_POS
# ARG_HELP([This is a minimal demo of Argbash potential])
# ARG_VERSION([echo $0 v0.1])
# ARGBASH_SET_INDENT([  ])
# ARGBASH_GO

# [ <-- needed because of Argbash

if [ "$_arg_print" = on ]
then
  echo "Positional arg value: '$_arg_positional_arg'"
  echo "Optional arg '--option' value: '$_arg_option'"
else
  echo "Not telling anything, print not requested"
fi

# ] <-- needed because of Argbash
