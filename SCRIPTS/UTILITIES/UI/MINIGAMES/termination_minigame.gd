extends Control
class_name TERMINATION_MINIGAME

signal minigame_success

@export var flash_screen : PackedScene

@onready var timer_bar = $BASE_CONTAINER/Timer_Bar
@onready var progress_bar = $BASE_CONTAINER/CONTAINER/ProgressBar
@onready var start = $Start
@onready var animation_player = $AnimationPlayer



@export var fill_amount : float
@export var decay_amount : float
@export var timer : float

var timer_duration : float

var is_filled : bool = false
var started : bool = false
var status : bool = false

func _ready():
	global_position = Vector2(0, -1000)
	_show_ui()
	
	if timer == 0:
		return
	
	timer_duration = timer
	timer_bar.value = timer
	timer_bar.max_value = timer

func _input(event):
	if event.is_action_pressed("interact") and !is_filled and started:
		progress_bar.value += fill_amount
		animation_player.play("termination")

func _process(delta):
	if started and !is_filled:
		timer -= delta
		timer_bar.value = timer
		if timer <= 0:
			if not is_filled:
				started = false
				timer = timer_duration
				start.disabled = false
				progress_bar.value = 0
				failed()
				
		if progress_bar.value > 0 and !is_filled:
			progress_bar.value -= decay_amount * delta
			
		if progress_bar.value > 99:
			progress_bar.value = 100
			is_filled = true
			success()

func _on_start_pressed():
	start.disabled = true
	started = true

func success():
	var screen_instance = flash_screen.instantiate()
	add_child(screen_instance)
	screen_instance._show_flash_green()
	minigame_success.emit("TERMINATION")
	_hide_ui()

func failed():
	var screen_instance = flash_screen.instantiate()
	add_child(screen_instance)
	start.text = "AGAIN"
	screen_instance._show_flash_red()
	print("FAILED")
	print("TRY AGAIN")

func _show_ui():
	SFX.play(SFX.show, 2,0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector2(0,20), 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", Vector2(0,0), 0.1).set_ease(Tween.EASE_IN_OUT)

func _hide_ui():
	await get_tree().create_timer(0.5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector2(0,20), 0.1).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", Vector2(0,-1000), 0.3).set_ease(Tween.EASE_IN_OUT)
	SFX.play(SFX.show, 2,0)
	await tween.finished
	
	queue_free()
