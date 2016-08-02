#!/bin/bash

# ARG_POSITIONAL_SINGLE([filename])
# ARG_OPTIONAL_SINGLE([unit], u, [What unit we accept (b for bytes, k for kibibytes, M for mebibytes)], b)
# ARG_VERSION([echo $0 v0.1])
# ARG_OPTIONAL_BOOLEAN(verbose)
# ARG_HELP([This program tells you size of file that you pass to it in chosen units.])
# ARGBASH_SET_INDENT([  ])
# ARGBASH_GO

# [ <-- needed because of Argbash

# ARG_HELP  <-- Unlike one above, his one does not disappear, it is behind the escape bracket.

# Now we take the parsed data and assign them no nice-looking variable names,
# sometimes after a basic validation
verbose=$_arg_verbose
unit=$_arg_unit

test -f $_arg_filename || { echo "Filename $_arg_filename doesn't seem to belong to a file"; exit 1; }
filename="$_arg_filename"

if [ $verbose = on ]
then
  _b="bytes (B)"
  _kb="kibibytes (kiB)"
  _mb="mebibytes (MiB)"
else
  _b="B"
  _kb="kiB"
  _mb="MiB"
fi

size_bytes=$(wc -c "$filename" | cut -f 1 -d ' ')

test "$unit" = b && echo $size_bytes $_b && exit 0

size_kilobytes=$(expr $size_bytes / 1024)
test "$unit" = k && echo $size_kilobytes $_kb && exit 0

size_megabytes=$(expr $size_kilobytes / 1024)
test "$unit" = M && echo $size_megabytes $_mb && exit 0

test "$verbose" = on && echo "The unit '$unit' is not supported!"
exit 1

# ] <-- needed because of Argbash
