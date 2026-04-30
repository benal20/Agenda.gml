agenda_create(function(agenda) {
    agenda.delay(0.5)
    agenda.delay_until(function() {
        return keyboard_check_pressed(vk_space)
    })
}).and_then(function(agenda) {
    agenda.defer(30)
    agenda.tween(CurveInOutQuad, 0.2, function(alpha, start_x) {
        self.x = start_x + (alpha * 100)
    }, self.x)
}).and_then(function(agenda) {
    agenda.tween(CurveInOutBack, 0.5, function(alpha, start_y) {
        self.y = start_y + (alpha * 100)
    }, self.y)
})