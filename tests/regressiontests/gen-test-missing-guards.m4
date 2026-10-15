#!/usr/bin/env bash

# A template that lacks the guard lines past ARGBASH_GO - argbash should warn about it.
# shellcheck disable=SC2154

# ARG_OPTIONAL_SINGLE([opt-arg], [o], [An optional argument])
# ARG_HELP([A template without the guard lines])
# ARGBASH_GO

echo "OPT_S=$_arg_opt_arg,"
