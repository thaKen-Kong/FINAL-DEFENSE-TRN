extends Node

signal cutscene_started
signal cutscene_finished

@onready var cam: Camera2D = Camera2D.new()

var is_playing: bool = false
var pan_speed := 6.0
var default_zoom := Vector2.ONE

var _sequence: Array = []
var _current_index := 0

# ===============================
# Lifecycle
# ===============================

func _ready():
	add_child(cam)
	cam.enabled = false
	cam.make_current()
	cam.zoom = default_zoom
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = pan_speed

# ===============================
# Public API
# ===============================

# Sequence format:
# [
#   { "node": Node2D, "hold": 1.0, "zoom": Vector2(1,1), "callback": Callable },
#   ...
# ]
func play_sequence(sequence: Array):
	if is_playing:
		return

	if sequence.is_empty():
		return

	_sequence = sequence.duplicate(true)
	_current_index = 0

	_start_cutscene()
	await _play_next()
	_end_cutscene()

# Simple helper for fast scripting
func play(nodes: Array[Node2D], hold_time := 1.0):
	var seq := []
	for n in nodes:
		seq.append({
			"node": n,
			"hold": hold_time,
			"zoom": default_zoom,
			"callback": null
		})
	play_sequence(seq)

# ===============================
# Core Logic
# ===============================

func _start_cutscene():
	is_playing = true
	_switch_to_cutscene_camera()
	cutscene_started.emit()

func _end_cutscene():
	is_playing = false
	_sequence.clear()
	cam.enabled = false
	cutscene_finished.emit()

func _switch_to_cutscene_camera():
	cam.enabled = true
	cam.make_current()

# ===============================
# Sequencing Engine
# ===============================

func _play_next():
	while _current_index < _sequence.size():
		var step = _sequence[_current_index]
		_current_index += 1

		if not step.has("node"):
			continue

		var target: Node2D = step["node"]
		if not is_instance_valid(target):
			continue

		var hold = step.get("hold", 1.0)
		var zoom = step.get("zoom", default_zoom)
		var callback = step.get("callback", null)

		await _move_camera(target.global_position, zoom)
		await get_tree().create_timer(hold).timeout

		if callback and callback is Callable:
			callback.call()

# ===============================
# Camera Motion Engine
# ===============================

func _move_camera(target_pos: Vector2, target_zoom: Vector2, tolerance := 2.0):
	while cam.global_position.distance_to(target_pos) > tolerance \
	or cam.zoom.distance_to(target_zoom) > 0.01:

		cam.global_position = cam.global_position.lerp(
			target_pos,
			get_process_delta_time() * pan_speed
		)

		cam.zoom = cam.zoom.lerp(
			target_zoom,
			get_process_delta_time() * pan_speed
		)

		await get_tree().process_frame

# ===============================
# Emergency Control
# ===============================

func force_stop():
	if not is_playing:
		return
	is_playing = false
	_sequence.clear()
	cam.enabled = false
	cutscene_finished.emit()
