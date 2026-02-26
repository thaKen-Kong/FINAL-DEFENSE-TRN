extends Area2D
class_name ClickableInteractionArea

signal interacted

@export var is_interactable : bool = true
@export var action_name : String = "DEF"

@export var sprite : Sprite2D
@export var object_name : String = "Object"
@export var font_path := "res://ASSETS/fonts/TrueType (.ttf)/Kaph-Regular.ttf"

var custom_font: Font
var interact : Callable = func():
	pass

var name_label: Label

# ===============================
# Lifecycle
# ===============================

func _ready():
	interacted.connect(_interacted)
	_create_name_label()
	_update_label_position()
	
	custom_font = load(font_path)
	_create_name_label()
	_update_label_position()

# ===============================
# Label System
# ===============================

func _create_name_label():
	name_label = Label.new()
	name_label.text = object_name
	name_label.visible = false
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.z_index = 100
	
	if font_path != "":
		custom_font = load(font_path)
		name_label.add_theme_font_override("font", custom_font)
		
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(1, 1, 0.9))
	name_label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.6))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(name_label)

func _update_label_position():
	if not sprite:
		return

	var rect := sprite.get_rect()
	name_label.position = Vector2(
		rect.size.x * 0.5 - name_label.size.x * 0.5,
		-rect.size.y * 0.6
	)

# ===============================
# Interaction Logic
# ===============================

func _interacted():
	is_interactable = false
	if name_label:
		name_label.visible = false

func _on_body_entered(body):
	if body.is_in_group("player") and is_interactable:
		InteractionSystem.register_area(self)
		if name_label:
			name_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		InteractionSystem.unregister_area(self)
		if name_label:
			name_label.visible = false
