extends Control


@export var PauseScreenMenu : PackedScene
@onready var atp_energy_label = $ATP_ENERGY_LABEL
@onready var guanix = $GUANIX

@onready var atp_points_durability = $ATP_POINTS_DURABILITY

var is_consuming_points : bool = false
var refilled_atp : bool = false

func _ready():
	_set_atp_energy_bar()

func _consume():
	if not is_consuming_points:
		is_consuming_points = true
	else:
		is_consuming_points = false

func _on_settings_pressed():
	GameState.is_paused = true
	if not PauseScreenMenu:
		return
	
	var pauseScreen = PauseScreenMenu.instantiate()
	add_child(pauseScreen)

func _set_atp_energy_bar():
	atp_energy_label.text = "ATP ENERGY: %0.2f ATP" % GameState.atp_energy
	atp_points_durability.max_value = GameState.atp_points
	atp_points_durability.value = GameState.atp_points
	refilled_atp = false


func _process(delta):
	_update_label()
	if not is_consuming_points:
		return
	
	if not refilled_atp:
		atp_points_durability.value += GameState.atp_points_reduction * delta
	if atp_points_durability.value == 0 and GameState.atp_energy > 0:
		refilled_atp = true
		atp_points_durability.value = GameState.atp_points
		GameState.atp_energy -= GameState.atp_energy_reduction
		if refilled_atp:
			_set_atp_energy_bar()
	
func _update_label():
	atp_energy_label.text = "ATP ENERGY: %0.2f ATP" % GameState.atp_energy
	guanix.text = "GAUNIX: %d G" % GameState.guanix
