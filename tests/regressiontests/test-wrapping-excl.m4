#!/bin/bash

# ARGBASH_WRAP([test-onlypos], [pos-opt])
# ARGBASH_WRAP([test-onlypos], [pos-arg])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,CMDLINE_ONLYPOS=${_args_test_onlypos[*]}"

# closing escape square bracket: ]

