m4_define([assert_equals],
	[m4_if(
		[$1],
		[$2],
		[],
		[m4_fatal(m4_ifnblank([$3], [$3: ])[Item '$1' doesn't match '$2'.])])])

m4_define([assert_not_equals],
	[m4_if(
		[$1],
		[$2],
		[m4_fatal(m4_ifnblank([$3], [$3: ])[Item '$1' matches '$2', although it shouldn't.])])])

m4_define([assert_equals_list_element], [m4_do(
	[m4_define([_ASEQ_LIST], [[$1]])],
	[m4_define([_ASEQ_ELEMENT], [m4_default([$2], 1)])],
	[assert_equals(m4_list_nth(_ASEQ_LIST, _ASEQ_ELEMENT), [$3])],
)])

m4_define([assert_equals_list_next], [m4_do(
	[m4_define([_ASEQ_ELEMENT], m4_incr(_ASEQ_ELEMENT))],
	[assert_equals(m4_list_nth(_ASEQ_LIST, _ASEQ_ELEMENT), [$1])],
)])

m4_define([BOMB], [m4_fatal(m4_ifblank([$1], [[Bomb has been expanded, which shouldn't happen]], [[$1]]))])
m4_define([BOMB2], [m4_fatal(m4_ifblank([$1], [[Bomb2 has been expanded, which shouldn't happen]], [[$1]]))])
m4_define([ANTIBOMB], [m4_ifndef([$1], [m4_fatal([We have expected '$1' to be defined])])])
m4_define([ANTIFUSE], [m4_define([$1])])

dnl Usage:
dnl
dnl To ensure proper quoting:
dnl  - BOMB must not expand
dnl  - use ANTIFUSE(xxx) followed by ANTIBOMB(xxx) - if ANTIFUSE was not expanded ANTIBOMB will fail.
