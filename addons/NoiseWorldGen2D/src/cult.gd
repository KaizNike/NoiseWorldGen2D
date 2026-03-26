@tool
extends TileMapLayer
var deltav = 0.0

func _process(delta: float) -> void:
	self.self_modulate.a = clampf(sin(PI - deltav), 0.518, 0.8)
	deltav += delta

func exude_pressure(loc:Vector2i):
	var xColor = randi_range(0,3)
	var yColor = randi_range(6,7)
	var num = randi_range(1,7)
	var look = Vector2i.ZERO
	for spot in range(num):
		set_cell(loc+look,1,Vector2i(xColor,yColor))
		look = Vector2i(randi_range(-1,1),randi_range(-1,1))
