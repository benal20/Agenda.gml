
/// @ignore
function __Agenda_Event_Connection(event, callback) constructor{
	self.event = event
	self.callback = method(method_get_self(callback), callback)
	self.connected = true
	self.next_connection = undefined
	
	/// @description Disconnect this connection from the AgendaEvent it is connected to.
	static disconnect = function() {
		if !self.connected {
			exit
		}
		
		self.connected = false
		
		if self.event.head_connection == self {
			self.event.head_connection = self.next_connection
		}
		else {
			var previous = self.event.head_connection
			
			while previous && previous.next_connection != self {
				previous = previous.next_connection
			}
			
			if previous {
				previous.next_connection = self.next_connection
			}
		}
	}
}
