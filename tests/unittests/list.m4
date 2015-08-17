m4_include([stuff.m4])

m4_define([BOMB], [m4_fatal(m4_ifblank([$1], [[Bomb $2 has been expanded, which shouldn't happen]], [[$1]]))])
m4_define([ANTIBOMB], [m4_ifndef([$1], [m4_fatal([We have expected '$1' to be defined])])])
m4_define([ANTIFUSE], [m4_define([$1])])

dnl If BOMB gets expanded, we will be noticed.
m4_list_add([FOO], [BOMB])), 
m4_list_add([FOO], [ANTIFUSE(list)])
m4_list_add([FOO], [BAZ])
m4_list_add([FOO], [BAZ2])
m4_ifnblank(m4_expand([m4_list_add([FOO], [])m4_list_add([FOO], [--LALA])]),
	[m4_fatal([Leaking text in m4_list_add])])
m4_if(
	m4_list_nth([FOO], 1),
	[BOMB], 
	[], 
	[m4_fatal([Item ]m4_list_nth([FOO], 1)[ don't match what it should])])
m4_ifnblank(
	m4_list_nth([FOO], 5),
	[m4_fatal([Item ]m4_list_nth([FOO], 5)[ is not blank.])])
m4_if(
	m4_list_nth([FOO], 6),
	[--LALA], 
	[], 
	[m4_fatal([Item ]m4_list_nth([FOO], 6)[ don't match what it should])])
m4_ignore([
])
dnl The list items should be single-quoted only, so passing them to m4_expand should expand them.
m4_expand(m4_list_nth([FOO], 2))
ANTIBOMB([list])
m4_list_declare([FOO])
m4_if(
	m4_argn(1, FOO_FOREACH([-item-,])),
	[-BOMB-],
	[],
	[m4_fatal([Item ]m4_argn(1, FOO_FOREACH([-item-,]))[ don't match what it should])])
dnl m4_divert_push(0)dnl
