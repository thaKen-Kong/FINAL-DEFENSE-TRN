extends Control
class_name REWARD_SCENE
@onready var leve_status = $LEVE_STATUS



@onready var mrna_delivered = $MRNA_DELIVERED
@onready var atp_energy_left = $ATP_ENERGY_LEFT
@onready var base_level_reward = $BASE_LEVEL_REWARD
@onready var total_reward_label = $TOTAL_REWARD
@onready var completed = $Completed
@onready var animation_player = $AnimationPlayer


#AMOUNTS LABEL NODE
@onready var atp_left_amount = $ATP_ENERGY_LEFT/AMOUNT
@onready var mrna_delivered_amount = $MRNA_DELIVERED/AMOUNT


#REWARD LABEL NODE
@onready var mrna_delivered_reward = $MRNA_DELIVERED/REWARD
@onready var atp_energy_left_reward = $ATP_ENERGY_LEFT/REWARD
@onready var base_reward = $BASE_LEVEL_REWARD/REWARD
@onready var total_reward_amount = $TOTAL_REWARD/TOTAL_REWARD2

var reward_1 : int
var reward_2 : int
var reward_3 : int
var total_reward : int

var reward_per_mrna = 100
var reward_per_atp_left = 5

var GameData = {
	"delivered" : 1,
	"max_deliveries" : 1,
	"base_reward" : 100,
	"energy" : 100,
	"status" : true
}

func _ready():
	GameState.is_paused = true
	get_tree().paused = true
	
	completed.modulate.a = 0
	
	_level_status()
	reward_calculation()
	reward_display()
	

func _get_children_node(node : Node):
	if not node:
		return node.get_children()
	
	return node.get_children()


func _on_finish_button_pressed():
	GameState.is_paused = false
	GameState.unlockLevel()
	get_tree().paused = false
	SceneTransition._change_scene("res://SCENES/WORLD_OBJECT/world.tscn")

func _level_status():
	if GameData.get("status") == true:
		leve_status.text = "LEVEL COMPLETED"
	elif GameData.get("status") == false:
		leve_status.text = "TIME RAN OUT"

func reward_display():
	var tween = create_tween()
	tween.tween_method(Callable(self, "mrna_delivered_calculation"), 0, GameData.get("delivered"), 1)
	tween.tween_method(Callable(self, "mrna_reward"), 0, reward_1, 1)
	tween.tween_method(Callable(self, "atp_energy_amount_calculation"), 0, GameData.get("energy"), 1)
	tween.tween_method(Callable(self, "atp_reward"), 0, reward_2, 1)
	tween.tween_method(Callable(self, "base_reward_calculation"), 0, reward_3, 1)
	tween.tween_method(Callable(self, "total_reward_calculation"), 0, total_reward, 1)
	
	await tween.finished
	stamp()

#MRNA
func mrna_delivered_calculation(value : float):
	mrna_delivered_amount.text = "%.1f/%.1f MRNA" % [value, GameData.get("max_deliveries")]

func mrna_reward(value : float):
	mrna_delivered_reward.text = "%d GUANIX" % int(value)

#ATP
func atp_energy_amount_calculation(value : float):
	atp_left_amount.text = "%.1f ATP" % value

func atp_reward(value : float):
	atp_energy_left_reward.text = "%d GUANIX" % int(value)

#BASE LEVEL
func base_reward_calculation(value : float):
	base_reward.text = "%d GUANIX" % int(value)


#TOTAL REWARD
func total_reward_calculation(value : float):
	total_reward_amount.text = "%d GUANIX" % value
	
func reward_calculation():
	if GameData:
		reward_1 = GameData.get("delivered") * reward_per_mrna
		reward_2 = GameData.get("energy") * reward_per_atp_left
		reward_3 = GameData.get("base_reward")
		total_reward = reward_1 + reward_2 + reward_3
		GameState.guanix += total_reward

func stamp():
	
	var tween = create_tween()
	tween.tween_property(completed, "modulate:a", 1, 0.2).set_ease(Tween.EASE_IN_OUT)
	SFX.play(SFX.whoosh)
	animation_player.play("show_stamp")
	
