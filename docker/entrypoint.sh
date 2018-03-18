#!/bin/sh

LAUNCH="argbash"
test "$PROGRAM" = 'argbash-init' && LAUNCH="argbash-init" || true

encountered_output_option=no
for arg in "$@"; do
	if printf "%s" "$arg" | grep -q -e '^\(-o\|--output\)\>'; then
		encountered_output_option=yes
		break
	fi
done

"${LAUNCH}" "$@"

if test "$encountered_output_option" != yes; then
	echo '# It seems that you use the output to stdout.' >&2
	echo '# Beware, docker is likely to change line endings to DOS line endings.' >&2
	echo '# This will make the script not executable on Unixes, unless you convert \r\n to \n' >&2
	echo '# Use the -o|--output option to save the output to a file.' >&2
fi
