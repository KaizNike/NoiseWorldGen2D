#@tool
## BY KaizarNike (2026)
extends TileMapLayer

var version = "4.0"
# Godot 4.5.1, Actors and Locations

@export var world_size: Vector2 = Vector2(50,50): set = size_change ## X, Y dimensions of world ( setting size greater than 1200 has long processing times )
@export var time: int = 0 ## Unimplemented, but will change world over time
@export var world_type = "overworld": set = type_change ## The type and tileset used to generate, overworld is earthlike
@export var heatSelect = "polar": set = heat_change ## Heat spectrum to use, polar the default does like earth with no consideration of rotated poles
@export var height_image: Image: set = height_image_change ## grayscale height image to override height generation
@export var world_seed: int = 0: set = world_seed_change ## gives a specific world, randomizes each seed the same way
@export var height_seed: int = 0: set = height_seed_change ## the seed for the landform generation
@export var forest_seed: int = 0: set = forest_seed_change ## seed determines forest growth
@export var land_seed: int = 0: set = land_seed_change ## determines land wetness by seed
@export var variation_seed: int = 0: set = variation_seed_change ## gives variance to everything
@export var Heat_Change: float = 0: set = changing_heat ## alters world heat
@export var Height_Change: float = 0: set = changing_height ## offsets world height
@export var is_rounded: bool = true: set = is_rounded_change ## if true (default), the world is rounded, otherwise square. exclusive with is ovalled
@export var is_ovalled: bool = false: set = is_ovalled_change ## can be handy for making something like other earth projections, if size x, y is same will be similar to is rounded but off by a tile or two, exclusive with is rounded
@export var lock_world: bool = false ## prevents variable changes in editor from making updates live
@export var regen_button: bool = false: set = regen_button_pressed ## force regeneration
#export(bool) var test = false setget testing

var continents = []
var drift_dirs = []
var drift = Vector2.ZERO

var heat_variation = 0.45
var height_variation = 0.015
var tiles_count  = 0


var heat = 0
var heatChange = 0
var heightChange = 0

var rng = RandomNumberGenerator.new()

@export var noise_height = FastNoiseLite.new()
@export var forest_noise = FastNoiseLite.new()
@export var land_noise = FastNoiseLite.new()
@export var variation_noise = FastNoiseLite.new()
@export var river_noise = FastNoiseLite.new()

@onready var Locations = $Locations
@onready var Actors = $Actors

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
#var OCEANTILES = [4, 5, 6, 7]
#var RIVERSTARTTILES = [2, 3]
#var CHILLTILES = [2, 12, 13, 14, 15]
#var CENTRALTILES = [16, 17]
const OCEANTILES = [TILES.abyssalwater,TILES.deepwater,TILES.medwater,TILES.shallowwater]
#var RIVERSTARTTILES = [2, 3]
var CHILLTILES = [TILES.mountain,TILES.snow, TILES.ice, TILES.tundra, TILES.tundraforest,TILES.tundradeepforest]
var CENTRALTILES = [TILES.desert,TILES.desertforest]
#var MIDTILES = [0, 1, 3, 9, 10, 20, 21, 22]
var MIDTILES = [TILES.grass,
	TILES.dirt,TILES.brushland,
	TILES.forest,TILES.lushgrass,
	TILES.lushgrass, TILES.lushbrushland,
	TILES.jungle,TILES.deepjungle]

var LOCATIONS = {
	"cave" : Vector2(0,0),
	"camp" : Vector2(0,1),
	"settlement" : Vector2(1,1),
	"town" : Vector2(2,1),
	"temple" : Vector2(3,1)
}

var HUMANS = {
	"ffarlander" : Vector2(0,0),
	"nmidlander" : Vector2(0,1),
	"mmidlanderknight" : Vector2(1,1),
	"mcentral" : Vector2(2,0),
	"fcentralknight" : Vector2(2,1)
}

var MONSTERS = {
	"blobkin" : Vector2(0,0),
	"forestslime" : Vector2(1,0),
	"goblinwarrior" : Vector2(0,1),
	"goblinmage" : Vector2(1,1),
	"zombiehuman" : Vector2(2,1),
	"zombiegoblin" : Vector2(3,1)
}

var ANIMALS = {
	"smallfish" : Vector2(2,0),
	"largefish" : Vector2(3,0),
	"fox" : Vector2(0,2),
	"snowrabbit" : Vector2(1,2),
	"bear" :  Vector2(2,2),
	"bee" : Vector2(3,2)
}

@onready var tiles = self.tile_set
#@onready var rect = tiles.tile_get_region(0)

func _ready():
	if get_used_cells() and not Engine.is_editor_hint():
		return
	if get_used_cells() and Engine.is_editor_hint():
		return
	if not get_used_cells():
		clear()
	randomize()
#	print(get_used_cells())
	if !get_used_cells() and Engine.is_editor_hint():
		startup()
	#elif not Engine.is_editor_hint():
		#$CreateTime.start()
		#pre_startup_init()

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


func heat_change(new_value):
	heatSelect = new_value
	pre_startup_init()

func height_image_change(new_image):
	height_image = new_image
	pre_startup_init()
	
	
func world_seed_change(new_seed):
	world_seed = new_seed
	var rand := RandomNumberGenerator.new()
	rand.seed = new_seed
	height_seed = rand.randi()
	forest_seed = rand.randi()
	land_seed = rand.randi()
	variation_seed = rand.randi()
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

# Would be cool to have a shape dropdown select with rounded, ovalled, ringworld and sky islands
func is_rounded_change(new_bool):
	if is_ovalled:
		is_ovalled = false
		notify_property_list_changed()
	is_rounded = new_bool
	pre_startup_init()


func is_ovalled_change(new_bool):
	if is_rounded:
		is_rounded = false
		notify_property_list_changed()
	is_ovalled = new_bool
	pre_startup_init()

func regen_button_pressed(new_bool):
	pre_startup_init()

func pre_startup_init():
	noise_height = FastNoiseLite.new()
	forest_noise = FastNoiseLite.new()
	land_noise = FastNoiseLite.new()
	variation_noise = FastNoiseLite.new()
	startup()


func startup():
	_noise_height_init()
	_forest_noise_init()
	_land_noise_init()
	_variation_noise_init()
	if not Locations or not Actors:
		if not $CreateTime:
			return
		$CreateTime.start()
		return
	if not get_tree():
		if not $CreateTime:
			return
		$CreateTime.start()
		return
	await get_tree().process_frame
	print("Genning a world!")
	genWorld(world_size,world_type,Heat_Change,Height_Change)
	print("Now for locations!")
	await get_tree().process_frame
	#Locations.genself(world_type,world_size)
	
	#Actors.genself(world_size)
	

func actorsNOW():
	Actors.genself(world_size)

func _noise_height_init():
	noise_height.seed = height_seed
	noise_height.fractal_octaves = 9
	#noise_height.period = 80.0
	#noise_height.persistence = 0.5
	#noise_height.lacunarity = 2


func _forest_noise_init():
	forest_noise.seed = forest_seed
	forest_noise.fractal_octaves = 9
	#forest_noise.period = 19.0
	#forest_noise.persistence = 0.2
	#forest_noise.lacunarity = 2


func _land_noise_init():
	land_noise.seed = land_seed
	land_noise.fractal_octaves = 9
	#land_noise.period = 19.0
	#land_noise.persistence = 0.2
	#land_noise.lacunarity = 2
	
	
func _variation_noise_init():
	variation_noise.seed = variation_seed
	variation_noise.fractal_octaves = 9
	#variation_noise.period = 3
	#variation_noise.persistence = 0.2
	#variation_noise.lacunarity = 2


func genWorld(size:Vector2, type, temp, height):
	var Height = size.y
	var Width = size.x
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
	if height_image:
		#false # height_image.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
		Height = height_image.get_size().y
		if Height > 1200:
			print("Image too large.")
			return
		Width = height_image.get_size().x
		if Width > 1200:
			print("Image too large.")
			return
		if Height > Width:
			size.x = Width
		else:
			size.y = Height
#	find_continents(Width,Height,height)
#	check type of world, if you have different tilesets for different worlds, include other consts for reference
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
					print(float(heat))
					await get_tree().process_frame
					pass
			for x in range(Width):
				var heat_cell = heat + heatChange + (0.35* variation_noise.get_noise_2d(float(x), float(y))) # + randf_range(-heat_variation, heat_variation) 
				if is_rounded and not on_circle(x, y, size):
					continue
				if is_ovalled and not is_point_in_rotated_oval(Vector2(x,y),Vector2(Width/2,Height/2),Vector2(Width/2,Height/2),40.0):
					continue
				tiles_count += 1
				var cell := 0.0
				if not height_image:
					cell = noise_height.get_noise_2d(float(x), float(y)) + heightChange + (0.05 * variation_noise.get_noise_2d(float(x), float(y))) #  + randf_range(-height_variation, height_variation)
				else:
					cell = (height_image.get_pixel(x, y).r * 2 - 1) + heightChange
				if cell + waterLoss < -0.1:
					if heat_cell < 0.15:
						set_cell(Vector2i(x,y),0,TILES.ice)
#						array[y][x] = TILES.ice
					else:
						if cell + waterLoss < -0.55:
							set_cell(Vector2i(x,y),0,TILES.abyssalwater)
#							array[y][x] = TILES.abyssalwater
						elif cell + waterLoss < -0.4:
							set_cell(Vector2i(x,y),0,TILES.deepwater)
#							array[y][x] = TILES.deepwater
						elif cell + waterLoss < -0.25:
							set_cell(Vector2i(x,y),0,TILES.medwater)
#							array[y][x] = TILES.medwater
						else:
							set_cell(Vector2i(x,y),0,TILES.shallowwater)
#							array[y][x] = TILES.shallowwater
				elif cell > 0.5:
					set_cell(Vector2i(x,y),0,TILES.mountain)
#					array[y][x] = TILES.mountain
				elif cell > 0.4:
					if heat_cell < 0.3 or heat_cell > 0.85:
						set_cell(Vector2i(x,y),0,TILES.dryhills)
#						array[y][x] = TILES.dryhills
					else:
						set_cell(Vector2i(x,y),0,TILES.hill)
#						array[y][x] = TILES.hill
				else:
					var cell_forest = forest_noise.get_noise_2d(float(x), float(y))
					if cell_forest > 0.3 and heat_cell > 0.15:
						if heat_cell > 0.15 and heat_cell < 0.3:
							if cell_forest > 0.5:
								set_cell(Vector2i(x,y),0,TILES.tundradeepforest)
#								array[y][x] = TILES.tundradeepforest
							elif cell_forest > 0.3:
								set_cell(Vector2i(x,y),0,TILES.tundraforest)
#								array[y][x] = TILES.tundraforest
						elif heat_cell > 0.6 and heat_cell < 0.85:
							if cell_forest > 0.5:
								set_cell(Vector2i(x,y),0,TILES.deepjungle)
#								array[y][x] = TILES.deepjungle
							elif cell_forest > 0.4:
								set_cell(Vector2i(x,y),0,TILES.jungle)
#								array[y][x] = TILES.jungle
							elif cell_forest > 0.3:
								set_cell(Vector2i(x,y),0,TILES.lushbrushland)
#								array[y][x] = TILES.lushbrushland
						elif heat_cell > 0.85:
							set_cell(Vector2i(x,y),0,TILES.desertforest)
#							if cell_forest > 0.3:
#							array[y][x] = TILES.desertforest
						else:
							if cell_forest > 0.5:
								set_cell(Vector2i(x,y),0,TILES.deepforest)
#								array[y][x] = TILES.deepforest
							elif cell_forest > 0.4:
								set_cell(Vector2i(x,y),0,TILES.forest)
#								array[y][x] = TILES.forest
							elif cell_forest > 0.3:
								set_cell(Vector2i(x,y),0,TILES.brushland)
#								array[y][x] = TILES.brushland
					else:
						var cell_land = land_noise.get_noise_2d(float(x), float(y))
						if heat_cell < 0.15:
							set_cell(Vector2i(x,y),0,TILES.snow)
#							array[y][x] = TILES.snow
						elif heat_cell > 0.85:
							set_cell(Vector2i(x,y),0,TILES.desert)
#							array[y][x] = TILES.desert
						else:
							if cell_land < -0.25:
								set_cell(Vector2i(x,y),0,TILES.swamp)
#								array[y][x] = TILES.swamp
							elif cell_land < -0.1:
								set_cell(Vector2i(x,y),0,TILES.dirt)
#								array[y][x] = TILES.dirt
							else:
								if heat_cell > 0.6 and heat_cell < 0.85:
									set_cell(Vector2i(x,y),0,TILES.lushgrass)
#									array[y][x] = TILES.lushgrass
								elif heat_cell > 0.15 and heat_cell < 0.3:
									set_cell(Vector2i(x,y),0,TILES.tundra)
#									array[y][x] = TILES.tundra
								else:
									set_cell(Vector2i(x,y),0,TILES.grass)
#									array[y][x] = TILES.grass
	# Define your own hellish landscape, bypasses typical generation
	elif type == "hellplanet":
		var yp = JacobianIK3D.RotationAxis.ROTATION_AXIS_ALL
		yp.Basis = is_rounded
		if yp:
			set_cell(Vector2i.RIGHT,1,Vector2i(0,0))
		else:
			var house = "..."
			house.concat(yp)
			var street = range(house)
		pass
	
	heat = 0
	Locations.genself(world_type,world_size)
		
func find_continents(X,Y,Height):
	var a = setup_continents(X,Y)
	for y in range(Y):
		var temp = []
		for x in range(X):
			var cell
			if not height_image:
				cell = noise_height.get_noise_2d(float(x), float(y)) + heightChange + (0.05 * variation_noise.get_noise_2d(float(x), float(y))) #  + randf_range(-height_variation, height_variation)
			else:
				cell = (height_image.get_pixel(x, y).r * 2 - 1) + heightChange
			if a[y][x] == 0 and cell > -0.1:
				paint(a)
			pass
	pass
		

func setup_continents(X,Y) -> Array:
	var a = []
	for y in range(Y):
		var temp = []
		for x in range(X):
			temp.append(0)
		a.append(temp)
	return a

func paint(array):
	
	
	
	
	pass

func on_circle(xpos, ypos, Size:Vector2):
	if not is_rounded or is_ovalled:
		return true
	if Size.x / 2 > sqrt(abs(xpos - Size.x / 2) * abs(xpos - Size.x / 2) + abs(ypos - Size.x / 2) * abs(ypos - Size.x / 2)):
		return true
	else:
		return false

# Copilot wrote this
func is_point_in_rotated_oval(point: Vector2, center: Vector2, radius: Vector2, angle: float) -> bool:
	if not is_ovalled or is_rounded:
		return true
	var rel = point - center
	var rotated = rel.rotated(-angle)
	return pow(rotated.x / radius.x, 2) + pow(rotated.y / radius.y, 2) <= 1.0


func _create_square2d_array(size):
	var a = []
#	var noise_height_image = noise_height.get_image(size, size)
	for y in range(size):
		a.append([])
		a[y].resize(size)
		
		for x in range(size):
			a[y][x] = null
#			var cell = noise_height.get_noise_2d(float(x), float(y))
#			print(noise_height_image.get_pixel(x, y))
#			if cell < -0.1:
#				a[y][x] = type2
#			elif cell > -0.1:
#				a[y][x] = type
#			if x % 2:
#				a[y][x] = type2
#			else:
#				a[y][x] = type
#			a[y][x] = type
			
	return a
	
#
#func genLocations(type:String, size:Vector2):
	##var result = _create_square2d_array(size)
##	print(size)
	#if type == "overworld":
		#print("Genning overworld locations.")
		#var caves = (size * size) / 1000
		#for y in size.y:
			#for x in size.x:
				#if Locations.get_cell_atlas_coords(Vector2i(x,y)) != Vector2i(-1,-1):
					#continue
				#
				#if self.get_cell_atlas_coords(Vector2i(x,y)) in OCEANTILES:
					## Sea locations go here.
					#continue
				#else:
					#var Rand = randf_range(-1, 1)
##						print(Rand)
					#if Rand > 0.995:
						#Locations.set_cell(Vector2i(x,y),0,LOCATIONS.cave)
##							print("location added")
##							caves -= 1
						#tiles_count += 1
					#elif Rand < -0.997:
						#var wealth = rng.randi_range(20, 25000)
						#var anythingPlaced = false
						#if is_rounded and not on_circle(x, y, size):
							#continue
						#if is_ovalled and not is_point_in_rotated_oval(Vector2(x,y),Vector2(size.x/2,size.y/2),Vector2(size.x/2,size.y/2),40.0):
							#continue
						#if is_rounded and on_circle(x+5,y+5,size-Vector2(5,5)):
							#continue
						#elif not (is_rounded or is_ovalled):
							#if x < 5 or x > size.x - 5 or y < 5 or y > size.y - 5:
								#continue
						#while (wealth > 0):
							#if wealth < 200 and !anythingPlaced:
								#Locations.set_cell(Vector2i(x,y),0,LOCATIONS.camp)
								#wealth = 0
							#elif wealth > 2200:
								#anythingPlaced = true
								#Locations.set_cell(Vector2i(x,y),0,LOCATIONS.temple)
								#wealth - 800
##									var Drange = 1
##									var displace = 1
##									while (wealth > 0):
##										var location = Vector2(0,0)
##										match displace:
##											1:
##												location.x = 0
##												location.y = -1 * Drange
##											2:
##												location.x = 0
##												location.y = 1 * Drange
##											3:
##												location.y = 0
##												location.x = -1 * Drange
##											4:
##												location.y = 0
##												location.x = 1 * Drange
##											5:
##												location.x = 1 * Drange
##												location.y = 1 * Drange
##											6:
##												location.x = 1 * Drange
##												location.y = -1 * Drange
##											7:
##												location.x = -1 * Drange
##												location.y = 1 * Drange
##											8:
##												location.x = -1 * Drange
##												location.y = -1 * Drange
##												Drange += 1
##												displace = 0
##
##										displace += 1
##										var Y = y + location.y
##										var X = x + location.x
##										if wealth > 2000:
##											Locations.set_cell(Vector2i(x,y),0,LOCATIONS.town
##											wealth -= 500
##										elif wealth > 200:
##											Locations.set_cell(Vector2i(x,y),0,LOCATIONS.settlement
##											wealth -= 200
##										else:
##											wealth = 0
##Commented out the expansion insanity, we need more florid growht!
								##if wealth > 500 and result[y-1][x] == null and array[y-1][x] != null:
									##result[y-1][x] = LOCATIONS.town
									##wealth -= 500
								##if wealth > 200 and result[y+1][x] == null and array[y+1][x] != null:
									##result[y+1][x] = LOCATIONS.settlement
									##wealth -= 200
								##if wealth > 200 and result[y][x-1] == null and array[y][x-1] != null:
									##result[y][x-1] = LOCATIONS.settlement
									##wealth -= 200
								##if wealth > 200 and result[y][x+1] == null and array[y][x+1] != null:
									##result[y][x+1] = LOCATIONS.settlement
									##wealth -= 200
								#wealth = 0
								#continue
							#elif wealth > 600:
								#anythingPlaced = true
								#Locations.set_cell(Vector2i(x,y),0,LOCATIONS.town)
								#wealth = 0
							#elif wealth > 200:
								#anythingPlaced = true
								#Locations.set_cell(Vector2i(x,y),0,LOCATIONS.settlement)
								#wealth = 0
							#wealth = 0
							#pass
##		generate_rivers(array)
##		print(result)


#func generate_characters(size):
	##var result = _create_square2d_array(size)
	#for y in size.y:
		#for x in size.x:
			#var R = randf()
##			print(R)
			#if R > 0.995:
				#if get_cell_atlas_coords(Vector2(x,y)) == null:
					#continue
				#if get_cell_atlas_coords(Vector2(x,y)) in OCEANTILES:
					#continue
				##if locArray[y][x] != null:
					##continue
###				print("Made it")
				#if get_cell_atlas_coords(Vector2(x,y)) in CENTRALTILES:
					#R = randf()
					#if R > 0.5:
						#Actors.set_cell(Vector2i(x,y),0,HUMANS.fcentralknight)
					#else:
						#Actors.set_cell(Vector2i(x,y),0,HUMANS.mcentral)
				#elif get_cell_atlas_coords(Vector2(x,y)) in MIDTILES:
					#R = randf()
					#if R > 0.5:
						#Actors.set_cell(Vector2i(x,y),0,HUMANS.mmidlanderknight)
					#else:
						#Actors.set_cell(Vector2i(x,y),0,HUMANS.nmidlander)
				#elif get_cell_atlas_coords(Vector2(x,y)) in CHILLTILES:
					#Actors.set_cell(Vector2i(x,y),0,HUMANS.ffarlander)
					#
			#elif R < 0.017:
				#if get_cell_atlas_coords(Vector2(x,y)) == Vector2i(TILES.swamp):
					#R = randf()
					#if R > 0.5:
						#Actors.set_cell(Vector2i(x,y),0,MONSTERS.zombiehuman)
					#else:
						#Actors.set_cell(Vector2i(x,y),0,MONSTERS.zombiegoblin)
				#if get_cell_atlas_coords(Vector2(x,y)) in OCEANTILES:
					#R = randf()
					#if R > 0.2:
						#Actors.set_cell(Vector2i(x,y),0,ANIMALS.smallfish)
					#else:
						#Actors.set_cell(Vector2i(x,y),0,ANIMALS.largefish)
	##				continue
				#elif get_cell_atlas_coords(Vector2(x,y)) in CHILLTILES:
					#Actors.set_cell(Vector2i(x,y),0,ANIMALS.snowrabbit)
				#elif get_cell_atlas_coords(Vector2(x,y)) in MIDTILES:
					#R = randf()
					#if R > 0.4:
						#R = randf()
						#if R > 0.9:
							#Actors.set_cell(Vector2i(x,y),0,ANIMALS.bear)
						#elif R > 0.8: 
							#Actors.set_cell(Vector2i(x,y),0,ANIMALS.fox)
						#else:
							#Actors.set_cell(Vector2i(x,y),0,ANIMALS.bee)
					#else:
						#R = randf()
						#if R > 0.4:
							#R = randf()
							#if R > 0.49:
								#Actors.set_cell(Vector2i(x,y),0,MONSTERS.goblinwarrior)
							#else:
								#Actors.set_cell(Vector2i(x,y),0,MONSTERS.goblinmage)
						#else:
							#R = randf()
							#if R < 0.2:
								#Actors.set_cell(Vector2i(x,y),0,MONSTERS.blobkin)
							#else:
								#Actors.set_cell(Vector2i(x,y),0,MONSTERS.forestslime)


func _on_create_time_timeout() -> void:
	if get_used_cells():
		return
	#pre_startup_init()
	startup()
	pass # Replace with function body.
