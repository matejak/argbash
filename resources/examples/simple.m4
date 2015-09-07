#!/bin/bash

# ARG_POSITIONAL_SINGLE([filename])
# ARG_OPTIONAL_SINGLE([unit], u, [What unit we accept (b for bytes, k for kilobytes, M for megabytes)], b)
# ARG_VERSION([echo $0 v0.1])
# ARG_OPTIONAL_BOOLEAN(verbose)
# ARG_HELP([This program tells you size of file that you pass to it in chosen units.])
# ARGBASH_GO

# opening escape square bracket: [

# ARG_HELP  <-- Unlike one above, his one does not disappear, it is behind the escape bracket.

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
VERBOSE=$_ARG_VERBOSE
UNIT=$_ARG_UNIT

test -f $_ARG_FILENAME || { echo "Filename $_ARG_FILENAME doesn't seem to belong to a file"; exit 1; }
FILENAME="$_ARG_FILENAME"

if [ $VERBOSE = on ]
then
	_b="bytes (B)"
	_kb="kilobytes (kB)"
	_mb="megabytes (MB)"
else
	_b="B"
	_kb="kB"
	_mb="MB"
fi

SIZE_BYTES=$(wc -c "$FILENAME" | cut -f 1 -d ' ')

test "$UNIT" = b && echo $SIZE_BYTES $_b && exit 0

SIZE_KILOBYTES=$(expr $SIZE_BYTES / 1024)
test "$UNIT" = k && echo $SIZE_KILOBYTES $_kb && exit 0

SIZE_MEGABYTES=$(expr $SIZE_KILOBYTES / 1024)
test "$UNIT" = M && echo $SIZE_MEGABYTES $_mb && exit 0

test "$VERBOSE" = on && echo "The unit '$UNIT' is not supported!"
exit 1

# closing escape square bracket: ]
