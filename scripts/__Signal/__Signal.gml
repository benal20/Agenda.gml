
/// Feather ignore all

function __Signal() constructor {
	__head_connection = undefined
	
	/// Fires all connected callbacks.
	/// @param {any}	sender
	/// @param {struct} options
	static fire = function(_sender, _options = {}) {
		var _connection = __head_connection
		
		while _connection {
			if _connection.__connected {
				_connection.__callback(_sender, _options)
			}
			
			_connection = _connection.__next_connection
		}
	}
	
	/// Fires all connected callbacks through an Agenda chain.
	/// @param {any}	sender
	/// @param {struct} agenda
	/// @param {struct} options
	static fire_agenda = function(_sender, _agenda, _options = {}) {
		if !__head_connection {
			exit
		}
		
		var _todo = _agenda.create_todo()
		var _data = {
			sender: _sender,
			connection: __head_connection,
			options: _options,
		}
		
		_todo.agenda(self, function(_agenda, _data) {
			_data.connection.__callback(_data.sender, _agenda, _data.options)
			
			return {
				sender: _data.sender,
				connection: _data.connection.__next_connection,
				options: _data.options,
			}
		}, _data)
		
		.and_repeat_until(function(_data) {
			return !_data.connection
		})
		
		.and_finally()
	}
	
	/// Connect a callback to this signal. Returns the newly created Connection.
	/// @param {any}		scope
	/// @param {function}	callback
	static connect = function(_scope, _callback) {
		var _connection = new __Connection(self, _scope, _callback)
		
		if __head_connection {
			_connection.__next_connection = __head_connection
		}
		
		__head_connection = _connection
		
		return _connection
	}
	
	/// Disconnect all connections.
	static disconnect_all = function() {
		__head_connection = undefined
	}
	
	static __disconnect = function(_connection) {
		if __head_connection == _connection {
			__head_connection = _connection.__next_connection
		}
		else {
			var _previous = __head_connection
			
			while _previous && _previous.__next_connection != _connection {
				_previous = _previous.__next_connection
			}
			
			if _previous {
				_previous.__next_connection = _connection.__next_connection
			}
		}
	}
}
