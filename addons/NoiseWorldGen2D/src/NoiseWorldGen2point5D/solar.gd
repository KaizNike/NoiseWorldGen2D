extends Node3D

func _ready() -> void:
	$GotOPoint/SubViewport/NoiseWorldGen2D.startup()
	$GotOPoint3/SubViewport/NoiseWorldGen2D.startup()
