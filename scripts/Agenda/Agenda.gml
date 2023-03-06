
/// feather ignore all

function __Agenda(_target, _handler) constructor{
	if !is_method(_handler) {
		show_error("handler is not a method", true)
	}
	
	__target = _target
	__handler = _handler
	__next_agenda = undefined
	__final_callback = undefined
	__value = undefined
	__todo_count = 0
	__locked = false
	
	static and_then = function(_handler) {
		__next_agenda = new __Agenda(__target, _handler)
		
		return __next_agenda
	}
	
	static and_finally = function(_callback) {
		__final_callback = method(__target, _callback)
	}
	
	static __attempt_to_resolve = function() {
		if __locked && __todo_count == 0 {
			if __final_callback {
				__final_callback(__value)
			}
			else if __next_agenda {
				__next_agenda.__handle(__value)
			}
		}
	}
	
	static __create_todo = function() {
		__todo_count ++
		
		return new __Todo(self)
	}
	
	static __finish_todo = function() {
		__todo_count --
		__attempt_to_resolve()
	}
	
	static __handle = function(_value) {
		var _handler = method(__target, __handler)
		__value = _handler(method(self, __create_todo), _value)
		__locked = true
		__attempt_to_resolve()
	}
}

function __Todo(_agenda) constructor{
	__on_finish = method(_agenda, _agenda.__finish_todo)
	__is_finished = false
	
	static finish = function() {
		if __is_finished {
			exit
		}
		
		__is_finished = true
		__on_finish()
	}
}

/// @func agenda_create(target, handler, value)
/// @param	{any}		target	target instance id or struct
/// @param	{function}	handler handler method
/// @param	{any}		[value]	optional value passed into the handler
/// @return	{struct}	agenda	the newly created agenda
function agenda_create(_target, _handler, _value = undefined) {
	var _agenda = new __Agenda(_target, _handler)
	_agenda.__handle(_value)
	
	return _agenda
}
