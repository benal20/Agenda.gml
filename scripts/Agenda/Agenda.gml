
/// feather ignore all

function __Agenda(_scope = {}, _handler) constructor{
	__scope = _scope
	__handler = _handler
	__todo_list = []
	__is_handled = false
	__is_handling = false
	__value = undefined
	__next_agenda = undefined
	__final_callback = undefined
	
	/// Creates and returns a new Todo. Must be called within the handler function.
	static create_todo = function() {
		if !__is_handling {
			show_error("Agenda Error: Todos cannot be created outside of the handler!", true)
		}
		
		var _todo = new __Todo(self)
		array_push(__todo_list, _todo)
		
		return _todo
	}
	
	/// Creates and returns a new Agenda to be handled after the current Agenda is resolved. Cannot be called within the handler.
	/// @param {function} handler function or method
	static and_then = function(_handler) {
		if __is_handling {
			show_error("Agenda Error: and_then cannot be called within the handler!", true)
		}
		
		__next_agenda = new __Agenda(__scope, _handler)
		
		return __next_agenda
	}
	
	/// Creates a callback to be handled after the current Agenda is resolved. Cannot be called within the handler.
	/// @param {function} callback function or method
	static and_finally = function(_callback) {
		if __is_handling {
			show_error("Agenda Error: and_finally cannot be called within the handler!", true)
		}
		
		__final_callback = method(__scope, _callback)
	}
	
	static __attempt_to_resolve = function() {
		if __is_handled && array_length(__todo_list) == 0 {
			if __final_callback {
				__final_callback(__value)
			}
			else if __next_agenda {
				__next_agenda.__handle(__value)
			}
		}
	}
	
	static __complete_todo = function(_todo) {
		if !_todo.__is_completed {
			exit
		}
		
		for(var _i = 0; _i < array_length(__todo_list); _i ++) {
			if __todo_list[_i] == _todo {
				array_delete(__todo_list, _i, 1)
				break
			}
		}
		__attempt_to_resolve()
	}
	
	static __handle = function(_value) {
		var _handler = method(__scope, __handler)
		__is_handling = true
		__value = _handler(self, _value) ?? _value
		__is_handling = false
		__is_handled = true
		__attempt_to_resolve()
	}
}

function __Todo(_agenda) constructor{
	__on_complete = method(_agenda, _agenda.__complete_todo)
	__is_completed = false
	
	static complete = function() {
		if __is_completed {
			exit
		}
		
		__is_completed = true
		__on_complete(self)
	}
}

/// Creates a new Agenda and executes its handler. Returns the newly created Agenda.
/// @param	{any}		scope	the scope to bind the handler to
/// @param	{function}	handler handler function or method
/// @param	{any}		[value]	optional value passed as an argument into the handler
function agenda_create(_scope, _handler, _value = undefined) {
	var _agenda = new __Agenda(_scope, _handler)
	_agenda.__handle(_value)
	
	return _agenda
}
