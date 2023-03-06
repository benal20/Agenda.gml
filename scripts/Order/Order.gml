function __Order(_target, _handler) constructor{
	target = _target
	handler = _handler
	next_order = undefined
	callback = undefined
	value = undefined
	todo_count = 0
	locked = false
	
	static and_then = function(_handler) {
		next_order = new __Order(target, _handler)
		return next_order
	}
	
	static and_finally = function(_callback) {
		callback = method(target, _callback)
	}
	
	static __check = function() {
		if locked && todo_count == 0 {
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
		
		todo_count ++
		
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

function __Todo(_order) constructor{
	order = _order
	is_finished = false
	
	static finish = function() {
		if is_finished {
			exit
		}
		
		is_finished = true
		
		with order {
			todo_count --
			__check()
		}
	}
}

function order_create(_target, _handler, _value = undefined) {
	var _order = new __Order(_target, _handler)
	_order.__handle(_value)
	return _order
}