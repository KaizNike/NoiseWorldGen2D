extends CSGSphere3D

func _ready() -> void:
	self.material.albedo_texture = $SubViewport.get_texture()
