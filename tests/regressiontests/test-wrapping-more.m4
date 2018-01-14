#!/bin/bash

# ARGBASH_WRAP([test-onlyopt], [boo_l,opt-arg])
# ARG_HELP([Testing program - wrapper])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,OPT_INCR=$_arg_incrx,CMDLINE=${_args_test_onlyopt[*]},"

# closing escape square bracket: ]

