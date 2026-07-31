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
@onready var mini_map_root := $UI/minimap
@onready var mini_map := $UI/minimap/mini_map
@onready var mini_map_explore := $UI/minimap/mini_map_explore
@onready var backpack := $UI/backpack
@onready var hand_interact := $UI/interaction/hand

var player_last_loc := Vector2(0,0)
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

var interior_data = {
	"1_aband_house" : [0, [10,50], {"stone" : 0.9, "dirt" : 0.1}], 
	"1_aband_apart" : [0, [20,20], {"stone" : 0.9, "dirt" : 0.1}]} #id, tiles, [x_size, y_size]

@onready var generated_interior = Global.generated_interior
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
var tiles_color = {
	"dirt" : Color8(104, 61, 43),
	"sand" : Color8(209, 196, 158),
	"water" : Color8(94, 125, 182),
	"grass" : Color8(20, 93, 15),
	"stone" : Color8(77, 77, 77)
}

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
	"tree" : [[1,1,0], null, preload("res://scenes/structures/tree.tscn")],
	"abandoned_house" : [[3,1,0], "1_aband_house", preload("res://scenes/structures/abandoned_house.tscn")],
	"abandoned_apartment" : [[3,1,0], "1_aband_apart", preload("res://scenes/structures/abandoned_apartment.tscn")]
}

var objects_pos := {}
var new_minimap_image : Image = Image.create(512, 288, false, Image.FORMAT_RGB8)
var minimap_image : Image = Image.create(512, 288, false, Image.FORMAT_RGB8)
var minimap_img_explore : Image = Image.create(512, 288, false, Image.FORMAT_RGB8)
@onready var chunk_size = Global.chunk_size
@onready var chunks = Global.chunks
@onready var chunks_obj = Global.chunks_obj

func _ready() -> void:
	minimap_img_explore.fill(Color.BLACK)
	interior_pos = tile_map.map_to_local(interior_tile)
	thread_1 = Thread.new()
	altitude = generate_noise(0.03, 3, "perlin", 1, 0.2)
	moisture = generate_noise(0.03, 3, "value_cubic")
	temperature = generate_noise(0.025, 3, "simplex_smooth")
	urban = generate_noise(0.006, 3, "simplex", 1, 0.36)
	destruction = generate_noise(0.003, 3, "cellular", 1, 0.2)
	_set_tile()
	_player_minimap()
	
	thread_1.start(_create_cell_chunk)
	
func _exit_tree() -> void:
	thread_1.wait_to_finish()

func tile_to_chunk(cur_tile : Vector2i):
	return Vector2i(Vector2(cur_tile)/chunk_size)

func pos_to_chunk(cur_pos : Vector2):
	var _pos : Vector2i = tile_map.local_to_map(cur_pos)
	return Vector2i(Vector2(_pos)/chunk_size)

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
	minimap_image.fill(Color.BLACK)
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
	var tile = random_tiles(biomes_data, _biome)
	var minimap_pos : Vector2i = pos + Vector2i(width_half, height_half)
	minimap_pos.x = int(float(minimap_pos.x)*512/width)
	minimap_pos.y = int(float(minimap_pos.y)*288/height)
	minimap_image.set_pixel(minimap_pos.x, minimap_pos.y, tiles_color[tile])
	blocks[pos] = tile
	chunks[cur_chunk].append([pos, tiles_data[tile]])
	create_object(pos, _biome)
	
func create_object(pos, _biome):
	var random_obj = random_tiles(objects_data, _biome)
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
			if objects_pos.get(pos+Vector2i(x-middle,-y+y_free)):
				return false
			temp_acc_coords.append(pos+Vector2i(x-middle,-y+y_free))
	for coords in temp_acc_coords: 
		objects_pos[coords] = random_obj
	return true
	
func tile_to_map(pos, random_obj):
	var obj_data = objects[str(random_obj)]
	var obj = obj_data[2].instantiate()
	obj.position = tile_map.map_to_local(pos)
	var obj_behav = obj_data[1]
	chunks_obj[cur_chunk].append(obj)
	ysort.add_child(obj)
	if obj_behav != null:
		gen_obj_interior[obj] = []
		generated_interior[obj] = create_interior(interior_data[obj_behav][1], interior_data[obj_behav][2], obj)
		
func create_interior(room_size, palette, obj):
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
	var max_room = int((x_range+1)*(y_range+1)/55)
	#tile = "water"
	#cur_interior[middle+interior_tile] = [middle+interior_tile, tile, tiles_data[tile]]
	for x in range(0, x_range+1):
		for y in range(0, y_range+1):
			var tile_pos = Vector2i(x,y)
			var _pos = tile_pos+interior_tile
			interior_sorted.append(_pos)
			
			if cur_interior.has(_pos): continue
			
			if room_amount < max_room and (x == 0 or x == x_range or y == 0 or y == y_range) and randf_range(0,1) <= 0.1: 
				create_room(room_availability, middle, cur_interior, palette, tile_pos, _pos, x_range, y_range)
				room_amount += 1
			else:
				rand_tiles_data()
				tile = random_tiles(palette)
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
			tile = random_tiles(palette)
			var find_new_sort = new_sorted.find(cur_interior[n_p_t])
			new_sorted.remove_at(find_new_sort)
			new_sorted.insert(find_new_sort, [n_p_t, tile, tiles_data[tile]])
		
	Global.cur_scene = "outside"
	return new_sorted

func create_room(room_availability, middle, cur_interior, palette, tile_pos, _pos, x_range, y_range):
	var tile
	var random_size = int(min(x_range+1, y_range+1)/2.5)
	var room_size : Vector2i = Vector2i(Vector2(randi_range(int(random_size) , int(random_size*1.3)), randi_range(int(random_size*0.8) , int(random_size*1.3)))/2)
	var vector_angle = (round(Vector2(tile_pos).angle_to_point(middle)*2/PI))/2*PI
	var door_normal = Vector2i(int(cos(vector_angle)), int(sin(vector_angle)))
	var door = Vector2i(door_normal.x*room_size.x, door_normal.y*room_size.y)+_pos
	#var door_normal_transpose = Vector2i(door_normal.y, door_normal.x)
	
	#var _door = [door]#, door+door_normal*2+(door_normal_transpose)]
	
	#for i in range(-1, 2):
	#	_door.append(door+door_normal+(door_normal_transpose*i))
	
	#for x in range(-room_size.x-1, room_size.x+2): #create invisible border around with -1 and +2 (1+1)
		#for y in range(-room_size.y-1, room_size.y+2):
	for x in range(-room_size.x, room_size.x+1): #create invisible border around with -1 and +2 (1+1)
		for y in range(-room_size.y, room_size.y+1):
			var cur_pos = Vector2i(x,y)
			var n_t_p = tile_pos+cur_pos #new_tile_pos
			var local_pos = _pos+cur_pos
			if n_t_p.x > x_range or n_t_p.x < 0 or n_t_p.y > y_range or n_t_p.y < 0 or room_availability.has(local_pos): continue
			
			rand_tiles_data()
			
			#if x == -room_size.x or y == -room_size.y or x == room_size.x or y == room_size.y:
			if (abs(x) == room_size.x or abs(y) == room_size.y) and abs(x) < room_size.x+1 and abs(y) < room_size.y+1:
				tile = "grass"
			else: 
				if randf_range(0,1) <= 0.1: Global.spawn_new_item(tile_map.map_to_local(local_pos)+Vector2(randf_range(-6, 6), randf_range(-6, 6)), Vector2i(0,0), "can", 1.25)
				tile = random_tiles(palette)
			
			room_availability.append(local_pos)
			cur_interior[local_pos] = [local_pos, tile, tiles_data[tile]]
		
	var not_found_air = true
	var index_door_normal = 0
	while not_found_air:
		var cur_pos_door = door+(door_normal*index_door_normal)
		if index_door_normal <= 1:
			rand_tiles_data()
			tile = random_tiles(palette)
			if !room_availability.has(cur_pos_door): room_availability.append(cur_pos_door)
			cur_interior[cur_pos_door] = [cur_pos_door, tile, tiles_data[tile]]
			index_door_normal += 1
		elif cur_interior.has(cur_pos_door):
			if cur_interior[cur_pos_door][1] == "grass":
				rand_tiles_data()
				tile = random_tiles(palette)
				if !room_availability.has(cur_pos_door): room_availability.append(cur_pos_door)
				cur_interior[cur_pos_door] = [cur_pos_door, tile, tiles_data[tile]]
				index_door_normal += 1
			else: not_found_air = false  
		else: not_found_air = false  
			
	#for i in _door:
	#	rand_tiles_data()
	#	tile = random_tiles(palette)
	#	if !room_availability.has(i): room_availability.append(i)
	#	cur_interior[i] = [i, tile, tiles_data[tile]]
	
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

func _create_cell_chunk():
	while true:
		if Global.changing_scene and Global.cur_scene == "outside":
			erase_all_chunks()
			Global.changing_scene = false
			camera.zoom = Vector2(1,1)
			player.position = player_last_loc
			camera.position = player.position
			camera.position = Vector2(clamp(camera.position.x, -boundary.x, boundary.x), clamp(camera.position.y, -boundary.y, boundary.y))
			var tiles_interior = generated_interior[Global.cur_interior]
			var obj_interior = gen_obj_interior[Global.cur_interior]
			for _tile in tiles_interior: tile_map.set_cell(_tile[0], -1)
			for _obj in obj_interior: 
				if _obj != null:
					_obj.col_shape.call_deferred("set_disabled", true)
					_obj.hide()
		
		if Global.cur_scene == "outside":
			corner_spot = (cam_global) - (Global.viewport_tree.size/2) + Vector2(-16, -16)
			var tile_chunk = pos_to_chunk(corner_spot)
			var temp_chunk = generated_chunks.duplicate()
			
			for x in range(0, Global.viewport_x_chunk):
				for y in range(0, Global.viewport_y_chunk):
					var place_tile = tile_chunk + Vector2i(x,y)
					if !generated_chunks.has(place_tile) and chunks.has(place_tile):
						for _tile in chunks[place_tile]: tile_map.set_cell(_tile[0], 1, _tile[1])
						for _obj in chunks_obj[place_tile]: _obj.call_deferred("show")
						generated_chunks.append(place_tile)
					elif generated_chunks.has(place_tile): temp_chunk.erase(place_tile)
					
			for _chunk in temp_chunk:
				for _tile in chunks[_chunk]: tile_map.set_cell(_tile[0], -1)
				for _obj in chunks_obj[_chunk]: _obj.call_deferred("hide")
				generated_chunks.erase(_chunk)
				
		elif Global.cur_scene == "interior" and Global.changing_scene and Global.cur_interior != null:
			erase_all_chunks()
			Global.changing_scene = false
			
			var tiles_interior = generated_interior[Global.cur_interior]
			var obj_interior = gen_obj_interior[Global.cur_interior]
			Global.cur_interior_size = tiles_interior.size()
			
			var first_pos = tile_map.map_to_local(tiles_interior[0][0])
			var last_pos = tile_map.map_to_local(tiles_interior[Global.cur_interior_size-1][0])
			var combine_pos = last_pos-first_pos
			var camera_equation = pow(1+(max(combine_pos.x, combine_pos.y)*0.0015),1.75)
			
			cam_middle = (last_pos - first_pos)/2 + interior_pos
			camera.zoom = Vector2(1,1)/camera_equation
			player_last_loc = player.position
			player.position = Vector2((last_pos.x - first_pos.x)/2 + interior_pos.x, last_pos.y-16) 
			Global.player_interior_out = player.position+Vector2(0,18)
			
			for _tile in tiles_interior:
				tile_map.set_cell(_tile[0], 1, _tile[2])
				
			for _obj in obj_interior: 
				if _obj != null:
					_obj.col_shape.call_deferred("set_disabled", false)
					_obj.show()
			
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
		new_minimap_image.fill(Color.WHITE)
		pass
		#dialogue.add_text("Kami mendapatkan info dari beberapa orang bahwa stok di kota [wave]GURT[/wave] telah diisi kembali.", 20, "Radio") #[wave amp=15 freq=5]
		#dialogue.add_text("[tornado radius=1.5 freq=3]Semoga Beruntung!", 15, "Radio") #[wave amp=15 freq=8]
	
	Global.player_tile = tile_map.local_to_map(player.position)
	Global.player_chunk = pos_to_chunk(player.position)
	
	player.move_and_slide()

	if Global.cur_scene == "outside": player.position = Vector2(clamp(player.position.x, -boundary_player.x, boundary_player.x), clamp(player.position.y, -boundary_player.y, boundary_player.y))
	elif Global.cur_scene == "interior" and !Global.changing_scene: 
		var player_offset = Vector2(2,2)
		var tiles_interior = generated_interior[Global.cur_interior]
		var first_pos = tile_map.map_to_local(tiles_interior[0][0]) - player_offset
		var last_pos = tile_map.map_to_local(tiles_interior[tiles_interior.size()-1][0]) + player_offset
		
		player.position = Vector2(clamp(player.position.x, first_pos.x, last_pos.x), clamp(player.position.y, first_pos.y, last_pos.y))
	
	_update_player_minimap()
	check_interaction()

func check_interaction():
	if Global.is_interacting: 
		hand_interact.show()
		hand_interact.rotation_degrees = cos(Global._timer*6.5)*6
		hand_interact.scale.x = 2+cos(Global._timer*13)*0.05
		hand_interact.scale.y = 2+sin(Global._timer*13)*0.05
	else: hand_interact.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if backpack.visible: backpack.hide()
		else: backpack.show()
	if event.is_action_pressed("map"):
		if mini_map_root.visible: mini_map_root.hide()
		else: mini_map_root.show()
