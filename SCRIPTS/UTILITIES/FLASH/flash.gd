extends Control
class_name flash

@onready var green = $green
@onready var red = $red


func _ready():
	green.self_modulate.a = 0
	red.self_modulate.a = 0

func _show_flash_green():
	var tween = get_tree().create_tween()
	tween.tween_property(green, "self_modulate:a", 1, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(green, "self_modulate:a", 0, 0.2).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()
	
func _show_flash_red():
	var tween = get_tree().create_tween()
	tween.tween_property(red, "self_modulate:a", 1, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(red, "self_modulate:a", 0, 0.2).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()
