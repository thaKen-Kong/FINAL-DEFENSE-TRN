@tool
extends Control
class_name PauseScreen

@export var background_screen : ColorRect
@export var base : Panel


func _ready():
	if not background_screen:
		return
	
	for child in $Base/VBoxContainer.get_children():
		if child is Button:
			child.mouse_entered.connect(func(): SFX.play(SFX.select_click, 2, 2))
			child.pressed.connect(func(): SFX.play(SFX.click_2, 20, 4))
	
	background_screen.self_modulate.a = 0
	base.modulate.a = 0
	
	_show_bg_screen()
	_show_menu()

func _show_bg_screen():
	var tween = get_tree().create_tween()
	tween.tween_property(background_screen, "self_modulate:a", 1, 0.4).set_ease(Tween.EASE_IN_OUT)

func _hide_bg_screen():
	var tween = get_tree().create_tween()
	tween.tween_property(background_screen, "self_modulate:a", 0, 0.4).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()

func _show_menu():
	var tween = get_tree().create_tween()
	tween.tween_property(base, "modulate:a", 1, 0.4).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	GameState.is_paused = true
	get_tree().paused = true

func _hide_menu():
	var tween = get_tree().create_tween()
	tween.tween_property(base, "modulate:a", 0, 0.4).set_ease(Tween.EASE_IN_OUT)
	GameState.is_paused = false
	get_tree().paused = false

	await tween.finished
	_hide_bg_screen()


func _on_resume_pressed():
	_hide_menu()


func _on_settings_pressed():
	pass # Replace with function body.


func _on_restart_pressed():
	pass # Replace with function body.


func _on_saveandexit_pressed():
	_hide_menu()
	SceneTransition._change_scene("res://SCENES/UTILITIES/UI/main_menu_screen.tscn")


func _on_go_to_lobby_pressed():
	_hide_menu()
	SceneTransition._change_scene("res://SCENES/WORLD_OBJECT/world.tscn")
