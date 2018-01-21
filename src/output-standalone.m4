m4_define([_ARGBASH_GO], [m4_do(
	[ARGBASH_GO_BASE($@)],
	[m4_divert_pop([STDOUT])],
)])
m4_divert_push([STDOUT])dnl
