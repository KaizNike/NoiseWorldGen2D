tool
extends TileMap

var version = "2.1"
# Eevee meme

# setting size greater than 1200 has long processing times
export(int, 7, 1200) var world_size = 50 setget size_change
export var world_type = "overworld" setget type_change
export(Image) var height_image setget height_image_change
export(int) var height_seed = 0 setget height_seed_change
export(int) var forest_seed = 0 setget forest_seed_change
export(int) var land_seed = 0 setget land_seed_change
export(int) var variation_seed = 0 setget variation_seed_change
export(float) var Heat_Change = 0 setget changing_heat
export(float) var Height_Change = 0 setget changing_height
export(bool) var is_rounded = true setget is_rounded_change
export(bool) var lock_world = false
export(bool) var regen_button = false setget regen_button_pressed
#export(bool) var test = false setget testing

var heat_variation = 0.045
var height_variation = 0.015
var tiles_count  = 0

var heatSelect = "polar"
var heat = 0
var heatChange = 0
var heightChange = 0

var rng = RandomNumberGenerator.new()

onready var noise_height = OpenSimplexNoise.new()
onready var forest_noise = OpenSimplexNoise.new()
onready var land_noise = OpenSimplexNoise.new()
onready var variation_noise = OpenSimplexNoise.new()
onready var river_noise = OpenSimplexNoise.new()

const TILES = {
	"dirt" : Vector2(0,0),
	"grass" : Vector2(1,0),
	"mountain" : Vector2(2,0),
	"hill" : Vector2(3,0),
	"shallowwater" : Vector2(0,1),
	"medwater" : Vector2(1,1),
	"deepwater" : Vector2(2,1),
	"abyssalwater" : Vector2(3,1),
	"swamp" : Vector2(0,2),
	"brushland" : Vector2(1,2),
	"forest" : Vector2(2,2),
	"deepforest" : Vector2(3,2),
	"snow" : Vector2(0,3),
	"ice" : Vector2(1,3),
	"tundra" : Vector2(2,3),
	"tundraforest" : Vector2(3,3),
	"desert" : Vector2(0,4),
	"desertforest" : Vector2(1,4),
	"dryhills" : Vector2(2,4),
	"tundradeepforest" : Vector2(3,4),
	"lushgrass" : Vector2(0,5),
	"lushbrushland" : Vector2(1,5),
	"jungle" : Vector2(2,5),
	"deepjungle" : Vector2(3,5)
}

onready var tiles = self.tile_set
onready var rect = tiles.tile_get_region(0)

func _ready():
#	print(get_used_cells())
	if !get_used_cells() and Engine.editor_hint:
		startup()
		

func testing(test):
	print("ready.")
	if height_image:
		print("set.")
		print(height_image.get_pixel(1,1).r * 2 - 1)
	else:
		print("no image.")

func size_change(new_size):
	world_size = new_size
	pre_startup_init()


func type_change(new_type):
	world_type = new_type
	pre_startup_init()


func height_image_change(new_image):
	height_image = new_image
	pre_startup_init()

func height_seed_change(new_seed):
	height_seed = new_seed
	pre_startup_init()

	
func forest_seed_change(new_seed):
	forest_seed = new_seed
	pre_startup_init()
	
	
func land_seed_change(new_seed):
	land_seed = new_seed
	pre_startup_init()
	
	
func variation_seed_change(new_seed):
	variation_seed = new_seed
	pre_startup_init()
	
	
func changing_heat(new_heat):
	Heat_Change = new_heat
	pre_startup_init()
	

func changing_height(new_height):
	Height_Change = new_height
	pre_startup_init()


func is_rounded_change(new_bool):
	is_rounded = new_bool
	pre_startup_init()


func regen_button_pressed(new_bool):
	pre_startup_init()

func pre_startup_init():
	noise_height = OpenSimplexNoise.new()
	forest_noise = OpenSimplexNoise.new()
	land_noise = OpenSimplexNoise.new()
	variation_noise = OpenSimplexNoise.new()
	startup()


func startup():
	_noise_height_init()
	_forest_noise_init()
	_land_noise_init()
	_variation_noise_init()
	genWorld(world_size,world_type,Heat_Change,Height_Change)


func _noise_height_init():
	noise_height.seed = height_seed
	noise_height.octaves = 5
	noise_height.period = 80.0
	noise_height.persistence = 0.3
	noise_height.lacunarity = 0.2


func _forest_noise_init():
	forest_noise.seed = forest_seed
	forest_noise.octaves = 9
	forest_noise.period = 19.0
	forest_noise.persistence = 0.2
	forest_noise.lacunarity = 2


func _land_noise_init():
	land_noise.seed = land_seed
	land_noise.octaves = 9
	land_noise.period = 19.0
	land_noise.persistence = 0.2
	land_noise.lacunarity = 2
	
	
func _variation_noise_init():
	variation_noise.seed = variation_seed
	variation_noise.octaves = 9
	variation_noise.period = 3
	variation_noise.persistence = 0.2
	variation_noise.lacunarity = 2


func genWorld(size, type, temp, height):
	var Height = size
	var Width = size
	if lock_world:
		return
	else:
		clear()
	heatChange = temp / 100
	var waterLoss = heatChange / 10
	if waterLoss < 0:
		waterLoss = 0
	heightChange = height / 100
#	print(heatChange)
#	check type of world, if you have different tilesets for different worlds, include other consts for reference
	if height_image:
		height_image.lock()
		Height = height_image.get_size().y
		if Height > 1200:
			print("Image too large.")
			return
		Width = height_image.get_size().x
		if Width > 1200:
			print("Image too large.")
			return
		if Height > Width:
			size = Width
		else:
			size = Height
	if type == "overworld":
		print("Generate overworld now!")
#		if heatSelect == "polar":
##			polarHeatMap.rect_size = Vector2(size, size)
##			polarHeatMap.rect_position.x = size
#			polarHeatMap.Gradient.width = size
##			print(polarHeatMap.rect_size)
#			heatImage = polarHeatMap.get_texture().get_data()
#			print(heatImage.get_size())
#			heatImage.lock()
#			print(heatImage.get_pixel(200, 0))
		for y in range(Height):
			if heatSelect == "polar":
#				heat += 1
				if y < (Height / 2):
					heat += 1.0 / float(Height) * 2.0
				elif y > (Height / 2):
					heat -= 1.0 / float(Height) * 2.0
				if y % 10 == 0:
#					print(float(heat))
					pass
			for x in range(Width):
				var heat_cell = heat + heatChange + (0.05* variation_noise.get_noise_2d(float(x), float(y))) # + rand_range(-heat_variation, heat_variation) 
				if not on_circle(x, y, size):
					continue
				tiles_count += 1
				var cell := 0.0
				if not height_image:
					cell = noise_height.get_noise_2d(float(x), float(y)) + heightChange + (0.05 * variation_noise.get_noise_2d(float(x), float(y))) #  + rand_range(-height_variation, height_variation)
				else:
					cell = (height_image.get_pixel(x, y).r * 2 - 1) + heightChange
				if cell + waterLoss < -0.1:
					if heat_cell < 0.15:
						set_cell(x,y,0,false,false,false,TILES.ice)
#						array[y][x] = TILES.ice
					else:
						if cell + waterLoss < -0.55:
							set_cell(x,y,0,false,false,false,TILES.abyssalwater)
#							array[y][x] = TILES.abyssalwater
						elif cell + waterLoss < -0.4:
							set_cell(x,y,0,false,false,false,TILES.deepwater)
#							array[y][x] = TILES.deepwater
						elif cell + waterLoss < -0.25:
							set_cell(x,y,0,false,false,false,TILES.medwater)
#							array[y][x] = TILES.medwater
						else:
							set_cell(x,y,0,false,false,false,TILES.shallowwater)
#							array[y][x] = TILES.shallowwater
				elif cell > 0.5:
					set_cell(x,y,0,false,false,false,TILES.mountain)
#					array[y][x] = TILES.mountain
				elif cell > 0.4:
					if heat_cell < 0.3 or heat_cell > 0.85:
						set_cell(x,y,0,false,false,false,TILES.dryhills)
#						array[y][x] = TILES.dryhills
					else:
						set_cell(x,y,0,false,false,false,TILES.hill)
#						array[y][x] = TILES.hill
				else:
					var cell_forest = forest_noise.get_noise_2d(float(x), float(y))
					if cell_forest > 0.3 and heat_cell > 0.15:
						if heat_cell > 0.15 and heat_cell < 0.3:
							if cell_forest > 0.5:
								set_cell(x,y,0,false,false,false,TILES.tundradeepforest)
#								array[y][x] = TILES.tundradeepforest
							elif cell_forest > 0.3:
								set_cell(x,y,0,false,false,false,TILES.tundraforest)
#								array[y][x] = TILES.tundraforest
						elif heat_cell > 0.6 and heat_cell < 0.85:
							if cell_forest > 0.5:
								set_cell(x,y,0,false,false,false,TILES.deepjungle)
#								array[y][x] = TILES.deepjungle
							elif cell_forest > 0.4:
								set_cell(x,y,0,false,false,false,TILES.jungle)
#								array[y][x] = TILES.jungle
							elif cell_forest > 0.3:
								set_cell(x,y,0,false,false,false,TILES.lushbrushland)
#								array[y][x] = TILES.lushbrushland
						elif heat_cell > 0.85:
							set_cell(x,y,0,false,false,false,TILES.desertforest)
#							if cell_forest > 0.3:
#							array[y][x] = TILES.desertforest
						else:
							if cell_forest > 0.5:
								set_cell(x,y,0,false,false,false,TILES.deepforest)
#								array[y][x] = TILES.deepforest
							elif cell_forest > 0.4:
								set_cell(x,y,0,false,false,false,TILES.forest)
#								array[y][x] = TILES.forest
							elif cell_forest > 0.3:
								set_cell(x,y,0,false,false,false,TILES.brushland)
#								array[y][x] = TILES.brushland
					else:
						var cell_land = land_noise.get_noise_2d(float(x), float(y))
						if heat_cell < 0.15:
							set_cell(x,y,0,false,false,false,TILES.snow)
#							array[y][x] = TILES.snow
						elif heat_cell > 0.85:
							set_cell(x,y,0,false,false,false,TILES.desert)
#							array[y][x] = TILES.desert
						else:
							if cell_land < -0.25:
								set_cell(x,y,0,false,false,false,TILES.swamp)
#								array[y][x] = TILES.swamp
							elif cell_land < -0.1:
								set_cell(x,y,0,false,false,false,TILES.dirt)
#								array[y][x] = TILES.dirt
							else:
								if heat_cell > 0.6 and heat_cell < 0.85:
									set_cell(x,y,0,false,false,false,TILES.lushgrass)
#									array[y][x] = TILES.lushgrass
								elif heat_cell > 0.15 and heat_cell < 0.3:
									set_cell(x,y,0,false,false,false,TILES.tundra)
#									array[y][x] = TILES.tundra
								else:
									set_cell(x,y,0,false,false,false,TILES.grass)
#									array[y][x] = TILES.grass
	# Define your own hellish landscape, bypasses typical generation
	elif type == "hellplanet":
		pass
		
	heat = 0
		
func on_circle(xpos, ypos, Size):
	if not is_rounded:
		return true
	if Size / 2 > sqrt(abs(xpos - Size / 2) * abs(xpos - Size / 2) + abs(ypos - Size / 2) * abs(ypos - Size / 2)):
		return true
	else:
		return false
