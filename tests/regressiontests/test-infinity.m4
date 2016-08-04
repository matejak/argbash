#!/bin/bash

# ARG_POSITIONAL_INF([pos-arg], [@pos-arg@], 0, first, second, third)
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation

echo -n POS_S=
for val in "${_arg_pos_arg[@]}"; do echo -n "$val,"; done
echo

# closing escape square bracket: ]
