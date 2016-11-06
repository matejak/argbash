#!/bin/bash

# DEFINE_SCRIPT_DIR()
# INCLUDE_PARSING_CODE([simple-parsing.sh])
# ARGBASH_GO

# [ <-- needed because of Argbash

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

size_kibibytes=$(($size_bytes / 1024))
test "$unit" = k && echo $size_kibibytes $_kb && exit 0

size_mebibytes=$(($size_kibibytes / 1024))
test "$unit" = M && echo $size_mebibytes $_mb && exit 0

test "$verbose" = on && echo "The unit '$unit' is not supported"
exit 1

# ] <-- needed because of Argbash
