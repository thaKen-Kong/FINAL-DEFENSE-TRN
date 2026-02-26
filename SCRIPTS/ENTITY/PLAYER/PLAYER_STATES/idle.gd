extends State
class_name idle

#VARIABLES
var direction : Vector2

# ENTER
func _enter(entity):
	pass

# EXIT
func _exit(entity):
	pass

# PROCESS
func _process_update(entity,delta):
	direction = Input.get_vector('a','d','w','s').normalized()
	entity.last_direction_facing = direction
	entity.player_sprite.speed_scale = 1
	if direction:
		_transition_to_next_state.emit(self, "move")
	
	if not direction:
		if entity.player_sprite:
			handle_input(entity.last_direction_facing, entity)
		entity.player_ui.is_consuming_points = false
		entity.velocity = lerp(entity.get_real_velocity(), Vector2.ZERO, 25 * delta)


# PHYSICS PROCESS
func _physics_process_update(entity,delta):
	pass
	
func handle_input(direction : Vector2, entity):
	
	match direction:
		Vector2(-1, 0):
			entity.player_sprite.play("stop")
			entity.player_sprite.flip_h = true
		Vector2(1, 0):
			entity.player_sprite.play("stop")
			entity.player_sprite.flip_h = false
		Vector2(0, -1):
			entity.player_sprite.play("stop_up")
		Vector2(0, 1):
			entity.player_sprite.play("stop_down")
