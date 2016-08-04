#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg],[@pos-arg@])
# ARG_OPTIONAL_SINGLE([opt-arg],[o],[],[x])
# ARG_VERSION([echo $0 FOO])
# ARG_HELP([Testing program])
# ARGBASH_GO()

# [ <-- needed because of Argbash

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "OPT_S=$_arg_opt_arg,POS_S=$_arg_pos_arg,"

# ] <-- needed because of Argbash
