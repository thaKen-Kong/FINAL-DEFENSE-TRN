extends StaticBody2D
class_name DNA_MT

@onready var interaction_area : ClickableInteractionArea = $ClickableInteractionArea
@export var DNA_UI : PackedScene


func _ready():
	if interaction_area:
		interaction_area.interact = Callable(self, "talk")

func talk():
	if not DNA_UI:
		return
		
	var intance_ui = DNA_UI.instantiate()
	$UI.add_child(intance_ui)
	if $UI.get_child(0) is Control:
		$UI.get_child(0).closed_ui.connect(func():
			interaction_area.is_interactable = true
			)
