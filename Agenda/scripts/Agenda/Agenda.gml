
/// @description Creates and handles a new Agenda.
/// @param {function}   handler Method used to create Todos for the Todo List. Takes this agenda and any additionally provided values as arguments.
/// @param {any}        [...]   Additional values that will be passed into the handler.
/// @return {struct.__Agenda}
function agenda_create(handler) {
	__GET_ARGS_AS_ARRAY
	array_delete(__arg_array, 0, 1)
	var agenda = new __Agenda(handler)
	with agenda {
		method_call(agenda.__handle, __arg_array)
	}
	return agenda
}

/// @description Creates and handles a new Agenda which resolves after a set amount of time.
/// @param {real}   time    Amount of time to delay.
/// @param {any}    [...]	Additional values that will be pased into the handler.
/// @return {struct.__Agenda}
function agenda_delay(time) {
	__GET_ARGS_AS_ARRAY
	var agenda = new __Agenda(function(agenda, time) {
		__GET_ARGS_AS_ARRAY
		agenda.delay(time)
		array_delete(__arg_array, 0, 2)
		return __arg_array
	})
	with agenda {
		method_call(agenda.__handle, __arg_array)
	}
	return agenda
}


// Agenda internals

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

/// @ignore
function __Agenda(handler, parent_todo = undefined) constructor {
	self.handler = method(method_get_self(handler), handler)
	self.parent_todo = parent_todo
	
	self.todo_list = []
	self.state = AGENDA_STATE.UNHANDLED
	self.previous_agenda = undefined
	self.arg_array = []
	
	self.next_agenda = undefined
	self.finally_callback = undefined
	self.repeat_predicate = undefined
    
    /// @ignore
	static __handle = function() {
		__GET_ARGS_AS_ARRAY
		array_insert(__arg_array, 0, self)
		self.state = AGENDA_STATE.HANDLING
		var returned_arg_array = method_call(self.handler, __arg_array)
		if self.state == AGENDA_STATE.CANCELED {
			exit
		}
		
		if returned_arg_array == undefined {
			array_delete(__arg_array, 0, 1)
			self.arg_array = __arg_array
		}
		else {
			if is_array(returned_arg_array) {
				if array_length(returned_arg_array) > 0 {
					self.arg_array = returned_arg_array
				}
			}
			else {
				self.arg_array = [returned_arg_array]
			}
		}
		self.state = AGENDA_STATE.HANDLED
		self.__attempt_to_resolve()
	}

    /// @ignore
	static __attempt_to_resolve = function() {
		if self.state == AGENDA_STATE.HANDLED && array_length(self.todo_list) == 0 {
			if self.repeat_predicate && !method_call(self.repeat_predicate, self.arg_array) {
				if self.state == AGENDA_STATE.CANCELED {
					exit
				}
				method_call(self.__handle, self.arg_array)
			}
			else if self.finally_callback {
				self.arg_array = method_call(self.finally_callback, self.arg_array)
				if self.state == AGENDA_STATE.CANCELED {
					exit
				}
				if self.parent_todo {
					with self.parent_todo {
						method_call(self.complete, other.arg_array ?? [])
					}
				}
				self.state = AGENDA_STATE.RESOLVED
				self.previous_agenda = undefined
			}
			else if self.next_agenda {
				with self.next_agenda {
					var args = array_length(self.arg_array) > 0 ? self.arg_array : other.arg_array
					method_call(self.__handle, args)
				}
				if self.state == AGENDA_STATE.CANCELED {
					exit
				}
				self.state = AGENDA_STATE.RESOLVED
				self.previous_agenda = undefined
			}
		}
	}

    /// @ignore
	static __complete_todo = function(todo) {
		__GET_ARGS_AS_ARRAY
		array_delete(__arg_array, 0, 1)
		if array_length(__arg_array) > 0 {
			self.arg_array = array_concat(self.arg_array, __arg_array)
		}

		for(var i = 0, n = array_length(self.todo_list); i < n; i ++) {
			if self.todo_list[i] == todo {
				array_delete(self.todo_list, i, 1)
				self.__attempt_to_resolve()
				break
			}
		}
	}

	/// @description Creates a new Todo. Must be called within the handler function.
    /// @return {Struct.__Agenda_Todo}
	static create_todo = function() {
		if !self.is_handling() {
            show_error("Agenda.create_todo can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			exit
		}

		var todo = new __Agenda_Todo(self)
		array_push(self.todo_list, todo)

		return todo
	}
	
	/// @description Alias for create_todo().delay_then_complete(time)
	/// @param {Real} time	Amount of time to delay.
    /// @return {Id.TimeSource}
	static delay = function(time) {
		if !self.is_handling() {
            show_error("Agenda.delay can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			exit
		}
		
		return self.create_todo().delay_then_complete(time)
	}
    
    /// @description Alias of create_todo().animate(anim_curve, time, callback, ...)
    /// @param {Id.AnimationCurve}  anim_curve  The anim curve to use.
    /// @param {real}               time        Amount of time to animate for.
    /// @param {function}           callback    The method to run every frame over the animation curve.
    /// @param {any}		        [...]	    Additional values that will be passed into the callback.
    /// @return {Id.TimeSource}
    static animate = function(anim_curve, time, callback) {
        __GET_ARGS_AS_ARRAY
        var todo = self.create_todo()
        with todo {
            return method_call(self.animate, __arg_array)
        }
    }
	
	/// @description Alias for as create_todo().extend(...)
    /// @param {function}   handler Method used to create Todos for the Todo List. Takes this agenda and any additionally provided values as arguments.
    /// @param {any}        [...]   Additional values that will be passed into the handler.
    /// @return {Struct.__Agenda}
	static extend = function(handler) {
		if !self.is_handling() {
            show_error("Agenda.extend can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			exit
		}
		
		__GET_ARGS_AS_ARRAY
		var todo = self.create_todo()
		with todo {
			return method_call(self.extend, __arg_array)
		}
	}
	
	/// @description Extends and returns the Agenda with a delay.
	/// @param {real} time    Amount of time to delay.
    /// @param {any}  [...]   Additional values that will be passed into the handler.
    /// @return {Struct.__Agenda}
	static extend_delay = function(time) {
		if !self.is_handling() {
            show_error("Agenda.extend_delay can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			exit
		}
		
		__GET_ARGS_AS_ARRAY
		var todo = self.create_todo()
		with todo {
			return method_call(self.extend_delay, __arg_array)
		}
	}

	/// @description Cancels this Agenda and all other Agendas chained onto it and off of it.
	/// @param {bool} cancel_parent_todo If true, and if one exists, cancel the defined parent_todo. Otherwise, complete it.
	static cancel = function(cancel_parent_todo = false) {
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			exit
		}

		self.state = AGENDA_STATE.CANCELED
		
		var is_final_agenda = true
		for(var i = 0, n = array_length(self.todo_list); i < n; i ++) {
			var todo = self.todo_list[i]
			todo.cancel()
		}
		if self.next_agenda {
			is_final_agenda = false
			self.next_agenda.cancel()
		}
		if self.previous_agenda {
			is_final_agenda = false
			self.previous_agenda.cancel()
			self.previous_agenda = undefined
		}
		
		if is_final_agenda && self.parent_todo {
			if cancel_parent_todo {
				self.parent_todo.cancel()
			}
			else {
				self.parent_todo.complete()
			}
		}
	}

	/// @description Creates and returns a new Agenda to be handled after this Agenda is resolved.
    /// @param {function}   handler Method used to create Todos for the Todo List. Takes this agenda and any additionally provided values as arguments.
    /// @param {any}        [...]   Additional values that will be passed into the handler.
    /// @return {Struct.__Agenda}
	static and_then = function(handler) {
		if self.is_handling() {
            show_error("Agenda.and_then cannot be called from within the handler method.", true)
        }
		if self.next_agenda {
            show_error("Agenda.and_then cannot be called if Agenda.and_then has already been called.", true)
        }
		if self.finally_callback {
            show_error("Agenda.and_then cannot be called if Agenda.and_finally has already been called.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			exit
		}
		
		__GET_ARGS_AS_ARRAY
		array_delete(__arg_array, 0, 1)

		self.next_agenda = new __Agenda(handler, self.parent_todo)
		self.next_agenda.previous_agenda = self
		self.next_agenda.arg_array = __arg_array
		self.__attempt_to_resolve()

		return self.next_agenda
	}

	/// @description Repeats this Agenda with the value its handler returned until the predicate returns false.
	/// @param {function} repeat_predicate Accepts the value returned by the previous Agenda as an argument. Must return true or false.
    /// @return {Struct.__Agenda}
	static and_repeat_until = function(repeat_predicate) {
		if self.is_handling() {
            show_error("Agenda.and_repeat_until cannot be called from within the handler method.", true)
        }
		if self.next_agenda {
            show_error("Agenda.and_repeat_until cannot be called if Agenda.and_then has already been called.", true)
        }
		if self.repeat_predicate {
            show_error("Agenda.and_repeat_until cannot be called if Agenda.and_repeat_until has already been called.", true)
        }
		if self.finally_callback {
            show_error("Agenda.and_repeat_until cannot be called if Agenda.and_finally has already been called.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			exit
		}

		self.repeat_predicate = method(method_get_self(repeat_predicate), repeat_predicate)
		self.__attempt_to_resolve()

		return self
	}

	/// @description Assigns a final callback to be executed after the current Agenda is resolved.
	/// @param {function} callback Optional function or method.
    /// @return {Struct.__Agenda}
	static and_finally = function(callback = undefined) {
		if self.is_handling() {
            show_error("Agenda.and_finally cannot be called from within the handler method.", true)
        }
		if self.next_agenda {
            show_error("Agenda.and_finally cannot be called if Agenda.and_then has already been called.", true)
        }
		if self.finally_callback {
            show_error("Agenda.and_finally cannot be called if Agenda.and_finally has already been called.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			exit
		}

		if callback {
			self.finally_callback = method(method_get_self(callback), callback)
		}
		else {
			self.finally_callback = function(){}
		}
		
		self.__attempt_to_resolve()
		
		return self
	}
	
	/// @description Returns true if the Agenda is unhandled.
    /// @return {bool}
	static is_unhandled = function() {
		return self.state == AGENDA_STATE.UNHANDLED
	}
	
	/// @description Returns true if the Agenda is currently being handled.
    /// @return {bool}
	static is_handling = function() {
		return self.state == AGENDA_STATE.HANDLING
	}
	
	/// @description Returns true if the Agenda has been handled.
    /// @return {bool}
	static is_handled = function() {
		return self.state == AGENDA_STATE.HANDLED
	}
	
	/// @description Returns true if the Agenda is resolved.
    /// @return {bool}
	static is_resolved = function() {
		return self.state == AGENDA_STATE.RESOLVED
	}
	
	/// @description Returns true if the Agenda is canceled.
    /// @return {bool}
	static is_canceled = function() {
		return self.state == AGENDA_STATE.CANCELED
	}
	
	/// @description Returns the current state of the Agenda.
    /// @return {bool}
	static get_state = function() {
		return self.state
	}
}

/// @ignore
function __Agenda_Todo(agenda) constructor {
	self.on_complete = method(agenda, agenda.__complete_todo)
	self.on_cancel = method(agenda, agenda.cancel)
	
	self.state = AGENDA_TODO_STATE.INCOMPLETE
    self.time_source = undefined

	/// @description Completes this Todo.
	/// @param {any} [...] Additional values which overwrites the Agenda's values array if this agenda is the last to be completed.
	static complete = function() {
		__GET_ARGS_AS_ARRAY
		array_insert(__arg_array, 0, self)
		if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}

		self.state = AGENDA_TODO_STATE.COMPLETE
		method_call(self.on_complete, __arg_array)
	}
	
	/// @description Cancels this Todo and its Agenda chain.
	static cancel = function() {
		if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}
		
		self.state = AGENDA_TODO_STATE.CANCELED
		self.on_cancel(self)
	}
	
	/// @description Waits for a period of time, then completes the todo.
	/// @param {real} time   Amount of time to delay.
    /// @return {Id.TimeSource}
	static delay_then_complete = function(time) {
		if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}
		
		self.time_source = time_source_create(time_source_game, time, time_source_units_seconds, function() {
            time_source_destroy(self.time_source)
            self.time_source = undefined
            self.complete()
        })
        time_source_start(self.time_source)
        return self.time_source
	}
    
    /// @description Executes a provided callback every frame over a given time period and animation curve, completing the todo at the end.
    /// @param {Id.AnimationCurve}  anim_curve  The anim curve to use.
    /// @param {real}               time        Amount of time to animate for.
    /// @param {function}           callback    The method to run every frame over the animation curve.
    /// @param {any}		        [...]	    Additional values that will be passed into the callback.
    /// @return {Id.TimeSource}
    static animate = function(anim_curve, time, callback) {
        __GET_ARGS_AS_ARRAY
        array_insert(__arg_array, 0, current_time)
        self.time_source = time_source_create(time_source_game, 1, time_source_units_frames, function(start_time, anim_curve, time, callback) {
            __GET_ARGS_AS_ARRAY
            array_delete(__arg_array, 0, 4)
            var time_alpha = (current_time - start_time) / (time * 1000)
            if time_alpha > 1 {
                time_alpha = 1
            }
            
            var channel = animcurve_get_channel(anim_curve, 0)
            var curve_alpha = animcurve_channel_evaluate(channel, time_alpha)
            array_insert(__arg_array, 0, curve_alpha)
            method_call(callback, __arg_array)
            
            if time_alpha == 1 {
                time_source_destroy(self.time_source)
                self.time_source = undefined
                self.complete()
            }
            else {
                time_source_reset(self.time_source)
                time_source_start(self.time_source)
            }
        }, __arg_array)
        time_source_start(self.time_source)
        return self.time_source
    }

	/// @description Creates a new Agenda from this Todo and executes its handler. Returns the newly created Agenda.
    /// @param {function}   handler Method used to create Todos for the Todo List. Takes this agenda and any additionally provided values as arguments.
    /// @param {any}		[...]	Additional values that will be passed into the handler.
	static extend = function(handler) {
		if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}
		
		__GET_ARGS_AS_ARRAY
		var agenda = new __Agenda(handler, self)
		with agenda {
			method_call(self.__handle, __arg_array, 1)
		}

		return agenda
	}

	/// @description Creates a new Agenda from this Todo and resolves it after a delay. Returns the newly created Agenda.
	/// @param {real} time	Amount of time to delay.
    /// @param {any} [...]	Additional values that will be passed into the handler.
	static extend_delay = function(time) {
		if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}
		
		__GET_ARGS_AS_ARRAY
		var agenda = new __Agenda(function(agenda, time) {
			__GET_ARGS_AS_ARRAY
			agenda.delay(time)
			array_delete(__arg_array, 0, 2)
			return __arg_array
		}, self)
		with agenda {
			method_call(self.__handle, __arg_array)	
		}
		return agenda
	}
}
