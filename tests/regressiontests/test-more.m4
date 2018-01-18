#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg], [@pos-arg@])
# ARG_POSITIONAL_MULTI([pos-more], [@pos-more-arg@], 3, [f[o]o], [ba,r])
# ARG_DEFAULTS_POS()
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_arg_pos_arg,POS_MORE=${_arg_pos_more[*]},"

# closing escape square bracket: ]
