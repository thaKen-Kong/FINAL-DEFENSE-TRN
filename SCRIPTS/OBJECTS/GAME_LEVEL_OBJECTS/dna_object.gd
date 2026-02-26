extends StaticBody2D
class_name DNA_OBJ

var parent : Node

@export var rnap : PackedScene
@export var inc_mrna_object : PackedScene
@export var mrna_object : PackedScene

@export var pre_initiation_minigame_scene : PackedScene
@export var initiation_minigame_scene : PackedScene
@export var termination_minigame_scene : PackedScene
@export var key_sequence : PackedScene


@onready var DNA_SPRITE : Node2D = $DNA_SPRITE
@onready var DNA_SHADOW : Sprite2D = $DNA_SHADOW
@onready var player = get_tree().get_first_node_in_group("player")
@onready var clickable_interaction_area = $ClickableInteractionArea
@onready var object_drop_area = $OBJECT_DROP_AREA
@onready var elongation_path = $ELONGATION_PATH
@onready var rna_p_path_follow = $ELONGATION_PATH/RNA_P_PATH_FOLLOW
@onready var elongation_progress = $ELONGATION_PATH/RNA_P_PATH_FOLLOW/RNA_ELONGATION/ELONGATION_PROGRESS



@onready var drop_area_sprite = $OBJECT_DROP_AREA/Sprite2D


#PHASE ENUM
enum PHASES {PRE_INIT, INIT, ELONGATION, TERMINATION, BASE_PARING, DELIVERY}
var phase = PHASES.PRE_INIT

#VARIABLES
var dna_pos = Vector2(0, 0)

#PHASES DONE
var is_pre_initation : bool = false
var is_initiation : bool = false
var is_elongation : bool = false
var is_termination : bool = false
var is_transcribed : bool = false


#ELONGATION VARIABLES
var is_elongating : bool = false
var is_elongated : bool = false
@export var elongation_speed : float = 0.1
var is_back_tracking : bool = false
var back_tracking_chance = 0.3 # 10% CHANCE TO BACKTRACK RNA
var back_track_duration = 1.0

func _ready():
	_backtrack()
	
	#HIDE ELONGATION PATH
	elongation_path.modulate.a = 0
	
	#GET PARENT
	parent = get_parent().get_parent()
	object_drop_area.modulate.a = 0
	#INITIALIZE DNA POS AND SHADOW
	if not player:
		return
	_init_dna()
	
	if not clickable_interaction_area:
		return
	
	clickable_interaction_area.interact = Callable(self, "_pre_initiation")
	object_drop_area.placed.connect(_rna_placed)

#PROCESS
func _process(delta):
	
	#ELONGATION PROCESS
	if !is_elongated and !is_elongation:
		_elongating(delta)

func _instantiate_minigame(node : Node):
	if not node:
		return
		
	player.ui_handler.add_child(node)
		
	for child in player.ui_handler.get_children():
		if child is PreInitiationMinigame:
			child.closed_ui.connect(func(): clickable_interaction_area.is_interactable = true)
			child.minigame_succes.connect(_phase_completed)
		if child is INITIATION_MINIGAME:
			child.minigame_success.connect(_phase_completed)
		if child is TERMINATION_MINIGAME:
			child.minigame_success.connect(_phase_completed)
		if child is BASE_PARING_MINIGAME:
			child.minigame_success.connect(_phase_completed)

# -------------
# PHASES
# -------------
func _pre_initiation():
	if !is_pre_initation and player:
		var pre_init_minigame_instance = pre_initiation_minigame_scene.instantiate()
		_instantiate_minigame(pre_init_minigame_instance)

#INITIATION PHSAE PART 1
func _initiation():
	if is_initiation:
		return
	
	if not parent and not rnap:
		return
	
	if parent.rnap_spawn_point:
		var rnap_instance = rnap.instantiate()
		rnap_instance.global_position = parent.rnap_spawn_point.global_position
		parent.objects.add_child(rnap_instance)
	
	#SHOW PROMOTER
	_promoter()
	
#INITIATION PHASE PART 2
func _rna_placed(rna_polymerase_object : obj):
	if is_initiation:
		return
	
	if not initiation_minigame_scene:
		return
	
	var initiation_minigame = initiation_minigame_scene.instantiate()
	_instantiate_minigame(initiation_minigame)

	rna_polymerase_object.interaction_area._interacted()

#ELONGATION PHASE
#ELONGATION PART 1
func _elongate():
	if is_elongation:
		return
		
	_elongation()
	
	if not parent:
		return
	
	for child in parent.objects.get_children():
		if child is obj:
			if child.object_name == "RNAP2":
				object_drop_area.placed_object = null
				object_drop_area.hovering_object = null
				print(child.object_name)
				child.queue_free()
	
	is_elongating = true

#ELONGATION PART 2
func _elongating(delta):
	if is_elongated:
		return
	
	if not is_elongating:
		return
	

	if !is_back_tracking:
		back_track_duration -= delta
		if back_track_duration <= 0:
			back_track_duration = 1
			#WHEN ELONGATING DEDUCTS 1 ATP PER SECOND
			GameState._deduct_atp(1)
			var paused = _backtrack()
			if paused:
				if not key_sequence:
					return
				var key = key_sequence.instantiate()
				if key is RNAP_PAUSED:
					key.key_sequence_status.connect(func(condition) : 
						if condition:
							is_back_tracking = false
						else:
							is_back_tracking = false
							GameState._deduct_atp(5)
							)
				player.ui_handler.add_child(key)
				is_back_tracking = true
	
	if !is_back_tracking:
		rna_p_path_follow.progress_ratio += elongation_speed * delta
		elongation_progress.value = rna_p_path_follow.progress_ratio
	
	if rna_p_path_follow.progress_ratio >= 0.988888 and rna_p_path_follow.progress_ratio <= 1:
		is_elongated = true
		_phase_completed("ELONGATION")


#RNA BACKTRACK ( ELONGATION PHASE )
func _backtrack():
	var attempt_chance = (round(randf() * 100) / 100)
	if attempt_chance <= back_tracking_chance:
		return true


#TERMINATION
func _termination():
	if not termination_minigame_scene:
		return
	var termination_minigame_instance = termination_minigame_scene.instantiate()
	_instantiate_minigame(termination_minigame_instance)

#BASE PARING
func _base_paring():
	if parent.inc_messenger_rna_spawn_point:
		var inc_mrna = inc_mrna_object.instantiate()
		inc_mrna.global_position = parent.inc_messenger_rna_spawn_point.global_position
		parent.objects.add_child(inc_mrna)

#DELIVERY
func _delivery():
	if parent.inc_messenger_rna_spawn_point:
		var mrna = mrna_object.instantiate()
		mrna.global_position = parent.inc_messenger_rna_spawn_point.global_position
		parent.objects.add_child(mrna)

#DETECT PHASE COMPLETION
func _phase_completed(phase_name : String):
	
	match phase_name:
		"PRE_INITIATION":
			phase = PHASES.INIT
			is_pre_initation = true
		"INITIATION":
			phase = PHASES.ELONGATION
			is_initiation = true
			_promoter()
		"ELONGATION":
			phase = PHASES.TERMINATION
			is_elongation = true
		"TERMINATION":
			_elongation()
			phase = PHASES.BASE_PARING
			is_termination = true
		"BASE_PARING":
			phase = PHASES.DELIVERY
			is_transcribed = true
	
	_start_phase(phase)


#START PHASE
func _start_phase(current_phase : int):
	match current_phase:
		1:
			_initiation()
		2:
			_elongate()
			print(phase)
		3:
			_termination()
		4:
			_base_paring()
		5:
			_delivery()

#INITIALIZE DNA
func _init_dna():
	DNA_SHADOW.modulate.a = 0
	DNA_SPRITE.position = Vector2(0, -5000)
	
	
	_drop_dna()
	_shadow_dna()


#SHOW DNA
func _drop_dna():
	if not DNA_SPRITE:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(DNA_SPRITE, "position", dna_pos, 0.7).set_ease(Tween.EASE_OUT)
	await tween.finished
	SFX.play(SFX.stomp, 10, -10)
	player.camera.shake(0.2, 30)

func _shadow_dna():
	var tween = get_tree().create_tween()
	tween.tween_property(DNA_SHADOW, "modulate:a", 1, 0.7).set_ease(Tween.EASE_OUT)

func _promoter():
	if is_initiation:
		var tween = get_tree().create_tween()
		tween.tween_property(object_drop_area, "modulate:a", 0, 0.2).set_ease(Tween.EASE_OUT)
		await tween.finished
		object_drop_area.hide()
	elif not is_initiation:
		object_drop_area.show()
		var tween = get_tree().create_tween()
		tween.tween_property(object_drop_area, "modulate:a", 1, 0.2).set_ease(Tween.EASE_OUT)
		await tween.finished

func _elongation():
	if is_elongation:
		var tween = get_tree().create_tween()
		tween.tween_property(elongation_path, "modulate:a", 0, 0.2).set_ease(Tween.EASE_OUT)
		await tween.finished
		elongation_path.hide()
	elif not is_elongation:
		elongation_path.show()
		var tween = get_tree().create_tween()
		tween.tween_property(elongation_path, "modulate:a", 1, 0.2).set_ease(Tween.EASE_OUT)
		await tween.finished


func _reset_dna(delivered : bool):
	if delivered:
		clickable_interaction_area.is_interactable = true
		rna_p_path_follow.progress_ratio = 0
		elongation_progress.value = 0
		object_drop_area.placed_object = null
		object_drop_area.hovering_object = null
		
		phase = PHASES.PRE_INIT
		
		is_pre_initation = false
		is_initiation = false
		is_elongation = false
		is_elongating = false
		is_elongated = false
		back_track_duration = 1
		is_back_tracking = false
		is_termination = false
		is_transcribed  = false
