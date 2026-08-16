extends Node

@onready var viewport_tree = get_tree().root.get_visible_rect()
@onready var chunk_size : int = 16
@onready var viewport_x_tile : int = viewport_tree.size.x/16
@onready var viewport_y_tile : int = viewport_tree.size.y/16
@onready var viewport_x_chunk : int = round(float(viewport_x_tile)/chunk_size)+1
@onready var viewport_y_chunk : int = round(float(viewport_y_tile)/chunk_size)+1

var generated_interior = {}
var gen_wall_interior = {}
var gen_obj_interior = {}
var chunks = {}
var chunks_wall = {}
var chunks_obj = {}
var chunks_enemy = {}
var backpack_inventory = {}
var central_inventory = {}
var cooking_inventory = {}

var cur_cam_cooking : Vector2 = Vector2(196.0, 108.0)
var player_interior_out : Vector2 = Vector2(0,0)
var item_id : int = 0
var cam_coords : Vector2 = Vector2(0,0)
var player_last_loc : Vector2 = Vector2(0,0)
var is_mouse_dragging = false
var changing_scene = false
var is_interacting = false
var is_opening_inventory = false
var cur_interior : Object = null
var cur_interior_size : int = 0
var cur_scene : String = "outside"
var is_exploring : bool = true
var all_scenes = ["outside", "interior", "cooking", "central_inventory"]
var player_pos : Vector2 = Vector2(0,0)
var player_tile : Vector2i = Vector2i(0,0)
var player_chunk : Vector2i = Vector2i(0,0)
var _timer : float = 0
var central_item_list : Dictionary = {}
var cur_central_count_list : Array = []
var item_count_central : Object = null
var cooking_inventory_scene : Object = null
var dialogue : Object = null
var cooking_scene : Object = null
var pelanggan_scene : Object = null
var cooking_inventory_list : Array = []
var cooking_target : float = 0
var cooking_obj : Array = []
var target_nutrition : float = 0
var days_left : float = 5
var coins : int = 0
var mouse_cooldown : float = 0
var heart : Object = null
var coin_icon : Object = null
var item_put_backpack = []

var customer_done : int = 0
var item_pickup_count : int = 0
var coins_earned : int = 0
var distance_traveled : float = 0
var item_cooked : int = 0

var first_time_story : bool = true #special, first time
var skip_dialogue : bool = false
var item_list_amount : int = 0
var item_drop = preload("res://scenes/__item_drop/item_drop.tscn")
var main_menu = preload("res://scenes/main/main_menu.tscn")
var coins_drop = preload("res://scenes/UI/coins_drop.tscn")

enum state {
	READY,
	TALKING,
	END
}

var _item_nutrition : Dictionary = {
	"belalang" : [
		{0 : [0, 15], 1 : [0, 35], 2 : [0, 60], 3 : [0, 150]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],
		
	"can" : [
		{0 : [0, 15], 1 : [0, 35], 2 : [0, 60], 3 : [0, 150]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],
		
	"kornet" : [
		{0 : [0, 45], 1 : [0, 90], 2 : [0, 180], 3 : [0, 360]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],
		
	"mie" : [
		{0 : [0, 10], 1 : [0, 20], 2 : [0, 40], 3 : [0, 80]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],
		
	"rumput" : [
		{0 : [0, 5], 1 : [0, 10], 2 : [0, 20], 3 : [0, 40]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],
		
	"sarden" : [
		{0 : [0, 30], 1 : [0, 60], 2 : [0, 125], 3 : [0, 250]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],
		
	"sawdust" : [
		{0 : [0, 5], 1 : [0, 10], 2 : [0, 20], 3 : [0, 40]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],
		
	"sosis" : [
		{0 : [0, 20], 1 : [0, 40], 2 : [0, 80], 3 : [0, 160]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],

	"ubi" : [
		{0 : [0, 10], 1 : [0, 20], 2 : [0, 40], 3 : [0, 80]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],

	"udang" : [
		{0 : [0, 15], 1 : [0, 30], 2 : [0, 60], 3 : [0, 120]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],
		
	"worm" : [
		{0 : [0, 10], 1 : [0, 20], 2 : [0, 40], 3 : [0, 80]}, 
		{0 : 0.65, 1 : 0.2, 2 : 0.1, 3 : 0.05}],

} #nutrition_value_per_star [amount (0), nutrition], star_chance

var sprite_counter = preload("res://scenes/global/counter.tscn")

var item_inventory = preload("res://scenes/_item_inventory/item_inventory.tscn")

func stats_reset():
	customer_done = 0
	item_pickup_count = 0
	coins_earned = 0
	distance_traveled = 0
	item_cooked = 0

func reset_game():
	generated_interior = {}
	gen_wall_interior = {}
	gen_obj_interior = {}
	chunks = {}
	chunks_wall = {}
	chunks_obj = {}
	chunks_enemy = {}
	backpack_inventory = {}
	central_inventory = {}
	cooking_inventory = {}
	
	cur_cam_cooking = Vector2(196.0, 108.0)
	player_interior_out = Vector2(0,0)
	item_id = 0
	cam_coords = Vector2(0,0)
	player_last_loc = Vector2(0,0)
	is_mouse_dragging = false
	changing_scene = false
	is_interacting = false
	is_opening_inventory = false
	cur_interior = null
	cur_interior_size = 0
	cur_scene = "outside"
	is_exploring = true
	player_pos = Vector2(0,0)
	player_tile = Vector2i(0,0)
	player_chunk = Vector2i(0,0)
	_timer = 0
	central_item_list = {}
	cur_central_count_list = []
	item_count_central = null
	cooking_inventory_scene = null
	dialogue = null
	cooking_scene = null
	pelanggan_scene = null
	cooking_inventory_list = []
	cooking_target = 0
	cooking_obj = []
	target_nutrition = 0
	days_left = 5
	coins = 0
	mouse_cooldown = 0
	heart = null
	coin_icon = null
	item_put_backpack = []
	stats_reset()

	skip_dialogue = false
	item_list_amount = 0
	
	add_preset_item("belalang", randi_range(2, 6))
	add_preset_item("worm", randi_range(3, 5))
	add_preset_item("sarden", randi_range(1, 3))
	add_preset_item("sawdust", randi_range(3, 5))
	add_preset_item("rumput", randi_range(2, 4))
	for item_name in _item_nutrition:
		central_inventory[item_name] = _item_nutrition[item_name][0].duplicate_deep()
		
func _ready() -> void:
	reset_game()

func add_preset_item(item : String, amount : int):
	cooking_inventory[item] = _item_nutrition[item][0].duplicate_deep()
	cooking_inventory[item][0][0] = amount

func _process(delta: float) -> void:
	_timer += 1 * delta
	if mouse_cooldown > 0:
		mouse_cooldown -= delta
		
	if Input.is_action_just_pressed("right-hand"):
		if coin_icon != null: coin_icon.change_coin(-1)
		#if heart != null: heart.change_day(-1.0)
	elif Input.is_action_just_pressed("left-hand"):
		if coin_icon != null: coin_icon.change_coin(1)
		#if heart != null: heart.change_day(-1.0)
		
	if days_left <= 0: 
		reset_game()
		get_tree().change_scene_to_packed(main_menu)

func spawn_new_item(pos: Vector2, chunk_pos: Vector2i, item_name: String, item_nutrition : float = -1.0):
	var drop_item = item_drop.instantiate()
	drop_item.position = pos
	drop_item.item_name = item_name
	if item_nutrition == -1: 
		var _item_star = rng_calculator(_item_nutrition[item_name][1])
		var cur_nutrition = _item_nutrition[item_name][0][_item_star]
		drop_item.item_star = _item_star
		drop_item.item_nutrition = cur_nutrition[1]
	else: 
		drop_item.item_star = -1
		drop_item.item_nutrition = item_nutrition
		
	drop_item.item_id = "#" + str(item_id)
	drop_item.item_dur = 0
	if cur_scene == "outside": 
		drop_item.col_shape_enabled = true
		drop_item.chunk_pos = chunk_pos
		chunks_obj[chunk_pos].append(drop_item)
	elif cur_scene == "interior":
		gen_obj_interior[cur_interior].append(drop_item)
		drop_item.interior = cur_interior
	item_id += 1
	get_tree().current_scene.get_node("Ysort").add_child(drop_item)
	
	
	
func spawn_item(_item_id: String, pos: Vector2, chunk_pos: Vector2i, item_name: String, item_star: int, item_nutrition : float):
	var drop_item = item_drop.instantiate()
	drop_item.position = pos
	drop_item.item_name = item_name
	drop_item.item_star = item_star
	drop_item.item_nutrition = item_nutrition
	drop_item.item_id = _item_id
	drop_item.item_dur = 2
	drop_item.col_shape_enabled = true
	drop_item.show()
	if cur_scene == "outside": 
		drop_item.chunk_pos = chunk_pos
		chunks_obj[chunk_pos].append(drop_item)
	elif cur_scene == "interior":
		gen_obj_interior[cur_interior].append(drop_item)
		drop_item.interior = cur_interior
	get_tree().current_scene.get_node("Ysort").add_child(drop_item)

func add_item(object, chunk_pos : Vector2i, _item_id: String, item_name: String, item_star: int, item_nutrition: float):
	var item_backpack = item_inventory.instantiate()
	item_backpack.position = Vector2(randf_range(viewport_tree.size.x/2-20, viewport_tree.size.x/2+20), 0)
	item_backpack.item_id = _item_id
	item_backpack.item_name = item_name
	item_backpack.modulate += Color(1,0,1) * (pow(1.3, item_star)-1)
	backpack_inventory[_item_id] = [item_name, item_star, item_nutrition, item_backpack]
	chunks_obj[chunk_pos].erase(object)
	if !item_put_backpack.has(_item_id):
		item_put_backpack.append(_item_id)
		item_pickup_count += 1
		
	get_tree().current_scene.get_node("UI/backpack").call_deferred("add_child", item_backpack)

func remove_item(_item_id: String):
	var remove_index = backpack_inventory.find(_item_id)
	for i in range(2): backpack_inventory.remove_at(remove_index)
	
func _drop_item(_item_id: String):
	var item_desc = backpack_inventory[_item_id]
	backpack_inventory.erase(_item_id)
	spawn_item(_item_id, player_pos, player_chunk, item_desc[0], item_desc[1], item_desc[2])

func change_scene_to(to_scene, interior = null):	
	if to_scene == "interior" or to_scene == "outside": is_exploring = true
	else: 
		if is_exploring: 
			if to_scene == "central_inventory": convert_to_central_inv()
			
			if cur_scene == "interior": get_tree().current_scene.change_to_outside()
			elif cur_scene == "outside": player_last_loc = get_tree().current_scene.update_player_location()
		
		is_exploring = false
		
	dialogue.cur_state = state.READY
	dialogue.text_array.clear()
	var cooking_scene_list = ["customer", "cooking"]
	if !cooking_scene_list.has(to_scene) and cooking_scene_list.has(cur_scene) and !cooking_inventory.is_empty():
		add_cookinginv_centralinv()
		
	if to_scene == "central_inventory" and cur_scene != "central_inventory":
		cooking_invlist_queue_free()
		
	if to_scene == "customer" and !cooking_scene_list.has(cur_scene):
		pelanggan_scene.first = true
		pelanggan_scene.entered = false
		
	if to_scene == "cooking":
		get_tree().call_group("cooking_item_list", "_recount")
		
	if interior != null: cur_interior = interior
	cur_scene = to_scene
	changing_scene = true

func add_cookinginv_centralinv():
	for cur_item in cooking_inventory:
		for star in cooking_inventory[cur_item]:
			if central_inventory.has(cur_item):
				central_inventory[cur_item][star][0] += cooking_inventory[cur_item][star][0]
					
	cooking_inventory.clear()

func cooking_invlist_queue_free():
	for cur_obj in cooking_inventory_list:
		cur_obj.call_deferred("queue_free")
			
	cooking_inventory_list.clear()

func convert_to_central_inv():
	for _item_id in backpack_inventory:
		var item_name = backpack_inventory[_item_id][0]
		var item_star = backpack_inventory[_item_id][1]
		var item_obj = backpack_inventory[_item_id][3]
		if !central_inventory.has(item_name): central_inventory[item_name] = _item_nutrition[item_name][0].duplicate_deep()
		central_inventory[item_name][item_star][0] += 1
		item_obj.call_deferred("queue_free")
	backpack_inventory.clear()
	item_put_backpack.clear()
	
	for _item_name in central_inventory:
		var total_num : int = 0
		for _item_star in central_inventory[_item_name]:
			total_num += central_inventory[_item_name][_item_star][0]
		
		if central_item_list.has(_item_name): 
			var cur_obj = central_item_list[_item_name]
			if total_num <= 0: 
				cur_obj.hide()
			else:
				cur_obj.item_count = total_num
				cur_obj.show()
				
		else: central_item(_item_name, total_num)
	
func central_item(item_name: String, amount: int) -> void:
	if amount <= 0: return
	var central_inv_scene = get_tree().current_scene.get_node("UI/central_inventory")

	var item_central = item_inventory.instantiate()
	var _sprite_counter = sprite_counter.instantiate()
	item_central.position = viewport_tree.size/2 + Vector2(randi_range(-80,80), randi_range(-80,80))
	item_central.item_count = amount
	item_central.item_name = item_name
	_sprite_counter.target_obj = item_central
	central_inv_scene.call_deferred("add_child", item_central)
	central_inv_scene.call_deferred("add_child", _sprite_counter)
	central_item_list[item_name] = item_central

func rng_calculator(data):
	var cur_place = data
	var chance = 0
	var rand_num = randf_range(0, 1)
	for cur_data in cur_place:
		chance += cur_place[cur_data]
		if rand_num <= chance:
			return cur_data
			
func spawn_coins(amount: int, should_add : bool = true):
	if amount <= 0: return
	var cur_coin = coins_drop.instantiate()
	cur_coin.global_position = viewport_tree.size/2 + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	cur_coin.coin_amount = amount
	cur_coin.target_pos = Vector2(15, 205)
	cur_coin.should_add = should_add
	get_tree().current_scene.add_child(cur_coin)
