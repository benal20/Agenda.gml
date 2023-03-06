function __Order(_target, _handler) constructor{
	target = _target
	handler = _handler
	next_order = undefined
	callback = undefined
	value = undefined
	todo_list = []
	locked = false
	
	static and_then = function(_handler) {
		next_order = new __Order(target, _handler)
		return next_order
	}
	
	static and_finally = function(_callback) {
		callback = method(target, _callback)
	}
	
	static __check = function() {
		if locked && array_length(todo_list) == 0 {
			if callback {
				callback(value)
			}
			else if next_order {
				next_order.__handle(value)
			}
		}
	}
	
	static __create_todo = function() {
		var _todo = function(_done = true) {
			static done = false
			static __self = self
			
			done = _done
			
			if done {
				for(var _i = 0; _i < array_length(__self.todo_list); _i ++) {
					var _todo = __self.todo_list[_i]
					var _todo_static = static_get(_todo)
			
					if _todo_static.done {
						array_delete(__self.todo_list, _i, 1)
						__self.__check()
				
						break
					}
				}
			}
		}
		
		_todo(false) // static values don't exist until after a function has been called for the first time
		
		array_push(todo_list, _todo)
		
		return _todo
	}
	
	static __handle = function(_value) {
		var _handler = method(target, handler)
		var _create_todo = function() {
			return __create_todo()
		}
		value = _handler(_create_todo, _value)
		locked = true
		__check()
	}
}

function order_create(_target, _handler, _value = undefined) {
	var _order = new __Order(_target, _handler)
	_order.__handle(_value)
	return _order
}