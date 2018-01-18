#!/bin/bash

# SC2154: _arg_pos_arg is referenced but not assigned.
# The absence of declaration is a feature of the test.
# shellcheck disable=SC2154

# ARG_POSITIONAL_SINGLE([pos-arg], [@pos-arg@])
# ARG_POSITIONAL_SINGLE([pos-opt], [@pos-opt-arg@], [pos-default])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,"

# closing escape square bracket: ]
