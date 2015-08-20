#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$SCRIPT_DIR/test-standalone.sh"

echo "BOOL=$_ARG_BOO_L,OPT_S=$_ARG_OPT_ARG,POS_S=$_ARG_POS_ARG,"
