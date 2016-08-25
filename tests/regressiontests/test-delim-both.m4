#!/bin/bash

# ARG_OPTIONAL_SINGLE([opt], , [])
# ARG_OPTIONAL_REPEATED([add], a, [@opt-repeated@])
# ARGBASH_SET_DELIM([ =])
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "OPT_S=$_arg_opt,OPT_REP=${_arg_add[*]},"

# closing escape square bracket: ]


