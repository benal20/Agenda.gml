can_move = true
goal = { x: 0, y: 0 }
callback = undefined

move = function(_x, _y) {
	if !can_move {
		exit
	}
	
	can_move = false
	
	var _value = { x: _x, y: _y }
	
	agenda_create(self, function(_create_todo, _value) {
		direction = point_direction(x, y, _value.x, _value.y)
		speed = random_range(5, 8)
		goal = _value
		
		var _todo = _create_todo()
		callback = method(_todo, function() {
			complete()
		})
		
		return irandom_range(5, 10)
		
	}, _value).and_then(function(_create_todo, _value) {
		var _fireworks = []
		for(var _i = 0; _i < _value; _i ++) {
			var _firework = instance_create_depth(x, y, depth - 1, obj_firework, {
				todo: _create_todo()
			})
		}
	}).and_finally(function(_value) {
		can_move = true
	})
}
