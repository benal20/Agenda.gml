agenda_delay(0.5).and_then(function(agenda) {
    agenda.animate(CurveInOutQuad, 0.2, function(alpha) {
        self.x = self.xstart + (alpha * 100)
    })
})