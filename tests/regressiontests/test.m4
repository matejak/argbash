#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg], [@pos-arg@])
# ARG_POSITIONAL_SINGLE([pos-opt], [@pos-opt-arg@], [pos-default])
# ARG_OPTIONAL_SINGLE([opt-arg], o, [], x)
# ARG_VERSION([echo $0 FOO])
# ARG_OPTIONAL_BOOLEAN(boo_l)
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "BOOL=$_ARG_BOO_L,OPT_S=$_ARG_OPT_ARG,POS_S=$_ARG_POS_ARG,POS_OPT=$_ARG_POS_OPT,"

# closing escape square bracket: ]
