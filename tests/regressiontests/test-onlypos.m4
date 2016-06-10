#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg], [@pos-arg@])
# ARG_POSITIONAL_SINGLE([pos-opt], [@pos-opt-arg@], [pos-default])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_ARG_POS_ARG,POS_OPT=$_ARG_POS_OPT,"

# closing escape square bracket: ]

