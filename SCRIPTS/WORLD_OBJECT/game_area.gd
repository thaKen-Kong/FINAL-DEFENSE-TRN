extends Node2D
class_name GAME_AREA

@export var npc : nucleolus_npc

@onready var object_spawn_points = $ObjectSpawnPoints
@onready var dna_object = $Objects/DNA_OBJECT
@onready var player = get_tree().get_first_node_in_group("player")

@onready var rnap_spawn_point = $ObjectSpawnPoints/RNAP_SPAWN_POINT
@onready var inc_messenger_rna_spawn_point = $ObjectSpawnPoints/INC_MESSENGER_RNA_SPAWN_POINT
@onready var exit_site = $"EXIT SITE"
@onready var objects = $Objects

@export var reward_scene : PackedScene

var required_deliveries : int = 1
var delivered_mrna : int = 0
var timer : float

var data = {}

func _ready():
	if npc:
		if !Tutorial.tutorial_finished:
			npc.resume_talk()
	
	
	if GameState.data:
		required_deliveries = GameState.data['deliveries']
		timer = GameState.data["timer"]
	
	if not exit_site:
		return
	
	exit_site.placed.connect(_delivered_object)

func _delivered_object(mrna : obj):
	if mrna.object_name == "MRNA":
		delivered_mrna += 1
		if required_deliveries > 1:
			dna_object._reset_dna(true)
	
	if mrna in objects.get_children():
		exit_site.placed_object = null
		exit_site.hovering_object = null
		await get_tree().create_timer(1).timeout
		objects.remove_child(mrna)
	
	if delivered_mrna == required_deliveries:
		if GameState.data:
			data["energy"] = GameState.atp_energy
			data["delivered"] = delivered_mrna
			data["max_deliveries"] = required_deliveries
			data["base_reward"] = GameState.data["reward"]
			data["status"] = true
		
			var reward_instantiate = reward_scene.instantiate()
			reward_instantiate.GameData = data
			player.ui_handler.add_child(reward_instantiate)
			player.player_ui.is_consuming_points = false
