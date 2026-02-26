extends NinePatchRect
class_name InvSlot

signal Item

@onready var item_texture_node: TextureRect = $Panel/MarginContainer/TextureRect

# --------------------------------------------------
# TEMPORARY INSPECTOR VARIABLES (EDITOR SETUP ONLY)
# --------------------------------------------------
@export var initial_item_name: String
@export var initial_item_texture: Texture2D
@export var drop_slot : String
# --------------------------------------------------
# SLOT ITEM DATA (RUNTIME SOURCE OF TRUTH)
# --------------------------------------------------
var item_data: Dictionary = {
	"name": null,
	"texture": null
}

# --------------------------------------------------
# SLOT STATE HELPERS
# --------------------------------------------------

func is_empty() -> bool:
	return item_data["texture"] == null


func set_item(name: String, texture: Texture2D):
	item_data["name"] = name
	item_data["texture"] = texture
	item_texture_node.texture = texture


func clear_item():
	item_data["name"] = null
	item_data["texture"] = null
	item_texture_node.texture = null


# --------------------------------------------------
# INITIALIZATION
# --------------------------------------------------

func _ready():
	# Initialize dictionary from exported variables
	if initial_item_texture != null:
		set_item(initial_item_name, initial_item_texture)
	else:
		clear_item()


# --------------------------------------------------
# DRAG SOURCE
# --------------------------------------------------

func _get_drag_data(at_position: Vector2):
	if is_empty():
		return null

	var preview := item_texture_node.duplicate()
	preview.custom_minimum_size = item_texture_node.size
	set_drag_preview(preview)

	return {
		"item_data": item_data.duplicate(),
		"from_slot": self
	}


# --------------------------------------------------
# DROP TARGET
# --------------------------------------------------

func _can_drop_data(at_position: Vector2, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("item_data")


func _drop_data(at_position: Vector2, data):
	var from_slot: InvSlot = data["from_slot"]
	var incoming_item: Dictionary = data["item_data"]

	# Prevent self-drop
	if from_slot == self:
		return

	# Store current item for swap
	var temp_item := item_data.duplicate()

	# Apply incoming item
	set_item(incoming_item["name"], incoming_item["texture"])

	# Restore previous item to source slot
	if temp_item["texture"] == null:
		from_slot.clear_item()
	else:
		from_slot.set_item(temp_item["name"], temp_item["texture"])
		
