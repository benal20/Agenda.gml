
/// Feather ignore all

function __Connection(_signal, _scope, _callback) constructor {
	__callback = method(_scope, _callback)
	__connected = true
	__next_connection = undefined
	__on_disconnect = method(_signal, _signal.__disconnect)
	
	/// Disconnect this connection from the signal it is connected to.
	static disconnect = function() {
		__connected = false
		__on_disconnect(self)
	}
}
