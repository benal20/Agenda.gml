var agenda = agenda_delay(5, "yellow").and_then(function(agenda, text) {
    x += 200
    y += 200
    
    show_debug_message(text)
    
    agenda.extend_delay(2, text).and_then(function(agenda, text) {
        x -= 100
        y -= 100
        show_debug_message(text)
    })
})
