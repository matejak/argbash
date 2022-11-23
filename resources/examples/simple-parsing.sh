#!/bin/bash

# ARG_POSITIONAL_SINGLE([filename])
# ARG_OPTIONAL_SINGLE([unit],[u],[What unit we accept (b for bytes, k for kibibytes, M for mebibytes)],[b])
# ARG_VERSION([echo $0 v0.1])
# ARG_OPTIONAL_BOOLEAN([verbose])
# ARG_HELP([This program tells you size of file that you pass to it in chosen units.])
# ARGBASH_SET_INDENT([  ])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.10.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.dev for more info


die()
{
  local _ret="${2:-1}"
  test "${_PRINT_HELP:-no}" = yes && print_help >&2
  echo "$1" >&2
  exit "${_ret}"
}


begins_with_short_option()
{
  local first_option all_short_options='uvh'
  first_option="${1:0:1}"
  test "${all_short_options}" = "${all_short_options/${first_option}/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_unit="b"
_arg_verbose="off"


print_help()
{
  printf '%s\n' "This program tells you size of file that you pass to it in chosen units."
  printf 'Usage: %s [-u|--unit <arg>] [-v|--version] [--(no-)verbose] [-h|--help] <filename>\n' "$0"
  printf '\t%s\n' "-u, --unit: What unit we accept (b for bytes, k for kibibytes, M for mebibytes) (default: 'b')"
  printf '\t%s\n' "-v, --version: Prints version"
  printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
  _positionals_count=0
  while test $# -gt 0
  do
    _key="$1"
    case "${_key}" in
      -u|--unit)
        test $# -lt 2 && die "Missing value for the optional argument '${_key}'." 1
        _arg_unit="$2"
        shift
        ;;
      --unit=*)
        _arg_unit="${_key##--unit=}"
        ;;
      -u*)
        _arg_unit="${_key##-u}"
        ;;
      -v|--version)
        echo $0 v0.1
        exit 0
        ;;
      -v*)
        echo $0 v0.1
        exit 0
        ;;
      --no-verbose|--verbose)
        _arg_verbose="on"
        test "${1:0:5}" = "--no-" && _arg_verbose="off"
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      -h*)
        print_help
        exit 0
        ;;
      *)
        _last_positional="$1"
        _positionals+=("${_last_positional}")
        _positionals_count=$((_positionals_count + 1))
        ;;
    esac
    shift
  done
}


handle_passed_args_count()
{
  local _required_args_string="'filename'"
  test "${_positionals_count}" -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 1 (namely: ${_required_args_string}), but got only ${_positionals_count}." 1
  test "${_positionals_count}" -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1 (namely: ${_required_args_string}), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
  local _positional_name _shift_for=$1
  _positional_names="_arg_filename "

  shift "${_shift_for}"
  for _positional_name in ${_positional_names}
  do
    test $# -gt 0 || break
    eval "${_positional_name}=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
    shift
  done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
