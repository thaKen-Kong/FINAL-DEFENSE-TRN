extends Control
class_name DNA_TEMPLATE_STRAND

var is_shown : bool = false

@onready var dna_sequence_template = $DNA_SEQUENCE_TEMPLATE


func _ready():
	modulate.a = 0
	_visibility()

func _input(event):
	if event.is_action_pressed("click") and is_shown:
		is_shown = false
		_visibility()

func _visibility():
	if is_shown:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 1, 0.2).set_ease(Tween.EASE_IN_OUT)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.2).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		queue_free()
