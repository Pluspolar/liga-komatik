extends Button

@onready var cur_central_count_list = Global.cur_central_count_list
@onready var cooking_inventory = Global.cooking_inventory
@onready var central_inventory = Global.central_inventory

var cos_sprite_counter := preload("res://scenes/global/costume_sprite_counter.tscn")
var counter := preload("res://scenes/global/counter.tscn")

func _ready() -> void:
	button_down.connect(_button_down)

func _process(delta: float) -> void:
	if is_hovered(): 
		scale.x += ((1.025+sin(Global._timer*3.1415)*0.05) - scale.x) * 15 * delta
		scale.y = scale.x
		rotation_degrees += (sin(Global._timer*4)*2 - rotation_degrees) * 15 * delta
	else: 
		scale += (Vector2(1,1) - scale) * 20 * delta 
		rotation_degrees += (0 - rotation_degrees) * 20 * delta

func _button_down():
	if cur_central_count_list.is_empty(): return
	Global.mouse_cooldown = 0.2
	
	var cur_item_name : String = cur_central_count_list[0]
	cur_central_count_list.remove_at(0)
	
	if !cooking_inventory.has(cur_item_name): 
		if cooking_inventory.size() >= 6: 
			Global.item_count_central.hide()
			return
		cooking_inventory[cur_item_name] = Global._item_nutrition[cur_item_name][0].duplicate_deep()
	
	Global.cooking_invlist_queue_free()
	
	var total_count : int = 0
	var total_count_pick : int = 0
	for cur_obj in cur_central_count_list:
		cooking_inventory[cur_item_name][cur_obj.item_star][0] = cur_obj.item_pick
		central_inventory[cur_item_name][cur_obj.item_star][0] = cur_obj.item_count
	
		total_count_pick += cur_obj.item_pick
		total_count += cur_obj.item_count
		
	if total_count_pick <= 0: cooking_inventory.erase(cur_item_name)
	Global.central_item_list[cur_item_name].item_count = total_count
	
	var count_idx = 0
	for _item_name in cooking_inventory:
		var total_num : int = 0
		for _item_star in cooking_inventory[_item_name]:
			total_num += cooking_inventory[_item_name][_item_star][0]
			
		var cur_obj = cos_sprite_counter.instantiate()
		var cur_counter = counter.instantiate()
		cur_obj.position = Vector2(15, 15 + count_idx*32.5)
		cur_obj.item_count = total_num
		cur_obj.play(_item_name)
		cur_counter.target_obj = cur_obj
		cur_obj.scale = Vector2(0.5, 0.5)
		cur_counter.scale = cur_obj.scale
		Global.cooking_inventory_list.append(cur_obj)
		Global.cooking_inventory_list.append(cur_counter)
		Global.cooking_inventory_scene.add_child(cur_obj)
		Global.cooking_inventory_scene.add_child(cur_counter)
		
		count_idx += 1
		
	Global.item_count_central.hide()
