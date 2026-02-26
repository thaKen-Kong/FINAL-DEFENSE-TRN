extends State
class_name move

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
	
	if GameState.atp_energy > 0:
		if direction == Vector2.ZERO:
			_transition_to_next_state.emit(self, "idle")
		if entity:
			entity.player_sprite.speed_scale = 2.4
			handle_input(direction, entity)
			entity.velocity = lerp(entity.get_real_velocity(), GameState.player_movement_speed * direction, 25 * delta)
			entity.player_ui.is_consuming_points = true
			
# PHYSICS PROCESS
func _physics_process_update(entity,delta):
	pass
	
func handle_input(direction : Vector2, entity):
	if direction.x == -1:
		entity.player_sprite.play('idle-side')
		entity.player_sprite.flip_h = true
	elif direction.x == 1:
		entity.player_sprite.play('idle-side')
		entity.player_sprite.flip_h = false
	
	if direction.y == 1:
		entity.player_sprite.play('idle-down')
	elif direction.y == -1:
		entity.player_sprite.play('idle-up')
