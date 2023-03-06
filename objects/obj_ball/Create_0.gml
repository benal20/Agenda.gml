can_move = true

move = function(_x, _y) {
	if !can_move {
		exit
	}
	
	can_move = false
	
	var _value = {
		x: _x,
		y: _y,
	}
	
	agenda_create(self, function(_create_todo, _value) {
		var _tween = TweenFire(self, EaseOutQuad, TWEEN_MODE_ONCE, true, 0, random_range(0.8, 1.2), "x>", _value.x, "y>", _value.y)
		var _todo = _create_todo()
		TweenAddCallback(_tween, TWEEN_EV_FINISH, _todo, _todo.finish, _todo)
		return irandom_range(5, 10)
		
	}, _value).and_then(function(_create_todo, _value) {
		var _fireworks = []
		for(var _i = 0; _i < _value; _i ++) {
			var _firework = instance_create_depth(x, y, depth - 1, obj_firework)
			array_push(_fireworks, _firework)
			var _tween = TweenFire(_firework, EaseOutSine, TWEEN_MODE_ONCE, true, 0, random_range(0.5, 1.5), "x>", _firework.x + random_range(-300, 300), "y>", _firework.y + random_range(-300, 300))
			var _todo = _create_todo()
			TweenAddCallback(_tween, TWEEN_EV_FINISH, _todo, _todo.finish, _todo)
		}
		return _fireworks
		
	}).and_then(function(_create_todo, _value) {
		array_foreach(_value, function(_firework) {
			var _tween = TweenFire(_firework, EaseInBack, TWEEN_MODE_ONCE, true, 0, random_range(0.2, 0.4), "image_scale>", 0)
			TweenDestroyWhenDone(_tween, true, true)
		})
		
	}).and_finally(function(_value) {
		can_move = true
	})
}