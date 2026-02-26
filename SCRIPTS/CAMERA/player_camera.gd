extends Camera2D
class_name ScreenShake

# Shake parameters
var shake_duration : float = 0
var shake_magnitude : float = 0
var shake_offset : Vector2 = Vector2.ZERO

# Optional smoothing
@export var smoothness : float = 0.2

func _process(delta):
	if Cutscene.is_playing:
		enabled = false
	else:
		enabled = true
		make_current()
	
	if shake_duration > 0:
		shake_duration -= delta

		# Generate random offset within a circle
		var target_offset = Vector2(
			randf_range(-shake_magnitude, shake_magnitude),
			randf_range(-shake_magnitude, shake_magnitude)
		)

		# Smoothly interpolate the current shake offset
		shake_offset = shake_offset.lerp(target_offset, smoothness)

		if shake_duration <= 0:
			shake_offset = Vector2.ZERO

	# Apply shake offset to camera
	# Use the built-in "offset" property, not "position"
	offset = shake_offset

# Public function to start shake
func shake(duration: float, magnitude: float) -> void:
	shake_duration = duration
	shake_magnitude = magnitude
