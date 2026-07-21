extends Node2D

@export var boundary_x : int = 300
@export var speed : float = 1000
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

var int_player_magnitude : int
var found_urban = false
var old_cam

var biome = {}
var destruction = {}
var blocks = {}
var tile_array = {}
var altitude = {}
var moisture = {}
var temperature = {}
var urban = {}

var test : float = 0

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
var objects_id := {}

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
	old_cam = $Camera2D.position
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
					
			
	#print(found_urban)
			#$TileMapLayer.set_cell(pos, 0, tiles_data["water"], 0)

func place_tile_biome(pos : Vector2i, _biome: String):
	rand_tiles_data()
	biome[pos] = _biome
	var tile = random_tiles(biomes_data, _biome)
	blocks[pos] = tile
	tile_array[pos] = tiles_data[tile]
	#$tilemap.set_cell(pos, 1, tiles_data[tile], 0)
	create_object(pos, _biome)

func random_tiles(data, _biome):
	var cur_biome = data[_biome]
	var chance = 0
	var rand_num = randf_range(0, 1)
	for tile in cur_biome:
		chance += cur_biome[tile]
		if rand_num <= chance:
			return tile

func create_object(pos, _biome):
	var random_obj = random_tiles(objects_data, _biome)
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
	obj.tile_id = pos
	objects_id[pos] = obj
	#print(objects_id[pos])
	ysort.add_child(obj)
	#objects_id[pos].hide()
	#print(objects_id.get(pos).visible)
	#print(objects_id.has(obj))
	
func _create_cell():
	var vel_x = round(abs(player.velocity.x/320)+1.5)
	var vel_y = round(abs(player.velocity.y/320)+1.5)
	#print(vel_x, " ", vel_y)
	Global.show_tiles.clear()
	corner_spot = ($Camera2D.global_position) - (Global.viewport_tree.size/2)
	#print($Camera2D.global_position)
	tile_set = $tilemap.local_to_map(corner_spot)
	#print(tile_set)
	for x in range(-8, Global.viewport_x_tile+8):
		for y in range(-8, Global.viewport_y_tile+8):
			var place_tile = tile_set + Vector2i(x,y)
			Global.show_tiles.append(place_tile)
			#if x < -2 or x > Global.viewport_x_tile+2 or y < -2 or y > Global.viewport_y_tile+2:
			if x < -vel_x or x > Global.viewport_x_tile+vel_x or y < -vel_y or y > Global.viewport_y_tile+vel_y:
				if objects_id.has(place_tile) : objects_id[place_tile].hide()
				$tilemap.set_cell(place_tile, -1)
				#if objects_id.find_key(place_tile) != null: objects_id[place_tile].hide()
			#elif !$tilemap.get_cell_tile_data(place_tile): 
			#elif blocks.has(place_tile):
			elif blocks.has(place_tile): #and !$tilemap.get_cell_tile_data(place_tile):
				#print(objects_id[place_tile])
				#if objects_id.find_key(place_tile) != null: objects_id[place_tile].show()
				#objects_id.get(place_tile).show()
				if objects_id.has(place_tile) : objects_id[place_tile].show()
				$tilemap.set_cell(place_tile, 1, tile_array[place_tile])
			
			
			
#$TileMapLayer.set_cell(place_tile, 1, Vector2i(randi_range(0,1),randi_range(0,1)), 0)

func is_in_water():
	if blocks[$tilemap.local_to_map(player.position)] == "water":
		return true
	for i in range(4):
		if blocks[$tilemap.local_to_map(player.position+Vector2(i%2*10-5, floor(i/2)*10-5))] == "water":
			return true
	return false
		

func _physics_process(delta: float) -> void:
	#$backpack.position = $Camera2D.position
	#corner_spot = ($Camera2D.global_position) - (get_viewport_rect().size/2)
	#print(corner_spot)
	#_create_cell()
	#print(1/sqrt(float(Input.is_action_pressed("left") or Input.is_action_pressed("right")) + float(Input.is_action_pressed("up") or Input.is_action_pressed("down"))))
	var diagonal: float = sqrt(float(Input.is_action_pressed("left") or Input.is_action_pressed("right")) + float(Input.is_action_pressed("up") or Input.is_action_pressed("down")))
	if diagonal == 0: diagonal = 1
	#print(diagonal)
	player.position = Vector2(clamp(player.position.x, -boundary_player.x, boundary_player.x), clamp(player.position.y, -boundary_player.y, boundary_player.y))
	var _is_in_water = is_in_water()
	#if blocks.has($tilemap.local_to_map(player.position+player.velocity)):
	#	cur_block.append(blocks[$tilemap.local_to_map(player.position+player.velocity)])
	#else:
	#	cur_block.append("")
	#if cur_block[0] == "water": player.velocity = speed/20 * delta * (1/diagonal) * Vector2(float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left")), float(Input.is_action_pressed("down")) - float(Input.is_action_pressed("up")))
	#else: 
	player.velocity += speed * delta * (1/diagonal) * Vector2(float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left")), float(Input.is_action_pressed("down")) - float(Input.is_action_pressed("up")))
	if _is_in_water: player.velocity *= pow(0.4, delta*60)
	else: player.velocity *= pow(0.85, delta*60)
	
	#$Camera2D.position_smoothing_speed = 5.0 + player.velocity.length()*0.01
	$Camera2D.position_smoothing_speed = 4 + speed/500.0
	$Camera2D.position = player.global_position
	
	#if abs($Camera2D.position.x) > boundary.x: $Camera2D.position.x = abs($Camera2D.position.x) / $Camera2D.position.x * boundary.x
	#if abs($Camera2D.position.y) > boundary.y: $Camera2D.position.y = abs($Camera2D.position.y) / $Camera2D.position.y * boundary.y
	
	
	$Camera2D.position = Vector2(clamp($Camera2D.position.x, -boundary.x, boundary.x), clamp($Camera2D.position.y, -boundary.y, boundary.y))
	#Global.cam_velocity = $Camera2D.position - old_cam
	#old_cam = $Camera2D.position
	Global.cam_coords = $Camera2D.position
	
	if Input.is_action_just_pressed("ui_accept"):
		#var item = items["item_1"].instantiate()
		#item.position = Vector2(randf_range(get_viewport_rect().size.x/2-20, get_viewport_rect().size.x/2+20), 0)
		Global.spawn_new_item(player.position + Vector2(15,0), "Test", 1.5)
		
	if Input.is_action_just_pressed("right_click"): 
		$dialogue.add_text("Also, we got some info from other sources that [wave]GURT[/wave] Town has been restocked.", 20, "Radio") #[wave amp=15 freq=5]
		$dialogue.add_text("[tornado radius=1.5 freq=3]Happy Scavenging!", 15, "Radio") #[wave amp=15 freq=8]
		#$backpack.add_child(item)
		
	#int_player_magnitude = player.velocity.length()/16/10
	#print(int_player_magnitude)
	_create_cell()
	#if abs($player.position.x) > boundary_player.x: $player.position.x = abs($player.position.x) / $player.position.x * boundary_player.x
	#if abs($player.position.y) > boundary_player.y: $player.position.y = abs($player.position.y) / $player.position.y * boundary_player.y
	
	#print(boundary)
	#print($Camera2D.position)
