
/// @description Creates and handles a new Agenda.
/// @param {function}   handler Method used to create Todos for the Todo List. Takes this agenda and any additionally provided values as arguments.
/// @param {any}        [...]   Additional values that will be passed into the handler.
/// @return {struct.__Agenda}
function agenda_create(handler) {
	__GET_ARGS_AS_ARRAY
	array_delete(__arg_array, 0, 1)
	with new __Agenda(handler) {
		method_call(self.__handle, __arg_array)
        return self
	}
}
