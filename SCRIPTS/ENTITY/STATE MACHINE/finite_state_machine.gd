extends Node
class_name FSM

var states : Dictionary = {}
var current_state : State

# EXPORT VARIABLES
@export var initial_state : State
@export var entity : CharacterBody2D
@export var state_machine_active : bool = true

func _ready():
	if state_machine_active:
		call_deferred("_activate_state_machine")

func _activate_state_machine():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child._transition_to_next_state.connect(_next_state)
	
	if initial_state:
		initial_state._enter(entity)
		current_state = initial_state

# CALL NEXT STATE
func _next_state(state, new_state_name):
	if not state_machine_active:
		return
	
	if current_state != state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state._exit(entity)
	
	new_state._enter(entity)
	current_state = new_state

# PROCESS
func _process(delta):
	if not state_machine_active:
		return
	if not entity:
		return
	if not current_state:
		return
	
	current_state._process_update(entity, delta)

# PHYSICS PROCESS
func _physics_process(delta):
	if not state_machine_active:
		return
	if not entity:
		return
	if not current_state:
		return
	
	current_state._physics_process_update(entity, delta)
