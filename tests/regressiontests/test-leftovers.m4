#!/bin/bash

# ARG_OPTIONAL_SINGLE([cosi], [c])
# ARG_OPTIONAL_BOOLEAN([fear])
# ARG_POSITIONAL_SINGLE([another])
# ARG_LEFTOVERS([just leftovers])
# ARG_HELP()
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation

echo -n "OPT_S=$_ARG_COSI,FEAR=$_ARG_FEAR,POS_S=$_ARG_ANOTHER,LEFTOVERS="
for val in "${_ARG_LEFTOVERS[@]}"
	do echo -n "$val,"
done
echo

# closing escape square bracket: ]

