#!/bin/bash

# ARG_POSITIONAL_SINGLE([positional-arg], [Positional arg description])
# ARG_OPTIONAL_SINGLE([option], o, [A option with short and long flags and default], b)
# ARG_OPTIONAL_BOOLEAN([print], , [A boolean option with long flag (and implicit default: off)], )
# ARG_VERSION([echo $0 v0.1])
# ARG_HELP([This is a minimal demo of Argbash potential])
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
