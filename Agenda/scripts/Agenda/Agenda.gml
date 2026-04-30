
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
    self.canceled_callback = undefined
    
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
    /// @return {Struct.__Agenda_Todo,undefined}
	static create_todo = function() {
		if !self.is_handling() {
            show_error("Agenda.create_todo can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			return undefined
		}

		var todo = new __Agenda_Todo(self)
		array_push(self.todo_list, todo)

		return todo
	}
	
	/// @description Alias for create_todo().delay_then_complete(time)
	/// @param {Real} time	Amount of time to delay.
    /// @return {Id.TimeSource,undefined}
	static delay = function(time) {
		if !self.is_handling() {
            show_error("Agenda.delay can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			return undefined
		}
		
		return self.create_todo().delay_then_complete(time)
	}
	
	/// @description Alias for create_todo().defer_then_complete(time)
	/// @param {Real} [frames]	Amount of frames to defer.
    /// @return {Id.TimeSource,undefined}
	static defer = function(frames = 1) {
		if !self.is_handling() {
            show_error("Agenda.defer can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			return undefined
		}
		
		return self.create_todo().defer_then_complete(frames)
	}
    
    /// @description Alias for create_todo().delay_until_then_complete(predicate, ...)
    /// @param {function}  predicate The method to run every frame until it returns true.
    /// @param {any}	   [...]	 Additional values that will be passed into the predicate.
    /// @return {Id.TimeSource,undefined}
    static delay_until = function(predicate) {
		if !self.is_handling() {
            show_error("Agenda.delay_until can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			return undefined
		}
        
        __GET_ARGS_AS_ARRAY
        with self.create_todo() {
            return method_call(self.delay_until_then_complete, __arg_array)
        }
    }
    
    /// @description Alias of create_todo().tween_then_complete(anim_curve, time, callback, ...)
    /// @param {Id.AnimationCurve}  anim_curve  The anim curve to use.
    /// @param {real}               time        Amount of time to tween for.
    /// @param {function}           callback    The method to run every frame over the animation curve.
    /// @param {any}		        [...]	    Additional values that will be passed into the callback.
    /// @return {Id.TimeSource,undefined}
    static tween = function(anim_curve, time, callback) {
		if !self.is_handling() {
            show_error("Agenda.tween can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			return undefined
		}
        
        __GET_ARGS_AS_ARRAY
        with self.create_todo() {
            return method_call(self.tween_then_complete, __arg_array)
        }
    }
	
	/// @description Alias for as create_todo().extend(...)
    /// @param {function}   handler Method used to create Todos for the Todo List. Takes this agenda and any additionally provided values as arguments.
    /// @param {any}        [...]   Additional values that will be passed into the handler.
    /// @return {Struct.__Agenda,undefined}
	static extend = function(handler) {
		if !self.is_handling() {
            show_error("Agenda.extend can only be called while the Agenda is being handled.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED || self.state == AGENDA_STATE.RESOLVED {
			return undefined
		}
		
		__GET_ARGS_AS_ARRAY
		with self.create_todo() {
			return method_call(self.extend, __arg_array)
		}
	}

	/// @description Cancels this Agenda and all other Agendas chained onto it and off of it.
	static cancel = function() {
		if self.state == AGENDA_STATE.CANCELED {
			exit
		}

		self.state = AGENDA_STATE.CANCELED
		
		for(var i = 0, n = array_length(self.todo_list); i < n; i ++) {
			var todo = self.todo_list[i]
			todo.cancel()
		}
		if self.next_agenda {
			self.next_agenda.cancel()
		}
		if self.previous_agenda {
			self.previous_agenda.cancel()
		}
		if self.parent_todo {
			self.parent_todo.cancel()
		}
        
        if self.canceled_callback {
            self.canceled_callback()
        }
	}

	/// @description Creates and returns a new Agenda to be handled after this Agenda is resolved.
    /// @param {function}   handler Method used to create Todos for the Todo List. Takes this agenda and any additionally provided values as arguments.
    /// @param {any}        [...]   Additional values that will be passed into the handler.
    /// @return {Struct.__Agenda,undefined}
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
			return undefined
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
    /// @return {Struct.__Agenda,undefined}
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
			return undefined
		}

		self.repeat_predicate = method(method_get_self(repeat_predicate), repeat_predicate)
		self.__attempt_to_resolve()

		return self
	}

	/// @description Assigns a final callback to be executed after the current Agenda is resolved.
	/// @param {function} callback Optional function or method.
    /// @return {Struct.__Agenda,undefined}
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
			return undefined
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
    
    /// @description Adds a callback that fires if this Agenda is ever cancelled.
    /// @param {function} callback The callback be call.
    /// @return {Struct.__Agenda,undefined}
    static when_canceled = function(callback) {
        if self.is_handling() {
            show_error("Agenda.when_canceled cannot be called from within the handler method.", true)
        }
        if self.canceled_callback {
            show_error("Agenda.when_canceled cannot be called if Agenda.when_canceled has already been called.", true)
        }
		
		if self.state == AGENDA_STATE.CANCELED {
			return undefined
		}
        
        self.canceled_callback = method(method_get_self(callback), callback)
        
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
    /// @return {real}
	static get_state = function() {
		return self.state
	}
}
