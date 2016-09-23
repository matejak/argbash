#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg], [])
# ARG_OPTIONAL_SINGLE([opt-arg])
# DEFINE_VALUE_TYPE([int], [INT], [pos-arg,opt-arg])
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_arg_pos_arg,OPT_S=$_arg_opt_arg,"

# closing escape square bracket: ]
