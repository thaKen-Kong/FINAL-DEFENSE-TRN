extends Control
class_name RotateTheWheel

@onready var rotate_the_wheel = $RotateTheWheel

var dragging = false
var previous_mouse_pos := Vector2.ZERO

func _ready():
	# Ensure pivot is at center
	rotate_the_wheel.set_pivot_offset(rotate_the_wheel.size / 2)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and rotate_the_wheel.get_global_rect().has_point(event.position):
				dragging = true
				previous_mouse_pos = event.position
			elif not event.pressed:
				dragging = false
	if event is InputEventMouseMotion and dragging:
		var delta = event.position - previous_mouse_pos
		print(delta)
		rotate_the_wheel.rotation += deg_to_rad(delta.x * 0.5)
