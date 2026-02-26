extends NinePatchRect
class_name PowerMeter

signal clicked_success
signal clicled_failed

@onready var color_rect = $ColorRect
@onready var color_rect_2 = $ColorRect2

var speed : int = 500

var direction = 1

var can_click = false

var needle_percentage : int
var bar_percentage
var stopped : bool = false

func _ready():
	_get_bar_percent()
	_randomize_speed()
	_place_bar_random()

func _get_bar_percent():
	var bar_start = (color_rect.position.x / size.x) * 100
	var bar_end = ((color_rect.position.x + color_rect.size.x) / size.x) * 100
	bar_percentage = range(bar_start, bar_end)


func _process(delta):
	if stopped:
		modulate.a = 0.5
		return
		
	color_rect_2.position.x += speed * direction * delta
	if color_rect_2.position.x >= size.x - color_rect_2.size.x:
		direction = -1

	elif color_rect_2.position.x < 0:
		direction = 1
	
	needle_percentage = (color_rect_2.position.x / size.x) * 100
	
	if needle_percentage in bar_percentage:
		can_click = true
	else:
		can_click = false
	
func _input(event):
	if event.is_action_pressed('click') and not stopped:
		if can_click:
			_place_bar_random()
			_set_bar_size()
			_randomize_speed()
			
			clicked_success.emit()
			
		else:
			clicled_failed.emit()
			
func _place_bar_random():
	color_rect.position.x = randf_range(position.x, (size.x - color_rect.size.x))
	_get_bar_percent()

func _set_bar_size():
	var new_size = color_rect.size.x - randf_range(10, color_rect.size.x * 0.5)
	color_rect.size.x = max(new_size, 70)

func _randomize_speed():
	speed = randf_range(400, 800)
