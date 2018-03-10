#!/bin/bash

m4_define(_DEFAULT_WRAP_FLAGS, [])

# ARGBASH_WRAP([test-onlyopt], [boo_l])
# ARGBASH_WRAP([test-wrapping-single_level], [pos-arg1])
# ARG_HELP([Testing program - wrapper])
# ARG_DEFAULTS_POS()
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
# shellcheck disable=SC2154
# SC2154: _arg_pos_arg1 is referenced but not assigned --- this is part of the test.
echo "POS_S1=$_arg_pos_arg1,POS_S0=$_arg_pos_arg0,POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,OPT_S=$_arg_opt_arg,POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,CMDLINE=${_args_test_onlyopt[*]} ${_args_test_wrapping_single_level[*]},"

# closing escape square bracket: ]

