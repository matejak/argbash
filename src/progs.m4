dnl A function for handling a generic program
dnl Macro:
dnl no args
m4_define([_CHECK_PROG_FACTORY_INDIR], [MAKE_FUNCTION(
	[[Checks for the program @S|@2, that can be optionally pin-pointed by @S|@1],
		[and fail with the @S|@3 error message if not successful.],
		[@S|@1: Name of the env var],
		[@S|@2: The program name],
		[@S|@3: The error message]],
	[check_prog],
	[_JOIN_INDENTED(1,
		[test -n "$_msg" || _msg="Unable to find a reachable executable '@S|@2'"],
		[eval "test -n \"\@S|@@S|@1\" || @S|@1=\"@S|@2\""],
		[eval "command -v \"\@S|@@S|@1\" > /dev/null 2> /dev/null" || die "$_msg" 1],
	)],
	[_msg="@S|@3"],
)])


dnl
dnl Works well when there is only one program wanted
dnl Macro:
dnl $1: The env var name
dnl $2: The prog name
dnl $3: The msg
dnl Function:
dnl no args
m4_define([_CHECK_PROG_FACTORY_SINGLE], [MAKE_FUNCTION(
	[],
	[check_prog_for_$1],
	[_JOIN_INDENTED(1,
		[test -n "@S|@$1" || $1="$2"],
		[$1="$(command -v "@S|@$1")" || die "m4_default([$3], [Unable to find a reachable executable '$2'])" 1],
	)])])


dnl
dnl $1 - prog name
dnl $2 - env var (default: argbash translit of prog name)
dnl $3 - msg if not OK (optional)
dnl $4 - help message (if you want to mention existence of this in the help)
dnl
dnl  In case of path issues (i.e. script is in a crontab), update the PATH variable yourself above the argbash code.
dnl
dnl  internally:
dnl  PROG_NAMES, PROG_VARS, PROG_MSGS, PROG_HELPS
argbash_api([ARG_USE_PROGRAM], [m4_ifndef([WRAPPED_FILE_STEM], [m4_do(
	[[$0($@)]],
	[m4_list_append([PROG_VARS], m4_default_quoted([$2], _translit_prog([$1])))],
	[m4_list_append([PROG_NAMES], [$1])],
	[m4_list_append([PROG_MSGS], [$3])],
	[m4_list_append([PROG_HELPS], [$4])],
)])])


dnl
dnl $1: A prologue message
m4_define([_HELP_PROGS], [m4_list_ifempty([PROG_VARS], , [m4_do(
	[m4_ifnblank([$1], [m4_n([$1])])],
	[m4_lists_foreach([PROG_VARS,PROG_NAMES,PROG_HELPS], [_envvarname,_progname,_proghelp], [m4_do(
		[_INDENT_()printf '%s: %s (define manually using %s)\n' "_progname" "_proghelp" "_envvarname"
],
	)])],
)])])


m4_define([_SETTLE_PROGS], [m4_list_ifempty([PROG_NAMES], , [m4_if(m4_list_len([PROG_NAMES]),
		1, [_SETTLE_ONE_PROG()],
		[_SETTLE_MORE_PROGS()])])])


m4_define([_SETTLE_MORE_PROGS], [m4_do(
	[_CHECK_PROG_FACTORY_INDIR()

],
	[# Make sure that m4_list_format_sequence([PROG_NAMES], [ and ]) are assigned to respective env vars.
],
	[m4_lists_foreach([PROG_VARS,PROG_NAMES,PROG_MSGS], [_envvarname,_progname,_progmsg], [m4_do(
		[check_prog "_envvarname" '_progname' _sh_quote(_progmsg)
],
)])],
)])


m4_define([_SETTLE_ONE_PROG], [m4_do(
	[_CHECK_PROG_FACTORY_SINGLE(m4_list_nth([PROG_VARS], 1), m4_list_nth([PROG_NAMES], 1), m4_list_nth([PROG_MSGS], 1))

],
	[check_prog_for_[]m4_list_nth([PROG_VARS], 1)
],
)])
