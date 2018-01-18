#!/bin/bash

# ARG_OPTIONAL_SINGLE([cosi], [c])
# ARG_OPTIONAL_BOOLEAN([fear])
# ARG_OPTIONAL_INCREMENTAL([more], m)
# ARG_POSITIONAL_SINGLE([another])
# ARG_LEFTOVERS([just leftovers])
# ARG_DEFAULTS_POS()
# ARG_HELP()
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation

echo -n "MORE=$_arg_more,OPT_S=$_arg_cosi,FEAR=$_arg_fear,POS_S=$_arg_another,LEFTOVERS="
for val in "${_arg_leftovers[@]}"
	do echo -n "$val,"
done
echo

# closing escape square bracket: ]
