agenda_delay(0.5).and_then(function(agenda) {
    agenda.tween(CurveInOutQuad, 0.2, function(alpha, start_x) {
        self.x = start_x + (alpha * 100)
    }, self.x)
}).and_then(function(agenda) {
    agenda.tween(CurveInOutBack, 0.5, function(alpha, start_y) {
        self.y = start_y + (alpha * 100)
    }, self.y)
})