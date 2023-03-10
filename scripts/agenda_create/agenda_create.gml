
/// Creates a new Agenda and executes its handler. Returns the newly created Agenda.
/// @param {any}		scope	The scope to bind the handler to.
/// @param {function}	handler Handler function or method.
/// @param {any}		[value]	Optional value passed as an argument into the handler.
function agenda_create(_scope, _handler, _value = undefined) {
	var _agenda = new __Agenda(_scope, _handler)
	_agenda.__handle(_value)
	
	return _agenda
}
