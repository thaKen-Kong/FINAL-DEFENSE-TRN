extends Sprite2D
class_name INCOMPLETE_MESSENGER_RNA

signal paired_done

@onready var dna = get_tree().get_first_node_in_group("dna")
@onready var player = get_tree().get_first_node_in_group("player")
@export var base_paring_minigame_ui : PackedScene
@onready var clickable_interaction_area = $ClickableInteractionArea
@onready var animation_player = $AnimationPlayer


func _ready():
	clickable_interaction_area.interact = Callable(self, "start_transcribing")


func start_transcribing():
	if not base_paring_minigame_ui:
		return
	
	var base_paring = base_paring_minigame_ui.instantiate()
	
	if !base_paring.is_ui_open and base_paring is BASE_PARING_MINIGAME:
		dna._instantiate_minigame(base_paring)
		base_paring.closed_ui.connect(func(): clickable_interaction_area.is_interactable = true)
		base_paring.paired.connect(_despawn)

func _despawn():
	animation_player.play("spawn")
	await animation_player.animation_finished
	queue_free()
