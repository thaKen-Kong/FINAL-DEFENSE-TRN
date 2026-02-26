extends Control
class_name DNA_MISSION_TERMINAL_UI

signal closed_ui

@export var level_data : LevelDataInfo

@onready var level_container : Panel = $"LEVEL CONTAINER"
@onready var background_screen : ColorRect = $ColorRect
@onready var levels = $"LEVEL CONTAINER/LEVELS/ScrollContainer/VBoxContainer".get_children()
@onready var level_detail_box : VBoxContainer = $"LEVEL DETAIL/TEXT CONTAINER/VBoxContainer"
@onready var start_button : Button = $"LEVEL DETAIL/Start"


var box_shown : bool = false
var def_pos = Vector2(113.75, 132.0)
var is_open : bool = false


func _ready():
	
	global_position = Vector2(0, -1000)
	
	level_detail_box.hide()
	
	#INITIALIZE LEVEL NAMES
	if levels.size() != 0:
		for button in range(levels.size()):
			levels[button].text = "LEVEL " + str(button + 1)
			levels[button].pressed.connect(_level_detail.bind(levels[button]))
			
			if GameState.level_data and GameState.level_data.max_levels != 0:
				levels[button].level = GameState.level_data.levels[button]
			
			#DISABLE BUTTON
			levels[button].disabled = true
	
	if GameState.level_data:
		enable_button()
	
	#DISABLE START BUTTON IF NO LEVEL IS SELECTED
	start_button.disabled = true
	
	if !is_open:
		_show()
		_show_bg_screen()


func enable_button():
	for level_button in levels:
		if level_button.level["unlocked"]:
			level_button.disabled = false

func get_node_children(node : Node):
	if not node:
		pass
	return node.get_children()
	
	

func _level_detail(button : LevelButton):
	if !box_shown:
		level_detail_box.show()
		box_shown = true
	
	#ENABLE START BUTTON
	start_button.disabled = false
	
	
	var level_details = get_node_children(level_detail_box)
	#REWARD
	level_details[0].text = "REWARD: %.1f G" % button.level['reward']
	#TIMER
	level_details[1].text = "TIMER: %.1f s" % button.level['timer']
	#DIFFICULTY
	level_details[2].text = "DELIVERIES: %d MRNA" % button.level['deliveries']
	
	GameState.data = button.level
	
func _on_start_pressed():
	if not GameState.data:
		return
	
	_on_close_pressed()
	await get_tree().create_timer(0.2).timeout
	SceneTransition._change_scene("res://SCENES/WORLD_OBJECT/level/game_area.tscn")

func _show_bg_screen():
	var tween = get_tree().create_tween()
	tween.tween_property(background_screen, "self_modulate:a", 1, 0.4).set_ease(Tween.EASE_IN_OUT)

func _hide_bg_screen():
	var tween = get_tree().create_tween()
	tween.tween_property(background_screen, "self_modulate:a", 0, 0.4).set_ease(Tween.EASE_IN_OUT)

func _show():
	SFX.play(SFX.show, 2,0)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector2(0, 20), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", Vector2(0, 0), 0.2).set_ease(Tween.EASE_IN)
	await tween.finished
	is_open = true

func _hide():
	if is_open:
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", Vector2(0, 20), 0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "global_position", Vector2(0, -1000), 0.2).set_ease(Tween.EASE_IN)
		_hide_bg_screen()
		SFX.play(SFX.show, 2,0)
		await tween.finished
		queue_free()


func _on_close_pressed():
	_hide()
	closed_ui.emit()
