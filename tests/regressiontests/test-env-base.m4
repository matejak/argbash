#!/bin/bash

# SC2317: Command appears to be unreachable
# When there are only action optional arguments and no positional ones, the shift statement can be omitted.
# The check smells risky, and its value is very low.
# shellcheck disable=SC2317
#
# ARG_USE_ENV([ENVI_FOO], [def,ault], [A sample env, variable])
# ARG_USE_ENV([ENVI_BAR], [], [A sample env, variable])
# ARG_HELP()
# ARGBASH_GO

echo "ENVI_FOO=$ENVI_FOO,ENVI_BAR=$ENVI_BAR,"
