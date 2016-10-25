#!/bin/bash

# ARG_POSITIONAL_SINGLE([pos-arg], [])
# ARG_OPTIONAL_SINGLE([int], , ,[0])
# ARG_TYPE_GROUP([int], [INT], [pos-arg,int])
# ARG_OPTIONAL_SINGLE([nnint], , ,[0])
# ARG_TYPE_GROUP([nnint], [INT+0], [nnint])
# ARG_OPTIONAL_SINGLE([pint], , ,[1])
# ARG_TYPE_GROUP([pint], [INT+], [pint])
# ARG_HELP([Testing program])
# ARGBASH_GO

# opening escape square bracket: [

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
echo "POS_S=$_arg_pos_arg,OPT_S=$_arg_int,NN=$_arg_nnint,P=$_arg_pint,"

# closing escape square bracket: ]
