@tool
extends RigidBody3D

@onready var clouds = $World/Clouds
@onready var World = $World

@export var planet_radius: float = 50.0:
	set(value):
		planet_radius = value
		if Engine.is_editor_hint():
			_generate_planet()

@export var resolution: int = 64:
	set(value):
		resolution = max(8, value) # Prevent too low resolution
		if Engine.is_editor_hint():
			_generate_planet()

@export var noise_scale: float = 8.0:
	set(value):
		noise_scale = value
		if Engine.is_editor_hint():
			_generate_planet()

@export var cave_threshold: float = 0.2:
	set(value):
		cave_threshold = value
		if Engine.is_editor_hint():
			_generate_planet()

@export var gravity_strength: float = 9.8

#var planet_mesh_instance: MeshInstance3D
var noise_3d := FastNoiseLite.new()

func _ready():
	if Engine.is_editor_hint():
		_generate_planet()
	if not World.mesh:
		_generate_planet()

func _generate_planet():
	# Remove old mesh if it exists
	if World.mesh:
		World.mesh = null
		#remove_child(planet_mesh_instance)
		#planet_mesh_instance.queue_free()
		#remove_child(clouds)
		#clouds.queue_free()

	# Configure noise
	noise_3d.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise_3d.seed = 12345  # Fixed seed for consistent editor preview
	noise_3d.frequency = 0.05

	# Create mesh instance
	#planet_mesh_instance = MeshInstance3D.new()
	World.mesh = _create_planet_mesh()
	
	# 🌍 Create and assign a material
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	#mat.albedo_color = Color(0.2, 0.7, 0.3)  # Greenish terrain
	mat.roughness = 1.0                      # Matte look
	mat.metallic = 0.0                       # No metallic shine
	#mat.vertex_color_use_as_albedo = false   # Ignore vertex colors
	World.set_surface_override_material(0, mat)
	
	#add_child(planet_mesh_instance)
	#World = planet_mesh_instance
	setup_clouds(planet_radius)

func _create_planet_mesh() -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for lat in range(resolution):
		var theta1 = float(lat) / resolution * PI
		var theta2 = float(lat + 1) / resolution * PI

		for lon in range(resolution):
			var phi1 = float(lon) / resolution * TAU
			var phi2 = float(lon + 1) / resolution * TAU

			var p1 = _spherical_point(theta1, phi1)
			var p2 = _spherical_point(theta2, phi1)
			var p3 = _spherical_point(theta2, phi2)
			var p4 = _spherical_point(theta1, phi2)

			_add_vertex_with_noise(st, p1)
			_add_vertex_with_noise(st, p2)
			_add_vertex_with_noise(st, p3)

			_add_vertex_with_noise(st, p1)
			_add_vertex_with_noise(st, p3)
			_add_vertex_with_noise(st, p4)

	st.generate_normals()
	print("world done!")
	
	return st.commit()
	
# Inside your Planet script or a dedicated Cloud script
func setup_clouds(planet_radius: float):
	if clouds:
		return
	##var cloud_mesh_instance = MeshInstance3D.new()
	##clouds = cloud_mesh_instance
	##add_child(cloud_mesh_instance)
	#
	## Create the sphere slightly larger than the planet
	#var sphere = SphereMesh.new()
	#sphere.radius = planet_radius + 0.5 # The "hover" height
	#sphere.height = (planet_radius + 0.5) * 2
	#clouds.mesh = sphere
	#if clouds.material_override:
		#return
	## Apply the shader material (defined below)
	#var mat = ShaderMaterial.new()
	#mat.shader = preload("res://addons/NoiseWorldGen2D/src/NoiseWorldGen3D/clouds.gdshader")
	#var noise = FastNoiseLite.new()
	#var noiseImg = noise.get_seamless_image(64,64)
	##mat.shader.noise_tex = noiseImg
	#clouds.material_override = mat
	#var override = clouds.material_override
	#override.set_shader_parameter("noise_tex",noiseImg)
	
	

func _spherical_point(theta: float, phi: float) -> Vector3:
	return Vector3(
		sin(theta) * cos(phi),
		cos(theta),
		sin(theta) * sin(phi)
	) * planet_radius

func _add_vertex_with_noise(st: SurfaceTool, pos: Vector3):
	var noise_val = noise_3d.get_noise_3d(pos.x / noise_scale, pos.y / noise_scale, pos.z / noise_scale)
	if noise_val < cave_threshold:
		pos *= 0.97
		
	# Visual color based on deformation
	var color_val = 0.5 + (noise_val * 0.5)
	st.set_color(Color(color_val, color_val * 0.5, 0.2))
	st.add_vertex(pos)

# Positional gravity for runtime
func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	for body in get_tree().get_nodes_in_group("gravity_objects"):
		if body is RigidBody3D:
			var dir = (global_transform.origin - body.global_transform.origin).normalized()
			body.apply_central_force(dir * gravity_strength * body.mass)
		if body is CharacterBody3D:
			body.up_direction = (global_transform.origin - body.global_transform.origin).normalized()
