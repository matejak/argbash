#!/bin/bash -e

# SC2317: Command appears to be unreachable
# When there are only action optional arguments and no positional ones, the shift statement can be omitted.
# The check smells risky, and its value is very low.
# shellcheck disable=SC2317
#
# ARG_VERSION([echo "$0 FOO"])
# ARG_USE_PROGRAM([fulala], [FULALA], [fulala doesnt exist], [Testing program m4_fatal(BOOM!)])
# ARG_USE_PROGRAM([make], [MAKE], [GNU make missing], [GNU make - utility used for automation])
# ARG_HELP([Testing program m4_fatal(BOOM!)], [m4_fatal([CRASH!])])
# ARGBASH_GO()

# [ <-- needed because of Argbash

"$MAKE" --version > /dev/null || die "make doesnt work"

# ] <-- needed because of Argbash
m4_ifdef([m4_esyscmd], [m4_fatal([The m4_esyscmd macro is enabled!])])
