extends Node2D

@export var boundary_x : int = 300
@export var speed : float = 1000

@onready var boundary_y : int = boundary_x
@onready var width : int = boundary_x
@onready var height : int = boundary_y
@onready var width_half : int = int(round(float(width)/2))
@onready var height_half : int = int(round(float(height)/2))

@onready var player := $Ysort/player
@onready var ysort := $Ysort
@onready var camera := $cam
@onready var dialogue := $dialogue
@onready var tile_map := $tilemap

var noise = FastNoiseLite.new()
var tile_set
var corner_spot
var thread_1 : Thread
var cam_global : Vector2
var accessibility_coords : Array = []
var int_player_magnitude : int

var biome = {}
var destruction = {}
var altitude = {}
var moisture = {}
var temperature = {}
var urban = {}

var interior_data = {
	"1_aband_house" : [0, [10,20], {"stone" : 0.9, "dirt" : 0.1}], 
	"1_aband_apart" : [0, [20,20], {"stone" : 0.9, "dirt" : 0.1}]} #id, tiles, [x_size, y_size]
var generate_interior = {}

var blocks = {}
var tile_array = {}
var generated_chunks = []
var cur_chunk : Vector2i
var cam_middle : Vector2 = Vector2(0,0)

@onready var changing_scene = Global.changing_scene
@onready var cur_scene = Global.cur_scene
@onready var chunks = Global.chunks
@onready var chunks_obj = Global.chunks_obj
@onready var chunk_size = Global.chunk_size
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
	"plains" : {"tree" : 0.025, "abandoned_house" : 0.0012},
	"beach" : {},
	"ocean" : {},
	"eucalyptus" : {"tree" : 0.01},
	"city_1" : {"abandoned_apartment" : 0.001}
}

var objects := { #[x_size, y_vertical_size, how much free space under "y"], scene
	"tree" : [[1,1,0], null, preload("res://scenes/tree.tscn")],
	"abandoned_house" : [[3,1,0], "1_aband_house", preload("res://scenes/abandoned_house.tscn")],
	"abandoned_apartment" : [[3,1,0], "1_aband_apart", preload("res://scenes/abandoned_apartment.tscn")]
}

var objects_pos := {}
#var objects_id := {}

func _ready() -> void:
	thread_1 = Thread.new()
	altitude = generate_noise(0.03, 3, "perlin", 1, 0.2)
	moisture = generate_noise(0.03, 3, "value_cubic")
	temperature = generate_noise(0.025, 3, "simplex_smooth")
	urban = generate_noise(0.006, 3, "simplex", 1, 0.36)
	destruction = generate_noise(0.003, 3, "cellular", 1, 0.2)
	_set_tile()
	
	thread_1.start(_create_cell_new)
	
func _exit_tree() -> void:
	thread_1.wait_to_finish()
	#print(altitude)

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
	
func _set_tile():
	for x in range(-width_half, width_half):
		for y in range(-height_half, height_half):
			var pos = Vector2i(x, y)
			var alt = altitude[pos]
			var temp = temperature[pos]
			var _urban = urban[pos]
			cur_chunk = tile_to_chunk(pos)
			
			if !chunks.has(cur_chunk): chunks[cur_chunk] = []
			if !chunks_obj.has(cur_chunk): chunks_obj[cur_chunk] = []
			
			if _urban > 0:
				if alt < -0.25: place_tile_biome(pos, "ocean")
				elif alt >= -0.25 and alt < -0.18 : place_tile_biome(pos, "eucalyptus")
				elif _urban <= 0.07: place_tile_biome(pos, "eucalyptus")
				else: place_tile_biome(pos, "city_1")
			else: 
				if alt < -0.25: place_tile_biome(pos, "ocean")
				elif alt >= -0.25 and alt < -0.2 : place_tile_biome(pos, "beach")
				elif alt >= -0.2 and alt < -0.15 : place_tile_biome(pos, "eucalyptus")
				else:
					if temp > 0.3: place_tile_biome(pos, "eucalyptus")
					else: place_tile_biome(pos, "plains")
		
func place_tile_biome(pos : Vector2i, _biome: String):
	rand_tiles_data()
	biome[pos] = _biome
	var tile = random_tiles(biomes_data, _biome)
	blocks[pos] = tile
	chunks[cur_chunk].append([pos, tiles_data[tile]])
	create_object(pos, _biome)
	#tile_array[pos] = tiles_data[tile]

func random_tiles(data, _place : String = ""):
	var cur_place
	if _place == "":
		cur_place = data
	else: cur_place = data[_place]
	var chance = 0
	var rand_num = randf_range(0, 1)
	for tile in cur_place:
		chance += cur_place[tile]
		if rand_num <= chance:
			return tile

func create_object(pos, _biome):
	var random_obj = random_tiles(objects_data, _biome)
	if random_obj != null:
		if check_accessibility(pos, random_obj):
			tile_to_map(pos, random_obj)
			#objects_pos[pos] = random_obj
	#else: objects_pos[pos] = null
	
func check_accessibility(pos, random_obj):
	accessibility_coords.clear()
	var temp_acc_coords = []
	var obj_size = objects[str(random_obj)][0]
	var y_free = obj_size[2]
	var middle = int(obj_size[0]/2)
	for x in range(obj_size[0]):
		for y in range(obj_size[1]+y_free):
			if objects_pos.get(pos+Vector2i(x-middle,-y+y_free)):
				return false
			temp_acc_coords.append(pos+Vector2i(x-middle,-y+y_free))
	accessibility_coords = temp_acc_coords.duplicate()
	return true
	
func tile_to_map(pos, random_obj):
	var obj_data = objects[str(random_obj)]
	var obj = obj_data[2].instantiate()
	obj.position = tile_map.map_to_local(pos)
	#obj.tile_id = pos
	for coords in accessibility_coords: 
		#objects_id[coords] = obj
		objects_pos[coords] = random_obj
	var obj_behav = obj_data[1]
	if obj_behav != null:
		#obj.object_id = interior_data[obj_behav][0]
		#interior_data[obj_behav][0] += 1
		generate_interior[obj] = create_interior(interior_data[obj_behav][1], interior_data[obj_behav][2])
	chunks_obj[cur_chunk].append(obj)
	ysort.add_child(obj)
	
func create_interior(room_size, palette):
	var cur_interior = []
	var x_range = room_size[0] - 1
	var y_range = room_size[1] - 1
	for x in range(x_range+1):
		for y in range(y_range+1):
			rand_tiles_data()
			var tile = random_tiles(palette)
			cur_interior.append([Vector2i(x,y), tile, tiles_data[tile]])
	return cur_interior
	
func _create_cell():
	var vel_x = round(abs(player.velocity.x/320)+1.5)
	var vel_y = round(abs(player.velocity.y/320)+1.5)
	Global.show_tiles.clear()
	corner_spot = (camera.global_position) - (Global.viewport_tree.size/2)
	tile_set = tile_map.local_to_map(corner_spot)
	for x in range(-8, Global.viewport_x_tile+8):
		for y in range(-8, Global.viewport_y_tile+8):
			var place_tile = tile_set + Vector2i(x,y)
			Global.show_tiles.append(place_tile)
			if x < -vel_x or x > Global.viewport_x_tile+vel_x or y < -vel_y or y > Global.viewport_y_tile+vel_y:
				pass #if objects_id.has(place_tile): objects_id[place_tile].hide()
				#tile_map.set_cell(place_tile, -1)
			#elif blocks.has(place_tile) and !$tilemap.get_cell_tile_data(place_tile):
			else: pass #if objects_id.has(place_tile): objects_id[place_tile].show()
				#tile_map.set_cell(place_tile, 1, tile_array[place_tile])

func tile_to_chunk(cur_tile : Vector2i):
	return cur_tile/chunk_size

func pos_to_chunk(cur_pos : Vector2):
	var _pos : Vector2i = tile_map.local_to_map(cur_pos)
	return _pos/chunk_size

func _create_cell_new():
	while true:
		if Global.cur_scene == "outside":
			camera.zoom = Vector2(1,1)
			corner_spot = (cam_global) - (Global.viewport_tree.size/2) + Vector2(-16, -16)
			var tile_chunk = pos_to_chunk(corner_spot)
			var temp_chunk = generated_chunks.duplicate()
			for x in range(0, Global.viewport_x_chunk):
				for y in range(0, Global.viewport_y_chunk):
					var place_tile = tile_chunk + Vector2i(x,y)
					if !generated_chunks.has(place_tile):
						for _tile in chunks[place_tile]: tile_map.set_cell(_tile[0], 1, _tile[1])
						for _obj in chunks_obj[place_tile]: _obj.call_deferred("show")
						generated_chunks.append(place_tile)
					temp_chunk.erase(place_tile)
			for _chunk in temp_chunk:
				for _tile in chunks[_chunk]: tile_map.set_cell(_tile[0], -1)
				for _obj in chunks_obj[_chunk]: _obj.call_deferred("hide")
				generated_chunks.erase(_chunk)
				
		elif Global.changing_scene and Global.cur_scene == "interior":
			Global.changing_scene = false
			erase_all_chunks()
			player.position = Vector2(0,0)
			var tiles_interior = generate_interior[Global.cur_interior]
			Global.cur_interior_size = tiles_interior.size()
			cam_middle = tile_map.map_to_local(tiles_interior[int(Global.cur_interior_size-1)][0])/2
			camera.zoom = Vector2(1,1)/(1+(log(Global.cur_interior_size)*0.1))
			print(cam_middle)
			for _tile in tiles_interior:
				tile_map.set_cell(_tile[0], 1, _tile[2])
				
		#if temp_chunk.size() > 0: print(temp_chunk.size())
		await get_tree().process_frame
		
func erase_all_chunks():
	for _chunk in generated_chunks:
		for _tile in chunks[_chunk]: tile_map.set_cell(_tile[0], -1)
		for _obj in chunks_obj[_chunk]: _obj.call_deferred("hide")
	generated_chunks.clear()
		
func is_in_water():
	var pos_p = tile_map.local_to_map(player.position)
	if blocks.has(pos_p) and blocks[pos_p] == "water":
		return true
	for i in range(4):
		pos_p = tile_map.local_to_map(player.position+Vector2(i%2*10-5, floor(float(i)/2)*10-5))
		if blocks.has(pos_p) and blocks[pos_p] == "water":
			return true
	return false
		
func _physics_process(delta: float) -> void:
	var _is_in_water = is_in_water()
	
	player.velocity += speed * delta * Vector2(float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left")), float(Input.is_action_pressed("down")) - float(Input.is_action_pressed("up"))).normalized()
	player.position = Vector2(clamp(player.position.x, -boundary_player.x, boundary_player.x), clamp(player.position.y, -boundary_player.y, boundary_player.y))
	if _is_in_water: player.velocity *= pow(0.4, delta*60)
	else: player.velocity *= pow(0.85, delta*60)
	
	camera.position += (player.global_position - camera.position) * 30 * delta
	
	if Global.cur_scene == "outside": camera.position = Vector2(clamp(camera.position.x, -boundary.x, boundary.x), clamp(camera.position.y, -boundary.y, boundary.y))
	else: camera.position = cam_middle
	Global.cam_coords = camera.position
	cam_global = camera.global_position
	
	if Input.is_action_just_pressed("ui_accept"):
		Global.spawn_new_item(player.position + Vector2(15,0), pos_to_chunk(player.position + Vector2(15,0)), "Test", 1.5)
		
	if Input.is_action_just_pressed("right_click"):
		pass
		
		#print(Global.player_chunk)
		#print(pos_to_chunk(corner_spot))
		#print(chunks_obj[Global.player_chunk].size())
		#print(chunks_obj[Global.player_chunk])
		#dialogue.add_text("Kami mendapatkan info dari beberapa orang bahwa stok di kota [wave]GURT[/wave] telah diisi kembali.", 20, "Radio") #[wave amp=15 freq=5]
		#dialogue.add_text("[tornado radius=1.5 freq=3]Semoga Beruntung!", 15, "Radio") #[wave amp=15 freq=8]

	Global.player_tile = tile_map.local_to_map(player.position)
	Global.player_chunk = pos_to_chunk(player.position)
	#print(objects_id.get(tile_map.local_to_map(player.position)))
	#_create_cell()
