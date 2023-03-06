if callback && distance_to_point(goal.x, goal.y) < speed {
	callback()
	callback = undefined
	speed = 0
}