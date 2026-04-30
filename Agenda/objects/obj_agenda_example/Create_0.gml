self.event = agenda_event_create()

self.event.connect(function(agenda, goal_x, goal_y) {
    agenda.delay(0.5)
})

self.event.connect(function(agenda, goal_x, goal_y) {
    agenda.tween(CurveInOutBack, 1, function(alpha, start_x, start_y, goal_x, goal_y) {
        self.x = lerp(start_x, goal_x, alpha)
        self.y = lerp(start_y, goal_y, alpha)
    }, self.x, self.y, goal_x, goal_y)
})

self.event.connect(function(agenda, goal_x, goal_y) {
    agenda.defer(30)
})

var agenda = agenda_create(function(agenda) {
    agenda.extend(function(agenda) {
        agenda.delay_until(function() {
            return keyboard_check_pressed(vk_space)
        })
    }).and_then(function(agenda) {
        agenda.tween(CurveInOutQuad, 0.2, function(alpha, start_x) {
            self.x = start_x + (alpha * 100)
        }, self.x)
    }).and_then(function(agenda) {
        self.event.fire_each(agenda, 500, 300)
    }).and_finally(function() {
        self.x = self.xstart
        self.y = self.ystart
    }).when_canceled(function() {
        self.x = self.xstart
        self.y = self.ystart
    })
}).and_repeat_until(function() {
    return false
})

agenda_create(function(agenda, other_agenda) {
    agenda.delay_until(function() {
        return keyboard_check_pressed(vk_backspace)
    })
}, agenda).and_finally(function(other_agenda) {
    other_agenda.cancel(true)
})

self.agenda = agenda