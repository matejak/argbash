#!/usr/bin/env bash

# shellcheck source=OUTPUT_ABS_DIRNAME/test-salone.sh

# The script directory is not defined explicitly - the include macro has to define it under the requested name.
# INCLUDE_PARSING_CODE([test-salone.sh], [my_dir])
# ARGBASH_GO

# [ <-- needed because of Argbash

echo "BOOL=$_arg_boo_l,OPT_S=$_arg_opt_arg,POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,OPT_INCR=$_arg_opt_incr,"

# ] <-- needed because of Argbash
