
/// feather ignore all

#macro private

/// Creates and handles a new Agenda.
/// @param {any}		scope	The scope to bind the handler to.
/// @param {function}	handler Handler function or method.
/// @param {any}		[value]	Optional value passed as an argument into the handler.
function Agenda(_scope, _handler, _value = undefined): __Agenda(_scope, _handler) constructor {
	handle(_value)
}

/// Alias of new Agenda(...)
function agenda_create(_scope, _handler, _value = undefined) {
	return new Agenda(_scope, _handler, _value)
}

private function __Agenda(_scope, _handler, _source_todo = undefined) constructor {
	private scope = _scope
	private handler = _handler
	private source_todo = _source_todo
	private todo_list = []
	private is_handling = false
	private is_handled = false
	private is_resolved = false
	private value = undefined
	private next_agenda = undefined
	private finally_callback = undefined
	private repeat_predicate = undefined
	
	private static assert = function(_expression, _error_message) {
		if !_expression {
			show_error(_error_message, true)
		}

		return _expression
	}

	private static handle = function(_value) {
		var _handler = method(scope, handler)
		is_handling = true
		value = _handler(self, _value) ?? _value
		is_handling = false
		is_handled = true
		attempt_to_resolve()
	}

	private static attempt_to_resolve = function() {
		if !is_resolved && is_handled && array_length(todo_list) == 0 {
			if repeat_predicate && !repeat_predicate(value) {
				handle(value)
			}
			else if finally_callback {
				finally_callback(value)
				if source_todo {
					source_todo.complete()
				}
				is_resolved = true
			}
			else if next_agenda {
				next_agenda.handle(value)
				is_resolved = true
			}
		}
	}

	private static complete_todo = function(_todo) {
		if !_todo.is_completed {
			exit
		}

		for(var _i = 0, _n = array_length(todo_list); _i < _n; _i ++) {
			if todo_list[_i] == _todo {
				array_delete(todo_list, _i, 1)
				attempt_to_resolve()
				break
			}
		}
	}

	/// Creates and returns a new Todo. Must be called within the handler function.
	static create_todo = function() {
		assert(is_handling, "Agenda Error: Todos cannot be created outside of the handler.")

		var _todo = new __Agenda_Todo(self)
		array_push(todo_list, _todo)

		return _todo
	}

	/// Cancels this Agenda by removing its ability to be resolved. Must be called within the handler function.
	/// @param {bool} do_complete_source_todo If true, and if one exists, completes the defined source_todo.
	static cancel = function(_do_complete_source_todo = false) {
		assert(is_handling, "Agenda Error: Agendas cannot be canceled outside of the handler.")

		if _do_complete_source_todo && source_todo {
			source_todo.complete()
		}

		is_resolved = true
	}

	/// Creates and returns a new Agenda to be handled after this Agenda is resolved.
	/// @param {function} handler Function or method.
	static and_then = function(_handler) {
		assert(!is_handling, "Agenda Error: and_then cannot be called within the handler.")
		assert(!finally_callback, "Agenda Error: and_then cannot be called on this Agenda if and_finally has already been called.")

		next_agenda = new __Agenda(scope, _handler, source_todo)
		attempt_to_resolve()

		return next_agenda
	}

	/// Repeats this Agenda with the value its handler returned until the predicate returns false.
	/// @param {function} repeat_predicate Accepts the value returned by the previous Agenda as an argument. Must return true or false.
	static and_repeat_until = function(_repeat_predicate) {
		assert(!is_handling, "Agenda Error: and_repeat_until cannot be called within the handler.")

		repeat_predicate = _repeat_predicate
		attempt_to_resolve()

		return self
	}

	/// Assigns a final callback to be executed after the current Agenda is resolved.
	/// @param {function} callback Optional function or method.
	static and_finally = function(_callback = undefined) {
		assert(!is_handling, "Agenda Error: and_finally cannot be called within the handler.")
		assert(!next_agenda, "Agenda Error: and_finally cannot be called on this Agenda if and_then has already been called.")

		finally_callback = method(scope, _callback ?? function(){})
		attempt_to_resolve()
	}
}

private function __Agenda_Todo(_agenda) constructor {
	private on_complete = method(_agenda, _agenda.complete_todo)
	private is_completed = false

	/// Completes this Todo.
	static complete = function() {
		if is_completed {
			exit
		}

		is_completed = true
		on_complete(self)
	}

	/// Creates a new Agenda from this Todo and executes its handler. Returns the newly created Agenda.
	/// @param {any}		scope	The scope to bind the handler to.
	/// @param {function}	handler Handler function or method.
	/// @param {any}		[value]	Optional value passed as an argument into the handler.
	static agenda = function(_scope, _handler, _value = undefined) {
		var _agenda = new __Agenda(_scope, _handler, self)
		_agenda.handle(_value)

		return _agenda
	}
}
