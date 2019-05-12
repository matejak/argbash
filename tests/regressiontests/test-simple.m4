#!/bin/bash -e

# ARG_POSITIONAL_SINGLE([pos-arg], [help line PEND-\n-PBEGIN])
# ARG_OPTIONAL_SINGLE([prefix],[o],[help line END-\n-BEGIN "line 2" END-\\n-2BEGIN],[x])
# ARG_OPTIONAL_SINGLE([la], [l], [help line END-\n-BEGIN "line 2"])
# ARG_VERSION([echo "$0 FOO"])
# ARG_HELP([Testing program m4_fatal(BOOM!)], [m4_fatal([CRASH!])])
# ARG_DEFAULTS_POS()
# ARGBASH_GO()

# [ <-- needed because of Argbash

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "OPT_S=$_arg_prefix,POS_S=$_arg_pos_arg,LA=$_arg_la,"

# ] <-- needed because of Argbash
m4_ifdef([m4_esyscmd], [m4_fatal([The m4_esyscmd macro is enabled!])])
