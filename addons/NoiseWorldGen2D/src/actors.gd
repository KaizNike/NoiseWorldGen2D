@tool
extends TileMapLayer

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

var HUMANS = {
	"ffarlander" : Vector2i(0,0),
	"nmidlander" : Vector2i(0,1),
	"mmidlanderknight" : Vector2i(1,1),
	"mcentral" : Vector2i(0,2),
	"fcentralknight" : Vector2i(1,2)
}

var MONSTERS = {
	"blobkin" : Vector2i(0,0),
	"forestslime" : Vector2i(1,0),
	"goblinwarrior" : Vector2i(0,1),
	"goblinmage" : Vector2i(1,1),
	"zombiehuman" : Vector2i(2,1),
	"zombiegoblin" : Vector2i(3,1)
}

var ANIMALS = {
	"smallfish" : Vector2i(2,0),
	"largefish" : Vector2i(3,0),
	"fox" : Vector2i(0,2),
	"snowrabbit" : Vector2i(1,2),
	"bear" :  Vector2i(2,2),
	"bee" : Vector2i(3,2)
}

func genself(size):
	clear()
	#var result = _create_square2d_array(size)
	for y in size.y:
		y = int(y)
		for x in size.x:
			if y == 45 and x == 20:
				pass
			x = int(x)
			#if get_parent().get_cell_atlas_coords(Vector2i(x,y)) == null:
				#continue
			var tile = get_parent().get_cell_atlas_coords(Vector2i(x,y))
			tile = TILES.find_key(tile)
			#if not tile:
				#continue
			#if tile:
				#pass
			var R = randf()
#			print(R)
			if R > 0.95:
				if get_parent().get_cell_atlas_coords(Vector2i(x,y)) == null:
					continue
				if get_parent().get_cell_atlas_coords(Vector2i(x,y)) in OCEANTILES:
					# Sea dwellers
					continue
				#if locArray[y][x] != null:
					#continue
##				print("Made it")
				if get_parent().get_cell_atlas_coords(Vector2i(x,y)) in CENTRALTILES:
					R = randf()
					if R > 0.5:
						set_cell(Vector2i(x,y),0,HUMANS.fcentralknight)
					else:
						set_cell(Vector2i(x,y),0,HUMANS.mcentral)
				elif get_parent().get_cell_atlas_coords(Vector2i(x,y)) in MIDTILES:
					R = randf()
					if R > 0.5:
						set_cell(Vector2i(x,y),0,HUMANS.mmidlanderknight)
					else:
						set_cell(Vector2i(x,y),0,HUMANS.nmidlander)
				elif get_parent().get_cell_atlas_coords(Vector2i(x,y)) in CHILLTILES:
					set_cell(Vector2i(x,y),0,HUMANS.ffarlander)
					
			elif R < -0.6:
				if get_parent().get_cell_atlas_coords(Vector2i(x,y)) == Vector2i(TILES.swamp):
					R = randf()
					if R > 0.5:
						set_cell(Vector2i(x,y),1,MONSTERS.zombiehuman)
					else:
						set_cell(Vector2i(x,y),1,MONSTERS.zombiegoblin)
				if get_parent().get_cell_atlas_coords(Vector2i(x,y)) in OCEANTILES:
					R = randf()
					if R > 0.2:
						set_cell(Vector2i(x,y),1,ANIMALS.smallfish)
					else:
						set_cell(Vector2i(x,y),1,ANIMALS.largefish)
	#				continue
				elif get_parent().get_cell_atlas_coords(Vector2i(x,y)) in CHILLTILES:
					set_cell(Vector2i(x,y),1,ANIMALS.snowrabbit)
				elif get_parent().get_cell_atlas_coords(Vector2i(x,y)) in MIDTILES:
					R = randf()
					if R > 0.4:
						R = randf()
						if R > 0.9:
							set_cell(Vector2i(x,y),1,ANIMALS.bear)
						elif R > 0.8: 
							set_cell(Vector2i(x,y),1,ANIMALS.fox)
						else:
							set_cell(Vector2i(x,y),1,ANIMALS.bee)
					else:
						R = randf()
						if R > 0.4:
							R = randf()
							if R > 0.49:
								set_cell(Vector2i(x,y),1,MONSTERS.goblinwarrior)
							else:
								set_cell(Vector2i(x,y),1,MONSTERS.goblinmage)
						else:
							R = randf()
							if R < 0.2:
								set_cell(Vector2i(x,y),1,MONSTERS.blobkin)
							else:
								set_cell(Vector2i(x,y),1,MONSTERS.forestslime)
	print("All Done!")
