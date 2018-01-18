#!/bin/bash

# ARG_POSITIONAL_SINGLE([act-ion], [], [foo])
# ARG_OPTIONAL_SINGLE([opt-tion], [], [], [foo])
# ARG_OPTIONAL_REPEATED([repeated])
# ARG_TYPE_GROUP_SET([act], [ACTION], [act-ion,opt-tion,repeated], [foo,baz,bar bar,[foo,baz]], [index])
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "ACT=$_arg_act_ion,IDX=$_arg_act_ion_index,OPT=$_arg_opt_tion,IDX2=$_arg_opt_tion_index,"

# closing escape square bracket: ]
