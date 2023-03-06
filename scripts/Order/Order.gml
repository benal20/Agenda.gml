function __Order(_target, _handler) constructor{
	__target = _target
	__handler = _handler
	__next_order = undefined
	__finally = undefined
	__value = undefined
	__todo_count = 0
	__locked = false
	
	static and_then = function(_handler) {
		__next_order = new __Order(__target, _handler)
		return __next_order
	}
	
	static and_finally = function(_callback) {
		__finally = method(__target, _callback)
	}
	
	static __check = function() {
		if __locked && __todo_count == 0 {
			if __finally {
				__finally(__value)
			}
			else if __next_order {
				__next_order.__handle(__value)
			}
		}
	}
	
	static __create_todo = function() {
		var _todo = new __Todo(self)
		
		__todo_count ++
		
		return _todo
	}
	
	static __handle = function(_value) {
		var _handler = method(__target, __handler)
		var _create_todo = function() {
			return __create_todo()
		}
		__value = _handler(_create_todo, _value)
		__locked = true
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
			__todo_count --
			__check()
		}
	}
}

function order_create(_target, _handler, _value = undefined) {
	var _order = new __Order(_target, _handler)
	_order.__handle(_value)
	return _order
}