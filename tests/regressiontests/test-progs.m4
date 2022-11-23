#!/bin/bash -e

# ARG_VERSION([echo "$0 FOO"])
# ARG_USE_PROGRAM([fulala], [FULALA], [fulala doesnt exist], [Testing program m4_fatal(BOOM!)])
# ARG_USE_PROGRAM([make], [MAKE], [GNU make missing], [GNU make - utility used for automation])
# ARG_HELP([Testing program m4_fatal(BOOM!)], [m4_fatal([CRASH!])])
# ARGBASH_GO()

# [ <-- needed because of Argbash

# Expecting make to come from the environment
# shellcheck disable=SC2154
"${MAKE}" --version > /dev/null || die "make doesn't work"

# ] <-- needed because of Argbash
m4_ifdef([m4_esyscmd], [m4_fatal([The m4_esyscmd macro is enabled!])])
