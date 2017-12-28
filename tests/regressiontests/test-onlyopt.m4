#!/bin/bash

dnl m4_define([test], [m4_fatal([BOOM!!!])])
m4_define([incrx], [m4_fatal([BOOM!!!])])
# ARG_OPTIONAL_SINGLE([opt-arg], o, [], x)
# ARG_VERSION([echo "$0 FOO"])
# ARG_OPTIONAL_BOOLEAN(boo_l, B)
# ARG_OPTIONAL_INCREMENTAL([incrx], i, [@pos-opt-arg@], 2)
# ARG_OPTIONAL_REPEATED([opt-repeated], r, [@opt-repeated@])
# ARGBASH_SET_INDENT([  ])
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "BOOL=$_arg_boo_l,OPT_S=$_arg_opt_arg,POS_S=$_arg_pos_arg,POS_OPT=$_arg_pos_opt,OPT_INCR=$_arg_incrx,ARG_REPEATED=${_arg_opt_repeated[*]},"

# closing escape square bracket: ]

