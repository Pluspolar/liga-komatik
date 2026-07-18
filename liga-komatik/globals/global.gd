extends Node

var inventory : Array = []
var item_id : int = 0
var item_drop = preload("res://scenes/item_drop.tscn")
var items := {"item_1" : preload("res://scenes/item_1.tscn")}
@onready var viewport = get_tree().root.get_visible_rect()
var is_mouse_dragging = false
var player_pos : Vector2
var backpack_weight : float = 0
	
func spawn_new_item(pos: Vector2, item_name: String, item_weight: float):
	var drop_item = item_drop.instantiate()
	drop_item.position = pos
	drop_item.item_name = item_name
	drop_item.item_weight = item_weight
	drop_item.item_id = "#" + str(item_id)
	drop_item.item_dur = 0
	item_id += 1
	get_tree().current_scene.get_node("Ysort").add_child(drop_item)

func spawn_item(_item_id: String, pos: Vector2, item_name: String, item_weight: float):
	var drop_item = item_drop.instantiate()
	drop_item.position = pos
	drop_item.item_name = item_name
	drop_item.item_weight = item_weight
	drop_item.item_id = _item_id
	get_tree().current_scene.get_node("Ysort").add_child(drop_item)

func add_item(_item_id: String, item_name: String, item_weight: float):
	var item_backpack = items["item_1"].instantiate()
	item_backpack.position = Vector2(randf_range(viewport.size.x/2-20, viewport.size.x/2+20), 0)
	#print(item_backpack.position)
	item_backpack.item_id = _item_id
	inventory.append(_item_id)
	inventory.append([item_name, item_weight])
	backpack_weight += item_weight
	get_tree().current_scene.get_node("backpack").call_deferred("add_child", item_backpack)
	#item_id += 1
	#return "#" + str(item_id-1)

func remove_item(_item_id: String):
	var remove_index = inventory.find(_item_id)
	for i in range(2): inventory.remove_at(remove_index)
	
func drop_item(_item_id: String):
	var item_index = inventory.find(_item_id)
	var item_desc = inventory[item_index+1]
	for i in range(2): inventory.remove_at(item_index)
	backpack_weight -= item_desc[1]
	spawn_item(_item_id, player_pos, item_desc[0], item_desc[1])
	#print(backpack_weight)
	
	
