#!/bin/bash

# ARG_POSITIONAL_MULTI([pos-more1], [@pos-more1-arg@], 2)
# ARG_POSITIONAL_MULTI([pos-more2], [@pos-more2-arg@], 2, [hu], [lu])
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_MORE1=${_arg_pos_more1[*]},POS_MORE2=${_arg_pos_more2[*]},"

# closing escape square bracket: ]

