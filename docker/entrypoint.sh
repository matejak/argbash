#!/bin/sh

LAUNCH="argbash"
test "$PROGRAM" = 'argbash-init' && LAUNCH="argbash-init" || true

"${LAUNCH}" "$@"
