#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg], [@pos-arg@])
# ARG_POSITIONAL_SINGLE([pos-opt], [@pos-opt-arg@], [pos-default])
# ARG_DEFAULTS_POS
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,"

# closing escape square bracket: ]
