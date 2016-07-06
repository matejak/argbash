#!/bin/bash

# ARGBASH_WRAP([test-onlyopt], [boo_l,opt-arg])
# ARG_HELP([Testing program - wrapper])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_ARG_POS_ARG,POS_OPT=$_ARG_POS_OPT,OPT_INCR=$_ARG_OPT_INCR,CMDLINE=${_ARGS_TEST_ONLYOPT[@]},"

# closing escape square bracket: ]

