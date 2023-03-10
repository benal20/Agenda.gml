
/// feather ignore all

function __Agenda(_scope, _handler, _source_todo = undefined) constructor {
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
	__repeat_predicate = undefined
	
	/// Creates and returns a new Todo. Must be called within the handler function.
	static create_todo = function() {
		assert(__is_handling, "Agenda Error: Todos cannot be created outside of the handler.")
		
		var _todo = new __Todo(self)
		array_push(__todo_list, _todo)
		
		return _todo
	}
	
	/// Cancels the Agenda, preventing it from chaining any further. Must be called within the handler function.
	/// @param {bool} do_complete_source_todo If true, and if one exists, completes the defined source_todo.
	static cancel = function(_do_complete_source_todo = false) {
		assert(__is_handling, "Agenda Error: Agendas cannot be canceled outside of the handler.")
		
		if _do_complete_source_todo && __source_todo {
			__source_todo.complete()
		}
		
		__is_resolved = true
	}
	
	/// Creates and returns a new Agenda to be handled after the current Agenda is resolved.
	/// @param {function} handler Function or method.
	static and_then = function(_handler) {
		assert(!__is_handling, "Agenda Error: and_then cannot be called within the handler.")
		assert(!__finally_callback, "Agenda Error: and_next cannot be called on this Agenda if and_finally has already been called.")
		
		__next_agenda = new __Agenda(__scope, _handler, __source_todo)
		__attempt_to_resolve()
		
		return __next_agenda
	}
	
	/// Repeats the previous Agenda with the value its handler returned until this predicate returns false.
	/// @param {function} repeat_predicate Accepts the value returned by the previous Agenda as an argument. Must return true or false.
	static and_repeat_until = function(_repeat_predicate) {
		assert(!__is_handling, "Agenda Error: and_repeat_until cannot be called within the handler.")
		
		__repeat_predicate = _repeat_predicate
		__attempt_to_resolve()
		
		return self
	}
	
	/// Assigns a final callback to be executed after the current Agenda is resolved.
	/// @param {function} callback Optional function or method.
	static and_finally = function(_callback = undefined) {
		assert(!__is_handling, "Agenda Error: and_finally cannot be called within the handler.")
		assert(!__next_agenda, "Agenda Error: and_finally cannot be called on this Agenda if and_then has already been called.")
		
		__finally_callback = method(__scope, _callback ?? function(){})
		__attempt_to_resolve()
	}
	
	static __attempt_to_resolve = function() {		
		if !__is_resolved && __is_handled && array_length(__todo_list) == 0 {
			if __repeat_predicate && !__repeat_predicate(__value) {
				__handle(__value)
			}
			else if __finally_callback {
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
