extends Control
class_name PreInitiationMinigame

signal minigame_succes
signal closed_ui

@export var screen : PackedScene

@onready var dna_label: Label = $BASE_CONTAINER/DNA_CONTAINER/DNA/RANDOMIZE_DNA_SEQUENCE
@onready var press = $BASE_CONTAINER/PRESS
@onready var meter = $BASE_CONTAINER/METER
@onready var inv_slot = $BASE_CONTAINER/inv_slot
@onready var atp_energy = $BASE_CONTAINER/DNA_CONTAINER/ATP_ENERGY


var is_ui_open : bool = false


const MAX_LETTERS := 38
const BASES := ["A", "T", "G", "C"]
const TATA_BOX := "TATA"

var can_click : bool = true

var dna_sequence: String = ""
var tata_start_index: int
var tata_end_index: int

var required_TATA_finding : int = 3
var TATA_found : int = 0

var is_GTF : bool = true


func _ready():
	
	_set_label()
	
	global_position = Vector2(0, -1000)
	if !is_ui_open:
		_show_ui()
	randomize()
	dna_label.self_modulate.a = 0
	
	
	if not meter:
		return
	
	if is_GTF:
		meter.max_value = required_TATA_finding
	
	if not is_GTF:
		press.disabled = true

# -----------------------------
# DNA GENERATION
# -----------------------------

func _generate_dna():
	dna_sequence = ""
	
	for i in MAX_LETTERS:
		dna_sequence += BASES.pick_random()
	
	_insert_tata()
	dna_label.text = dna_sequence


func _insert_tata():
	tata_start_index = randi_range(0, MAX_LETTERS - TATA_BOX.length())
	tata_end_index = tata_start_index + TATA_BOX.length() - 1
	
	dna_sequence = (
		dna_sequence.substr(0, tata_start_index)
		+ TATA_BOX
		+ dna_sequence.substr(tata_start_index + TATA_BOX.length())
	)


# -----------------------------
# INPUT HANDLING
# -----------------------------

func _on_RANDOMIZE_DNA_SEQUENCE_gui_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("click"):
		if is_GTF:
			_handle_click(event.position)


func _handle_click(local_mouse_pos: Vector2):
	if can_click:
		var char_width := dna_label.size.x / dna_label.text.length()
		var clicked_index := int(local_mouse_pos.x / char_width)

		if clicked_index >= tata_start_index and clicked_index <= tata_end_index:
			_hide_label()
			await get_tree().create_timer(0.4).timeout
			_start()
			
			TATA_found += 1
			meter.value = TATA_found
			GameState._deduct_atp(0.3)
			_set_label()
			
			if TATA_found == required_TATA_finding:
				minigame_succes.emit("PRE_INITIATION")
				_hide_ui()
			
			
		else:
			GameState._deduct_atp(1.0)
			_set_label()
			if not screen:
				return
			var flash_screen = screen.instantiate()
			add_child(flash_screen)
			flash_screen._show_flash_red()


func _show_label():
	can_click = true
	var tween = get_tree().create_tween()
	tween.tween_property(dna_label, "self_modulate:a", 1, 0.4).set_ease(Tween.EASE_IN_OUT)

func _hide_label():
	can_click = false
	var tween = get_tree().create_tween()
	tween.tween_property(dna_label, "self_modulate:a", 0, 0.4).set_ease(Tween.EASE_IN_OUT)

func _show_ui():
	SFX.play(SFX.show, 2,0)
	is_ui_open = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector2(0,20), 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", Vector2(0,0), 0.1).set_ease(Tween.EASE_IN_OUT)

func _hide_ui():
	is_ui_open = false
	if not screen:
		return
	var flash_screen = screen.instantiate()
	add_child(flash_screen)
	flash_screen._show_flash_green()
	await get_tree().create_timer(0.3).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector2(0,20), 0.1).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", Vector2(0,-1000), 0.3).set_ease(Tween.EASE_IN_OUT)
	SFX.play(SFX.show, 2,0)
	await tween.finished
	queue_free()

func _on_press_pressed():
	if is_GTF:
		_start()
		press.disabled = true
	else:
		print("NO GTF FOUND")
	
func _start():
	_generate_dna()
	_show_label()


func _on_close_ui_pressed():
	closed_ui.emit()
	_hide_ui()

func _set_label():
	atp_energy.text = "ATP ENERGY: %0.1f ATP" % GameState.atp_energy
