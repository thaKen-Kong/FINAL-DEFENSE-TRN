extends Area2D
class_name DROP_AREA

signal placed
signal in_drop_area

@export var drop_area_name: String = "DEFAULT"
@export var accepted_object_name: String = ""

var placed_object: obj = null
var hovering_object: obj = null

const DROP_ACTION_PREFIX := "PLACE IN "

func _on_area_entered(area: Area2D) -> void:
	if not area is ClickableInteractionArea:
		return

	var parent_obj := area.get_parent()
	if not parent_obj is obj:
		return

	# Reject if already occupied
	if placed_object:
		return

	# Reject wrong object type
	if accepted_object_name != "" and parent_obj.object_name != accepted_object_name:
		return

	hovering_object = parent_obj
	parent_obj.drop_area = self

	# IMPORTANT: this is required for your obj script
	parent_obj._init_drop_area()

	area.action_name = DROP_ACTION_PREFIX + drop_area_name
	in_drop_area.emit()


func _on_area_exited(area: Area2D) -> void:
	if not area is ClickableInteractionArea:
		return

	var parent_obj := area.get_parent()
	if parent_obj != hovering_object:
		return

	area.action_name = parent_obj.grab_action
	parent_obj.drop_area = null
	hovering_object = null
