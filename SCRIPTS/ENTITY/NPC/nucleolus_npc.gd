extends CharacterBody2D
class_name nucleolus_npc

@export var dialogue : DialogueResource
@export var interaction_area : ClickableInteractionArea

func _ready():
	if !dialogue:
		return
	
	if !interaction_area:
		return
	interaction_area.interact = Callable(self, "talk_to_npc")
	
func talk_to_npc():
	
	DialogueManager.show_dialogue_balloon(dialogue)
	
	#REACTIVATE INTERACTION AREA AFTER FINISHED TALKING
	DialogueManager.dialogue_ended.connect(func(res): 
		if interaction_area and !interaction_area.is_interactable:
			interaction_area.is_interactable = true
		)
	#
	if Tutorial.TutorialStep.ELEVENTH:
		remove_child(interaction_area)
	

func resume_talk():
	Tutorial.next_part()
	await get_tree().create_timer(0.2).timeout
	talk_to_npc()
	
func activateDialogueWireless():
	if !dialogue:
		return
	if !interaction_area:
		return
	
	interaction_area._interacted()
	talk_to_npc()
