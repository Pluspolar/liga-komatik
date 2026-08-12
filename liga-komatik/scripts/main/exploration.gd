extends Node2D

@export var boundary_x : int = 800
@export var map_detail : int = 1 #from 256, higher value better
@export var speed : float = 1000

@onready var boundary_y : int = int(float(boundary_x)/16*9)
@onready var width : int = boundary_x
@onready var height : int = boundary_y
@onready var width_half : int = int(round(float(width)/2))
@onready var height_half : int = int(round(float(height)/2))
@onready var interior_tile := Vector2i(boundary_x, boundary_y)+Vector2i(200,200)
@onready var interior_pos : Vector2

@onready var player := $Ysort/player
@onready var ysort := $Ysort
@onready var camera := $cam
@onready var dialogue := $UI/dialogue
@onready var tile_map := $tilemap
@onready var tilemap_wall := $Ysort/tilemap_wall
@onready var mini_map_root := $UI/minimap
@onready var mini_map := $UI/minimap/mini_map
@onready var mini_map_explore := $UI/minimap/mini_map_explore
@onready var backpack := $UI/backpack
@onready var hand_interact := $UI/interaction/hand
@onready var fog := $Ysort/player/fog
@onready var fog_texture := $darker_area/canvas_fog/fog_texture
@onready var darker_area := $darker_area
@onready var _central_inventory := $UI/central_inventory
@onready var _cooking_inv_scene := $UI/cooking_inventory
@onready var _customer_scene := $pelanggan
@onready var _cooking_scene := $Cooking
#@onready var _cooking_scene := $Cooking

var noise = FastNoiseLite.new()
var corner_spot
var thread_1 : Thread
var cam_global : Vector2
var int_player_magnitude : int

@onready var map_size: Vector2 = Vector2(256, 144) * map_detail

var biome = {}
var destruction = {}
var altitude = {}
var moisture = {}
var temperature = {}
var urban = {}
var city = {}
var road = {}

@onready var generated_interior = Global.generated_interior
@onready var gen_wall_interior = Global.gen_wall_interior
@onready var gen_obj_interior = Global.gen_obj_interior

var blocks = {}
var tile_array = {}
var generated_chunks = []
var cur_chunk : Vector2i
var cam_middle : Vector2 = Vector2(0,0)

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
var walls_data := {}
var interior_data = {} #id, tiles, [x_size, y_size]

var tiles_color = {
	"dirt" : Color8(104, 61, 43),
	"sand" : Color8(209, 196, 158),
	"water" : Color8(94, 125, 182),
	"grass" : Color8(20, 93, 15),
	"stone" : Color(0.35, 0.35, 0.35),
	"asphalt" : Color(0.25, 0.25, 0.25),
	"gravel" : Color(0.3, 0.3, 0.3),
}

var walls_color = {
	"crate" : Color8(104, 61, 43)
}

func rand_tiles_data():
	tiles_data = {
	"dirt" : Vector2i(randi_range(0,1), randi_range(0,1))*2,
	"sand" : Vector2i(randi_range(2,3), randi_range(0,1))*2,
	"water" : Vector2i(8,0),
	"grass" : Vector2i(11,1),
	"stone" : Vector2i(0,4),
	"asphalt" : Vector2i(4,4),
	"gravel" : Vector2i(17,1),
	}

	#tiles_data = {
	#"dirt" : Vector2i(randi_range(0,1), randi_range(0,1))*2,
	#"sand" : Vector2i(randi_range(2,3), randi_range(0,1))*2,
	#"water" : Vector2i(4,0),
	#"grass" : Vector2i(randi_range(6,7), randi_range(0,1)),
	#"stone" : Vector2i(randi_range(0,1), randi_range(2,3)),
	#"asphalt" : Vector2i(2,2),
	#"gravel" : Vector2i(4,2),
	#}
func rand_walls_data():
	walls_data = {
		"crate" : Vector2i(0, 0)
	}

var biomes_data := {
	"plains" : {"grass" : 1, "dirt" : 0},
	"beach" : {"sand" : 1},
	"ocean" : {"water" : 1},
	"eucalyptus" : {"grass" : 0.05, "dirt" : 0.95},
	"urban" : {"stone" : 0.998, "dirt" : 0.002},
	"city" : {"asphalt" : 1},
	"city_transition" : {"asphalt" : 1},
	"city_road" : {"gravel" : 1},
}

var biomes_wall_data := {
	"plains" : {},
	"beach" : {},
	"ocean" : {},
	"eucalyptus" : {},
	"urban" : {},
	"city" : {},
	"city_transition" : {"crate" : 1},
	"city_road" : {},
}

var objects_data := {
	"plains" : {"tree" : 0.025, "abandoned_house" : 0.0012},
	"beach" : {},
	"ocean" : {},
	"eucalyptus" : {"tree" : 0.01},
	"urban" : {},
	"city" : {"abandoned_apartment" : 0.01},
	"city_transition" : {},
	"city_road" : {},
}

var objects := { #[x_size, y_vertical_size, how much free space under "y"], scene
	"tree" : [[1,1,0], null, preload("res://scenes/structures/tree.tscn")],
	"abandoned_house" : [[3,1,0], "1_aband_house", preload("res://scenes/structures/abandoned_house.tscn")],
	"abandoned_apartment" : [[3,1,0], "1_aband_apart", preload("res://scenes/structures/abandoned_apartment.tscn")]
}

func rand_interior_data():
	interior_data = {
	"1_aband_house" : [0.2, [randi_range(10,20), randi_range(10,20)], {"stone" : 0.9, "dirt" : 0.1}, {"crate" : 1}, 0.125, {"can" : 0.5, "mie": 0.5}], 
	"1_aband_apart" : [0.1, [randi_range(20,35), randi_range(20,35)], {"stone" : 0.9, "dirt" : 0.1}, {"crate" : 1}, 0.06, {"can" : 0.25, "belalang" : 0.1, "kornet" : 0.05, "worm" : 0.2, "udang" : 0.4}]
} #room_abundance, [x_size, y_size], tiles, chance_item_per_tile, item_list #old: id, [x_size, y_size], tiles, chance_item_per_tile, item_loot_table

var objects_pos := {}
var new_minimap_image : Image = Image.create(512, 288, false, Image.FORMAT_RGB8)
var minimap_image : Image = Image.create(512, 288, false, Image.FORMAT_RGB8)
var minimap_img_explore : Image = Image.create(512, 288, false, Image.FORMAT_RGB8)

@onready var chunk_size = Global.chunk_size
@onready var chunks = Global.chunks
@onready var chunks_wall = Global.chunks_wall
@onready var chunks_obj = Global.chunks_obj
@onready var astargrid : AStarGrid2D = AStarGrid2D.new()

func _ready_rand():
	rand_tiles_data()
	rand_walls_data()
	rand_interior_data()

func _ready() -> void:
	_ready_rand()
	minimap_img_explore.fill(Color.BLACK)
	interior_pos = tile_map.map_to_local(interior_tile)
	thread_1 = Thread.new()
	altitude = generate_noise(0.03, 3, "perlin", 1, 0.2)
	moisture = generate_noise(0.03, 3, "value_cubic")
	temperature = generate_noise(0.025, 3, "simplex_smooth")
	#urban = generate_noise(0.006, 3, "simplex", 1, 0.36)
	#urban = generate_noise(0.006, 3, "simplex", 1, 0.45)
	urban = generate_noise(0.0045, 3, "simplex", 1, 0.5)
	city = generate_noise(0.003, 4, "cellular", 1, 0.3)
	road = generate_noise(0.02, 2, "perlin", 1, 0)#, false, "sign")
	#road = generate_noise(0.02, 2, "value_cubic", 1, 0)#, false, "sign")
	#road = generate_noise(0.015, 2, "perlin", 1, 0.0, false, "sign")
	#road = generate_noise(0.015, 2, "cellular", 1, 0.55, false, "sign")
	#road = generate_noise(0.005, 2, "cellular", 1, 0.6, false, "sign")
	#road = generate_noise(0.0125, 2, "cellular", 1, 0.6, false, "sign")
	#road = generate_noise(0.015, 2, "cellular", 1, 0.5, false, "sign")
	destruction = generate_noise(0.003, 3, "cellular", 1, 0.2)
	_set_tile()
	_player_minimap()
	
	thread_1.start(_load_scene)
	
func _exit_tree() -> void:
	thread_1.wait_to_finish()

func tile_to_chunk(cur_tile : Vector2i):
	return Vector2i(Vector2(cur_tile)/chunk_size)

func pos_to_chunk(cur_pos : Vector2):
	var _pos : Vector2i = tile_map.local_to_map(cur_pos)
	return Vector2i(Vector2(_pos)/chunk_size)

func generate_noise(freq : float, oct : int, noise_type: String, multiplier: float = 1, additive: float = 0, is_abs : bool = false, special_inst : String = ""):
	noise.seed = randi()
	noise.frequency = freq
	noise.fractal_octaves = oct
	noise.noise_type = noisetype[noise_type.to_lower()]
	var grid_noise = {}
	if !is_abs:
		for x in range(-width_half, width_half):
			for y in range(-height_half, height_half):
				var cur_val = multiplier*(noise.get_noise_2d(x, y)+additive)
				#if special_inst == "sign": 
				#	if cur_val > 0: cur_val = 1
				grid_noise[Vector2i(x,y)] = cur_val
		return grid_noise
	else:
		for x in range(-width_half, width_half):
			for y in range(-height_half, height_half):
				grid_noise[Vector2i(x,y)] = multiplier*(abs(noise.get_noise_2d(x, y))+additive)
		return grid_noise
		
func setup_astargrid():
	astargrid.region = Rect2i(-width_half-1, -height_half-1, width_half*2+2, height_half*2+2)
	astargrid.cell_size = Vector2i(16,16)
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astargrid.update()

func _set_tile():
	minimap_image.fill(Color.BLACK)
	setup_astargrid()
	
	for x in range(-width_half-1, width_half+1):
		for y in range(-height_half-1, height_half+1):
			var pos = Vector2i(x, y)
			if pos.x == (-width_half-1) or pos.y == (-height_half-1) or pos.x == width_half or pos.y == height_half:
				astargrid.set_point_solid(pos, true)
				continue
			
			var alt = altitude[pos]
			var temp = temperature[pos]
			var _urban = urban[pos]
			var _city = city[pos]
			var _road = road[pos]
			cur_chunk = tile_to_chunk(pos)
			
			if !chunks.has(cur_chunk): chunks[cur_chunk] = []
			if !chunks_wall.has(cur_chunk): chunks_wall[cur_chunk] = []
			if !chunks_obj.has(cur_chunk): chunks_obj[cur_chunk] = []
			
			if _urban > 0:
				if _road >= -0.08 and _road <= 0: place_tile_biome(pos, "city_road")
				else:
					if _city < -0.3: 
						if _urban <= 0.07: place_tile_biome(pos, "eucalyptus")
						elif _city > -0.31 and _city <= -0.3: place_tile_biome(pos, "city_transition")
						
						#elif _road >= 0 and _road < 0.09: place_tile_biome(pos, "city_road")
						else: place_tile_biome(pos, "city")
						
					elif alt < -0.25: place_tile_biome(pos, "ocean")
					elif alt >= -0.25 and alt < -0.18 : place_tile_biome(pos, "eucalyptus")
					elif _urban <= 0.07: place_tile_biome(pos, "eucalyptus")
					else: place_tile_biome(pos, "urban")
			else: 
				if alt < -0.25: place_tile_biome(pos, "ocean")
				elif alt >= -0.25 and alt < -0.2 : place_tile_biome(pos, "beach")
				elif alt >= -0.2 and alt < -0.15 : place_tile_biome(pos, "eucalyptus")
				else:
					if temp > 0.3: place_tile_biome(pos, "eucalyptus")
					else: place_tile_biome(pos, "plains")
					
	mini_map.texture = ImageTexture.create_from_image(minimap_image)
	new_minimap_image = minimap_image.duplicate()
		
func _player_minimap():
	var new_sprite = Sprite2D.new()
	new_sprite.texture = preload("res://textures/sprites/UI/map_player_2.png")
	new_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	new_sprite.scale = Vector2(1,1)*0.5
	player.map_sprite = new_sprite
	mini_map.add_child(new_sprite)
	
func _update_player_minimap():
	if Global.cur_scene == "outside" and !Global.changing_scene: 
		player.map_sprite.position = player.global_position/(16*float(boundary_x)/512)+Vector2(256, 144)
		map_unlock_section()
	
func map_unlock_section():
	var pixel_change : bool = false
	for x in range(-12, 13):
		for y in range(-12, 13):
			var map_player = player.map_sprite.position+Vector2(x,y)
			if map_player.x > 512 or map_player.x < 0 or map_player.y > 288 or map_player.y < 0: continue
			var new_minimap_pixel = new_minimap_image.get_pixelv(map_player)
			
			if (abs(x) <= 8 and abs(y) <= 8) and minimap_image.get_pixelv(map_player) != new_minimap_pixel:
				minimap_image.set_pixelv(map_player, new_minimap_pixel)
				if !pixel_change: pixel_change = true
			
			if (abs(x) >= 11 or abs(y) >= 11) and minimap_img_explore.get_pixelv(map_player).r < 0.3: 
				minimap_img_explore.set_pixelv(map_player, Color(0.3,0,0,1))
			elif (abs(x) >= 8 or abs(y) >= 8) and minimap_img_explore.get_pixelv(map_player).r < 0.5: 
				minimap_img_explore.set_pixelv(map_player, Color(0.5,0,0,1))
			else: 
				minimap_img_explore.set_pixelv(map_player, Color(1,0,0,1))
					
	mini_map_explore.texture = ImageTexture.create_from_image(minimap_img_explore)
	if pixel_change: mini_map.texture = ImageTexture.create_from_image(minimap_image)

func place_tile_biome(pos : Vector2i, _biome: String):
	rand_tiles_data()
	biome[pos] = _biome
	var tile = rng_calculator(biomes_data, _biome)
	var minimap_pos : Vector2i = pos + Vector2i(width_half, height_half)
	minimap_pos.x = int(float(minimap_pos.x)*512/width)
	minimap_pos.y = int(float(minimap_pos.y)*288/height)
	minimap_image.set_pixel(minimap_pos.x, minimap_pos.y, tiles_color[tile])
	blocks[pos] = tile
	if tile == "water": astargrid.set_point_weight_scale(pos, 8.0)
	chunks[cur_chunk].append([pos, tiles_data[tile]])
	place_wall_biome(pos, _biome, minimap_pos)
	create_object(pos, _biome)
	
func place_wall_biome(pos : Vector2i, _biome: String, minimap_pos : Vector2i) -> void:
	rand_tiles_data()
	var tile = rng_calculator(biomes_wall_data, _biome)
	
	if tile == null or objects_pos.get(pos): return
	
	minimap_image.set_pixelv(minimap_pos, walls_color[tile])
	objects_pos[pos] = tile
	astargrid.set_point_solid(pos, true)
	chunks_wall[cur_chunk].append([pos, walls_data[tile]])
	
func create_object(pos, _biome):
	var random_obj = rng_calculator(objects_data, _biome)
	if random_obj != null:
		if check_accessibility(pos, random_obj):
			tile_to_map(pos, random_obj)
	
func check_accessibility(pos, random_obj):
	var temp_acc_coords = []
	var obj_size = objects[str(random_obj)][0]
	var y_free = obj_size[2]
	var middle = int(obj_size[0]/2)
	for x in range(obj_size[0]):
		for y in range(obj_size[1]+y_free):
			var new_pos = pos+Vector2i(x-middle,-y+y_free)
			if objects_pos.get(new_pos):
				return false
			temp_acc_coords.append(new_pos)
	for coords in temp_acc_coords: 
		astargrid.set_point_solid(coords, true)
		objects_pos[coords] = random_obj
	return true
	
func tile_to_map(pos, random_obj):
	rand_interior_data()
	var obj_data = objects[str(random_obj)]
	var obj = obj_data[2].instantiate()
	obj.position = tile_map.map_to_local(pos)
	var obj_behav = obj_data[1]
	chunks_obj[cur_chunk].append(obj)
	ysort.add_child(obj)
	if obj_behav != null:
		gen_obj_interior[obj] = []
		gen_wall_interior[obj] = []
		generated_interior[obj] = create_interior(interior_data[obj_behav], obj)
		
func create_interior(cur_interior_data, obj):
	var room_abundance = cur_interior_data[0]
	room_abundance = randf_range(room_abundance*0.85, room_abundance*1.15)
	var room_size = cur_interior_data[1]
	var floor_palette = cur_interior_data[2]
	var wall_palette = cur_interior_data[3]
	var chance_item_spawn = cur_interior_data[4]
	var item_loot_table = cur_interior_data[5]
	
	Global.cur_scene = "interior"
	Global.cur_interior = obj
	var cur_interior = {}
	var interior_sorted = []
	var room_availability = []
	var x_range = room_size[0] - 1
	var y_range = room_size[1] - 1
	var middle : Vector2i = Vector2i(Vector2(x_range, y_range)/2)
	var tile
	var room_amount = 0
	var cur_wall : Dictionary
	var total_wall := {}
	var max_room = int((x_range+1)*(y_range+1)/55*(randf_range(0.9, 1.25)))

	for x in range(0, x_range+1):
		for y in range(0, y_range+1):
			var tile_pos = Vector2i(x,y)
			var _pos = tile_pos+interior_tile
			interior_sorted.append(_pos)
			
			if cur_interior.has(_pos): continue
			
			if room_amount < max_room and (x == 0 or x == x_range or y == 0 or y == y_range) and randf_range(0,1) <= room_abundance: 
				cur_wall = create_room(total_wall, room_availability, middle, cur_interior, floor_palette, wall_palette, chance_item_spawn, item_loot_table, tile_pos, _pos, x_range, y_range)
				for i in cur_wall: total_wall[i] = cur_wall[i]
				room_amount += 1
			else:
				rand_tiles_data()
				tile = rng_calculator(floor_palette)
				cur_interior[_pos] = [_pos, tile, tiles_data[tile]]
	
	var new_sorted = []
	
	for i in interior_sorted:
		new_sorted.append(cur_interior[i])
	
	var first_pos = tile_map.map_to_local(new_sorted[0][0])
	var last_pos = tile_map.map_to_local(new_sorted[-1][0])
	var player_cur_tile = tile_map.local_to_map(Vector2((last_pos.x - first_pos.x)/2 + interior_pos.x, last_pos.y-16))
		
	for x in range(-2,2):
		for y in range(-1,2):
			var n_p_t = player_cur_tile+Vector2i(x,y) #new_player_tile
			if !cur_interior.has(n_p_t): continue
			
			rand_tiles_data()
			if y == 1 and (x == -1 or x == 0): tile = "water"
			else: tile = rng_calculator(floor_palette)
			var find_new_sort = new_sorted.find(cur_interior[n_p_t])
			
			new_sorted.remove_at(find_new_sort)
			total_wall.erase(n_p_t)
			new_sorted.insert(find_new_sort, [n_p_t, tile, tiles_data[tile]])
		
	Global.cur_scene = "outside"
		
	for i in total_wall:
		gen_wall_interior[obj].append(total_wall[i])
		
	return new_sorted

func create_room(total_wall, room_availability, middle, cur_interior, floor_palette, wall_palette, chance_item_spawn, item_loot_table, tile_pos, _pos, x_range, y_range) -> Dictionary:
	var tile
	var random_size = int(min(x_range+1, y_range+1)/2.5)
	var room_size : Vector2i = Vector2i(Vector2(randi_range(int(random_size) , int(random_size*1.25)), randi_range(int(random_size) , int(random_size*1.25)))/2)
	var vector_angle = (round(Vector2(tile_pos).angle_to_point(middle)*2/PI))/2*PI
	var door_normal = Vector2i(int(cos(vector_angle)), int(sin(vector_angle)))
	var door = Vector2i(door_normal.x*room_size.x, door_normal.y*room_size.y)+_pos
	var cur_wall = {}
	var door_normal_transpose = Vector2i(door_normal.y, door_normal.x)
	
	for x in range(-room_size.x, room_size.x+1): #create invisible border around with -1 and +2 (1+1)
		for y in range(-room_size.y, room_size.y+1):
			var cur_pos = Vector2i(x,y)
			var n_t_p = tile_pos+cur_pos #new_tile_pos
			var local_pos = _pos+cur_pos
			if room_availability.has(local_pos) or n_t_p.x > x_range or n_t_p.x < 0 or n_t_p.y > y_range or n_t_p.y < 0: continue
			
			rand_tiles_data()
			
			#if x == -room_size.x or y == -room_size.y or x == room_size.x or y == room_size.y:
			if (abs(x) == room_size.x or abs(y) == room_size.y) and abs(x) < room_size.x+1 and abs(y) < room_size.y+1:
				tile = "grass"
				var wall_tile = rng_calculator(wall_palette)
				cur_wall[local_pos] = [local_pos, wall_tile, walls_data[wall_tile]]
			else: 
				if randf_range(0,1) <= chance_item_spawn: 
					var rand_position = tile_map.map_to_local(local_pos)+Vector2(randf_range(-6, 6), randf_range(-6, 6))
					Global.spawn_new_item(rand_position, Vector2i(0,0), rng_calculator(item_loot_table))#, 0.5)
				tile = rng_calculator(floor_palette)
			
			room_availability.append(local_pos)
			cur_interior[local_pos] = [local_pos, tile, tiles_data[tile]]
		
	var not_found_air = true
	var index_door_normal = 0
	var index_transpose_normal = 0
	while not_found_air:
		var cur_pos_door = door+(door_normal*index_door_normal)+(door_normal_transpose*index_transpose_normal)
		if (index_door_normal <= 1 or total_wall.has(cur_pos_door)) and index_door_normal <= 3:
			rand_tiles_data()
			tile = rng_calculator(floor_palette)
			if !room_availability.has(cur_pos_door): room_availability.append(cur_pos_door)
			if total_wall.has(cur_pos_door): total_wall.erase(cur_pos_door)
			if cur_wall.has(cur_pos_door): cur_wall.erase(cur_pos_door)
			cur_interior[cur_pos_door] = [cur_pos_door, tile, tiles_data[tile]]
			index_door_normal += 1
		elif index_transpose_normal >= 1:  not_found_air = false 
		else:
			index_transpose_normal += 1
			index_door_normal = 0
			
	return cur_wall
	
func rng_calculator(data, _place : String = ""):
	var cur_place
	if _place == "": cur_place = data
	else: cur_place = data[_place]
	var chance = 0
	var rand_num = randf_range(0, 1)
	for cur_data in cur_place:
		chance += cur_place[cur_data]
		if rand_num <= chance:
			return cur_data

func change_to_outside():
	Global.changing_scene = false
	camera.zoom = Vector2(1,1)
	player.position = Global.player_last_loc
	camera.position = player.position
	camera.position = Vector2(clamp(camera.position.x, -boundary.x, boundary.x), clamp(camera.position.y, -boundary.y, boundary.y))
	var tiles_interior = generated_interior[Global.cur_interior]
	var obj_interior = gen_obj_interior[Global.cur_interior]
	var walls_interior = gen_wall_interior[Global.cur_interior]
	for _tile in tiles_interior: tile_map.set_cell(_tile[0], -1)
	for _wall in walls_interior: tilemap_wall.set_cell(_wall[0], -1)
	for _obj in obj_interior: 
		if _obj != null:
			_obj.col_shape.call_deferred("set_disabled", true)
			_obj.hide()
			
	fog_texture.call_deferred("hide")
	fog.texture_scale = 30
	fog.shadow_item_cull_mask = 0

func update_player_location():
	return player.position

func _load_scene():
	while true:
		if Global.changing_scene:
			_central_inventory.hide()
			_cooking_inv_scene.hide()
			_customer_scene.hide()
			_cooking_scene.hide()
			#_cooking_scene.hide()
			if Global.is_exploring: 
				darker_area.show()
			else:
				camera.position = Vector2(192,108)
				if Global.cur_scene == "central_inventory": 
					_central_inventory.show()
					_cooking_inv_scene.show()
				elif Global.cur_scene == "customer":
					_customer_scene.show()
					_customer_scene._start()
					#_customer_scene.get_child(2)._start()
				elif Global.cur_scene == "cooking":
					_cooking_scene.show()
				hand_interact.hide()
				darker_area.hide()
		
		if Global.changing_scene and Global.cur_scene == "outside":
			change_to_outside()
		
		if Global.cur_scene == "outside":
			corner_spot = (cam_global) - (Global.viewport_tree.size/2) + Vector2(-16, -16)
			var tile_chunk = pos_to_chunk(corner_spot)
			var temp_chunk = generated_chunks.duplicate()
			
			for x in range(0, Global.viewport_x_chunk):
				for y in range(0, Global.viewport_y_chunk):
					var place_tile = tile_chunk + Vector2i(x,y)
					if !generated_chunks.has(place_tile) and chunks.has(place_tile):
						for _tile in chunks[place_tile]: tile_map.set_cell(_tile[0], 0, _tile[1])
						for _wall in chunks_wall[place_tile]: tilemap_wall.set_cell(_wall[0], 1, _wall[1])
						for _obj in chunks_obj[place_tile]: _obj.call_deferred("show")
						generated_chunks.append(place_tile)
					elif generated_chunks.has(place_tile): temp_chunk.erase(place_tile)
					
			for _chunk in temp_chunk:
				for _tile in chunks[_chunk]: tile_map.set_cell(_tile[0], -1)
				for _wall in chunks_wall[_chunk]: tilemap_wall.set_cell(_wall[0], -1)
				for _obj in chunks_obj[_chunk]: _obj.call_deferred("hide")
				generated_chunks.erase(_chunk)
				
		elif Global.cur_scene == "interior" and Global.changing_scene and Global.cur_interior != null:
			erase_all_chunks()
			fog_texture.call_deferred("show")
			fog.texture_scale = 4
			fog.shadow_item_cull_mask = 3
			
			Global.changing_scene = false
			
			var tiles_interior = generated_interior[Global.cur_interior]
			var walls_interior = gen_wall_interior[Global.cur_interior]
			var obj_interior = gen_obj_interior[Global.cur_interior]
			Global.cur_interior_size = tiles_interior.size()
			
			var first_pos = tile_map.map_to_local(tiles_interior[0][0])
			var last_pos = tile_map.map_to_local(tiles_interior[Global.cur_interior_size-1][0])
			var combine_pos = last_pos-first_pos
			var camera_equation = pow(1+(max(combine_pos.x, combine_pos.y)*0.0015),1.75)
			
			cam_middle = (last_pos - first_pos)/2 + interior_pos
			camera.zoom = Vector2(1,1)/camera_equation
			Global.player_last_loc = player.position
			player.position = Vector2((last_pos.x - first_pos.x)/2 + interior_pos.x, last_pos.y-8) 
			Global.player_interior_out = player.position+Vector2(0,10)
			
			for _tile in tiles_interior: tile_map.set_cell(_tile[0], 0, _tile[2])
			for _wall in walls_interior: tilemap_wall.set_cell(_wall[0], 1, _wall[2])
			for _obj in obj_interior: 
				if _obj != null:
					_obj.col_shape.call_deferred("set_disabled", false)
					_obj.show()
			
		if not Global.is_exploring:
			erase_all_chunks()
			Global.changing_scene = false
		await get_tree().process_frame
		
func erase_all_chunks():
	for _chunk in generated_chunks:
		for _tile in chunks[_chunk]: tile_map.set_cell(_tile[0], -1)
		for _wall in chunks_wall[_chunk]: tilemap_wall.set_cell(_wall[0], -1)
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
		
func _exploring(delta: float) -> void:
	var _is_in_water = is_in_water()
	
	player.velocity += speed * delta * Vector2(float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left")), float(Input.is_action_pressed("down")) - float(Input.is_action_pressed("up"))).normalized()
	
	if _is_in_water: player.velocity *= pow(0.4, delta*60)
	else: player.velocity *= pow(0.85, delta*60)
	
	camera.position += (player.global_position - camera.position) * 10 * delta
	
	if Global.cur_scene == "outside": 
		camera.position = Vector2(clamp(camera.position.x, -boundary.x, boundary.x), clamp(camera.position.y, -boundary.y, boundary.y))
	else: 
		camera.position = cam_middle
	
	Global.cam_coords = camera.position
	cam_global = camera.global_position
		
	if Input.is_action_just_pressed("right_click"):
		pass

		
		#new_minimap_image.fill(Color.WHITE)
		#pass
		#dialogue.add_text("Kami mendapatkan info dari beberapa orang bahwa stok di kota [wave]GURT[/wave] telah diisi kembali.", 20, "Radio") #[wave amp=15 freq=5]
		#dialogue.add_text("[tornado radius=1.5 freq=3]Semoga Beruntung!", 15, "Radio") #[wave amp=15 freq=8]
	
	Global.player_tile = tile_map.local_to_map(player.position)
	Global.player_chunk = pos_to_chunk(player.position)
	
	player_move_and_slide()
	
	var player_local = -player.make_canvas_position_local(Vector2.ZERO)*camera.zoom
	fog_texture.material.set_shader_parameter("player_pos", (player_local/get_viewport_rect().size))
	
	_update_player_minimap()
	check_interaction()
		
func find_path(cur_pos):
	var point_solid_y = -1
	if astargrid.is_point_solid(Global.player_tile):
		point_solid_y += 1
		astargrid.set_point_solid(Global.player_tile, false)  
		if !astargrid.is_point_solid(Global.player_tile+Vector2i(0,-1)):
			point_solid_y += 1
			astargrid.set_point_solid(Global.player_tile+Vector2i(0,-1), true)  
		
	var path_taken = astargrid.get_id_path(tile_map.local_to_map(cur_pos), Global.player_tile)
		
	if point_solid_y >= 0: 
		for i in range(point_solid_y+1):
			if i == 0:
				astargrid.set_point_solid(Global.player_tile, true)
			if i == 1:
				astargrid.set_point_solid(Global.player_tile+Vector2i(0,-1), false)
		
		for i in path_taken:
			tile_map.set_cell(i, 0, tiles_data["grass"])
		
func player_move_and_slide():
	var player_clamp
	var player_offset
	var tiles_interior
	var first_pos
	var last_pos
	
	var old_pos : Vector2 = player.position
	if Global.cur_scene == "outside": player.position = Vector2(clamp(player.position.x, -boundary_player.x, boundary_player.x), clamp(player.position.y, -boundary_player.y, boundary_player.y))
	elif Global.cur_scene == "interior" and !Global.changing_scene: 
		player_offset = Vector2(2,2)
		tiles_interior = generated_interior[Global.cur_interior]
		first_pos = tile_map.map_to_local(tiles_interior[0][0]) - player_offset
		last_pos = tile_map.map_to_local(tiles_interior[tiles_interior.size()-1][0]) + player_offset
		
		player.position = Vector2(clamp(player.position.x, first_pos.x, last_pos.x), clamp(player.position.y, first_pos.y, last_pos.y))
	
	if old_pos.x != player.position.x: player.velocity.x = 0
	if old_pos.y != player.position.y: player.velocity.y = 0

	player.move_and_slide()

	#if Global.cur_scene == "outside": player.position = Vector2(clamp(player.position.x, -boundary_player.x, boundary_player.x), clamp(player.position.y, -boundary_player.y, boundary_player.y))
	#elif Global.cur_scene == "interior" and !Global.changing_scene: player.position = Vector2(clamp(player.position.x, first_pos.x, last_pos.x), clamp(player.position.y, first_pos.y, last_pos.y))
		
func _physics_process(delta: float) -> void:
	if Global.is_exploring: _exploring(delta)
	elif Global.cur_scene == "central_inventory": camera_follow_mouse(delta)
	elif Global.cur_scene == "customer": camera.position = Global.viewport_tree.size/2
	elif Global.cur_scene == "cooking": camera.position = Global.cur_cam_cooking
	
func check_interaction():
	if Global.is_interacting: 
		hand_interact.show()
		hand_interact.rotation_degrees = cos(Global._timer*6.5)*6
		hand_interact.scale.x = 2+cos(Global._timer*13)*0.05
		hand_interact.scale.y = 2+sin(Global._timer*13)*0.05
	else: hand_interact.hide()

func camera_follow_mouse(delta: float) -> void:
	var mouse_viewport_pos = get_viewport().get_mouse_position()
	camera.position += (mouse_viewport_pos-camera.position) * 10 * delta
	Global.cam_coords = camera.position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		Global.spawn_new_item(Global.player_pos, Global.player_chunk, rng_calculator({"can" : 0.5, "mie" : 0.5}))
		if Global.is_opening_inventory: 
			backpack.hide()
			Global.is_opening_inventory = false
		else: 
			backpack.show()
			Global.is_opening_inventory = true
	if event.is_action_pressed("map"):
		if mini_map_root.visible: mini_map_root.hide()
		else: mini_map_root.show()
		
