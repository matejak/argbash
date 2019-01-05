dnl
dnl $1: List name
dnl $2: Variable name
dnl $3: Foreach body
m4_define([m4_list_foreach], [m4_list_ifempty([$1], ,
	[m4_foreach([$2], m4_quote(m4_dquote_elt(m4_list_contents([$1]))), [$3])])])


dnl $1: List names
dnl $2: If yes
dnl $3: If not
m4_define([_lists_same_len], [m4_if(m4_count($1), 1, [$2],
	[m4_if(m4_list_len(m4_car($1)), m4_list_len(m4_argn(2, $1)),
		[_lists_same_len(m4_expand([m4_shift($1)]), [$2], [$3])], [$3])])])


dnl
dnl $1: List of list names
dnl $2: List of var names
dnl $3: What
m4_define([m4_lists_foreach], [_lists_same_len([$1],
	[m4_do(
		[m4_pushdef([_varnames], m4_quote(m4_dquote_elt($2)))],
		[dnl How long is the first list
],
		[m4_pushdef([l_len], [m4_list_len(m4_car($1))])],
		[dnl How many of lists they are (on input)
],
		[m4_pushdef([l_count], [m4_count($1)])],
		[m4_if(l_count, 0, ,
			[m4_if(l_len, 0, , [m4_for([_idx_item], 1, l_len, 1, [m4_do(
				[dnl Go through all varnames and push the corresponding list value into it
],
				[m4_for([_idx_list], 1, l_count, 1, [m4_do(
					[m4_pushdef(m4_argn(_idx_list, _varnames), m4_dquote(m4_list_nth(m4_argn(_idx_list, $1), _idx_item)))],
				)])],
				[$3],
				[dnl After we do the loop body, pop all of the definitions
],
				[m4_for([_idx_list], 1, l_count, 1, [m4_do(
					[m4_popdef(m4_argn(_idx_list, _varnames))],
				)])],
		)])])])],
		[m4_popdef([l_count])],
		[m4_popdef([l_len])],
		[m4_popdef([_varnames])],
	)], [m4_fatal([Lists $1 don't have the same length.])])])

dnl
dnl $1: The list's ID
dnl $2, ... Items to be appended: DON'T QUOTE items too much before you add them, quotes will be escaped (m4_escape) and therefore ineffective in m4sugar!
m4_define([m4_list_append], [m4_do(
	[m4_for([idx], 2, $#, 1,
		[_m4_list_append_single($1, m4_argn(idx, $@))])],
)])

m4_define([_m4_list_append_single], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_ifndef(_LIST_NAME,
		[m4_define(_LIST_NAME, m4_dquote(m4_escape([$2])))],
		[m4_define(_LIST_NAME, m4_quote(m4_list_contents([$1]),)m4_dquote(m4_escape([$2])))],
	)],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([m4_list_len], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_ifndef(_LIST_NAME, 0, [m4_count(m4_indir(_LIST_NAME))])],
	[m4_popdef([_LIST_NAME])],
)])

dnl
dnl Pefrorm an action if a given list is empty
dnl $1: The list's ID
dnl $2: The action to do if the list is empty or not even defined
dnl $3: The action to do if the list is defined and non-empty
m4_define([m4_list_ifempty], [m4_if(m4_list_len([$1]), 0, [$2], [$3])])

dnl
dnl Given a list name, it expands to its contents, suitable to use e.g. in m4_foreach
dnl TODO: It produces a list of double-quoted items, which we maybe don't want
m4_define([m4_list_contents], [m4_do(
	[m4_if($#, 1, , [m4_fatal([$0: Expected exactly one argument, got $# instead (others were: ]m4_quote(m4_shift($@))[)])])],
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_ifndef(_LIST_NAME, [], [m4_dquote_elt(m4_indir(_LIST_NAME))])],
	[m4_popdef([_LIST_NAME])],
)])

dnl	[m4_ifndef(_LIST_NAME, [], m4_expand([m4_dquote_elt(m4_indir(_LIST_NAME))]))],

dnl
dnl Given a list name and an element, it returns list of indices of the element in the list
dnl or nothing if it has not been found
m4_define([m4_list_indices], [m4_do(
	[m4_define([_FOUND_IDX], 1)],
	[m4_define([_FOUND_RESULT], [])],
	[m4_foreach([elem], [m4_list_contents([$1])], [m4_do(
		[m4_if(elem, [$2], [m4_define([_FOUND_RESULT], m4_expand([_FOUND_RESULT,_FOUND_IDX]))])],
		[m4_define([_FOUND_IDX], m4_incr(_FOUND_IDX))],
	)])],
	[m4_expand(m4_cdr(_FOUND_RESULT))],
	[m4_undefine([_FOUND_RESULT])],
	[m4_undefine([_FOUND_IDX])],
)])


dnl
dnl Do something if the item is (isn't) in the list
dnl $1: List name
dnl $2: What
dnl $3: If it is there
dnl $4: If it is not there
m4_define([m4_list_contains],
	[m4_ifnblank(m4_list_indices([$1], [$2]), [$3], [$4])])

m4_define([m4_list_sum], [m4_do(
	[m4_eval(m4_quote(m4_join(+, m4_unquote(m4_list_contents([$1])))))],
)])


dnl
dnl $1: list name
dnl $2: With what to join
dnl $3: left quote
dnl $4: right quote
dnl $5: last join
m4_define([m4_list_join], [m4_do(
	[m4_pushdef([listlen], m4_list_len([$1]))],
	[m4_if(m4_cmp(listlen - 2, 0), 1,
		[m4_for([idx], 1, m4_eval(listlen - 2), 1, [[$3]m4_list_nth([$1], idx)[$4$2]])],
	)],
	[m4_if(m4_cmp(listlen - 1, 0), 1,
		[[$3]m4_list_nth([$1], m4_decr(listlen))[$4]m4_default([$5], [$2])],
	)],
	[m4_if(m4_cmp(listlen - 0, 0), 1,
		[[$3]m4_list_nth([$1], listlen)[$4]],
	)],
	[m4_popdef([listlen])],
)])

dnl
dnl Returns its n-th element, first item has index of 1.
dnl If the element index is wrong, return $3
m4_define([m4_list_nth], [m4_do(
	[m4_bmatch([$2], [[1-9][0-9]*], [m4_do(
		[m4_pushdef([_listlen], m4_list_len([$1]))],
		[m4_if(m4_cmp([$2], _listlen), 1, [m4_ifnblank([$3], [$3], [m4_fatal([The list '$1' has length of ]_listlen[, so element No. $2 is not available])])])],
		[m4_popdef([_listlen])],
		[m4_expand(m4_argn([$2], m4_list_contents([$1])))],
	)], [m4_ifnblank([$3], [$3], [m4_fatal([Requesting element $2 from list '$1': Only positive indices are available])])])],
)])

dnl
dnl The list loses its 1st element, which is also expanded by this macro.
m4_define([m4_list_pop_front], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_car(m4_unquote(_LIST_NAME))],
	[m4_define(_LIST_NAME, m4_cdr(m4_unquote(_LIST_NAME)))],
	[m4_popdef([_LIST_NAME])],
)])

dnl
dnl The list loses its last element, which is also expanded by this macro.
m4_define([m4_list_pop_back], [m4_do(
	[m4_pushdef([_LIST_NAME], [[_LIST_$1]])],
	[m4_define(_LIST_NAME, m4_dquote(m4_reverse(m4_unquote(_LIST_NAME))))],
	[m4_list_pop_front([$1])],
	[m4_define(_LIST_NAME, m4_dquote(m4_reverse(m4_unquote(_LIST_NAME))))],
	[m4_popdef([_LIST_NAME])],
)])

m4_define([m4_list_destroy], [m4_ifdef([_LIST_$1], [m4_undefine([_LIST_$1])])])
