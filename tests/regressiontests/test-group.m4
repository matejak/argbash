#!/bin/bash

# ARG_POSITIONAL_SINGLE([act-ion], [help], [foo])
# ARG_TYPE_GROUP_SET([act_null], [ACTION], [act-ion], [foo,baz,bar bar,[foo,baz],])
# dnl The construction below is there for precise targeting of a sed substitution.
# ARG_OPTIONAL_REPEATED([repeated][], , [help])
# ARG_TYPE_GROUP_SET([act_nonull], [ACTION2], [repeated], [foo,baz])
# ARG_HELP([Testing program])
# ARGBASH_GO
#[

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "ACT=$_arg_act_ion,REP=${_arg_repeated[*]}"

#]
