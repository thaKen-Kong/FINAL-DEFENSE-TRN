extends CanvasLayer

@onready var scene_transition_screen : ColorRect = $ColorRect

var scene_to_load : String = ""

func _ready():
	scene_transition_screen.hide()


func _change_scene(path : String = ""):
	_show_screen()
	scene_to_load = path
	
func _load_new_scene():
	if scene_to_load == "":
		return
	get_tree().call_deferred("change_scene_to_file", scene_to_load)

func _show_screen():
	scene_transition_screen.show()
	
	scene_transition_screen.global_position = Vector2(-scene_transition_screen.size.x, 0)
	
	var tween = get_tree().create_tween()
	tween.tween_property(scene_transition_screen, "global_position", Vector2(0, 0), 0.7).set_ease(Tween.EASE_IN_OUT).connect("finished", _load_new_scene)
	await get_tree().create_timer(1).timeout
	_hide_screen()


func _hide_screen():
	var tween = get_tree().create_tween()
	tween.tween_property(scene_transition_screen, "global_position", Vector2(scene_transition_screen.size.x, 0), 0.7).set_ease(Tween.EASE_IN_OUT)
