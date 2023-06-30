# What are Agendas?

Agendas are Promise-like struct objects that allow you to easily schedule and chain together callbacks. Unlike Promises, Agendas forgo error catching in favor of a simpler design more suitable for offline-only singleplayer games.
<br><br>An Agenda is essentially a fancy todo list — Todos get created within a Handler function and may be completed at any time. The Agenda is resolved once all created Todos are completed, or immediately if none were created, which will then execute the Handler function of the next Agenda in the chain if one exists.

# Using Agendas

### Creating Agendas

Agendas can be created like this `agenda_create(scope, handler, [value])` or this `new Agenda(scope, handler, [value])`.
<br>Agendas created in this way are handled immediately, meaning their handler is called immediately.
```js
agenda_create(self, function(agenda, value) {
  var todo = agenda.create_todo()
  do_animation("jump", todo)
})
```
You can create new Todos within the handler function using the `create_todo()` method.
<br> Any number of Todos can be created within an Agenda.
```js
agenda_create(self, function(agenda, value) {
  for(var i = 0; i < 10; i ++) {
    var todo = agenda.create_todo()
    fire_projectile(obj_fireball, todo)
  }
})
```
___

### Resolving Agendas

An Agenda will resolve after all Todos created within the Agenda's handler are completed.
<br>Todos can be completed with the `complete()` method.
```js
static animation_finished = function(todo) {
  todo.complete()
}
```
If no Todos were created within the handler, the Agenda will resolve immediately.

___

### Chaining Agendas

Agendas can be chained onto with the `and_then(handler)` method.
<br>These Agendas will be handled after the Agenda they are chained onto is resolved.
```js
agenda_create(self, function(agenda, value) {
  do_animation("attack_start", agenda.create_todo())
})

.and_then(function(agenda, value) {
  do_animation("attack_end", agenda.create_todo())
})
```
A final callback can be chained onto an Agenda with the `and_finally([callback])` method.
<br>This does not create a new Agenda, and cannot be chained off of.
```js
agenda_create(self, function(agenda, value) {
  do_animation("attack_start", agenda.create_todo())
})

.and_then(function(agenda, value) {
  do_animation("attack_end", agenda.create_todo())
})

.and_finally(function(value) {
  finished_animating = true
})
```

___

### Passing Values Through Agendas

`agenda_create` has an optional `[value]` argument which will be passed into the handler.
```js
agenda_create(self, function(agenda, animation_name) {
  do_animation(animation_name, agenda.create_todo())
}, "attack_start")
```
This value will be passed into the next Agenda or final callback in the chain.
```js
agenda_create(self, function(agenda, victim_instance) {
  do_animation("attack_start", agenda.create_todo())
}, victim_instance)

.and_then(function(agenda, victim_instance) {
  attack_instance(victim_instance)
  do_animation("attack_end", agenda.create_todo())
})
```
If you want to pass a different value into the next Agenda or final callback in the chain, return it in the handler
```js
agenda_create(self, function(agenda, victim_instance) {
  do_animation("attack_start", agenda.create_todo())
}, victim_instance)

.and_then(function(agenda, victim_instance) {
  var retaliation_damage = attack_instance(victim_instance)
  do_animation("attack_end", agenda.create_todo())
  return retaliation_damage
})

.and_finally(retaliation_damage) {
  take_damage(retaliation_damage)
})
```

___

### Repeating Agendas

An Agenda can be repeated with the `and_repeat_until(predicate_function)` method.
<br>The predicate function takes the return value of the previous Agenda's handler as an argument. It should return false if the previous Agenda should be handled again, or true if it should be resolved.
```js
agenda_create(self, function(agenda, amount) {
  fire_projectile(agenda.create_todo())
  return amount --
}, 5)

.and_repeat_until(function(amount) {
  return ammount == 0
})

.and_finally(amount) {
  play_sound(snd_out_of_ammo)
}
```
If `and_repeat_until` is chained off of, it will pass the same value it received onto the next Agenda or final callback in the chain.

___

### Chaining Agendas off of Todos

Agendas can be created from Todos with the `agenda(scope, handler, [value])` method. 
```js
static do_animation = function(animation_name, todo) {
  todo.agenda(self, function(agenda, animation_name) {
    animate(animation_name, agenda.create_todo())
  }, animation_name)

  .and_finally()
}

agenda_create(self, function(agenda, value) {
  do_animation("attack_start", agenda.create_todo())
})

.and_finally(function(value) {
  finished_animating = true
})
```
After the chain reaches its `and_finally` callback, the chain's source Todo will `complete` itself.
<br>Notice how no callback is passed into `and_finally` within `do_animation`. As long as the final Agenda in a chain has `and_finally` chained onto it, the source Todo will be completed whether a callback is passed or not.

___

### Canceling Agendas

An Agenda can be canceled within the handler with the `cancel([do_complete_source_todo])` method, preventing any further chaining.
```js
agenda_create(self, function(agenda, value) {
  var success = do_animation("attack_start", agenda.create_todo())
  if !success {
    agenda.cancel()
  }
})

.and_then(function(agenda, value) {
  var success = do_animation("attack_end", agenda.create_todo())
  if !success {
    agenda.cancel()
  }
})

.and_finally(function(value) {
  finished_animating = true
})
```
If the Agenda was created from the `agenda` method of a Todo, you may optionally pass `true` into `cancel` to complete the original Todo.
<br>If this is not done, the original Todo will not be completed because the `and_finally` callback will never be executed.
<br>If the Agenda was created from `agenda_create` then this argument is ignored.
