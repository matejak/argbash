#!/bin/bash

# ARGBASH_WRAP([test-onlyopt.m4])
# ARGBASH_WRAP([test-onlypos.m4])
# ARG_HELP([Testing program - wrapper])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_ARG_POS_ARG,POS_OPT=$_ARG_POS_OPT,BOOL=$_ARG_BOO_L,OPT_S=$_ARG_OPT_ARG,POS_S=$_ARG_POS_ARG,POS_OPT=$_ARG_POS_OPT,OPT_INCR=$_ARG_OPT_INCR,"

# closing escape square bracket: ]
