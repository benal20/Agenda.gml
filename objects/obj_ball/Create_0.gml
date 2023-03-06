animate = function(_x, _y) {
	var _value = { x: _x, y: _y}
	
	order_create(self, function(_create_todo, _value) {
		var _tween = TweenFire(self, EaseOutQuad, TWEEN_MODE_ONCE, true, 0, random_range(0.8, 1.2), "x>", _value.x, "y>", _value.y)
		TweenAddCallback(_tween, TWEEN_EV_FINISH, self, _create_todo())
		return irandom_range(5, 10)
		
	}, _value).and_then(function(_create_todo, _value) {
		var _fireworks = []
		for(var _i = 0; _i < _value; _i ++) {
			var _firework = instance_create_depth(x, y, depth - 1, obj_firework)
			array_push(_fireworks, _firework)
			var _tween = TweenFire(_firework, EaseOutSine, TWEEN_MODE_ONCE, true, 0, random_range(0.5, 1.5), "x>", _firework.x + random_range(-100, 100), "y>", _firework.y + random_range(-100, 100))
			TweenAddCallback(_tween, TWEEN_EV_FINISH, _firework, _create_todo())
		}
		return _fireworks
		
	}).and_then(function(_create_todo, _value) {
		array_foreach(_value, function(_firework) {
			var _tween = TweenFire(_firework, EaseInBack, TWEEN_MODE_ONCE, true, 0, random_range(0.2, 0.4), "image_scale>", 0)
			TweenDestroyWhenDone(_tween, true, true)
		})
		return choose("live", "kill")
		
	}).and_finally(function(_value) {
		if _value == "kill" {
			instance_destroy()
		}
	})
}