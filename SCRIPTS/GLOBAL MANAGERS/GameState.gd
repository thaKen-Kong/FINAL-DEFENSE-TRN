extends Node

#LEVELS
@export var level_data : LevelDataInfo

#PLAYER
var player_movement_speed : float = 500.0
var atp_energy : float = 100
var atp_points : int = 100

var atp_energy_reduction : int = 1
var atp_points_reduction : float = -20

var guanix : int = 0

# GAME STATUS
var is_paused : bool = false


# LEVEL DATA  
var data : Dictionary
var next_level : Dictionary

func unlockLevel():
	for levels in range(len(level_data.levels)):
		if data == level_data.levels[levels]:
			if (levels + 1) > level_data.levels.size():
				return
			level_data.levels[levels + 1]["unlocked"] = true


func _deduct_atp(atp_amount):
	atp_energy -= atp_amount
