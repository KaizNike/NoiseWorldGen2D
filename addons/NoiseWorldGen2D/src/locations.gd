#@tool
extends TileMapLayer

var rng = RandomNumberGenerator.new()

const TILES = {
	"dirt" : Vector2i(0,0),
	"grass" : Vector2i(1,0),
	"mountain" : Vector2i(2,0),
	"hill" : Vector2i(3,0),
	"shallowwater" : Vector2i(0,1),
	"medwater" : Vector2i(1,1),
	"deepwater" : Vector2i(2,1),
	"abyssalwater" : Vector2i(3,1),
	"swamp" : Vector2i(0,2),
	"brushland" : Vector2i(1,2),
	"forest" : Vector2i(2,2),
	"deepforest" : Vector2i(3,2),
	"snow" : Vector2i(0,3),
	"ice" : Vector2i(1,3),
	"tundra" : Vector2i(2,3),
	"tundraforest" : Vector2i(3,3),
	"desert" : Vector2i(0,4),
	"desertforest" : Vector2i(1,4),
	"dryhills" : Vector2i(2,4),
	"tundradeepforest" : Vector2i(3,4),
	"lushgrass" : Vector2i(0,5),
	"lushbrushland" : Vector2i(1,5),
	"jungle" : Vector2i(2,5),
	"deepjungle" : Vector2i(3,5)
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
	"cave" : Vector2i(0,0),
	"camp" : Vector2i(0,1),
	"settlement" : Vector2i(1,1),
	"town" : Vector2i(2,1),
	"temple" : Vector2i(3,1)
}


func genself(type:String, size:Vector2):
	clear()
	#var result = _create_square2d_array(size)
#	print(size)
	if type == "overworld":
		print("Genning overworld locations.")
		var caves = (size * size) / 1000
		for y in size.y:
			for x in size.x:
				if self.get_cell_atlas_coords(Vector2i(x,y)) != Vector2i(-1,-1):
					continue
				
				if get_parent().get_cell_atlas_coords(Vector2i(x,y)) in OCEANTILES:
					# Sea locations go here.
					continue
				else:
					var Rand = randf_range(-1, 1)
#						print(Rand)
					if Rand > 0.995:
						self.set_cell(Vector2i(x,y),0,LOCATIONS.cave)
#							print("location added")
#							caves -= 1
						#tiles_count += 1
					elif Rand < -0.997:
						var wealth = rng.randi_range(20, 25000)
						var anythingPlaced = false
						if get_parent().is_rounded and not get_parent().on_circle(x, y, size):
							continue
						if get_parent().is_ovalled and not get_parent().is_point_in_rotated_oval(Vector2i(x,y),Vector2i(size.x/2,size.y/2),Vector2i(size.x/2,size.y/2),40.0):
							continue
						#if get_parent().is_rounded and get_parent().on_circle(x+5,y+5,Vector2i(size)-Vector2i(5,5)):
							#continue
						elif not (get_parent().is_rounded or get_parent().is_ovalled):
							if x < 5 or x > size.x - 5 or y < 5 or y > size.y - 5:
								continue
						while (wealth > 0):
							if wealth < 200 and !anythingPlaced:
								self.set_cell(Vector2i(x,y),0,LOCATIONS.camp)
								wealth = 0
							elif wealth > 2200:
								anythingPlaced = true
								self.set_cell(Vector2i(x,y),0,LOCATIONS.temple)
								wealth - 800
#									var Drange = 1
#									var displace = 1
#									while (wealth > 0):
#										var location = Vector2i(0,0)
#										match displace:
#											1:
#												location.x = 0
#												location.y = -1 * Drange
#											2:
#												location.x = 0
#												location.y = 1 * Drange
#											3:
#												location.y = 0
#												location.x = -1 * Drange
#											4:
#												location.y = 0
#												location.x = 1 * Drange
#											5:
#												location.x = 1 * Drange
#												location.y = 1 * Drange
#											6:
#												location.x = 1 * Drange
#												location.y = -1 * Drange
#											7:
#												location.x = -1 * Drange
#												location.y = 1 * Drange
#											8:
#												location.x = -1 * Drange
#												location.y = -1 * Drange
#												Drange += 1
#												displace = 0
#
#										displace += 1
#										var Y = y + location.y
#										var X = x + location.x
#										if wealth > 2000:
#											self.set_cell(Vector2i(x,y),0,LOCATIONS.town
#											wealth -= 500
#										elif wealth > 200:
#											self.set_cell(Vector2i(x,y),0,LOCATIONS.settlement
#											wealth -= 200
#										else:
#											wealth = 0
#Commented out the expansion insanity, we need more florid growht!
								#if wealth > 500 and result[y-1][x] == null and array[y-1][x] != null:
									#result[y-1][x] = LOCATIONS.town
									#wealth -= 500
								#if wealth > 200 and result[y+1][x] == null and array[y+1][x] != null:
									#result[y+1][x] = LOCATIONS.settlement
									#wealth -= 200
								#if wealth > 200 and result[y][x-1] == null and array[y][x-1] != null:
									#result[y][x-1] = LOCATIONS.settlement
									#wealth -= 200
								#if wealth > 200 and result[y][x+1] == null and array[y][x+1] != null:
									#result[y][x+1] = LOCATIONS.settlement
									#wealth -= 200
								wealth = 0
								continue
							elif wealth > 600:
								anythingPlaced = true
								self.set_cell(Vector2i(x,y),0,LOCATIONS.town)
								wealth = 0
							elif wealth > 200:
								anythingPlaced = true
								self.set_cell(Vector2i(x,y),0,LOCATIONS.settlement)
								wealth = 0
							wealth = 0
							pass
#		generate_rivers(array)
#		print(result)
	print("Ok, that's good (LOC), now for (MONS)+more!")
	get_parent().actorsNOW()
