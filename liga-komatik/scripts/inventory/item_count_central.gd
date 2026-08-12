extends CanvasLayer

var item_central_interact = preload("res://scenes/inventory/item_central_interact.tscn")
@onready var cur_central_count_list = Global.cur_central_count_list

func _ready() -> void:
	Global.item_count_central = self
	
func create_items(item_name : String, amount : int):
	Global.item_list_amount = 0
	show()
	
	if !cur_central_count_list.is_empty(): 
		for obj in cur_central_count_list:
			obj.queue_free()
		cur_central_count_list.clear()
		
	cur_central_count_list.append(item_name)
	
	for i in range(amount):
		var item_list = item_central_interact.instantiate()
		item_list.item_name = item_name
		item_list.item_star = i
		Global.item_list_amount += 1
		cur_central_count_list.append(item_list)
		add_child(item_list)
