# What are Agendas?

An Agenda is a struct that allows you to schedule and delay the execution of callbacks until after pre-requisites called Todos have been completed. Agendas can be chained off of each other, making them especially useful for multi-stage animation systems.

Agendas have 3 main components:

- **Resolution** - What happens when the Agenda is resolved.
- **Todos** - Structs that need to be completed in order for the Agenda to be resolved.
- **Handler** - A method for creating Todos within an Agenda.

# Using Agendas

### Creating Agendas

Agendas can be created with the `agenda_create(scope, handler, [value])` function.
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
}).and_then(function(agenda, value) {
  do_animation("attack_end", agenda.create_todo())
})
```
A final callback can be chained onto an Agenda with the `and_finally(callback)` method.
<br>This does not create a new Agenda, and cannot be chained onto.
```js
agenda_create(self, function(agenda, value) {
  do_animation("attack_start", agenda.create_todo())
}).and_then(function(agenda, value) {
  do_animation("attack_end", agenda.create_todo())
}).and_finally(function(value) {
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
}, victim_instance).and_then(function(agenda, victim_instance) {
  attack_instance(victim_instance)
  do_animation("attack_end", agenda.create_todo())
})
```
If you want to pass a different value into the next Agenda or final callback in the chain, return it in the handler
```js
agenda_create(self, function(agenda, victim_instance) {
  do_animation("attack_start", agenda.create_todo())
}, victim_instance).and_then(function(agenda, victim_instance) {
  var retaliation_damage = attack_instance(victim_instance)
  do_animation("attack_end", agenda.create_todo())
  return retaliation_damage
}).and_then(agenda, retaliation_damage) {
  take_damage(retaliation_damage)
})
```

___

### Creating Agendas from Todos

Agendas can be created from Todos with the `agenda(scope, handler, [value])` method. 
```js
static do_animation = function(animation_name, todo) {
  todo.agenda(self, function(agenda, animation_name) {
    animate(animation_name, agenda.create_todo())
  }, animation_name).and_finally(function(animation_name) {
    done_animating = true
  })
}

agenda_create(self, function(agenda, value) {
  do_animation("attack_start", agenda.create_todo())
}).and_finally(function(value) {
  finished_animating = true
})
```
When the chain is finished, whether there is an `and_finally` callback or not, the Todo will call `complete` on itself automatically.

___

### Canceling Agendas

An Agenda can be canceled within the handler with the `cancel([do_complete_source_todo])` method, preventing any further chaining.
```js
agenda_create(self, function(agenda, value) {
  var success = do_animation("attack_start", agenda.create_todo())
  if !success {
    agenda.cancel()
  }
}).and_then(function(agenda, value) {
  var success = do_animation("attack_end", agenda.create_todo())
  if !success {
    agenda.cancel()
  }
}).and_finally(function(value) {
  finished_animating = true
})
```
If the Agenda was created from a Todo, you may optionally pass `true` into `cancel` to complete the source Todo immediately.
<br>Otherwise, the Todo will not be completed automatically.
