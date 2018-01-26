#!/bin/bash

# shellcheck source=OUTPUT_ABS_DIRNAME/test-salone.sh

# DEFINE_SCRIPT_DIR
# INCLUDE_PARSING_CODE([test-salone.sh])
# ARGBASH_GO

# [ <-- needed because of Argbash

echo "BOOL=$_arg_boo_l,OPT_S=$_arg_opt_arg,POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,OPT_INCR=$_arg_opt_incr,"

# ] <-- needed because of Argbash
