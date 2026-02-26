extends TextureRect
class_name CODON

signal matched

#EXPORTED NODES
@export var nb_buttons : NITROGEN_BASES

#NODES
@export var slots : GridContainer

#VARIABLES
@export var codon_code : String

var can_add_base : bool = true

var codon_size : Array
var bases : Array
var base_index : int = 0
var base_input = []

var codon_to_pair : int
var codon_paired : int

var codon_scale = Vector2(size.x * 0.24, size.y * 0.24)

func _ready():
	if not nb_buttons:
		return
	nb_buttons.nitrogen_base.connect(_pair_base)
	_set_children()

func _display_base(base):
	if base_index < codon_size.size():
		bases[base_index].text = base
		base_index += 1
	
func _pair_base(base : String):
	if not can_add_base:
		return
	if codon_size == []:
		return
	
	if codon_size.size() > 0 and base_input.size() < codon_size.size():
		base_input.append(base)
		_display_base(base)


func _complementary_base(base):
	match base:
		"A" : return "U"
		"T" : return "A"
		"G" : return "C"
		"C" : return "G"

func _reset():
	base_index = 0
	base_input = []
	
	for base in slots.get_children():
		base.text = ""
	

func _check_pair():
	if codon_size == []:
		return

	
	if codon_size == base_input and base_index == codon_size.size():
		matched.emit(self.duplicate())
		_add_codon_paired()
		_reset()
	elif codon_size != base_input and base_index == codon_size.size():
		_reset()

func _add_codon_paired():
	codon_paired += 1
	if codon_paired == codon_to_pair:
		print("YO")
	
func _set_children():
	bases = slots.get_children()

func _set_label_scale():
	for slot in slots.get_children():
		slot.custom_minimum_size = Vector2(30, 38)

func _set_code(code):
	codon_code = code

func _initialize_code(code):
	codon_size = []
	
	for base in code.split(""):
		codon_size.append(_complementary_base(base))
	
	print(codon_size)
