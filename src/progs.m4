dnl
dnl Macro:
dnl no args
dnl Function:
dnl $1: Name of the env var
dnl $2: The program name
dnl $3: The error message
m4_define([_CHECK_PROG_FACTORY_INDIR], [MAKE_FUNCTION(
	[check_prog],
	[_JOIN_INDENTED(1,
		[test -n "$_msg" || _msg="Unable to find a reachable executable '@S|@2'"],
		[eval "test -n \"@S|@@S|@1\" || @S|@1=\"@S|@2\""],
		[eval "test -x \"$(which \"@S|@2\")\" && @S|@1=\"$(which \"@S|@2\")\" || die \"$_msg\" 1"],
	)],
	[local _msg="@S|@3"],
)])


dnl
dnl Macro:
dnl $1: The env var name
dnl $2: The prog name
dnl $3: The msg
dnl Function:
dnl no args
m4_define([_CHECK_PROG_FACTORY_SINGLE], [MAKE_FUNCTION(
	[check_prog],
	[_JOIN_INDENTED(1,
		[test -n "@S|@$1" || $1="$2"],
		[test -x "$(which "@S|@$1")" && $1="$(which "@S|@$1")" || die "m4_default([$3], [Unable to find a reachable executable '$2'])" 1],
	)])])


dnl
dnl Given a program name, error messages and variable name, do this:
dnl  - if a var name is not empty, test the prog (find the file with rx permissions), if not OK, die with our msg
dnl  - else try: progname until RC == 0
dnl  - if nothing is found, die with provided msg
dnl  - if successful, save the form that works in a variable (i.e. don't try to make it an absolute path at all costs)
dnl
dnl $1 - env var (default: argbash translit of prog name)
dnl $2 - prog name
dnl $3 - msg if not OK
dnl $4 - help message (if you want to mention existence of this in the help)
dnl $5 - args (if you want to check args)
dnl
dnl  In case of path issues (i.e. script is in a crontab), update the PATH variable yourself above the argbash code.
dnl
dnl  internally:
dnl  PROG_NAMES, PROG_VARS, PROG_MSGS, PROG_HELPS, PROG_ARGS, PROG_HAVE_ARGS
argbash_api([ARG_USE_PROG], [m4_ifndef([WRAPPED_FILE_STEM], [m4_do(
	[m4_list_append([PROG_VARS], m4_default([$1], _translit_prog([$2])))],
	[m4_list_append([PROG_NAMES], [$2])],
	[m4_list_append([PROG_MSGS], [$3])],
	[m4_list_append([PROG_HELPS], [$4])],
	[m4_list_append([PROG_ARGS], [$5])],
	[dnl Even if $# == 5, $5 can be blank, which we support.
],
	[m4_list_append([PROG_HAVE_ARGS], m4_if([$#], 5, 1, 0))],
)])])


dnl
dnl $1: A prologue message
m4_define([_HELP_PROGS], [m4_list_ifempty([PROG_VARS], , [m4_do(
	[m4_n([$1])],
	[m4_for([idx], 1, m4_list_len([PROG_VARS]), 1, [m4_do(
		[],
	)])],
)])])
