extends Node

@onready var viewport_tree = get_tree().root.get_visible_rect()
@onready var chunk_size : int = 16
@onready var viewport_x_tile : int = viewport_tree.size.x/16
@onready var viewport_y_tile : int = viewport_tree.size.y/16
@onready var viewport_x_chunk : int = round(float(viewport_x_tile)/chunk_size)+1
@onready var viewport_y_chunk : int = round(float(viewport_y_tile)/chunk_size)+1

var generated_interior = {}
var gen_obj_interior = {}
var chunks = {}
var chunks_obj = {}
#var cur_chunk : Vector2i
var inventory = {}
var item_id : int = 0
var cam_coords : Vector2 = Vector2(0,0)
var item_drop = preload("res://scenes/__item_drop/can.tscn")
var item_inventory := {"can" : preload("res://scenes/_item_inventory/can.tscn")}
var is_mouse_dragging = false
var changing_scene = false
var is_interacting = false
var cur_interior
var cur_interior_size
var cur_scene = "outside"
var all_scenes = ["outside", "interior"]
var player_pos : Vector2
var player_tile : Vector2i
var player_chunk : Vector2i
var backpack_weight : float = 0
var show_tiles : Array = []
var _timer : float
	
func _process(delta: float) -> void:
	_timer += 1 * delta

func spawn_new_item(pos: Vector2, chunk_pos: Vector2i, item_name: String, item_weight: float):
	var drop_item = item_drop.instantiate()
	drop_item.position = pos
	drop_item.item_name = item_name
	drop_item.item_weight = item_weight
	drop_item.item_id = "#" + str(item_id)
	drop_item.item_dur = 0
	if cur_scene == "outside": 
		drop_item.chunk_pos = chunk_pos
		chunks_obj[chunk_pos].append(drop_item)
	elif cur_scene == "interior":
		gen_obj_interior[cur_interior].append(drop_item)
		drop_item.interior = cur_interior
	item_id += 1
	get_tree().current_scene.get_node("Ysort").add_child(drop_item)

func spawn_item(_item_id: String, pos: Vector2, chunk_pos: Vector2i, item_name: String, item_weight: float):
	var drop_item = item_drop.instantiate()
	drop_item.position = pos
	drop_item.item_name = item_name
	drop_item.item_weight = item_weight
	drop_item.item_id = _item_id
	drop_item.item_dur = 2
	drop_item.show()
	if cur_scene == "outside": 
		drop_item.chunk_pos = chunk_pos
		chunks_obj[chunk_pos].append(drop_item)
	elif cur_scene == "interior":
		gen_obj_interior[cur_interior].append(drop_item)
		drop_item.interior = cur_interior
	get_tree().current_scene.get_node("Ysort").add_child(drop_item)

func add_item(object, chunk_pos : Vector2i, _item_id: String, item_name: String, item_weight: float):
	var item_backpack = item_inventory["can"].instantiate()
	item_backpack.position = Vector2(randf_range(viewport_tree.size.x/2-20, viewport_tree.size.x/2+20), 0)
	item_backpack.item_id = _item_id
	inventory[_item_id] = [item_name, item_weight]
	backpack_weight += item_weight
	chunks_obj[chunk_pos].erase(object)
	get_tree().current_scene.get_node("UI/backpack").call_deferred("add_child", item_backpack)

func remove_item(_item_id: String):
	var remove_index = inventory.find(_item_id)
	for i in range(2): inventory.remove_at(remove_index)
	
func _drop_item(_item_id: String):
	var item_desc = inventory[_item_id]
	inventory.erase(_item_id)
	backpack_weight -= item_desc[1]
	spawn_item(_item_id, player_pos, player_chunk, item_desc[0], item_desc[1])

func change_scene_to(to_scene, interior):
	cur_scene = to_scene
	if interior != Node: cur_interior = interior
	changing_scene = true
	
