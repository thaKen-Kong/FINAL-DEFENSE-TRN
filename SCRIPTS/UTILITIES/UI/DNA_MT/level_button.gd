extends Button
class_name LevelButton


var level

func _ready():
	mouse_entered.connect(func(): SFX.play(SFX.select_click, -1, 1))
	pressed.connect(func(): SFX.play(SFX.click_2, 20, 4))
