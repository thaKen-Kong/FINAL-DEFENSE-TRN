extends Control

@onready var timer : Timer = $Timer
@onready var nucleolus_eye : TextureRect = $Nucleolus/Eyes

var eye_follow_max_radius : float = 20
var eye_center : Vector2  # store original center

func _ready():
	eye_center = nucleolus_eye.global_position # local position relative to parent
	
	for child in $"Button Container/VBoxContainer".get_children():
		if child is Button:
			child.mouse_entered.connect(func(): SFX.play(SFX.select_click, 2, 1))
			child.pressed.connect(func(): SFX.play(SFX.click_2, 20, 4))

func _process(delta):
	# Vector from eye center to mouse in global space
	var dir = get_global_mouse_position() - nucleolus_eye.global_position
	
	# Limit the vector to max radius
	if dir.length() > eye_follow_max_radius:
		dir = dir.normalized() * eye_follow_max_radius
	
	# Move the eye to new position (relative to original center)
	nucleolus_eye.global_position = eye_center + dir

func _on_start_pressed():
	SceneTransition._change_scene("res://SCENES/WORLD_OBJECT/world.tscn")


func _on_exit_pressed():
	get_tree().quit()
