
#macro __GET_ARGS_AS_ARRAY var __arg_array = []\
for(var __i = 0; __i < argument_count; __i ++) {\
	array_push(__arg_array, argument[__i])\
}

enum AGENDA_STATE {
	UNHANDLED,
	HANDLING,
	HANDLED,
	RESOLVED,
	CANCELED,
}

enum AGENDA_TODO_STATE {
	INCOMPLETE,
	COMPLETE,
	CANCELED,
}
