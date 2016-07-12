#!/bin/bash

# ARG_POSITIONAL_INF([pos-arg], [@pos-arg@])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation

echo -n POS_S=
for val in "${_ARG_POS_ARG[@]}"; do echo -n "$val,"; done
echo

# closing escape square bracket: ]
