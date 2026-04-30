
/// @ignore
function __Agenda_Todo(agenda) constructor {
	self.agenda = agenda
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
        with self.agenda {
            method_call(self.__complete_todo, __arg_array)
        }
	}
	
	/// @description Cancels this Todo and its Agenda chain.
	static cancel = function() {
		if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}
        
        if self.time_source != undefined && time_source_exists(self.time_source) {
            time_source_destroy(self.time_source)
            self.time_source = undefined
        }
		
		self.state = AGENDA_TODO_STATE.CANCELED
        with self.agenda {
            self.cancel(self)
        }
	}
	
	/// @description Waits for a period of time, then completes the todo.
	/// @param {real} time   Amount of time to delay.
    /// @return {Id.TimeSource}
	static delay_then_complete = function(time) {
		if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}
		if self.time_source != undefined {
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
    
    /// @description Completes the todo on the next frame, or in a number of frames.
	/// @param {real} [frames]   Amount of frames to defer.
    /// @return {Id.TimeSource}
    static defer_then_complete = function(frames = 1) {
        if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}
		if self.time_source != undefined {
            exit
        }
		
		self.time_source = time_source_create(time_source_game, frames, time_source_units_frames, function() {
            time_source_destroy(self.time_source)
            self.time_source = undefined
            self.complete()
        })
        time_source_start(self.time_source)
        return self.time_source
    }
    
    /// @description Executes a predicate method every frame until it returns true, then resolves the todo.
    /// @param {function}  predicate The method to run every frame until it returns true.
    /// @param {any}	   [...]	 Additional values that will be passed into the predicate.
    /// @return {Id.TimeSource}
    static delay_until_then_complete = function(predicate) {
        if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}
		if self.time_source != undefined {
            exit
        }
        
        __GET_ARGS_AS_ARRAY
        self.time_source = time_source_create(time_source_game, 1, time_source_units_frames, function(predicate) {
            __GET_ARGS_AS_ARRAY
            array_delete(__arg_array, 0, 1)
            if method_call(predicate, __arg_array) {
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
    
    /// @description Executes a provided callback every frame over a given time period and animation curve, completing the todo at the end.
    /// @param {Id.AnimationCurve}  anim_curve  The anim curve to use.
    /// @param {real}               time        Amount of time to tween for.
    /// @param {function}           callback    The method to run every frame over the animation curve.
    /// @param {any}		        [...]	    Additional values that will be passed into the callback.
    /// @return {Id.TimeSource}
    static tween_then_complete = function(anim_curve, time, callback) {
		if self.state != AGENDA_TODO_STATE.INCOMPLETE {
			exit
		}
		if self.time_source != undefined {
            exit
        }
        
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
		with new __Agenda(handler, self) {
			method_call(self.__handle, __arg_array, 1)
            return self
		}
	}
}
