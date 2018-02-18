m4_define([_ARGBASH_GO], [m4_do(
	[m4_divert_push([STDOUT])],
	[ARGBASH_GO_BASE([], m4_shift($@))],
	[m4_divert_pop([STDOUT])],
)])
