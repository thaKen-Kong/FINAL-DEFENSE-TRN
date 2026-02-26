extends Control
class_name BASE_PARING_MINIGAME

signal paired
signal minigame_success
signal closed_ui

@export var DNA_TEMPLATE : PackedScene
#NODES
@onready var codon = $BASE_CONTAINER/DNA_CONTAINER/CODON
@onready var stored_codon = $BASE_CONTAINER/MRNA_CONTAINER/GridContainer
@onready var codon_pair = $BASE_CONTAINER/BUTTONS/CODON_PAIR
@onready var codon_paired_label = $BASE_CONTAINER/BUTTONS/CODON_PAIRED
@onready var atp = $BASE_CONTAINER/BUTTONS/ATP


#VARIABLES
@export var dna_template_strand : String
var arr_strand : Array
var template_length : int = 12
var display_strand
var bases = ["A", "T", "G", "C"]
var codon_group_count : int = 4
var codons : Array
var strand : Array

var index : int
var recurse : int = 4

var codon_paired : int = 0
var max_codon_paired : int = 4

var is_ui_open : bool = false

func _ready():
	if not codon:
		return
	
	global_position = Vector2(0, -1000)
	_show_ui()
	
	_set_label()
	
	_set_template_strand()
	_set_display_codon()
	_next_codon(codon_paired)
	
	
	codon.matched.connect(_store_codon)

func _on_template_strand_gui_input(event):
	if event.is_action_pressed('click'):
		var dna_template_node = DNA_TEMPLATE.instantiate()
		dna_template_node.is_shown = true
		add_child(dna_template_node)
		
		_get_template_strand_node()


func _on_check_pair_pressed():
	codon._check_pair()

func _store_codon(codon_node):
	if codon_node is CODON:
		if codon_paired < max_codon_paired:
			_add_codon_to_mrna_container(codon_node)
			if codon_paired < max_codon_paired:
				codon_paired += 1
				_next_codon(codon_paired)
				_set_label()

func _add_codon_to_mrna_container(node : CODON):
	var new_codon = node.duplicate()
	new_codon.custom_minimum_size = new_codon.codon_scale
	new_codon._set_children()
	new_codon._set_label_scale()
	new_codon.slots.add_theme_constant_override("h_separation", 21)
	var labels = new_codon.slots.get_children()
	new_codon.slots.position = Vector2(20, 5)
	
	for label in labels:
		label.add_theme_font_size_override("font_size", 24)
	
	new_codon.can_add_base = false
	
	stored_codon.add_child(new_codon)

func _set_template_strand():
	for index in range(template_length):
		dna_template_strand += bases.pick_random()
		arr_strand = dna_template_strand.split("")
	
	_group_codon()
	
func _group_codon():
	var base_size = 3
	var codon_code = []
	codon_code = arr_strand.slice(0, base_size)   # first N elements
	arr_strand = arr_strand.slice(base_size, arr_strand.size())  # remove them
	if codons.size() < 4:
		codons.append(codon_code)
	
	if index < recurse:
		index += 1
		_group_codon()

func _set_display_codon():
	for codon_code in codons:
		strand.append("".join(codon_code))
	
	for codes in strand:
		display_strand = "-".join(strand)
	

func _get_template_strand_node():
	for child in get_children():
		if child is DNA_TEMPLATE_STRAND:
			child.dna_sequence_template.text = display_strand

func _next_codon(index):
	if index < max_codon_paired:
		codon._initialize_code(strand[index])
		codon_pair.text = strand[index]

func _set_label():
	atp.text = "ATP: %d" % 10
	codon_paired_label.text = "CODON PAIRED: %d/%d" % [codon_paired, max_codon_paired]
	if codon_paired == max_codon_paired:
		codon_pair.text = ""
		codon_pair.tooltip_text = ""
		
		minigame_success.emit("BASE_PARING")
		_hide_ui()

func _show_ui():
	SFX.play(SFX.show, 2,0)
	is_ui_open = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector2(0,20), 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", Vector2(0,0), 0.1).set_ease(Tween.EASE_IN_OUT)

func _hide_ui():
	
	is_ui_open = false
	await get_tree().create_timer(0.2).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector2(0,20), 0.1).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", Vector2(0,-1000), 0.3).set_ease(Tween.EASE_IN_OUT)
	SFX.play(SFX.show, 2,0)
	await tween.finished
	paired.emit()
	
	queue_free()
	


func _on_close_pressed():
	_hide_ui()
	closed_ui.emit()
