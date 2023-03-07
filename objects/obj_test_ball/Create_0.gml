can_move = true
goal = { x: 0, y: 0 }
callback = undefined

move = function(_x, _y, _speed, _todo) {
	direction = point_direction(x, y, _x, _y)
	speed = _speed
	goal = { x: _x, y: _y }
	
	callback = method(_todo, function() {
		complete()
	})
}

move_and_return = function(_x, _y) {
	if !can_move {
		exit
	}
	
	can_move = false
	
	var _value = { x: _x, y: _y }
	agenda_create(self, function(_agenda, _value) {
		var _speed = 8
		move(_value.x, _value.y, _speed, _agenda.create_todo())
		
		return {
			x: x,
			y: y,
			speed: _speed,
		}
	}, _value)
	
	.and_then(function(_agenda, _value) {
		var _fireworks = []
		for(var _i = 0; _i < irandom_range(6, 12); _i ++) {
			var _firework = instance_create_depth(x, y, depth - 1, obj_test_firework, {
				todo: _agenda.create_todo(),
			})
		}
	})
	
	.and_then(function(_agenda, _value) {
		move(_value.x, _value.y, _value.speed, _agenda.create_todo())
	})
	
	.and_finally(function(_value) {
		can_move = true
	})
}
