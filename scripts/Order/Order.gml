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
		trace(array_length(todo_list), "todos remain")
		if locked && array_length(todo_list) == 0 {
			trace("resolving order")
			if callback {
				callback(value)
			}
			else if next_order {
				next_order.__handle(value)
			}
		}
	}
	
	static __create_todo = function() {
		var _todo = new __Todo(self)
		
		array_push(todo_list, _todo)
		
		return _todo.finish
	}
	
	static __handle = function(_value) {
		trace("handling order")
		var _handler = method(target, handler)
		var _create_todo = function() {
			return __create_todo()
		}
		value = _handler(_create_todo, _value)
		locked = true
		__check()
	}
}

function __Todo(_order) constructor{
	order = _order
	is_finished = false
	
	finish = function(_self = undefined) {
		static __self = _self
		
		with __self {
			if is_finished || _self {
				exit
			}
		
			is_finished = true
		
			with order {
				for(var _i = 0; _i < array_length(todo_list); _i ++) {
					var _todo = todo_list[_i]
			
					if _todo.is_finished {
						array_delete(todo_list, _i, 1)
						__check()
				
						break
					}
				}
			}
		}
	}
	
	finish(self)
}

function order_create(_target, _handler, _value = undefined) {
	var _order = new __Order(_target, _handler)
	_order.__handle(_value)
	return _order
}