can_move = true
move_speed = 8
goal = { x: 0, y: 0 }
callback = undefined
text = "Click anywhere to move the ball"
move_and_return_text = ""
shoot_green_fireworks_text = ""

randomize()

move = function(_x, _y, _speed, _todo) {
	direction = point_direction(x, y, _x, _y)
	speed = _speed
	goal = { x: _x, y: _y }
	
	callback = method(_todo, function() {
		complete()
	})
}

on_click = function(_x, _y) {
	if !can_move {
		exit
	}
	
	can_move = false
	text = "Waiting for move_and_return and shoot_green_fireworks to finish"
	
	var _destination = { x: _x, y: _y }
	agenda_create(self, function(_agenda, _destination) {
		move_and_return(_destination, _agenda.create_todo())
		shoot_green_fireworks(irandom_range(1, 10), _agenda.create_todo())
	}, _destination)
	
	.and_finally(function() {
		can_move = true
		text = "The ball can be moved again!"
	})
}

move_and_return = function(_destination, _todo) {
	_todo.agenda(self, function(_agenda, _destination) {
		move(_destination.x, _destination.y, move_speed, _agenda.create_todo())
		move_and_return_text = "The ball is moving towards its destination"
		
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
				color: c_red,
			})
		}
		move_and_return_text = "The ball is waiting for all red fireworks to be destroyed"
	})
	
	.and_then(function(_agenda, _start_location) {
		move(_start_location.x, _start_location.y, move_speed, _agenda.create_todo())
		move_and_return_text = "The ball is returning to its starting location"
	})
	
	.and_finally(function(_start_location) {
		move_and_return_text = ""
		text = "Waiting for shoot_green_fireworks to finish"
	})
}

shoot_green_fireworks = function(_amount, _todo) {
	_todo.agenda(self, function(_agenda, _amount) {
		var _firework = instance_create_depth(x, y, depth - 1, obj_test_firework, {
			todo: _agenda.create_todo(),
			color: c_green,
		})
		_amount --
		
		shoot_green_fireworks_text = string(_amount) + " green fireworks left to shoot"
		
		return _amount
	}, _amount)
	
	.and_repeat_until(function(_amount) {
		return _amount == 0
	})
	
	.and_finally(function(_amount) {
		shoot_green_fireworks_text = ""
		text = "Waiting for move_and_return to finish"
	})
}

step = function() {
	if callback && point_distance(x, y, goal.x, goal.y) < speed {
		x = goal.x
		y = goal.y
		speed = 0
		callback()
		callback = undefined
	}
}
