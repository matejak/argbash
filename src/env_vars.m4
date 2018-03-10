

dnl
dnl Given an env variable name, assign a default value to it (if it is empty)
dnl  $1 - env var
dnl  $2 - default value (optional, but maybe it shouldn't be blank unless we have $# >=4)
dnl  $3 - help message (optional)
dnl  $4 - (don't implement now) arg name the env var can default to (none by default, the env default's priority is higher than default's priority, but lower than actual argument value)
dnl
dnl  internally:
dnl  ENV_NAMES, ENV_DEFAULTS, ENV_HELPS, ENV_ARGNAMES
dnl TODO: Hanlde the case of wrapping correctly
dnl TODO: Find out a proper name for this
argbash_api([ARG_USE_ENV], [m4_ifndef([WRAPPED_FILE_STEM], [m4_do(
	[[$0($@)]],
	[m4_list_append([ENV_NAMES], [$1])],
	[m4_list_append([ENV_DEFAULTS], [$2])],
	[m4_list_append([ENV_HELPS], [$3])],
	[m4_list_append([ENV_ARGNAMES], [$4])],
)])])


m4_define([_SETTLE_ENV], [m4_list_ifempty([ENV_NAMES], , [m4_lists_foreach([ENV_NAMES,ENV_DEFAULTS], [_name,_default], [m4_do(
	[# Setting environmental variables
],
	[m4_ifnblank(m4_quote(_default), [m4_list_append([_OTHER],
		m4_expand([__SETTLE_ENV(m4_expand([_name]), m4_expand([_default]))]))])],
)])]
)])


dnl
dnl $1: name
dnl $2: default
dnl TODO: Try to use the 'declare' builtin to see whether the variable is even defined
m4_define([__SETTLE_ENV], [m4_do(
	[test -n "@S|@$1" || $1="$2"
],
)])

