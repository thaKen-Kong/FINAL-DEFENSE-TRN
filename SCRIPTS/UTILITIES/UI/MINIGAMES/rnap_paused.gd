extends Control
class_name RNAP_PAUSED

signal key_sequence_status

@export var keys : Array[PackedScene]

@onready var key_container = $KEY_CONTAINER
@onready var progress_bar = $ProgressBar
@onready var label = $ProgressBar/Label


var randomize_keys : Array
var key_input_to_match : Array
var player_input : Array


var started : bool = false
var minigame_duration : float = 4
var time_out : bool = false

func _show():
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.2).set_ease(Tween.EASE_IN_OUT)

func _hide():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.2).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()

func _ready():
	self.modulate.a = 0
	_show()
	
	if keys.size() == 0:
		return
	
	for index in range(keys.size()):
		randomize_keys.append(keys.pick_random())
	
	for key in randomize_keys:
		key_container.add_child(key.instantiate())
	
	for key in key_container.get_children():
		if key is KEY:
			key_input_to_match.append(key.direction)
		
	started = true

func _input(event):
	if started:
		if event.is_action_pressed("ui_left"):
			player_input.append("left")
		elif event.is_action_pressed("ui_right"):
			player_input.append("right")
		elif event.is_action_pressed("ui_down"):
			player_input.append("down")
		elif event.is_action_pressed("ui_up"):
			player_input.append("up")

func _check_input_matched():
	if key_input_to_match == player_input:
		print("MATCHED")
		key_sequence_status.emit(true)
		started = false
		_hide()
	elif player_input.size() == key_input_to_match.size() and key_input_to_match != player_input or time_out:
		print("NOT MATCHED")
		key_sequence_status.emit(false)
		started = false
		_hide()
		

func _keys_done():
	pass

func _process(delta):
	if started:
		if minigame_duration > 0:
			minigame_duration -= delta
			progress_bar.value = minigame_duration
			label.text = "TIME LEFT: %0.1f" % minigame_duration
			_check_input_matched()
		if minigame_duration <= 0:
			time_out = true
			label.text = "TIME LEFT: %0.1f" % 0
			started = false
			_check_input_matched()
