self.aev = agenda_event_create()

self.aev.connect(function(agenda, goal_x, goal_y) {
    agenda.delay(0.5)
})

self.aev.connect(function(agenda, goal_x, goal_y) {
    agenda.tween(CurveInOutBack, 1, function(alpha, start_x, start_y, goal_x, goal_y) {
        self.x = lerp(start_x, goal_x, alpha)
        self.y = lerp(start_y, goal_y, alpha)
    }, self.x, self.y, goal_x, goal_y)
})

self.aev.connect(function(agenda, goal_x, goal_y) {
    agenda.defer(30)
})

agenda_create(function(agenda) {
    agenda.delay_until(function() {
        return keyboard_check_pressed(vk_space)
    })
}).and_then(function(agenda) {
    agenda.tween(CurveInOutQuad, 0.2, function(alpha, start_x) {
        self.x = start_x + (alpha * 100)
    }, self.x)
}).and_then(function(agenda) {
    self.aev.fire_each(agenda, 500, 300)
}).and_finally(function() {
    instance_destroy()
})