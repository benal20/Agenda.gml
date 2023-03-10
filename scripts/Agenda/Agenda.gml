
/// feather ignore all

function __Agenda(_scope, _handler, _source_todo = undefined) constructor{
	__scope = _scope
	__handler = _handler
	__source_todo = _source_todo
	__todo_list = []
	__is_handling = false
	__is_handled = false
	__is_resolved = false
	__value = undefined
	__next_agenda = undefined
	__finally_callback = undefined
	
	/// Creates and returns a new Todo. Must be called within the handler function.
	static create_todo = function() {
		assert(__is_handling, "Agenda Error: Todos cannot be created outside of the handler.")
		
		var _todo = new __Todo(self)
		array_push(__todo_list, _todo)
		
		return _todo
	}
	
	/// Cancels the Agenda, preventing it from chaining any further. Must be called within the handler function.
	/// @param {bool} do_complete_source_todo if true, and if one exists, completes the defined source_todo
	static cancel = function(_do_complete_source_todo = false) {
		assert(__is_handling, "Agenda Error: Agendas cannot be canceled outside of the handler.")
		
		if _do_complete_source_todo && __source_todo {
			__source_todo.complete()
		}
		
		__is_resolved = true
	}
	
	/// Creates and returns a new Agenda to be handled after the current Agenda is resolved.
	/// @param {function} handler function or method
	static and_then = function(_handler) {
		assert(!__is_handling, "Agenda Error: and_then cannot be called within the handler.")
		assert(!__finally_callback, "Agenda Error: and_next cannot be called on this Agenda if and_finally has already been called.")
		
		__next_agenda = new __Agenda(__scope, _handler, __source_todo)
		__attempt_to_resolve()
		
		return __next_agenda
	}
	
	/// Assigns a final callback to be executed after the current Agenda is resolved.
	/// @param {function} callback function or method
	static and_finally = function(_callback) {
		assert(!__is_handling, "Agenda Error: and_finally cannot be called within the handler.")
		assert(!__next_agenda, "Agenda Error: and_finally cannot be called on this Agenda if and_then has already been called.")
		
		__finally_callback = method(__scope, _callback)
		__attempt_to_resolve()
	}
	
	static __attempt_to_resolve = function() {		
		if !__is_resolved && __is_handled && array_length(__todo_list) == 0 {
			if __finally_callback {
				__finally_callback(__value)
				if __source_todo {
					__source_todo.complete()
				}
				__is_resolved = true
			}
			else if __next_agenda {
				__next_agenda.__handle(__value)
				__is_resolved = true
			}
			else if __source_todo {
				__source_todo.complete()
				__is_resolved = true
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
	
	/// Completes the Todo.
	static complete = function() {
		if __is_completed {
			exit
		}
		
		__is_completed = true
		__on_complete(self)
	}
	
	/// Creates a new Agenda from this Todo and executes its handler. Returns the newly created Agenda.
	static agenda = function(_scope, _handler, _value = undefined) {
		var _agenda = new __Agenda(_scope, _handler, self)
		_agenda.__handle(_value)
		
		return _agenda
	}
}

/// Creates a new Agenda and executes its handler. Returns the newly created Agenda.
/// @param {any}		scope	the scope to bind the handler to
/// @param {function}	handler handler function or method
/// @param {any}		[value]	optional value passed as an argument into the handler
function agenda_create(_scope, _handler, _value = undefined) {
	var _agenda = new __Agenda(_scope, _handler)
	_agenda.__handle(_value)
	
	return _agenda
}
