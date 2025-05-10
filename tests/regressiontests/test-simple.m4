#!/usr/bin/env -S bash -e

# ARG_POSITIONAL_SINGLE([pos-arg], [help line PEND-\n-PBEGIN])
# ARG_OPTIONAL_SINGLE([prefix],[o],[help line END-\n-BEGIN "line 2" END-\\n-2BEGIN],[x])
# ARG_OPTIONAL_BOOLEAN([print-optionals],[p],[Print the set of optional arguments],[off])
# ARG_OPTIONAL_SINGLE([la], [l], [help line END-\n-BEGIN "line 2"])
# ARG_OPTIONAL_BOOLEAN([not-supplied],[s])
# ARGBASH_INDICATE_SUPPLIED([prefix])
# ARGBASH_INDICATE_SUPPLIED([print-optionals],[la])
# ARG_VERSION([echo "$0 FOO"])
# ARG_HELP([Testing program m4_fatal(BOOM!)], [m4_fatal([CRASH!])])
# ARG_DEFAULTS_POS()
# ARGBASH_GO()

# [ <-- needed because of Argbash

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
if [ "$_arg_print_optionals" = on ]; then
    set -u
    echo "_supplied_arg_prefix=${_supplied_arg_prefix},_supplied_arg_print_optionals=${_supplied_arg_print_optionals},_supplied_arg_la=${_supplied_arg_la},_supplied_arg_not_supplied=${_supplied_arg_not_supplied-x}"
else
    echo "OPT_S=$_arg_prefix,POS_S=$_arg_pos_arg,LA=$_arg_la,"
fi

# ] <-- needed because of Argbash
m4_ifdef([m4_esyscmd], [m4_fatal([The m4_esyscmd macro is enabled!])])
