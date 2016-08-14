#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg], [@pos-arg@])
# ARG_POSITIONAL_SINGLE([pos-opt], [@pos-opt-arg@], [pos-default])
# ARG_OPTIONAL_SINGLE([opt-arg], o, [], x)
# ARG_VERSION([echo $0 FOO])
# ARG_OPTIONAL_BOOLEAN(boo_l)
# ARG_OPTIONAL_INCREMENTAL([opt-incr], i, [@pos-opt-arg@], 2)
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "BOOL=$_arg_boo_l,OPT_S=$_arg_opt_arg,POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,OPT_INCR=$_arg_opt_incr,"

# closing escape square bracket: ]
