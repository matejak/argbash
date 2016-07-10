#!/bin/bash

# ARG_POSITIONAL_SINGLE([directory])
# ARGBASH_WRAP([simple], [filename])
# ARG_HELP([This program tells you size of files in a given directory in units you choose.])
# ARGBASH_GO

# [ <-- needed because of Argbash

test -f simple.sh || { echo "Missing the wrapped script, execute me from the directory where 'simple.sh' is."; exit 1; }
test -d "$_ARG_DIRECTORY" || { echo "We expected a directory, got '$_ARG_DIRECTORY'."; exit 1; }

for file in $_ARG_DIRECTORY/*
do
	test -f "$file" && echo "$file: $(./simple.sh "${_ARGS_SIMPLE_OPT[@]}" "$file")"
done

# ] <-- needed because of Argbash
