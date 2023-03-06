if callback && point_distance(x, y, goal.x, goal.y) < speed {
	x = goal.x
	y = goal.y
	speed = 0
	callback()
	callback = undefined
}