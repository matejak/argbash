#!/bin/bash -e

# ARG_POSITIONAL_SINGLE([arg], [], [foo])
# ARG_OPTIONAL_SINGLE([width], w, [])
# ARG_OPTIONAL_BOOLEAN([time], t, [])
# ARG_OPTIONAL_BOOLEAN([long], l, [)
# ARG_OPTIONAL_INCREMENTAL([verbose], v, [])
# ARG_HELP([Testing program])
# ARGBASH_GO
#[

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "ARG=$_arg_arg,WIDTH=$_arg_width,TIME=$_arg_time,LONG=$_arg_long,VERBOSE=$_arg_verbose,"

#]
