#!/bin/bash

# DEFINE_SCRIPT_DIR
# ARG_POSITIONAL_INF([directory], [Directories to go through], 1)
# ARG_OPTIONAL_SINGLE([glob], , [What files to match in the directory], [*])
# ARGBASH_WRAP([simple-parsing], [filename])
# ARG_HELP([This program tells you size of specified files in given directories in units you choose.])
# ARGBASH_SET_INDENT([  ])
# ARGBASH_GO

# [ <-- needed because of Argbash

script="$script_dir/simple.sh"
test -f "$script" || { echo "Missing the wrapped script, was expecting it next to me, in '$script_dir'."; exit 1; }

for directory in "${_arg_directory[@]}"
do
  test -d "$directory" || die "We expected a directory, got '$directory', bailing out."
  printf "Contents of '%s' matching '%s':\n" "$directory" "$_arg_glob"
  for file in "$directory"/$_arg_glob
  do
    test -f "$file" && printf "\t%s: %s\n" "$(basename "$file")" "$("$script" "${_args_simple_parsing_opt[@]}" "$file")"
  done
done

# ] <-- needed because of Argbash
