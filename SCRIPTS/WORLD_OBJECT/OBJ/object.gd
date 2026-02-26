extends RigidBody2D
class_name obj




@onready var interaction_area = $ClickableInteractionArea
@onready var player = get_tree().get_first_node_in_group("player")
@onready var object_sprite = $OBJECT_SPRITE
@onready var object_shadow = $OBJECT_SHADOW
@onready var animation_player = $AnimationPlayer


@export var object_name : String


var drop_area : DROP_AREA
var is_grabbed : bool = false
var is_in_dropped_area : bool = false
var place_in_drop_area

@export var grab_action = "GRAB "
@export var drop_action = "DROP "


func _ready():
	initialize_spawn_pos()
	
	gravity_scale = 0
	angular_damp = 4
	linear_damp = 4
	
	if not interaction_area:
		return
	interaction_area.interact = Callable(self, "state")
	
	if not animation_player:
		return
	
	if object_name == "RNAP2" and animation_player.has_animation("play"):
		animation_player.play("play")

func state():
	if is_grabbed:
		if is_in_dropped_area:
			place_in_drop_area = true
			if drop_area:
				drop_area.placed_object = self
				drop_area.placed.emit(self)
		drop()
	elif !is_grabbed:
		grab()
		place_in_drop_area = true
	

func grab():
	if not player:
		return
	
	if player.object_held == null:
		player.object_held = self
		is_grabbed = true
	player.object_held = self
	object_shadow.hide()
	if drop_area:
		drop_area.placed_object = null
	interaction_area.action_name = drop_action
	

func drop():
	if not player:
		return
	player.object_held = null
	is_grabbed = false
	gravity_scale = 1.6
	object_shadow.show()
	await get_tree().create_timer(0.2).timeout
	gravity_scale = 0
	interaction_area.is_interactable = true
	interaction_area.action_name = grab_action

func _init_drop_area():
	if not drop_area:
		return
	
	drop_area.in_drop_area.connect(func(): 
		is_in_dropped_area = true
	)
	

func _physics_process(delta):
	if is_grabbed:
		global_position = lerp(global_position, player.hand.global_position, 25 * delta)
		interaction_area.is_interactable = true
	elif place_in_drop_area and drop_area:
		global_position = lerp(global_position, drop_area.global_position, 25 * delta)



func initialize_spawn_pos():
	object_sprite.position = Vector2(0, -1000)
	spawn()

func spawn():
	var tween = get_tree().create_tween()
	tween.tween_property(object_sprite, "position", Vector2(0, 0), 0.5).set_ease(Tween.EASE_IN)
	await tween.finished
	SFX.play_multiple([SFX.thud], 10)
	if player:
		player.camera.shake(0.2, 10)
