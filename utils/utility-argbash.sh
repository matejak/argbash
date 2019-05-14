#!/bin/bash
### @accetto (https://github.com/accetto)

### Warning! The following two variables must be configured manually before using this script!
### Name of an accesible 'argbash' docker image to use
### Example: _docker="matejak/argbash"
### Example: _docker="accetto/argbash-docker:latest"
_docker="TODO"
### Name of an accessible working directory where you develop your scripts.
### The working directory will be used by Docker containers.
### Note that the containers must have writing permissions for the working directory.
### Example (Linux): _workdir="/home/joe/docker/volumes/argbash/work"
### Example (Linux): _workdir="~/docker/volumes/argbash/work"
### Example (Windows): _workdir="C:\Users\Joe\Documents\docker\volumes\argbash\work"
### Example (Windows (bash)): _workdir="C:/Users/Joe/Documents/docker/volumes/argbash/work"
### Example (Windows (bash)): _workdir="~/Documents/docker/volumes/argbash/work"
_workdir="TODO"

# ARG_POSITIONAL_SINGLE([template],[Template file to use])
# ARG_OPTIONAL_SINGLE([output],[o],[Output file. The template is overwritten by default (only non-M4).],[""])
# ARG_LEFTOVERS([Other argbash options])
# ARG_HELP([Processes a template file in the working directory using an 'argbash' docker container.],[The input template can be a '*.m4' file or a script previously generated by 'argbash'.\nInput template file is overwritten by default, except:\n  - if it is a '*.m4' file\n  - if the output file is explicitely defined\nCreated container will be automatically removed after use.\nCurrent Docker image to use is \"$_docker\".\nCurrent working directory to use is \"$_workdir\".\nNote that containers must have writing permissions for the working directory.])
# ARG_VERSION([echo $0 v0.1.0])
# ARGBASH_SET_INDENT([  ])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.8.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


die()
{
  local _ret=$2
  test -n "$_ret" || _ret=1
  test "$_PRINT_HELP" = yes && print_help >&2
  echo "$1" >&2
  exit ${_ret}
}


begins_with_short_option()
{
  local first_option all_short_options='ohv'
  first_option="${1:0:1}"
  test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
_arg_leftovers=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_output=""


print_help()
{
  printf '%s\n' "Processes a template file in the working directory using an 'argbash' docker container."
  printf 'Usage: %s [-o|--output <arg>] [-h|--help] [-v|--version] <template> ... \n' "$0"
  printf '\t%s\n' "<template>: Template file to use"
  printf '\t%s\n' "... : Other argbash options"
  printf '\t%s\n' "-o, --output: Output file. The template is overwritten by default (only non-M4). (default: '""')"
  printf '\t%s\n' "-h, --help: Prints help"
  printf '\t%s\n' "-v, --version: Prints version"
  printf '\n%s\n' "The input template can be a '*.m4' file or a script previously generated by 'argbash'.
Input template file is overwritten by default, except:
  - if it is a '*.m4' file
  - if the output file is explicitely defined
Created container will be automatically removed after use.
Current Docker image to use is \"$_docker\".
Current working directory to use is \"$_workdir\".
Note that containers must have writing permissions for the working directory."
}


parse_commandline()
{
  _positionals_count=0
  while test $# -gt 0
  do
    _key="$1"
    case "$_key" in
      -o|--output)
        test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
        _arg_output="$2"
        shift
        ;;
      --output=*)
        _arg_output="${_key##--output=}"
        ;;
      -o*)
        _arg_output="${_key##-o}"
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      -h*)
        print_help
        exit 0
        ;;
      -v|--version)
        echo $0 v0.1
        exit 0
        ;;
      -v*)
        echo $0 v0.1
        exit 0
        ;;
      *)
        _last_positional="$1"
        _positionals+=("$_last_positional")
        _positionals_count=$((_positionals_count + 1))
        ;;
    esac
    shift
  done
}


handle_passed_args_count()
{
  local _required_args_string="'template'"
  test "${_positionals_count}" -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require at least 1 (namely: $_required_args_string), but got only ${_positionals_count}." 1
}


assign_positional_args()
{
  local _positional_name _shift_for=$1
  _positional_names="_arg_template "
  _our_args=$((${#_positionals[@]} - 1))
  for ((ii = 0; ii < _our_args; ii++))
  do
    _positional_names="$_positional_names _arg_leftovers[$((ii + 0))]"
  done

  shift "$_shift_for"
  for _positional_name in ${_positional_names}
  do
    test $# -gt 0 || break
    eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
    shift
  done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

if [[ -z "$_docker" || "$_docker" == "TODO" ]] ; then
  echo "The Docker image name is not configured yet!"
  echo "Please set the '_docker' variable at the top of this script to an accessible 'argbash' docker image name."
  echo "Example: _docker=\"accetto/argbash-docker:latest\""
  exit 1
fi
if [[ -z "$_workdir" || "$_workdir" == "TODO" ]] ; then
  echo "The working directory is not configured yet!"
  echo "Please set the '_workdir' variable at the top of this script accordingly."
  echo "Note that Docker containers must have writing permissions for the working directory."
  echo "Example (Linux): _workdir=\"/home/docker/volumes/argbash/work\""
  echo "Example (Windows): _workdir=\"C:/docker/volumes/argbash/work\""
  exit 1
fi

if [ ! -f "$_arg_template" ] ; then
  echo "Template file \"$_workdir/$_arg_template\" not found!"
  exit 1
fi

if [[ "$_arg_template" =~ m4$ ]] ; then
  ### do not overwrite M4 templates
  if [ -z "$_arg_output" ] ; then echo "M4-template requires an explicit output file. Provide the option [-o|--output <arg>]." ; exit 1 ; fi
fi

if [ -z "$_arg_output" ] ; then
  ### output file option not provided - overwrite the template
  ### flatten the leftovers array first
  _leftovers=$( IFS=$' '; echo "${_arg_leftovers[*]}" )
  _cmd="docker run -it --rm -e PROGRAM=argbash -v ${_workdir}:/work ${_docker} ${_arg_template} -o ${_arg_template} ${_leftovers}"
else
  ### output file option provided - pass on all arguments
  _cmd="docker run -it --rm -e PROGRAM=argbash -v ${_workdir}:/work ${_docker} ${@}"
fi

echo "$_cmd"

if ( $_cmd ) ; then
  echo "Template file \"$_arg_template\" has been sucessfully processed into the working directory."
else
  echo "ERROR! Something went wrong. Try to check the provided arguments, configuration and 'argbash' documentation."
fi

# ] <-- needed because of Argbash
