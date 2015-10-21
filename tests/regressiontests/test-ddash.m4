#!/bin/bash

# ARG_OPTIONAL_BOOLEAN(boo_l)
# ARG_POSITIONAL_DOUBLEDASH()
# ARG_POSITIONAL_SINGLE([pos-opt], [@pos-opt-arg@], [pos-default])
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "BOOL=$_ARG_BOO_L,POS_OPT=$_ARG_POS_OPT,"

# closing escape square bracket: ]

