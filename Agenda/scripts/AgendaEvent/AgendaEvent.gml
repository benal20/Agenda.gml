
/// @ignore
function __Agenda_Event() constructor{
	self.head_connection = undefined
	
	/// @description Recursively fires each connection through an agenda one at a time.
    /// @param {struct.__Agenda}    agenda  The Agenda to use.
    /// @param {any}                [...]   Additional values that will be passed to each connection's callback.
	static fire_each = function(agenda) {
		if !self.head_connection {
			exit
		}
		
		__GET_ARGS_AS_ARRAY
		array_delete(__arg_array, 0, 1)
		
		agenda.extend(function(agenda, connection, arg_array) {
			array_insert(arg_array, 0, agenda)
			with connection {
				method_call(self.callback, arg_array)
			}
			array_delete(arg_array, 0, 1)
			
			return [connection.next_connection, arg_array]
		}, self.head_connection, __arg_array)
		
		.and_repeat_until(function(connection, arg_array) {
			return !connection
		})
		
		.and_finally()
	}
	
	/// @description Fires all connections through an agenda simultaneously.
    /// @param {struct.__Agenda}    agenda  The Agenda to use.
    /// @param {any}                [...]   Additional values that will be passed to each connection's callback.
	static fire_all = function(agenda) {
		if !self.head_connection {
			exit
		}
		
		__GET_ARGS_AS_ARRAY
		array_delete(__arg_array, 0, 1)
		
		agenda.extend(function(agenda, connection, arg_array) {
			while connection {
				array_insert(arg_array, 0, agenda)
				with connection {
					method_call(self.callback, arg_array)
				}
				array_delete(arg_array, 0, 1)
				
				connection = connection.next_connection
			}
		}, self.head_connection, __arg_array)
		
		.and_finally()
	}
	
	/// @description Connect a callback to this AgendaEvent. Returns the newly created Connection.
    /// @param {function} callback The method that is called when this AgendaEvent is fired. Accepts an Agenda and any number of optional parameters as arguments.
	/// @return {struct.__Agenda_Event_Connection}
    static connect = function(callback) {
		var connection = new __Agenda_Event_Connection(self, callback)
		
		if self.head_connection {
			connection.next_connection = self.head_connection
		}
		
		self.head_connection = connection
		
		return connection
	}
	
	/// @description Disconnect all connections.
	static disconnect_all = function() {
		self.head_connection = undefined
	}
	
	/// @description Alias of disconnect_all().
	static destroy = function() {
		self.disconnect_all()
	}
}
