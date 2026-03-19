extends Node

func _ready() -> void:
	$CanvasLayer/MagnifierRoot.planet = $Solar/GotOPoint
	$CanvasLayer/MagnifierRoot.camera = $Camera3D
	$CanvasLayer/MagnifierRoot.lens = $CanvasLayer/MagnifierRoot/Lens
