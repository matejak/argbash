#!/bin/bash

m4_define([if_not_posix], [m4_if(m4_quote(_OUTPUT_TYPE), [posix-script], [$2], [$1])])

dnl m4_define([test], [m4_fatal([BOOM!!!])])
m4_define([incrx], [m4_fatal([BOOM!!!])])
# ARG_OPTIONAL_SINGLE([opt-arg], o, [@opt-arg@], x)
# ARG_VERSION([echo "$0 FOO"])
# ARG_OPTIONAL_BOOLEAN(boo_l, B)
if_not_posix([# ARG_OPTIONAL_REPEATED([opt-repeated], r, [@opt-repeated@])])
# ARG_OPTIONAL_INCREMENTAL([incrx], i, [@pos-opt-arg@], 2)
# ARGBASH_SET_INDENT([  ])
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "BOOL=$_arg_boo_l,OPT_S=$_arg_opt_arg,OPT_INCR=$_arg_incrx,]if_not_posix([[ARG_REPEATED=${_arg_opt_repeated[*]},]])["

# closing escape square bracket: ]

