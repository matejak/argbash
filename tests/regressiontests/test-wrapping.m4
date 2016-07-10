#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg0], [@pos-arg0@])
# ARGBASH_WRAP([test-onlyopt], [boo_l])
# ARGBASH_WRAP([test-onlypos])
# ARG_HELP([Testing program - wrapper])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S0=$_ARG_POS_ARG0,POS_S=$_ARG_POS_ARG,POS_OPT=$_ARG_POS_OPT,OPT_S=$_ARG_OPT_ARG,POS_S=$_ARG_POS_ARG,POS_OPT=$_ARG_POS_OPT,OPT_INCR=$_ARG_OPT_INCR,CMDLINE=${_ARGS_TEST_ONLYOPT[@]} ${_ARGS_TEST_ONLYPOS[@]},"

# closing escape square bracket: ]
