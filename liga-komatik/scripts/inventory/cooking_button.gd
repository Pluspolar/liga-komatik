extends Button

func _ready() -> void:
	button_down.connect(_button_down)

func _process(delta: float) -> void:
	visible = !Global.item_count_central.visible
	if !visible: return
	if is_hovered(): modulate = Color(1, 1, 0.3)
	else: modulate = Color(1, 1, 1)
	
func _button_down():
	if Global.cooking_inventory.is_empty():
		Global.change_scene_to("outside")
	else:
		var total_amount = 0
		for obj in Global.cooking_inventory:
			for star in Global.cooking_inventory[obj]:
				total_amount += Global.cooking_inventory[obj][star][0]
		
		if total_amount <= 0: 
			Global.change_scene_to("outside")
		else: Global.change_scene_to("customer")
