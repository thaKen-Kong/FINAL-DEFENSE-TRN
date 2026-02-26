extends CharacterBody2D
class_name Player

@export var parent_world_node : Node2D 

@export var player_sprite : AnimatedSprite2D

var last_direction_facing : Vector2

# NODES

@onready var camera : Camera2D = $Camera2D
@onready var ui_handler = $"UI HANDLER"
@onready var player_ui = $"UI HANDLER/player_ui"
@onready var hand = $Hand
@onready var finite_state_machine = $FiniteStateMachine

var left = []
var right = []
var up = []
var down = []

# EXPORTED NODES
@export var state_manager : Node

var object_held : obj

func _ready():
	pass

# PHYSICS PROCESS
func _physics_process(delta):
	
	if !Tutorial.movement_tut_finished and parent_world_node:
		if Input.is_action_pressed("w"):
			up.append("W")
		elif Input.is_action_pressed("a"):
			left.append("A")
		elif Input.is_action_pressed("s"):
			down.append("S")
		elif Input.is_action_pressed("d"):
			right.append("D")
		
		if up.size() >= 20 and down.size() >= 20 and left.size() >= 20 and right.size() >= 20:
			Tutorial.movement_tut_finished = true
			parent_world_node.resume_npc()
	
	move_and_slide()
