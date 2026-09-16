#!/usr/bin/env bash

# ARGBASH_WRAP([test-body-brackets])
# ARG_HELP([Test that we can wrap a script whose body has square brackets that do not match])
# ARGBASH_GO

# [ <-- needed because of Argbash

echo "WRAPPED=${_args_test_body_brackets[*]},"

# ] <-- needed because of Argbash
