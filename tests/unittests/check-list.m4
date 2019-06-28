m4_include([utilities.m4])
m4_include_once([test-support.m4])

dnl If BOMB gets expanded, we will be noticed.
assert_equals(m4_quote(m4_list_contents([lol])), [])
assert_equals(m4_quote(m4_list_nth([lol], , x)), [x])
assert_equals(m4_quote(m4_list_indices([lol], [lala])), [])
m4_list_declare([FOO])
assert_equals(m4_list_len([FOO]), 0)
assert_equals(m4_list_len([NOLIST]), 0)
assert_equals(m4_quote(m4_argn(1, m4_list_foreach([FOO], [item], [-item-,]))), [])
m4_list_ifempty([FOO], ,[m4_fatal([The list is supposed to be empty now])])
m4_list_append([FOO], [BOMB])
m4_list_ifempty([FOO], [m4_fatal([The list is supposed to be non-empty now])],)
assert_equals(m4_list_len([FOO]), 1)
m4_list_append([FOO], [ANTIFUSE(list)])
m4_list_append([FOO], [BOMB], [BAZ])
assert_equals(m4_quote(m4_list_nth([FOO], 9, x)), [x])
assert_equals(m4_list_nth([FOO], 4), [BAZ])
assert_equals(m4_list_nth([FOO], m4_list_indices([FOO], [BAZ])), [BAZ])
assert_equals(m4_list_join([FOO], -), [BOMB-ANTIFUSE(list)-BOMB-BAZ])
assert_equals(m4_list_join([FOO], -, ", ', [ and ]), ["BOMB'-"ANTIFUSE(list)'-"BOMB' and "BAZ'])
assert_equals(m4_expand([m4_list_join([FOO], [,], ", ', [ , ])]), ["BOMB',"ANTIFUSE(list)',"BOMB' , "BAZ'])
m4_list_append([FOO], [BAZ2])
assert_equals(m4_list_len([FOO]), 5)

dnl Try a simple sum
m4_list_append([nums], [1])
m4_list_append([nums], [8])
m4_list_append([nums],[-5])
m4_list_append([nums],[12])
m4_list_append([nums], [0])
dnl Sum is ........ 16
assert_equals(m4_list_sum([nums]), 16)

m4_ifnblank(m4_expand([m4_list_append([FOO], [])m4_list_append([FOO], [--LALA])]),
	[m4_fatal([Leaking text in m4_list_append])])
assert_equals(m4_list_nth([FOO], 1), [BOMB])
m4_ifnblank(
	m4_list_nth([FOO], 6),
	[m4_fatal([Item ]m4_list_nth([FOO], 5)[ is not blank.])])
assert_equals(m4_list_nth([FOO], 7), [--LALA])
dnl The list items should be single-quoted only, so passing them to m4_expand should expand them.
m4_expand(m4_list_nth([FOO], 2))
ANTIBOMB([list])
assert_equals(m4_quote(m4_argn(1, m4_list_foreach([FOO], [item], [-item-,]))), [-BOMB-])
assert_equals(m4_quote(m4_argn(1, m4_lists_foreach([FOO,FOO], [item,item2], [-item-item2-,]))), [-BOMB-BOMB-])
assert_equals(m4_list_len([FOO]), 7)
assert_equals(m4_quote(m4_list_indices([FOO], [BOMB])), [1,3])
assert_equals(m4_quote(m4_list_indices([FOO], [BAZ])), 4)
assert_equals(m4_quote(m4_list_indices([FOO], [BAM])), [])
assert_equals(m4_quote(m4_list_pop_front([FOO])), [BOMB])
assert_equals(m4_quote(m4_list_indices([FOO], [BOMB])), [2])
assert_equals(m4_quote(m4_list_contains([FOO], [BOMB], 3, 4)), [3])
assert_equals(m4_quote(m4_list_contains([FOO], [lalala], 3, 4)), [4])
assert_equals(m4_list_len([FOO]), 6)
assert_equals(m4_quote(m4_list_pop_back([FOO])), [--LALA])
assert_equals(m4_list_len([FOO]), 5)
dnl After pop
assert_equals(m4_list_nth([FOO], 2), [BOMB])

m4_list_append([EMPTY], [])
m4_list_append([EMPTY], [second])

assert_equals(m4_list_nth([EMPTY], 1), [])
assert_equals(m4_list_nth([EMPTY], 2), [second])
assert_equals(m4_list_len([EMPTY]), 2)
m4_ignore([
m4_divert_push(0)dnl
])
]) dnl m4_ignore
