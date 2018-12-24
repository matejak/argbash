
m4_define([_SYNOPSIS_OF_OPTIONAL_ARGS], [m4_lists_foreach_optional([_ARGS_LONG,_ARGS_SHORT,_ARGS_CATH], [_argname,_arg_short,_arg_type], [m4_do(
	[ @<:@],
	[m4_case(_arg_type,
		[bool], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, )],
		[arg], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, , _CAPITALIZE(_argname))],
		[repeated], [_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, , _CAPITALIZE(_argname))],
		[_FORMAT_OPTIONAL_ARGUMENT_FOR_HELP_SYNOPSIS(_argname, )])],
	[@:>@],
	[m4_case(_arg_type,
		[repeated], [...],
		[incr], [...],
		[])],
)])])

