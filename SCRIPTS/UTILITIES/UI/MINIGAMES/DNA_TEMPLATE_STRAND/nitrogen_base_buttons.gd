extends GridContainer
class_name NITROGEN_BASES

signal nitrogen_base

func _ready():
	for child in get_children():
		if child is Button:
			child.pressed.connect(_base_pressed.bind(child))


func _base_pressed(button : Button):
	nitrogen_base.emit(button.name)
