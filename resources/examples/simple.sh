
#!/bin/bash

#
#
#
#
#
# # THE DEFAULTS INITIALIZATION
_ARG_UNIT=b

_ARG_VERBOSE=off


# THE PRINT HELP FUNCION
function print_help
{
	echo "Usage: $0 <filename> [--unit <arg>] [--version] [--(no-)verbose] [--help]"
	echo -e "\t<filename>: Positional arg"
	echo -e "\t-u,--unit: What unit we accept (b for bytes, k for kilobytes, M for megabytes) (default: 'b')"
	echo -e "\t-v,--version: Prints version"
	echo -e "\t--verbose,--no-verbose:  (default: 'off')"
	echo -e "\t-h,--help: Prints help"
}
# THE PARSING ITSELF
while test $# -gt 0
do
	_key="$1"
	case "$_key" in
		-u|--unit)
			_ARG_UNIT="$2"
			shift
			;;
		-v|--version)
			echo [b],[echo _LIST__ARGS_DEFAULT v0.1],[off],[print_help] v0.1
			exit 0
			;;
		--verbose)
			_ARG_VERBOSE="on"
			test "${1:0,5}" = "--no-" && _ARG_VERBOSE="off"
			;;
		-h|--help)
			print_help
			exit 0
			;;
		*)
		    	POSITIONALS+=("$1")
		    	# unknown option
			;;
	esac
	shift
done

POSITIONAL_NAMES=('_ARG_FILENAME' )
test ${#POSITIONALS[@]} -lt 1 && { echo "Not enough positional arguments." &1>2; print_help; exit 1; }
test ${#POSITIONALS[@]} -gt 1 && { echo "There were spurious positional arguments." &1>2; print_help; exit 1; }
for (( ii = 0; ii <  ${#POSITIONALS[@]}; ii++))
do
	eval "${POSITIONAL_NAMES[$ii]}=${POSITIONALS[$ii]}"
done

# opening escape square bracket:

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

# closing escape square bracket:
