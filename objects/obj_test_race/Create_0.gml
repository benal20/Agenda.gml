racing = false
racers = []
winner_text = ""
race_text = ""
names = ["Amanda", "Ben", "Cameron", "Diane", "Everett", "Frida", "Gigi", "Henry"]
text = ""

on_race = function() {
	if racing {
		exit
	}
	
	racing = true
	winner_text = ""
	racers = []
	
	new Agenda(self, function(_agenda) {
		_agenda.event_todo_completed.define(function(_agenda, _name) {
			_agenda.resolve(_name)
		})
		
		racer_count = irandom_range(2, array_length(names))
		for(_i = 0; _i < racer_count; _i ++) {
			array_push(racers, {
				name: names[_i],
				countdown: irandom_range(60 * 3, 60 * 6),
				todo: _agenda.create_todo(),
			})
		}
	})
	
	.and_finally(function(_name) {
		winner_text = "WINNER! " + _name
		racing = false
	})
}

step = function() {
	text = racing ? "" : "Press Spacebar to start a race"
	if !racing {
		exit
	}
	
	race_text = ""

	for(var _i = 0, _n = array_length(racers); _i < _n; _i ++) {
		var _racer = racers[_i]

		_racer.countdown --
		race_text += string("{0} {1}\n", _racer.name, _racer.countdown)

		if _racer.countdown == 0 {
			_racer.todo.complete(_racer.name)
		}
	}
}