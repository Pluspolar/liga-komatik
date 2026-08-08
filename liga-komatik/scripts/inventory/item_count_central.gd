extends CanvasLayer

var item_central_interact = preload("res://scenes/inventory/item_central_interact.tscn")
var central_item_list : Array = []

func _ready() -> void:
	Global.item_count_central = self
	
func create_items(item_name : String, amount : int):
	Global.item_list_amount = 0
	if !central_item_list.is_empty(): 
		for obj in central_item_list:
			obj.call_deferred("queue_free")
		central_item_list.clear()
		
	for i in range(amount):
		var item_list = item_central_interact.instantiate()
		item_list.item_name = item_name
		item_list.list_id = i
		Global.item_list_amount += 1
		central_item_list.append(item_list)
		add_child(item_list)
