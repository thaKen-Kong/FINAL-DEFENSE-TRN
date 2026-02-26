extends Node2D
class_name world

@export var npc_nucleolus : nucleolus_npc

func _ready():
	GameState.is_paused = false
	if GameState.is_paused:
		get_tree().paused = true
	
	start_npc()

func start_npc():
	if !npc_nucleolus:
		return
	
	if !Tutorial.tutorial_finished:
		npc_nucleolus.activateDialogueWireless()

func resume_npc():
	if !npc_nucleolus:
		return
	
	if Tutorial.movement_tut_finished:
		npc_nucleolus.resume_talk()
