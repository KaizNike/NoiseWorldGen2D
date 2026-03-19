extends CharacterBody3D


@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
#@onready var _skin: SophiaSkin = %SophiaSkin


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity


func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO

	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity + _gravity * delta

	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_impulse

	move_and_slide()

	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	#_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	#if is_starting_jump:
		##_skin.jump()
		#pass
	#elif not is_on_floor() and velocity.y < 0:
		##_skin.fall()
		#pass
	#elif is_on_floor():
		#var ground_speed := velocity.length()
		#if ground_speed > 0.0:
			#_skin.move()
		#else:
			#_skin.idle()

#extends CharacterBody3D
#@export var move_speed := 8.0
#@export var acceleration := 20.0
#@export var jump_impulse := 12.0
#@export var mouse_sensitivity := 0.25
#var gravity := -30.0
#var camera_input := Vector2.ZERO
#@onready var cam_pivot: Node3D = $CameraPivot
#@onready var cam: Camera3D = $CameraPivot/Camera3D
#func _unhandled_input(event):
	#if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#camera_input = event.relative * mouse_sensitivity
#func _physics_process(delta):
	   ## Camera rotation
	#cam_pivot.rotation.x = clamp(cam_pivot.rotation.x + camera_input.y * delta, -PI/8, PI/3)
	#cam_pivot.rotation.y -= camera_input.x * delta
	#camera_input = Vector2.ZERO
	## Movement
	#var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#var forward = -cam.global_transform.basis.z
	#var right = cam.global_transform.basis.x
	#var direction = (forward * input_dir.y + right * input_dir.x).normalized()
	#var y_vel = velocity.y
	#velocity.y = 0.0
	#velocity = velocity.move_toward(direction * move_speed, acceleration * delta)
	#velocity.y = y_vel + gravity * delta
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = jump_impulse
		#move_and_slide()
##extends CharacterBody3D
##
##func get_dir_mouse_pffer_check():
	##var check = Input.get_last_mouse_velocity()
	##return check
	##
##func get_keyboard_move():
	##var xy = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	##return Vector3(xy.x,0,xy.y)
	##
##func _physics_process(delta: float) -> void:
	##if get_dir_mouse_pffer_check():
		##var check = get_dir_mouse_pffer_check()
		##look_at(Vector3(0,check.x,check.y),up_direction)
	##velocity += get_keyboard_move() * 50
	##move_and_slide()
