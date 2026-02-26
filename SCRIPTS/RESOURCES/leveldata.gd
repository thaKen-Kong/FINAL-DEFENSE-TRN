extends Resource
class_name LevelDataInfo

@export var chapter_id: int = 1
@export var levels: Array[Dictionary] = []
@export var max_levels : int 

func _init(_chapter_id := 1):
	chapter_id = _chapter_id
	levels = []

	for i in range(20):
		levels.append({
			"reward": 10 + (i * 5),
			"timer": 500 - (i * 50),
			"deliveries": (i / 3) + 1,
			"unlocked": i == 0
		})
