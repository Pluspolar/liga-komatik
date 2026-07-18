extends Node2D

@export var boundary_x : int = 300
@onready var boundary_y : int = boundary_x
var noise = FastNoiseLite.new()
var tile_set
var corner_spot

@onready var width : int = boundary_x
@onready var height : int = boundary_x
@onready var width_half : int = round(width/2)
@onready var height_half : int = round(height/2)


@onready var player := $Ysort/player
@onready var ysort := $Ysort

var found_urban = false

var biome = {}
var destruction = {}
var blocks = {}
var altitude = {}
var moisture = {}
var temperature = {}
var urban = {}

@onready var boundary : Vector2 = Vector2(boundary_x*8 - get_viewport_rect().size.x/2, boundary_y*8 - get_viewport_rect().size.y/2)
@onready var boundary_player : Vector2 = Vector2(boundary_x*8-6, boundary_y*8-6)

enum dia_state {
	READY,
	TALKING,
	DONE
}

var noisetype := {
	"simplex" : FastNoiseLite.TYPE_SIMPLEX,
	"simplex_smooth" : FastNoiseLite.TYPE_SIMPLEX_SMOOTH,
	"cellular" : FastNoiseLite.TYPE_CELLULAR,
	"perlin" : FastNoiseLite.TYPE_PERLIN,
	"value_cubic" : FastNoiseLite.TYPE_VALUE_CUBIC,
	"value" : FastNoiseLite.TYPE_VALUE
}

var tiles_data := {}

func rand_tiles_data():
	tiles_data = {
	"dirt" : Vector2i(randi_range(0,1), randi_range(0,1)),
	"sand" : Vector2i(randi_range(2,3), randi_range(0,1)),
	"water" : Vector2i(4,0),
	"grass" : Vector2i(randi_range(6,7), randi_range(0,1)),
	"stone" : Vector2i(randi_range(0,1), randi_range(2,3))
}


var biomes_data := {
	"plains" : {"grass" : 1, "dirt" : 0},
	"beach" : {"sand" : 1},
	"ocean" : {"water" : 1},
	"eucalyptus" : {"grass" : 0.05, "dirt" : 0.95},
	"city_1" : {"stone" : 0.997, "dirt" : 0.003}
}

var objects_data := {
	"plains" : {"tree" : 0.03},
	"beach" : {},
	"ocean" : {},
	"eucalyptus" : {"tree" : 0.01},
	"city_1" : {}
}

var objects := {"tree" : [[1,1], preload("res://scenes/tree.tscn")]}

var objects_pos := {}

func generate_noise(freq : float, oct : int, noise_type: String, multiplier: float = 1, additive: float = 0, is_abs : bool = false):
	noise.seed = randi()
	noise.frequency = freq
	noise.fractal_octaves = oct
	noise.noise_type = noisetype[noise_type.to_lower()]
	var grid_noise = {}
	if !is_abs:
		for x in range(-width_half, width_half):
			for y in range(-height_half, height_half):
				grid_noise[Vector2i(x,y)] = multiplier*(noise.get_noise_2d(x, y)+additive)
		return grid_noise
	else:
		for x in range(-width_half, width_half):
			for y in range(-height_half, height_half):
				grid_noise[Vector2i(x,y)] = multiplier*(abs(noise.get_noise_2d(x, y))+additive)
		return grid_noise
		
func _ready() -> void:
	altitude = generate_noise(0.0175, 3, "perlin", 1, 0.05)
	#altitude = generate_noise(0.0175, 3, "cellular", 1, 0.55)
	moisture = generate_noise(0.01, 3, "value_cubic")
	temperature = generate_noise(0.02, 3, "simplex_smooth")
	urban = generate_noise(0.0025, 1, "simplex", 1, 0.2)
	destruction = generate_noise(0.003, 3, "cellular", 1, 0.2)
	#altitude = generate_noise(0.0275, 3, "circullar")
	#print(altitude)
	_set_tile()
	
func _set_tile():
	#tile_set = $TileMapLayer.local_to_map(corner_spot)
	for x in range(-width_half, width_half):
		for y in range(-height_half, height_half):
			var pos = Vector2i(x, y)
			#print($TileMapLayer.map_to_local(pos))
			var alt = altitude[pos]
			var temp = temperature[pos]
			var _urban = urban[pos]
			
			if _urban > 0:
				found_urban = true
				if alt < -0.5: place_tile_biome(pos, "ocean")
				elif alt >= -0.5 and alt < -0.45 : place_tile_biome(pos, "eucalyptus")
				elif _urban <= 0.03: place_tile_biome(pos, "eucalyptus")
				else: place_tile_biome(pos, "city_1")
			else: 
				if alt < -0.25: place_tile_biome(pos, "ocean")
				elif alt >= -0.25 and alt < -0.2 : place_tile_biome(pos, "beach")
				elif alt >= -0.2 and alt < -0.15 : place_tile_biome(pos, "eucalyptus")
				else:
					if temp > 0.3: place_tile_biome(pos, "eucalyptus")
					else: place_tile_biome(pos, "plains")
					
			
	print(found_urban)
			#$TileMapLayer.set_cell(pos, 0, tiles_data["water"], 0)

func place_tile_biome(pos : Vector2i, _biome: String):
	rand_tiles_data()
	biome[pos] = _biome
	var tile = random_tiles(biomes_data, _biome)
	blocks[pos] = tile
	$tilemap.set_cell(pos, 1, tiles_data[tile], 0)
	create_object(pos, _biome)

func random_tiles(data, _biome):
	var cur_biome = data[_biome]
	var chance = 0
	var rand_num = randf_range(0, 1)
	for tile in cur_biome:
		chance += cur_biome[tile]
		if rand_num <= chance:
			return tile

func create_object(pos, biome):
	var random_obj = random_tiles(objects_data, biome)
	if random_obj != null:
		if check_accessibility(pos, random_obj):
			tile_to_map(pos, random_obj)
			objects_pos[pos] = random_obj
	else: objects_pos[pos] = null
	
func check_accessibility(pos, random_obj):
	var obj_size = objects[str(random_obj)][0]
	for x in range(obj_size[0]):
		for y in range(obj_size[1]):
			if objects_pos.get(pos):
				return false
	return true
	
func tile_to_map(pos, random_obj):
	var obj = objects[str(random_obj)][1].instantiate()
	obj.position = $tilemap.map_to_local(pos)
	ysort.add_child(obj)
	
#func _create_cell():
#	tile_set = $TileMapLayer.local_to_map(corner_spot)
	#print(tile_set)
#	for i in range(-2, 18):
#		for j in range(-2, 11):
#			var place_tile = tile_set + Vector2i(i,j)
#			if !$TileMapLayer.get_cell_tile_data(place_tile): 
#				$TileMapLayer.set_cell(place_tile, 1, Vector2i(randi_range(0,1),randi_range(0,1)), 0)

func _process(delta: float) -> void:
	corner_spot = ($Camera2D.global_position) - (get_viewport_rect().size/2)
	#print(corner_spot)
	#_create_cell()
	#print(1/sqrt(float(Input.is_action_pressed("left") or Input.is_action_pressed("right")) + float(Input.is_action_pressed("up") or Input.is_action_pressed("down"))))
	var diagonal: float = sqrt(float(Input.is_action_pressed("left") or Input.is_action_pressed("right")) + float(Input.is_action_pressed("up") or Input.is_action_pressed("down")))
	if diagonal == 0: diagonal = 1
	#print(diagonal)
	player.position = Vector2(clamp(player.position.x, -boundary_player.x, boundary_player.x), clamp(player.position.y, -boundary_player.y, boundary_player.y))
	var cur_block = blocks[$tilemap.local_to_map(player.position)]
	if cur_block == "water": player.velocity += 10000 * delta * (1/diagonal) * Vector2(float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left")), float(Input.is_action_pressed("down")) - float(Input.is_action_pressed("up")))
	else: player.velocity += 10000 * delta * (1/diagonal) * Vector2(float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left")), float(Input.is_action_pressed("down")) - float(Input.is_action_pressed("up")))
	player.velocity *= pow(0.85, delta*60)
	
	$Camera2D.position_smoothing_speed = 5 + player.velocity.length()*0.01
	$Camera2D.position = player.global_position
	
	#if abs($Camera2D.position.x) > boundary.x: $Camera2D.position.x = abs($Camera2D.position.x) / $Camera2D.position.x * boundary.x
	#if abs($Camera2D.position.y) > boundary.y: $Camera2D.position.y = abs($Camera2D.position.y) / $Camera2D.position.y * boundary.y
	
	$Camera2D.position = Vector2(clamp($Camera2D.position.x, -boundary.x, boundary.x), clamp($Camera2D.position.y, -boundary.y, boundary.y))
	
	if Input.is_action_just_pressed("ui_accept"):
		#var item = items["item_1"].instantiate()
		#item.position = Vector2(randf_range(get_viewport_rect().size.x/2-20, get_viewport_rect().size.x/2+20), 0)
		Global.spawn_new_item(player.position + Vector2(15,0), "Test", 1.5)
		#$backpack.add_child(item)
	
	#if abs($player.position.x) > boundary_player.x: $player.position.x = abs($player.position.x) / $player.position.x * boundary_player.x
	#if abs($player.position.y) > boundary_player.y: $player.position.y = abs($player.position.y) / $player.position.y * boundary_player.y
	
	#print(boundary)
	#print($Camera2D.position)
