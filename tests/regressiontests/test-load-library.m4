#!/usr/bin/env bash

# The library loader has to work even if the script directory has not been defined explicitly.
# shellcheck source=OUTPUT_ABS_DIRNAME/test-library.sh

# DEFINE_LOAD_LIBRARY
# ARG_OPTIONAL_SINGLE([opt-arg], [o], [An optional argument], [default])
# ARG_HELP([Test of the library loader without an explicit script directory definition])
# ARGBASH_GO

# [ <-- needed because of Argbash

load_lib_relativepath test-library.sh
echo "LIB=$_lib_loaded,OPT_S=$_arg_opt_arg,"

# ] <-- needed because of Argbash
