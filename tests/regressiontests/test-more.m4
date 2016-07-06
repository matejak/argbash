#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg], [@pos-arg@])
# ARG_POSITIONAL_MULTI([pos-more], [@pos-more-arg@], 3, [f[o]o], [ba,r])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_ARG_POS_ARG,POS_MORE=${_ARG_POS_MORE[@]},"

# closing escape square bracket: ]
