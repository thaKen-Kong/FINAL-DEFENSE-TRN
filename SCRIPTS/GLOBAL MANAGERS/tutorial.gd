extends Node2D


var Nuclues_intro : bool = false
var tutorial_finished : bool = false
var movement_tut_finished : bool = false

enum TutorialStep {
	FIRST,
	SECOND,
	THIRD,
	FOURTH,
	FIFTH,
	SIXTH,
	FINISHED
}

var step: TutorialStep = TutorialStep.FIRST

func next_part():
	if step < TutorialStep.FINISHED:
		step += 1


func trigger_nucleus_intro():
	if Nuclues_intro:
		return
	Nuclues_intro = true
	_play_nucleus_cutscene()

func _play_nucleus_cutscene():
	Cutscene.play_sequence([
		{
			"node": get_tree().get_first_node_in_group("Map"),
			"hold": 3.0,
			"zoom": Vector2(0.3, 0.3)
		}
	])


func _zoom_to_DNAMT():
	Cutscene.play_sequence([
		{
			"node": get_tree().get_first_node_in_group("player"),
			"hold": 0.5,
			"zoom": Vector2(1, 1)
		},
		{
			"node": get_tree().get_first_node_in_group("dnamt"),
			"hold": 1.0,
			"zoom": Vector2(0.7, 0.7)
		},
		{
			"node": get_tree().get_first_node_in_group("player"),
			"hold": 0.5,
			"zoom": Vector2(1, 1)
		}
	])


func _zoom_dna():
	Cutscene.play_sequence([
		{
			"node": get_tree().get_first_node_in_group("player"),
			"hold": 0.5,
			"zoom": Vector2(1, 1)
		},
		{
			"node": get_tree().get_first_node_in_group("dna"),
			"hold": 1.0,
			"zoom": Vector2(0.7, 0.7)
		},
		{
			"node": get_tree().get_first_node_in_group("player"),
			"hold": 0.5,
			"zoom": Vector2(1, 1)
		}
	])


func _zoom_exit_site():
	Cutscene.play_sequence([
		{
			"node": get_tree().get_first_node_in_group("player"),
			"hold": 0.5,
			"zoom": Vector2(1, 1)
		},
		{
			"node": get_tree().get_first_node_in_group("exitsite"),
			"hold": 1.0,
			"zoom": Vector2(0.7, 0.7)
		},
		{
			"node": get_tree().get_first_node_in_group("player"),
			"hold": 0.5,
			"zoom": Vector2(1, 1)
		}
	])
