#!/usr/bin/env bash

# ARG_POSITIONAL_MULTI([pair], [Two values], 2)
# ARG_LEFTOVERS([args])
# ARGBASH_GO

# [ <-- needed because of Argbash

printf 'PAIR='; printf '<%s>' "${_arg_pair[@]}"
printf ',LEFTOVERS=%s,' "${#_arg_leftovers[@]}"; printf '<%s>' "${_arg_leftovers[@]}"
echo ','

# ] <-- needed because of Argbash
