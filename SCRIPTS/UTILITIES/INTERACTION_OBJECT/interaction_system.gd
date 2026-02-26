extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label: Label = $CanvasLayer/Label

var active_areas: Array[ClickableInteractionArea] = []
var can_interact: bool = true

var base_action : String = "[SPACE] "

# Register/unregister areas
func register_area(area: ClickableInteractionArea):
	if area not in active_areas:
		active_areas.push_back(area)

func unregister_area(area: ClickableInteractionArea):
	active_areas.erase(area)

# Sorting function: closest area first
func _sort_by_distance_to_player(area1, area2):
	if area1 and area2:
		var d1 = player.global_position.distance_to(area1.global_position)
		var d2 = player.global_position.distance_to(area2.global_position)
		return d1 < d2

func _process(_delta):
	if active_areas.size() > 0:
		active_areas.sort_custom(_sort_by_distance_to_player)
		
		var closest_area = active_areas[0]
		
		# Update label
		if closest_area.is_interactable:
			label.show()
			label.text = base_action + closest_area.action_name
		else:
			label.hide()
	else:
		label.hide()

# Handle input
func _input(event):
	if event.is_action_pressed("interact") and can_interact and active_areas.size() > 0:
		can_interact = false
		var closest_area = active_areas[0]
		if closest_area.interact and closest_area.is_interactable:
			await closest_area.interact.call()
		closest_area.interacted.emit()
		can_interact = true
