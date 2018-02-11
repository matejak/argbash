dnl And stop those annoying diversion warnings
m4_define([_m4_divert(STDOUT2)], 2)
dnl We wrap the generated stuff into m4_ignore, so when we re-run the script, the results will be +- the same. Devillish!
m4_define([_ARGBASH_GO], [m4_do(
	[ARGBASH_GO_BASE($@)],
	[[
# @<:@ <-- needed because of Argbash]],
	[m4_divert_text([STDOUT2], [[# @:>@ <-- needed because of Argbash]])],
)])
m4_divert_push([STDOUT])dnl
