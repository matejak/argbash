#!/bin/bash

# ARG_USE_ENV([ENVI_FOO], [def,ault], [A sample env, variable])
# ARG_USE_ENV([ENVI_BAR], [], [A sample env, variable])
# ARG_HELP()
# ARGBASH_GO

# Assume ENVI_BAR is set by the environment
# shellcheck disable=2154
echo "ENVI_FOO=${ENVI_FOO},ENVI_BAR=${ENVI_BAR},"
