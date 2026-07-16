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

var biome = {}
var altitude = {}
var moisture = {}
var temperature = {}

@onready var boundary : Vector2 = Vector2(boundary_x*8 - get_viewport_rect().size.x/2, boundary_y*8 - get_viewport_rect().size.y/2)
@onready var boundary_player : Vector2 = Vector2(boundary_x*8-6, boundary_y*8-6)

var noisetype := {
	"simplex" : FastNoiseLite.TYPE_SIMPLEX,
	"simplex_smooth" : FastNoiseLite.TYPE_SIMPLEX_SMOOTH,
	"cellular" : FastNoiseLite.TYPE_CELLULAR,
	"perlin" : FastNoiseLite.TYPE_PERLIN,
	"value_cubic" : FastNoiseLite.TYPE_VALUE_CUBIC,
	"value" : FastNoiseLite.TYPE_VALUE
}

var tiles_data := {
	"dirt" : Vector2i(randi_range(0,1), randi_range(0,1)),
	"sand" : Vector2i(randi_range(2,3), randi_range(0,1)),
	"water" : Vector2i(4,0),
	"grass" : Vector2i(randi_range(6,7), randi_range(0,1))
}

var biomes_data := {
	"plains" : {"grass" : 1, "dirt" : 0},
	"beach" : {"sand" : 1},
	"ocean" : {"water" : 1},
	"eucalyptus" : {"grass" : 0.05, "dirt" : 0.95}
}

var objects_data := {
	"plains" : {"tree" : 0.03},
	"beach" : {},
	"ocean" : {},
	"eucalyptus" : {"tree" : 0.01}
}

var objects := {"tree" : [[1,1], preload("res://scenes/tree.tscn")]}

var objects_pos := {}

func generate_noise(freq : float, oct : int, noise_type: String):
	noise.seed = randi()
	noise.frequency = freq
	noise.fractal_octaves = oct
	noise.noise_type = noisetype[noise_type.to_lower()]
	var grid_noise = {}
	for x in range(-width_half, width_half):
		for y in range(-height_half, height_half):
			grid_noise[Vector2i(x,y)] = noise.get_noise_2d(x, y)
	return grid_noise

func _ready() -> void:
	altitude = generate_noise(0.0175, 3, "perlin")
	moisture = generate_noise(0.01, 3, "value_cubic")
	temperature = generate_noise(0.02, 3, "simplex_smooth")
	#altitude = generate_noise(0.0275, 3, "circullar")
	#print(altitude)
	_set_tile()

func rand_tiles_data():
	tiles_data = {
	"dirt" : Vector2i(randi_range(0,1), randi_range(0,1)),
	"sand" : Vector2i(randi_range(2,3), randi_range(0,1)),
	"water" : Vector2i(4,0),
	"grass" : Vector2i(randi_range(6,7), randi_range(0,1))
}

func _set_tile():
	#tile_set = $TileMapLayer.local_to_map(corner_spot)
	for x in range(-width_half, width_half):
		for y in range(-height_half, height_half):
			var pos = Vector2i(x, y)
			#print($TileMapLayer.map_to_local(pos))
			var alt = altitude[pos]
			var temp = temperature[pos]
			
			if alt < -0.2: place_tile_biome(pos, "ocean")
			
			elif alt >= -0.2 and alt < -0.15 : place_tile_biome(pos, "beach")
			
			elif alt >= -0.15 and alt < -0.1 : place_tile_biome(pos, "eucalyptus")
			
			else: 
				if temp > 0.3: place_tile_biome(pos, "eucalyptus")
				else: place_tile_biome(pos, "plains")
			
			#$TileMapLayer.set_cell(pos, 0, tiles_data["water"], 0)

func place_tile_biome(pos : Vector2i, _biome: String):
	rand_tiles_data()
	biome[pos] = _biome
	$TileMapLayer.set_cell(pos, 0, tiles_data[random_tiles(biomes_data, _biome)], 0)
	create_object(pos, _biome)

func random_tiles(data, biome):
	var cur_biome = data[biome]
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
	obj.position = $TileMapLayer.map_to_local(pos)
	add_child(obj)
	
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
	$player.position += 5 * (1/diagonal) * Vector2(float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left")), float(Input.is_action_pressed("down")) - float(Input.is_action_pressed("up")))
	
	$Camera2D.position = $player.global_position
	#if abs($Camera2D.position.x) > boundary.x: $Camera2D.position.x = abs($Camera2D.position.x) / $Camera2D.position.x * boundary.x
	#if abs($Camera2D.position.y) > boundary.y: $Camera2D.position.y = abs($Camera2D.position.y) / $Camera2D.position.y * boundary.y
	
	$Camera2D.position = Vector2(clamp($Camera2D.position.x, -boundary.x, boundary.x), clamp($Camera2D.position.y, -boundary.y, boundary.y))
	$player.position = Vector2(clamp($player.position.x, -boundary_player.x, boundary_player.x), clamp($player.position.y, -boundary_player.y, boundary_player.y))
	
	#if abs($player.position.x) > boundary_player.x: $player.position.x = abs($player.position.x) / $player.position.x * boundary_player.x
	#if abs($player.position.y) > boundary_player.y: $player.position.y = abs($player.position.y) / $player.position.y * boundary_player.y
	
	#print(boundary)
	#print($Camera2D.position)
