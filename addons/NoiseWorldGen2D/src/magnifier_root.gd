extends Control

@export var planet: Node3D
@export var camera: Camera3D
@onready var lens: ColorRect

func _process(_delta):
	if not planet or not camera: return

	# 1. Check if planet is in front of the camera
	if camera.is_position_behind(planet.global_position):
		hide()
		return
	show()

	# 2. Get screen position (Pixels)
	var screen_pos = camera.unproject_position(planet.global_position)
	
	# 3. Position the UI element over the planet
	global_position = screen_pos - (size / 2.0)

	# 4. Pass normalized coordinates (0.0 to 1.0) to the shader
	var viewport_size = get_viewport().get_visible_rect().size
	var normalized_pos = screen_pos / viewport_size
	
	lens.material.set_shader_parameter("planet_screen_pos", normalized_pos)
