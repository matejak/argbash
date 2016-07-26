#!/bin/bash

# ARG_OPTIONAL_SINGLE([opt-arg], o, [], x)
# ARG_VERSION([echo $0 FOO])
# ARG_OPTIONAL_BOOLEAN(boo_l)
# ARG_OPTIONAL_INCREMENTAL([opt-incr], i, [@pos-opt-arg@], 2)
# ARG_OPTIONAL_REPEATED([opt-repeated], r, [@opt-repeated@])
# ARGBASH_SET_INDENT([  ])
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "BOOL=$_ARG_BOO_L,OPT_S=$_ARG_OPT_ARG,POS_S=$_ARG_POS_ARG,POS_OPT=$_ARG_POS_OPT,OPT_INCR=$_ARG_OPT_INCR,ARG_REPEATED=${_ARG_OPT_REPEATED[@]},"

# closing escape square bracket: ]

