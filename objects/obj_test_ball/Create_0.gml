can_move = true
move_speed = 8
goal = { x: 0, y: 0 }
callback = undefined
text = "Click anywhere to move the ball"

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
	
	var _destination = { x: _x, y: _y }
	agenda_create(self, function(_agenda, _destination) {
		move(_destination.x, _destination.y, move_speed, _agenda.create_todo())
		text = "The ball is moving towards its destination"
		
		return {
			x: x,
			y: y,
		}
	}, _destination)
	
	.and_then(function(_agenda, _start_location) {
		var _fireworks = []
		for(var _i = 0; _i < irandom_range(6, 12); _i ++) {
			var _firework = instance_create_depth(x, y, depth - 1, obj_test_firework, {
				todo: _agenda.create_todo(),
			})
		}
		text = "The ball is waiting for all fireworks to be destroyed"
	})
	
	.and_then(function(_agenda, _start_location) {
		move(_start_location.x, _start_location.y, move_speed, _agenda.create_todo())
		text = "The ball is returning to its starting location"
	})
	
	.and_finally(function(_start_location) {
		can_move = true
		text = "Click anywhere to move the ball"
	})
}
