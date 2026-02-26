extends Control
class_name INITIATION_MINIGAME

signal minigame_success

@export var f : PackedScene

@onready var meter = $BASE_CONTAINER/METER
@onready var progress_bar = $BASE_CONTAINER/CONTAINER/ProgressBar
@onready var atp_energy = $BASE_CONTAINER/CONTAINER2/ATP_ENERGY
@onready var rnap_texture = $BASE_CONTAINER/RNAP_TEXTURE
@onready var animation_player = $AnimationPlayer
@onready var combo_label = $BASE_CONTAINER/Combo


@export var shrink_increment : float
@export var progress_fill : float
@export var progress_decay : float

var filled : bool = false

var combo : int = 0
var atp_reduction : float = 1

func _ready():
	_calculate_combo_atp_reduction()
	combo_label.hide()
	_update_atp_label()
	global_position = Vector2(0, -1000)
	_show_ui()
	
	if not meter:
		return
	meter.clicked_success.connect(_power_meter_clicked)
	meter.clicled_failed.connect(_failed_click)

func _power_meter_clicked():
	combo += 1
	combo_label.show()
	_animate_combo_text()
	_calculate_combo_atp_reduction(combo)
	combo_label.text = "COMBO %d" % combo
	progress_bar.value += progress_fill
	shrink_rna()

func _process(delta):
	_update_atp_label()
	if progress_bar.value > 0 and not filled:
		progress_bar.value -= progress_decay * delta
		
	if progress_bar.value >= 98 and not filled:
		filled = true
		progress_bar.value = 100
		meter.stopped = true
		_hide_ui()

func shrink_rna():
	var screen = f.instantiate()
	add_child(screen)
	screen._show_flash_green()
	animation_player.play("rnap")

func _failed_click():
	combo = 0
	combo_label.hide()
	GameState._deduct_atp(1)
	var screen = f.instantiate()
	add_child(screen)
	screen._show_flash_red()


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
	
	minigame_success.emit("INITIATION")
	
	queue_free()

func _update_atp_label():
	atp_energy.text = "ATP: %0.1f" % GameState.atp_energy

func _animate_combo_text():
	var tween = get_tree().create_tween()
	tween.tween_property(combo_label, "theme_override_font_sizes/font_size", 50, 0.1).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(combo_label, "theme_override_font_sizes/font_size", 40, 0.1).set_ease(Tween.EASE_IN_OUT)

func _calculate_combo_atp_reduction(consistent: float = 0):
	if consistent == 0:
		return
	var reduced_reduction = atp_reduction - abs(atp_reduction - (1 / consistent))
	GameState._deduct_atp(reduced_reduction)
	
