#!/bin/bash

m4_define(_DEFAULT_WRAP_FLAGS, [])

# ARG_POSITIONAL_SINGLE([pos-arg0], [@pos-arg0@])
# ARGBASH_WRAP([test-onlyopt], [boo_l])
# ARGBASH_WRAP([test-onlypos])
# ARG_HELP([Testing program - wrapper])
# ARG_DEFAULTS_POS()
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S0=$_arg_pos_arg0,POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,OPT_S=$_arg_opt_arg,POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,OPT_INCR=$_arg_incrx,CMDLINE=${_args_test_onlyopt[*]} ${_args_test_onlypos[*]},"

# closing escape square bracket: ]
