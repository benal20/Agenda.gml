
/// Feather ignore all

function __Todo(_agenda) constructor {
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
	/// @param {any}		scope	The scope to bind the handler to.
	/// @param {function}	handler Handler function or method.
	/// @param {any}		[value]	Optional value passed as an argument into the handler.
	static agenda = function(_scope, _handler, _value = undefined) {
		var _agenda = new __Agenda(_scope, _handler, self)
		_agenda.__handle(_value)
		
		return _agenda
	}
}
