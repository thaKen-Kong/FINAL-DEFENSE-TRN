extends Node

var whoosh = preload("res://ASSETS/sfx/fast-woosh-230497.mp3")
var stomp = preload("res://ASSETS/sfx/stomp2-93279.mp3")
var thud = preload("res://ASSETS/sfx/thud-291047.mp3")
var show = preload("res://ASSETS/sfx/click-buttons-ui-menu-sounds-effects-button-12-205395 (1).mp3")

var click_2 = preload("res://ASSETS/sfx/clickselect-92098.mp3")
var select_click = preload("res://ASSETS/sfx/click-for-game-menu-131903.mp3")
var click = preload("res://ASSETS/sfx/button-click-289742 (1).mp3")

var player : AudioStreamPlayer

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)

func play(sound: AudioStream, volume : float = 0.0, pitch : float = 0.0):
	player.pitch_scale = pitch
	player.volume_db = volume
	player.stream = sound
	player.play()

func play_multiple(sounds : Array, volume : float = 0.0):
	for sound in sounds:
		player.volume_db = volume
		player.stream = sound
		player.play()
