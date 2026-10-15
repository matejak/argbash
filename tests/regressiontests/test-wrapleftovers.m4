#!/usr/bin/env bash

# SC2154: the wrapped library has no optional args, so _args_*_opt is referenced but not assigned.
# shellcheck disable=SC2154

m4_define(_DEFAULT_WRAP_FLAGS, [])

# ARG_POSITIONAL_SINGLE([cmd], [the command])
# ARGBASH_WRAP([test-wrapleftovers-lib])
# ARG_DEFAULTS_POS()
# ARGBASH_GO

# [ <-- needed because of Argbash

printf 'CMD=%s,PAIR=' "$_arg_cmd"; printf '<%s>' "${_arg_pair[@]}"
printf ',LEFTOVERS=%s,' "${#_arg_leftovers[@]}"; printf '<%s>' "${_arg_leftovers[@]}"
printf ',CMDLINE=%s,' "${#_args_test_wrapleftovers_lib[@]}"; printf '<%s>' "${_args_test_wrapleftovers_lib[@]}"
echo ','

# ] <-- needed because of Argbash
