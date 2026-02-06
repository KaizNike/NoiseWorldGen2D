extends MeshInstance3D

func _ready() -> void:
	self.mesh.material.albedo_texture = $SubViewport.get_texture()
